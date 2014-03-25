//
//  PMCenteredCircularCollectionView.m
//  Pods
//
//  Created by Peter Meyers on 3/23/14.
//
//

#import "PMCenteredCircularCollectionView.h"
#import "PMUtils.h"


@implementation PMCenteredCircularCollectionView


- (void) centerView:(UIView *)view animated:(BOOL)animated
{
    NSUInteger index = [self.views indexOfObject:view];
    [self centerViewAtIndex:index animated:animated];
}

- (void) centerViewAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index < self.views.count) {
        
        if (CGSizeEqualToSize(CGSizeZero, self.contentSize)) {
            [self layoutSubviews];
        }
        
        NSIndexPath *indexPathAtMiddle;
        if (self.visibleCells.count) {
            indexPathAtMiddle = [self visibleIndexPathNearestToPoint:[self contentOffsetInBoundsCenter]];
        }
        else {
            indexPathAtMiddle = [self indexPathNearestToPoint:[self contentOffsetInBoundsCenter]];
        }
        
        if (indexPathAtMiddle) {
            
            NSInteger originalIndexOfMiddle = indexPathAtMiddle.item % self.views.count;
            
            NSInteger delta = [self.views distanceFromIndex:originalIndexOfMiddle toIndex:index circular:YES];
            
            NSInteger toItem = indexPathAtMiddle.item + delta;
            
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toItem inSection:0];
            
            [self scrollToItemAtIndexPath:toIndexPath
                         atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                                 animated:animated];
        }
    }
}

- (void) centerNearestIndexPath
{
    // Find index path of closest cell. Do not use -indexPathForItemAtPoint:
    // This method returns nil if the specified point lands in the spacing between cells.
    
    NSIndexPath *indexPath = [self visibleIndexPathNearestToPoint:[self contentOffsetInBoundsCenter]];
    
    if (indexPath) {
        [self collectionView:self didSelectItemAtIndexPath:indexPath];
    }
}

- (CGPoint) contentOffsetInBoundsCenter
{
    CGPoint middlePoint = self.contentOffset;
    middlePoint.x += self.bounds.size.width / 2.0f;
    middlePoint.y += self.bounds.size.height / 2.0f;
    return middlePoint;
}


#pragma mark - UIScrollViewDelegate Methods


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint targetOffset = *targetContentOffset;
    
    BOOL targetFirstIndexPath = CGPointEqualToPoint(targetOffset, CGPointZero);
    BOOL targetLastIndexPath = (targetOffset.x == self.contentSize.width - self.bounds.size.width &&
                                targetOffset.y == self.contentSize.height - self.bounds.size.height);
    
    if ( !targetFirstIndexPath && !targetLastIndexPath) {
        
        targetOffset.x += self.bounds.size.width / 2.0f;
        targetOffset.y += self.bounds.size.height / 2.0f;
        
        NSIndexPath *targetedIndexPath = [self indexPathNearestToPoint:targetOffset];
        
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:targetedIndexPath];
        
        targetOffset = [self contentOffsetForCenteredRect:attributes.frame];
        
        *targetContentOffset = targetOffset;
    }

    if ([[self superclass] instancesRespondToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [super scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
    else if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.secondaryDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerNearestIndexPath];
    
    if ([[self superclass] instancesRespondToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [super scrollViewDidEndDecelerating:scrollView];
    }
    else if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.secondaryDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self centerNearestIndexPath];
    }
    
    if ([[self superclass] instancesRespondToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    else if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.secondaryDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}


#pragma mark - UICollectionViewDelegate Methods


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self scrollToItemAtIndexPath:indexPath
                 atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                         animated:YES];
    
    if ([[self superclass] instancesRespondToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
    else if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self.secondaryDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

@end
