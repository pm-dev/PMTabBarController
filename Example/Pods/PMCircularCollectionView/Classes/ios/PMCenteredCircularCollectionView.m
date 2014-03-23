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
    NSUInteger originalIndexOfView = [self.views indexOfObject:view];
    
    if (originalIndexOfView != NSNotFound) {
        
        NSIndexPath *indexPathAtMiddle;
        if (self.visibleCells.count) {
            indexPathAtMiddle = [self visibleIndexPathNearestToPoint:[self contentOffsetInBoundsCenter]];
        }
        else {
            indexPathAtMiddle = [self indexPathNearestToPoint:[self contentOffsetInBoundsCenter]];
        }
        
        if (indexPathAtMiddle) {
            
            NSInteger originalIndexOfMiddle = indexPathAtMiddle.item % self.views.count;
            
            NSInteger delta = [self.views distanceFromIndex:originalIndexOfMiddle toIndex:originalIndexOfView circular:YES];
            
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
    
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.secondDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerNearestIndexPath];
    
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.secondDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.secondDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.secondDelegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.secondDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self centerNearestIndexPath];
    }
    
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.secondDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.secondDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.secondDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([self.secondDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        [self.secondDelegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.secondDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.secondDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.secondDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if ([self.secondDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.secondDelegate scrollViewDidScrollToTop:scrollView];
    }
}


#pragma mark - UICollectionViewDelegate Methods


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self scrollToItemAtIndexPath:indexPath
                 atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                         animated:YES];
    
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self.secondDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:shouldHighlightItemAtIndexPath:)]) {
        return [self.secondDelegate collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
    }
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:didHighlightItemAtIndexPath:)]) {
        [self.secondDelegate collectionView:collectionView didHighlightItemAtIndexPath:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:didUnhighlightItemAtIndexPath:)]) {
        [self.secondDelegate collectionView:collectionView didUnhighlightItemAtIndexPath:indexPath];
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:shouldSelectItemAtIndexPath:)]) {
        return [self.secondDelegate collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
    }
    return YES;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:shouldDeselectItemAtIndexPath:)]) {
        return [self.secondDelegate collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath];
    }
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)]) {
        [self.secondDelegate collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [self.secondDelegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)]) {
        [self.secondDelegate collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:shouldShowMenuForItemAtIndexPath:)]) {
        return [self.secondDelegate collectionView:collectionView shouldShowMenuForItemAtIndexPath:indexPath];
    }
    return NO;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:canPerformAction:forItemAtIndexPath:withSender:)]) {
        return [self.secondDelegate collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
    }
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:performAction:forItemAtIndexPath:withSender:)]) {
        [self.secondDelegate collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
    }
}
- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    if ([self.secondDelegate respondsToSelector:@selector(collectionView:transitionLayoutForOldLayout:newLayout:)]) {
        return [self.secondDelegate collectionView:collectionView transitionLayoutForOldLayout:fromLayout newLayout:toLayout];
    }
    return [[UICollectionViewTransitionLayout alloc] initWithCurrentLayout:fromLayout
                                                                nextLayout:toLayout];
}


@end
