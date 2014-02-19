//
//  AppDelegate.h
//  Bible
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadingViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) ReadingViewController *detailView;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
