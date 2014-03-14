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

-(NSArray *)verseAndChapterNumbersForRange:(NSRange)range inMarkup:(NSString *)markupText;
-(NSArray *)verseNumbersForRange:(NSRange)range inMarkup:(NSString *)markupText;
-(NSArray *)chapterNumbersForRange:(NSRange)range inMarkup:(NSString *)markupText withStartingChapter:(NSString *)startingChapter;
-(NSString *)displayStringFromMarkup:(NSString *)markupText;
-(BookLocation *)saveLocationForCharAtIndex:(int)index forText:(NSString *)markupText andBook:(Book *)book;
-(int)getTextPositionForLocation:(BookLocation *)location inMarkup:(NSString *)markupText;

@end
