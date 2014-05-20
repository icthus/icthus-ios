//
//  AppDelegate.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"

@implementation AppDelegate 

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Subscribe to Core Data notifications
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self selector: @selector (iCloudAccountAvailabilityChanged) name: NSUbiquityIdentityDidChangeNotification object:nil];
    [dc addObserver:self selector:@selector(storesWillChange:) name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:nil];
    [dc addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    // Handle first launch
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"appHasLaunchedBefore"] == nil) {
        [self handleFirstLaunch];
    }
    else {
        [self setupControllers];
    }
    
    [self.window makeKeyAndVisible];
    
    // Show latest version of tutorial if we haven't yet
    if (![defaults boolForKey:@"shownTutorial"]) {
        [self showTutorial];
    }
    
    return YES;
}

- (void)handleFirstLaunch {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"WEB" forKey:@"selectedTranslation"];
    [prefs setObject:[NSNumber numberWithInt:1] forKey:@"databaseVersion"];
    [prefs setObject:[NSNumber numberWithInt:1] forKey:@"whatsNewVersion"];
    [prefs setBool:YES forKey:@"appHasLaunchedBefore"];
    [self setupControllers];
    [self showTutorial];
    [prefs synchronize];
}


- (void)setupControllers {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        [self setDetailView:(ReadingViewController *)[[splitViewController.viewControllers lastObject] topViewController]];
        [self setMasterView:(MasterViewController *)[splitViewController.viewControllers firstObject]];

        // Call UISplitViewControllerDelegate method again so that bar button items work. Hack.
        [self.detailView splitViewController:splitViewController willHideViewController:nil withBarButtonItem:nil forPopoverController:self.detailView.masterPopover];
    } else {
        [self setMasterView:(MasterViewController *)self.window.rootViewController];
        [self setDetailView:(ReadingViewController *)self.masterView.topViewController];
    }
    
    [self.detailView setBookToLatest];
}

- (void)showTutorial {
    IcthusTutorialPageViewController *pageViewController = [self.detailView.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
    [self.detailView presentViewController:pageViewController animated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shownTutorial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
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

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"mergedChangesFromiCloud" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSLog(@"Successfully merged iCloud data");
        [self.detailView setBookToLatest];
        completionHandler(UIBackgroundFetchResultNewData);
    }];
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

#pragma mark - Core Data stack

- (void)storesWillChange:(NSNotification *)n {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSError *error;
    if ([moc hasChanges]) {
        if (![NSThread isMainThread]) {
            [self performSelectorOnMainThread:@selector(storesWillChange:) withObject:n waitUntilDone:YES];
        } else {
            [moc save:&error];
            [moc reset];
        }
    }
}

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    if (notification.object != self.managedObjectContext) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }
}

- (void)iCloudAccountAvailabilityChanged {
    _persistentStoreCoordinator = nil;
    // TODO: handle changes in iCloud accounts
}

- (void)mergeChangesFromiCloud:(NSNotification *)notification {
    
	NSLog(@"Merging in changes from iCloud...");
    
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    [moc performBlock:^{
        
        [moc mergeChangesFromContextDidSaveNotification:notification];
        
        NSNotification* refreshNotification = [NSNotification notificationWithName:@"mergedChangesFromiCloud"
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
    
    // Two Configurations: Ubiquitous and Local
    // Ubiquitous contains all user data and is synced between devices
    // Local contains data that cannot be recreated but is the same across all devices.
    // Ubiquitous:
    NSURL *iCloudURL = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"IcthusUbiquitousStore.sqlite"];
    
    if (iCloudURL) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    } else {
        NSLog(@"User is not signed into iCloud. Using a local store.");
        iCloudURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IcthusSubstitueUbiquitousStore.sqlite"];
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
    }

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
    if (![[NSFileManager defaultManager] fileExistsAtPath:[localStoreURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"IcthusPrepopulatedStore" ofType:@"sqlite"]];
        NSError* err = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:localStoreURL error:&err]) {
            NSLog(@"VERY BAD: Could not copy preloaded data");
            // TODO: give user an alert
        }
        
        // Make sure that the preloaded database and the local database aren't backed up to iCloud
        [self addSkipBackupAttributeToItemAtURL:preloadURL];
        [self addSkipBackupAttributeToItemAtURL:localStoreURL];
    }
    
    options = @{
                 NSMigratePersistentStoresAutomaticallyOption: [NSNumber numberWithBool:YES],
                 NSInferMappingModelAutomaticallyOption: [NSNumber numberWithBool:YES],
                };
    
    [psc lock];
    [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:@"Local" URL:localStoreURL options:options error:nil];
    [psc unlock];

    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
