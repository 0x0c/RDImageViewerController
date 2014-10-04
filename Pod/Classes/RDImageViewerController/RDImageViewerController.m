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
	UIImage *(^imageHandler_)(NSInteger pageIndex);
	void (^asyncImageHandler_)(RDImageScrollView *imageView, NSInteger pageIndex);
}

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
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
		if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
			if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
				[pagingView_ resizeWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) duration:duration];
			}
			else {
				[pagingView_ resizeWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame)) duration:duration];
			}
		}
		else {
			[pagingView_ resizeWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame)) duration:duration];
		}
	}
	[pagingView_ endRotation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self reloadPageHud];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[pagingView_ startRotation];
	[super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
	[coordinator animateAlongsideTransition: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
		UIViewController *fromViewController = [context viewControllerForKey: UITransitionContextFromViewControllerKey];
		UIInterfaceOrientation toInterfaceOrientation = fromViewController.interfaceOrientation;
		NSTimeInterval duration = [context transitionDuration];
		if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
			if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
				[pagingView_ resizeWithFrame:CGRectMake(0, 0, size.width, size.height) duration:duration];
			}
			else {
				[pagingView_ resizeWithFrame:CGRectMake(0, 0, size.height, size.width) duration:duration];
			}
		}
		else {
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
		imageHandler_ = [imageHandler copy];
	}
	
	return self;
}

- (instancetype)initWithAsynchronousImageHandler:(void (^)(RDImageScrollView *imageView, NSInteger pageIndex))asyncHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction
{
	self = [self initWithNumberOfPages:pageCount direction:direction];
	if (self) {
		asyncImageHandler_ = [asyncHandler copy];
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setBarHidden:NO animated:YES];
	
	if (currentPageHud_ == nil) {
		currentPageHud_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
		currentPageHud_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
		currentPageHud_.backgroundColor = [UIColor blackColor];
		currentPageHud_.layer.cornerRadius = 10;
		currentPageHud_.frame = CGRectMake(self.view.center.x - CGRectGetWidth(currentPageHud_.frame) / 2, CGRectGetHeight(self.view.frame) - CGRectGetHeight(currentPageHud_.frame) - 50, CGRectGetWidth(currentPageHud_.frame), CGRectGetHeight(currentPageHud_.frame));
		currentPageHud_.alpha = 0;
		currentPageHud_.layer.borderColor = [UIColor whiteColor].CGColor;
		currentPageHud_.layer.borderWidth = 1;
		
		currentPageHudLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, PageLabelFontSize)];
		currentPageHudLabel_.backgroundColor = [UIColor clearColor];
		currentPageHudLabel_.font = [UIFont systemFontOfSize:PageLabelFontSize];
		currentPageHudLabel_.textColor = [UIColor whiteColor];
		currentPageHudLabel_.textAlignment = NSTextAlignmentCenter;
		currentPageHudLabel_.text = [NSString stringWithFormat:@"%d/%ld", 1, (long)pagingView_.numberOfPages];
		currentPageHudLabel_.center = CGPointMake(CGRectGetWidth(currentPageHud_.frame) / 2, CGRectGetHeight(currentPageHud_.frame) / 2);
		currentPageHudLabel_.tag = CurrentPageLabel;
		[currentPageHud_ addSubview:currentPageHudLabel_];
		
		[self.view addSubview:pagingView_];
		[self.view addSubview:currentPageHud_];
		
		UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.8, 20)];
		slider.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
		[slider addTarget:self action:@selector(sliderDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		slider.maximumTrackTintColor = pagingView_.direction == RDPagingViewDirectionLeft ? [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0] : [UIColor whiteColor];
		slider.minimumTrackTintColor = pagingView_.direction == RDPagingViewDirectionLeft ? [UIColor whiteColor] : [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
		if (pagingView_.direction == RDPagingViewDirectionRight) {
			slider.value = 0;
		}
		else {
			slider.value = 1.0;
		}
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *sliderItem = [[UIBarButtonItem alloc] initWithCustomView:slider];
		self.toolbarItems = @[flexibleSpace, sliderItem, flexibleSpace];
	}
	
	[pagingView_ scrollAtPage:0];
	
	[self setHudHidden:NO animated:animated];
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
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self setBarHidden:NO animated:NO];
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
	statusBarHidden_ = hidden;
	[self.navigationController setNavigationBarHidden:hidden animated:animated];
	[self.navigationController setToolbarHidden:hidden animated:animated];
	[self setHudHidden:hidden animated:animated];
}

- (void)setHudHidden:(BOOL)hidden animated:(BOOL)animated
{
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration * animated animations:^{
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

#pragma mark - RDPagingViewDelegate

- (UIView *)pagingView:(RDPagingView *)pageView viewForIndex:(NSInteger)index
{
	RDImageScrollView *imageScrollView = (RDImageScrollView *)[pagingView_ dequeueView];
	if (imageScrollView == nil) {
		imageScrollView = [[RDImageScrollView alloc] initWithFrame:self.view.bounds];
		imageScrollView.maximumZoomScale = 2.5;
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
	if (imageHandler_) {
		scrollView.image = imageHandler_(index);
	}
	else {
		__weak void (^asyncImageHandler)(RDImageScrollView *imageView, NSInteger pageIndex) = asyncImageHandler_;
		[queue_ addOperationWithBlock:^{
			asyncImageHandler(scrollView, index);
		}];
	}
	
	return imageScrollView;
}

- (void)pagingView:(RDPagingView *)pagingView willChangeViewSize:(CGSize)size duration:(NSTimeInterval)duration visibleViews:(NSArray *)views
{
	[views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		__block RDImageScrollView<RDPagingViewProtocol> *v = obj;
		if (v.indexOfPage != pagingView.currentPageIndex) {
			v.hidden = YES;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				v.hidden = NO;
			});
		}
		[UIView animateWithDuration:duration animations:^{
			v.frame = CGRectMake((pagingView.direction == RDPagingViewDirectionRight ? v.indexOfPage : (pagingView.numberOfPages - v.indexOfPage - 1)) * size.width, 0, size.width, size.height);
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
		UIScrollView *pageView = (UIScrollView *)obj;
		if (page != CGRectGetMinX(pageView.frame) / CGRectGetWidth(pagingView_.frame)) {
			pageView.zoomScale = 1.0;
		}
	}];
}

@end
