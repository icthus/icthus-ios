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
- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

@property (nonatomic) Book *book;
@property NSNumber *chapter;
@property NSDate   *lastModified;
@property NSNumber *verse;

@end
