//
//  ChapterCollectionViewCell.m
//  Icthus
//
//  Created by Matthew Lorentz on 1/25/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "ChapterCollectionViewCell.h"

@implementation ChapterCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.label.highlightedTextColor = self.appDel.colorManager.highlightedTextColor;
    self.label.textColor = self.appDel.colorManager.bookTextColor;
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        self.label.font = [UIFont fontWithName:@"Bariol-Regular" size:34.0f];
    } else {
        self.label.font = [UIFont fontWithName:@"Bariol-Regular" size:28.0f];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    self.label.highlighted = highlighted;
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
