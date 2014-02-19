//
//  ReadingViewController.h
//  Bible
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "ReadingView.h"

@interface ReadingViewController : UIViewController <UISplitViewControllerDelegate>
-(id)initWithBook:(Book *)book;

@property (strong, nonatomic) IBOutlet ReadingView *readingView;
@property (nonatomic, strong) Book *book;
@property (retain, nonatomic) UIPopoverController *popoverController;

@end
