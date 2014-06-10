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

static inline NSTimeInterval _PMDuration(CGFloat rate, CGFloat distance) {
    return distance / rate;
}

static inline PMPanDirection _PMPanDirectionForVelocity(CGPoint velocity) {
    return (velocity.x > 0.0f)? PMPanDirectionPositive : PMPanDirectionNegative;
}

static inline NSString * _PMReuseIdentifier(NSInteger index) {
    return [[NSNumber numberWithInteger:index] stringValue];
}


@interface PMTabBarController ()
<UITabBarControllerDelegate, PMAnimatorDelegate, UICollectionViewDataSource, PMCenteredCircularCollectionViewDelegate>

@end


@implementation PMTabBarController
{
	CGFloat _addedTitlePadding;
	BOOL _animateWithDuration;
	BOOL _isTransitionInteractive;
	PMPanAnimator *_panAnimator;
	PMCenteredCircularCollectionView *_titleBanner;
	UIPercentDrivenInteractiveTransition *_interactivePanTransition;
	void(^_panAnimatiorEndedBlock)(BOOL completed);
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _commonPMTabBarControllerInit];
    }
    return self;
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
    
	PMCenteredCollectionViewFlowLayout *titleBannerLayout = [PMCenteredCollectionViewFlowLayout new];
	titleBannerLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    titleBannerLayout.minimumLineSpacing = 0.0f;
    titleBannerLayout.minimumInteritemSpacing = 0.0f;
    
    _titleBanner = [PMCenteredCircularCollectionView collectionViewWithFrame:bannerFrame collectionViewLayout:titleBannerLayout];
    _titleBanner.delegate = self;
	_titleBanner.dataSource = self;
    _titleBanner.backgroundColor = _titleBannerBackgroundColor;
    _titleBanner.shadowRadius = _titleBannerShadowRadius;
    [_titleBanner centerCellAtIndex:self.selectedIndex animated:NO];
	_titleBanner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_titleBanner];
    
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

- (BOOL) shouldAutorotate
{
	return NO;
}


#pragma mark - Public Methods


- (void) setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated completion:(void (^)(BOOL completed))completion
{
    NSUInteger index = [self.viewControllers indexOfObject:selectedViewController];
    [self setSelectedIndex:index animated:animated completion:completion];
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated completion:(void(^)(BOOL completed))completion
{
    if (selectedIndex < self.viewControllers.count &&
        selectedIndex != self.selectedIndex) {
        
        [_titleBanner centerCellAtIndex:selectedIndex animated:animated];
        _animateWithDuration = animated;
        _panAnimatiorEndedBlock = [completion copy];
        self.selectedIndex = selectedIndex;
    }
}


#pragma mark - Accessors


- (void) setTitleViews:(NSArray *)titleViews
{
    if (_titleViews != titleViews) {
        _titleViews = titleViews;
        [self _registerCells];
		_addedTitlePadding = [self _calculateTitlePadding];
        [_titleBanner reloadData];
        [_titleBanner centerCellAtIndex:self.selectedIndex animated:NO];
    }
}

- (void) setTitleBannerBackgroundColor:(UIColor *)titleBannerBackgroundColor
{
    if (_titleBannerBackgroundColor != titleBannerBackgroundColor) {
        _titleBannerBackgroundColor = titleBannerBackgroundColor;
        _titleBanner.backgroundColor = titleBannerBackgroundColor;
		_titleBanner.shadowColor = titleBannerBackgroundColor;
    }
}

- (void) setTitleBannerShadowRadius:(CGFloat)titleBannerShadowRadius
{
    if (_titleBannerShadowRadius != titleBannerShadowRadius) {
        _titleBannerShadowRadius = titleBannerShadowRadius;
        _titleBanner.shadowRadius = titleBannerShadowRadius;
    }
}

- (void) setTitleBannerSpacing:(CGFloat)titleBannerSpacing
{
    if (_titleBannerSpacing != titleBannerSpacing) {
        _titleBannerSpacing = titleBannerSpacing;
        CGFloat newTitlePadding = [self _calculateTitlePadding];
        if (newTitlePadding != _addedTitlePadding) {
			_addedTitlePadding = newTitlePadding;
            [_titleBanner reloadData];
        }
    }
}

- (void) setIsTransitionInteractive:(BOOL)isTransitionInteractive
{
    if (_isTransitionInteractive != isTransitionInteractive) {
        _isTransitionInteractive = isTransitionInteractive;
        _titleBanner.userInteractionEnabled = !isTransitionInteractive;
        if (_isTransitionInteractive) {
            [_titleBanner killScroll];
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
	return self.titleViews.count;
}

- (UICollectionViewCell *) collectionView:(PMCenteredCircularCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger normalizedIndex = [collectionView normalizeIndex:indexPath.item];
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_PMReuseIdentifier(normalizedIndex) forIndexPath:indexPath];
	if (!cell.contentView.subviews.count) {
		cell.contentView.backgroundColor = _titleBannerBackgroundColor;
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
    if (!_isTransitionInteractive) {
		NSInteger normalizedIndex = [collectionView normalizeIndex:index];
        self.selectedIndex = normalizedIndex;
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout Methods


- (CGSize) collectionView:(PMCenteredCircularCollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger normalizedIndex = [collectionView normalizeIndex:indexPath.item];
    UIView *view = self.titleViews[normalizedIndex];
    return CGSizeMake(view.frame.size.width + _addedTitlePadding, collectionView.bounds.size.height);
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
                [_titleBanner centerCellAtIndex:self.selectedIndex animated:YES];
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

- (void) _registerCells
{
    for (NSInteger i = 0; i < self.titleViews.count; i++) {
        [_titleBanner registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_PMReuseIdentifier(i)];
    }
}

- (CGFloat) _calculateTitlePadding
{
    CGFloat contentWidth = 0.0f;
    for (UIView *view in self.titleViews) {
        contentWidth += view.frame.size.width;
    }
    
    CGFloat maxSpacingRequired = 0.0f;
    for (UIView *view in self.titleViews) {

        CGFloat totalSpacingRequired =  (_titleBanner.bounds.size.width - (contentWidth - view.frame.size.width));
        CGFloat spacingRequired = ceilf(totalSpacingRequired / (self.titleViews.count-1));
        
        if (spacingRequired > maxSpacingRequired) {
            maxSpacingRequired = spacingRequired;
        }
    }
    
    return fmaxf(maxSpacingRequired, _titleBannerSpacing);
}


@end
