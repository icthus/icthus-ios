//
//  BibleTextView.m
//  Icthus
//
//  Created by Matthew Lorentz on 9/5/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BibleTextView.h"
#import "ReadingView.h"
#import "BibleVerseView.h"
#import <CoreText/CoreText.h>

@implementation BibleTextView

BibleVerseView *verseView;
@synthesize ctFrame;
@synthesize textRange = _textRange;
@synthesize parentView = _parentView;
@synthesize chapters = _chapters;
@synthesize verses = _verses;


- (id)initWithFrame:(CGRect)frame TextRange:(NSRange)textRange Parent:(ReadingView *)parentView Chapters:(NSArray *)chapters AndVerses:(NSArray *)verses {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.textRange = textRange;
        self.parentView = parentView;
        self.chapters = chapters;
        self.verses = verses;
        
        // Build the ctFrame that we can draw when necessary
        NSAttributedString *attString = [self.parentView.attString attributedSubstringFromRange:self.textRange];
        CGRect textFrame;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            textFrame = CGRectInset(self.bounds, 50, 0);
        } else {
            textFrame = CGRectInset(self.bounds, 10, 0);
        }
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textFrame);
        CTFrameRef ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        [self setCTFrame:ctframe];
        
        // make the BibleVerseView
        if ([chapters count] && [verses count]) {
            CGFloat lineHeight = [attString boundingRectWithSize:CGSizeMake(textFrame.size.width, textFrame.size.height) options:0 context:nil].size.height;
            CFArrayRef lines = CTFrameGetLines(ctframe);
            int length = CFArrayGetCount(lines);
            CGPoint origins[length];
            CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), origins);
        
            verseView = [[BibleVerseView alloc] initWithContentFrame:frame verses:verses chapters:chapters andLineOrigins:origins withLength:length andLineHeight:lineHeight];
            [self addSubview:verseView];
        }
    }
    return self;
}

-(void)setCTFrame:(CTFrameRef) f {
    ctFrame = f;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw((CTFrameRef)ctFrame, context);

}

-(void)dealloc {
    CFRelease(ctFrame);
    [verseView removeFromSuperview];
    verseView = nil;
}

@end
