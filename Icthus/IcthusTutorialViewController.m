//
//  IcthusTutorialViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/17/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "IcthusTutorialViewController.h"

@implementation IcthusTutorialViewController

@synthesize pageViewController = _pageViewController;
@synthesize isFirstPage = _isFirstPage;
@synthesize isLastPage = _isLastPage;
@synthesize leftButton;
@synthesize rightButton;

- (void)viewDidLoad {
    self.isLastPage = NO;
    [self setupUserInterfaceElements];
}

- (void)setupUserInterfaceElements {
    CGRect frame = self.view.frame;
    CGFloat labelWidth, labelHeight, sideMargin, topMargin;
    UIColor *tintColor = [UIColor colorWithRed:0 green:165/255.0 blue:91/255.0 alpha:1];
    UIFont  *font = [UIFont systemFontOfSize:17];
    
    // Set button metrics;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        labelWidth = 60;
        labelHeight = 21;
        sideMargin = 12;
        topMargin = 15;
        
    } else {
        labelWidth = 60;
        labelHeight = 21;
        sideMargin = 12;
        topMargin = 30;
    }
    
    // Create the right side button;
    if (!self.rightButton) {
        self.rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.view addSubview:self.rightButton];
    }
    self.rightButton.frame = CGRectMake(frame.size.width - labelWidth - sideMargin, topMargin, labelWidth, labelHeight);
    [self.rightButton setTitleColor:tintColor forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = font;
    self.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.rightButton removeTarget:self.parentViewController action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    if (self.isLastPage) {
        [self.rightButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(dismissParentViewController) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.rightButton setTitle:@"Next" forState:UIControlStateNormal];
        [self.rightButton addTarget:self.parentViewController action:@selector(showNextViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Create left side button
    if (!self.leftButton) {
        self.leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.view addSubview:self.leftButton];
    }
    self.leftButton.frame = CGRectMake(sideMargin, topMargin, labelWidth, labelHeight);
    [self.leftButton setTitleColor:tintColor forState:UIControlStateNormal];
    self.leftButton.titleLabel.font = font;
    self.leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.leftButton removeTarget:self.parentViewController action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    if (self.isFirstPage) {
        [self.leftButton setTitle:@"Dismiss" forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(dismissParentViewController) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.leftButton setTitle:@"Back" forState:UIControlStateNormal];
        [self.leftButton addTarget:self.parentViewController action:@selector(showPreviousViewController) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)dismissParentViewController {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPageViewController:(IcthusTutorialPageViewController *)pageViewController {
    _pageViewController = pageViewController;
    [self setupUserInterfaceElements];
}

- (IcthusTutorialPageViewController *)pageViewController {
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
