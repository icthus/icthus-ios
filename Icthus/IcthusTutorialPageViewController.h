//
//  IcthusTutorialViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 4/17/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcthusTutorialViewController.h"

@interface IcthusTutorialPageViewController : UIPageViewController <UIPageViewControllerDataSource>

@property NSArray *tutorialViewControllers;

- (void)showNextViewController;
- (void)showPreviousViewController;

@end
