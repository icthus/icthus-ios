//
//  ChapterPickerViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "ChapterPickerViewController.h"
#import "Book.h"
#import "ReadingViewController.h"
#import "BookCollectionViewCell.h"
#import "ChapterCollectionViewCell.h"
#import "BookLocation.h"

@interface ChapterPickerViewController()

@end

@implementation ChapterPickerViewController

@synthesize appDel = _appDel;
@synthesize selectedBook;
@synthesize selectedChapter;
@synthesize finishedAnimations;
BOOL isFirstTimeViewDidLayoutSubviews;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder");
    
    self = [super initWithCoder: aDecoder];
    if (self) {
        _appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = [_appDel managedObjectContext];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Don't overlap the iPhone X Notch
    if (@available(iOS 11.0, *)) {
        [self.collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
    }
    
    [self subscribeToColorChangedNotification];
    isFirstTimeViewDidLayoutSubviews = YES;
    if (self.navigationController && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationController.navigationBar.titleTextAttributes = @{
            NSFontAttributeName: [UIFont fontWithName:@"Avenir-Roman" size:22.0f],
            NSForegroundColorAttributeName: self.appDel.colorManager.titleTextColor,
        };
    }
    // TODO: Set background color of popover view controller
    self.collectionView.backgroundColor = self.appDel.colorManager.bookBackgroundColor;

    selectedBook = nil;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (isFirstTimeViewDidLayoutSubviews) {
        // Set the contentOffset to the currently displayed book
        NSIndexPath *index = [self.fetchedResultsController indexPathForObject:self.appDel.detailView.book];
        [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        isFirstTimeViewDidLayoutSubviews = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItems = 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    if (selectedBook) {
        numberOfItems = (NSInteger)[sectionInfo numberOfObjects] + [selectedBook.numberOfChapters integerValue];
    } else {
        numberOfItems = (NSInteger)[sectionInfo numberOfObjects];
    }
    return numberOfItems;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat viewWidth = self.view.frame.size.width;
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        if ([self isBookAtIndexPath:indexPath]) {
            return CGSizeMake(viewWidth, 54);
        } else {
            CGFloat idealCellWidth = 56;
            int cellsPerRow = floor(viewWidth / idealCellWidth);
            CGFloat cellWidth = idealCellWidth + (fmod(viewWidth, idealCellWidth) / cellsPerRow) - 0.001;
            return CGSizeMake(cellWidth, 54);
        }
    } else {
        if ([self isBookAtIndexPath:indexPath]) {
            return CGSizeMake(viewWidth, 42);
        } else {
            CGFloat idealCellWidth = 56;
            int cellsPerRow = floor(viewWidth / idealCellWidth);
            CGFloat cellWidth = idealCellWidth + (fmod(viewWidth, idealCellWidth) / cellsPerRow) - 0.001;
            return CGSizeMake(cellWidth, 42);
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bookIdentifier = @"BookCollectionViewCell";
    static NSString *chapterIdentifier = @"ChapterCollectionViewCell";
    UICollectionViewCell *uiCollectionViewCell;
    
    // Determine whether we should make a book or chapter cell
    NSRange chapterRange = [self getChapterRange];
    NSUInteger index = [indexPath item];
    if ([self isBookAtIndexPath:indexPath]) {
        BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:bookIdentifier forIndexPath:indexPath];
        if (index > chapterRange.location) {
            NSUInteger actualIndexArray[2] = { 0, index - chapterRange.length };
            indexPath = [[NSIndexPath alloc] initWithIndexes:actualIndexArray length:2];
        }
        Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UILabel *label = cell.label;
        [label setText:book.shortName];
        uiCollectionViewCell = cell;
    } else {
        ChapterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:chapterIdentifier forIndexPath:indexPath];
        UILabel *label = cell.label;
        NSUInteger chapterNumber = index - chapterRange.location + 1;
        [label setText:[NSString stringWithFormat:@"%lu", (unsigned long)chapterNumber]];
        uiCollectionViewCell = cell;
    }
    
    return uiCollectionViewCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [indexPath item];
    NSRange chapterRange = [self getChapterRange];
    if ([self isBookAtIndexPath:indexPath]) {
        if (index > chapterRange.location) {
            NSUInteger actualIndexArray[2] = { 0, index - chapterRange.length };
            indexPath = [[NSIndexPath alloc] initWithIndexes:actualIndexArray length:2];
        }
        Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        self.finishedAnimations = 0;
        if ([selectedBook isEqual:book]) {
            // This is the second time the user tapped the book. Remove the chapters.
            [self.collectionView performBatchUpdates:^{
                NSArray *indexPaths = [self indexPathsForChapters];
                self.selectedBook = nil;
                [self.collectionView deleteItemsAtIndexPaths:indexPaths];
            } completion:nil];
        } else {
            if (selectedBook) {
                // There was another book selected
                // Delete old chapters
                [self.collectionView performBatchUpdates:^{
                    NSArray *indexPaths = [self indexPathsForChapters];
                    self.selectedBook = nil;
                    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
                } completion:^(BOOL finished) {
                    @synchronized(self.finishedAnimations) {
                        self.finishedAnimations = [NSNumber numberWithInt:[self.finishedAnimations intValue] + 1];
                        if ([self.finishedAnimations intValue] >= 2) {
                            [self scrollCellIntoViewIfNeeded];
                            self.finishedAnimations = 0;
                        }
                    }
                }];
            } else {
                // Let the other block know not to wait on animations
                self.finishedAnimations = [NSNumber numberWithInt:1];
            }
            
            // Insert the new chapters
            selectedBook = book;
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:[self indexPathsForChapters]];
            } completion:^(BOOL finished){
                @synchronized(self.finishedAnimations) {
                    self.finishedAnimations = [NSNumber numberWithInt:[self.finishedAnimations intValue] + 1];
                    if ([self.finishedAnimations intValue] >= 2) {
                        [self scrollCellIntoViewIfNeeded];
                        self.finishedAnimations = 0;
                    }
                }
            }];
        }
    } else {
        self.selectedChapter = index - chapterRange.location + 1;
        [self updateLocationAndShowChapter];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showChapter"]) {
        [self updateLocationAndShowChapter];
    }
}

- (void)updateLocationAndShowChapter {
    NSIndexPath *chapterIndexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
    NSRange chapterRange = [self getChapterRange];
    self.selectedChapter = [chapterIndexPath item] - chapterRange.location + 1;
    BookLocation *location = [selectedBook setLocationChapter:selectedChapter verse:1];
    [_appDel.detailView setLocation:location];
    [self performSegueWithIdentifier:@"unwindToReadingViewController" sender:self];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Find only Books for the current translation
    NSString *translationCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTranslation"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"translation == '%@'", translationCode]]];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Books"];
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

-(BOOL)isBookAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isBook = NO;
    
    if (selectedBook) {
        NSRange chapterRange = [self getChapterRange];
        if (NSLocationInRange([indexPath item], chapterRange)) {
            isBook = NO;
        } else {
            isBook = YES;
        }
    } else {
        isBook = YES;
    }
    
    return isBook;
}

- (NSRange)getChapterRange {
    if (selectedBook) {
        return NSMakeRange([[self.fetchedResultsController indexPathForObject:selectedBook] item] + 1, [selectedBook.numberOfChapters integerValue]);
    } else {
        return NSMakeRange(0,0);
    }
}

- (NSArray *)indexPathsForChapters {
    NSRange chapterRange = [self getChapterRange];
    NSMutableArray *chapterIndexPaths = [[NSMutableArray alloc] initWithCapacity:chapterRange.length];
    for (NSUInteger i = chapterRange.location; i < chapterRange.location + chapterRange.length; i++) {
        NSUInteger indexes[2] = {0, i};
        NSIndexPath *path = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
        [chapterIndexPaths addObject:path];
    }
    return chapterIndexPaths;
}

- (void)scrollCellIntoViewIfNeeded {
    // Get the cell of the selectedBook
    NSIndexPath *selectedBookPath = [self.fetchedResultsController indexPathForObject:self.selectedBook];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:selectedBookPath];
    
    // Get the number of total books
    // If the selectedBook is the last book then we need to scroll it into view.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][selectedBookPath.section];
    NSInteger numberOfBooks = (NSInteger)[sectionInfo numberOfObjects];
    
    if (![[self.collectionView visibleCells] containsObject:cell] || selectedBookPath.item == numberOfBooks - 1) {
        [self.collectionView scrollToItemAtIndexPath:selectedBookPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}


- (void)subscribeToColorChangedNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColorModeChanged) name:colorModeChangedNotification object:nil];
}

- (void)unsubscribeFromColorChangedNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleColorModeChanged {
    // TODO: Set background color of popover view controller
    self.collectionView.backgroundColor = self.appDel.colorManager.bookBackgroundColor;
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSFontAttributeName: [UIFont fontWithName:@"Avenir-Roman" size:22.0f],
        NSForegroundColorAttributeName: self.appDel.colorManager.titleTextColor,
    };
    [self.collectionView reloadData];
}

- (void)dealloc {
    [self unsubscribeFromColorChangedNotification];
}
@end
