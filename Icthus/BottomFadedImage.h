//
//  BottomFadedImage.h
//  Icthus
//
//  Created by Matthew Lorentz on 4/23/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FADEHEIGHT  80.0
@interface BottomFadedImage : UIImage

+ (UIImage *)imageWithBottomFaded:(UIImage *)image WithFrame:(CGRect)frame;
    
@end
