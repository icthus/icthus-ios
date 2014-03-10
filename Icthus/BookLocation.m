//
//  BookLocation.m
//  Icthus
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BookLocation.h"

@implementation BookLocation

@synthesize bookCode = _bookCode;
@synthesize chapter = _chapter;
@dynamic lastModified;
@synthesize verse = _verse;

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        [self setLastModified:[NSDate date]];
    }
    
    return self;
}

- (void)setBookCode:(NSString *)code chapter:(int)chapterNumber verse:(int)verseNumber {

    [self setBookCode:code];
    [self setChapter:[NSNumber numberWithInt:chapterNumber]];
    [self setVerse:[NSNumber numberWithInt:verseNumber]];
    [self setLastModified:[NSDate date]];
}

- (void)setBookCode:(NSString *)bookCode {
    _bookCode = bookCode;
    [self setLastModified:[NSDate date]];
}

- (NSString *)bookCode {
    return _bookCode;
}

- (void)setChapter:(NSNumber *)chapter {
    _chapter = chapter;
    [self setLastModified:[NSDate date]];
}

- (NSNumber *)chapter {
    return _chapter;
}

- (void)setVerse:(NSNumber *)verse {
    _verse = verse;
    [self setLastModified:[NSDate date]];
}

- (NSNumber *)verse {
    return _verse;
}

@end
