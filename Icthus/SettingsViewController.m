//
//  SettingsViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 3/19/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

- (IBAction)recentBooksPressed:(id)sender {
    [(MasterViewController *)self.navigationController showRecentBooks];
}
@end
