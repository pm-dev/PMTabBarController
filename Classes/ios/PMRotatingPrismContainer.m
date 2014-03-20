//
//  PMRotatingPrismContainer.m
//  PMPrismContainerController
//
//  Created by Peter Meyers on 2/24/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMRotatingPrismContainer.h"
#import "PMCircularCollectionView.h"
#import "PMUtils.h"

static CGFloat const RequiredXVelocity = 100.0f;
static CGFloat const RequiredDeltaDistance = 20.0f;
static CGFloat const CoverFullAlpha = 0.5f;
static CGFloat const BannerHeight = 30.0f;
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

@property (nonatomic, strong, readwrite) PMOrderedDictionary *orderedPanels;
@property (nonatomic, strong) UIView *appearingCover;
@property (nonatomic, strong) UIView *topCover;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) PMCircularCollectionView *titleBanner;
@property (nonatomic) NSInteger topIndex;
@property (nonatomic) PanDirection panDirection;

@end

@implementation PMRotatingPrismContainer


- (instancetype) initWithPanels:(NSDictionary *)panels
{
	self = [super init];
	if (self) {
		_orderedPanels = [PMOrderedDictionary dictionaryWithDictionary:panels];
	}
	return self;
}

+ (instancetype) rotatingPrismContainerWithPanels:(NSDictionary *)panels
{
	return [[[self class] alloc] initWithPanels:panels];
}

- (NSDictionary *) panels
{
	return [NSDictionary dictionaryWithObjects:self.panels.allValues
									   forKeys:self.panels.allKeys];
}

- (BOOL) prefersStatusBarHidden
{
	return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];

	NSAssert(self.orderedPanels.count, @"At least one panel must be set before loading view");
	self.topIndex = self.orderedPanels.count - 1;
	
    NSMutableArray *titleLabels = [[NSMutableArray alloc] initWithCapacity:self.orderedPanels.count];
    
	for (NSString *title in self.orderedPanels) {
		UIView *panel = self.orderedPanels[title];
		panel.hidden = (panel != self.top);
		panel.frame = self.panelFrame;
        [titleLabels addObject:[self newTitleLabel:title]];
		[self.view addSubview:panel];
	}

	if (self.orderedPanels.count > 1) {
		
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
	
    
    CGRect frame = {0, 0, self.view.bounds.size.width, BannerHeight };

    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 50.0f;
    
    self.titleBanner = [[PMCircularCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.titleBanner.views = titleLabels;
    self.titleBanner.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.titleBanner];
}

- (UILabel *) newTitleLabel:(NSString *)title
{
    UILabel *label = [UILabel new];
    label.text = title;
    label.backgroundColor = [UIColor orangeColor];
//    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
//    CGRect frame = label.frame;
//    frame.size.width += 50.0f;
//    label.frame = frame;
    return label;
}

- (UIView *) top
{
	return [self.orderedPanels objectForKey:[self.orderedPanels keyAtIndex:self.topIndex]];
}

- (UIView *) appearing
{
	switch (self.panDirection) {
		case PanDirectionPositive:	return [self.orderedPanels objectForKey:[self.orderedPanels keyAtIndex:[self previousIndex]]];
		case PanDirectionNegative:	return [self.orderedPanels objectForKey:[self.orderedPanels keyAtIndex:[self nextIndex]]];
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
			if ((delta.x < 0.0f && self.panDirection == PanDirectionPositive) ||
				(delta.x > 0.0f && self.panDirection == PanDirectionNegative)) {
				[self rotateEndedCancelled:YES];
				[self rotateBeganWithVelocity:velocity];
			}
			
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
}

- (void) rotateBeganWithVelocity:(CGPoint)velocity
{
	self.panDirection = (velocity.x >= 0.0f)? PanDirectionPositive : PanDirectionNegative;
	
	[self setAnchorPoints];
	self.appearingCover.hidden = NO;
	self.topCover.hidden = NO;
	self.appearing.hidden = NO;
	self.topCover.layer.shouldRasterize = YES;
	self.appearingCover.layer.shouldRasterize = YES;
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
	for (NSString *title in self.orderedPanels) {
		UIView *panel = self.orderedPanels[title];
		panel.hidden = (panel != self.top);
		panel.frame = self.panelFrame;
		panel.layer.transform = CATransform3DIdentity;
	}
	
	self.topCover.hidden = YES;
	self.appearingCover.hidden = YES;
	self.topCover.layer.shouldRasterize = NO;
	self.appearingCover.layer.shouldRasterize = NO;
	
	self.titleLabel.text = (NSString *)[self.orderedPanels keyAtIndex:self.topIndex];
	
	if (cancelled) {
		[self.view insertSubview:self.top aboveSubview:self.appearing];
	}
	
	self.panDirection = PanDirectionNone;
	
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
	if (self.topIndex == self.orderedPanels.count-1) {
		return 0;
	}
	return self.topIndex + 1;
}

- (NSUInteger) previousIndex
{
	if (self.topIndex == 0) {
		return self.orderedPanels.count - 1;
	}
	return self.topIndex - 1;
}

- (CGRect)panelFrame
{
	CGRect frame = self.view.bounds;
	frame.origin.y += BannerHeight;
	frame.size.height -= BannerHeight;
	return frame;
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
		case PanDirectionPositive:	return self.panelFrame.size.width - self.top.frame.origin.x;
		case PanDirectionNegative:	return self.top.frame.origin.x;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -distanceRemaining:", nil) userInfo:nil]);
	}
}

+ (CGFloat) magnitudeOfVector:(CGPoint)vector
{
	return sqrt( vector.x*vector.x + vector.y*vector.y );
}

@end
