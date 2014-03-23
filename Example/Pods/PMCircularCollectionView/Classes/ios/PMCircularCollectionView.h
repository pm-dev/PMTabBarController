//
//  PMCircularCollectionView.h
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import <UIKit/UIKit.h>

@interface PMCircularCollectionView : UICollectionView <UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *views;

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;

@end
