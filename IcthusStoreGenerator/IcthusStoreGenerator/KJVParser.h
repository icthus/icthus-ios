//
//  KJVParser.h
//  IcthusStoreGenerator
//
//  Created by Matthew Lorentz on 7/30/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "USFXParser.h"

@interface KJVParser : USFXParser

- (void) instantiateBooks:(NSManagedObjectContext *)context translationCode:(NSString *)code displayName:(NSString *)displayName bookNamePath:(NSString *)bookNamePath bookTextPath:(NSString *)bookTextPath;
    
@end
