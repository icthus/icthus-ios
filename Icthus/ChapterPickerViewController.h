//
//  ChapterPickerViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Book.h"
#import "IcthusColorMode.h"

@interface ChapterPickerViewController: UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, IcthusColorMode>

@property (nonatomic, strong) AppDelegate *appDel;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, atomic) Book *selectedBook;
@property (nonatomic) NSUInteger selectedChapter;
@property (atomic) NSNumber *finishedAnimations;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *dismissButton;

- (void)subscribeToColorChangedNotification;
- (void)unsubscribeFromColorChangedNotification;
- (void)handleColorModeChanged;


@end
