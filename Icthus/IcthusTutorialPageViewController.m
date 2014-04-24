//
//  IcthusTutorialViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/17/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "IcthusTutorialPageViewController.h"

@implementation IcthusTutorialPageViewController

@synthesize tutorialViewControllers;

- (void)viewDidLoad {
    self.dataSource = self;
    self.view.backgroundColor = [UIColor whiteColor];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    // Set up the pages
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.tutorialViewControllers = @[
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage1"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage2"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage3"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage4"],
                             ];
    } else {
        self.tutorialViewControllers = @[
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage1"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage2"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage3"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage4"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage5"],
                             [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage6"],
                             ];
    }
    for (IcthusTutorialViewController *viewController in self.tutorialViewControllers) {
        [viewController setPageViewController:self];
    }
    [(IcthusTutorialViewController *)[self.tutorialViewControllers firstObject] setIsFirstPage:YES];
    [(IcthusTutorialViewController *)[self.tutorialViewControllers lastObject] setIsLastPage:YES];
    [self setViewControllers:@[[self.tutorialViewControllers firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)showNextViewController {
    UIViewController *next = [self pageViewController:self viewControllerAfterViewController:[self.viewControllers firstObject]];
    [self setViewControllers:@[next] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)showPreviousViewController {
    UIViewController *previous = [self pageViewController:self viewControllerBeforeViewController:[self.viewControllers firstObject]];
    [self setViewControllers:@[previous] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self.tutorialViewControllers indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    } else if (index >= [self.tutorialViewControllers count] - 1) {
        return nil;
    } else {
        return [self.tutorialViewControllers objectAtIndex:index + 1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.tutorialViewControllers indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    } else if (index == 0) {
        return nil;
    } else {
        return [self.tutorialViewControllers objectAtIndex:index - 1];
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.tutorialViewControllers count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return [self.tutorialViewControllers indexOfObject:[self.viewControllers firstObject]];
}

@end
