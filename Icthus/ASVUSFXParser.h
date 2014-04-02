//
//  ASVUSFXParser.h
//  Icthus
//
//  Created by Matthew Lorentz on 4/2/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "USFXParser.h"

@interface ASVUSFXParser : USFXParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;

@end
