//
//  BookCollectionViewCell.m
//  Icthus
//
//  Created by Matthew Lorentz on 1/13/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "BookCollectionViewCell.h"

@implementation BookCollectionViewCell

@synthesize label;
@synthesize book;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.label.textColor = self.appDel.colorManager.bookTextColor;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.label.font = [UIFont fontWithName:@"Bariol-Regular" size:34.0f];
    } else {
        self.label.font = [UIFont fontWithName:@"Bariol-Regular" size:28.0f];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
