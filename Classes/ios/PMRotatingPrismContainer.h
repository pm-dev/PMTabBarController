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

- (NSDictionary *) panels;

- (instancetype) initWithPanels:(NSDictionary *)panels;

+ (instancetype) rotatingPrismContainerWithPanels:(NSDictionary *)panels;

@end
