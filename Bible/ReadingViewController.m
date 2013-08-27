//
//  ReadingViewController.m
//  Bible
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "ReadingViewController.h"

@interface ReadingViewController ()

@end

@implementation ReadingViewController

@synthesize textView;
@synthesize book = _book;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithBook:(Book *)book {
    self = [super init];
    if (self) {
        _book = book;
        [[self textView] setText:[book text]];
    }
    return self;
}

- (void)setBook:(Book *)newBook {
    if (_book != newBook) {
        _book = newBook;
        
        // Update the view.
        [self configureView];
    }
    
//    if (self.masterPopoverController != nil) {
//        [self.masterPopoverController dismissPopoverAnimated:YES];
//    }
}


- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (_book) {
        [self.textView setText:[_book text]];
        NSLog(@"Text for book %@", [_book text]);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureView];
}

@end
