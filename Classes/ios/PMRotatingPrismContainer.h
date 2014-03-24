//
//  PMRotatingPrismContainer.h
//  PMPrismContainerController
//
//  Created by Peter Meyers on 2/24/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const PMRotatingPrismContainerRotationWillBegin;
extern NSString * const PMRotatingPrismContainerRotationDidComplete;
extern NSString * const PMRotatingPrismContainerRotationDidCancel;

@interface PMRotatingPrismContainer : UIViewController

@property (nonatomic, strong, readonly) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *titleViews;

- (void) rotateToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completionBlock;

- (instancetype) initWithViewControllers:(NSArray *)viewControllers;

+ (instancetype) rotatingPrismContainerWithViewControllers:(NSArray *)viewControllers;

@end
