//
//  WEBUSFXParser.h
//  Icthus
//
//  Created by Matthew Lorentz on 4/1/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "USFXParser.h"

@interface WEBUSFXParser : USFXParser

@property bool inSPTag;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName;
@end
