//
//  ChapterCollectionViewCell.h
//  Icthus
//
//  Created by Matthew Lorentz on 1/25/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ChapterCollectionViewCell : UICollectionViewCell
@property AppDelegate *appDel;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end
