//
//  BookCollectionViewCell.h
//  Icthus
//
//  Created by Matthew Lorentz on 1/13/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "AppDelegate.h"

@interface BookCollectionViewCell : UICollectionViewCell

@property AppDelegate *appDel;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property Book *book;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
