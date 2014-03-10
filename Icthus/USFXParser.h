//
//  USFXParser.h
//  Icthus
//
//  Created by Matthew Lorentz on 3/10/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//
// Information on the usfx format can be found here: http://ebible.org/usfx/
// XML Schema: http://ebible.org/usfx.xsd

#import <Foundation/Foundation.h>
#import "Book.h"

@interface USFXParser : NSObject <NSXMLParserDelegate>

- (void) instantiateBooks:(NSManagedObjectContext *)context translationCode:(NSString *)code displayName:(NSString *)displayName;
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