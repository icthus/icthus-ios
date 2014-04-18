//
//  IcthusTutorialViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 4/17/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IcthusTutorialPageViewController;

@interface IcthusTutorialViewController : UIViewController

@property IcthusTutorialPageViewController *pageViewController;
@property BOOL isFirstPage;
@property BOOL isLastPage;
@property UIButton *leftButton;
@property UIButton *rightButton;

- (void)dismissParentViewController;

@end
