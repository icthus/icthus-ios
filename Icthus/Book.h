//
//  Book.h
//  Icthus
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BookLocation.h"
@class BookLocation;


@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * abbr;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * translation;
@property (nonatomic, retain) NSNumber * numberOfChapters;

-(BookLocation *)getLocation; // Gets the most recent location
-(void)updateLocationChapter:(int)chapter verse:(int)verse; // Updates the most recent BookLocation
-(void)setLocation:(BookLocation *)location; // Saves given BookLocation as a new object
-(BookLocation *)setLocationChapter:(int)chapter verse:(int)verse; // Creates new BookLocation and saves it

@end
