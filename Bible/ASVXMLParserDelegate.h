//
//  ASVXMLParserDelegate.h
//  Bible
//
//  Created by Matthew Lorentz on 8/26/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"

@interface ASVXMLParserDelegate : NSObject  <NSXMLParserDelegate>

- (void) instantiateBooks:(NSManagedObjectContext *)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;
- (void)parserDidEndDocument:(NSXMLParser *)parser;

@property (nonatomic, strong) NSXMLParser *nameParser;
@property (nonatomic, strong) NSXMLParser *bookParser;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSMutableDictionary *booksByCode;
@property (nonatomic, strong) Book *currentBook;

@end
