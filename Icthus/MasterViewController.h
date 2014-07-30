//
//  MasterViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ReadingListViewController.h"

@class DetailViewController;
@class ReadingListViewController;
@class AppDelegate;

@interface MasterViewController : UINavigationController

@property (strong, nonatomic) AppDelegate *appDel;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) UITableViewController *settingsViewController;
@property (strong, nonatomic) ReadingListViewController *readingListViewController;

- (void)showSettings;
- (void)toggleSettingsPopover;
- (void)toggleReadingListPopover;

@end
