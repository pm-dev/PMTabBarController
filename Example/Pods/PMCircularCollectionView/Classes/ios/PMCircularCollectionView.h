//
//  PMCircularCollectionView.h
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import <UIKit/UIKit.h>

@interface PMCircularCollectionView : UICollectionView <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<UICollectionViewDelegateFlowLayout> secondaryDelegate;
@property (nonatomic, strong) NSArray *views;
@property (nonatomic) CGFloat shadowRadius;

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;

@end
