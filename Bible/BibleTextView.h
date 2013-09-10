//
//  BibleTextView.h
//  Bible
//
//  Created by Matthew Lorentz on 9/5/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface BibleTextView : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIView *view;
@property CTFrameRef ctFrame;

-(void)setCTFrame:(CTFrameRef)f;

@end
