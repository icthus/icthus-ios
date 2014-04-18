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

@interface SettingsViewController : UITableViewController <MFMailComposeViewControllerDelegate>

- (void)presentMailViewController;

@end
