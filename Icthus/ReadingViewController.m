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

@synthesize appDel;
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
    
    self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = self.appDel.managedObjectContext;
    // Find the last book that was open and open to it.
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BookLocation" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    // Sort by lastModified
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModified" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    // Only fetch the most recent location
    [request setFetchLimit:1];

    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    if ([array count]) {
        [self setLocation:[array firstObject]];
    } else {
        // Default to Genesis 1:1
        NSFetchRequest *genesisRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        NSString *translationCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTranslation"];
        [genesisRequest setPredicate:[NSPredicate predicateWithFormat:@"code == %@ && translation == %@", @"GEN", translationCode]];
        array = [moc executeFetchRequest:genesisRequest error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        } else if ([array count]) {
            Book *genesis = [array firstObject];
            BookLocation *location = [NSEntityDescription insertNewObjectForEntityForName:@"BookLocation" inManagedObjectContext:moc];
            [location setBook:genesis chapter:1 verse:1];
            [self setLocation:location];
        }
    }
    
    tintColor = [UIColor colorWithRed:(0/255.0) green:(165/255.0) blue:(91/255.0) alpha:1.0];
    // Style the nav bar
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:1.0 alpha:0.7];
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
    UIImage *settingsIcon = [UIImage imageNamed:@"SettingsIcon"];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:settingsIcon style:UIBarButtonItemStylePlain target:self.appDel.masterView action:@selector(toggleSettingsPopover)];
    
    UIBarButtonItem *readingListButton = [[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStylePlain target:self.appDel.masterView action:@selector(toggleReadingListPopover)];

    [self.navigationItem setLeftBarButtonItems:@[settingsButton, readingListButton]];
    self.masterPopover = pc;
}

- (void)setBook:(Book *)newBook {
    _book = newBook;
    [self configureViewWithLocation:[newBook getLocation]];
}

- (void)setLocation:(BookLocation *)location {
    _book = location.book;
    [self configureViewWithLocation:location];
}

- (void)setTranslation:(Translation *)translation {
    if (_book) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"code == %@ && translation == %@", [_book code], [translation code]]];
        NSError *error;
        NSArray *array = [self.appDel.managedObjectContext executeFetchRequest:request error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);

        } else {
            _book = [array firstObject];
            [self configureViewWithLocation:[_book getLocation]];
        }
    }
}

- (void)configureViewWithLocation:(BookLocation *)location {
    // Update the user interface for the detail item.
    if (_book) {
        self.navigationItem.title = [_book shortName];
        if (!self.navigationController) {
            NSLog(@"navigation controller was lost");
        }
        [self.readingView setBook:_book];
        [self.readingView setText:[_book text]];
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
    [self configureViewWithLocation:[self.book getLocation]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.readingView saveCurrentLocation];
}



@end
