//
//  PMCenteredCircularCollectionView.h
//  Pods
//
//  Created by Peter Meyers on 3/23/14.
//
//

#import "PMCircularCollectionView.h"

@interface PMCenteredCircularCollectionView : PMCircularCollectionView

- (void) centerView:(UIView *)view animated:(BOOL)animated;

- (void) centerViewAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end
