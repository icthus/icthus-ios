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
#import "IcthusColorMode.h"
#import "VerseOverlayView.h"
#import "Icthus-Swift.h"

@interface ReadingViewController ()

@property UIBarButtonItem *settingsButton;

@end

@implementation ReadingViewController

@synthesize appDel;
@synthesize book = _book;
@synthesize masterPopover;
@synthesize chapterPickerPopover;
UIColor *tintColor;
CGRect previousFrame;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ColorManager *colorManager = self.appDel.colorManager;
    [self subscribeToColorChangedNotification];

    // Style the nav bar
    self.view.backgroundColor = colorManager.bookBackgroundColor;
    self.navigationController.navigationBar.tintColor = colorManager.tintColor;
    self.navigationController.navigationBar.translucent = colorManager.navBarTranslucency;
    self.navigationController.navigationBar.barTintColor = colorManager.navBarColor;
    UIFont *titleFont;
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        titleFont = [UIFont fontWithName:@"Avenir-Medium" size:22.0f];
    } else {
        titleFont = [UIFont fontWithName:@"Avenir-Medium" size:20.0f];
    }
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: colorManager.titleTextColor,
        NSFontAttributeName: titleFont,
    };
    
    // Style the Go To button
    if (self.goToButton) {
        self.goToButton.tintColor = colorManager.tintColor;
//        [self.goToButton setTitleTextAttributes:@{
//            NSFontAttributeName: [UIFont fontWithName:@"Bariol-Regular" size:23.0],
//        } forState:UIControlStateNormal];
    }
    
    // Start the NSUserActivity
    if(NSClassFromString(@"NSUserActivity")) {
        self.userActivity = [[NSUserActivity alloc] initWithActivityType:@"com.MattLorentz.Icthus.Reading"];
        self.userActivity.title = @"Reading";
        [self.userActivity becomeCurrent];
        [self setBookToLatest];
    }
}

- (BookLocation *)getLatestLocation {
    self.moc = self.appDel.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BookLocation" inManagedObjectContext:self.moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    // Sort by lastModified
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModified" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    // Only fetch the most recent location
    [request setFetchLimit:1];
    
    NSError *error;
    NSArray *array = [self.moc executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    if ([array count]) {
        return [array firstObject];
    } else {
        return nil;
    }
    
}

- (void)setBookToLatest {
    // Warning: This method does not save the current book before changing books.
    self.moc = self.appDel.managedObjectContext;
    // Find the last book that was open and open to it.
    BookLocation *location = [self getLatestLocation];
    if (location) {
        [self setLocation:location];
    } else {
        // Default to Genesis 1:1
        NSFetchRequest *genesisRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        NSString *translationCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTranslation"];
        [genesisRequest setPredicate:[NSPredicate predicateWithFormat:@"code == %@ && translation == %@", @"GEN", translationCode]];
        NSError *error;
        NSArray *array = [self.moc executeFetchRequest:genesisRequest error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        } else if ([array count]) {
            Book *genesis = [array firstObject];
            location = [NSEntityDescription insertNewObjectForEntityForName:@"BookLocation" inManagedObjectContext:self.moc];
            [location setBook:genesis chapter:1 verse:1];
            [self.moc save:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            [self setLocation:location];
        }
    }
}

- (id)initWithBook:(Book *)book {
    self = [super init];
    if (self) {
        self.book = book;
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
    if (self.book) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"code == %@ && translation == %@", [self.book code], [translation code]]];
        NSError *error;
        NSArray *array = [self.appDel.managedObjectContext executeFetchRequest:request error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);

        } else {
            self.book = [array firstObject];
            [self configureViewWithLocation:[self.book getLocation]];
        }
    }
}

- (void)configureViewWithLocation:(BookLocation *)location {
    // Update the user interface for the detail item.
    if (self.book) {
        self.navigationItem.title = [self.book shortName];
        if (!self.navigationController) {
            NSLog(@"navigation controller was lost");
        }
        
        [self.readingView setBook:self.book];
        [self.readingView setText:[self.book text]];
        [self.readingView setHorizontalSizeClass:self.traitCollection.horizontalSizeClass];
        [self.readingView buildFrames];
        [self.readingView setCurrentLocation:location];
        [self.readingView addVerseOverlayViewToViewHierarchy];
        NSLog(@"ReadingViewController: Changing book to %@ %@:%@", [self.book shortName], [location chapter], [location verse]);
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
    if ([[segue identifier] isEqualToString:@"showHistoryFromLeft"] || [[segue identifier] isEqualToString:@"showSettingsFromLeft"]) {
        [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        UIViewController *destination = segue.destinationViewController;
        [destination setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        destination.transitioningDelegate = self;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[SlideFromLeftPresentationController alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
     SlideFromLeftPresentationController *animator = [[SlideFromLeftPresentationController alloc] init];
    [animator setPresenting:false];
    return animator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewWithLocation:[self.book getLocation]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    if (!CGRectEqualToRect(previousFrame, self.view.frame)) {
        [self.readingView saveCurrentLocation];
        [self.readingView setHorizontalSizeClass:self.traitCollection.horizontalSizeClass];
        [self.readingView redrawText];
        previousFrame = self.view.frame;
        [self setBookToLatest];
    }
    
    // Set up the nav bar
    if (self.settingsButton == nil) {
        UIImage *settingsIcon = [UIImage imageNamed:@"SettingsIcon"];
        self.settingsButton = [[UIBarButtonItem alloc] initWithImage:settingsIcon style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTapped)];
    }
    
    // Remove the Settings button
    NSMutableArray<UIBarButtonItem *> *leftBarButtonItems = [[NSMutableArray alloc] initWithArray:self.navigationItem.leftBarButtonItems];
    [leftBarButtonItems removeObject:self.settingsButton];
    
    // Add it back if we have space
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        [leftBarButtonItems insertObject:self.settingsButton atIndex:0];
    }
    
    [self.navigationItem setLeftBarButtonItems:leftBarButtonItems];
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)viewWillDisappear:(BOOL)animated {
    // hack to fix a weird bug where self.book would be null on first launch on an 32-bit iPhone using iCloud.
    if (!self.book.managedObjectContext) {
        _book = (Book *)[self.moc objectWithID:self.book.objectID];
    }
    [self.readingView saveCurrentLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    if (![self.readingView.verseOverlayView superview]) {
        [self.readingView addVerseOverlayViewToViewHierarchy];
    }
}

- (void)subscribeToColorChangedNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColorModeChanged) name:colorModeChangedNotification object:nil];
}

- (void)unsubscribeFromColorChangedNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleColorModeChanged {
    ColorManager *colorManager = self.appDel.colorManager;
    self.view.backgroundColor = colorManager.bookBackgroundColor;
    self.navigationController.navigationBar.tintColor = colorManager.tintColor;
    self.navigationController.navigationBar.translucent = colorManager.navBarTranslucency;
    self.navigationController.navigationBar.barTintColor = colorManager.navBarColor;
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: colorManager.titleTextColor,
    };
    if (self.goToButton) {
        self.goToButton.tintColor = colorManager.tintColor;
    }
    [self setBookToLatest];
}

- (IBAction)goToButtonPressed:(id)sender {
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        [self performSegueWithIdentifier:@"showChapterPickerAsPopover" sender:self];
    } else {
        [self performSegueWithIdentifier:@"showChapterPickerModally" sender:self];
    }
}

- (void)settingsButtonTapped {
    [self performSegueWithIdentifier:@"showSettingsFromLeft" sender:self];
}

- (IBAction)userSwipedFromLeftEdge:(id)sender {
    [self performSegueWithIdentifier:@"showHistoryFromLeft" sender:self];
}

- (void)updateUserActivityState:(NSUserActivity *)activity {
    BasicBookLocation *location = [self.readingView getCurrentLocation];
    activity.userInfo = @{
                          @"bookCode": self.book.code,
                          @"chapter": [NSNumber numberWithInt:location->chapter],
                          @"verse": [NSNumber numberWithInt:location->verse],
                          };
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    if (action == @selector(unwindToReadingViewController:)) {
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)unwindToReadingViewController:(UIStoryboardSegue *)segue {
}

- (void)dealloc {
    [self unsubscribeFromColorChangedNotification];
    [self.userActivity invalidate];
}


@end
