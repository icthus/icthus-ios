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
        [_book setReading:[NSNumber numberWithBool:YES]];
        NSManagedObjectContext *context = [(NSManagedObject *)_book managedObjectContext];
        NSError *error;
        [context save:&error];
        if (error != nil) {
            NSLog(@"An error occured during save");
            NSLog(@"%@", [error localizedDescription]);
        }
        
        // Update the view.
        [self configureView];
    }
    
}


- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (_book) {
        [self.textView setText:[_book text]];
        [self.textView setContentOffset:CGPointMake(0.0, [[_book position] floatValue])];
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

- (void)viewWillDisappear:(BOOL)animated {
    [_book setPosition:[NSNumber numberWithFloat:[self.textView contentOffset].y]];
    NSManagedObjectContext *context = [(NSManagedObject *)_book managedObjectContext];
    NSError *error;
    [context save:&error];
    if (error != nil) {
        NSLog(@"An error occured during save");
        NSLog(@"%@", [error localizedDescription]);
    }

}

@end
