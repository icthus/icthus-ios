//
//  WEBUSFXParser.m
//  Icthus
//
//  Created by Matthew Lorentz on 4/1/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "WEBUSFXParser.h"

@implementation WEBUSFXParser

@synthesize inSPTag;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
    
    if ([self.currentBook.code isEqualToString:@"PSA"]) {
        if ([elementName isEqualToString:@"c"]) {
            // Beginning of a Psalm
            [self.mutableBookText appendString:[NSString stringWithFormat:@"\n\nPsalm %@", [attributeDict objectForKey:@"id"]]];
        }
    }

    if ([self.currentBook.code isEqualToString:@"SNG"]) {
        if ([elementName isEqualToString:@"p"]) {
            if ([attributeDict objectForKey:@"sfm"] && [[attributeDict objectForKey:@"sfm"] isEqualToString:@"sp"]) {
                self.inSPTag = YES;
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    if ([self.currentBook.code isEqualToString:@"SNG"]) {
        if (self.inSPTag) {
            if ([[self.mutableBookText substringFromIndex:self.mutableBookText.length - 1] isEqualToString:@" "]) {
                [self.mutableBookText insertString:@":" atIndex:self.mutableBookText.length - 1];
            } else {
                [self.mutableBookText appendString:@":"];
            }
            self.inSPTag = NO;
        } else {
            self.inSPTag = NO;
        }
    }
    
    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName];
}
@end