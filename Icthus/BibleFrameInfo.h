//
//  BibleTextFrameInfo.h
//  Icthus
//
//  Created by Matthew Lorentz on 3/28/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface BibleFrameInfo : NSObject

@property (assign) CGRect  frame;
@property CTFrameRef ctFrame;
@property (assign) NSRange textRange;
@property (nonatomic, strong) NSArray *lineRanges;
@property (nonatomic, strong) NSMutableArray *chapters;
@property (nonatomic, strong) NSMutableArray *verses;

@end
