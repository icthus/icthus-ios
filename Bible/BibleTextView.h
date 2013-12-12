//
//  BibleTextView.h
//  Bible
//
//  Created by Matthew Lorentz on 9/5/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "ReadingView.h"

@interface BibleTextView : UIView

@property CTFrameRef ctFrame;
@property NSRange textRange;
@property ReadingView *parentView;

-(void)setCTFrame:(CTFrameRef)f;
- (id)initWithFrame:(CGRect)frame andTextRange:(NSRange)textRange andParent:(ReadingView *)parentView;

@end
