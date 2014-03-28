//
//  BibleTextFrameInfo.h
//  Icthus
//
//  Created by Matthew Lorentz on 3/28/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BibleFrameInfo : NSObject

@property CGRect  frame;
@property NSRange textRange;
@property NSArray *lineRanges;
@property NSMutableArray *chapters;
@property NSMutableArray *verses;

@end
