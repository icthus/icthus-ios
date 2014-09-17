//
//  AppDelegate.h
//  Icthus
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadingViewController.h"
#import "IcthusTutorialPageViewController.h"
#import "IcthusWhatsNewViewController.h"
@class ColorManager;
@class ReadingViewController;
@class MasterViewController;

#define CURRENT_DATABASE_VERSION 20
#define WHATS_NEW_VERSION 5

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) ReadingViewController *detailView;
@property (strong, nonatomic) MasterViewController *masterView;
@property (strong, nonatomic) ColorManager *colorManager;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
