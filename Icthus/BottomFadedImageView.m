//
//  BottomFadedImageView.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/23/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "BottomFadedImageView.h"

@implementation BottomFadedImageView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Create the fade at the bottom
        self.image = [BottomFadedImage imageWithBottomFaded:self.image WithFrame:self.frame];
    }
    return self;
}


@end
