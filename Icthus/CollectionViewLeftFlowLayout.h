//
//  CollectionViewLeftFlowLayout.h
//  Icthus
//
//  Created by Matthew Lorentz on 4/8/14.
//  Copyright (c) 2014 Matthew Lorentz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewLeftFlowLayout : UICollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
