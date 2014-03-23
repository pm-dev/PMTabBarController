//
//  PMCircularCollectionView.m
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import "PMCircularCollectionView.h"
#import "PMUtils.h"

static CGFloat const ContentMultiplier = 4.0f;

static inline NSString * PMReuseIdentifierForViewIndex(NSUInteger index) {
    return [[NSNumber numberWithInteger:index] stringValue];
}


@interface PMCircularCollectionView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) CGSize viewsSize;

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
    }
    return self;
}

- (void) setViews:(NSArray *)views
{
    if (_views != views) {
        _views = views;
        [self registerCells];
        [self setMinimumSpacing];
        [self reloadData];
    }
}

- (void) registerCells
{
    for (NSUInteger i = 0; i < self.views.count; i++) {
        [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:PMReuseIdentifierForViewIndex(i)];
    }
}

- (void) setMinimumSpacing
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    
    CGFloat contentWidth = 0.0f;
    CGFloat contentHeight = 0.0f;
    
    for (UIView *view in self.views) {
        contentWidth += view.frame.size.width;
        contentHeight += view.frame.size.height;
    }
    
    self.viewsSize = CGSizeMake(contentWidth, contentHeight);
    
    NSUInteger spaces = self.views.count - 1;
    CGFloat minimumInteritemSpacing = ceilf((self.bounds.size.width - contentWidth) / spaces + 1.0f);
    CGFloat minimumLineSpacing = ceilf((self.bounds.size.height - contentHeight) / spaces + 1.0f);
    
    if (minimumInteritemSpacing - layout.minimumInteritemSpacing > 0.0f) {
        layout.minimumInteritemSpacing = minimumInteritemSpacing;
    }
    
    if (minimumLineSpacing - layout.minimumLineSpacing > 0.0f) {
        layout.minimumLineSpacing = minimumLineSpacing;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self recenterIfNecessary];
}

- (void) recenterIfNecessary
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGPoint currentOffset = self.contentOffset;
    
    switch (layout.scrollDirection) {
            
        case UICollectionViewScrollDirectionHorizontal: {

            CGFloat contentCenteredX = (self.contentSize.width - self.bounds.size.width) / 2.0f;
            CGFloat deltaFromCenter = currentOffset.x - contentCenteredX;
            CGFloat singleContentWidth = self.viewsSize.width + layout.minimumInteritemSpacing * self.views.count;
            
            if (fabsf(deltaFromCenter) >= singleContentWidth ) {
                
                CGFloat correction = (deltaFromCenter > 0)? deltaFromCenter - singleContentWidth : deltaFromCenter + singleContentWidth;
                
                currentOffset.x = contentCenteredX + correction;
            }

            break;
        }
        case UICollectionViewScrollDirectionVertical: {
            
            CGFloat contentCenteredY = (self.contentSize.height - self.bounds.size.height) / 2.0f;
            CGFloat deltaFromCenter = currentOffset.y - contentCenteredY;
            CGFloat singleContentHeight = self.viewsSize.height + layout.minimumLineSpacing * self.views.count;
            
            if (fabsf(deltaFromCenter) >= singleContentHeight) {
                
                CGFloat correction = (deltaFromCenter > 0)? deltaFromCenter - singleContentHeight : deltaFromCenter + singleContentHeight;
                
                currentOffset.y = contentCenteredY + correction;
            }
            
            break;
        }
    }
    
    self.contentOffset = currentOffset;
}


- (NSUInteger) viewIndexForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.item % self.views.count;
}


#pragma mark - UICollectionViewDatasource Methods


- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    return self.views.count * ContentMultiplier;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    NSUInteger viewIndex = [self viewIndexForIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PMReuseIdentifierForViewIndex(viewIndex)
                                                                           forIndexPath:indexPath];
    if (!cell.contentView.subviews.count) {
        
        cell.contentView.backgroundColor = [UIColor blueColor];
        UIView *view = self.views[viewIndex];
        [cell.contentView addSubview:view];
        
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
        PMDirection direction = layout.scrollDirection == UICollectionViewScrollDirectionHorizontal? PMDirectionVertical : PMDirectionHorizontal;
        [view centerInRect:cell.contentView.bounds forDirection:direction];
    }

    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = self.views[[self viewIndexForIndexPath:indexPath]];
    
    switch (collectionViewLayout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: return CGSizeMake(view.frame.size.width, self.bounds.size.height);
        case UICollectionViewScrollDirectionVertical: return CGSizeMake(self.bounds.size.width, view.frame.size.height);
    }
}

@end
