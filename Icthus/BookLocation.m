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
@synthesize lastModified = _lastModified;
@synthesize verse = _verse;

- (void) awakeFromInsert {
    [super awakeFromInsert];
    self.lastModified = [NSDate date];
}

- (void)setBook:(Book *)book chapter:(int)chapterNumber verse:(int)verseNumber {
    [self setBook:book];
    [self setChapter:[NSNumber numberWithInt:chapterNumber]];
    [self setVerse:[NSNumber numberWithInt:verseNumber]];
}

- (void)updateChapter:(int)chapter verse:(int)verse {
    self.chapter = [NSNumber numberWithInt:chapter];
    self.verse = [NSNumber numberWithInt:verse];
}

- (void)setBook:(Book *)book {
    [self willChangeValueForKey:@"bookCode"];
    [self setPrimitiveValue:book.code forKey:@"bookCode"];
    [self didChangeValueForKey:@"bookCode"];
    [self setLastModified:[NSDate date]];
}

- (Book *)book {
    [self willAccessValueForKey:@"book"];
    NSArray *fetchedPropertyBooks = (NSArray *)[self primitiveValueForKey:@"book"];
    [self didAccessValueForKey:@"book"];
    
    NSString *translationCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTranslation"];
    for (Book *book in fetchedPropertyBooks) {
        if ([book.translation isEqualToString:translationCode]) {
            return book;
        }
    }
    return nil;
}

- (void)setChapter:(NSNumber *)chapter {
    [self willChangeValueForKey:@"chapter"];
    [self setPrimitiveValue:chapter forKey:@"chapter"];
    [self didChangeValueForKey:@"chapter"];
    [self setLastModified:[NSDate date]];
}

- (NSNumber *)chapter {
    NSNumber *chapter;
    [self willAccessValueForKey:@"chapter"];
    chapter = [self primitiveValueForKey:@"chapter"];
    [self didAccessValueForKey:@"chapter"];
    return chapter;
}

- (void)setVerse:(NSNumber *)verse {
    [self willChangeValueForKey:@"verse"];
    [self setPrimitiveValue:verse forKey:@"verse"];
    [self didChangeValueForKey:@"verse"];
    [self setLastModified:[NSDate date]];
}

- (NSNumber *)verse {
    NSNumber *verse;
    [self willAccessValueForKey:@"verse"];
    verse = [self primitiveValueForKey:@"verse"];
    [self didAccessValueForKey:@"verse"];
    return verse;
}

- (void)setLastModified:(NSDate *)lastModified {
    [self willChangeValueForKey:@"lastModified"];
    [self setPrimitiveValue:lastModified forKey:@"lastModified"];
    [self didChangeValueForKey:@"lastModified"];
}

- (NSDate *)lastModified {
    NSDate *lastModified;
    [self willAccessValueForKey:@"lastModified"];
    lastModified = [self primitiveValueForKey:@"lastModified"];
    [self didAccessValueForKey:@"lastModified"];
    return lastModified;
}

@end
