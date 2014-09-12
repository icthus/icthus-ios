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

@property UILabel* verseLabel;
- (id)initWithFrame:(CGRect)frame;
- (void)updateLabelWithLocation:(BookLocation *)location;

@end
