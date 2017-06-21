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
#import "VerseOverlayView.h"

@implementation ReadingView

@synthesize appDel;
@synthesize textViews;
@synthesize frameData;
@synthesize textRanges;
@synthesize attString;
@synthesize sizingString;
@synthesize book;
@synthesize parser;
@synthesize versesByView;
@synthesize chaptersByView;
@synthesize verseOverlayView;

NSString *markup;
NSString *currentChapter;
CGPoint lastKnownContentOffset;
NSInteger activeViewWindow = 3;
CGRect textFrame;
CGFloat topMargin;
CGPoint maxContentOffset;

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
    self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.alwaysBounceHorizontal = YES;
    self.directionalLockEnabled = YES;
    self.scrollsToTop = NO;
    parser = [[BibleMarkupParser alloc] init];
    lastKnownContentOffset = CGPointMake(0,0);
    
    CGFloat width = 160;
    CGFloat height = 100;
    CGFloat xorigin = (self.frame.size.width - width) / 2;
    CGFloat yorigin = (self.frame.size.height - height) / 2;
    self.verseOverlayView = [[VerseOverlayView alloc] initWithFrame:CGRectMake(xorigin, yorigin, width, height) MovementSensitivity:self.bounds.size.height * 0.5 InTimeInterval:1];
    self.verseOverlayView.hidden = YES;
}

- (void)addVerseOverlayViewToViewHierarchy {
    [self.verseOverlayView reset];
    [self addSubview:self.verseOverlayView];
}

- (void)removeVerseOverlayViewFromViewHierarchy {
    [self.verseOverlayView removeFromSuperview];
}

- (void)clearText {
    for (BibleTextView *view in self.textViews) {
        if (![view isEqual:[NSNull null]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)setText:(NSString *)text {
    // remove the old text
    [self clearText];
    _text = text;
}

- (void)redrawText {
    [self clearText];
    [self buildFrames];
    CGPoint contentOffset = self.contentOffset;
    int height = round(textFrame.size.height);
    int currentFrameIndex  = roundf(contentOffset.y - topMargin) / height;
    [self redrawTextViews:currentFrameIndex];
}

- (NSDictionary *)getAttributedStringAttributesForHorizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass {
    NSDictionary *attributesDict;
    
    if (sizeClass == UIUserInterfaceSizeClassRegular) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineSpacing:14];
        attributesDict = @{
                             NSFontAttributeName: [UIFont fontWithName:@"AkzidenzGroteskCE-Roman"size:24],
                             NSForegroundColorAttributeName: self.appDel.colorManager.bookTextColor,
                             NSParagraphStyleAttributeName: paragraphStyle,
                         };
    } else {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineSpacing:7.5f];
        attributesDict = @{
                             NSFontAttributeName: [UIFont fontWithName:@"AkzidenzGroteskCE-Roman"size:22],
                             NSForegroundColorAttributeName: self.appDel.colorManager.bookTextColor,
                             NSParagraphStyleAttributeName: paragraphStyle,
                         };
    }
    
    return attributesDict;
}

- (void)buildFrames {
    self.frameData = [NSMutableArray array];
    self.textViews = [NSMutableArray array];
    self.textRanges = [NSMutableArray array];
    self.chaptersByView = [NSMutableArray array];
    self.versesByView = [NSMutableArray array];
    // The problem is the self.frame is not expanded to fill the superview until just before viewWillAppear.
    
    // parse the markup
    NSString *displayString = [parser displayStringFromMarkup:self.text];
    NSDictionary *attributesDict = [self getAttributedStringAttributesForHorizontalSizeClass:self.horizontalSizeClass];
    [self setAttString:[[NSAttributedString alloc] initWithString:displayString attributes:attributesDict]];
    [self setSizingString:[[NSAttributedString alloc] initWithString:@"Foo" attributes:attributesDict]];
    
    if (self.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        textFrame = CGRectInset(self.bounds, 50, 0);
    } else {
        textFrame = CGRectInset(self.bounds, 15, 0);
    }
    topMargin = [[self.attString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil] lineSpacing];
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
        frameInfo.frame = CGRectMake(0, textFrame.size.height * pageIndex + topMargin, self.frame.size.width, textFrame.size.height);
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
    
    // Then parse all the verse and chapter numbers
    [parser addChapterAndVerseNumbersToFrameData:frameData fromMarkup:self.text];
    
    // set the total size of the scroll view
    // We need to cut off the blank space on the last text view
    NSRange lastRange = [[self.frameData lastObject] textRange];
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
        framesetter,
        CFRangeMake(lastRange.location, lastRange.length),
        nil, CGSizeMake(textFrame.size.width, CGFLOAT_MAX),
        nil
    );
    CGFloat lastFrameHeight = suggestedSize.height;
    CGFloat lastLineSpacing = [[self.attString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil] lineSpacing];
    self.contentSize = CGSizeMake(textFrame.size.width, (pageIndex - 1) * textFrame.size.height + topMargin + lastFrameHeight + lastLineSpacing);
    maxContentOffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
}

- (int)getCurrentTextPosition {
    // hack to fix a weird bug where self.book would be null on first launch on an 32-bit iPhone using iCloud.
    if (!self.book.managedObjectContext) {
        self.book = (Book *)[[(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext] objectWithID:self.book.objectID];
    }
    
    // find the current view
    int contentOffset = round(self.contentOffset.y);
    int height = round(textFrame.size.height);
    int currentFrameIndex  = (contentOffset - topMargin) / height;
    BibleTextView *textView = [self.textViews objectAtIndex:currentFrameIndex];
    if ([textView class] == [NSNull class]) {
        NSLog(@"Error: getCurrentTextPosition failed to get a non-nil textView");
        return 0;
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
    int textPos = (int)(textViewRange.location + lineRange.location + lineRange.length);
    return textPos;
}

- (BasicBookLocation *)getCurrentLocation {
    return [parser getLocationForCharAtIndex:[self getCurrentTextPosition] forText:self.text andBook:self.book];
}

- (BookLocation *)saveCurrentLocation {
    BookLocation *bookLocation = [parser saveLocationForCharAtIndex:[self getCurrentTextPosition] forText:self.text andBook:self.book];
    NSLog(@"ReadingView.saveCurrentLocation: got location %@ %@:%@", self.book.shortName, bookLocation.chapter, bookLocation.verse);
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
        
        // TODO: Use ReadingViewController.sizeClass here
        BibleTextView *textView = [[BibleTextView alloc] initWithFrameInfo:[frameData objectAtIndex:i] horizontalSizeClass:self.horizontalSizeClass andParent:self];
        [self addSubview:textView];
        [self.textViews replaceObjectAtIndex:i withObject:textView];

        int contentOffset = textView.frame.origin.y;

        // find the correct line in the view
        CFArrayRef lines = CTFrameGetLines(textView.ctFrame);
        if (CFArrayGetCount(lines)) {
            for (i = 0; i < CFArrayGetCount(lines) - 1; i++) {
                CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                CFRange range = CTLineGetStringRange(line);
                if (targetTextPos < textRange.location + range.location + range.length - 1) { // TODO: We shouldn't need a "- 1" in this statement. There must be a bug somewhere but I can't find it and it's time to ship.
                    break;
                }
            }
            
            int originLength = CFArrayGetCount(lines);
            CGPoint origins[originLength];
            CTFrameGetLineOrigins(textView.ctFrame, CFRangeMake(0, 0), origins);
            CGPoint origin = origins[i];
            contentOffset += textView.frame.size.height - origin.y - [self lineHeightForString:self.attString];
        }
        
        lastKnownContentOffset = CGPointMake(0, 0 - textFrame.size.height); // to trigger BibleTextFrame creation on next scroll;
        if (contentOffset > maxContentOffset.y) {
            [self setContentOffset:maxContentOffset animated:NO];
        } else {
            [self setContentOffset:CGPointMake(0, contentOffset) animated:NO];
        }
        // Sometimes scrollViewDidScroll doesn't get called. So we'll call it ourselves.
        [self scrollViewDidScroll:self];
    }
}

- (void)redrawTextViews:(int)currentFrameIndex {
    int startActiveRange = MAX(currentFrameIndex - activeViewWindow / 2, 0);
    int endActiveRange   = MIN([self.textViews count], currentFrameIndex + activeViewWindow / 2);
    NSRange activeRange = NSMakeRange(startActiveRange, endActiveRange - startActiveRange + 1);
    
    for (int i = 0; i < [self.textViews count]; i++) {
        BibleTextView *textView = [self.textViews objectAtIndex:i];
        if (NSLocationInRange(i, activeRange)) {
            if ([textView class] == [NSNull class]) {
                // if the view is null, create it
                BibleTextView *textView = [[BibleTextView alloc] initWithFrameInfo:[frameData objectAtIndex:i] horizontalSizeClass:self.horizontalSizeClass andParent:self];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    int height = round(textFrame.size.height);
    int previousFrameIndex = roundf(lastKnownContentOffset.y - topMargin) / height;
    int currentFrameIndex  = roundf(contentOffset.y - topMargin) / height;
    if (previousFrameIndex != currentFrameIndex) {
        [self redrawTextViews:currentFrameIndex];
    }
    
    // Uncomment this to enable the VerseOverlayView updating
    // Update the verseOverlayView
    //if (self.verseOverlayView) {
    //    self.verseOverlayView.frame = CGRectMake(0, contentOffset.y, 200, 100);
    //    [self.verseOverlayView updateLabelWithLocation:[self getCurrentLocation]];
    //    [self.verseOverlayView userScrolledPoints:abs(lastKnownContentOffset.y - contentOffset.y)];
    //    [self bringSubviewToFront:self.verseOverlayView];
    //}
    
    // Dirty the NSUserActivity
    if(NSClassFromString(@"NSUserActivity")) {
        self.appDel.detailView.userActivity.needsSave = YES;
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
    // Uncomment this to enable the VerseOverlayView
    //[self.verseOverlayView fadeOutOfView];
}

- (CGFloat)lineHeightForString:(NSAttributedString *)string {
    CGFloat lineHeight = 0.0;
    UIFont *uiFont = [string attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)uiFont.fontName, uiFont.pointSize, nil);
    
    if (ctFont != nil) {
        lineHeight += CTFontGetLeading(ctFont);
        lineHeight += floorf(CTFontGetAscent(ctFont) + 0.5);
        lineHeight += floorf(CTFontGetDescent(ctFont) + 0.5);
    } else {
        NSLog(@"Error: lineHeightForString got a nil font.");
    }
    
    NSParagraphStyle *style = [string attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
    lineHeight += style.lineSpacing;
    
    return lineHeight;
}

@end
