//
//  ReadingView.h
//  Bible
//
//  Created by Matthew Lorentz on 9/9/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookLocation.h"
#import "Book.h"

@interface ReadingView : UIScrollView <UIScrollViewDelegate>

- (BookLocation *)getCurrentLocation;
- (void)setCurrentLocation:(BookLocation *)location;
- (void)saveLocation;

@property (retain, nonatomic) NSAttributedString* attString;
@property (retain, nonatomic) NSString *text;
@property (retain, nonatomic) NSMutableArray* textViews;
@property (retain, nonatomic) NSMutableArray* verseViews;
@property (retain, nonatomic) NSMutableArray* textRanges;
@property (retain, nonatomic) Book *book;

@end
