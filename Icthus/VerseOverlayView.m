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
@synthesize movementSensitivity;
@synthesize timeInterval;
NSTimer *timer;
CGFloat pointsMoved;

- (id)initWithFrame:(CGRect)frame MovementSensitivity:(CGFloat)sensitity InTimeInterval:(NSTimeInterval)time {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.allowsGroupOpacity = NO;
        self.movementSensitivity = sensitity;
        self.timeInterval = timeInterval;
        pointsMoved = 0;
        
        UIToolbar* blurredBackground = [[UIToolbar alloc] initWithFrame:frame];
        blurredBackground.barStyle = UIBarStyleDefault;
        blurredBackground.layer.masksToBounds = YES;
        blurredBackground.layer.cornerRadius = 6.0;
        [self addSubview:blurredBackground];

        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
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

- (void)updateLabelWithLocation:(BasicBookLocation *)location {
    self.verseLabel.text = [NSString stringWithFormat:@"%d:%d", location->chapter, location->verse];
}

- (void)userScrolledPoints:(CGFloat)points {
    pointsMoved += points;
//    NSLog(@"User scrolled %f points. Total points moved is now %f.", points, pointsMoved);
    if (pointsMoved >= self.movementSensitivity) {
        if (self.hidden) {
            [self fadeIntoView];
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(fadeOutOfView) userInfo:nil repeats:NO];
    }
}

- (void)fadeIntoView {
    self.hidden = NO;
    self.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)fadeOutOfView {
//    NSLog(@"VerseOverlayView fading out");
    pointsMoved = 0;
    if (!self.hidden && [self.layer.animationKeys count] == 0) {
        [UIView animateWithDuration:.2 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            self.alpha = 1.0;
        }];
    }
}

- (void)reset {
    self.hidden = YES;
    pointsMoved = 0;
    if (timer) {
        [timer invalidate];
    }
}

@end
