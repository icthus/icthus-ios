//
//  KJVParser.m
//  IcthusStoreGenerator
//
//  Created by Matthew Lorentz on 7/30/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "KJVParser.h"

@implementation KJVParser

- (void) instantiateBooks:(NSManagedObjectContext *)context translationCode:(NSString *)code displayName:(NSString *)displayName bookNamePath:(NSString *)bookNamePath bookTextPath:(NSString *)bookTextPath {
    [super instantiateBooks:context translationCode:code displayName:displayName bookNamePath:bookNamePath bookTextPath:bookTextPath];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
    
    if ([self.currentBook.code isEqualToString:@"PSA"]) {
        if ([elementName isEqualToString:@"c"]) {
            // Beginning of a Psalm
            [self.mutableBookText appendString:[NSString stringWithFormat:@"\n\nPsalm %@", [attributeDict objectForKey:@"id"]]];
        } else if ([elementName isEqualToString:@"p"] && ![attributeDict objectForKey:@"sfm"]) {
            // remove tab and add another newline
            [self.mutableBookText replaceCharactersInRange:NSMakeRange([self.mutableBookText length] - 1, 1) withString:@""];
        }
    }
}

@end
