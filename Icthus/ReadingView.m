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
#import "BibleFrameInfo.h"
#import "AppDelegate.h"

@implementation ReadingView

@synthesize textViews;
@synthesize frameData;
@synthesize textRanges;
@synthesize attString;
@synthesize sizingString;
@synthesize book;
@synthesize parser;
@synthesize versesByView;
@synthesize chaptersByView;

NSString *markup;
NSString *currentChapter;
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
        NSDictionary *attributesDict = @{
            NSFontAttributeName: [UIFont fontWithName:@"AkzidenzGroteskCE-Roman"size:24],
            NSParagraphStyleAttributeName: paragraphStyle,
        };
        [self setAttString:[[NSAttributedString alloc] initWithString:displayString attributes:attributesDict]];
        [self setSizingString:[[NSAttributedString alloc] initWithString:@"Foo" attributes:attributesDict]];
    } else {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineSpacing:6];
        NSDictionary *attributesDict = @{
            NSFontAttributeName: [UIFont fontWithName:@"AkzidenzGroteskCE-Roman"size:20],
            NSParagraphStyleAttributeName: paragraphStyle,
        };
        [self setAttString:[[NSAttributedString alloc] initWithString:displayString attributes:attributesDict]];
        [self setSizingString:[[NSAttributedString alloc] initWithString:@"Foo" attributes:attributesDict]];
    }
        
    // build the subviews
    [self buildFrames];
}

- (void)buildFrames {
    self.frameData = [NSMutableArray array];
    self.textViews = [NSMutableArray array];
    self.textRanges = [NSMutableArray array];
    self.chaptersByView = [NSMutableArray array];
    self.versesByView = [NSMutableArray array];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        textFrame = CGRectInset(self.bounds, 50, 0);
    } else {
        textFrame = CGRectInset(self.bounds, 15, 0);
    }
    // Set the height of the frame to fit an arbitrary 50 lines of text
    CGFloat lineHeight = [self lineHeightForString:self.attString];
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
        
        // Save the frame info so we can instantiate this frame later.
        BibleFrameInfo *frameInfo = [[BibleFrameInfo alloc] init];
        frameInfo.frame = CGRectMake(0, textFrame.size.height * pageIndex, self.frame.size.width, textFrame.size.height);
        frameInfo.ctFrame = frame;
        frameInfo.textRange = nsFrameRange;

        CFArrayRef lines = CTFrameGetLines(frame);
        int length = CFArrayGetCount(lines);
        NSMutableArray *lineRanges = [[NSMutableArray alloc] initWithCapacity:length];
        for (int i = 0; i < length; i++) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            CFRange cfStringRange = CTLineGetStringRange(line);
            [lineRanges addObject:[NSValue valueWithRange:NSMakeRange(cfStringRange.location, cfStringRange.length)]];
        }
        frameInfo.lineRanges = lineRanges;
        frameInfo.chapters = [[NSMutableArray alloc] initWithCapacity:length];
        frameInfo.verses   = [[NSMutableArray alloc] initWithCapacity:length];
        for (int i = 0; i < length; i++) {
            [frameInfo.chapters addObject:[[NSMutableArray alloc] init]];
            [frameInfo.verses   addObject:[[NSMutableArray alloc] init]];
        }
        
        [self.frameData addObject:frameInfo];
        [self.textViews addObject:[NSNull null]];
        
        //prepare for next frame
        textPos += frameRange.length;
        pageIndex++;
        contentOffset += textFrame.size.height;
    }
    
    // The parse all the verse and chapter numbers
    [parser addChapterAndVerseNumbersToFrameData:frameData fromMarkup:self.text];
    
    //set the total size of the scroll view
    self.contentSize = CGSizeMake(textFrame.size.width, pageIndex * textFrame.size.height);
}

- (BookLocation *)saveCurrentLocation {
    // hack to fix a weird bug where self.book would be null on first launch on an 32-bit iPhone using iCloud.
    if (!self.book.managedObjectContext) {
        self.book = (Book *)[[(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext] objectWithID:self.book.objectID];
    }
    
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
    NSRange textViewRange = [[frameData objectAtIndex:currentFrameIndex] textRange];
    int location = textViewRange.location + lineRange.location + lineRange.length;

    BookLocation *bookLocation = [parser saveLocationForCharAtIndex:location forText:self.text andBook:self.book];
    NSLog(@"ReadingView.getCurrentLocation: got location %@ %@:%@", self.book.shortName, bookLocation.chapter, bookLocation.verse);
    return bookLocation;
}

- (void)setCurrentLocation:(BookLocation *)location {
    if ([self.textViews count]) {
        int targetTextPos = [parser getTextPositionForLocation:location inMarkup:self.text];

        // find the index of the view with the given location and instantiate it
        NSRange textRange;
        int i;
        for (i = 0; i < [frameData count]; i++) {
            textRange = [[frameData objectAtIndex:i] textRange];
            if (NSLocationInRange(targetTextPos, textRange)) {
                break;
            }
        }

        BibleTextView *textView = [[BibleTextView alloc] initWithFrameInfo:[frameData objectAtIndex:i] andParent:self];
        [self addSubview:textView];
        [self.textViews replaceObjectAtIndex:i withObject:textView];

        int contentOffset = textView.frame.origin.y;

        // find the correct line in the view
        CFArrayRef lines = CTFrameGetLines(textView.ctFrame);
        if (CFArrayGetCount(lines)) {
            for (i = 0; i < CFArrayGetCount(lines); i++) {
                CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                CFRange range = CTLineGetStringRange(line);
                if (targetTextPos <= textRange.location + range.location + range.length) {
                    break;
                }
            }
            
            int originLength = CFArrayGetCount(lines);
            CGPoint origins[originLength];
            CTFrameGetLineOrigins(textView.ctFrame, CFRangeMake(0, 0), origins);
            // if (i == 0) we don't need to do anything; contentOffset is already set to the beginning of our BibleTextView
            // get the origin of the line just above the line we want to show because CoreText origins are on a Cartesian plane.
//            if (i != 0) {
//                CGPoint origin = origins[i - 1];
                CGPoint origin = origins[i];
                contentOffset += textView.frame.size.height - origin.y;
//            }
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
                    BibleTextView *textView = [[BibleTextView alloc] initWithFrameInfo:[frameData objectAtIndex:i] andParent:self];
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

- (CGFloat)lineHeightForString:(NSAttributedString *)string {
    CGFloat lineHeight = [self.sizingString boundingRectWithSize:CGSizeMake(textFrame.size.width, textFrame.size.height) options:0 context:nil].size.height;
    NSParagraphStyle *style = [self.attString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
    lineHeight += style.lineSpacing;
    return lineHeight;
}

@end
