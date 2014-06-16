//
//  PMPanAnimator.h
//  Pods
//
//  Created by Peter Meyers on 3/24/14.
//
//

#import <Foundation/Foundation.h>
#import "PMAnimatorDelegate.h"

typedef NS_ENUM(NSUInteger, PMPanDirection)
{
	PMPanDirectionNone,
	PMPanDirectionPositive,
	PMPanDirectionNegative
};

@interface PMPanAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) PMPanDirection panDirection;
@property (nonatomic, weak) id<PMAnimatorDelegate> delegate;

@end
