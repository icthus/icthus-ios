//
//  SwipingLeftImageView.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/24/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "SwipingLeftImageView.h"

@implementation SwipingLeftImageView

@synthesize shouldAnimate;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.shouldAnimate = NO;
        touchHover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Touch Icon Hover"]];
        touchHoverCenter = CGPointMake(self.frame.size.width / 2 - touchHover.frame.size.width / 2, self.frame.size.height / 2 - touchHover.frame.size.height / 2);
        touchHover.frame = CGRectMake(touchHoverCenter.x, touchHoverCenter.y, touchHover.frame.size.width, touchHover.frame.size.height);
        touchPressed = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Touch Icon Pressed"]];
        touchPressed.frame = CGRectMake(touchHoverCenter.x, touchHoverCenter.y, touchPressed.frame.size.width, touchPressed.frame.size.height);
    }
    
    return self;
}

- (void)startSwipeAnimations {
    self.shouldAnimate = YES;
    originalFrame = self.frame;
    [self addSubview:touchHover];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LULL_ANIMATION_LENGTH * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [touchHover removeFromSuperview];
        [self runMoveTouchIconAnimation];
    });
}

- (void)stopSwipeAnimations {
    self.shouldAnimate =  NO;
    [self.layer removeAllAnimations];
    self.frame = originalFrame;
}

- (void)runMoveTouchIconAnimation {
    [self addSubview:touchHover];
    [UIView animateWithDuration:TOUCH_MOVE_ANIMATION_LENGTH delay:LULL_ANIMATION_LENGTH options:UIViewAnimationOptionTransitionNone animations:^{
        touchHover.frame = CGRectMake(touchHoverCenter.x, touchHover.frame.origin.y, touchHover.frame.size.width, touchHover.frame.size.height);
    } completion:^(BOOL finished) {
        if (self.shouldAnimate) {
            [self runLeftSwipeAnimation];
        }
    }];
}

- (void)runLeftSwipeAnimation {
    [UIView animateWithDuration:SWIPE_ANIMATION_LENGTH animations:^{
        [touchHover removeFromSuperview];
        [self addSubview:touchPressed];
        self.frame = CGRectMake(self.frame.origin.x - abs(self.image.size.width - self.frame.size.width), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        if (self.shouldAnimate) {
            [self runReturnAnimation];
        }
        
    }];
}

- (void)runReturnAnimation {
    [touchPressed removeFromSuperview];
    [self addSubview:touchHover];
    [UIView animateWithDuration:RETURN_ANIMATION_LENGTH delay:0 usingSpringWithDamping:0.87 initialSpringVelocity:1 options:UIViewAnimationOptionTransitionNone animations:^{
        
        self.frame = CGRectMake(self.frame.origin.x + abs(self.image.size.width - self.frame.size.width), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        touchHover.frame = CGRectMake(touchHover.frame.origin.x - abs(self.image.size.width - self.frame.size.width), touchHover.frame.origin.y, touchHover.frame.size.width, touchHover.frame.size.height);
        
    } completion:^(BOOL finished) {
        [touchHover removeFromSuperview];
        if (self.shouldAnimate) {
            [self runMoveTouchIconAnimation];
        }
        
    }];
}

@end
