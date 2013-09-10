//
//  BibleTextView.m
//  Bible
//
//  Created by Matthew Lorentz on 9/5/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BibleTextView.h"
#import <CoreText/CoreText.h>

@implementation BibleTextView

@synthesize text;
@synthesize view;
@synthesize ctFrame;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
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
