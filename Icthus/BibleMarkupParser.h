//
//  BibleMarkupParser.h
//  Icthus
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookLocation.h"
#import "Book.h"

@interface BibleMarkupParser : NSObject <NSXMLParserDelegate>

-(NSString *)displayStringFromMarkup:(NSString *)markupText;
-(void)addChapterAndVerseNumbersToFrameData:(NSArray *)frameDataArray fromMarkup:(NSString *)markupText;
-(BasicBookLocation *)getLocationForCharAtIndex:(int)index forText:(NSString *)markupText andBook:(Book *)book;
-(BookLocation *)saveLocationForCharAtIndex:(int)index forText:(NSString *)markupText andBook:(Book *)book;
-(int)getTextPositionForLocation:(BookLocation *)location inMarkup:(NSString *)markupText;

@end
