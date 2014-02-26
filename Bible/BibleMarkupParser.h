//
//  BibleMarkupParser.h
//  Icthus
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookLocation.h"

@interface BibleMarkupParser : NSObject <NSXMLParserDelegate>

-(NSArray *)verseAndChapterNumbersForRange:(NSRange)range inMarkup:(NSString *)markupText;
-(NSArray *)verseNumbersForRange:(NSRange)range inMarkup:(NSString *)markupText;
-(NSArray *)chapterNumbersForRange:(NSRange)range inMarkup:(NSString *)markupText withStartingChapter:(NSString *)startingChapter;
-(NSString *)displayStringFromMarkup:(NSString *)markupText;
-(BookLocation *)getLocationForCharAtIndex:(int)index forText:(NSString *)markupText andBookCode:(NSString *)code;
-(int)getTextPositionForLocation:(BookLocation *)location inMarkup:(NSString *)markupText;

@end
