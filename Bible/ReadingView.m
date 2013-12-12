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

@synthesize textViews;
@synthesize verseViews;
@synthesize textRanges;
@synthesize attString;
@synthesize book;

NSString *markup;
NSString *currentChapter;
NSString *remainingMarkup;
CGFloat  lastKnownContentOffset;
BibleMarkupParser *parser;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = false;
        self.delegate = self;
        parser = [[BibleMarkupParser alloc] init];
        lastKnownContentOffset = 0;
    }
    return self;
}

-(void)awakeFromNib {
    self.delegate = self;
    self.alwaysBounceHorizontal = YES;
    parser = [[BibleMarkupParser alloc] init];
    lastKnownContentOffset = 0;
}

-(void)setText:(NSString *)text {
    _text = text;
    
    // parse the markup
    NSString *displayString = [parser displayStringFromMarkup:text];

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
    self.textViews = [NSMutableArray array];
    self.verseViews = [NSMutableArray array];
    self.textRanges = [NSMutableArray array];
    remainingMarkup = self.text;
    
    CGRect textFrame;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        textFrame = CGRectInset(self.bounds, 50, 0);
    } else {
        textFrame = CGRectInset(self.bounds, 10, 0);
    }
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CGFloat lineHeight = [attString boundingRectWithSize:CGSizeMake(textFrame.size.width, textFrame.size.height) options:0 context:nil].size.height;
    
    int textPos = 0;
    int contentOffset = 0;
    int pageIndex = 0;
    
    while (textPos < [attString length]) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textFrame);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        NSRange nsFrameRange = NSMakeRange(frameRange.location, frameRange.length);
        [self.textRanges addObject:[NSValue valueWithRange:nsFrameRange]];
        
        CGRect tmpFrame = CGRectMake(0, contentOffset, self.frame.size.width,self.frame.size.height);
//        BibleTextView *content = [[BibleTextView alloc] initWithFrame:tmpFrame andTextRange:nsFrameRange andParent:self];

		//set the text and verse view contents and add it as subview
        [self.textViews addObject:[NSNull null]];
//        [self addSubview:content];
        

//        BibleVerseView *verseView = [self getVerseViewForTextFrame:frame bounds:tmpFrame andLineHeight:lineHeight];
//        [self.verseViews addObject:verseView];
//        [self addSubview:verseView];
        
        //prepare for next frame
        textPos += frameRange.length;
        pageIndex++;
        contentOffset += self.bounds.size.height;
    }
    
    //set the total width of the scroll view
    self.contentSize = CGSizeMake(self.bounds.size.width, (pageIndex + 1) * self.bounds.size.height);
}

-(BibleVerseView *)getVerseViewForTextFrame:(CTFrameRef)ctframe bounds:(CGRect)frame andLineHeight:(CGFloat) lineHeight {
    CFArrayRef lines = CTFrameGetLines(ctframe);
    NSMutableArray *versesByLine = [[NSMutableArray alloc] init];
    NSMutableArray *chaptersByLine = [[NSMutableArray alloc] init];
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange cfStringRange = CTLineGetStringRange(line);
        NSRange stringRange = NSMakeRange(0, cfStringRange.length);
        NSArray *versesChaptersAndMarkupPos = [parser verseAndChapterNumbersForRange:stringRange inMarkup:remainingMarkup];
        [versesByLine insertObject:[versesChaptersAndMarkupPos objectAtIndex:0] atIndex:i];
        NSArray *chapters = [versesChaptersAndMarkupPos objectAtIndex:1];
        if ([chapters lastObject]) {
            currentChapter = [chapters lastObject];
        } else {
            chapters = [[NSArray alloc] initWithObjects:currentChapter, nil];
        }
        [chaptersByLine insertObject:chapters atIndex:i];
        
        NSNumber *markupPos = [versesChaptersAndMarkupPos objectAtIndex:2];
        remainingMarkup = [remainingMarkup substringFromIndex:[markupPos unsignedIntegerValue]];
        if ([remainingMarkup length] > 0) {
            remainingMarkup = [@"<book><c i=\"\"><v i=\"\">" stringByAppendingString:remainingMarkup];
        }
    }
    
    int length = CFArrayGetCount(lines);
    CGPoint origins[length];
    CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), origins);
    
    return [[BibleVerseView alloc] initWithContentFrame:frame verses:versesByLine chapters:chaptersByLine andLineOrigins:origins withLength:length andLineHeight:lineHeight];
}

- (void)getTouchedLocation {
    int frameHeight = self.frame.size.height;
    int offset = self.contentOffset.y;
    int frameOffset = offset % frameHeight;
    BibleTextView *currentView = [self.textViews objectAtIndex: offset / frameHeight];
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
    int contentOffset = round(self.contentOffset.y);
    int height = round(self.frame.size.height);
    int currentFrameIndex  = contentOffset / height;
    BibleTextView *textView = [self.textViews objectAtIndex:currentFrameIndex];
    if ([textView class] == [NSNull class]) {
        NSLog(@"Fatal: getCurrentLocation failed to get a non-nil textView");
    }

    // find the origin of the current line
    CFArrayRef lines = CTFrameGetLines(textView.ctFrame);
    int originsLength = CFArrayGetCount(lines);
    CGPoint origins[originsLength];
    CTFrameGetLineOrigins(textView.ctFrame, CFRangeMake(0, 0), origins);
    int i = 0;
    if (originsLength > 0) {
        for (i = 0; i < originsLength - 1; i++) {
            int origin = origins[i].y;
            int offset = textView.frame.origin.y + textView.frame.size.height - origin;
            int contentOffset = self.contentOffset.y;
            if (offset > contentOffset) {
                break;
            }
        }
    }
    
    CTLineRef line = CFArrayGetValueAtIndex(lines, i);
    CFRange lineRange = CTLineGetStringRange(line);
    NSRange textViewRange = [[self.textRanges objectAtIndex:currentFrameIndex] rangeValue];
    int location = textViewRange.location + lineRange.location + lineRange.length;

    NSString *bookCode;
    if (self.book != nil) {
        bookCode = self.book.code;
    }
    
    return [parser getLocationForCharAtIndex:location forText:self.text andBookCode:bookCode];
}

- (void)setCurrentLocation:(BookLocation *)location {
    if ([self.textViews count]) {
        int targetTextPos = [parser getTextPositionForLocation:location inMarkup:self.text];

        // find the index of the view with the given location and instantiate it
        NSRange lastTextRange = [[self.textRanges firstObject] rangeValue];
        int i;
        for (i = 0; i < [self.textRanges count]; i++) {
            NSRange thisTextRange = [[self.textRanges objectAtIndex:i] rangeValue];
            if (thisTextRange.location >= targetTextPos) {
                if (i > 0) {
                    i -= 1;
                }
                break;
            }
            lastTextRange = thisTextRange;
        }
        
        CGRect frame = CGRectMake(0, self.frame.size.height * i, self.frame.size.width, self.frame.size.height);
        BibleTextView *textView = [[BibleTextView alloc] initWithFrame:frame andTextRange:lastTextRange andParent:self];
        [self addSubview:textView];
        [self.textViews replaceObjectAtIndex:i withObject:textView];

        int contentOffset = textView.frame.origin.y;

        // find the correct line in the view
        CFArrayRef lines = CTFrameGetLines(textView.ctFrame);
        if (CFArrayGetCount(lines)) {
            int i;
            for (i = 0; i < CFArrayGetCount(lines) - 1; i++) {
                CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                CFRange range = CTLineGetStringRange(line);
                if (targetTextPos <= range.location + range.length) {
                    break;
                }
            }
            
            int originLength = CFArrayGetCount(lines);
            CGPoint origins[originLength];
            CTFrameGetLineOrigins(textView.ctFrame, CFRangeMake(0, 0), origins);
            // get the origin of the line just above the line we want to show because CoreText origins are on a Cartesian plane.
            if (i == 0) {
                CGPoint origin = textView.frame.origin;
                contentOffset += origin.y;
            } else {
                CGPoint origin = origins[i + 1]; // I don't understand why this is i + 1 but it works
                contentOffset += textView.frame.size.height - origin.y;
            }
        }
        
        lastKnownContentOffset = contentOffset;
        [self setContentOffset:CGPointMake(0, contentOffset) animated:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int contentOffset = round(scrollView.contentOffset.y);
    int height = round(self.frame.size.height);
    int previousFrameIndex = lastKnownContentOffset / height;
    int currentFrameIndex  = contentOffset / height;
    if (previousFrameIndex != currentFrameIndex) {
        // delete all the old textViews
        for (int i = 0; i < [self.textViews count]; i++) {
            BibleTextView *textView = [self.textViews objectAtIndex:i];
            if ([textView class] != [NSNull class]) {
                [textView removeFromSuperview];
                textView = nil;
                [self.textViews replaceObjectAtIndex:i withObject:[NSNull null]];
            }
        }
        
        // add the correct textView
        CGRect frame = CGRectMake(0, self.frame.size.height * currentFrameIndex, self.frame.size.width, self.frame.size.height);
        NSRange textRange = [[self.textRanges objectAtIndex:currentFrameIndex] rangeValue];
        BibleTextView *textView = [[BibleTextView alloc] initWithFrame:frame andTextRange:textRange andParent:self];
        [self addSubview:textView];
        [self.textViews replaceObjectAtIndex:currentFrameIndex withObject:textView];
    }
    lastKnownContentOffset = scrollView.contentOffset.y;
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
