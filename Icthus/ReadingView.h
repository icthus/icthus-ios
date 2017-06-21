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
@class AppDelegate;
@class VerseOverlayView;

@interface ReadingView : UIScrollView <UIScrollViewDelegate>

- (void)addVerseOverlayViewToViewHierarchy;
- (void)removeVerseOverlayViewFromViewHierarchy;
- (CGFloat)lineHeightForString:(NSAttributedString *)string;
- (void)setCurrentLocation:(BookLocation *)location;
- (BookLocation *)saveCurrentLocation;
- (BasicBookLocation *)getCurrentLocation;
- (void)buildFrames;
- (void)redrawText;

@property (strong, nonatomic) AppDelegate *appDel;
@property (retain, nonatomic) NSAttributedString* attString;
@property (retain, nonatomic) NSAttributedString* sizingString;
@property (retain, nonatomic) NSString *text;
@property (nonatomic) UIUserInterfaceSizeClass horizontalSizeClass;
@property (retain, nonatomic) NSMutableArray* textViews;
@property (retain, nonatomic) NSMutableArray* frameData;
@property (retain, nonatomic) NSMutableArray* textRanges;
@property (retain, nonatomic) NSMutableArray* versesByView;
@property (retain, nonatomic) NSMutableArray* chaptersByView;
@property (retain, nonatomic) Book *book;
@property (retain, nonatomic) BibleMarkupParser *parser;
@property VerseOverlayView *verseOverlayView;
@property NSTimer *verseOverlayTimer;

@end
