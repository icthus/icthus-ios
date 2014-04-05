//
//  ReadingView.h
//  Icthus
//
//  Created by Matthew Lorentz on 9/9/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookLocation.h"
#import "BibleMarkupParser.h"
#import "Book.h"

@interface ReadingView : UIScrollView <UIScrollViewDelegate>

- (CGFloat)lineHeightForString:(NSAttributedString *)string;
- (BookLocation *)getCurrentLocation;
- (void)setCurrentLocation:(BookLocation *)location;
- (void)saveCurrentLocation;

@property (retain, nonatomic) NSAttributedString* attString;
@property (retain, nonatomic) NSAttributedString* sizingString;
@property (retain, nonatomic) NSString *text;
@property (retain, nonatomic) NSMutableArray* textViews;
@property (retain, nonatomic) NSMutableArray* frameData;
@property (retain, nonatomic) NSMutableArray* textRanges;
@property (retain, nonatomic) NSMutableArray* versesByView;
@property (retain, nonatomic) NSMutableArray* chaptersByView;
@property (retain, nonatomic) Book *book;
@property (retain, nonatomic) BibleMarkupParser *parser;

@end
