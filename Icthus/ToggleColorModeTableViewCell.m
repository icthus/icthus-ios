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
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup {
    self.colorManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] colorManager];
    if ([self.colorManager isDarkModeActivated]) {
        [self.textLabel setText:@"Light Mode"];
    } else {
        [self.textLabel setText:@"Dark Mode"];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)toggleDarkMode {
    [self.colorManager toggleDarkMode];
    if ([self.colorManager isDarkModeActivated]) {
        [self.textLabel setText:@"Light Mode"];
    } else {
        [self.textLabel setText:@"Dark Mode"];
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Fixes a bug in iOS 7 where the cell separator will disappear
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = NO;
        }
    }
}

@end
