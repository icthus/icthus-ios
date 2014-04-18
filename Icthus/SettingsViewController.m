//
//  SettingsViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 3/19/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell class] == [SendMailTableViewCell class]) {
        [self presentMailViewController];
    } else if ([selectedCell class] == [ShowTutorialTableViewCell class]) {
        IcthusTutorialPageViewController *pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
        [(MasterViewController *)self.navigationController toggleSettingsPopover];
        [self presentViewController:pageViewController animated:YES completion:nil];
        
    }
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

@end
