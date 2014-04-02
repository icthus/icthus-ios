//
//  ASVUSFXParser.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/2/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "ASVUSFXParser.h"

@implementation ASVUSFXParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if ([self.currentBook.code isEqualToString:@"PSA"]) {
        if ([elementName isEqualToString:@"v"] && [[attributeDict objectForKey:@"id"] isEqualToString:@"1"]) {
            // ASV sometimes has line breaks in between Psalm title and first verse.
            while ([[self.mutableBookText substringFromIndex:[self.mutableBookText length] - 2] isEqualToString:@"\n\n"]) {
                self.mutableBookText = [NSMutableString stringWithString:[self.mutableBookText substringToIndex:[self.mutableBookText length] - 1]];
            }
        }
    }
    
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
    
    if ([self.currentBook.code isEqualToString:@"PSA"]) {
        if ([elementName isEqualToString:@"c"]) {
            // Beginning of a Psalm
            [self.mutableBookText appendString:[NSString stringWithFormat:@"\n\nPsalm %@", [attributeDict objectForKey:@"id"]]];
        }
   }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // Remove the stupid left brackets before "Selah"
    if ([[self.heirarchy lastObject] isEqualToString:@"qs"] && [[string substringToIndex:1] isEqualToString:@"["]) {
        string = [string substringFromIndex:1];
    }
    [super parser:parser foundCharacters:string];
}

@end
