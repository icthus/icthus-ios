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

-(id)initWithContentFrame:(CGRect)contentFrame verses:(NSArray *)versesByLine chapters:(NSArray *)chaptersByLine andLineOrigins:(CGPoint[])origins withLength:(int)length {
    
    CGRect frame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y, contentFrame.size.width + gutterWidth, contentFrame.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        for (int i = 0; i < length; i++) {
            CGPoint origin = origins[i];
            NSLog(@"origin: (%f, %f)", origin.x, origin.y);
            CGRect labelFrame = CGRectMake(self.frame.size.width - gutterWidth, self.frame.size.height - origin.y, gutterWidth, 20);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            
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
