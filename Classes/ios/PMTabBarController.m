//
//  PMTabBarController.m
//  PMPrismContainerController
//
//  Created by Peter Meyers on 2/24/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMTabBarController.h"
#import "PMCenteredCircularCollectionView.h"
#import "PMPanAnimator.h"
#import "PMUtils.h"

static CGFloat const RequiredXVelocity = 100.0f;
static CGFloat const RequiredDeltaDistance = 20.0f;
static CGFloat const BannerHeight = 45.0f;

static inline NSTimeInterval PMDuration(CGFloat rate, CGFloat distance) {
    return distance / rate;
}

@interface PMTabBarController () <UICollectionViewDelegateFlowLayout, UITabBarControllerDelegate, PMAnimatorDelegate>

@property (nonatomic, strong, readwrite) PMCenteredCircularCollectionView *titleBanner;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePanTransition;
@property (nonatomic, strong) PMPanAnimator *panAnimator;
@property (nonatomic, copy) void(^panAnimatiorEndedBlock)(BOOL completed);
@property (nonatomic) BOOL isTransitionInteractive;
@property (nonatomic) BOOL disableAnimations;

@end


@implementation PMTabBarController


- (instancetype) init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBar.hidden = YES;
    
    CGRect bannerFrame;
    CGRect containerFrame;
    CGRectDivide(self.view.bounds, &bannerFrame, &containerFrame, BannerHeight, CGRectMaxYEdge);
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.titleBanner = [[PMCenteredCircularCollectionView alloc] initWithFrame:bannerFrame collectionViewLayout:layout];
    self.titleBanner.views = self.titleViews;
    self.titleBanner.backgroundColor = self.titleBannerBackgroundColor;
    self.titleBanner.secondaryDelegate = self;
    self.titleBanner.shadowRadius = 10.0f;
    [self.titleBanner centerViewAtIndex:self.selectedIndex animated:NO];
    [self.view addSubview:self.titleBanner];
    
    UIScreenEdgePanGestureRecognizer *leftEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    leftEdgePan.edges = UIRectEdgeLeft;
    UIScreenEdgePanGestureRecognizer *rightEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    rightEdgePan.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:leftEdgePan];
    [self.view addGestureRecognizer:rightEdgePan];
    
    self.interactivePanTransition = [UIPercentDrivenInteractiveTransition new];
    self.interactivePanTransition.completionCurve = UIViewAnimationCurveEaseOut;
    self.panAnimator = [PMPanAnimator new];
    self.panAnimator.delegate = self;
    self.panAnimator.containerBounds = containerFrame;
}

- (void) setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated completion:(void (^)(BOOL completed))completion
{
    NSUInteger index = [self.viewControllers indexOfObject:selectedViewController];
    [self setSelectedIndex:index animated:animated completion:completion];
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated completion:(void(^)(BOOL completed))completion
{
    if (selectedIndex < self.viewControllers.count &&
        selectedIndex != self.selectedIndex) {
        
        [self.titleBanner centerView:self.titleViews[selectedIndex] animated:animated];
        self.disableAnimations = !animated;
        self.panAnimatiorEndedBlock = completion;
        self.selectedIndex = selectedIndex;
    }
}

- (void) setTitleViews:(NSArray *)titleViews
{
    if (_titleViews != titleViews) {
        _titleViews = titleViews;
        self.titleBanner.views = titleViews;
        [self.titleBanner centerViewAtIndex:self.selectedIndex animated:NO];
    }
}

- (void) setTitleBannerBackgroundColor:(UIColor *)titleBannerBackgroundColor
{
    if (_titleBannerBackgroundColor != titleBannerBackgroundColor) {
        _titleBannerBackgroundColor = titleBannerBackgroundColor;
        self.titleBanner.backgroundColor = titleBannerBackgroundColor;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
	
	CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view.superview];
	CGPoint delta = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    
	switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            self.isTransitionInteractive = YES;
            self.selectedIndex = (velocity.x < 0.0f)? [self nextIndex] : [self previousIndex];
		}

        case UIGestureRecognizerStateChanged: {
            CGFloat percent =  fabsf(delta.x) / gestureRecognizer.view.superview.frame.size.width;
//            Apple bug that apparently prevents completion block from firing if update goes to 100%. This may now be fixed
//            if (percent >= 1.0)
//                percent = 0.9999;
            [self.interactivePanTransition updateInteractiveTransition:percent];
            break;
        }
        
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {

            CGFloat remainingDistance = gestureRecognizer.view.superview.frame.size.width - fabsf(delta.x);
            CGFloat speedMultiplier = self.interactivePanTransition.duration / PMDuration(fabsf(velocity.x), remainingDistance);
            self.interactivePanTransition.completionSpeed = fmaxf(1.0f, speedMultiplier);

            if ([self shouldCompleteForVelocity:velocity delta:delta]) {
                [self.interactivePanTransition finishInteractiveTransition];
            }
            else {
                [self.interactivePanTransition cancelInteractiveTransition];
            }
            self.isTransitionInteractive = NO;
            break;
        }
        default:  break;
    }
}

- (BOOL) shouldCompleteForVelocity:(CGPoint)velocity delta:(CGPoint)delta
{
	switch (self.panAnimator.panDirection) {
		case PMPanDirectionPositive:	return (velocity.x >= RequiredXVelocity && delta.x >= RequiredDeltaDistance);
		case PMPanDirectionNegative:	return (velocity.x <= RequiredXVelocity && delta.x <= RequiredDeltaDistance);
		case PMPanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -shouldCompleteForVelocity", nil) userInfo:nil]);
	}
}

- (NSUInteger) nextIndex
{
	if (self.selectedIndex == self.viewControllers.count-1) {
		return 0;
	}
	return self.selectedIndex + 1;
}

- (NSUInteger) previousIndex
{
	if (self.selectedIndex == 0) {
		return self.viewControllers.count - 1;
	}
	return self.selectedIndex - 1;
}


#pragma mark - PMAnimatorDelegate Methods


- (BOOL) disableAnimator:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if (animator == self.panAnimator) {
        return self.disableAnimations;
    }
    return NO;
}

- (void) animatior:(id<UIViewControllerAnimatedTransitioning>)animator ended:(BOOL)completed
{
    if (animator == self.panAnimator) {
        
        [self.titleBanner centerViewAtIndex:self.selectedIndex animated:YES];
        
        if (self.panAnimatiorEndedBlock) {
            self.panAnimatiorEndedBlock(completed);
        }
        self.disableAnimations = NO;
    }
}

#pragma mark - UIScrollViewDelegate Methods


- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.x) {
        self.panAnimator.panDirection = ( velocity.x > 0.0f )? PMPanDirectionNegative : PMPanDirectionPositive;
    }
}


#pragma mark - UICollectionViewDelegate Methods


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.item % self.titleViews.count;
    self.selectedIndex = index;
}


#pragma mark - UITabBarControllerDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC
{
    if (self.panAnimator.panDirection == PMPanDirectionNone) {
        
        NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
        NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
        
        NSInteger delta = [tabBarController.viewControllers distanceFromIndex:fromVCIndex toIndex:toVCIndex circular:YES];
        
        self.panAnimator.panDirection = (delta > 0.0f)? PMPanDirectionNegative : PMPanDirectionPositive;
    }
    
    return self.panAnimator;
}


- (id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
                      interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController
{
    return self.isTransitionInteractive? self.interactivePanTransition : nil;
}



@end
