//
//  IcthusTutorialViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 4/17/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IcthusParentPageViewController;
@class SwipingLeftImageView;

@interface IcthusTutorialViewController : UIViewController

@property IcthusParentPageViewController *pageViewController;
@property BOOL isFirstPage;
@property BOOL isLastPage;
@property UIButton *leftButton;
@property UIButton *rightButton;

// Couldn't figure out how to forward declare a Swift protocol so I had to use the implementation class here.
@property IBOutlet SwipingLeftImageView *animatedImage;

- (void)dismissParentViewController;

@end
