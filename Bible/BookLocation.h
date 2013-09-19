//
//  BookLocation.h
//  Bible
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const BookLocationBookCode;
NSString *const BookLocationChapterKey;
NSString *const BookLocationVerseKey;

@interface BookLocation : NSObject <NSCoding>

- (id)initWithBookCode:(NSString *)code chapter:(int)chapterNumber verse:(int)verseNumber;

@property NSString *bookCode;
@property int chapter;
@property int verse;

@end
