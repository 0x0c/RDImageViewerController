//
//  RDImageScrollView.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/28/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RDImageScrollView.h"

static CGSize kZoomRect = {100, 100};

@implementation UIImage (RDImageView)

- (CGSize)rd_displayScaledSize
{
	CGFloat scale = [UIScreen mainScreen].bounds.size.width / self.size.width;
	CGSize size = CGSizeMake(self.size.width * scale, self.size.height * scale);
	
	return size;
}

@end

@interface RDImageView : UIImageView

@property (nonatomic, readonly) BOOL alreadyLoaded;

- (instancetype)initWithFrame:(CGRect)frame filename:(NSString *)filename;

@end

@interface RDImageView ()

@property (nonatomic, strong) NSString *imageName;

@end

@implementation RDImageView

- (instancetype)initWithFrame:(CGRect)frame filename:(NSString *)filename
{
	self = [super initWithFrame:frame];
	if (self) {
		self.imageName = filename;
	}
	
	return self;
}

- (void)setImage:(UIImage *)image
{
	_alreadyLoaded = YES;
	[super setImage:image];
}

- (void)drawRect:(CGRect)rect
{
	if (self.image == nil) {
		[self loadImage];
	}
	
	[super drawRect:rect];
}

#pragma mark -

- (void)setImageWithFilename:(NSString *)filename
{
	_alreadyLoaded = NO;
	self.imageName = filename;
	self.image = nil;
}

- (void)loadImage
{
	if (_alreadyLoaded == NO) {
		_alreadyLoaded = YES;
		self.image = [UIImage imageNamed:self.imageName];
	}
}

@end

@implementation RDImageScrollView
{
	RDImageView *imageView_;
	UITapGestureRecognizer *zoomGesture_;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		imageView_ = [[RDImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		imageView_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		imageView_.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
		imageView_.layer.borderColor = [UIColor blackColor].CGColor;
		imageView_.layer.borderWidth = 1.0;
		imageView_.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:imageView_];
		
		zoomGesture_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomeImageView:)];
		zoomGesture_.numberOfTapsRequired = 2;
		zoomGesture_.numberOfTouchesRequired = 1;
		[self addGestureRecognizer:zoomGesture_];
	}
	
	return self;
}

- (UIImage *)image
{
	return imageView_.image;
}

//- (void)setFrame:(CGRect)frame
//{
//	[super setFrame:frame];
//	CGSize size = [imageView_.image rd_displayScaledSize];
//	CGFloat scale = size.height > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) / size.height : CGRectGetWidth(self.frame) / size.width;
//	imageView_.bounds = CGRectMake(0, 0, size.width * scale, size.height * scale);
//	self.contentSize = CGSizeMake(size.width * scale, size.height * scale);
//	[self setZoomScale:1.0];
//}

- (void)setImage:(UIImage *)image
{
	imageView_.image = image;
//	CGSize size = [imageView_.image rd_displayScaledSize];
//	imageView_.bounds = CGRectMake(0, 0, size.width, size.height);
}

- (void)setImageView:(RDImageView *)imageView
{
	imageView_ = imageView;
//	CGSize size = [imageView_.image rd_displayScaledSize];
//	imageView_.bounds = CGRectMake(0, 0, size.width, size.height);
	[self addSubview:imageView];
}

#pragma mark -

- (void)zoomeImageView:(UIGestureRecognizer *)gesture
{
	UIScrollView *scrollView = (UIScrollView *)gesture.view;
	if (scrollView.zoomScale > scrollView.minimumZoomScale) {
		[scrollView setZoomScale:1 animated:YES];
	}
	else {
		CGPoint position = [gesture locationInView:scrollView];
		[scrollView zoomToRect:CGRectMake(position.x - kZoomRect.width / 2, position.y - kZoomRect.height / 2, kZoomRect.width, kZoomRect.height) animated:YES];
	}
}

- (void)addGestureRecognizerPriorityHigherThanZoomGestureRecogniser:(UIGestureRecognizer *)gesture
{
	[gesture requireGestureRecognizerToFail:zoomGesture_];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imageView_;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	UIView *subView = [scrollView.subviews objectAtIndex:0];
	CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
	CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
	subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - RDPagingViewProtocol

- (NSInteger)indexOfPage
{
	return self.tag - RDSubViewTagOffset;
}

@end
