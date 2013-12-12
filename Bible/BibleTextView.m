//
//  BibleTextView.m
//  Bible
//
//  Created by Matthew Lorentz on 9/5/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BibleTextView.h"
#import "ReadingView.h"
#import <CoreText/CoreText.h>

@implementation BibleTextView

@synthesize ctFrame;
@synthesize textRange = _textRange;
@synthesize parentView = _parentView;

- (id)initWithFrame:(CGRect)frame andTextRange:(NSRange)textRange andParent:(ReadingView *)parentView {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.textRange = textRange;
        self.parentView = parentView;
        
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
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        [self setCTFrame:frame];
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
}

@end
