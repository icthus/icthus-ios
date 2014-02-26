//
//  ASVXMLParserDelegate.m
//  Icthus
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//  USFX XML schema is located at http://ebible.org/usfx.xsd

#import "ASVXMLParserDelegate.h"
#import "Book.h"
#import "Translation.h"

@implementation ASVXMLParserDelegate

@synthesize nameParser = _nameParser;
@synthesize bookParser = _bookParser;
@synthesize context = _context;
@synthesize booksByCode = _booksByCode;
@synthesize currentBook = _currentBook;

NSMutableString *mutableBookText;
int chapterIndex;
bool shouldParseCharacters;
static NSString *translationCode = @"ASV";
static NSString *translationDisplayName = @"American Standard Version";

- (void) instantiateBooks:(NSManagedObjectContext *)context {
    _context = context;
    _booksByCode = [[NSMutableDictionary alloc] init];
    
    Translation *trans = [NSEntityDescription insertNewObjectForEntityForName:@"Translation" inManagedObjectContext:_context];
    [trans setCode:translationCode];
    [trans setDisplayName:translationDisplayName];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"BookNames" ofType:@"xml"];
    _nameParser = [[NSXMLParser alloc] initWithData:[[NSData alloc] initWithContentsOfFile:path]];
    [_nameParser setDelegate:self];
    
    if ([_nameParser parse]) {
        NSLog(@"Successfully parsed book names");
    } else {
        NSLog(@"An error occured parsing book names");
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"eng-asv_usfx" ofType:@"xml"];
    _bookParser = [[NSXMLParser alloc] initWithData:[[NSData alloc] initWithContentsOfFile:path]];
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
        Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_context];
        [book setCode:[attributeDict valueForKey:@"code"]];
        [book setLongName:[attributeDict valueForKey:@"long"]];
        [book setShortName:[attributeDict valueForKey:@"short"]];
        [book setAbbr:[attributeDict valueForKey:@"abbr"]];
        [book setTranslation:translationCode];
        [book setReading:NO];
        [book setText:@""];
        [_booksByCode setValue:book forKey:[book code]];
    } else if ([elementName isEqualToString:@"book"]) {
        _currentBook = [_booksByCode valueForKey:[attributeDict valueForKey:@"id"]];
        mutableBookText = [[NSMutableString alloc] initWithString:@"<book>"];
        chapterIndex = 0;
    } else if ([elementName isEqualToString:@"p"]) {
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

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    if (parser == _bookParser && [elementName isEqualToString:@"book"]) {
        [mutableBookText appendString:@"</c></book>"];
        [_currentBook setNumberOfChapters:[NSNumber numberWithInt:chapterIndex]];
        [_currentBook setText:mutableBookText];
    }
    else if ([elementName isEqualToString:@"p"]) {
        shouldParseCharacters = NO;
    } else if ([elementName isEqualToString:@"f"]) {
        shouldParseCharacters = YES;
    } else if ([elementName isEqualToString:@"ve"]) {
        [mutableBookText appendString:@"</v>"];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (shouldParseCharacters) {
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
