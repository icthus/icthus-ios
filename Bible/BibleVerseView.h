//
//  BibleVerseView.h
//  Bible
//
//  Created by Matthew Lorentz on 11/13/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BibleVerseView : UIView

-(id)initWithContentFrame:(CGRect)contentFrame verses:(NSArray *)versesByLine chapters:(NSArray *)chaptersByLine andLineOrigins:(CGPoint[])origins withLength:(int)length andLineHeight:(CGFloat)lineHeight;

@end
