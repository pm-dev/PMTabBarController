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

@property (strong, nonatomic, readonly) NSArray *panels;

- (instancetype) initWithPanels:(NSArray *)panels;

+ (instancetype) rotatingPrismContainerWithPanels:(NSArray *)panels;

@end
