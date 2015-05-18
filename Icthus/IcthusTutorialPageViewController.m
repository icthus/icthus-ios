//
//  IcthusTutorialViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/17/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "IcthusTutorialPageViewController.h"

@implementation IcthusTutorialPageViewController

- (void)viewDidLoad {
    // Set up the pages
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.pages = @[
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage1"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage2"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage3"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage4"],
                             ];
    } else {
        self.pages = @[
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage1"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage2"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage3"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage4"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage5"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage6"],
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
