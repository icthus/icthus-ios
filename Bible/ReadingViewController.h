//
//  ReadingViewController.h
//  Bible
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface ReadingViewController : UIViewController
-(id)initWithBook:(Book *)book;

@property (nonatomic, strong) Book *book;
@property (nonatomic, retain) IBOutlet UITextView *textView;

@end
