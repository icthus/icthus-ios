//
//  ColorManager.m
//  Icthus
//
//  Created by Matthew Lorentz on 6/28/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "ColorManager.h"

@implementation ColorManager

@synthesize navBarColor;
@synthesize tintColor;
@synthesize titleTextColor;
@synthesize bookTextColor;
@synthesize bookBackgroundColor;
@synthesize highlightedTextColor;
@synthesize navBarTranslucency;
@synthesize isDarkModeActivated;

- (id)init {
    self = [super init];
    if (self) {
        isDarkModeActivated = [[NSUserDefaults standardUserDefaults] boolForKey:@"showDarkMode"];
        if (isDarkModeActivated) {
            [self loadDarkScheme];
        } else {
            [self loadLightScheme];
        }
        
        navBarTranslucency = NO;
    }
    
    return self;
}

- (void)toggleDarkMode {
    self.isDarkModeActivated = !self.isDarkModeActivated;
    [[NSUserDefaults standardUserDefaults] setBool:self.isDarkModeActivated forKey:@"showDarkMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.isDarkModeActivated) {
        [self loadDarkScheme];
    } else {
        [self loadLightScheme];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:colorModeChangedNotification object:nil];
}

- (void)loadDarkScheme {
    tintColor = [UIColor colorWithRed:(71/255.0) green:(191/255.0) blue:(70/255.0) alpha:1.0];
    titleTextColor = [UIColor colorWithWhite:0.87 alpha:1.0];
    navBarColor = [UIColor colorWithWhite:0.258 alpha:1.0];
    bookTextColor  = [UIColor colorWithWhite:0.725 alpha:1.0];
    bookBackgroundColor = [UIColor colorWithWhite:0.1294 alpha:1.0];
    highlightedTextColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)loadLightScheme {
    tintColor = [UIColor colorWithRed:(0/255.0) green:(165/255.0) blue:(91/255.0) alpha:1.0];
    titleTextColor = [UIColor blackColor];
    navBarColor    = [UIColor colorWithWhite:1.0 alpha:0.1];
    bookTextColor  = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0];
    bookBackgroundColor = [UIColor whiteColor];
    highlightedTextColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

@end
