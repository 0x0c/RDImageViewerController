//
//  RDImageViewerController.m
//
//  Created by Akira Matsuda on 2014/03/20.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "RDImageViewerController.h"
#import <QuartzCore/QuartzCore.h>
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
	RDImageViewerControllerDelegateFlag delegateFlag;
	BOOL statusBarHidden_;
}

@property (nonatomic, strong) RDPagingView *pagingView;
@property (nonatomic, strong) UIView *currentPageHud;
@property (nonatomic, strong) NSOperationQueue *asynchronousImageHandlerQueue;
@property (nonatomic, readonly) UISlider *pageSlider;
@property (nonatomic, strong) NSMutableArray *remoteImageRequestArray;

@end

@implementation RDImageViewerController

NSString *const RDImageViewerControllerReuseIdentifierImage = @"RDImageViewerControllerReuseIdentifierImage";
NSString *const RDImageViewerControllerReuseIdentifierRemoteImage = @"RDImageViewerControllerReuseIdentifierRemoteImage";

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

- (instancetype)initWithNumberOfPages:(NSInteger)num direction:(RDPagingViewForwardDirection)direction
{
	self = [super init];
	if (self) {
		self.maximumZoomScale = kDefaultMaximumZoomScale;
		self.landscapeMode = RDImageScrollViewResizeModeAspectFit;
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
		self.asynchronousImageHandlerQueue = [NSOperationQueue new];
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

- (instancetype)initWithRemoteImageHandler:(NSURLRequest *(^)(NSInteger pageIndex))remoteImageHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction
{
	self = [self initWithNumberOfPages:pageCount direction:direction];
	if (self) {
		self.remoteImageHandler = remoteImageHandler;
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
	self.currentPageHud = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
	self.currentPageHud.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	self.currentPageHud.backgroundColor = [UIColor blackColor];
	self.currentPageHud.layer.cornerRadius = 10;
	self.currentPageHud.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.currentPageHud.frame) / 2, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.currentPageHud.frame) - 50 * (self.toolbarItems.count > 0) - 10, CGRectGetWidth(self.currentPageHud.frame), CGRectGetHeight(self.currentPageHud.frame));
	self.currentPageHud.alpha = 0;
	self.currentPageHud.layer.borderColor = [UIColor whiteColor].CGColor;
	self.currentPageHud.layer.borderWidth = 1;
	
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
	
	if (self.showSlider == YES && _pageSlider == nil) {
		_pageSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 30, 31)];
		_pageSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_pageSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
		[_pageSlider addTarget:self action:@selector(sliderDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *sliderItem = [[UIBarButtonItem alloc] initWithCustomView:_pageSlider];
		self.toolbarItems = @[sliderItem];
		if (self.pagingView.direction == RDPagingViewDirectionRight) {
			_pageSlider.value = (CGFloat)self.pagingView.currentPageIndex / (self.pagingView.numberOfPages - 1);
		}
		else {
			_pageSlider.value = 1 - (CGFloat)self.pagingView.currentPageIndex / (self.pagingView.numberOfPages - 1);
		}
		self.currentPageHud.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.currentPageHud.frame) / 2, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.currentPageHud.frame) - 50 * (self.toolbarItems.count > 0) - 10, CGRectGetWidth(self.currentPageHud.frame), CGRectGetHeight(self.currentPageHud.frame));
		[self applySliderTintColor];
	}
	if (self.showPageNumberHud == YES) {
		[self setPageHudNumberWithPageIndex:self.pagingView.currentPageIndex];
		[self.view addSubview:self.currentPageHud];
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
	delegateFlag.willChangeIndexTo = [_delegate respondsToSelector:@selector(imageViewerController:willChangeIndexTo:)];
}

- (NSInteger)currentPageIndex
{
	return self.pagingView.currentPageIndex;
}

- (void)setCurrentPageIndex:(NSInteger)pageIndex
{
	if (self.pagingView.direction == RDPagingViewDirectionRight) {
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
	_pageSlider.maximumTrackTintColor = self.pagingView.direction == RDPagingViewDirectionLeft ? maximumTintColor : minimumTintColor;
	_pageSlider.minimumTrackTintColor = self.pagingView.direction == RDPagingViewDirectionLeft ? minimumTintColor : maximumTintColor;
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

- (void)setRemoteImageHandler:(NSURLRequest *(^)(NSInteger pageIndex))remoteImageHandler completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))completionHandler decodeHandler:(UIImage *(^)(NSData *data, NSInteger pageIndex))decodeHandler
{
	self.remoteImageHandler = remoteImageHandler;
	self.requestCompletionHandler = completionHandler;
	self.imageDecodeHandler = decodeHandler;
}

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
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		if (self.toolbarItems.count > 0 || self.showSlider) {
			[self.navigationController setToolbarHidden:hidden animated:animated];
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
		self.currentPageHud.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.currentPageHud.frame) / 2, toolBarPositionY - CGRectGetHeight(self.currentPageHud.frame) - 10, CGRectGetWidth(self.currentPageHud.frame), CGRectGetHeight(self.currentPageHud.frame));
		self.currentPageHud.alpha = !hidden * 0.8;
	} completion:^(BOOL finished) {
	}];
}

- (void)cancelAutoBarHidden
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:self];
}

- (void)sliderValueDidChange:(id)sender
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:self];
	UISlider *slider = sender;
	CGFloat trueValue = self.pagingView.direction == RDPagingViewDirectionRight ? slider.value : 1 - slider.value;
	CGFloat page = trueValue * (self.pagingView.numberOfPages - 1);
	[self.pagingView scrollAtPage:page];
}

- (void)sliderDidTouchUpInside:(id)sender
{
	UISlider *slider = sender;
	CGFloat value = self.pagingView.currentPageIndex / (CGFloat)(self.pagingView.numberOfPages - 1);;
	CGFloat trueValue = self.pagingView.direction == RDPagingViewDirectionRight ? value : 1 - value;
	[slider setValue:trueValue animated:YES];
}

- (RDImageScrollView *)imageScrollViewForIndex:(NSInteger)index reuseIdentifier:(NSString *)identifier
{
	RDImageScrollView *imageScrollView = (RDImageScrollView *)[self.pagingView dequeueViewWithReuseIdentifier:identifier];
	if (imageScrollView == nil) {
		imageScrollView = [[RDImageScrollView alloc] initWithFrame:self.view.bounds];
		imageScrollView.maximumZoomScale = self.maximumZoomScale;
		[self.pagingView.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			UIGestureRecognizer *gesture = obj;
			if ([gesture isMemberOfClass:[UITapGestureRecognizer class]]) {
				[imageScrollView addGestureRecognizerPriorityHigherThanZoomGestureRecogniser:gesture];
				*stop = YES;
			}
		}];
	}
	imageScrollView.mode = self.landscapeMode;
	[imageScrollView setZoomScale:1.0];
	imageScrollView.image = nil;
	
	[self loadImageAtIndex:index imageScrollView:imageScrollView reuseIdentifier:identifier];
	
	return imageScrollView;
}

- (void)loadImageAtIndex:(NSInteger)index imageScrollView:(RDImageScrollView *)imageScrollView reuseIdentifier:(NSString *)identifier
{
	imageScrollView.image = nil;
	__weak typeof(self) bself = self;
	__weak RDImageScrollView *bimagescrollView = imageScrollView;
	if ([identifier isEqualToString:RDImageViewerControllerReuseIdentifierImage] && self.imageHandler) {
		if (self.loadAsync) {
			NSBlockOperation *op = [[NSBlockOperation alloc] init];
			[op addExecutionBlock:^{
				UIImage *image = self.imageHandler(index);
				if (bimagescrollView.indexOfPage == index) {
					dispatch_async(dispatch_get_main_queue(), ^{
						bimagescrollView.image = image;
						if (bself.imageViewConfigurationHandler) {
							bself.imageViewConfigurationHandler(index, bimagescrollView);
						}
					});
				}
			}];
			[self.asynchronousImageHandlerQueue addOperation:op];
		}
		else {
			bimagescrollView.image = _imageHandler(index);
		}
	}
	else if ([identifier isEqualToString:RDImageViewerControllerReuseIdentifierRemoteImage] && self.remoteImageHandler) {
		NSInteger waitingOperationCount = self.remoteImageRequestArray.count - self.preloadCount;
		if (waitingOperationCount > 0) {
			for (NSInteger i = 0; i < waitingOperationCount; i++) {
				rd_M2DURLConnectionOperation *op = self.remoteImageRequestArray[i];
				[op stop];
				[self.remoteImageRequestArray removeObject:op];
			}
		}
		__weak typeof(self) bself = self;
		NSURLRequest *request = self.remoteImageHandler(index);
		rd_M2DURLConnectionOperation *op = [[rd_M2DURLConnectionOperation alloc] initWithRequest:request];
		[self.remoteImageRequestArray addObject:op];
		__weak typeof(op) bop = op;
		__weak NSMutableArray *bremoteImageRequestArray = self.remoteImageRequestArray;
		[op sendRequestWithCompleteBlock:^(NSURLResponse *response, NSData *data, NSError *error) {
			if (bself.requestCompletionHandler) {
				bself.requestCompletionHandler(response, data, error);
			}
			
			UIImage *image = nil;
			if (bself.imageDecodeHandler) {
				image = bself.imageDecodeHandler(data, index);
			}
			else {
				image = [[UIImage alloc] initWithData:data];
			}
			if (bimagescrollView.indexOfPage == index) {
				dispatch_async(dispatch_get_main_queue(), ^{
					bimagescrollView.image = image;
					if (bself.imageViewConfigurationHandler) {
						bself.imageViewConfigurationHandler(index, bimagescrollView);
					}
				});
			}
			
			[bremoteImageRequestArray removeObject:bop];
		}];
	}
	[bimagescrollView adjustContentAspect];
}

- (UIView *)contentViewForIndex:(NSInteger)index
{
	UIView *view = [self.pagingView dequeueViewWithReuseIdentifier:self.reuseIdentifierHandler(index)];
	
	return self.viewHandler(index, view);
}

- (void)reloadViewAtIndex:(NSInteger)index
{
	UIView *view = [self.pagingView viewForIndex:index];
	if (self.reuseIdentifierHandler) {
		NSString *reuseIdentifier = self.reuseIdentifierHandler(index);
		if ([reuseIdentifier isEqualToString:RDImageViewerControllerReuseIdentifierImage] || [reuseIdentifier isEqualToString:RDImageViewerControllerReuseIdentifierRemoteImage]) {
			[self loadImageAtIndex:index imageScrollView:(RDImageScrollView *)view reuseIdentifier:reuseIdentifier];
		}
	}
	else {
		NSString *reuseIdentifier = nil;
		if (self.imageHandler) {
			reuseIdentifier = RDImageViewerControllerReuseIdentifierImage;
		}
		else if (self.remoteImageHandler) {
			reuseIdentifier = RDImageViewerControllerReuseIdentifierRemoteImage;
		}
		
		if (reuseIdentifier != nil) {
			[self loadImageAtIndex:index imageScrollView:(RDImageScrollView *)view reuseIdentifier:reuseIdentifier];
		}
		else {
			self.reloadViewHandler(index, view);
		}
	}
}

#pragma mark - RDPagingViewDelegate

- (void)pagingView:(RDPagingView *)pagingView willChangeIndexTo:(NSInteger)index
{
	if (delegateFlag.willChangeIndexTo) {
		[self.delegate imageViewerController:self willChangeIndexTo:index];
	}
}

- (UIView *)pagingView:(RDPagingView *)pageView viewForIndex:(NSInteger)index
{
	UIView *view = nil;
	if (self.reuseIdentifierHandler) {
		NSString *reuseIdentifier = self.reuseIdentifierHandler(index);
		if ([reuseIdentifier isEqualToString:RDImageViewerControllerReuseIdentifierImage] || [reuseIdentifier isEqualToString:RDImageViewerControllerReuseIdentifierRemoteImage]) {
			view = [self imageScrollViewForIndex:index reuseIdentifier:reuseIdentifier];
		}
		else {
			view = [self contentViewForIndex:index];
		}
	}
	else {
		if (self.imageHandler) {
			view = [self imageScrollViewForIndex:index reuseIdentifier:RDImageViewerControllerReuseIdentifierImage];
		}
		else if (self.remoteImageHandler) {
			view = [self imageScrollViewForIndex:index reuseIdentifier:RDImageViewerControllerReuseIdentifierRemoteImage];
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
	[views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
		if (view.indexOfPage != pagingView.currentPageIndex) {
			view.hidden = YES;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				view.hidden = NO;
			});
		}
		view.frame = CGRectMake((pagingView.direction == RDPagingViewDirectionRight ? view.indexOfPage : (pagingView.numberOfPages - view.indexOfPage - 1)) * size.width, 0, size.width, size.height);
		if ([view isKindOfClass:[UIScrollView class]]) {
			[(UIScrollView *)view setZoomScale:1.0];
			if ([view isKindOfClass:[RDImageScrollView class]]) {
				[(RDImageScrollView *)view adjustContentAspect];
			}
		}
	}];
}

- (void)pagingView:(RDPagingView *)pagingView didScrollToPosition:(CGFloat)position
{
	UISlider *slider = _pageSlider;
	if (slider.state == UIControlStateNormal) {
		[slider setValue:position / (pagingView.numberOfPages - 1) animated:NO];
	}
	[self reloadPageHud];
}

- (void)pagingViewDidEndDecelerating:(RDPagingView *)pagingView
{
	CGFloat page = self.pagingView.contentOffset.x / CGRectGetWidth(self.pagingView.frame);
	[pagingView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[UIScrollView class]]) {
			UIScrollView *pageView = (UIScrollView *)obj;
			if (page != CGRectGetMinX(pageView.frame) / CGRectGetWidth(self.pagingView.frame)) {
				pageView.zoomScale = 1.0;
			}
		}
	}];
}

@end
