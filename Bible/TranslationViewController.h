//
//  TranslationViewController.h
//  Icthus
//
//  Created by Matthew Lorentz on 10/17/13.
//  Copyright (c) 2013 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface TranslationViewController : UITableViewController

@property (nonatomic, strong) AppDelegate *appDel;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
