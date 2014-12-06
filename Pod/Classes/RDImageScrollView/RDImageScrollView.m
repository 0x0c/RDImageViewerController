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

- (CGSize)rd_scaledSize:(CGSize)size
{
	CGSize newSize = CGSizeZero;
	CGFloat scale = size.width / self.size.width;
	newSize = CGSizeMake(self.size.width * scale, self.size.height * scale);
	
	return newSize;
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
	UIActivityIndicatorView *indicator_;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.mode = RDImageScrollViewResizeModeAspectFit;
		
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
		
		indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		indicator_.center = imageView_.center;
		indicator_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
		[indicator_ startAnimating];
		[self addSubview:indicator_];
		
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

- (void)setImage:(UIImage *)image
{
	imageView_.image = image;
	if (image == nil) {
		[indicator_ startAnimating];
	}
	else {
		[indicator_ stopAnimating];
	}
}

- (void)setMode:(RDImageScrollViewResizeMode)mode
{
	_mode = mode;
	switch (_mode) {
		case RDImageScrollViewResizeModeAspectFit:
			[self setImageSizeAspectFit];
			break;
		case RDImageScrollViewResizeModeDisplayFit:
			[self setImageSizeDisplayFit];
			break;
	default:
			break;
	}
}

#pragma mark -

- (void)setImageFrame:(CGRect)frame
{
	imageView_.frame = frame;
}

- (void)setImageSizeAspectFit
{
	CGRect frame = imageView_.frame;
	CGSize size = [imageView_.image rd_scaledSize:frame.size];
	CGFloat scale = 0;
	if (size.width > 0 && size.height > 0) {
		scale = size.height > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) / size.height : CGRectGetWidth(self.frame) / size.width;
	}
	imageView_.bounds = CGRectMake(0, 0, size.width * scale, size.height * scale);
	imageView_.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
	self.contentSize = CGSizeMake(size.width * scale, size.height * scale);
	[self setZoomScale:1.0];
}

- (void)setImageSizeDisplayFit
{
	CGRect frame = imageView_.frame;
	CGSize size = [imageView_.image rd_scaledSize:frame.size];
	CGFloat scale = 0;
	if (size.width > 0 && size.height > 0) {
		scale = size.width < CGRectGetWidth(self.frame) ? CGRectGetHeight(self.frame) / size.height : CGRectGetWidth(self.frame) / size.width;
	}
	imageView_.frame = CGRectMake(0, 0, size.width * scale, size.height * scale);
	self.contentSize = CGSizeMake(size.width * scale, size.height * scale);
	[self setZoomScale:1.0];
}

- (void)setImageSize:(CGSize)size
{
	imageView_.bounds = CGRectMake(0, 0, size.width, size.height);
}

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

@end
