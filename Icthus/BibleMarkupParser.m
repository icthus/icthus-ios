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
    int markupPos;
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
    findingVersesForString = NO;
    findingChaptersForString = NO;
    currentChapter = 0;
    currentVerse = 0;
    textPos = 0;
    markupPos = 0;
}

-(NSArray *)verseAndChapterNumbersForRange:(NSRange)range inMarkup:(NSString *)markupText {
    // returns an array that has [verseNumbers, chapterNumbers, markupRange]
    [self reset];
    NSString *substring;
    
    #pragma mark - terrible, horrible hack, what are you even doing fix this right now you idiot
    // NSXMLParser sucks and is a memory hog so I needed to chop down the strings I was feeding it.
    // We don't know how much to chop down because the range we get in the arguments is for the plain
    // text not the markup. So the theory is that if we are looking for more than 10 characters of text
    // the ratio of text to markup should be greater that 1:4 so we can chop off some of that string
    // we are parsing so NSXMLParser doesn't allocate as much memory. Sorry.
    if (range.length > 10) {
        NSRange hackRange = NSMakeRange(range.location, MIN([markupText length], range.length * 4));
        substring = [markupText substringWithRange:hackRange];
    } else {
        substring = markupText;
    }
    NSData *data = [substring dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    findingVersesForString = YES;
    findingChaptersForString = YES;
    displayStringRange = range;
    versesInString = [[NSMutableArray alloc] init];
    chaptersInString = [[NSMutableArray alloc] init];
    [parser parse];
    return [[NSArray alloc] initWithObjects:versesInString, chaptersInString, [NSNumber numberWithInt:markupPos], nil];
}

-(NSArray *)verseNumbersForRange:(NSRange)range inMarkup:(NSString *)markupText {
    [self reset];
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
    [self reset];
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

- (BookLocation *)saveLocationForCharAtIndex:(int)index forText:(NSString *)markupText andBook:(Book *)book {
    [self reset];
    textPos = 0;
    neededTextPos = index;
    NSData *data = [markupText dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    gettingLocationForChar = YES;
    [parser parse];
    
    [book updateLocationChapter:currentChapter verse:currentVerse];
    NSManagedObjectContext *moc = book.managedObjectContext;
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
        }
    }
    
    if (gettingTextPos) {
        if (currentChapter == neededChapter && currentVerse == neededVerse) {
            [parser abortParsing];
            // we need to bump the text position onto the current verse
            textPos += 1;
        }
    }
    
    if (findingChaptersForString || findingVersesForString) {
        markupPos += [self lengthForOpeningMarkupElement:elementName withAttributes:attributeDict];
    }
    
    if ((findingVersesForString || findingChaptersForString) && textPos >= displayStringRange.location) {
        if (findingVersesForString) {
            if ([elementName isEqualToString:@"v"]) {
                NSString *i = [attributeDict objectForKey:@"i"];
                if ([i length]) {
                    [versesInString addObject:i];
                }
            }
        }
        if (findingChaptersForString) {
            if ([elementName isEqualToString:@"c"]) {
                NSString *i = [attributeDict objectForKey:@"i"];
                if ([i length]) {
                    [chaptersInString addObject:i];
                }
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    if (findingChaptersForString || findingVersesForString) {
        markupPos += [self lengthForClosingMarkupElement:elementName];
    }
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
    } else if (findingVersesForString || findingChaptersForString) {
        markupPos += length;
        textPos += length;
        if (textPos >= displayStringRange.location + displayStringRange.length) {
            // back the markup and text positions up to match the displayStringRange's end
            int diff = textPos - displayStringRange.length;
            textPos -= diff;
            markupPos -= diff;
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
        // TODO: don't use exit(0)
        exit(0);
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
        // TODO: don't use exit(0)
        exit(0);
    }
    
    return length;
}

@end
