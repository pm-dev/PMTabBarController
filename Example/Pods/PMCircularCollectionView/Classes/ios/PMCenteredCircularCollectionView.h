//
//  PMCenteredCircularCollectionView.h
//  Pods
//
//  Created by Peter Meyers on 3/23/14.
//
//

#import "PMCircularCollectionView.h"

@interface PMCenteredCircularCollectionView : PMCircularCollectionView

@property (nonatomic, weak) id<UICollectionViewDelegate, UIScrollViewDelegate> secondDelegate;

- (void) centerView:(UIView *)view animated:(BOOL)animated;

@end
