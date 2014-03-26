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

- (void) centerView:(UIView *)view animated:(BOOL)animated;

- (void) centerViewAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end
