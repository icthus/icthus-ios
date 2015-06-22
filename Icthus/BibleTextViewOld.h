//
//  BibleTextViewOld.h
//  Icthus
//
//  Created by Matthew Lorentz on 9/5/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "BibleVerseView.h"
#import "BibleFrameInfo.h"
#import "IcthusColorMode.h"
@class ReadingViewOld;

@interface BibleTextViewOld : UIView <IcthusColorMode> {
    @private BibleVerseView *verseView;
}

@property (nonatomic, strong) NSAttributedString *attString;
@property CTFrameRef ctFrame;
@property NSRange textRange;
@property ReadingViewOld *parentView;
@property NSArray *chapters;
@property NSArray *verses;
@property AppDelegate *appDel;

- (id)initWithFrameInfo:(BibleFrameInfo *)frameInfo andParent:(ReadingViewOld *)parentView;
- (void)subscribeToColorChangedNotification;
- (void)unsubscribeFromColorChangedNotification;
- (void)handleColorModeChanged;
    
@end
