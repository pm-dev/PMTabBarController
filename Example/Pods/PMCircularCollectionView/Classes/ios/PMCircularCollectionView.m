//
//  PMCircularCollectionView.m
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import "PMCircularCollectionView.h"
#import "PMUtils.h"

static NSString *CellReuseID = @"Cell";
static CGFloat const ContentMultiplier = 3.0f;

@interface PMCircularCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation PMCircularCollectionView

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellReuseID];
    }
    return self;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = self.views[indexPath.row % self.views.count];
    
    switch (collectionViewLayout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: return CGSizeMake(view.frame.size.width, self.bounds.size.height);
        case UICollectionViewScrollDirectionVertical: return CGSizeMake(self.bounds.size.width, view.frame.size.height);
    }
}


- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    return self.views.count * ContentMultiplier;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseID
                                                                           forIndexPath:indexPath];
    
    UIView *view = self.views[indexPath.row % self.views.count];
    
    [cell.contentView removeSubviews];
    [cell.contentView addSubview:view];
    
    return cell;
}

- (void) recenterIfNecessary
{
    CGPoint currentOffset = self.contentOffset;
    CGFloat centerOffset;
    CGFloat distanceFromCenter;
    CGFloat contentDistance;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    
    switch (layout.scrollDirection) {
            
        case UICollectionViewScrollDirectionHorizontal:
            contentDistance = self.contentSize.width;
            centerOffset = (contentDistance -  self.bounds.size.width) / 2.0f;
            distanceFromCenter = fabsf(currentOffset.x - centerOffset);
            break;
            
        case UICollectionViewScrollDirectionVertical:
            contentDistance = self.contentSize.height;
            centerOffset = (contentDistance - self.bounds.size.height) / 2.0f;
            distanceFromCenter = fabsf(currentOffset.y - centerOffset);
            break;
    }
    
    if (distanceFromCenter >= contentDistance / ContentMultiplier  ) {
        
        switch (layout.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal:
                currentOffset.x = centerOffset;
                break;
            case UICollectionViewScrollDirectionVertical:
                currentOffset.y = centerOffset;
                break;
        }
        
        self.contentOffset = currentOffset;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self recenterIfNecessary];
}

@end
