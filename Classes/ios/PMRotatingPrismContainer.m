//
//  PMRotatingPrismContainer.m
//  PMPrismContainerController
//
//  Created by Peter Meyers on 2/24/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMRotatingPrismContainer.h"
#import "PMCenteredCircularCollectionView.h"
#import "PMUtils.h"

static CGFloat const RequiredXVelocity = 100.0f;
static CGFloat const RequiredDeltaDistance = 20.0f;
static CGFloat const CoverFullAlpha = 0.5f;
static CGFloat const BannerHeight = 30.0f;
static NSTimeInterval const MaximumDuration = 0.4;

static inline CGFloat PMMagnitudeOfVector(CGPoint vector) {
    return sqrt( vector.x*vector.x + vector.y*vector.y );
}

NSString * const PMRotatingPrismContainerRotationWillBegin = @"PMRotatingPrismContainerRotationWillBegin";
NSString * const PMRotatingPrismContainerRotationDidComplete = @"PMRotatingPrismContainerRotationDidComplete";
NSString * const PMRotatingPrismContainerRotationDidCancel = @"PMRotatingPrismContainerRotationDidCancel";

typedef NS_ENUM(NSInteger, PanDirection)
{
	PanDirectionNone = 0,
	PanDirectionPositive,
	PanDirectionNegative
};

@interface PMRotatingPrismContainer () <UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) NSArray *viewControllers;
@property (nonatomic, strong, readwrite) PMCenteredCircularCollectionView *titleBanner;
@property (nonatomic, strong) UIView *appearingCover;
@property (nonatomic, strong) UIView *topCover;
@property (nonatomic) NSUInteger topIndex;
@property (nonatomic) NSUInteger appearingIndex;
@property (nonatomic) PanDirection panDirection;

@end

@implementation PMRotatingPrismContainer


- (instancetype) initWithViewControllers:(NSArray *)viewControllers
{
	self = [super init];
	if (self) {
		_viewControllers = viewControllers;
	}
	return self;
}

+ (instancetype) rotatingPrismContainerWithViewControllers:(NSArray *)viewControllers
{
	return [[[self class] alloc] initWithViewControllers:viewControllers];
}

- (BOOL) prefersStatusBarHidden
{
	return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSAssert(self.viewControllers.count, @"At least one panel must be set before loading view");
	self.topIndex = self.viewControllers.count - 1;
    
    [self insertViews];
    [self resetTitleBanner];

	if (self.viewControllers.count > 1) {
		
		self.appearingCover = [[UIView alloc] initWithFrame:self.panelFrame];
		self.topCover = [[UIView alloc] initWithFrame:self.panelFrame];
		self.appearingCover.backgroundColor = self.topCover.backgroundColor = [UIColor blackColor];
		self.appearingCover.alpha = self.topCover.alpha = 0.0f;
		[self.view addSubview:self.appearingCover];
		[self.view addSubview:self.topCover];
		
        UIScreenEdgePanGestureRecognizer *leftEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        leftEdgePan.edges = UIRectEdgeLeft;
        UIScreenEdgePanGestureRecognizer *rightEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        rightEdgePan.edges = UIRectEdgeRight;
        
        [self.view addGestureRecognizer:leftEdgePan];
		[self.view addGestureRecognizer:rightEdgePan];
	}
}

- (void) insertViews
{
    for (UIViewController *controller in self.viewControllers) {
        
		controller.view.hidden = (controller != self.top);
		controller.view.frame = self.panelFrame;
		[self.view addSubview:controller.view];
	}
}

- (void) resetTitleBanner
{
    [self.titleBanner removeFromSuperview];
    self.titleBanner = nil;
    
    if (self.titleViews.count) {
        CGRect frame = {0, 0, self.view.bounds.size.width, BannerHeight };
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.titleBanner = [[PMCenteredCircularCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        self.titleBanner.views = self.titleViews;
        self.titleBanner.secondDelegate = self;
        [self.view addSubview:self.titleBanner];
    }
}

- (void) setTitleViews:(NSArray *)titleViews
{
    if (_titleViews != titleViews) {
        _titleViews = titleViews;
        [self insertViews];
        [self resetTitleBanner];
    }
}

- (void) rotateToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completionBlock
{
    NSUInteger indexOfController = [self.viewControllers indexOfObject:viewController];
    [self rotateToViewControllerAtIndex:indexOfController animated:animated completion:completionBlock];
}

- (void) rotateToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated completion:(void(^)())completionBlock
{
    if (index != self.topIndex &&
        index != NSNotFound) {
        
        if (self.panDirection == PanDirectionNone) {
            NSInteger delta = [self.viewControllers distanceFromIndex:self.topIndex toIndex:index circular:YES];
            self.panDirection = (delta >= 0)? PanDirectionNegative : PanDirectionPositive;
        }
        
        self.appearingIndex = index;
        [self rotateWillBegin];
        
        NSTimeInterval duration = animated? MaximumDuration : 0.0;
        
        [self animateToPercent:1.0f duration:duration completion:^(BOOL finished) {
            
            self.topIndex = self.appearingIndex;
            [self rotateDidEndCancelled:NO];
            
            if (completionBlock) {
                completionBlock();
            }
        }];
    }
    else if (completionBlock) {
        completionBlock();
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
	
	CGPoint velocity = [gestureRecognizer velocityInView:self.view];
	CGPoint delta = [gestureRecognizer translationInView:self.view];
	
	switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
		{
            self.panDirection = (velocity.x >= 0.0f)? PanDirectionPositive : PanDirectionNegative;
            [self updateAppearingIndex];
			[self rotateWillBegin];
		}
        case UIGestureRecognizerStateChanged:
        {
			CGFloat percent =  fabsf(delta.x) / self.panelFrame.size.width;
			[self panToPercent:percent];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
			NSTimeInterval duration = [self durationForVelocity:velocity];

			if ([self shouldCompleteForVelocity:velocity delta:delta]) {
				[self animateToPercent:1.0f duration:duration completion:^(BOOL finished) {
					self.topIndex = self.appearingIndex;
					[self rotateDidEndCancelled:NO];
				}];
			}
			else {
				[self animateToPercent:0.0f duration:duration completion:^(BOOL finished) {
					[self rotateDidEndCancelled:YES];
				}];
			}
            break;
        }
        default:  break;
    }
}

- (BOOL) shouldCompleteForVelocity:(CGPoint)velocity delta:(CGPoint)delta
{
	switch (self.panDirection) {
		case PanDirectionPositive:	return (velocity.x >= RequiredXVelocity && delta.x >= RequiredDeltaDistance);
		case PanDirectionNegative:	return (velocity.x <= RequiredXVelocity && delta.x <= RequiredDeltaDistance);
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -shouldCompleteForVelocity", nil) userInfo:nil]);
	}
}

- (void) rotateWillBegin
{
	self.appearingCover.hidden = NO;
	self.topCover.hidden = NO;
	self.appearing.view.hidden = NO;
	self.topCover.layer.shouldRasterize = YES;
	self.appearingCover.layer.shouldRasterize = YES;
	self.appearingCover.alpha = CoverFullAlpha;
	self.topCover.alpha = 0.0;
    self.titleBanner.userInteractionEnabled = NO;
    
    [self panToPercent:0.0f];
    
	[self.view insertSubview:self.appearing.view aboveSubview:self.top.view];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PMRotatingPrismContainerRotationWillBegin object:self];
}

- (void) panToPercent:(CGFloat)percent
{
	CGRect appearingFrame = [self appearingFrameWithPercent:percent];
	self.appearing.view.frame = appearingFrame;
	self.appearingCover.frame = appearingFrame;
	self.appearingCover.alpha = CoverFullAlpha * (1.0f - percent);
	
	CGRect topFrame = [self topFrameWithPercent:percent];
	self.top.view.frame = topFrame;
	self.topCover.frame = topFrame;
	self.topCover.alpha = percent * CoverFullAlpha;
}

- (void) animateToPercent:(CGFloat)percent duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion
{
	[UIView animateWithDuration:duration
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{ [self panToPercent:percent]; }
					 completion:completion];
}

- (void) rotateDidEndCancelled:(BOOL)cancelled
{
	for (UIViewController *controller in self.viewControllers) {
		controller.view.hidden = (controller != self.top);
		controller.view.frame = self.panelFrame;
	}
    
    [self.titleBanner centerView:self.titleBanner.views[self.topIndex] animated:YES];

	self.topCover.hidden = YES;
	self.appearingCover.hidden = YES;
	self.topCover.layer.shouldRasterize = NO;
	self.appearingCover.layer.shouldRasterize = NO;
    self.titleBanner.userInteractionEnabled = YES;

	if (cancelled) {
		[self.view insertSubview:self.top.view aboveSubview:self.appearing.view];
	}
    
	self.panDirection = PanDirectionNone;
	
	NSString *notificationName = cancelled? PMRotatingPrismContainerRotationDidCancel : PMRotatingPrismContainerRotationDidComplete;
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

- (void) updateAppearingIndex
{
    switch (self.panDirection) {
		case PanDirectionPositive:	self.appearingIndex = [self previousIndex]; break;
		case PanDirectionNegative:	self.appearingIndex = [self nextIndex]; break;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -updateAppearingIndex", nil) userInfo:nil]);
	}
}

- (CGRect) appearingFrameWithPercent:(CGFloat)percent
{
	CGRect frame = self.panelFrame;
	switch (self.panDirection) {
		case PanDirectionPositive:	frame.origin.x = floorf(frame.size.width * (percent - 1.0f)); break;
		case PanDirectionNegative:	frame.origin.x = floorf(frame.size.width * (1.0f - percent)); break;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -appearingFrameWithPercent:", nil) userInfo:nil]);
	}
	return frame;
}

- (CGRect) topFrameWithPercent:(CGFloat)percent
{
	CGRect frame = self.panelFrame;
	switch (self.panDirection) {
		case PanDirectionPositive:	frame.origin.x = floorf(frame.size.width * percent); break;
		case PanDirectionNegative:	frame.origin.x = floorf(-frame.size.width * percent); break;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -topFrameWithPercent:", nil) userInfo:nil]);
	}
	return frame;
}

- (UIViewController *) top
{
	return [self.viewControllers objectAtIndex:self.topIndex];
}

- (UIViewController *) appearing
{
    return [self.viewControllers objectAtIndex:self.appearingIndex];
}

- (NSUInteger) nextIndex
{
	if (self.topIndex == self.viewControllers.count-1) {
		return 0;
	}
	return self.topIndex + 1;
}

- (NSUInteger) previousIndex
{
	if (self.topIndex == 0) {
		return self.viewControllers.count - 1;
	}
	return self.topIndex - 1;
}

- (CGRect)panelFrame
{
	CGRect frame = self.view.bounds;
    if (self.titleViews.count) {
        frame.origin.y += BannerHeight;
        frame.size.height -= BannerHeight;
    }
	return frame;
}

- (NSTimeInterval) durationForVelocity:(CGPoint)velocity
{
	CGFloat distance = [self distanceRemaining];
	CGFloat rate = PMMagnitudeOfVector(velocity);
	NSTimeInterval durtaion = MIN(distance / rate, MaximumDuration);
	return durtaion;
}

- (CGFloat) distanceRemaining
{
	switch (self.panDirection) {
		case PanDirectionPositive:	return self.panelFrame.size.width - self.top.view.frame.origin.x;
		case PanDirectionNegative:	return self.top.view.frame.origin.x;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -distanceRemaining:", nil) userInfo:nil]);
	}
}


#pragma mark - UIScrollViewDelegate Methods


- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.x) {
        self.panDirection = ( velocity.x > 0 )? PanDirectionNegative : PanDirectionPositive;
    }
}


#pragma mark - UICollectionViewDelegate Methods


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.item % self.titleViews.count;
    [self rotateToViewControllerAtIndex:index animated:YES completion:nil];
}

@end
