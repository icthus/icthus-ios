//
//  IcthusTutorialViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/17/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "IcthusTutorialViewController.h"
#import "Icthus-Swift.h"

@implementation IcthusTutorialViewController

@synthesize pageViewController = _pageViewController;
@synthesize isFirstPage = _isFirstPage;
@synthesize isLastPage = _isLastPage;
@synthesize leftButton;
@synthesize rightButton;
@synthesize animatedImage;

- (void)viewDidAppear:(BOOL)animated {
    if (self.animatedImage) {
        [self.animatedImage startAnimation];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.animatedImage) {
        [self.animatedImage stopAnimation];
    }
}

- (void)viewDidLoad {
    self.isLastPage = NO;
    
    // Create left side button
    self.leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:self.leftButton];
    
    // Create the right side button;
    self.rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:self.rightButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setupUserInterfaceElements];
}

- (void)setupUserInterfaceElements {
    NSLog(@"%ld", (long)[self traitCollection].horizontalSizeClass);
    
    // Remove old actions if they exist
    [self.rightButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = self.view.frame;
    CGFloat labelWidth, labelHeight, sideMargin, topMargin;
    UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    UIFont  *font;
    
    // Set button metrics;
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        font = [UIFont systemFontOfSize:17];
        labelWidth = 60;
        labelHeight = 21;
        sideMargin = 17;
        topMargin = 30;
        
        // Hack to correctly position labels on first launch
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shownTutorial"]) {
            topMargin += 20;
        }
        
    } else {
        font = [UIFont systemFontOfSize:13];
        labelWidth = 60;
        labelHeight = 21;
        sideMargin = 15;
        topMargin = 26;
    }
    
    
    self.rightButton.frame = CGRectMake(frame.size.width - labelWidth - sideMargin, topMargin, labelWidth, labelHeight);
    [self.rightButton setTitleColor:tintColor forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = font;
    self.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    if (self.isLastPage) {
        [self.rightButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(dismissParentViewController) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.rightButton setTitle:@"Next" forState:UIControlStateNormal];
        [self.rightButton addTarget:self.parentViewController action:@selector(showNextViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    self.leftButton.frame = CGRectMake(sideMargin, topMargin, labelWidth, labelHeight);
    [self.leftButton setTitleColor:tintColor forState:UIControlStateNormal];
    self.leftButton.titleLabel.font = font;
    self.leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    if (self.isFirstPage) {
        [self.leftButton setTitle:@"Dismiss" forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(dismissParentViewController) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.leftButton setTitle:@"Back" forState:UIControlStateNormal];
        [self.leftButton addTarget:self.parentViewController action:@selector(showPreviousViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSLog(@"%lu", (unsigned long)[self.view.subviews count]);
}

- (void)dismissParentViewController {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPageViewController:(IcthusParentPageViewController *)pageViewController {
    _pageViewController = pageViewController;
}

- (IcthusParentPageViewController *)pageViewController {
    return _pageViewController;
}

- (void)setIsFirstPage:(BOOL)isFirstPage {
    _isFirstPage = isFirstPage;
    [self setupUserInterfaceElements];
}

- (BOOL)isFirstPage {
    return _isFirstPage;
}

- (void)setIsLastPage:(BOOL)isLastPage {
    _isLastPage = isLastPage;
    [self setupUserInterfaceElements];
}

- (BOOL)isLastPage {
    return _isLastPage;
}



@end
