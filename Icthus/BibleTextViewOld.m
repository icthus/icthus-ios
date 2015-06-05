//
//  BibleTextViewOld.m
//  Icthus
//
//  Created by Matthew Lorentz on 9/5/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BibleTextViewOld.h"
#import "Icthus-Swift.h"
#import "BibleVerseViewOld.h"
#import <CoreText/CoreText.h>
#import "ReadingViewOld.h"

@implementation BibleTextViewOld

BibleVerseViewOld *verseView;
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
        self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.backgroundColor = self.appDel.colorManager.bookBackgroundColor;
        
        // This is all duplicate code from ReadingScrollView->buildFrames. Make sure they stay the same or bad things will happen.
        // Build the ctFrame that we can draw when necessary
        NSAttributedString *attString = [self.parentView.attString attributedSubstringFromRange:self.textRange];
        CGRect textFrame;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            textFrame = CGRectInset(self.bounds, 50, 0);
        } else {
            textFrame = CGRectInset(self.bounds, 15, 0);
        }
        
        CGFloat lineHeight = [self.parentView lineHeightForString:attString];
        textFrame.size.height = lineHeight * 50;
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textFrame);
        CTFrameRef ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        [self setCtFrame:ctframe];
        // TODO: Fix this so that we are not just duplicating the ctFrame made in ReadingScrollView.buildFrames();
//        [self setCtFrame:frameInfo.ctFrame];
        
        [self refreshVerseView];
    }
    return self;
}

- (void)refreshVerseView {
    if (verseView) {
        [verseView removeFromSuperview];
    }
    
    // make the BibleVerseViewOld
    if ([self.chapters count] && [self.verses count]) {
        CFArrayRef lines = CTFrameGetLines(self.ctFrame);
        int length = CFArrayGetCount(lines);
        CGPoint origins[length];
        CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), origins);
        CGFloat lineHeight = [self.parentView.sizingString boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height) options:0 context:nil].size.height;
        
        verseView = [[BibleVerseViewOld alloc] initWithContentFrame:self.frame verses:self.verses chapters:self.chapters andLineOrigins:origins withLength:length andLineHeight:lineHeight];
        [self addSubview:verseView];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetFillColorWithColor(context, [self.appDel.colorManager.bookTextColor CGColor]);
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

@end
