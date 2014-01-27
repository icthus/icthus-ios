//
//  BookCollectionViewCell.m
//  Bible
//
//  Created by Matthew Lorentz on 1/13/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import "BookCollectionViewCell.h"

@implementation BookCollectionViewCell

@synthesize label;
@synthesize book;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UICollectionViewLayout *layout = [[UICollectionViewLayout alloc] init];
        UICollectionView *chapterCollectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
        self.collectionView = chapterCollectionView;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
