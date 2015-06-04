//
//  Translation.m
//  Icthus
//
//  Created by Matthew Lorentz on 10/17/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "Translation.h"


@implementation Translation

@dynamic code;
@dynamic copyrightText;
@dynamic displayName;

-(Book *)getBookWithCode:(NSString *)bookCode {
    if (bookCode != nil) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"code == %@ && translation == %@", bookCode, self.code]];
        NSError *error;
        NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            return nil;
        } else {
            Book *book = [array firstObject];
            return book;
        }
    } else {
        return nil;
    }
}

@end
