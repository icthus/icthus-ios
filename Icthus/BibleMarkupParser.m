//
//  BibleMarkupParser.m
//  Icthus
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BibleMarkupParser.h"
#import "BookLocation.h"
#import "AppDelegate.h"
#import "BibleFrameInfo.h"


@implementation BibleMarkupParser
{
    NSMutableString *displayText;
    NSMutableArray *versesInString;
    NSMutableArray *chaptersInString;
    NSArray *frameData;
    NSRange displayStringRange;
    bool gettingLocationForChar;
    bool gettingDisplayString;
    bool gettingTextPos;
    bool findingVersesAndChaptersForString;
    int currentChapter;
    int currentVerse;
    int neededChapter;
    int neededVerse;
    int neededTextPos;
    int frameIndex;
    int lineIndex;
    int lineCount;
    int frameCount;
    int textPos;
}

- (id)init {
    self = [super init];
    if (self) {
        [self reset];
    }
    
    return self;
}

- (void)reset {
    gettingLocationForChar = NO;
    gettingDisplayString = NO;
    gettingTextPos = NO;
    findingVersesAndChaptersForString = NO;
    currentChapter = 0;
    currentVerse = 0;
    frameIndex = 0;
    lineIndex = 0;
    lineCount = 0;
    frameCount = 0;
    textPos = 0;
}

-(void)addChapterAndVerseNumbersToFrameData:(NSArray *)frameDataArray fromMarkup:(NSString *)markupText {
    [self reset];
    findingVersesAndChaptersForString = YES;
    
    frameData = frameDataArray;
    if ([frameData count] > 0) {
        BibleFrameInfo *frameInfo = [frameData firstObject];
        frameCount = [frameData count];
        lineCount = [frameInfo.lineRanges count];
        displayStringRange = [[frameInfo.lineRanges firstObject] rangeValue];
    }
    NSData *data = [markupText dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
}

- (NSString *)displayStringFromMarkup:(NSString *)markupText {
    [self reset];
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

- (BasicBookLocation *)getLocationForCharAtIndex:(int)index forText:(NSString *)markupText andBook:(Book *)book {
    [self reset];
    textPos = 0;
    neededTextPos = index;
    NSData *data = [markupText dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    gettingLocationForChar = YES;
    [parser parse];
    BasicBookLocation *location = malloc(sizeof(BasicBookLocation));
    location->chapter = currentChapter;
    location->verse   = currentVerse;
    return location;
}

- (BookLocation *)saveLocationForCharAtIndex:(int)index forText:(NSString *)markupText andBook:(Book *)book {
    BasicBookLocation *unmanagedLocation = [self getLocationForCharAtIndex:index forText:markupText andBook:book];
    BookLocation *location = [book getLocation];
    [location updateChapter:unmanagedLocation->chapter verse:unmanagedLocation->verse];
    NSManagedObjectContext *moc = location.managedObjectContext;
    NSError *error;
    [moc save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    return [book getLocation];
}

- (int)getTextPositionForLocation:(BookLocation *)location inMarkup:(NSString *)markupText {
    [self reset];
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
            currentVerse = 1;
        }
    }
    
    if (gettingTextPos) {
        if (currentChapter == neededChapter && currentVerse == neededVerse) {
            [parser abortParsing];
            // we need to bump the text position onto the current verse
            textPos += 1;
        }
    }
    
    if (findingVersesAndChaptersForString) {
        if ([elementName isEqualToString:@"v"]) {
            NSString *i = [attributeDict objectForKey:@"i"];
            if ([i length]) {
                NSMutableArray *versesForLine = [[(BibleFrameInfo *)[frameData objectAtIndex:frameIndex] verses] objectAtIndex:lineIndex];
                [versesForLine addObject:i];
            }
        }

        if ([elementName isEqualToString:@"c"]) {
            NSString *i = [attributeDict objectForKey:@"i"];
            if ([i length]) {
                currentChapter = [i intValue];
            }
        }
        
        if ([elementName isEqualToString:@"v"] || [elementName isEqualToString:@"c"]) {
            NSMutableArray *chaptersForLine = [[(BibleFrameInfo *)[frameData objectAtIndex:frameIndex] chapters] objectAtIndex:lineIndex];
            [chaptersForLine addObject:[NSString stringWithFormat:@"%d", currentChapter]];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSUInteger length = [string length];
    if (gettingDisplayString) {
        [displayText appendString:string];
    } else if (gettingTextPos) {
        textPos += length;
    } else if (gettingLocationForChar) {
        textPos += length;
        if (textPos > neededTextPos) {
            [parser abortParsing];
        }
    } else if (findingVersesAndChaptersForString) {
        textPos += length;
        while (!NSLocationInRange(textPos, displayStringRange)) {
            lineIndex++;
            if (lineIndex >= lineCount) {
                lineIndex = 0;
                frameIndex++;
                if (frameIndex >= frameCount) {
                    [parser abortParsing];
                    return;
                }
                lineCount = [[[frameData objectAtIndex:frameIndex] lineRanges] count];
            }
            BibleFrameInfo *frameInfo = [frameData objectAtIndex:frameIndex];
            displayStringRange = [[frameInfo.lineRanges objectAtIndex:lineIndex] rangeValue];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
//    NSLog(@"A parsing error occured");
//    NSLog(@"%@", [parseError localizedDescription]);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {

}

- (int)lengthForOpeningMarkupElement:(NSString *)elementName withAttributes:(NSDictionary *)attributeDict {
    int length = 0;
    if ([elementName isEqualToString:@"v"]) {
        length = 8 + [[attributeDict objectForKey:@"i"] length];
    } else if ([elementName isEqualToString:@"c"]) {
        length = 8 + [[attributeDict objectForKey:@"i"] length];
    } else if ([elementName isEqualToString:@"book"]) {
        length = 6;
    } else {
        NSLog(@"FATAL! lengthForMarkupElementwithAttributes encountered an unkown markup element!");
    }
    
    return length;
}

- (int)lengthForClosingMarkupElement:(NSString *)elementName {
    int length = 0;
    if ([elementName isEqualToString:@"v"]) {
        length = 4;
    } else if ([elementName isEqualToString:@"c"]) {
        length = 4;
    } else if ([elementName isEqualToString:@"book"]) {
        length = 7;
    } else {
        NSLog(@"FATAL! lengthForMarkupElementwithAttributes encountered an unkown markup element:%@", elementName);
    }
    
    return length;
}

@end
