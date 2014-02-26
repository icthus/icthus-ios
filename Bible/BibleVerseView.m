//
//  BibleVerseView.m
//  Icthus
//
//  Created by Matthew Lorentz on 11/13/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BibleVerseView.h"

@implementation BibleVerseView
int gutterWidth = 70;

-(id)initWithContentFrame:(CGRect)contentFrame verses:(NSArray *)versesByLine chapters:(NSArray *)chaptersByLine andLineOrigins:(CGPoint[])origins withLength:(int)length andLineHeight:(CGFloat)lineHeight {
    
    CGRect frame = CGRectMake(0, 0, contentFrame.size.width + gutterWidth, contentFrame.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        for (int i = 0; i < length; i++) {
            CGFloat labelTop = frame.size.height - origins[i].y - lineHeight;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - gutterWidth, labelTop, gutterWidth, lineHeight)];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                label.font = [UIFont fontWithName:@"AkzidenzGroteskCE-Roman" size:22];
            }
            
            // align the baseline with the BibleTextView text
            CGRect newFrame = label.frame;
            newFrame.origin.y -= label.font.descender;
            label.frame = newFrame;
            
            NSArray *verses = [versesByLine objectAtIndex:i];
            NSArray *chapters = [chaptersByLine objectAtIndex:i];
            NSString *displayString;
            if ([verses count] == 1) {
                displayString = [NSString stringWithFormat:@"%@:%@", [chapters firstObject], [verses firstObject]];
            } else if ([verses count] > 1) {
                NSString *firstChapter = [chapters firstObject];
                NSString *lastChapter = [chapters lastObject];
                if ([firstChapter isEqualToString:lastChapter]) {
                    displayString = [NSString stringWithFormat:@"%@:%@-%@", firstChapter, [verses firstObject], [verses lastObject]];
                } else {
                    displayString = [NSString stringWithFormat:@"%@:%@-%@:%@", firstChapter, [verses firstObject], lastChapter, [verses lastObject]];
                }
            }
            label.text = displayString;
            [self addSubview:label];
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
