//
//  ColorManager.h
//  Icthus
//
//  Created by Matthew Lorentz on 6/28/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IcthusColorMode.h"

@interface ColorManager : NSObject

@property UIColor *navBarColor;
@property UIColor *tintColor;
@property UIColor *titleTextColor;
@property UIColor *bookTextColor;
@property UIColor *bookBackgroundColor;
@property UIColor *highlightedTextColor;
@property BOOL navBarTranslucency;
@property BOOL isDarkModeActivated;

- (id)init;
- (void)toggleDarkMode;

@end
