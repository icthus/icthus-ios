//
//  BookLocation.m
//  Icthus
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BookLocation.h"

@implementation BookLocation

@dynamic bookCode;
@dynamic chapter;
@dynamic verse;

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {

    }
    
    return self;
}

- (void)setBookCode:(NSString *)code chapter:(int)chapterNumber verse:(int)verseNumber {

    [self setBookCode:code];
    [self setChapter:[NSNumber numberWithInt:chapterNumber]];
    [self setVerse:[NSNumber numberWithInt:verseNumber]];
}

@end
