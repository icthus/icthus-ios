//
//  ToggleColorModeTableViewCell.m
//  Icthus
//
//  Created by Matthew Lorentz on 7/30/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "ToggleColorModeTableViewCell.h"

@implementation ToggleColorModeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)toggleDarkMode {
    ColorManager *colorManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] colorManager];
    [colorManager toggleDarkMode];
    if ([colorManager isDarkModeActivated]) {
        [self.textLabel setText:@"Light Mode"];
    } else {
        [self.textLabel setText:@"Dark Mode"];
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
