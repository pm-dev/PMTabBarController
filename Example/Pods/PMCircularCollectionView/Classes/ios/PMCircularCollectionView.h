//
//  PMCircularCollectionView.h
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import <UIKit/UIKit.h>

@interface PMCircularCollectionView : UICollectionView

@property (nonatomic, strong) NSArray *views;
@property (nonatomic, weak) id<UICollectionViewDelegate> secondaryDelegate;

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;

@end
