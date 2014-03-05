//
//  CircleLabel.h
//  Icthus
//
//  Created by Matthew Lorentz on 3/5/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CircleLabel : UIView

- (id)initWithTextFrame:(CGRect)frame text:(NSString *)text;
@property UILabel *label;
@property CGFloat diameter;
@property UIColor *backgroundColor;
@property UIColor *foregroundColor;

@end
