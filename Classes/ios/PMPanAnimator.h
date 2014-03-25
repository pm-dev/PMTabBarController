//
//  PMPanAnimator.h
//  Pods
//
//  Created by Peter Meyers on 3/24/14.
//
//

#import <Foundation/Foundation.h>
#import "PMAnimatorDelegate.h"

typedef NS_ENUM(NSInteger, PMPanDirection)
{
	PMPanDirectionNone = 0,
	PMPanDirectionPositive,
	PMPanDirectionNegative
};

@interface PMPanAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) PMPanDirection panDirection;
@property (nonatomic) CGRect containerBounds;
@property (nonatomic, weak) id<PMAnimatorDelegate> delegate;

@end
