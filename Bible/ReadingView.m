//
//  ReadingView.m
//  Bible
//
//  Created by Matthew Lorentz on 9/9/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "ReadingView.h"
#import "BibleTextView.h"
#import <CoreText/CoreText.h>

@implementation ReadingView

@synthesize frames;
@synthesize attString;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = false;
    }
    return self;
}

-(void)setText:(NSString *)text {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:4];
    NSDictionary *attributesDict = [[NSDictionary alloc] initWithObjectsAndKeys:
        [UIFont fontWithName:@"Helvetica" size:19], NSFontAttributeName,
        paragraphStyle, NSParagraphStyleAttributeName,
        nil
    ];
    self.attString = [[NSAttributedString alloc] initWithString:text attributes:attributesDict];
    [self buildFrames];
}

- (void)buildFrames {
    self.frames = [NSMutableArray array];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    CGRect textFrame = CGRectInset(self.bounds, 10, 0);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    int textPos = 0;
    int contentOffset = 0;
    int pageIndex = 0;
    
    while (textPos < [attString length]) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textFrame);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        
        CGRect tmpFrame = CGRectMake(0, contentOffset, self.frame.size.width,self.frame.size.height);
        BibleTextView *content = [[BibleTextView alloc] initWithFrame:tmpFrame];

		//set the column view contents and add it as subview
        [content setCTFrame:frame];
        [self.frames addObject:content];
        [self addSubview:content];
        
        //prepare for next frame
        textPos += frameRange.length;
        CFRelease(path);
        pageIndex++;
        contentOffset += self.bounds.size.height;
    }
    
    //set the total width of the scroll view
    self.contentSize = CGSizeMake(self.bounds.size.width, (pageIndex + 1) * self.bounds.size.height);
}

@end
