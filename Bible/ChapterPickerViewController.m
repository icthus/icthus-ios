//
//  ChapterPickerViewController.m
//  Bible
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

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder");
    
    self = [super initWithCoder: aDecoder];
    if (self)
    {
        _appDel = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [_appDel managedObjectContext];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedBook = nil;
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([self isBookAtIndexPath:indexPath]) {
            return CGSizeMake(293, 84);
        } else {
            return CGSizeMake(64, 64);
        }
    } else {
        if ([self isBookAtIndexPath:indexPath]) {
            return CGSizeMake(319, 61);
        } else {
            return CGSizeMake(61, 61);
        }
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
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
        [label setText:[NSString stringWithFormat:@"%d", chapterNumber]];
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
        selectedBook = book;
        NSLog(@"User selected book %@", book.shortName);
        NSLog(@"Book has %i chapters", [book.numberOfChapters intValue]);
        [self.collectionView reloadData];
    } else {
        self.selectedChapter = index - chapterRange.location + 1;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self updateLocationAndShowChapter];
        }
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
        BookLocation *location = [selectedBook getLocation];
        location.chapter = [NSNumber numberWithInteger:selectedChapter];
        location.verse   = [NSNumber numberWithInt:1];
        NSError *error;
        [_managedObjectContext save:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        [_appDel.detailView setBook:(Book *)selectedBook];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shortName" ascending:YES];
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

@end
