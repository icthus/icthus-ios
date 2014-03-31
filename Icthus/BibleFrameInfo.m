//
//  BibleTextFrameInfo.m
//  Icthus
//
//  Created by Matthew Lorentz on 3/28/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "BibleFrameInfo.h"

@implementation BibleFrameInfo

@synthesize frame = _frame;
@synthesize ctFrame = _ctFrame;
@synthesize textRange = _textRange;
@synthesize lineRanges;
@synthesize chapters;
@synthesize verses;

- (void)setCtFrame:(CTFrameRef)ctFrame {
    if (_ctFrame) {
        CFRelease(_ctFrame);
    }
    _ctFrame = CFRetain(ctFrame);
}

- (CTFrameRef)ctFrame {
    return _ctFrame;
}

- (void)dealloc {
    if (_ctFrame) {
        CFRelease(_ctFrame);
    }
}

@end
