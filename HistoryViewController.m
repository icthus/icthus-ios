//
//  ReadingListViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "HistoryViewController.h"
#import "ReadingViewController.h"
#import "Book.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController
@synthesize appDel = _appDel;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder");
    
    self = [super initWithCoder: aDecoder];
    if (self) {
        _appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    [self subscribeToColorChangedNotification];
    self.tableView.backgroundColor = self.appDel.colorManager.bookBackgroundColor;
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: self.appDel.colorManager.titleTextColor,
    };

    if (self.presentingViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    } else {        
        UIImage *settingsIcon = [UIImage imageNamed:@"SettingsIcon"];
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:settingsIcon style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTapped)];
        self.navigationItem.rightBarButtonItem = settingsButton;
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
        self.navigationItem.leftBarButtonItem = backButton;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self setEditing:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        height = 60;
    } else {
        height = 50;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BookLocation *location = (BookLocation *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    [location setLastModified:[NSDate date]];
    NSManagedObjectContext *moc = location.managedObjectContext;
    NSError *error;
    [moc save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [_appDel.detailView setLocation:(BookLocation *)location];    
    [self performSegueWithIdentifier:@"unwindToReadingViewController" sender:self];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BookLocation *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Book *book = location.book;
    
    // Format the bookNameString
    UIFont *bookNameFont;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        bookNameFont = [UIFont fontWithName:@"Bariol-Regular"size:27];
    } else {
        bookNameFont = [UIFont fontWithName:@"Bariol-Regular"size:19];
    }
    cell.textLabel.text = book.shortName;
    cell.textLabel.font = bookNameFont;
    cell.backgroundColor = self.appDel.colorManager.bookBackgroundColor;
    cell.textLabel.textColor = self.appDel.colorManager.bookTextColor;
    
    // Format the locationString
    NSString *locationString = [[NSString alloc] initWithFormat:@"%@:%@", location.chapter, location.verse];
    
    UIFont *locationFont;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        locationFont = [UIFont fontWithName:@"Bariol-Regular"size:27];
    } else {
        locationFont = [UIFont fontWithName:@"Bariol-Regular"size:19];
    }
    
    cell.detailTextLabel.text = locationString;
    cell.detailTextLabel.font = locationFont;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showChapter"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BookLocation *location = (BookLocation *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        [(ReadingViewController *)[segue destinationViewController] setLocation:location];
    }
}

- (void)settingsButtonTapped {
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

- (void)backButtonTapped {
    [self performSegueWithIdentifier:@"unwindToReadingViewController" sender:self];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    [NSFetchedResultsController deleteCacheWithName:@"ReadingList"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BookLocation" inManagedObjectContext:self.appDel.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModified" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.appDel.managedObjectContext sectionNameKeyPath:nil cacheName:@"ReadingList"];
    self.fetchedResultsController = aFetchedResultsController;
    [self.fetchedResultsController setDelegate:self];
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BookLocation *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.appDel.managedObjectContext deleteObject:location];
        NSError *error;
        [self.appDel.managedObjectContext save:&error];
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
            
        // Delete the row from the data source
        self.fetchedResultsController = nil;
        [self.fetchedResultsController performFetch:&error];
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)subscribeToColorChangedNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColorModeChanged) name:colorModeChangedNotification object:nil];
}

- (void)unsubscribeFromColorChangedNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleColorModeChanged {
    self.tableView.backgroundColor = self.appDel.colorManager.bookBackgroundColor;
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: self.appDel.colorManager.titleTextColor,
    };
}

- (void)dealloc {
    [self unsubscribeFromColorChangedNotification];
}

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

@end
