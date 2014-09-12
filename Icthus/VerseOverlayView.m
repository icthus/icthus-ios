//
//  VerseOverlayViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/20/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "VerseOverlayView.h"

@interface VerseOverlayView ()

@end

@implementation VerseOverlayView

@synthesize verseLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIToolbar* bgToolbar = [[UIToolbar alloc] initWithFrame:frame];
        bgToolbar.barStyle = UIBarStyleDefault;
        bgToolbar.layer.masksToBounds = YES;
        bgToolbar.layer.cornerRadius = 6.0;
        [self addSubview:bgToolbar];

        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            label.font = [UIFont fontWithName:@"AkzidenzGroteskCE-Roman" size:44];
        } else {
            label.font = [UIFont fontWithName:@"AkzidenzGroteskCE-Roman" size:40];
        }
        label.textAlignment = NSTextAlignmentCenter;
        self.verseLabel = label;
        [self addSubview:verseLabel];
    }
    return self;
}

- (void)updateLabelWithLocation:(BookLocation *)location {
    self.verseLabel.text = [NSString stringWithFormat:@"%@:%@", location.chapter, location.verse];
}

@end
