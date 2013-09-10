//
//  ReadingView.h
//  Bible
//
//  Created by Matthew Lorentz on 9/9/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadingView : UIScrollView <UIScrollViewDelegate>

@property (retain, nonatomic) NSAttributedString* attString;
@property (retain, nonatomic) NSString *text;
@property (retain, nonatomic) NSMutableArray* frames;

@end
