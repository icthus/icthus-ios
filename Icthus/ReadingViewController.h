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
#import "Translation.h"
#import "ColorManager.h"
@class MasterViewController;
@class AppDelegate;

@interface ReadingViewController : UIViewController <IcthusColorMode, UIViewControllerTransitioningDelegate>
- (id)initWithBook:(Book *)book;
- (BookLocation *)getLatestLocation; // Gets the latest location from the database, not necessarily what ReadingView is displaying.
- (void)setBookToLatest;
- (void)setLocation:(BookLocation *)location;
- (void)setBook:(Book *)newBook;
- (void)setTranslation:(Translation *)translation;
- (void)subscribeToColorChangedNotification;
- (void)unsubscribeFromColorChangedNotification;
- (void)handleColorModeChanged;
- (IBAction)goToButtonPressed:(id)sender;
- (IBAction)userSwipedFromLeftEdge:(id)sender;

@property (strong, nonatomic) AppDelegate *appDel;
@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) IBOutlet ReadingView *readingView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *goToButton;
@property (strong, nonatomic) Book *book;
@property (strong, nonatomic) UIPopoverController *masterPopover;
@property (strong, nonatomic) UIPopoverController *chapterPickerPopover;

@end
