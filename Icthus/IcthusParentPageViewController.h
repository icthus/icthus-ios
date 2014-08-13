//
//  IcthusParentPageViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 8/13/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcthusTutorialViewController.h"

@interface IcthusParentPageViewController : UIPageViewController <UIPageViewControllerDataSource>

@property NSArray *pages;

- (void)showNextViewController;
- (void)showPreviousViewController;

@end
