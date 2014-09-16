//
//  VerseOverlayViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 8/20/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadingView.h"
#import "BookLocation.h"

@interface VerseOverlayView : UIView

@property UILabel *verseLabel;
@property CGFloat movementSensitivity;
@property NSTimeInterval timeInterval;

/* 
 The VerseOverlayViewController is a view that displays the current verse and chapter number,
 and is activated based on a few parameters defined in it's initializer. The VerseOverlayController
 expects to receive messages informing it of how much the user is scrolling, and if the user scrolls
 a certain number of pixels (the movement sensitivity) in the given time interval the 
 VerseOverlayController will display itself.
*/
- (id)initWithFrame:(CGRect)frame MovementSensitivity:(CGFloat)sensitity InTimeInterval:(NSTimeInterval)time;

/* 
 Tells the VerseOverlayViewController what verse and chapter to display 
*/
- (void)updateLabelWithLocation:(BasicBookLocation *)location;

/*
 Informs the VerseOverlayView how many points the user scrolled. Should be called
 from scrollViewDidScroll.
*/
- (void)userScrolledPoints:(CGFloat)points;

- (void)fadeIntoView;
- (void)fadeOutOfView;
- (void)reset;

@end
