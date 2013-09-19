//
//  BookLocation.m
//  Bible
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BookLocation.h"
NSString *const BookLocationBookCode = @"bookCode";
NSString *const BookLocationChapterKey = @"chapter";
NSString *const BookLocationVerseKey = @"verse";

@implementation BookLocation

@synthesize bookCode;
@synthesize chapter;
@synthesize verse;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.bookCode forKey:BookLocationBookCode];
    [encoder encodeObject:[[NSNumber alloc] initWithInt:self.chapter] forKey:BookLocationChapterKey];
    [encoder encodeObject:[[NSNumber alloc] initWithInt:self.verse] forKey:BookLocationVerseKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        [self setBookCode:[decoder decodeObjectForKey:BookLocationBookCode]];
        [self setChapter:[(NSNumber *)[decoder decodeObjectForKey:BookLocationChapterKey] intValue]];
        [self setVerse:[(NSNumber *)[decoder decodeObjectForKey:BookLocationVerseKey] intValue]];
    }
    return self;
}


- (id)initWithBookCode:(NSString *)code chapter:(int)chapterNumber verse:(int)verseNumber {
    self = [super init];
    if (self) {
        [self setBookCode:code];
        [self setChapter:chapterNumber];
        [self setVerse:verseNumber];
    }
    
    return self;
}

@end
