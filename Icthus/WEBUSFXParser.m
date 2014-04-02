//
//  WEBUSFXParser.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/1/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "WEBUSFXParser.h"

@implementation WEBUSFXParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
    
    if ([self.currentBook.code isEqualToString:@"PSA"]) {
        if ([elementName isEqualToString:@"c"]) {
            // Beginning of a Psalm
            [self.mutableBookText appendString:[NSString stringWithFormat:@"\n\nPsalm %@", [attributeDict objectForKey:@"id"]]];
        }
    }
}

@end