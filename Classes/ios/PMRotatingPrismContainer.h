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

- (void) rotateToPanel:(UIView *)panel animated:(BOOL)animated completion:(void(^)())completionBlock;

- (void) rotateToPanelWithTitle:(NSString *)panelTitle animated:(BOOL)animated completion:(void(^)())completionBlock;

- (NSDictionary *) panels;

- (instancetype) initWithPanels:(NSDictionary *)panels;

+ (instancetype) rotatingPrismContainerWithPanels:(NSDictionary *)panels;

@end
