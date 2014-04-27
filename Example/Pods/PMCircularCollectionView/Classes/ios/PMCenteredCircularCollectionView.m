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

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(PMCenteredCollectionViewFlowLayout *)layout
{
    return [super initWithFrame:frame collectionViewLayout:layout];
}

- (void) centerCell:(UICollectionViewCell *)cell animated:(BOOL)animated;
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    [self centerCellAtIndex:indexPath.item animated:animated];
}

- (void) centerCellAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index < self.itemCount) {
        
        if (CGSizeEqualToSize(CGSizeZero, self.contentSize)) {
            [self layoutSubviews];
        }
        
        NSIndexPath *indexPathAtMiddle = [self indexPathAtMiddle];
        
        if (indexPathAtMiddle) {
            
            NSInteger originalIndexOfMiddle = indexPathAtMiddle.item % self.itemCount;
            
            NSRange range = NSMakeRange(0, self.itemCount);

            NSInteger delta = PMShortestCircularDistance(originalIndexOfMiddle, index, range);
            
            NSInteger toItem = indexPathAtMiddle.item + delta;
            
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toItem inSection:0];
            
            [self scrollToItemAtIndexPath:toIndexPath
                         atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                                 animated:animated];
        }
    }
}

- (NSIndexPath *) indexPathAtMiddle
{
    if (self.visibleCells.count) {
        return [self visibleIndexPathNearestToPoint:[self contentOffsetInBoundsCenter]];
    }
    else {
        return [self indexPathNearestToPoint:[self contentOffsetInBoundsCenter]];
    }
}

- (void) centerNearestIndexPath
{
    // Find index path of closest cell. Do not use -indexPathForItemAtPoint:
    // This method returns nil if the specified point lands in the spacing between cells.
    
    NSIndexPath *indexPath = [self indexPathAtMiddle];
    
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


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerNearestIndexPath];
    
    if ([[self superclass] instancesRespondToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [super scrollViewDidEndDecelerating:scrollView];
    }
    else if ([[self PMDelegate] respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [[self PMDelegate] scrollViewDidEndDecelerating:scrollView];
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
    else if ([[self PMDelegate] respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [[self PMDelegate] collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

@end
