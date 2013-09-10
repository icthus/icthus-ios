//
//  BibleMarkupParser.m
//  Bible
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "BibleMarkupParser.h"

@implementation BibleMarkupParser

NSMutableString *displayText;

- (NSString *)displayStringFromMarkup:(NSString *)markupText {
    NSData *data = [markupText dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    displayText = [[NSMutableString alloc] init];
    if ([parser parse]) {
        return displayText;
    } else {
        NSLog(@"An error occured parsing book markup");
        return nil;
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [displayText appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"A parsing error occured");
    NSLog(@"%@", [parseError localizedDescription]);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {

}

@end
