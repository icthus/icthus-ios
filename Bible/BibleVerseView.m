//
//  BibleVerseView.m
//  Bible
//
//  Created by Matthew Lorentz on 11/13/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BibleVerseView.h"

@implementation BibleVerseView
int gutterWidth = 70;

-(id)initWithContentFrame:(CGRect)contentFrame verses:(NSArray *)versesByLine chapters:(NSArray *)chaptersByLine andLineOrigins:(CGPoint[])origins withLength:(int)length andLineHeight:(CGFloat)lineHeight {
    
    CGRect frame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y, contentFrame.size.width + gutterWidth, contentFrame.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        for (int i = 0; i < length; i++) {
            CGFloat labelTop = frame.size.height - origins[i].y - lineHeight;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - gutterWidth, labelTop, gutterWidth, lineHeight)];
            
            // align the baseline with the BibleTextView text
            CGRect newFrame = label.frame;
            newFrame.origin.y -= label.font.descender;
            label.frame = newFrame;
            
            NSArray *verses = [versesByLine objectAtIndex:i];
            if ([verses count] == 1) {
                NSString *displayString = [verses firstObject];
                label.text = displayString;
                [self addSubview:label];
            } else if ([verses count] > 1) {
                NSString *displayString = [NSString stringWithFormat:@"%@-%@", [verses firstObject], [verses lastObject]];
                label.text = displayString;
                [self addSubview:label];
            }
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
