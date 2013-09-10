//
//  BibleMarkupParser.h
//  Bible
//
//  Created by Matthew Lorentz on 9/10/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BibleMarkupParser : NSObject <NSXMLParserDelegate>

- (NSString *)displayStringFromMarkup:(NSString *)markupText;

@end
