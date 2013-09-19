//
//  BibleMarkupParser.m
//  Bible
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BibleMarkupParser.h"
#import "BookLocation.h"

@implementation BibleMarkupParser
{
    NSMutableString *displayText;
    bool gettingLocationForChar;
    bool gettingDisplayString;
    bool gettingTextPos;
    int currentChapter;
    int currentVerse;
    int neededChapter;
    int neededVerse;
    int neededTextPos;
    int textPos;
}

- (id)init {
    self = [super init];
    if (self) {
        gettingLocationForChar = NO;
        gettingDisplayString = NO;
        gettingTextPos = NO;
        currentChapter = 0;
        currentVerse = 0;
        textPos = 0;
    }
    
    return self;
}

- (NSString *)displayStringFromMarkup:(NSString *)markupText {
    NSData *data = [markupText dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    displayText = [[NSMutableString alloc] init];
    gettingDisplayString = YES;
    if ([parser parse]) {
        return displayText;
    } else {
        NSLog(@"An error occured parsing book markup");
        return nil;
    }
}

- (BookLocation *)getLocationForCharAtIndex:(int)index forText:(NSString *)markupText andBookCode:(NSString *)code {
    textPos = 0;
    neededTextPos = index;
    NSData *data = [markupText dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    gettingLocationForChar = YES;
    [parser parse];
    return [[BookLocation alloc] initWithBookCode:code chapter:currentChapter verse:currentVerse];
}

- (int)getTextPositionForLocation:(BookLocation *)location inMarkup:(NSString *)markupText {
    textPos = 0;
    neededChapter = [location chapter];
    neededVerse = [location verse];
    gettingTextPos = YES;
    
    NSData *data = [markupText dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    return textPos;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {

    if (gettingLocationForChar || gettingTextPos) {
        if ([elementName isEqualToString:@"v"]) {
            currentVerse = [[attributeDict objectForKey:@"i"] intValue];
        } else if ([elementName isEqualToString:@"c"]) {
            currentChapter = [[attributeDict objectForKey:@"i"] intValue];
        }
    }
    
    if (gettingTextPos) {
        if (currentChapter == neededChapter && currentVerse == neededVerse) {
            [parser abortParsing];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (gettingDisplayString) {
        [displayText appendString:string];
    } else if (gettingTextPos) {
        textPos += [string length];
    } else if (gettingLocationForChar) {
        textPos += [string length];
        if (textPos > neededTextPos) {
            [parser abortParsing];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"A parsing error occured");
    NSLog(@"%@", [parseError localizedDescription]);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {

}

@end
