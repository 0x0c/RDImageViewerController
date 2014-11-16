//
//  RDImageViewerController.m
//
//  Created by Akira Matsuda on 2014/03/20.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "RDImageViewerController.h"
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, ViewTag) {
	MainScrollView = 1,
	PageScrollView,
	CurrentPageLabel
};

typedef NS_ENUM(NSInteger, Direction) {
	RDImageViewMoveDirectionForward = 1,
	RDImageViewMoveDirectionBackward = -1
};

static const NSInteger PageLabelFontSize = 17;

@interface RDImageViewerController ()
{
	NSOperationQueue *queue_;
	RDPagingView *pagingView_;
	UIView *currentPageHud_;
	UILabel *currentPageHudLabel_;
	BOOL statusBarHidden_;
}

@end

@implementation RDImageViewerController

NSString *const RDImageViewerControllerReuseIdentifierImage = @"RDImageViewerControllerReuseIdentifierImage";

static NSInteger kPreloadDefaultCount = 1;
static CGFloat kDefaultMaximumZoomScale = 2.5;

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

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[pagingView_ startRotation];
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
			[pagingView_ resizeWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame)) duration:duration];
		}
	}
	else {
		[pagingView_ resizeWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame)) duration:duration];
	}
	[pagingView_ endRotation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self reloadPageHud];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	[pagingView_ startRotation];
	UIUserInterfaceSizeClass sizeClass = self.traitCollection.verticalSizeClass;
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		if (self.traitCollection.verticalSizeClass != sizeClass) {
			NSTimeInterval duration = [context transitionDuration];
			[pagingView_ resizeWithFrame:CGRectMake(0, 0, size.width, size.height) duration:duration];
		}
	} completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		[pagingView_ endRotation];
	}];
}

- (instancetype)initWithNumberOfPages:(NSInteger)num direction:(RDPagingViewForwardDirection)direction
{
	self = [super init];
	if (self) {
		self.maximumZoomScale = kDefaultMaximumZoomScale;
		_landscapeMode = RDImageViewerControllerLandscapeModeAspectFit;
		pagingView_ = [[RDPagingView alloc] initWithFrame:self.view.bounds];
		pagingView_.backgroundColor = [UIColor blackColor];
		pagingView_.pagingDelegate = self;
		pagingView_.direction = direction;
		pagingView_.directionalLockEnabled = YES;
		pagingView_.tag = MainScrollView;
		pagingView_.showsHorizontalScrollIndicator = NO;
		pagingView_.showsVerticalScrollIndicator = NO;
		pagingView_.numberOfPages = num;
		UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setBarHiddenUsingTapGesture)];
		[pagingView_ addGestureRecognizer:gesture];

		queue_ = [NSOperationQueue new];
		self.preloadCount = kPreloadDefaultCount;
	}
	
	return self;
}

- (instancetype)initWithImageHandler:(UIImage *(^)(NSInteger pageIndex))imageHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction
{
	self = [self initWithNumberOfPages:pageCount direction:direction];
	if (self) {
		self.imageHandler = imageHandler;
	}
	
	return self;
}

- (instancetype)initWithViewHandler:(UIView *(^)(NSInteger pageIndex, UIView *reusedView))viewHandler reuseIdentifier:(NSString *(^)(NSInteger pageIndex))reuseIdentifierHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction
{
	self = [self initWithNumberOfPages:pageCount direction:direction];
	if (self) {
		self.viewHandler = viewHandler;
		self.reuseIdentifierHandler = reuseIdentifierHandler;
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	currentPageHud_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
	currentPageHud_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	currentPageHud_.backgroundColor = [UIColor blackColor];
	currentPageHud_.layer.cornerRadius = 10;
	currentPageHud_.frame = CGRectMake(self.view.center.x - CGRectGetWidth(currentPageHud_.frame) / 2, CGRectGetHeight(self.view.frame) - CGRectGetHeight(currentPageHud_.frame) - 50 * (self.toolbarItems.count > 0) - 10, CGRectGetWidth(currentPageHud_.frame), CGRectGetHeight(currentPageHud_.frame));
	currentPageHud_.alpha = 0;
	currentPageHud_.layer.borderColor = [UIColor whiteColor].CGColor;
	currentPageHud_.layer.borderWidth = 1;
	
	currentPageHudLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, PageLabelFontSize)];
	currentPageHudLabel_.backgroundColor = [UIColor clearColor];
	currentPageHudLabel_.font = [UIFont systemFontOfSize:PageLabelFontSize];
	currentPageHudLabel_.textColor = [UIColor whiteColor];
	currentPageHudLabel_.textAlignment = NSTextAlignmentCenter;
	currentPageHudLabel_.center = CGPointMake(CGRectGetWidth(currentPageHud_.frame) / 2, CGRectGetHeight(currentPageHud_.frame) / 2);
	currentPageHudLabel_.tag = CurrentPageLabel;
	[currentPageHud_ addSubview:currentPageHudLabel_];
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
	_pageSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 280, 20)];
	[_pageSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
	[_pageSlider addTarget:self action:@selector(sliderDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	_pageSlider.maximumTrackTintColor = pagingView_.direction == RDPagingViewDirectionLeft ? [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] : [UIColor whiteColor];
	_pageSlider.minimumTrackTintColor = pagingView_.direction == RDPagingViewDirectionLeft ? [UIColor whiteColor] : [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setBarHidden:NO animated:YES];
	[self setHudHidden:NO animated:animated];
	
	if (pagingView_.superview == nil) {
		[self.view addSubview:pagingView_];
		[pagingView_ scrollAtPage:pagingView_.currentPageIndex];
	}
	
	if (self.showSlider == YES) {
		_pageSlider.value = (CGFloat)pagingView_.currentPageIndex / pagingView_.numberOfPages;
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *sliderItem = [[UIBarButtonItem alloc] initWithCustomView:_pageSlider];
		self.toolbarItems = @[flexibleSpace, sliderItem, flexibleSpace];
		currentPageHud_.frame = CGRectMake(self.view.center.x - CGRectGetWidth(currentPageHud_.frame) / 2, CGRectGetHeight(self.view.frame) - CGRectGetHeight(currentPageHud_.frame) - 50 * (self.toolbarItems.count > 0) - 10, CGRectGetWidth(currentPageHud_.frame), CGRectGetHeight(currentPageHud_.frame));
	}
	if (self.showPageNumberHud == YES) {
		currentPageHudLabel_.text = [NSString stringWithFormat:@"%d/%ld", pagingView_.currentPageIndex, (long)pagingView_.numberOfPages];
		[self.view addSubview:currentPageHud_];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	pagingView_.pagingDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	pagingView_.pagingDelegate = nil;
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self setBarHidden:NO animated:NO];
}

- (NSInteger)pageIndex
{
	return pagingView_.currentPageIndex;
}

- (void)setPageIndex:(NSInteger)pageIndex
{
	self.pageSlider.value = (CGFloat)pageIndex / pagingView_.numberOfPages;
	
	[pagingView_ scrollAtPage:pageIndex];
}

#pragma mark -

- (void)setShowPageNumberHud:(BOOL)showPageNumberHud
{
	_showPageNumberHud = showPageNumberHud;
	if (showPageNumberHud == YES) {
		[self.view addSubview:currentPageHud_];
	}
	else {
		[currentPageHud_ removeFromSuperview];
	}
}

- (void)setShowSlider:(BOOL)showSlider
{
	_showSlider = showSlider;
	CGFloat toolBarPositionY = (self.toolbarItems.count > 0) ? CGRectGetMinY(self.navigationController.toolbar.frame) : CGRectGetHeight(self.view.frame);
	currentPageHud_.frame = CGRectMake(self.view.center.x - CGRectGetWidth(currentPageHud_.frame) / 2, toolBarPositionY - CGRectGetHeight(currentPageHud_.frame) - 10, CGRectGetWidth(currentPageHud_.frame), CGRectGetHeight(currentPageHud_.frame));
}

- (void)setPreloadCount:(NSUInteger)preloadCount
{
	pagingView_.preloadCount = preloadCount;
}

- (NSUInteger)preloadCount
{
	return pagingView_.preloadCount;
}

- (void)setPagingEnabled:(BOOL)paging
{
	pagingView_.pagingEnabled = paging;
}

- (BOOL)pagingEnabled
{
	return pagingView_.pagingEnabled;
}

#pragma mark -

- (void)hideBars
{
	[self setBarHidden:YES animated:YES];
}

- (void)setPageHudNumberWithPageIndex:(NSInteger)pageIndex
{
	currentPageHudLabel_.text = [NSString stringWithFormat:@"%ld/%ld", (long)pageIndex + 1, (long)pagingView_.numberOfPages];
}

- (void)reloadPageHud
{
	[self setPageHudNumberWithPageIndex:pagingView_.currentPageIndex];
}

- (void)setBarHiddenUsingTapGesture
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:self];
	[self setBarHidden:!statusBarHidden_ animated:YES];
}

- (void)setBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		if (self.toolbarItems.count > 0) {
			[self.navigationController setToolbarHidden:hidden animated:animated];
		}
		else {
			[self.navigationController setToolbarHidden:YES animated:animated];
		}
		[self.navigationController setNavigationBarHidden:hidden animated:animated];
		[self setHudHidden:hidden animated:animated];
	});
	[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	
	statusBarHidden_ = hidden;
}

- (void)setHudHidden:(BOOL)hidden animated:(BOOL)animated
{
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration * animated animations:^{
		CGFloat toolBarPositionY = (self.toolbarItems.count > 0) ? CGRectGetMinY(self.navigationController.toolbar.frame) : CGRectGetHeight(self.view.frame);
		currentPageHud_.frame = CGRectMake(self.view.center.x - CGRectGetWidth(currentPageHud_.frame) / 2, toolBarPositionY - CGRectGetHeight(currentPageHud_.frame) - 10, CGRectGetWidth(currentPageHud_.frame), CGRectGetHeight(currentPageHud_.frame));
		currentPageHud_.alpha = !hidden * 0.8;
	} completion:^(BOOL finished) {
	}];
}

- (void)sliderValueDidChange:(id)sender
{
	UISlider *slider = sender;
	
	CGFloat trueValue = pagingView_.direction == RDPagingViewDirectionRight ? slider.value : 1 - slider.value;
	CGFloat page = trueValue * (pagingView_.numberOfPages - 1);
	[pagingView_ scrollAtPage:page];
}

- (void)sliderDidTouchUpInside:(id)sender
{
	UISlider *slider = sender;
	CGFloat value = pagingView_.currentPageIndex / (CGFloat)(pagingView_.numberOfPages - 1);;
	CGFloat trueValue = pagingView_.direction == RDPagingViewDirectionRight ? value : 1 - value;
	[slider setValue:trueValue animated:YES];
}

- (RDImageScrollView *)imageScrollViewForIndex:(NSInteger)index
{
	RDImageScrollView *imageScrollView = (RDImageScrollView *)[pagingView_ dequeueViewWithReuseIdentifier:RDImageViewerControllerReuseIdentifierImage];
	if (imageScrollView == nil) {
		imageScrollView = [[RDImageScrollView alloc] initWithFrame:self.view.bounds];
		imageScrollView.maximumZoomScale = self.maximumZoomScale;
		[pagingView_.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			UIGestureRecognizer *gesture = obj;
			if ([gesture isMemberOfClass:[UITapGestureRecognizer class]]) {
				[imageScrollView addGestureRecognizerPriorityHigherThanZoomGestureRecogniser:gesture];
				*stop = YES;
			}
		}];
	}
	[imageScrollView setZoomScale:1.0];
	imageScrollView.image = nil;
	__weak RDImageScrollView *scrollView = imageScrollView;
	if (_imageHandler) {
		if (self.loadAsync) {
			[queue_ addOperationWithBlock:^{
				UIImage *image = _imageHandler(index);
				if (scrollView.indexOfPage == index) {
					dispatch_async(dispatch_get_main_queue(), ^{
						scrollView.image = image;
						[self adjustContentAspect:scrollView];
					});
				}
			}];
		}
		else {
			scrollView.image = _imageHandler(index);
			[self adjustContentAspect:scrollView];
		}
	}
	return imageScrollView;
}

- (UIView *)contentViewForIndex:(NSInteger)index
{
	UIView *view = [pagingView_ dequeueViewWithReuseIdentifier:self.reuseIdentifierHandler(index)];
	
	return self.viewHandler(index, view);
}

- (void)adjustContentAspect:(UIView *)view
{
	if ([view isKindOfClass:[RDImageScrollView class]]) {
		RDImageScrollView *v = (RDImageScrollView *)view;
		if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
			UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
			if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
				if (_landscapeMode == RDImageViewerControllerLandscapeModeAspectFit) {
					[v setImageSizeAspectFit];
				}
				else {
					[v setImageSizeDisplayFit];
					[v setContentOffset:CGPointMake(0, 0)];
				}
			}
			else {
				[v setImageSizeAspectFit];
			}
		}
		else {
			if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
				if (_landscapeMode == RDImageViewerControllerLandscapeModeAspectFit) {
					[v setImageSizeAspectFit];
				}
				else {
					[v setImageSizeDisplayFit];
					[v setContentOffset:CGPointMake(0, 0)];
				}
			}
			else {
				[v setImageSizeAspectFit];
			}
		}
	}
}

#pragma mark - RDPagingViewDelegate

- (UIView *)pagingView:(RDPagingView *)pageView viewForIndex:(NSInteger)index
{
	UIView *view = nil;
	if (self.reuseIdentifierHandler) {
		NSString *reuseIdentifier = self.reuseIdentifierHandler(index);
		if ([reuseIdentifier isEqualToString:RDImageViewerControllerReuseIdentifierImage]) {
			view = [self imageScrollViewForIndex:index];
		}
		else {
			view = [self contentViewForIndex:index];
		}
	}
	else {
		if (self.imageHandler) {
			view = [self imageScrollViewForIndex:index];
		}
		else {
			view = [self contentViewForIndex:index];
		}
	}
	
	return view;
}

- (NSString *)paginView:(RDPagingView *)paginView reuseIdentifierForIndex:(NSInteger)index
{
	NSString *identifier = RDImageViewerControllerReuseIdentifierImage;
	if (self.reuseIdentifierHandler) {
		identifier = self.reuseIdentifierHandler(index);
	}
	
	return identifier;
}

- (void)pagingView:(RDPagingView *)pagingView willChangeViewSize:(CGSize)size duration:(NSTimeInterval)duration visibleViews:(NSArray *)views
{
	[views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		__block RDImageScrollView *v = obj;
		if (v.indexOfPage != pagingView.currentPageIndex) {
			v.hidden = YES;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				v.hidden = NO;
			});
		}
		[UIView animateWithDuration:duration animations:^{
			v.frame = CGRectMake((pagingView.direction == RDPagingViewDirectionRight ? v.indexOfPage : (pagingView.numberOfPages - v.indexOfPage - 1)) * size.width, 0, size.width, size.height);
			[self adjustContentAspect:v];
  		}];
	}];
}

- (void)pagingView:(RDPagingView *)pagingView didScrollToPosition:(CGFloat)position
{
	UISlider *slider = (UISlider *)[self.toolbarItems[1] customView];
	if (slider.state == UIControlStateNormal) {
		[slider setValue:position / (pagingView.numberOfPages - 1) animated:NO];
	}
	[self reloadPageHud];
}

- (void)pagingViewDidEndDecelerating:(RDPagingView *)pagingView
{
	CGFloat page = pagingView_.contentOffset.x / CGRectGetWidth(pagingView_.frame);
	[pagingView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[UIScrollView class]]) {
			UIScrollView *pageView = (UIScrollView *)obj;
			if (page != CGRectGetMinX(pageView.frame) / CGRectGetWidth(pagingView_.frame)) {
				pageView.zoomScale = 1.0;
			}			
		}
	}];
}

@end
