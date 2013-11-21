//
//  BibleMarkupParser.m
//  Bible
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BibleMarkupParser.h"
#import "BookLocation.h"
#import "AppDelegate.h"


@implementation BibleMarkupParser
{
    NSMutableString *displayText;
    NSMutableArray *versesInString;
    NSMutableArray *chaptersInString;
    NSRange displayStringRange;
    bool gettingLocationForChar;
    bool gettingDisplayString;
    bool gettingTextPos;
    bool findingVersesForString;
    bool findingChaptersForString;
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
        findingVersesForString = NO;
        findingChaptersForString = NO;
        currentChapter = 0;
        currentVerse = 0;
        textPos = 0;
    }
    
    return self;
}

-(NSArray *)verseNumbersForRange:(NSRange)range inMarkup:(NSString *)markupText {
    NSData *data = [markupText dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    findingVersesForString = YES;
    textPos = 0;
    displayStringRange = range;
    versesInString = [[NSMutableArray alloc] init];
    if ([parser parse]) {
        return [NSArray arrayWithArray:versesInString];
    } else if (versesInString) {
        return [NSArray arrayWithArray:versesInString];
    } else {
        NSLog(@"An error occured finding verse numbers for string: %@", markupText);
        return nil;
    }
}

-(NSArray *)chapterNumbersForRange:(NSRange)range inMarkup:(NSString *)markupText withStartingChapter:(NSString *)startingChapter {
    NSData *data = [markupText dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    findingChaptersForString = YES;
    textPos = 0;
    displayStringRange = range;
    chaptersInString = [[NSMutableArray alloc] init];
    if ([parser parse]) {
        return [NSArray arrayWithArray:chaptersInString];
    } else if ([chaptersInString count]) {
        return [NSArray arrayWithArray:chaptersInString];
    } else {
        if (startingChapter) {
            [chaptersInString insertObject:startingChapter atIndex:0];
        }
        return [NSArray arrayWithArray:chaptersInString];
    }
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
//        NSLog(@"An error occured parsing book markup");
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
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDel managedObjectContext];
    BookLocation *location = [NSEntityDescription insertNewObjectForEntityForName:@"BookLocation" inManagedObjectContext:managedObjectContext];
    [location setBookCode:code chapter:currentChapter verse:currentVerse];
    return location;
}

- (int)getTextPositionForLocation:(BookLocation *)location inMarkup:(NSString *)markupText {
    textPos = 0;
    neededChapter = [[location chapter] intValue];
    neededVerse = [[location verse] intValue];
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
            // we need to bump the text position onto the current verse
            textPos += 1;
        }
    }
    
    if (textPos >= displayStringRange.location) {
        if (findingVersesForString) {
            if ([elementName isEqualToString:@"v"]) {
                 [versesInString addObject:[attributeDict objectForKey:@"i"]];
            }
        } else if (findingChaptersForString) {
            if ([elementName isEqualToString:@"c"]) {
                [chaptersInString addObject:[attributeDict objectForKey:@"i"]];
            }
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
    } else if (findingVersesForString || findingChaptersForString) {
        textPos += [string length];
        if (textPos >= displayStringRange.location + displayStringRange.length) {
            findingChaptersForString = NO;
            findingVersesForString = NO;
            [parser abortParsing];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
//    NSLog(@"A parsing error occured");
//    NSLog(@"%@", [parseError localizedDescription]);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {

}

@end
