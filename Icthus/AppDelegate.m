//
//  AppDelegate.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "USFXParser.h"

@implementation AppDelegate 

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set up iCloud
    // TODO: check for a change in iCloud tokens
    id currentiCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (currentiCloudToken) {
        NSData *newTokenData =
        [NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken];
        [[NSUserDefaults standardUserDefaults]
         setObject: newTokenData
         forKey: @"ubiquityIdentityToken"];
    } else {
        [[NSUserDefaults standardUserDefaults]
         removeObjectForKey: @"ubiquityIdentityToken"];
    }

    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self selector: @selector (iCloudAccountAvailabilityChanged) name: NSUbiquityIdentityDidChangeNotification object:nil];
    [dc addObserver:self selector:@selector(storesWillChange:) name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:nil];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"appHasLaunchedBefore"] == nil) {
        [self handleFirstLaunch];
    }
    else {
        [self setupControllers];
    }
    return YES;
}

- (void)setupControllers {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers firstObject];
        [self setDetailView:(ReadingViewController *)[[splitViewController.viewControllers lastObject] topViewController]];
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (void)instantiateBooks {
    [[[USFXParser alloc] init] instantiateBooks:self.managedObjectContext translationCode:@"WEB" displayName:@"World English Bible"];
    [[[USFXParser alloc] init] instantiateBooks:self.managedObjectContext translationCode:@"ASV" displayName:@"American Standard Version"];
}

- (void)handleFirstLaunch {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ubiquityIdentityToken"]) {
        [self promptForiCloud];
    } else {
        [self finishHandlingFirstLaunch];
    }
}

- (void)finishHandlingFirstLaunch {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"WEB" forKey:@"selectedTranslation"];
    [prefs setBool:YES forKey:@"appHasLaunchedBefore"];
    [prefs synchronize];
    [self instantiateBooks];
    [self setupControllers];
}

- (void)promptForiCloud {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Use iCloud?" message: @"Would you like iCloud to keep your reading positions in sync across your devices?" delegate: self cancelButtonTitle: @"Local Only" otherButtonTitles: @"Use iCloud", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userWantsToUseiCloud"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"userWantsToUseiCloud"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    // We have to kill the persistentStoreCoordinator and managedObjectContext because they were created when the xibs were loaded.
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
    [self finishHandlingFirstLaunch];
}

- (void)iCloudAccountAvailabilityChanged {
    // TODO: handle changes in iCloud accounts
}

#pragma mark - Core Data stack

- (void)storesWillChange:(NSNotification *)n {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error;
    if ([moc hasChanges]) {
        [moc save:&error];
    }
    [moc reset];
    //TODO: reset user interface
}

- (void)mergeChangesFromiCloud:(NSNotification *)notification {
    
	NSLog(@"Merging in changes from iCloud...");
    
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    [moc performBlock:^{
        
        [moc mergeChangesFromContextDidSaveNotification:notification];
        
        NSNotification* refreshNotification = [NSNotification notificationWithName:@"underlyingDataChanged"
                                                                            object:self
                                                                          userInfo:[notification userInfo]];
        
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFromiCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        }];
        _managedObjectContext = moc;
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's mode	l.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Icthus" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if((_persistentStoreCoordinator != nil)) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    NSPersistentStoreCoordinator *psc = _persistentStoreCoordinator;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"userWantsToUseiCloud"]) {
        NSLog(@"using iCloud");
        
        // Two Configurations: Ubiquitous and Local
        // Ubiquitous:
        NSURL *iCloudURL = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"IcthusUbiquitousStore.sqlite"];

        NSDictionary *options = @{
            NSPersistentStoreUbiquitousContentNameKey: @"IcthusUbiquitousStore",
            NSMigratePersistentStoresAutomaticallyOption: [NSNumber numberWithBool:YES],
            NSInferMappingModelAutomaticallyOption: [NSNumber numberWithBool:YES],
        };
        
        NSError *error;
        [psc lock];
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:@"Ubiquitous" URL:iCloudURL options:options error:&error];
        [psc unlock];
        if (error) {
            NSLog(@"Error adding iCloud persistent store %@", [error localizedDescription]);
        }
        
        // Local
        NSURL *localStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IcthusLocalStore.sqlite"];
        
        options = @{
                     NSMigratePersistentStoresAutomaticallyOption: [NSNumber numberWithBool:YES],
                     NSInferMappingModelAutomaticallyOption: [NSNumber numberWithBool:YES],
                    };
        
        [psc lock];
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:@"Local" URL:localStoreURL options:options error:nil];
        [psc unlock];
    }
    else {
        NSLog(@"User hasn't chosen to use iCloud - using a local store with 'Default' configuration.");
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IcthusDefaultStore.sqlite"];
        
        NSDictionary *options = @{
            NSMigratePersistentStoresAutomaticallyOption: [NSNumber numberWithBool:YES],
            NSInferMappingModelAutomaticallyOption: [NSNumber numberWithBool:YES],
        };
        
        [psc lock];
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:@"Default" URL:storeURL options:options error:nil];
        [psc unlock];
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
