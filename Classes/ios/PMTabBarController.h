//
//  PMTabBarController.h
//  PMPrismContainerController
//
//  Created by Peter Meyers on 2/24/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMTabBarController : UITabBarController

@property (nonatomic, strong) NSArray *tabViews;

- (instancetype) initWithTabViews:(NSArray *)tabViews;
+ (instancetype) tabBarWithTabViews:(NSArray *)tabViews;

- (void) setTabBarBackgroundColor:(UIColor *)tabBarBackgroundColor;
- (UIColor *) tabBarBackgroundColor;

- (void) setMinimumTabBarSpacing:(CGFloat)tabBarSpacing;
- (CGFloat) minimumTabBarSpacing;

- (void) setTabBarShadowRadius:(CGFloat)tabBarShadowRadius;
- (CGFloat) tabBarShadowRadius;

- (void) setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated completion:(void(^)(BOOL completed))completion;

- (void) setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated completion:(void(^)(BOOL completed))completion;

@end
