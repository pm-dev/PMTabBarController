//
//  PMTabBarController.h
//  PMPrismContainerController
//
//  Created by Peter Meyers on 2/24/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMTabBarController : UITabBarController

@property (nonatomic, strong) NSArray *titleViews;
@property (nonatomic, strong) UIColor *titleBannerBackgroundColor;

- (void) setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated completion:(void(^)(BOOL completed))completion;

- (void) setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated completion:(void(^)(BOOL completed))completion;

@end
