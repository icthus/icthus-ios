//
//  AppDelegate.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate 

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize colorManager = _colorManager;
BOOL foundNewDataIniCloud;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];
    
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
        [self checkForUserDefaultsUpgrades];
        [self setupControllers];
    }
    
    [self.window makeKeyAndVisible];
    
    // Show latest version of tutorial if we haven't yet
//    if (![defaults boolForKey:@"shownTutorial"]) {
//        [self showTutorial];
//    } else if ([(NSNumber *)[defaults objectForKey:@"whatsNewVersion"] integerValue] < WHATS_NEW_VERSION) {
//        [self showWhatsNew];
//        [defaults setObject:[NSNumber numberWithInt:WHATS_NEW_VERSION] forKey:@"whatsNewVersion"];
//        [defaults synchronize];
//    }
    
    return YES;
}

- (void)handleFirstLaunch {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"WEB" forKey:@"selectedTranslation"];
    [prefs setObject:[NSNumber numberWithInt:CURRENT_DATABASE_VERSION] forKey:@"databaseVersion"];
    [prefs setObject:[NSNumber numberWithInt:WHATS_NEW_VERSION] forKey:@"whatsNewVersion"];
    [prefs setObject:[NSNumber numberWithInt:1] forKey:@"colorManagerVersion"];
    [prefs setBool:YES forKey:@"appHasLaunchedBefore"];
    [prefs setBool:NO  forKey:@"showDarkMode"];
    [self setupControllers];
//    [self showTutorial];
    [prefs synchronize];
}

- (void)checkForUserDefaultsUpgrades {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"showDarkMode"] == nil) {
        [prefs setBool:NO forKey:@"showDarkMode"];
    }
    [prefs synchronize];
}

- (void)setupControllers {
    ReadingViewController *readingViewController = (ReadingViewController *)[[(UINavigationController *)self.window.rootViewController childViewControllers] firstObject];
    [self setDetailView:readingViewController];
    [readingViewController setBookToLatest];
}

- (void)showTutorial {
    IcthusTutorialPageViewController *pageViewController = [self.detailView.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
    [self.detailView presentViewController:pageViewController animated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shownTutorial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)showWhatsNew {
    IcthusWhatsNewViewController *pageViewController = [self.detailView.storyboard instantiateViewControllerWithIdentifier:@"WhatsNewPageViewController"];
    [self.detailView presentViewController:pageViewController animated:YES completion:nil];
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
    self.persistentStoreCoordinator = nil;
    if (![[self.detailView.book getLocation] isEqual:[self.detailView getLatestLocation]]) {
        [self.detailView setBookToLatest];
    }
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
    [NSTimer scheduledTimerWithTimeInterval:25 target:self selector:@selector(backgroundFetchTimedOutWithTimer:) userInfo:completionHandler repeats:NO];
    NSLog(@"Background App Refresh: activated at %@", [NSDate date]);
    foundNewDataIniCloud = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"mergedChangesFromiCloud" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSLog(@"Background App Refresh: got new data from iCloud");
        foundNewDataIniCloud = YES;
    }];
}

- (void)backgroundFetchTimedOutWithTimer:(NSTimer *)timer {
    void (^completionHandler)(UIBackgroundFetchResult) = (void (^)(UIBackgroundFetchResult))timer.userInfo;
    if (foundNewDataIniCloud) {
        completionHandler(UIBackgroundFetchResultNewData);
        NSLog(@"Background App Refresh: timing out, successfully fetched new data");
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
        NSLog(@"Background App Refresh: timing out, did not fetch any data");
    }
}

#pragma mark - Handoff

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {

    NSDictionary *info = userActivity.userInfo;
    NSString *bookCode = [info objectForKey:@"bookCode"];
    NSNumber *chapter = [info objectForKey:@"chapter"];
    NSNumber *verse = [info objectForKey:@"verse"];
    if (bookCode && chapter && verse) {
        
        // Fetch the book based on the bookCode
        NSFetchRequest *genesisRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        NSString *translationCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTranslation"];
        [genesisRequest setPredicate:[NSPredicate predicateWithFormat:@"code == %@ && translation == %@", bookCode, translationCode]];
        NSError *error;
        NSArray *array = [self.managedObjectContext executeFetchRequest:genesisRequest error:&error];
        if (error || ![array count]) {
            NSLog(@"%@", [error localizedDescription]);
            return NO;
        }
        Book *book = [array firstObject];
        
        // Create a new BookLocation to show the user
        BookLocation *location = [NSEntityDescription insertNewObjectForEntityForName:@"BookLocation" inManagedObjectContext:self.managedObjectContext];
        [location setBook:book chapter:[chapter intValue] verse:[verse intValue]];
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            return NO;
        }
    
        // Show the latest BookLocation
        [self.detailView setLocation:location];
        
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
    return YES;
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
            [moc setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType]];
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
    if  (![[NSFileManager defaultManager] fileExistsAtPath:[localStoreURL path]]) {
        [self createLocalDatastore];
    } else if ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"databaseVersion"] integerValue] < CURRENT_DATABASE_VERSION) {
        [self upgradeLocalDatastore];
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

- (void)createLocalDatastore {
    NSURL *localStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IcthusLocalStore.sqlite"];
    NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"IcthusPrepopulatedStore" ofType:@"sqlite"]];
    NSError* err = [[NSError alloc] init];
    if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:localStoreURL error:&err]) {
        NSLog(@"VERY BAD: Could not create database.");
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create database. Please contact support@icthusapp.com if the problem persists." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        NSLog(@"Successfully created database with version %d", CURRENT_DATABASE_VERSION);
        // Make sure that the preloaded database and the local database aren't backed up to iCloud
        [self addSkipBackupAttributeToItemAtURL:preloadURL];
        [self addSkipBackupAttributeToItemAtURL:localStoreURL];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:CURRENT_DATABASE_VERSION] forKey:@"databaseVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}

- (void)upgradeLocalDatastore {
    NSURL *localStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IcthusLocalStore.sqlite"];
    NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"IcthusPrepopulatedStore" ofType:@"sqlite"]];
    NSURL *backupURL= [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IcthusLocalStoreBackup.sqlite"];
    NSError* err = nil;
    BOOL failure = NO;
    
    // Try to copy the prepopulated store to to the database location
    [[NSFileManager defaultManager] moveItemAtURL:localStoreURL toURL:backupURL error:&err];
    if (err) {
        failure = YES;
        NSLog(@"%@", [err localizedDescription]);
        [[NSFileManager defaultManager] removeItemAtURL:backupURL error:&err];
    } else {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"IcthusLocalStore.sqlite*" options:NSRegularExpressionCaseInsensitive error:&err];
        [self removeFiles:regex inPath:[[self applicationDocumentsDirectory] path]];
        [[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:localStoreURL error:&err];
        if (err) {
            failure = YES;
            NSLog(@"%@", [err localizedDescription]);
            [[NSFileManager defaultManager] moveItemAtURL:backupURL toURL:localStoreURL error:&err];
        }
        [[NSFileManager defaultManager] removeItemAtURL:backupURL error:&err];
        if (err) {
            failure = YES;
            NSLog(@"%@", [err localizedDescription]);
        }
    }
    
    if (failure) {
        NSLog(@"VERY BAD: Could not upgrade to new version of database, keeping old version.");
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not upgrade database. Please contact support@icthusapp.com if the problem persists." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        NSLog(@"Successfully upgraded user from database version %@ to version %d", [[NSUserDefaults standardUserDefaults] objectForKey:@"databaseVersion"], CURRENT_DATABASE_VERSION);
        // Make sure that the preloaded database and the local database aren't backed up to iCloud
        [self addSkipBackupAttributeToItemAtURL:preloadURL];
        [self addSkipBackupAttributeToItemAtURL:localStoreURL];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:CURRENT_DATABASE_VERSION] forKey:@"databaseVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - File Management

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

- (void)removeFiles:(NSRegularExpression*)regex inPath:(NSString*)path {
    NSDirectoryEnumerator *filesEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    
    NSString *file;
    NSError *error;
    while (file = [filesEnumerator nextObject]) {
        NSUInteger match = [regex numberOfMatchesInString:file
                                                  options:0
                                                    range:NSMakeRange(0, [file length])];
        
        if (match) {
            [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
        }
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

#pragma mark - Properties
- (ColorManager *)colorManager {
    if (_colorManager == nil) {
        _colorManager = [[ColorManager alloc] init];
    }
    return _colorManager;
}

- (void)setColorManager:(ColorManager *)colorManager {
    _colorManager = colorManager;
}

@end
