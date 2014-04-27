//
//  PMCenteredCircularCollectionView.h
//  Pods
//
//  Created by Peter Meyers on 3/23/14.
//
//

#import "PMCircularCollectionView.h"
#import "PMCenteredCollectionViewFlowLayout.h"

@interface PMCenteredCircularCollectionView : PMCircularCollectionView

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(PMCenteredCollectionViewFlowLayout *)layout;

- (void) centerCell:(UICollectionViewCell *)cell animated:(BOOL)animated;

- (void) centerCellAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end
