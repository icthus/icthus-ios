//
//  SwipingLeftImageView.h
//  Icthus
//
//  Created by Matthew Lorentz on 4/24/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SWIPE_ANIMATION_LENGTH 1.5
#define RETURN_ANIMATION_LENGTH 0.45
#define LULL_ANIMATION_LENGTH 1
#define TOUCH_MOVE_ANIMATION_LENGTH 0.4

@interface SwipingLeftImageView : UIImageView {
    UIImageView *touchHover;
    UIImageView *touchPressed;
    CGRect      originalFrame;
    CGPoint     touchHoverCenter;
}

@property BOOL shouldAnimate;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)startSwipeAnimations;
- (void)stopSwipeAnimations;
- (void)runMoveTouchIconAnimation;
- (void)runLeftSwipeAnimation;
- (void)runReturnAnimation;

@end
