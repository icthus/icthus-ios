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
@synthesize ctFrame = _ctFrame;
@synthesize textRange = _textRange;
@synthesize parentView = _parentView;
@synthesize chapters = _chapters;
@synthesize verses = _verses;

- (id)initWithFrameInfo:(BibleFrameInfo *)frameInfo andParent:(ReadingView *)parentView {
    self = [super initWithFrame:frameInfo.frame];
    if (self) {
        self.opaque = NO;
        self.textRange = frameInfo.textRange;
        self.parentView = parentView;
        self.chapters = frameInfo.chapters;
        self.verses = frameInfo.verses;
        
        // Build the ctFrame that we can draw when necessary
        NSAttributedString *attString = [self.parentView.attString attributedSubstringFromRange:self.textRange];
        CGRect textFrame;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            textFrame = CGRectInset(self.bounds, 50, 0);
        } else {
            textFrame = CGRectInset(self.bounds, 15, 0);
        }
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textFrame);
        CTFrameRef ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        [self setCtFrame:ctframe];
        // TODO: Fix this so that we are not just duplicating the ctFrame made in ReadingView.buildFrames();
//        [self setCtFrame:frameInfo.ctFrame];
        
        [self refreshVerseView];
    }
    return self;
}

- (void)refreshVerseView {
    if (verseView) {
        [verseView removeFromSuperview];
    }
    
    // make the BibleVerseView
    if ([self.chapters count] && [self.verses count]) {
        CFArrayRef lines = CTFrameGetLines(self.ctFrame);
        int length = CFArrayGetCount(lines);
        CGPoint origins[length];
        CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), origins);
        CGFloat lineHeight = [self.parentView.sizingString boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height) options:0 context:nil].size.height;
        
        verseView = [[BibleVerseView alloc] initWithContentFrame:self.frame verses:self.verses chapters:self.chapters andLineOrigins:origins withLength:length andLineHeight:lineHeight];
        [self addSubview:verseView];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw(self.ctFrame, context);

}

- (void)setCtFrame:(CTFrameRef)ctFrame {
    if (_ctFrame) {
        CFRelease(_ctFrame);
    }
    _ctFrame = CFRetain(ctFrame);
}

- (CTFrameRef)ctFrame {
    return _ctFrame;
}

-(void)dealloc {
    [verseView removeFromSuperview];
    verseView = nil;
    if (_ctFrame) {
        CFRelease(_ctFrame);
    }
}

@end
