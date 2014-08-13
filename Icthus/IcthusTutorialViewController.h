//
//  IcthusTutorialViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 4/17/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipingLeftImageView.h"
@class IcthusParentPageViewController;

@interface IcthusTutorialViewController : UIViewController

@property IcthusParentPageViewController *pageViewController;
@property BOOL isFirstPage;
@property BOOL isLastPage;
@property UIButton *leftButton;
@property UIButton *rightButton;
@property (strong, nonatomic) IBOutlet SwipingLeftImageView *animatedImage;

- (void)dismissParentViewController;

@end
