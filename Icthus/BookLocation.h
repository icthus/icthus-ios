//
//  BookLocation.h
//  Icthus
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Book.h"
@class Book;

@interface BookLocation : NSManagedObject

- (void)setBook:(Book *)code chapter:(int)chapterNumber verse:(int)verseNumber;
- (void)updateChapter:(int)chapter verse:(int)verse;

@property (nonatomic, retain) Book     *book;
@property (nonatomic, retain) NSString *bookCode;
@property (nonatomic, retain) NSNumber *chapter;
@property (nonatomic, retain) NSDate   *lastModified;
@property (nonatomic, retain) NSNumber *verse;

struct UnmanagedBookLocationStruct {
    int chapter;
    int verse;
};
typedef struct UnmanagedBookLocationStruct BasicBookLocation;

@end
