//
//  ReadingViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "ReadingViewController.h"
#import "ReadingView.h"
#import "BookLocation.h"
#import "AppDelegate.h"

@interface ReadingViewController ()

@end

@implementation ReadingViewController

@synthesize book = _book;
@synthesize masterPopover;
@synthesize chapterPickerPopover;
UIColor *tintColor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)awakeFromNib {
    self.splitViewController.delegate = self;
    
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDel.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:moc];
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
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:fetchRequest error:&error];
    if (array == nil)
    {
        // Deal with error...
    } else {
        [self setBook:[array firstObject]];
    }
    
    tintColor = [UIColor colorWithRed:(0/255.0) green:(165/255.0) blue:(91/255.0) alpha:1.0];
    // Style the nav bar
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0],
        NSFontAttributeName: [UIFont fontWithName:@"Avenir-Medium" size:22.0f],
    };
    
    // Style the Go To button
    if (self.goToButton) {
        self.goToButton.tintColor = tintColor;
        [self.goToButton setTitleTextAttributes:@{
//            NSFontAttributeName: [UIFont fontWithName:@"Bariol-Regular" size:23.0],
        } forState:UIControlStateNormal];
    }
}

- (id)initWithBook:(Book *)book {
    self = [super init];
    if (self) {
        _book = book;
    }
    return self;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopover = nil;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = @"Menu";
    [barButtonItem setTitleTextAttributes:@{
//        NSFontAttributeName: [UIFont fontWithName:@"Bariol-Regular" size:23.0],
    } forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopover = pc;
}

- (void)setBook:(Book *)newBook {
    if (_book != newBook) {
        _book = newBook;
        [_book setReading:[NSNumber numberWithBool:YES]];
        NSManagedObjectContext *context = [(NSManagedObject *)_book managedObjectContext];
        NSError *error;
        [context save:&error];
        if (error != nil) {
            NSLog(@"An error occured during save");
            NSLog(@"%@", [error localizedDescription]);
        }
        
        // Update the view.
        [self configureView];
    }
    
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (_book) {
        self.navigationItem.title = [_book shortName];
        if (!self.navigationController) {
            NSLog(@"navigation controller was lost");
        }
        [self.readingView setBook:_book];
        [self.readingView setText:[_book text]];
        BookLocation *location = [_book getLocation];
        [self.readingView setCurrentLocation:location];
        NSLog(@"ReadingViewController: Changing book to %@ %@:%@", [_book shortName], [location chapter], [location verse]);
    }
    
    if (self.masterPopover != nil) {
        [self.masterPopover dismissPopoverAnimated:YES];
    }
    if (self.chapterPickerPopover != nil) {
        [self.chapterPickerPopover dismissPopoverAnimated:YES];
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showChapterPickerPopover"]) {
        if (self.chapterPickerPopover.popoverVisible) {
            [self.chapterPickerPopover dismissPopoverAnimated:YES];
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showChapterPickerPopover"]) {
        self.chapterPickerPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.readingView saveLocation];
}



@end
