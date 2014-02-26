//
//  BookLocation.h
//  Icthus
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BookLocation : NSManagedObject

- (void)setBookCode:(NSString *)code chapter:(int)chapterNumber verse:(int)verseNumber;
- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

@property NSString *bookCode;
@property NSNumber *chapter;
@property NSNumber *verse;

@end
