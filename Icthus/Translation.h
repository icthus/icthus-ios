//
//  Translation.h
//  Icthus
//
//  Created by Matthew Lorentz on 10/17/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Translation : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * copyrightText;
@property (nonatomic, retain) NSString * displayName;

@end
