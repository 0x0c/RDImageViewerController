//
//  RDImageViewerController.m
//
//  Created by Akira Matsuda on 2014/03/20.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "RDImageViewerController.h"
#import <QuartzCore/QuartzCore.h>
#import "RDImageScrollView.h"
#import "rd_M2DURLConnectionOperation.h"

typedef NS_ENUM(NSInteger, ViewTag) {
	MainScrollView = 1,
	PageScrollView,
	CurrentPageLabel
};

typedef NS_ENUM(NSInteger, Direction) {
	RDImageViewMoveDirectionForward = 1,
	RDImageViewMoveDirectionBackward = -1
};

typedef struct {
	BOOL willChangeIndexTo;
} RDImageViewerControllerDelegateFlag;

static const NSInteger PageLabelFontSize = 17;

@interface RDImageViewerController ()
{
	BOOL statusBarHidden_;
	NSInteger previousPageIndex_;
}

@property (nonatomic, strong) UISelectionFeedbackGenerator *feedbackGenerator;
@property (nonatomic, assign) RDImageViewerControllerDelegateFlag delegateFlag;
@property (nonatomic, strong) RDPagingView *pagingView;
@property (nonatomic, strong) UIView *currentPageHud;
@property (nonatomic, strong) NSOperationQueue *asynchronousImageHandlerQueue;
@property (nonatomic, readonly) UISlider *pageSlider;
@property (nonatomic, strong) NSMutableArray *remoteImageRequestArray;
@property (nonatomic, strong) NSMutableArray *remoteImageRequestRunnintArray;

- (instancetype)initWithNumberOfPages:(NSInteger)num direction:(RDPagingViewForwardDirection)direction;

@end

@implementation RDImageViewerController

static NSInteger kPreloadDefaultCount = 1;

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden
{
	return statusBarHidden_;
}

-(BOOL)shouldAutorotate
{
	return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}

// iOS7
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.pagingView startRotation];
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
			[self.pagingView resizeWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame)) duration:duration];
		}
	}
	else {
		[self.pagingView resizeWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame)) duration:duration];
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration - 0.5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		CGFloat toolBarPositionY = (self.toolbarItems.count > 0) ? CGRectGetMinY(self.navigationController.toolbar.frame) : CGRectGetHeight(self.view.frame);
		self.currentPageHud.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.currentPageHud.frame) / 2, toolBarPositionY - CGRectGetHeight(self.currentPageHud.frame) - 10, CGRectGetWidth(self.currentPageHud.frame), CGRectGetHeight(self.currentPageHud.frame));
	});
	[self.pagingView endRotation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self reloadPageHud];
}

// iOS8
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	[self.pagingView startRotation];
	UIUserInterfaceSizeClass sizeClass = self.traitCollection.verticalSizeClass;
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		if (self.traitCollection.verticalSizeClass != sizeClass) {
			NSTimeInterval duration = [context transitionDuration];
			[self.pagingView resizeWithFrame:CGRectMake(0, 0, size.width, size.height) duration:duration];
		}
		CGFloat toolBarPositionY = (self.toolbarItems.count > 0) ? CGRectGetMinY(self.navigationController.toolbar.frame) : CGRectGetHeight(self.view.frame);
		self.currentPageHud.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.currentPageHud.frame) / 2, toolBarPositionY - CGRectGetHeight(self.currentPageHud.frame) - 10, CGRectGetWidth(self.currentPageHud.frame), CGRectGetHeight(self.currentPageHud.frame));
	} completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		[self.pagingView endRotation];
	}];
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.feedbackGenerator = [UISelectionFeedbackGenerator new];
		[self.feedbackGenerator prepare];
		previousPageIndex_ = 0;
	}
	
	return self;
}

- (instancetype)initWithContentData:(NSArray <RDPageContentData *> *)contentData direction:(RDPagingViewForwardDirection)direction
{
	self = [self initWithNumberOfPages:contentData.count direction:direction];
	if (self) {
		self.contentData = contentData;
	}
	
	return self;
}

- (instancetype)initWithNumberOfPages:(NSInteger)num direction:(RDPagingViewForwardDirection)direction
{
	self = [self init];
	if (self) {
		self.pagingView = [[RDPagingView alloc] initWithFrame:self.view.bounds];
		self.pagingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.pagingView.backgroundColor = [UIColor blackColor];
		self.pagingView.pagingDelegate = self;
		self.pagingView.direction = direction;
		self.pagingView.directionalLockEnabled = YES;
		self.pagingView.tag = MainScrollView;
		self.pagingView.showsHorizontalScrollIndicator = NO;
		self.pagingView.showsVerticalScrollIndicator = NO;
		self.pagingView.numberOfPages = num;
		UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setBarHiddenByTapGesture)];
		[self.pagingView addGestureRecognizer:gesture];
		self.remoteImageRequestArray = [NSMutableArray new];
		self.remoteImageRequestRunnintArray = [NSMutableArray new];
		self.asynchronousImageHandlerQueue = [NSOperationQueue new];
		self.preloadCount = kPreloadDefaultCount;
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.currentPageHud = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
	if (NSFoundationVersionNumber_iOS_8_0 <= floor(NSFoundationVersionNumber)) {
		UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
		blurView.frame = self.currentPageHud.bounds;
		[self.currentPageHud addSubview:blurView];
		self.currentPageHud.clipsToBounds = YES;
		self.currentPageHud.layer.cornerRadius = 15;
	}
	else {
		self.currentPageHud.layer.cornerRadius = 10;
		self.currentPageHud.backgroundColor = [UIColor blackColor];
	}
	self.currentPageHud.layer.borderColor = [UIColor whiteColor].CGColor;
	self.currentPageHud.layer.borderWidth = 1;
	self.currentPageHud.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	self.currentPageHud.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.currentPageHud.frame) / 2, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.currentPageHud.frame) - 50 * (self.toolbarItems.count > 0) - 10, CGRectGetWidth(self.currentPageHud.frame), CGRectGetHeight(self.currentPageHud.frame));
	self.currentPageHud.alpha = 0;
	
	_currentPageHudLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, PageLabelFontSize)];
	self.currentPageHudLabel.backgroundColor = [UIColor clearColor];
	self.currentPageHudLabel.font = [UIFont systemFontOfSize:PageLabelFontSize];
	self.currentPageHudLabel.textColor = [UIColor whiteColor];
	self.currentPageHudLabel.textAlignment = NSTextAlignmentCenter;
	self.currentPageHudLabel.center = CGPointMake(CGRectGetWidth(self.currentPageHud.frame) / 2, CGRectGetHeight(self.currentPageHud.frame) / 2);
	self.currentPageHudLabel.tag = CurrentPageLabel;
	[self.currentPageHud addSubview:self.currentPageHudLabel];
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.pagingView.frame = self.view.bounds;
	
	if (self.restoreBarsState == NO) {
		[self setBarsHidden:NO animated:YES];
		[self setHudHidden:NO animated:animated];
	}
	
	if (self.pagingView.superview == nil) {
		[self.view addSubview:self.pagingView];
		[self.pagingView scrollAtPage:self.pagingView.currentPageIndex];
	}
	
	if (self.contentData.count) {
		if ((self.showSlider == YES && RDPagingViewForwardDirectionVertical(self.pagingView.direction)) && _pageSlider == nil) {
			_pageSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 30, 31)];
			_pageSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			[_pageSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
			[_pageSlider addTarget:self action:@selector(sliderDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
			UIBarButtonItem *sliderItem = [[UIBarButtonItem alloc] initWithCustomView:_pageSlider];
			self.toolbarItems = @[sliderItem];
			if (RDPagingViewForwardDirectionVertical(self.pagingView.direction)) {
				if (self.pagingView.direction == RDPagingViewForwardDirectionRight) {
					_pageSlider.value = (CGFloat)self.pagingView.currentPageIndex / (self.pagingView.numberOfPages - 1);
				}
				else {
					_pageSlider.value = 1 - (CGFloat)self.pagingView.currentPageIndex / (self.pagingView.numberOfPages - 1);
				}
			}
			self.currentPageHud.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.currentPageHud.frame) / 2, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.currentPageHud.frame) - 50 * (self.toolbarItems.count > 0) - 10, CGRectGetWidth(self.currentPageHud.frame), CGRectGetHeight(self.currentPageHud.frame));
			[self applySliderTintColor];
		}
		if (self.showPageNumberHud == YES) {
			[self setPageHudNumberWithPageIndex:self.pagingView.currentPageIndex];
			[self.view addSubview:self.currentPageHud];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.pagingView.pagingDelegate = self;
	if (self.autoBarsHiddenDuration > 0) {
		[self performSelector:@selector(hideBars) withObject:self afterDelay:self.autoBarsHiddenDuration];
		self.autoBarsHiddenDuration = 0;
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:self];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	self.pagingView.pagingDelegate = nil;
}

- (void)setDelegate:(id<RDImageViewerControllerDelegate>)delegate
{
	_delegate = delegate;
	_delegateFlag.willChangeIndexTo = [_delegate respondsToSelector:@selector(imageViewerController:willChangeIndexTo:)];
}

- (NSInteger)currentPageIndex
{
	return self.pagingView.currentPageIndex;
}

- (void)setCurrentPageIndex:(NSInteger)pageIndex
{
	if (self.pagingView.direction == RDPagingViewForwardDirectionRight) {
		_pageSlider.value = (CGFloat)self.pagingView.currentPageIndex / (self.pagingView.numberOfPages - 1);
	} else {
		_pageSlider.value = 1 - (CGFloat)self.pagingView.currentPageIndex / (self.pagingView.numberOfPages - 1);
	}
	
	[self.pagingView scrollAtPage:pageIndex];
}

- (NSInteger)numberOfPages
{
	return self.pagingView.numberOfPages;
}

#pragma mark -

- (void)applySliderTintColor
{
	UIColor *maximumTintColor =  self.pageSliderMaximumTrackTintColor ?: [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
	UIColor *minimumTintColor = self.pageSliderMinimumTrackTintColor ?: [UIColor whiteColor];
	_pageSlider.maximumTrackTintColor = self.pagingView.direction == RDPagingViewForwardDirectionLeft ? maximumTintColor : minimumTintColor;
	_pageSlider.minimumTrackTintColor = self.pagingView.direction == RDPagingViewForwardDirectionLeft ? minimumTintColor : maximumTintColor;
}

- (void)setShowPageNumberHud:(BOOL)showPageNumberHud
{
	_showPageNumberHud = showPageNumberHud;
	if (showPageNumberHud == YES) {
		[self.view addSubview:self.currentPageHud];
	}
	else {
		[self.currentPageHud removeFromSuperview];
	}
}

- (void)setShowSlider:(BOOL)showSlider
{
	_showSlider = showSlider;
	CGFloat toolBarPositionY = (self.toolbarItems.count > 0) ? CGRectGetMinY(self.navigationController.toolbar.frame) : CGRectGetHeight(self.view.frame);
	self.currentPageHud.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.currentPageHud.frame) / 2, toolBarPositionY - CGRectGetHeight(self.currentPageHud.frame) - 10, CGRectGetWidth(self.currentPageHud.frame), CGRectGetHeight(self.currentPageHud.frame));
	[self applySliderTintColor];
}

- (void)setPreloadCount:(NSUInteger)preloadCount
{
	self.pagingView.preloadCount = preloadCount;
}

- (NSUInteger)preloadCount
{
	return self.pagingView.preloadCount;
}

- (void)setPagingEnabled:(BOOL)paging
{
	self.pagingView.pagingEnabled = paging;
}

- (BOOL)pagingEnabled
{
	return self.pagingView.pagingEnabled;
}

#pragma mark -

- (void)hideBars
{
	[self setBarsHidden:YES animated:YES];
}

- (void)setPageHudNumberWithPageIndex:(NSInteger)pageIndex
{
	self.currentPageHudLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)pageIndex + 1, (long)self.pagingView.numberOfPages];
}

- (void)reloadPageHud
{
	[self setPageHudNumberWithPageIndex:self.pagingView.currentPageIndex];
}

- (void)setBarHiddenByTapGesture
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:self];
	[self setBarsHidden:!statusBarHidden_ animated:YES];
}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated
{
	if ((self.toolbarItems.count > 0 || self.showSlider) && RDPagingViewForwardDirectionVertical(self.pagingView.direction)) {
		[self.navigationController setToolbarHidden:hidden animated:animated];
	}
	[self.navigationController setNavigationBarHidden:hidden animated:animated];
	[self setHudHidden:hidden animated:animated];
	[self setStatusBarHidden:hidden];
}

- (void)setHudHidden:(BOOL)hidden animated:(BOOL)animated
{
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration * animated animations:^{
		CGFloat toolBarPositionY = (self.toolbarItems.count > 0) ? CGRectGetMinY(self.navigationController.toolbar.frame) : CGRectGetHeight(self.view.frame);
		self.currentPageHud.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.currentPageHud.frame) / 2, toolBarPositionY - CGRectGetHeight(self.currentPageHud.frame) - 10, CGRectGetWidth(self.currentPageHud.frame), CGRectGetHeight(self.currentPageHud.frame));
		// TODO: use NSFoundationVersionNumber_iOS_9_0
		if (NSFoundationVersionNumber_iOS_7_1 < floor(NSFoundationVersionNumber)) {
			self.currentPageHud.alpha = !hidden;
		}
		else {
			self.currentPageHud.alpha = !hidden * 0.8;
		}
	} completion:nil];
}

- (void)setStatusBarHidden:(BOOL)hidden
{
	statusBarHidden_ = hidden;
	BOOL viewBasedAppearance = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue];
	if (viewBasedAppearance == NO) {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	}
	else {
		[self setNeedsStatusBarAppearanceUpdate];
	}
}

- (void)cancelAutoBarHidden
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:self];
}

- (void)sliderValueDidChange:(id)sender
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:self];
	UISlider *slider = sender;
	CGFloat trueValue = self.pagingView.direction == RDPagingViewForwardDirectionRight ? slider.value : 1 - slider.value;
	CGFloat page = trueValue * (self.pagingView.numberOfPages - 1);
	if (self.currentPageIndex != (NSInteger)page) {
		[self.feedbackGenerator selectionChanged];
	}
	[self.pagingView scrollAtPage:page];
}

- (void)sliderDidTouchUpInside:(id)sender
{
	UISlider *slider = sender;
	CGFloat value = self.pagingView.currentPageIndex / (CGFloat)(self.pagingView.numberOfPages - 1);
	CGFloat trueValue = self.pagingView.direction == RDPagingViewForwardDirectionRight ? value : 1 - value;
	[slider setValue:trueValue animated:YES];
}

- (void)reloadViewAtIndex:(NSInteger)index
{
	RDPageContentData *data = self.contentData[index];
	[data reload];
	[self refreshViewAtIndex:index];
}

- (void)refreshViewAtIndex:(NSInteger)index
{
	RDPageContentData *data = self.contentData[index];
	UIView *view = [self.pagingView viewForIndex:index];
	if (view) {
		[data configureForView:view];
	}
}

#pragma mark - RDPagingViewDelegate

- (void)pagingView:(RDPagingView *)pagingView willChangeIndexTo:(NSInteger)index
{
	if (_delegateFlag.willChangeIndexTo) {
		[self.delegate imageViewerController:self willChangeIndexTo:index];
	}
}

- (UIView *)pagingView:(RDPagingView *)pageView viewForIndex:(NSInteger)index
{
	RDPageContentData *data = self.contentData[index];
	UIView *view = nil;
	if ([data respondsToSelector:@selector(contentViewWithFrame:)]) {
		view = [data contentViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(pageView.bounds), CGRectGetHeight(pageView.bounds))];
	}
	else {
		view = [[data class] contentViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(pageView.bounds), CGRectGetHeight(pageView.bounds))];
	}
	NSAssert(view, @"contentViewWithFrame: must not return nil.");
	if (data.preloadable) {
		[data preload];
	}
	[data configureForView:view];
	if ([view isKindOfClass:[RDImageScrollView class]]) {
		RDImageScrollView *imageScrollView = (RDImageScrollView *)view;
		[self.pagingView.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			UIGestureRecognizer *gesture = obj;
			if ([gesture isMemberOfClass:[UITapGestureRecognizer class]]) {
				[imageScrollView addGestureRecognizerPriorityHigherThanZoomGestureRecogniser:gesture];
				*stop = YES;
			}
		}];
	}
	if (self.contentViewWillAppearHandler) {
		self.contentViewWillAppearHandler(index, view);
	}

	return view;
}

- (NSString *)paginView:(RDPagingView *)paginView reuseIdentifierForIndex:(NSInteger)index
{
	RDPageContentData *data = self.contentData[index];
	return NSStringFromClass([data class]);
}

- (void)pagingView:(RDPagingView *)pagingView willChangeViewSize:(CGSize)size duration:(NSTimeInterval)duration visibleViews:(NSArray *)views
{
	[views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
		if (view.pageIndex != pagingView.currentPageIndex) {
			view.hidden = YES;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				view.hidden = NO;
			});
		}
		if (RDPagingViewForwardDirectionVertical(pagingView.direction)) {
			view.frame = CGRectMake((pagingView.direction == RDPagingViewForwardDirectionRight ? view.pageIndex : (pagingView.numberOfPages - view.pageIndex - 1)) * size.width, 0, size.width, size.height);
		}
		else {
			view.frame = CGRectMake(0, (pagingView.direction == RDPagingViewForwardDirectionDown ? view.pageIndex : (pagingView.numberOfPages - view.pageIndex - 1)) * size.height, size.width, size.height);
		}

		if ([view isKindOfClass:[UIScrollView class]]) {
			[(UIScrollView *)view setZoomScale:1.0];
			if ([view isKindOfClass:[RDImageScrollView class]]) {
				[(RDImageScrollView *)view adjustContentAspect];
			}
		}
	}];
}

- (void)pagingView:(RDPagingView *)pagingView willViewEnqueue:(UIView *)view
{
	RDPageContentData *data = self.contentData[view.pageIndex];
	[data stopPreloading];
}

- (void)pagingView:(RDPagingView *)pagingView didScrollToPosition:(CGFloat)position
{
	UISlider *slider = _pageSlider;
	if (slider.state == UIControlStateNormal) {
		[slider setValue:position / (pagingView.numberOfPages - 1) animated:NO];
	}
	[self reloadPageHud];
}

- (void)pagingViewWillBeginDragging:(RDPagingView *)pagingView
{
	if (pagingView.dragging == NO) {
		previousPageIndex_ = self.currentPageIndex;
	}
}

- (void)pagingViewDidEndDecelerating:(RDPagingView *)pagingView
{
	NSInteger page = self.currentPageIndex;
	[pagingView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[UIScrollView class]]) {
			UIScrollView *pageView = (UIScrollView *)obj;
			if (RDPagingViewForwardDirectionVertical(pagingView.direction)) {
				if (pagingView.pagingEnabled == YES && page != previousPageIndex_) {
					pageView.zoomScale = 1.0;
				}
				else if (previousPageIndex_ == pagingView.currentPageIndex - 2 || previousPageIndex_ == pagingView.currentPageIndex + 2) {
					pageView.zoomScale = 1.0;
				}
			}
			else {
				if (pagingView.pagingEnabled == YES && page != previousPageIndex_) {
					pageView.zoomScale = 1.0;
				}
				else if (previousPageIndex_ == pagingView.currentPageIndex - 2 || previousPageIndex_ == pagingView.currentPageIndex + 2) {
					pageView.zoomScale = 1.0;
				}
			}
		}
	}];
}

@end
