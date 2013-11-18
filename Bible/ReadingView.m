//
//  ReadingView.m
//  Bible
//
//  Created by Matthew Lorentz on 9/9/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "ReadingView.h"
#import "BibleTextView.h"
#import "BibleVerseView.h"
#import "BibleMarkupParser.h"
#import "BookLocation.h"
#import <CoreText/CoreText.h>

@implementation ReadingView

@synthesize frames;
@synthesize attString;
@synthesize book;

NSMutableArray *gutterViews;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = false;
        self.delegate = self;
    }
    return self;
}

-(void)awakeFromNib {
    self.delegate = self;
    self.alwaysBounceHorizontal = YES;
}

-(void)setText:(NSString *)text {
    _text = text;
    
    // parse the markup
    NSString *displayString = [[[BibleMarkupParser alloc] init] displayStringFromMarkup:text];

    // set up the formatting
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineSpacing:14];
        NSDictionary *attributesDict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica"size:24], NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
        [self setAttString:[[NSAttributedString alloc] initWithString:displayString attributes:attributesDict]];
    } else {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineSpacing:4];
        NSDictionary *attributesDict = [[NSDictionary alloc] initWithObjectsAndKeys:
            [UIFont fontWithName:@"Helvetica" size:19], NSFontAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil
        ];
        [self setAttString:[[NSAttributedString alloc] initWithString:displayString attributes:attributesDict]];
    }
        
    // build the subviews
    [self buildFrames];
}

- (void)buildFrames {
    self.frames = [NSMutableArray array];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CGRect textFrame;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        textFrame = CGRectInset(self.bounds, 50, 0);
    } else {
        textFrame = CGRectInset(self.bounds, 10, 0);
    }
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    int textPos = 0;
    int contentOffset = 0;
    int pageIndex = 0;
    
    while (textPos < [attString length]) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textFrame);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        
        CGRect tmpFrame = CGRectMake(0, contentOffset, self.frame.size.width,self.frame.size.height);
        BibleTextView *content = [[BibleTextView alloc] initWithFrame:tmpFrame];

		//set the text and verse view contents and add it as subview
        [content setTextPos:textPos];
        [content setCTFrame:frame];
        [self.frames addObject:content];
        [self addSubview:content];
        
        BibleVerseView *verseView = [self getVerseViewForFrame:frame string:attString rect:tmpFrame];
        [gutterViews addObject:verseView];
        [self addSubview:verseView];
        
        //prepare for next frame
        textPos += frameRange.length;
        CFRelease(path);
        pageIndex++;
        contentOffset += self.bounds.size.height;
    }
    
    //set the total width of the scroll view
    self.contentSize = CGSizeMake(self.bounds.size.width, (pageIndex + 1) * self.bounds.size.height);
}

-(BibleVerseView *)getVerseViewForFrame:(CTFrameRef)ctframe string:(NSAttributedString *)displayText rect:(CGRect)frame {
    CFArrayRef lines = CTFrameGetLines(ctframe);
    BibleMarkupParser *parser = [[BibleMarkupParser alloc] init];
    NSMutableArray *versesByLine = [[NSMutableArray alloc] init];
    NSMutableArray *chaptersByLine = [[NSMutableArray alloc] init];
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange stringRange = CTLineGetStringRange(line);
        NSString *lineString = [[displayText string] substringWithRange:NSMakeRange(stringRange.location, stringRange.length)];
        [versesByLine insertObject:[parser verseNumbersInString:lineString] atIndex:i];
        [chaptersByLine insertObject:[parser chapterNumbersInString:lineString] atIndex:i];
    }
    
    CGPoint origins[ CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), origins);
    
    return [[BibleVerseView alloc] initWithContentFrame:frame verses:versesByLine chapters:chaptersByLine andLineOrigins:origins];
}

- (void)getTouchedLocation {
    int frameHeight = self.frame.size.height;
    int offset = self.contentOffset.y;
    int frameOffset = offset % frameHeight;
    BibleTextView *currentView = [self.frames objectAtIndex: offset / frameHeight];
    CTFrameRef currentFrame = currentView.ctFrame;
    
    NSArray *lines = (NSArray *) CTFrameGetLines(currentFrame);
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(currentFrame, CFRangeMake(0, 0), origins);
    
    int i;
    for (i = 0; i < [lines count]; i++) {
        CGPoint currentLineOrigin = origins[i];
        if (currentLineOrigin.y > frameOffset) {
            i -= 1;
            break;
        }
    }
    
    CTLineRef currentLine = (__bridge CTLineRef)[lines objectAtIndex:i];
}

- (BookLocation *)getCurrentLocation {
    // find the current view
    BibleTextView *lastView = [self.frames objectAtIndex:0];
    for (BibleTextView *view in self.frames) {
        if (view.frame.origin.y > self.contentOffset.y) {
            break;
        }
        lastView = view;
    }

    // find the origin of the current line
    CFArrayRef lines = CTFrameGetLines(lastView.ctFrame);
    int originsLength = CFArrayGetCount(lines);
    CGPoint origins[originsLength];
    CTFrameGetLineOrigins(lastView.ctFrame, CFRangeMake(0, 0), origins);
    int i = 0;
    if (originsLength > 0) {
        for (i = 0; i < originsLength - 1; i++) {
            int origin = origins[i].y;
            int offset = lastView.frame.origin.y + lastView.frame.size.height - origin;
            int contentOffset = self.contentOffset.y;
            if (offset > contentOffset) {
                break;
            }
        }
    }
    
    CTLineRef line = CFArrayGetValueAtIndex(lines, i);
    CFRange range = CTLineGetStringRange(line);

    NSString *bookCode;
    if (self.book != nil) {
        bookCode = self.book.code;
    }
    
    return [[[BibleMarkupParser alloc] init] getLocationForCharAtIndex:(range.location + range.length) forText:self.text andBookCode:bookCode];
}

- (void)setCurrentLocation:(BookLocation *)location {
    if ([self.frames count]) {
        int targetTextPos = [[[BibleMarkupParser alloc] init] getTextPositionForLocation:location inMarkup:self.text];

        // find the view with the given location
        BibleTextView *lastView = [self.frames objectAtIndex:0];
        for (BibleTextView *view in self.frames) {
            if (view.textPos >= targetTextPos) {
                break;
            }
            lastView = view;
        }

        int contentOffset = lastView.frame.origin.y;

        // find the correct line in the view
        CFArrayRef lines = CTFrameGetLines(lastView.ctFrame);
        if (CFArrayGetCount(lines)) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, 0);
            int i;
            for (i = 0; i < CFArrayGetCount(lines) - 1; i++) {
                line = CFArrayGetValueAtIndex(lines, i);
                CFRange range = CTLineGetStringRange(line);
                if (targetTextPos <= range.location + range.length) {
                    break;
                }
            }
            
            int originLength = CFArrayGetCount(lines);
            CGPoint origins[originLength];
            CTFrameGetLineOrigins(lastView.ctFrame, CFRangeMake(0, 0), origins);
            // get the origin of the line just above the line we want to show because CoreText origins are on a Cartesian plane.
            if (i == 0) {
                CGPoint origin = lastView.frame.origin;
                contentOffset += origin.y;
            } else {
                CGPoint origin = origins[i + 1]; // I don't understand why this is i + 1 but it works
                contentOffset += lastView.frame.size.height - origin.y;
            }
        }
        
        [self setContentOffset:CGPointMake(0, contentOffset)];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self saveLocation];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self saveLocation];
}

- (void)saveLocation {
    [self.book setLocation:[self getCurrentLocation]];
    NSManagedObjectContext *context = [(NSManagedObject *)self.book managedObjectContext];
    NSError *error;
    [context save:&error];
    if (error != nil) {
        NSLog(@"An error occured during save");
        NSLog(@"%@", [error localizedDescription]);
    }
}

@end
