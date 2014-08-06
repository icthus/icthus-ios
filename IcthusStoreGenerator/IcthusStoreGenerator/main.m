#import "USFXParser.h"
#import "WEBUSFXParser.h"
#import "ASVUSFXParser.h"
#import "KJVParser.h"
//
//  main.m
//  IcthusStoreGenerator
//
//  Created by Matthew Lorentz on 4/9/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

static void instantiateBooks(NSManagedObjectContext *moc) {
    // WEB
    NSString* WEBBookNamePath = [[NSBundle mainBundle] pathForResource:@"WEBBookNames" ofType:@"xml"];
    NSString* WEBBookTextPath = [[NSBundle mainBundle] pathForResource:@"eng-web_usfx" ofType:@"xml"];
    [[[WEBUSFXParser alloc] init] instantiateBooks:moc translationCode:@"WEB" displayName:@"World English Bible" bookNamePath:WEBBookNamePath bookTextPath:WEBBookTextPath];
    
    // ASV
    NSString* ASVBookTextPath = [[NSBundle mainBundle] pathForResource:@"eng-asv_usfx" ofType:@"xml"];
    NSString* ASVBookNamePath = [[NSBundle mainBundle] pathForResource:@"ASVBookNames" ofType:@"xml"];
    [[[ASVUSFXParser alloc] init] instantiateBooks:moc translationCode:@"ASV" displayName:@"American Standard Version" bookNamePath:ASVBookNamePath bookTextPath:ASVBookTextPath];
    
    // KJV
    NSString* KJVBookTextPath = [[NSBundle mainBundle] pathForResource:@"eng-kjv_usfx" ofType:@"xml"];
    NSString* KJVBookNamePath = [[NSBundle mainBundle] pathForResource:@"KJVBookNames" ofType:@"xml"];
    [[[KJVParser alloc] init] instantiateBooks:moc translationCode:@"KJV" displayName:@"King James Version" bookNamePath:KJVBookNamePath bookTextPath:KJVBookTextPath];
}

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"Icthus";
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = @"IcthusPrepopulatedStore";
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        // Delete the old store
        [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

static void copyPrepopulatedStore() {
    NSString *filename = @"/IcthusPrepopulatedStore.sqlite";
    NSString *source = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingString:filename];
    NSString *destination = [[[[NSProcessInfo processInfo]environment] objectForKey:@"PREPOPULATED_STORE_DEST"] stringByAppendingString:filename];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err = nil;
    NSLog(@"Source %@", source);
    NSLog(@"Destination %@", destination);
    
    // Check to see if store file exists. If so, remove it.
    if ([fm fileExistsAtPath:destination isDirectory:NO]) {
        [fm removeItemAtPath:destination error:&err];
        if (err) {
            NSLog(@"%@", [err localizedDescription]);
            exit(1);
        }
    }
    // Copy new store file to destination.
    [fm moveItemAtPath:source toPath:destination error:&err];
    if (err) {
        NSLog(@"%@", [err localizedDescription]);
        exit(1);
    }
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        instantiateBooks(context);
        copyPrepopulatedStore();
    }
    return 0;
}

