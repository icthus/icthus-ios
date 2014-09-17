//
//  Book.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "Book.h"

@implementation Book

@dynamic abbr;
@dynamic code;
@dynamic index;
@dynamic longName;
@dynamic shortName;
@dynamic text;
@dynamic translation;
@dynamic numberOfChapters;

-(BookLocation *)getLocation {
    NSManagedObjectContext *context = [(NSManagedObject *)self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BookLocation" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookCode = %@", self.code];
    [request setPredicate:predicate];
    // Sort by lastModified
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModified" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    // Only fetch the most recent location
    [request setFetchLimit:1];

    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array == nil)
    {
        NSLog(@"Error fetching BookLocation");
        NSLog(@"%@", [error localizedDescription]);
    }
    
    BookLocation *location;
    if ([array count] >= 1) {
        location = [array firstObject];
    } else {
        location = [NSEntityDescription insertNewObjectForEntityForName:@"BookLocation" inManagedObjectContext:context];
        [location setBook:self chapter:1 verse:1];
    }
    
    return location;
}

-(void)updateLocationChapter:(int)chapter verse:(int)verse { // Updates the most recent BookLocation
    NSManagedObjectContext *context = [(NSManagedObject *)self managedObjectContext];
    BookLocation *location = [self getLocation];
    [location updateChapter:chapter verse:verse];
    
    NSError *error;
    [context save:&error];
    if (error != nil) {
        NSLog(@"An error occured during save");
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(BookLocation *)setLocationChapter:(int)chapter verse:(int)verse { // Saves given BookLocation as a new object
    NSManagedObjectContext *context = [(NSManagedObject *)self managedObjectContext];
    BookLocation *location = [NSEntityDescription insertNewObjectForEntityForName:@"BookLocation" inManagedObjectContext:context];
    [location setBook:self chapter:chapter verse:verse];
    NSError *error;
    [context save:&error];
    if (error != nil) {
        NSLog(@"An error occured during save");
        NSLog(@"%@", [error localizedDescription]);
    }
    return location;
}

@end
