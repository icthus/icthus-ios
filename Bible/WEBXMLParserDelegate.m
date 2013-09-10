    //
//  WEBXMLParserDelegate.m
//  Bible
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "WEBXMLParserDelegate.h"
#import "Book.h"

@implementation WEBXMLParserDelegate

@synthesize nameParser = _nameParser;
@synthesize bookParser = _bookParser;
@synthesize context = _context;
@synthesize booksByCode = _booksByCode;
@synthesize currentBook = _currentBook;

NSMutableString *mutableBookText;
int chapterIndex;
bool shouldParseCharacters;

- (void) instantiateBooks:(NSManagedObjectContext *)context {
    _context = context;
    _booksByCode = [[NSMutableDictionary alloc] init];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"BookNames" ofType:@"xml"];
    _nameParser = [[NSXMLParser alloc] initWithData:[[NSData alloc] initWithContentsOfFile:path]];
    [_nameParser setDelegate:self];
    
    if ([_nameParser parse]) {
        NSLog(@"Successfully parsed book names");
    } else {
        NSLog(@"An error occured parsing book names");
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"eng-web_usfx" ofType:@"xml"];
    _bookParser = [[NSXMLParser alloc] initWithData:[[NSData alloc] initWithContentsOfFile:path]];
    [_bookParser setDelegate:self];
    
    if ([_bookParser parse]) {
        NSLog(@"Successfully parsed books");
    } else {
        NSLog(@"An error occured parsing books");
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if (parser == _nameParser && [elementName isEqual: @"book"]) {
        Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_context];
        [book setCode:[attributeDict valueForKey:@"code"]];
        [book setLongName:[attributeDict valueForKey:@"long"]];
        [book setShortName:[attributeDict valueForKey:@"short"]];
        [book setAbbr:[attributeDict valueForKey:@"abbr"]];
        [book setTranslation:@"WEB"];
        [book setReading:NO];
        [book setText:@""];
        [book setPosition:0];
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
        [mutableBookText appendString:[NSString stringWithFormat:@"<v i=\"%d\">", chapterIndex]];
    } else if ([elementName isEqualToString:@"c"]) {
        if (chapterIndex != 0) {
            [mutableBookText appendString:@"</c>"];
        }
        chapterIndex = [(NSString *)[attributeDict objectForKey:@"id"] intValue];
        [mutableBookText appendString:[NSString stringWithFormat:@"<c i=\"%@\">", [attributeDict objectForKey:@"id"]]];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    if (parser == _bookParser && [elementName isEqualToString:@"book"]) {
        [mutableBookText appendString:@"</c></book>"];
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
    if (parser == _bookParser) {
        NSError *error;
        if (![_context save:&error]) {
            NSLog(@"Error saving books: %@", [error localizedDescription]);
        }
    }
}


@end
