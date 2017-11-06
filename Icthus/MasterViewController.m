//
//  MasterViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@implementation MasterViewController

@synthesize appDel;

- (void)awakeFromNib {
    self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Style the nav bar
    [self subscribeToColorChangedNotification];
    ColorManager *colorManager = self.appDel.colorManager;
    self.navigationBar.tintColor = colorManager.tintColor;
    self.navigationBar.translucent = colorManager.navBarTranslucency;
    self.navigationBar.barTintColor = colorManager.navBarColor;
    UIFont *titleFont;
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        titleFont = [UIFont fontWithName:@"Avenir-Medium" size:22.0f];
    } else {
        titleFont = [UIFont fontWithName:@"Avenir-Medium" size:20.0f];
    }
    
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor greenColor],
        NSFontAttributeName: titleFont
    };
    
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        self.historyViewController = (HistoryViewController *)self.topViewController;
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.settingsViewController = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    } else {
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.settingsViewController = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    }
}


- (void)toggleSettingsPopover {
    self.viewControllers = @[self.settingsViewController];
    [self.splitViewController performSelector:@selector(toggleMasterVisible:) withObject:nil];
}

- (void)toggleReadingListPopover {
    self.viewControllers = @[self.historyViewController];
    [self.splitViewController performSelector:@selector(toggleMasterVisible:) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)subscribeToColorChangedNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColorModeChanged) name:colorModeChangedNotification object:nil];
}

- (void)unsubscribeFromColorChangedNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleColorModeChanged {
    ColorManager *colorManager = self.appDel.colorManager;
    self.navigationBar.tintColor = colorManager.tintColor;
    self.navigationBar.translucent = colorManager.navBarTranslucency;
    self.navigationBar.barTintColor = colorManager.navBarColor;
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor greenColor]
    };
}

- (void)dealloc {
    [self unsubscribeFromColorChangedNotification];
}

@end
