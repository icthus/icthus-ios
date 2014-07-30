//
//  SettingsViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 3/19/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendMailTableViewCell.h"
#import "ShowTutorialTableViewCell.h"
#import "IcthusTutorialPageViewController.h"
#import "MasterViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "ToggleColorModeTableViewCell.h"
#import "IcthusColorMode.h"
@class AppDelegate;

@interface SettingsViewController : UITableViewController <MFMailComposeViewControllerDelegate, IcthusColorMode>

- (void)presentMailViewController;
- (void)subscribeToColorChangedNotification;
- (void)unsubscribeFromColorChangedNotification;
- (void)handleColorModeChanged;

@property AppDelegate *appDel;

@end
