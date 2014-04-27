//
//  PMCircularCollectionView.h
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import <UIKit/UIKit.h>

@protocol PMCircularCollectionViewDataSource;

@interface PMCircularCollectionView : UICollectionView <UICollectionViewDelegateFlowLayout>

@property (nonatomic) CGFloat shadowRadius;
@property (nonatomic, readonly) NSInteger itemCount;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

- (void)setDataSource:(id<PMCircularCollectionViewDataSource>)dataSource;
- (id<PMCircularCollectionViewDataSource>)PMDataSource;

- (void)setDelegate:(id<UICollectionViewDelegateFlowLayout>)delegate;
- (id<UICollectionViewDelegateFlowLayout>)PMDelegate;

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;
+ (instancetype) collectionViewWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;
+ (instancetype) collectionView;

@end

@protocol PMCircularCollectionViewDataSource <NSObject>

@required
- (NSString *) circularCollectionView:(PMCircularCollectionView *)collectionView reuseIdentifierForIndex:(NSUInteger)index;
- (NSUInteger) numberOfItemsInCircularCollectionView:(PMCircularCollectionView *)collectionView;
- (void) circularCollectionView:(PMCircularCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell atIndex:(NSUInteger)index;

@end
