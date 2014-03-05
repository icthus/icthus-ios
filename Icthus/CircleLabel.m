//
//  CircleLabel.m
//  Icthus
//
//  Created by Matthew Lorentz on 3/5/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "CircleLabel.h"

@implementation CircleLabel {
}

@synthesize label;
@synthesize diameter;
@synthesize backgroundColor;
@synthesize foregroundColor = _foregroundColor;

- (id)initWithTextFrame:(CGRect)frame text:(NSString *)text {
    // Make a square out of the textFrame, and make our frame
    // big enough to draw a circle around the textFrame
    CGFloat size, diff;
    if (frame.size.height <= frame.size.width) {
        size = frame.size.height * sqrt(2);
        diff = size - frame.size.height;
    } else {
        size = frame.size.width * sqrt(2);
        diff = size - frame.size.width;
    }
    CGRect newFrame = CGRectMake(frame.origin.x - diff, frame.origin.y - diff, frame.size.width + diff * 2, frame.size.height + diff * 2);
    self = [super initWithFrame:newFrame];
    if (self) {
        self.diameter = size;
        self.opaque = NO;
        
        UILabel *l = [[UILabel alloc] initWithFrame:frame];
        self.label = l;
        l.font = [UIFont fontWithName:@"AkzidenzGroteskCE-Roman" size:22];
        l.adjustsFontSizeToFitWidth = NO;
        l.textColor = [UIColor whiteColor];
        l.text = text;
        [l sizeToFit];
        [self addSubview:l];
    }
    return self;
}

- (void)setForegroundColor:(UIColor *)aColor {
    _foregroundColor = aColor;
    self.label.textColor = aColor;
}

- (UIColor *)foregroundColor {
    return _foregroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.center = CGPointMake(self.diameter * 0.5f, self.diameter * 0.5f);
}

- (void)drawRect:(CGRect)rect {
    [self.backgroundColor setFill];
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.diameter, self.diameter)].CGPath;
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = self.backgroundColor.CGColor;
    [self.layer addSublayer:circle];
}
@end
