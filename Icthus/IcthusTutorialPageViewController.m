//
//  IcthusTutorialViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/17/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "IcthusTutorialPageViewController.h"
#import "AppDelegate.h"

@implementation IcthusTutorialPageViewController

- (void)viewDidLoad {
    
    
    // Set up the pages
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        self.pages = @[
                             [self.storyboard instantiateViewControllerWithIdentifier:@"RegularTutorialPage1"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"RegularTutorialPage2"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"RegularTutorialPage3"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"RegularTutorialPage4"],
                             ];
    } else {
        self.pages = @[
                             [self.storyboard instantiateViewControllerWithIdentifier:@"CompactTutorialPage1"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"CompactTutorialPage2"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"CompactTutorialPage3"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"CompactTutorialPage4"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"CompactTutorialPage5"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"CompactTutorialPage6"],
                             ];
    }
    
    // Make sure that this PageViewController is presented in portrait
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {

}

@end
