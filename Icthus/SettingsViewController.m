//
//  SettingsViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 3/19/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

@synthesize appDel;

- (void)viewDidLoad {
    [self subscribeToColorChangedNotification];
    self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: self.appDel.colorManager.titleTextColor,
    };
    self.tableView.backgroundColor = self.appDel.colorManager.bookBackgroundColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell class] == [SendMailTableViewCell class]) {
        [self presentMailViewController];
        [selectedCell setSelected:NO];
    } else if ([selectedCell class] == [ShowTutorialTableViewCell class]) {
        
        IcthusTutorialPageViewController *pageViewController;
        
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
            pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RegularTutorialPageViewController"];
        } else {
            pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CompactTutorialPageViewController"];
        }
        
    } else if ([selectedCell class] == [ToggleColorModeTableViewCell class]) {
        [(ToggleColorModeTableViewCell *)selectedCell toggleDarkMode];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = self.appDel.colorManager.bookBackgroundColor;
    cell.textLabel.textColor = self.appDel.colorManager.bookTextColor;
}

- (void)presentMailViewController {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setToRecipients:@[@"support@icthusapp.com"]];
        [self presentViewController:mailController animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No Mail Account Configured" message:@"You must configure a mail account before you can send email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    // Handle any errors here & check for controller's result as well
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)subscribeToColorChangedNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColorModeChanged) name:colorModeChangedNotification object:nil];
}

- (void)unsubscribeFromColorChangedNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleColorModeChanged {
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: self.appDel.colorManager.titleTextColor,
    };
    self.tableView.backgroundColor = self.appDel.colorManager.bookBackgroundColor;
    [self.tableView reloadData];
}

- (void)dealloc {
    [self unsubscribeFromColorChangedNotification];
}

@end
