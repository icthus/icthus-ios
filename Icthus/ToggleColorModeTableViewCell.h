//
//  ToggleColorModeTableViewCell.h
//  Icthus
//
//  Created by Matthew Lorentz on 7/30/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorManager.h"
#import "AppDelegate.h"

@interface ToggleColorModeTableViewCell : UITableViewCell

- (void)toggleDarkMode;

@property ColorManager *colorManager;

@end
