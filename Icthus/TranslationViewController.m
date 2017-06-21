//
//  TranslationViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 10/17/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "TranslationViewController.h"
#import "Translation.h"
#import "Icthus-Swift.h"

@interface TranslationViewController ()

@end

@implementation TranslationViewController
@synthesize appDel = _appDel;
@synthesize managedObjectContext = _managedObjectContext;

NSString *selectedTranslation;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = [_appDel managedObjectContext];
        selectedTranslation = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTranslation"];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder");
    
    self = [super initWithCoder: aDecoder];
    if (self)
    {
        _appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = [_appDel managedObjectContext];
        selectedTranslation = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTranslation"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = self.appDel.colorManager.bookBackgroundColor;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TranslationTableViewCell";
    TranslationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[TranslationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    // Configure the cell...
    Translation *trans = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.translation = trans;
    if ([[trans code] isEqualToString:selectedTranslation]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell showCopyrightButton];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Translation *trans = [self.fetchedResultsController objectAtIndexPath:indexPath];
    selectedTranslation = [trans code];
    [[NSUserDefaults standardUserDefaults] setObject:selectedTranslation forKey:@"selectedTranslation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.appDel.detailView setTranslation:trans];
    [self performSegueWithIdentifier:@"unwindToReadingViewController" sender:self];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Translation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Translations"];
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



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showCopyright"] &&
        [sender class] == [CopyrightButton class] &&
        [[segue destinationViewController] class] == [CopyrightViewController class]) {
        ((CopyrightViewController *)segue.destinationViewController).translation = ((CopyrightButton *)sender).translation;
    } else {
        NSLog(@"Error: TranslationViewController could not segue to CopyrightViewController properly");
    }
}

@end
