//
//  BibleMarkupParser.h
//  Bible
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookLocation.h"

@interface BibleMarkupParser : NSObject <NSXMLParserDelegate>

-(NSArray *)verseNumbersInString:(NSString *)markupText;
-(NSArray *)chapterNumbersInString:(NSString *)markupText;
-(NSString *)displayStringFromMarkup:(NSString *)markupText;
-(BookLocation *)getLocationForCharAtIndex:(int)index forText:(NSString *)markupText andBookCode:(NSString *)code;
-(int)getTextPositionForLocation:(BookLocation *)location inMarkup:(NSString *)markupText;

@end
