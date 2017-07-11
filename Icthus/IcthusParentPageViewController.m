//
//  IcthusParentPageViewController.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/13/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "IcthusParentPageViewController.h"

@interface IcthusParentPageViewController ()

@end

@implementation IcthusParentPageViewController

@synthesize pages;

- (void)viewDidLoad {
    self.dataSource = self;
    self.view.backgroundColor = [UIColor whiteColor];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    for (IcthusTutorialViewController *viewController in self.pages) {
        [viewController setPageViewController:self];
    }
    
    if ([self.pages count] >= 1) {
        [(IcthusTutorialViewController *)[self.pages firstObject] setIsFirstPage:YES];
        [(IcthusTutorialViewController *)[self.pages lastObject] setIsLastPage:YES];
    }
    [self setViewControllers:@[[self.pages firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
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
    NSUInteger index = [self.pages indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    } else if (index >= [self.pages count] - 1) {
        return nil;
    } else {
        IcthusTutorialViewController *controller = [self.pages objectAtIndex:index + 1];
        
        // Let this view controller know that it is the last page.
        if ([self.pages count] == index + 2) {
            [controller setIsLastPage:YES];
        }
        
        return controller;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.pages indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    } else if (index == 0) {
        return nil;
    } else {
        return [self.pages objectAtIndex:index - 1];
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.pages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return [self.pages indexOfObject:[self.viewControllers firstObject]];
}

@end
