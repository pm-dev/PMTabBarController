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

static inline PMPanDirection PMPanDirectionForVelocity(CGPoint velocity) {
    return (velocity.x > 0.0f)? PMPanDirectionPositive : PMPanDirectionNegative;
}

static inline NSString * PMReuseIdentifier(NSInteger index) {
    return [[NSNumber numberWithInteger:index] stringValue];
}

@interface PMTabBarController ()
<UITabBarControllerDelegate, PMAnimatorDelegate, UICollectionViewDataSource, PMCenteredCircularCollectionViewDelegate>

@property (nonatomic, strong, readwrite) PMCenteredCircularCollectionView *titleBanner;
@property (nonatomic, strong) PMCenteredCollectionViewFlowLayout *titleBannerLayout;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePanTransition;
@property (nonatomic, strong) PMPanAnimator *panAnimator;
@property (nonatomic, copy) void(^panAnimatiorEndedBlock)(BOOL completed);
@property (nonatomic) BOOL isTransitionInteractive;
@property (nonatomic) BOOL animateWithDuration;
@property (nonatomic) CGFloat addedTitlePadding;

@end


@implementation PMTabBarController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commontPMTabBarControllerInit];
    }
    return self;
}


- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commontPMTabBarControllerInit];
    }
    return self;
}

- (void) commontPMTabBarControllerInit
{
    self.delegate = self;
    self.animateWithDuration = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBar.hidden = YES;
    
    CGRect bannerFrame;
    CGRect containerFrame;
    CGRectDivide(self.view.bounds, &bannerFrame, &containerFrame, BannerHeight, CGRectMaxYEdge);
    
    self.titleBannerLayout = [PMCenteredCollectionViewFlowLayout new];
    self.titleBannerLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.titleBannerLayout.minimumLineSpacing = 0.0f;
    self.titleBannerLayout.minimumInteritemSpacing = 0.0f;
    
    self.titleBanner = [PMCenteredCircularCollectionView collectionViewWithFrame:bannerFrame collectionViewLayout:self.titleBannerLayout];
    self.titleBanner.delegate = self;
	self.titleBanner.dataSource = self;
    self.titleBanner.backgroundColor = self.titleBannerBackgroundColor;
    self.titleBanner.shadowRadius = self.titleBannerShadowRadius;
    [self.titleBanner centerCellAtIndex:self.selectedIndex animated:NO];
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
        
        [self.titleBanner centerCellAtIndex:selectedIndex animated:animated];
        self.animateWithDuration = animated;
        self.panAnimatiorEndedBlock = completion;
        self.selectedIndex = selectedIndex;
    }
}

- (void) setTitleViews:(NSArray *)titleViews
{
    if (_titleViews != titleViews) {
        _titleViews = titleViews;
        [self registerCells];
        [self setAddedTitlePadding];
        [self.titleBanner reloadData];
        [self.titleBanner centerCellAtIndex:self.selectedIndex animated:NO];
    }
}

- (void) registerCells
{
    for (NSInteger i = 0; i < self.titleViews.count; i++) {
        [self.titleBanner registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:PMReuseIdentifier(i)];
    }
}
- (void) setAddedTitlePadding
{
    CGFloat contentWidth = 0.0f;
    for (UIView *view in self.titleViews) {
        contentWidth += view.frame.size.width;
    }
    
    CGFloat maxSpacingRequired = 0.0f;
    for (UIView *view in self.titleViews) {
        
        CGFloat totalSpacingRequired =  (self.titleBanner.bounds.size.width - (contentWidth - view.frame.size.width));
        CGFloat spacingRequired = ceilf(totalSpacingRequired / (self.titleViews.count-1));
        
        if (spacingRequired > maxSpacingRequired) {
            maxSpacingRequired = spacingRequired;
        }
    }
    
    self.addedTitlePadding = fmaxf(maxSpacingRequired, self.titleBannerSpacing);
}

- (void) setTitleBannerBackgroundColor:(UIColor *)titleBannerBackgroundColor
{
    if (_titleBannerBackgroundColor != titleBannerBackgroundColor) {
        _titleBannerBackgroundColor = titleBannerBackgroundColor;
        self.titleBanner.backgroundColor = titleBannerBackgroundColor;
    }
}

- (void) setTitleBannerShadowRadius:(CGFloat)titleBannerShadowRadius
{
    if (_titleBannerShadowRadius != titleBannerShadowRadius) {
        _titleBannerShadowRadius = titleBannerShadowRadius;
        self.titleBanner.shadowRadius = titleBannerShadowRadius;
    }
}

- (void) setTitleBannerSpacing:(CGFloat)titleBannerSpacing
{
    if (_titleBannerSpacing != titleBannerSpacing) {
        _titleBannerSpacing = titleBannerSpacing;
        CGFloat titlePadding = self.addedTitlePadding;
        [self setAddedTitlePadding];
        if (titlePadding != self.addedTitlePadding) {
            [self.titleBanner reloadData];
        }
    }
}

- (void) setIsTransitionInteractive:(BOOL)isTransitionInteractive
{
    if (_isTransitionInteractive != isTransitionInteractive) {
        _isTransitionInteractive = isTransitionInteractive;
        self.titleBanner.userInteractionEnabled = !isTransitionInteractive;
        if (_isTransitionInteractive) {
            [self.titleBanner killScroll];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
	
	CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view.superview];
	CGPoint delta = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    
	switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            self.isTransitionInteractive = YES;
            self.panAnimator.panDirection = PMPanDirectionForVelocity(velocity);
            self.selectedIndex = (velocity.x < 0.0f)? [self nextIndex] : [self previousIndex];
		}

        case UIGestureRecognizerStateChanged: {
            
            CGFloat percent =  fabsf(delta.x) / gestureRecognizer.view.superview.frame.size.width;
            [self.interactivePanTransition updateInteractiveTransition:percent];
            break;
        }
        
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {

            CGFloat remainingDistance = gestureRecognizer.view.superview.frame.size.width - fabsf(delta.x);
            CGFloat speedMultiplier = self.interactivePanTransition.duration / PMDuration(fabsf(velocity.x), remainingDistance);
            self.interactivePanTransition.completionSpeed = fmaxf(1.0f, speedMultiplier);

            if ([self shouldCompleteForVelocity:velocity delta:delta]) {
                [self.titleBanner centerCellAtIndex:self.selectedIndex animated:YES];
                [self.interactivePanTransition finishInteractiveTransition];
            }
            else {
                [self.interactivePanTransition cancelInteractiveTransition];
            }
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


- (BOOL) animateWithDuration:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if (animator == self.panAnimator) {
        return self.animateWithDuration;
    }
    return YES;
}

- (void) animatior:(id<UIViewControllerAnimatedTransitioning>)animator ended:(BOOL)completed
{
    if (animator == self.panAnimator) {
        
        if (self.panAnimatiorEndedBlock) {
            self.panAnimatiorEndedBlock(completed);
        }
        self.animateWithDuration = YES;
        self.isTransitionInteractive = NO;
    }
}

#pragma mark - UIScrollViewDelegate Methods


- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView.panGestureRecognizer.view];
    if (velocity.x) {
        self.panAnimator.panDirection = PMPanDirectionForVelocity(velocity);
    }
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.titleViews.count;
}

- (UICollectionViewCell *) collectionView:(PMCenteredCircularCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger normalizedIndex = [collectionView normalizeIndex:indexPath.item];
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PMReuseIdentifier(normalizedIndex) forIndexPath:indexPath];
	if (!cell.contentView.subviews.count) {
		cell.contentView.backgroundColor = self.titleBannerBackgroundColor;
        UIView *view = self.titleViews[normalizedIndex];
        view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [cell.contentView addSubview:view];
        [view centerInRect:cell.contentView.bounds forDirection:PMDirectionVertical | PMDirectionHorizontal];
	}
	return cell;
}


#pragma mark - PMCenteredCircularCollectionViewDelegate Methods

- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView didCenterItemAtIndex:(NSUInteger)index
{
    if (!self.isTransitionInteractive) {
		NSInteger normalizedIndex = [collectionView normalizeIndex:index];
        self.selectedIndex = normalizedIndex;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize) collectionView:(PMCenteredCircularCollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger normalizedIndex = [collectionView normalizeIndex:indexPath.item];
    UIView *view = self.titleViews[normalizedIndex];
    return CGSizeMake(view.frame.size.width + self.addedTitlePadding, collectionView.bounds.size.height);
}

#pragma mark - UITabBarControllerDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC
{
    if (self.panAnimator.panDirection == PMPanDirectionNone) {
        
        NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
        NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
        
        NSRange range = NSMakeRange(0, tabBarController.viewControllers.count);
        NSInteger delta = PMShortestCircularDistance(fromVCIndex, toVCIndex, range);
        
        self.panAnimator.panDirection = (delta > 0)? PMPanDirectionNegative : PMPanDirectionPositive;
    }
    return self.panAnimator;
}


- (id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
                      interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController
{
    return self.isTransitionInteractive? self.interactivePanTransition : nil;
}



@end
