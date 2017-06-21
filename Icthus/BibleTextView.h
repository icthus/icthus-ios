//
//  BibleTextView.h
//  Icthus
//
//  Created by Matthew Lorentz on 9/5/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "ReadingView.h"
#import "BibleVerseView.h"
#import "BibleFrameInfo.h"
#import "IcthusColorMode.h"

@interface BibleTextView : UIView <IcthusColorMode> {
    @private BibleVerseView *verseView;
}

@property (nonatomic, strong) NSAttributedString *attString;
@property CTFrameRef ctFrame;
@property NSRange textRange;
@property ReadingView *parentView;
@property NSArray *chapters;
@property NSArray *verses;
@property AppDelegate *appDel;

- (id)initWithFrameInfo:(BibleFrameInfo *)frameInfo horizontalSizeClass:(UIUserInterfaceSizeClass)sizeClass andParent:(ReadingView *)parentView;
- (void)subscribeToColorChangedNotification;
- (void)unsubscribeFromColorChangedNotification;
- (void)handleColorModeChanged;
    
@end
