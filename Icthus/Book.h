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


@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * abbr;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSNumber * reading;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * translation;
@property (nonatomic, retain) NSNumber * numberOfChapters;

-(BookLocation *)getLocation;
-(void)setLocation:(BookLocation *)location;

@end
