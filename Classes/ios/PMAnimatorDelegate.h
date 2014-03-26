//
//  PMAnimatorDelegate.h
//  Pods
//
//  Created by Peter Meyers on 3/24/14.
//
//

#import <UIKit/UIKit.h>

@protocol PMAnimatorDelegate <NSObject>
@optional
- (BOOL) animateWithDuration:(id<UIViewControllerAnimatedTransitioning>)animator;
- (void) animatior:(id<UIViewControllerAnimatedTransitioning>)animator ended:(BOOL)completed;
@end

