//
//  BottomFadedImage.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/23/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "BottomFadedImage.h"

@implementation BottomFadedImage


+ (UIImage *)imageWithBottomFaded:(UIImage *)image WithFrame:(CGRect)frame {
    
    // Crop the image
    CGFloat scale = image.scale;
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    UIImage *gradientImage;
    if (currentContext) {
        CGContextTranslateCTM(currentContext, 0, frame.size.height);
        CGContextScaleCTM(currentContext, 1.0, -1.0);
        
        CGRect clippedRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        CGContextClipToRect(currentContext, clippedRect);
        
        CGContextTranslateCTM(currentContext, 0, frame.size.height - image.size.height);
        CGRect drawRect = CGRectMake(0, 0, image.size.width, image.size.height);
        CGContextDrawImage(currentContext, drawRect, image.CGImage);
        gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    
    NSLog(@"cropped size = %f x %f", gradientImage.size.width, gradientImage.size.height);
    // Add a gradient
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, scale);
    currentContext = UIGraphicsGetCurrentContext();
    if (currentContext) {
        CGContextClipToRect(currentContext, CGRectMake(0, 0, gradientImage.size.width, gradientImage.size.height));
        CGContextTranslateCTM(currentContext, 0, frame.size.height);
        CGContextScaleCTM(currentContext, 1.0, -1.0);
        CGContextDrawImage(currentContext, CGRectMake(0, 0, frame.size.width, frame.size.height), gradientImage.CGImage);
//
        CGColorRef whiteColor = [UIColor redColor].CGColor;
//        CGColorRef whiteColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
//        CGColorRef clearColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
        CGColorRef clearColor = [UIColor blueColor].CGColor;
        NSArray *colors = @[(__bridge id)whiteColor, (__bridge id)clearColor];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, nil);
//
//        CGFloat diff = abs(image.size.height - frame.size.height);
        CGPoint startPoint = CGPointMake(0, 0);
//        NSLog(@"diff = %f", diff);
        CGPoint endPoint = CGPointMake(0, FADEHEIGHT);
        CGContextDrawLinearGradient(currentContext, gradient, startPoint, endPoint, 0);
        gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return gradientImage;
}

@end
