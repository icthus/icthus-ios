//
//  ReadingViewController.m
//  Bible
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import "ReadingViewController.h"
#import "ReadingView.h"

@interface ReadingViewController ()

@end

@implementation ReadingViewController

@synthesize readingView;
@synthesize book = _book;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)awakeFromNib {
}

- (id)initWithBook:(Book *)book {
    self = [super init];
    if (self) {
        _book = book;
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
        [self.readingView setText:[_book text]];
        [self.readingView setContentOffset:CGPointMake(0.0, [[_book position] floatValue])];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [_book setPosition:[NSNumber numberWithFloat:[self.readingView contentOffset].y]];
    NSManagedObjectContext *context = [(NSManagedObject *)_book managedObjectContext];
    NSError *error;
    [context save:&error];
    if (error != nil) {
        NSLog(@"An error occured during save");
        NSLog(@"%@", [error localizedDescription]);
    }

}

@end
