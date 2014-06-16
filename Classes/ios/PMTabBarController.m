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

static NSString * const PMReuseIdentifier = @"PMReuseIdentifier";
static void * PMContext = &PMContext;

static inline NSTimeInterval _PMDuration(CGFloat rate, CGFloat distance) {
    return distance / rate;
}

static inline PMPanDirection _PMPanDirectionForVelocity(CGPoint velocity) {
    return (velocity.x > 0.0f)? PMPanDirectionPositive : PMPanDirectionNegative;
}

@interface PMTabBarController ()
<UITabBarControllerDelegate, PMAnimatorDelegate, UICollectionViewDataSource, PMCenteredCircularCollectionViewDelegate>

@end


@implementation PMTabBarController
{
	CGFloat _tabPadding;
	BOOL _animateWithDuration;
	BOOL _isTransitionInteractive;
	PMPanAnimator *_panAnimator;
	PMCenteredCircularCollectionView *_tabBar;
	UIPercentDrivenInteractiveTransition *_interactivePanTransition;
	void(^_panAnimatiorEndedBlock)(BOOL completed);
}

+ (instancetype) tabBarWithTabViews:(NSArray *)tabViews
{
	return [[self alloc] initWithTabViews:tabViews];
}

- (instancetype) initWithTabViews:(NSArray *)tabViews
{
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		_tabViews = tabViews;
		_tabPadding = [self _calculateTabPadding];
		[self _commonPMTabBarControllerInit];
	}
	return self;
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	return [self initWithTabViews:nil];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonPMTabBarControllerInit];
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
    
	PMCenteredCollectionViewFlowLayout *tabBarLayout = [PMCenteredCollectionViewFlowLayout new];
	tabBarLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    tabBarLayout.minimumLineSpacing = 0.0f;
	tabBarLayout.minimumInteritemSpacing = 0.0f;
    
    _tabBar = [PMCenteredCircularCollectionView collectionViewWithFrame:bannerFrame collectionViewLayout:tabBarLayout];
    _tabBar.delegate = self;
	_tabBar.dataSource = self;
	_tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[_tabBar registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:PMReuseIdentifier];
	[_tabBar addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionNew context:PMContext];
    [self.view addSubview:_tabBar];
	
	UIView *panContainer = [[UIView alloc] initWithFrame:containerFrame];
	panContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:panContainer];
	
    UIScreenEdgePanGestureRecognizer *leftEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
    leftEdgePan.edges = UIRectEdgeLeft;
    UIScreenEdgePanGestureRecognizer *rightEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
    rightEdgePan.edges = UIRectEdgeRight;
    [panContainer addGestureRecognizer:leftEdgePan];
    [panContainer addGestureRecognizer:rightEdgePan];

    _interactivePanTransition = [UIPercentDrivenInteractiveTransition new];
    _interactivePanTransition.completionCurve = UIViewAnimationCurveEaseOut;
    _panAnimator = [PMPanAnimator new];
    _panAnimator.delegate = self;
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[_tabBar setCenteredIndex:self.selectedIndex animated:YES];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == PMContext) {
		if (object == _tabBar && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
			CGFloat tabPadding = [self _calculateTabPadding];
			if (tabPadding != _tabPadding) {
				_tabPadding = tabPadding;
				[_tabBar.collectionViewLayout invalidateLayout];
			}
		}
	}
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[_tabBar reloadData];
}

#pragma mark - Public Methods


- (void) setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated completion:(void (^)(BOOL completed))completion
{
    NSUInteger selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
    [self setSelectedIndex:selectedIndex animated:animated completion:completion];
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated completion:(void(^)(BOOL completed))completion
{
    if (selectedIndex < self.viewControllers.count && selectedIndex != self.selectedIndex) {
        _animateWithDuration = animated;
        _panAnimatiorEndedBlock = [completion copy];
        self.selectedIndex = selectedIndex;
		[_tabBar setCenteredIndex:selectedIndex animated:animated];
    }
}


#pragma mark - Accessors


- (void) setTabViews:(NSArray *)tabViews
{
    if (_tabViews != tabViews) {
        _tabViews = tabViews;
		_tabPadding = [self _calculateTabPadding];
		[_tabBar reloadData];
		_tabBar.centeredIndex = self.selectedIndex;
    }
}

- (void) setTabBarBackgroundColor:(UIColor *)tabBarBackgroundColor
{
    if (_tabBar.backgroundColor != tabBarBackgroundColor) {
        _tabBar.backgroundColor = tabBarBackgroundColor;
		_tabBar.shadowColor = tabBarBackgroundColor;
    }
}

- (UIColor *) tabBarBackgroundColor
{
	return _tabBar.backgroundColor;
}

- (void) setTabBarShadowRadius:(CGFloat)tabBarShadowRadius
{
    if (_tabBar.shadowRadius != tabBarShadowRadius) {
        _tabBar.shadowRadius = tabBarShadowRadius;
    }
}

- (CGFloat) tabBarShadowRadius
{
	return _tabBar.shadowRadius;
}

- (void) setMinimumTabBarSpacing:(CGFloat)tabBarSpacing
{
    if (_tabBar.collectionViewLayout.minimumInteritemSpacing != tabBarSpacing) {
		_tabBar.collectionViewLayout.minimumInteritemSpacing = tabBarSpacing;
		_tabBar.collectionViewLayout.minimumLineSpacing = tabBarSpacing;
        _tabPadding = [self _calculateTabPadding];
		[_tabBar.collectionViewLayout invalidateLayout];
    }
}

- (CGFloat) minimumTabBarSpacing
{
	return _tabBar.collectionViewLayout.minimumInteritemSpacing;
}

- (void) setIsTransitionInteractive:(BOOL)isTransitionInteractive
{
    if (_isTransitionInteractive != isTransitionInteractive) {
        _isTransitionInteractive = isTransitionInteractive;
        _tabBar.userInteractionEnabled = !isTransitionInteractive;
        if (_isTransitionInteractive) {
            [_tabBar killScroll];
        }
    }
}


#pragma mark - PMAnimatorDelegate Methods


- (BOOL) animateWithDuration:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if (animator == _panAnimator) {
        return _animateWithDuration;
    }
    return YES;
}

- (void) animatior:(id<UIViewControllerAnimatedTransitioning>)animator ended:(BOOL)completed
{
    if (animator == _panAnimator) {
        
        if (_panAnimatiorEndedBlock) {
            _panAnimatiorEndedBlock(completed);
        }
        _animateWithDuration = YES;
        self.isTransitionInteractive = NO;
    }
}


#pragma mark - UIScrollViewDelegate Methods


- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView.panGestureRecognizer.view];
    if (velocity.x) {
        _panAnimator.panDirection = _PMPanDirectionForVelocity(velocity);
    }
}


#pragma mark - UICollectionViewDataSource Methods


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.tabViews.count;
}

- (UICollectionViewCell *) collectionView:(PMCenteredCircularCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger normalizedIndex = [collectionView normalizeIndex:indexPath.item];
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PMReuseIdentifier forIndexPath:indexPath];
	[cell.contentView removeSubviews];
	UIView *view = self.tabViews[normalizedIndex];
	view.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin |
							 UIViewAutoresizingFlexibleLeftMargin |
							 UIViewAutoresizingFlexibleRightMargin |
							 UIViewAutoresizingFlexibleTopMargin);
	[cell.contentView addSubview:view];
	[view centerInRect:cell.contentView.bounds forDirection:PMDirectionVertical | PMDirectionHorizontal];
	return cell;
}


#pragma mark - PMCenteredCircularCollectionViewDelegate Methods


- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView willCenterItemAtIndex:(NSUInteger)index
{
    if (!_isTransitionInteractive) {
		NSInteger normalizedIndex = [collectionView normalizeIndex:index];
        self.selectedIndex = normalizedIndex;
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout Methods


- (CGSize) collectionView:(PMCenteredCircularCollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger normalizedIndex = [collectionView normalizeIndex:indexPath.item];
    UIView *view = self.tabViews[normalizedIndex];
    return CGSizeMake(view.frame.size.width + _tabPadding, collectionView.bounds.size.height);
}


#pragma mark - UITabBarControllerDelegate Methods


- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC
{
    if (_panAnimator.panDirection == PMPanDirectionNone) {
        
        NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
        NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
        
        NSRange range = NSMakeRange(0, tabBarController.viewControllers.count);
        NSInteger delta = PMShortestCircularDistance(fromVCIndex, toVCIndex, range);
        
        _panAnimator.panDirection = (delta > 0)? PMPanDirectionNegative : PMPanDirectionPositive;
    }
    return _panAnimator;
}


- (id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
                      interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController
{
    return _isTransitionInteractive? _interactivePanTransition : nil;
}


#pragma mark - Private Methods


- (void) _commonPMTabBarControllerInit
{
    self.delegate = self;
    _animateWithDuration = YES;
}

- (void)_handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
	
	CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view.superview];
	CGPoint delta = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    
	switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            self.isTransitionInteractive = YES;
            _panAnimator.panDirection = _PMPanDirectionForVelocity(velocity);
            self.selectedIndex = (velocity.x < 0.0f)? [self _nextIndex] : [self _previousIndex];
		}
			
        case UIGestureRecognizerStateChanged: {
            
            CGFloat percent =  fabsf(delta.x) / gestureRecognizer.view.superview.frame.size.width;
            [_interactivePanTransition updateInteractiveTransition:percent];
            break;
        }
			
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
			
            CGFloat remainingDistance = gestureRecognizer.view.superview.frame.size.width - fabsf(delta.x);
            CGFloat speedMultiplier = _interactivePanTransition.duration / _PMDuration(fabsf(velocity.x), remainingDistance);
            _interactivePanTransition.completionSpeed = fmaxf(1.0f, speedMultiplier);
			
            if ([self _shouldCompleteForVelocity:velocity delta:delta]) {
                [_tabBar setCenteredIndex:self.selectedIndex animated:YES];
                [_interactivePanTransition finishInteractiveTransition];
            }
            else {
                [_interactivePanTransition cancelInteractiveTransition];
            }
            break;
        }
        default:  break;
    }
}

- (BOOL) _shouldCompleteForVelocity:(CGPoint)velocity delta:(CGPoint)delta
{
	switch (_panAnimator.panDirection) {
		case PMPanDirectionPositive:	return (velocity.x >= RequiredXVelocity && delta.x >= RequiredDeltaDistance);
		case PMPanDirectionNegative:	return (velocity.x <= RequiredXVelocity && delta.x <= RequiredDeltaDistance);
		case PMPanDirectionNone:		@throw([NSException exceptionWithName:@"Pan Direction Not Set" reason:NSLocalizedString(@"Pan Direction must be set when calling -shouldCompleteForVelocity", nil) userInfo:nil]);
	}
}

- (NSUInteger) _nextIndex
{
	if (self.selectedIndex == self.viewControllers.count-1) {
		return 0;
	}
	return self.selectedIndex + 1;
}

- (NSUInteger) _previousIndex
{
	if (self.selectedIndex == 0) {
		return self.viewControllers.count - 1;
	}
	return self.selectedIndex - 1;
}

- (CGFloat) _calculateTabPadding
{
    CGFloat contentWidth = 0.0f;
	CGFloat widestViewWidth = 0.0f;
	
    for (UIView *view in self.tabViews) {
        contentWidth += view.frame.size.width;
		if (view.frame.size.width > widestViewWidth) {
			widestViewWidth = view.frame.size.width;
		}
    }
	
	contentWidth += _tabBar.collectionViewLayout.minimumInteritemSpacing * (self.tabViews.count-1);
    
	CGFloat requiredContentWidth = _tabBar.frame.size.width + widestViewWidth;
	
	if (requiredContentWidth > contentWidth) {
		
		CGFloat missingWidth = requiredContentWidth - contentWidth;
		CGFloat paddingRequiredPerTab = ceilf(missingWidth / (self.tabViews.count-1));
		return paddingRequiredPerTab;
	}
	
	return 0.0f;
}


@end
