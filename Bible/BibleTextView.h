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
#import "BibleVerseView.h"

@interface BibleTextView : UIView {
    @private BibleVerseView *verseView;
}

@property CTFrameRef ctFrame;
@property NSRange textRange;
@property ReadingView *parentView;
@property NSArray *chapters;
@property NSArray *verses;

-(void)setCTFrame:(CTFrameRef)f;
-(id)initWithFrame:(CGRect)frame TextRange:(NSRange)textRange Parent:(ReadingView *)parentView Chapters:(NSArray *)chapters AndVerses:(NSArray *)verses;

@end
