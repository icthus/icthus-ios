//
//  ChapterPickerViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 8/27/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Book.h"

@interface ChapterPickerViewController: UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) AppDelegate *appDel;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Book *selectedBook;
@property (nonatomic) NSUInteger selectedChapter;

@end
