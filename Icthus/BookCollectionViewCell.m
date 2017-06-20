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
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.label.textColor = self.appDel.colorManager.bookTextColor;
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
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
