//
//  MasterViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "HistoryViewController.h"
#import "IcthusColorMode.h"

@class DetailViewController;
@class HistoryViewController;
@class AppDelegate;

@interface MasterViewController : UINavigationController <IcthusColorMode>

@property (strong, nonatomic) AppDelegate *appDel;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) UITableViewController *settingsViewController;
@property (strong, nonatomic) HistoryViewController *historyViewController;

- (void)showSettings;
- (void)toggleSettingsPopover;
- (void)toggleReadingListPopover;
- (void)subscribeToColorChangedNotification;
- (void)unsubscribeFromColorChangedNotification;
- (void)handleColorModeChanged;

@end
