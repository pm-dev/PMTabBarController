//
//  PMRotatingPrismContainer.m
//  PMPrismContainerController
//
//  Created by Peter Meyers on 2/24/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMRotatingPrismContainer.h"

static CGFloat const RequiredXVelocity = 100.0f;
static CGFloat const RequiredDeltaDistance = 20.0f;
static CGFloat const CoverFullAlpha = 0.5f;
static NSTimeInterval const MaximumDuration = 0.5;

NSString * const PMRotatingPrismContainerRotationWillBegin = @"PMRotatingPrismContainerRotationWillBegin";
NSString * const PMRotatingPrismContainerRotationDidComplete = @"PMRotatingPrismContainerRotationDidComplete";
NSString * const PMRotatingPrismContainerRotationDidCancel = @"PMRotatingPrismContainerRotationDidCancel";

typedef NS_ENUM(NSInteger, PanDirection)
{
	PanDirectionNone = 0,
	PanDirectionPositive,
	PanDirectionNegative
};

@interface PMRotatingPrismContainer ()

@property (nonatomic, strong, readwrite) NSArray *panels;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UIView *appearingCover;
@property (nonatomic, strong) UIView *topCover;
@property (nonatomic) NSInteger topIndex;
@property (nonatomic) PanDirection panDirection;

@end

@implementation PMRotatingPrismContainer


- (instancetype) initWithPanels:(NSArray *)panels
{
	self = [super init];
	if (self) {
		_panels = panels;
	}
	return self;
}

+ (instancetype) rotatingPrismContainerWithPanels:(NSArray *)panels
{
	return [[[self class] alloc] initWithPanels:panels];
}

- (BOOL) prefersStatusBarHidden
{
	return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];

	NSAssert(self.panels.count, @"At least one panel must be set before loading view");
	self.topIndex = self.panels.count - 1;
	
	for (UIView *panel in self.panels) {
		panel.hidden = (panel != self.top);
		panel.frame = self.view.bounds;
		[self.view addSubview:panel];
	}

//	self.pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//	self.pan.edges = UIRectEdgeLeft | UIRectEdgeRight;
	if (self.panels.count > 1) {
		
		self.appearingCover = [[UIView alloc] initWithFrame:self.view.bounds];
		self.topCover = [[UIView alloc] initWithFrame:self.view.bounds];
		self.appearingCover.backgroundColor = self.topCover.backgroundColor = [UIColor blackColor];
		self.appearingCover.alpha = self.topCover.alpha = 0.0f;
		[self.view addSubview:self.appearingCover];
		[self.view addSubview:self.topCover];
		
		self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
		[self.view addGestureRecognizer:self.pan];
	}
}

- (UIView *) top
{
	return self.panels[self.topIndex];
}

- (UIView *) appearing
{
	switch (self.panDirection) {
		case PanDirectionPositive:	return self.panels[[self previousIndex]];
		case PanDirectionNegative:	return self.panels[[self nextIndex]];
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -appearing", nil) userInfo:nil]);
	}
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
	
	CGPoint velocity = [gestureRecognizer velocityInView:self.view];
	CGPoint delta = [gestureRecognizer translationInView:self.view];
	
	switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
		{
			[self rotateBeganWithVelocity:velocity];
		}
        case UIGestureRecognizerStateChanged:
        {
			// This shouldn't be needed if switching to an Edge Pan gesture
			if ((delta.x < 0 && self.panDirection == PanDirectionPositive) ||
				(delta.x > 0 && self.panDirection == PanDirectionNegative)) {
				[self rotateEndedCancelled:YES];
				[self rotateBeganWithVelocity:velocity];
			}
			
			CGFloat percent =  fabsf(delta.x) / self.view.bounds.size.width;
			[self panToPercent:percent];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
			NSTimeInterval duration = [self durationForVelocity:velocity];

			if ([self shouldCompleteForVelocity:velocity delta:delta]) {
				[self animateToPercent:1.0f duration:duration completion:^(BOOL finished) {
					[self updateTopIndex];
					[self rotateEndedCancelled:NO];
				}];
			}
			else {
				[self animateToPercent:0.0f duration:duration completion:^(BOOL finished) {
					[self rotateEndedCancelled:YES];
					
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

- (void) updateTopIndex
{
	switch (self.panDirection) {
		case PanDirectionPositive:	self.topIndex = [self previousIndex]; break;
		case PanDirectionNegative:	self.topIndex = [self nextIndex]; break;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -updateTopIndex", nil) userInfo:nil]);
	}
	
	[self.view bringSubviewToFront:self.top];
}

- (void) rotateBeganWithVelocity:(CGPoint)velocity
{
	self.panDirection = (velocity.x >= 0)? PanDirectionPositive : PanDirectionNegative;
	
	[self setAnchorPoints];
	self.appearingCover.hidden = NO;
	self.topCover.hidden = NO;
	self.appearing.hidden = NO;
	self.appearingCover.alpha = CoverFullAlpha;
	self.topCover.alpha = 0.0;
	
	[self.view insertSubview:self.appearing aboveSubview:self.top];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PMRotatingPrismContainerRotationWillBegin object:self];
}

- (void) panToPercent:(CGFloat)percent
{
	self.appearing.layer.transform = CATransform3DRotate(CATransform3DIdentity ,
														 [self appearingRotationWithPercent:percent],
														 0.0f,
														 1.0f,
														 0.0f);
	
	self.top.layer.transform = CATransform3DRotate(CATransform3DIdentity,
												   [self topRotationWithPercent:percent],
												   0.0f,
												   1.0f,
												   0.0f);
	
	CGRect appearingFrame = [self appearingFrameWithPercent:percent];
	self.appearing.frame = appearingFrame;
	self.appearingCover.frame = appearingFrame;
	self.appearingCover.alpha = CoverFullAlpha * (1.0f - percent);
	
	CGRect topFrame = [self topFrameWithPercent:percent];
	self.top.frame = topFrame;
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

- (void) rotateEndedCancelled:(BOOL)cancelled
{
	for (UIView *panel in self.panels) {
		panel.hidden = (panel != self.top);
		panel.frame = self.view.bounds;
		panel.layer.transform = CATransform3DIdentity;
	}
	
	self.panDirection = PanDirectionNone;
	self.topCover.hidden = YES;
	self.appearingCover.hidden = YES;
	
	NSString *notificationName = cancelled? PMRotatingPrismContainerRotationDidCancel : PMRotatingPrismContainerRotationDidComplete;
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

- (CGFloat) appearingRotationWithPercent:(CGFloat)percent
{
	switch (self.panDirection) {
		case PanDirectionPositive:	return M_PI_2 * (percent - 1.0f);
		case PanDirectionNegative:	return M_PI_2 * (1.0f - percent);
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -appearingRotationWithPercent:", nil) userInfo:nil]);
	}
}

- (CGFloat) topRotationWithPercent:(CGFloat)percent
{
	switch (self.panDirection) {
		case PanDirectionPositive:	return percent * M_PI_2;
		case PanDirectionNegative:	return -percent * M_PI_2;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -topRotationWithPercent:", nil) userInfo:nil]);
	}
}

- (CGRect) appearingFrameWithPercent:(CGFloat)percent
{
	CGRect frame = self.view.bounds;
	switch (self.panDirection) {
		case PanDirectionPositive:	frame.origin.x = floorf(frame.size.width * (percent - 1.0f)); break;
		case PanDirectionNegative:	frame.origin.x = floorf(frame.size.width * (1.0f - percent)); break;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -appearingFrameWithPercent:", nil) userInfo:nil]);
	}
	return frame;
}

- (CGRect) topFrameWithPercent:(CGFloat)percent
{
	CGRect frame = self.view.bounds;
	switch (self.panDirection) {
		case PanDirectionPositive:	frame.origin.x = floorf(frame.size.width * percent); break;
		case PanDirectionNegative:	frame.origin.x = floorf(-frame.size.width * percent); break;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -topFrameWithPercent:", nil) userInfo:nil]);
	}
	return frame;
}

- (void) setAnchorPoints
{
	switch (self.panDirection)
	{
		case PanDirectionPositive:
			self.top.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
			self.appearing.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
			break;
			
		case PanDirectionNegative:
			self.top.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
			self.appearing.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
			break;
			
		case PanDirectionNone:
			@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -setAnchorPoints:", nil) userInfo:nil]);
	}
}

- (NSUInteger) nextIndex
{
	if (self.topIndex == self.panels.count-1) {
		return 0;
	}
	return self.topIndex + 1;
}

- (NSUInteger) previousIndex
{
	if (self.topIndex == 0) {
		return self.panels.count - 1;
	}
	return self.topIndex - 1;
}

- (NSTimeInterval) durationForVelocity:(CGPoint)velocity
{
	CGFloat distance = [self distanceRemaining];
	CGFloat rate = [PMRotatingPrismContainer magnitudeOfVector:velocity];
	NSTimeInterval durtaion = MIN(distance / rate, MaximumDuration);
	return durtaion;
}

- (CGFloat) distanceRemaining
{
	switch (self.panDirection) {
		case PanDirectionPositive:	return self.view.bounds.size.width - self.top.frame.origin.x;
		case PanDirectionNegative:	return self.top.frame.origin.x;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -distanceRemaining:", nil) userInfo:nil]);
	}
}

+ (CGFloat) magnitudeOfVector:(CGPoint)vector
{
	return sqrt( vector.x*vector.x + vector.y*vector.y );
}

@end
