//
//  ReadingView.m
//  Icthus
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
@synthesize parser;
@synthesize versesByView;
@synthesize chaptersByView;

NSString *markup;
NSString *currentChapter;
NSMutableString *remainingMarkup;
CGPoint lastKnownContentOffset;
NSInteger activeViewWindow = 3;
CGRect textFrame;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.delegate = self;
    self.alwaysBounceHorizontal = YES;
    self.directionalLockEnabled = YES;
    self.scrollsToTop = NO;
    parser = [[BibleMarkupParser alloc] init];
    lastKnownContentOffset = CGPointMake(0,0);
}

- (void)clearText {
    for (BibleTextView *view in self.textViews) {
        if (![view isEqual:[NSNull null]]) {
            [view removeFromSuperview];
        }
    }
    for (BibleVerseView *view in self.verseViews) {
        if (![view isEqual:[NSNull null]]) {
            [view removeFromSuperview];
        }
    }
}

-(void)setText:(NSString *)text {
    // remove the old text
    [self clearText];
    _text = text;
    
    // parse the markup
    NSString *displayString = [parser displayStringFromMarkup:text];

    // set up the formatting
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineSpacing:14];
        NSDictionary *attributesDict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:@"AkzidenzGroteskCE-Roman"size:24], NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
        [self setAttString:[[NSAttributedString alloc] initWithString:displayString attributes:attributesDict]];
    } else {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineSpacing:4];
        NSDictionary *attributesDict = [[NSDictionary alloc] initWithObjectsAndKeys:
            [UIFont fontWithName:@"AkzidenzGroteskCE-Roman" size:19], NSFontAttributeName,
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
    self.chaptersByView = [[NSMutableArray alloc] init];
    self.versesByView = [[NSMutableArray alloc] init];
    remainingMarkup = [[NSMutableString alloc] initWithString:self.text];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        textFrame = CGRectInset(self.bounds, 50, 0);
    } else {
        textFrame = CGRectInset(self.bounds, 10, 0);
    }
    // Trim the height of the frame to fit an arbitrary 50 lines of text
    CGFloat lineHeight = [attString boundingRectWithSize:CGSizeMake(textFrame.size.width, textFrame.size.height) options:0 context:nil].size.height;
    textFrame.size.height = lineHeight * 50;

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
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
        [self.textViews addObject:[NSNull null]];
        
        NSMutableArray *chaptersForView = [[NSMutableArray alloc] init];
        NSMutableArray *versesForView = [[NSMutableArray alloc] init];
        [self addChapterNumbers:chaptersForView AndVerseNumbers:versesForView ForCTFrame:frame];
        [self.chaptersByView addObject:chaptersForView];
        [self.versesByView addObject:versesForView];
        
        //prepare for next frame
        textPos += frameRange.length;
        pageIndex++;
        contentOffset += self.bounds.size.height;
    }
    
    //set the total width of the scroll view
    self.contentSize = CGSizeMake(self.bounds.size.width, pageIndex * self.bounds.size.height);
}

// Populates the arrays with the chapter and verse numbers in the frame. When the method returns, each
// array will be of the form:
//  [
//      [1],    the first line contains the beginning of the first verse
//      [],     the second line does not contain the start of any verses
//      [2, 3], the third line contains the beginnings of verses 2 and 3
//      [4],    the fourth line contains the beginning of the fourth verse
//  ]
- (void) addChapterNumbers:(NSMutableArray *)chaptersByLine AndVerseNumbers:(NSMutableArray *)versesByLine ForCTFrame:(CTFrameRef)ctFrame {
    CFArrayRef lines = CTFrameGetLines(ctFrame);
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
        [remainingMarkup deleteCharactersInRange:NSMakeRange(0, [markupPos unsignedIntegerValue])];
        if ([remainingMarkup length] > 0) {
            [remainingMarkup insertString:@"<book><c i=\"\"><v i=\"\">" atIndex:0];
        }
    }
}

- (void)getTouchedLocation {
    int frameHeight = textFrame.size.height;
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

- (BookLocation *)saveCurrentLocation {
    // find the current view
    int contentOffset = round(self.contentOffset.y);
    int height = round(textFrame.size.height);
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
    
    BookLocation *bookLocation = [parser saveLocationForCharAtIndex:location forText:self.text andBook:book];
    NSLog(@"ReadingView.getCurrentLocation: got location %@ %@:%@", self.book.shortName, bookLocation.chapter, bookLocation.verse);
    return bookLocation;
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
        
        CGRect frame = CGRectMake(0, textFrame.size.height * i, textFrame.size.width, textFrame.size.height);
        NSArray *chapters = [self.chaptersByView objectAtIndex:i];
        NSArray *verses = [self.versesByView objectAtIndex:i];
        BibleTextView *textView = [[BibleTextView alloc] initWithFrame:frame TextRange:lastTextRange Parent:self Chapters:chapters AndVerses:verses];
        [self addSubview:textView];
        [self.textViews replaceObjectAtIndex:i withObject:textView];

        int contentOffset = textView.frame.origin.y;

        // find the correct line in the view
        CFArrayRef lines = CTFrameGetLines(textView.ctFrame);
        if (CFArrayGetCount(lines)) {
            for (i = 0; i < CFArrayGetCount(lines) - 1; i++) {
                CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                CFRange range = CTLineGetStringRange(line);
                if (targetTextPos <= lastTextRange.location + range.location + range.length) {
                    break;
                }
            }
            
            int originLength = CFArrayGetCount(lines);
            CGPoint origins[originLength];
            CTFrameGetLineOrigins(textView.ctFrame, CFRangeMake(0, 0), origins);
            // if (i == 0) we don't need to do anything; contentOffset is already set to the beginning of our BibleTextView
            // get the origin of the line just above the line we want to show because CoreText origins are on a Cartesian plane.
            if (i != 0) {
                CGPoint origin = origins[i - 1];
                contentOffset += textView.frame.size.height - origin.y;
            }
        }
        
        lastKnownContentOffset = CGPointMake(0, 0 - textFrame.size.height);
        [self setContentOffset:CGPointMake(0, contentOffset) animated:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    int height = round(textFrame.size.height);
    int previousFrameIndex = roundf(lastKnownContentOffset.y) / height;
    int currentFrameIndex  = roundf(contentOffset.y) / height;
    if (previousFrameIndex != currentFrameIndex) {
        int startActiveRange = MAX(currentFrameIndex - activeViewWindow / 2, 0);
        int endActiveRange   = MIN([self.textViews count], currentFrameIndex + activeViewWindow / 2);
        NSRange activeRange = NSMakeRange(startActiveRange, endActiveRange - startActiveRange + 1);
        
        for (int i = 0; i < [self.textViews count]; i++) {
            BibleTextView *textView = [self.textViews objectAtIndex:i];
            if (NSLocationInRange(i, activeRange)) {
                if ([textView class] == [NSNull class]) {
                    // if the view is null, create it
                    CGRect frame = CGRectMake(0, textFrame.size.height * i, textFrame.size.width, textFrame.size.height);
                    NSRange textRange = [[self.textRanges objectAtIndex:i] rangeValue];
                    NSArray *chapters = [self.chaptersByView objectAtIndex:i];
                    NSArray *verses = [self.versesByView objectAtIndex:i];
                    BibleTextView *textView = [[BibleTextView alloc] initWithFrame:frame TextRange:textRange Parent:self Chapters:chapters AndVerses:verses];
                    [self addSubview:textView];
                    [self.textViews replaceObjectAtIndex:i withObject:textView];
                }
            } else {
                // if we are not in the range of active views, make sure this view is null
                if ([textView class] != [NSNull class]) {
                    [textView removeFromSuperview];
                    textView = nil;
                    [self.textViews replaceObjectAtIndex:i withObject:[NSNull null]];
                }
            }
        }
    }
    
    lastKnownContentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self saveCurrentLocation];
        self.alwaysBounceHorizontal = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self saveCurrentLocation];
}

@end
