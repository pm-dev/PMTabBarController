//
//  PMPanAnimator.m
//  Pods
//
//  Created by Peter Meyers on 3/24/14.
//
//

#import "PMPanAnimator.h"

static NSTimeInterval const AnimationDuration = 0.5;
static CGFloat const CoverFullAlpha = 0.1f;


@implementation PMPanAnimator

- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    UIView *disappearing = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    UIView *appearing = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    
    CGRect appearingStartFrame = self.containerBounds;
    CGRect disappearingEndFrame = self.containerBounds;
    
    CGFloat containerWidth = containerView.bounds.size.width;
    
    switch (self.panDirection) {
            
        case PMPanDirectionNegative:
            appearingStartFrame.origin.x = containerWidth;
            disappearingEndFrame.origin.x = -containerWidth;
            break;
            
        case PMPanDirectionPositive:
            appearingStartFrame.origin.x = -containerWidth;
            disappearingEndFrame.origin.x = containerWidth;
            break;
            
        case PMPanDirectionNone:
            @throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when animating the presentation transition", nil) userInfo:nil]);
    }
    
    appearing.frame = appearingStartFrame;
    
    UIView *appearingCover = [[UIView alloc] initWithFrame:appearing.frame];
    appearingCover.alpha = CoverFullAlpha;
    appearingCover.backgroundColor = [UIColor blackColor];
    
    UIView *disappearingCover = [[UIView alloc] initWithFrame:disappearing.frame];
    disappearingCover.alpha = 0.0f;
    disappearingCover.backgroundColor = [UIColor blackColor];
    
    [containerView insertSubview:appearing aboveSubview:disappearing];
    [containerView insertSubview:appearingCover aboveSubview:appearing];
    [containerView insertSubview:disappearingCover aboveSubview:disappearing];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         appearing.frame = self.containerBounds;
                         appearingCover.frame = self.containerBounds;
                         appearingCover.alpha = 0.0f;
                         
                         disappearing.frame = disappearingEndFrame;
                         disappearingCover.frame = disappearingEndFrame;
                         disappearingCover.alpha = CoverFullAlpha;
                         
                     }
                     completion:^(BOOL finished) {

                         [disappearingCover removeFromSuperview];
                         [appearingCover removeFromSuperview];
                         
                         [self performSelector:@selector(didComplete:) withObject:transitionContext afterDelay:0.1];
                     }];
}

- (void) didComplete:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
}

- (NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    BOOL animateWithDuration = YES;
    
    if ([self.delegate respondsToSelector:@selector(animateWithDuration:)]) {
        animateWithDuration = [self.delegate animateWithDuration:self];
    }
    
    return animateWithDuration? AnimationDuration : 0.0;
}

- (void) animationEnded:(BOOL)transitionCompleted
{
    if ([self.delegate respondsToSelector:@selector(animatior:ended:)]) {
        [self.delegate animatior:self ended:transitionCompleted];
    }
    
    self.panDirection = PMPanDirectionNone;
}




@end
