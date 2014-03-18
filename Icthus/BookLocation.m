//
//  BookLocation.m
//  Icthus
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BookLocation.h"

@implementation BookLocation

@synthesize book = _book;
@synthesize bookCode = _bookCode;
@synthesize chapter = _chapter;
@dynamic lastModified;
@synthesize verse = _verse;

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        [self setLastModified:[NSDate dateWithTimeIntervalSince1970:0]];
    }

    return self;
}

- (void)setBook:(Book *)book chapter:(int)chapterNumber verse:(int)verseNumber {
    NSLog(@"Book.shortName = %@", book.shortName);
    [self setBook:book];
    [self setChapter:[NSNumber numberWithInt:chapterNumber]];
    [self setVerse:[NSNumber numberWithInt:verseNumber]];
    [self setLastModified:[NSDate date]];
}

- (void)updateChapter:(int)chapter verse:(int)verse {
    _chapter = [NSNumber numberWithInt:chapter];
    _verse   = [NSNumber numberWithInt:verse];
    [self setLastModified:[NSDate date]];
}

- (void)setBook:(Book *)book {
    _bookCode = book.code;
    [self setLastModified:[NSDate date]];
}

- (Book *)book {
    NSArray *fetchedPropertyBooks = (NSArray *)_book;
    NSString *translationCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTranslation"];
    for (Book *book in fetchedPropertyBooks) {
        if ([book.translation isEqualToString:translationCode]) {
            return book;
        }
    }
    return nil;
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
