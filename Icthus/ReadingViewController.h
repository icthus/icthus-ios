//
//  ReadingViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "ReadingView.h"
#import "MasterViewController.h"
@class MasterViewController;
@class AppDelegate;

@interface ReadingViewController : UIViewController <UISplitViewControllerDelegate>
- (id)initWithBook:(Book *)book;
- (void)setLocation:(BookLocation *)location;

@property (strong, nonatomic) AppDelegate *appDel;
@property (strong, nonatomic) IBOutlet ReadingView *readingView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *goToButton;
@property (nonatomic, strong) Book *book;
@property (strong, nonatomic) UIPopoverController *masterPopover;
@property (strong, nonatomic) UIPopoverController *chapterPickerPopover;

@end
