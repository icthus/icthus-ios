//
//  USFXParser.m
//  Icthus
//
//  Created by Matthew Lorentz on 3/10/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "USFXParser.h"
#import "Translation.h"
#import "Book.h"

@implementation USFXParser

@synthesize nameParser = _nameParser;
@synthesize bookParser = _bookParser;
@synthesize context = _context;
@synthesize booksByCode = _booksByCode;
@synthesize currentBook = _currentBook;

NSArray *includedBooks;
NSMutableString *mutableBookText;
int chapterIndex;
bool shouldParseCharacters;
bool shouldParseBook;
static NSString *translationCode;
static NSString *translationDisplayName;

- (void) instantiateBooks:(NSManagedObjectContext *)context translationCode:(NSString *)code displayName:(NSString *)displayName bookNamePath:(NSString *)bookNamePath bookTextPath:(NSString *)bookTextPath {
    translationCode = code;
    translationDisplayName = displayName;
    _context = context;
    _booksByCode = [[NSMutableDictionary alloc] init];
    
    // Define the books we will include
    includedBooks = @[@"GEN",@"EXO",@"LEV",@"NUM",@"DEU",@"JOS",@"JDG",@"RUT",@"1SA",@"2SA",@"1KI",@"2KI",@"1CH",@"2CH",@"EZR",@"NEH",@"EST",@"JOB",@"PSA",@"PRO",@"ECC",@"SNG",@"ISA",@"JER",@"LAM",@"EZK",@"DAN",@"HOS",@"JOL",@"AMO",@"OBA",@"JON",@"MIC",@"NAM",@"HAB",@"ZEP",@"HAG",@"ZEC",@"MAL",@"MAT",@"MRK",@"LUK",@"JHN",@"ACT",@"ROM",@"1CO",@"2CO",@"GAL",@"EPH",@"PHP",@"COL",@"1TH",@"2TH",@"1TI",@"2TI",@"TIT",@"PHM",@"HEB",@"JAS",@"1PE",@"2PE",@"1JN",@"2JN",@"3JN",@"JUD",@"REV",];
    
    Translation *trans = [NSEntityDescription insertNewObjectForEntityForName:@"Translation" inManagedObjectContext:_context];
    [trans setCode:translationCode];
    [trans setDisplayName:translationDisplayName];
    
    _nameParser = [[NSXMLParser alloc] initWithData:[[NSData alloc] initWithContentsOfFile:bookNamePath]];
    [_nameParser setDelegate:self];
    
    if ([_nameParser parse]) {
        NSLog(@"Successfully parsed book names");
    } else {
        NSLog(@"An error occured parsing book names");
    }
    
    _bookParser = [[NSXMLParser alloc] initWithData:[[NSData alloc] initWithContentsOfFile:bookTextPath]];
    [_bookParser setDelegate:self];
    
    if ([_bookParser parse]) {
        NSLog(@"Successfully parsed books");
    } else {
        NSLog(@"An error occured parsing books");
    }
    
    NSError *error;
    if (![_context save:&error]) {
        NSLog(@"Error saving books: %@", [error localizedDescription]);
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if (parser == _nameParser && [elementName isEqual: @"book"]) {
        NSUInteger bookIndex = [includedBooks indexOfObject:[attributeDict valueForKey:@"code"]];
        if (bookIndex != NSNotFound) {
            Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_context];
            [book setCode:[attributeDict valueForKey:@"code"]];
            [book setIndex:[NSNumber numberWithInteger:bookIndex]];
            [book setLongName:[attributeDict valueForKey:@"long"]];
            [book setShortName:[attributeDict valueForKey:@"short"]];
            [book setAbbr:[attributeDict valueForKey:@"abbr"]];
            [book setTranslation:translationCode];
            [book setText:@""];
            [_booksByCode setValue:book forKey:[book code]];
        }
    } else if ([elementName isEqualToString:@"book"]) {
        NSUInteger bookIndex = [includedBooks indexOfObject:[attributeDict valueForKey:@"id"]];
        if (bookIndex == NSNotFound) {
            shouldParseBook = NO;
        } else {
            shouldParseBook = YES;
            _currentBook = [_booksByCode valueForKey:[attributeDict valueForKey:@"id"]];
            mutableBookText = [[NSMutableString alloc] initWithString:@"<book>"];
            chapterIndex = 0;
        }
    } else if (shouldParseBook) {
        if ([elementName isEqualToString:@"p"]) {
            shouldParseCharacters = YES;
        } else if ([elementName isEqualToString:@"f"]) {
            shouldParseCharacters = NO;
        } else if ([elementName isEqualToString:@"v"]) {
            shouldParseCharacters = YES;
            [mutableBookText appendString:[NSString stringWithFormat:@"<v i=\"%d\">", [[attributeDict objectForKey:@"id"] intValue]]];
        } else if ([elementName isEqualToString:@"q"] ||
                   [elementName isEqualToString:@"qt"] ||
                   [elementName isEqualToString:@"wj"] ||
                   [elementName isEqualToString:@"tl"] ||
                   [elementName isEqualToString:@"qac"] ||
                   [elementName isEqualToString:@"sls"] ||
                   [elementName isEqualToString:@"bk"] ||
                   [elementName isEqualToString:@"pn"] ||
                   [elementName isEqualToString:@"k"] ||
                   [elementName isEqualToString:@"ord"] ||
                   [elementName isEqualToString:@"sig"] ||
                   [elementName isEqualToString:@"bd"] ||
                   [elementName isEqualToString:@"it"] ||
                   [elementName isEqualToString:@"bdit"] ||
                   [elementName isEqualToString:@"sc"] ||
                   [elementName isEqualToString:@"no"] ||
                   [elementName isEqualToString:@"quoteStart"] ||
                   [elementName isEqualToString:@"quoteEnd"] ||
                   [elementName isEqualToString:@"quoteRemind"] ||
                   [elementName isEqualToString:@"nd"]) {
            shouldParseCharacters = YES;
        } else if ([elementName isEqualToString:@"qs"]) {
            // For the "Selah" in the Psalms
            shouldParseCharacters = YES;
        } else if ([elementName isEqualToString:@"d"]) {
            // Indicating the title of a Psalm
            shouldParseCharacters = YES;
            [mutableBookText appendString:@"\n"];
        } else if ([elementName isEqualToString:@"c"]) {
            if (chapterIndex != 0) {
                [mutableBookText appendString:@"</c>"];
            }
            chapterIndex = [(NSString *)[attributeDict objectForKey:@"id"] intValue];
            [mutableBookText appendString:[NSString stringWithFormat:@"<c i=\"%@\">", [attributeDict objectForKey:@"id"]]];
        } else {
            shouldParseCharacters = NO;
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    if (parser == _bookParser && [elementName isEqualToString:@"book"]) {
        [mutableBookText appendString:@"</c></book>"];
        [_currentBook setNumberOfChapters:[NSNumber numberWithInt:chapterIndex]];
        [_currentBook setText:mutableBookText];
    } else if (shouldParseBook) {
        if ([elementName isEqualToString:@"p"]) {
            shouldParseCharacters = NO;
        } else if ([elementName isEqualToString:@"f"]) {
            shouldParseCharacters = YES;
        } else if ([elementName isEqualToString:@"ve"]) {
            [mutableBookText appendString:@"</v>"];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (shouldParseBook && shouldParseCharacters) {
        [mutableBookText appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"A parsing error occured");
    NSLog(@"%@", [parseError localizedDescription]);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {

}


@end