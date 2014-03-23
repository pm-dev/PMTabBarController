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
static CGFloat const TitleFontSize = 18.0f;
static NSString * const TitleFontName = @"HelveticaNeue-Light";

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

@property (nonatomic, strong, readwrite) PMOrderedDictionary *orderedPanels;
@property (nonatomic, strong) UIView *appearingCover;
@property (nonatomic, strong) UIView *topCover;
@property (nonatomic, strong) PMCenteredCircularCollectionView *titleBanner;
@property (nonatomic) NSUInteger topIndex;
@property (nonatomic) NSUInteger appearingIndex;
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
    
    self.titleBanner = [[PMCenteredCircularCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.titleBanner.views = titleLabels;
    self.titleBanner.secondDelegate = self;
    self.titleBanner.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.titleBanner];
}

- (UILabel *) newTitleLabel:(NSString *)title
{
    UILabel *label = [UILabel new];
    label.text = title;
    label.font = [UIFont fontWithName:TitleFontName size:TitleFontSize];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    return label;
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.x) {
        self.panDirection = ( velocity.x > 0 )? PanDirectionNegative : PanDirectionPositive;
    }
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSAssert(cell.contentView.subviews.count == 1, @"The only subview of a PMCircularCollectionView cell is the view we assigned to it.");
    
    UILabel *titleLabel = cell.contentView.subviews.firstObject;
    
    if (titleLabel) {
        NSString *title = titleLabel.text;
        [self rotateToPanelWithTitle:title animated:YES completion:nil];
    }
}

- (UIView *) top
{
	return [self.orderedPanels objectAtIndex:self.topIndex];
}

- (UIView *) appearing
{
    return [self.orderedPanels objectAtIndex:self.appearingIndex];
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
			[self rotateBegan];
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
                    [self.titleBanner centerView:self.titleBanner.views[self.topIndex] animated:YES];
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

- (void) rotateToPanel:(UIView *)panel animated:(BOOL)animated completion:(void(^)())completionBlock
{
    NSUInteger indexOfPanel = [self.orderedPanels indexOfObject:panel];
    [self rotateToPanelAtIndex:indexOfPanel animated:animated completion:completionBlock];
}

- (void) rotateToPanelWithTitle:(NSString *)panelTitle animated:(BOOL)animated completion:(void(^)())completionBlock
{
    NSUInteger indexOfPanel = [self.orderedPanels indexOfKey:panelTitle];
    [self rotateToPanelAtIndex:indexOfPanel animated:animated completion:completionBlock];
}

- (void) rotateToPanelAtIndex:(NSUInteger)index animated:(BOOL)animated completion:(void(^)())completionBlock
{
    if (index != self.topIndex &&
        index != NSNotFound) {
  
        if (self.panDirection == PanDirectionNone) {
            NSInteger delta = [self.orderedPanels distanceFromIndex:self.topIndex toIndex:index circular:YES];
            self.panDirection = (delta >= 0)? PanDirectionNegative : PanDirectionPositive;
        }
        
        self.appearingIndex = index;
        [self rotateBegan];
        
        NSTimeInterval duration = animated? MaximumDuration : 0.0;
        
        [self animateToPercent:1.0f duration:duration completion:^(BOOL finished) {
            
            self.topIndex = self.appearingIndex;
            [self.titleBanner centerView:self.titleBanner.views[self.topIndex] animated:animated];
            [self rotateEndedCancelled:NO];
            
            if (completionBlock) {
                completionBlock();
            }
        }];
    }
    else if (completionBlock) {
        completionBlock();
    }
}

- (void) rotateBegan
{
	[self setAnchorPoints];
	self.appearingCover.hidden = NO;
	self.topCover.hidden = NO;
	self.appearing.hidden = NO;
	self.topCover.layer.shouldRasterize = YES;
	self.appearingCover.layer.shouldRasterize = YES;
	self.appearingCover.alpha = CoverFullAlpha;
	self.topCover.alpha = 0.0;
    self.titleBanner.userInteractionEnabled = NO;
	
    [self panToPercent:0.0f];
    
	[self.view insertSubview:self.appearing aboveSubview:self.top];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PMRotatingPrismContainerRotationWillBegin object:self];
}

- (void) panToPercent:(CGFloat)percent
{
//	self.appearing.layer.transform = CATransform3DRotate(CATransform3DIdentity ,
//														 [self appearingRotationWithPercent:percent],
//														 0.0f,
//														 1.0f,
//														 0.0f);
//	
//	self.top.layer.transform = CATransform3DRotate(CATransform3DIdentity,
//												   [self topRotationWithPercent:percent],
//												   0.0f,
//												   1.0f,
//												   0.0f);
	
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
    self.titleBanner.userInteractionEnabled = YES;

    
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

- (void) updateAppearingIndex
{
    switch (self.panDirection) {
		case PanDirectionPositive:	self.appearingIndex = [self previousIndex]; break;
		case PanDirectionNegative:	self.appearingIndex = [self nextIndex]; break;
		case PanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -updateAppearingIndex", nil) userInfo:nil]);
	}
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
