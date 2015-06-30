//
//  RDImageScrollView.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/28/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RDImageScrollView.h"

static CGSize kZoomRect = {100, 100};

@implementation RDImageScrollView
{
	UIImageView *imageView_;
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
		
		imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		imageView_.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
		imageView_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		imageView_.layer.borderColor = [UIColor blackColor].CGColor;
		imageView_.layer.borderWidth = 0.5;

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
	[self adjustContentAspect];
}

- (void)setMode:(RDImageScrollViewResizeMode)mode
{
	_mode = mode;
	[self adjustContentAspect];
}

- (void)setBorderColor:(UIColor *)borderColor
{
	imageView_.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor
{
	return [UIColor colorWithCGColor:imageView_.layer.borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
	imageView_.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth
{
	return imageView_.layer.borderWidth;
}

#pragma mark -

- (void)adjustContentAspect
{
	switch (_mode) {
		case RDImageScrollViewResizeModeAspectFit:
			[self setImageSizeAsAspectFit];
			break;
		case RDImageScrollViewResizeModeDisplayFit:
			[self setImageSizeAsDisplayFit];
			break;
		default:
			break;
	}
	[self setContentOffset:CGPointMake(0, 0)];
}

- (void)setImageSizeAsAspectFit
{
	[imageView_ sizeToFit];
	CGFloat height = CGRectGetHeight(self.frame);
	CGFloat width = CGRectGetWidth(self.frame);
	CGFloat scale = 1;
	
	BOOL fitWidth = NO;
	if (width < height) {
		scale = width / MAX(CGRectGetWidth(imageView_.frame), 1);
		fitWidth = YES;
	}
	else {
		scale = height / MAX(CGRectGetHeight(imageView_.frame), 1);
	}
	imageView_.frame = CGRectMake(0, 0, CGRectGetWidth(imageView_.frame) * scale , CGRectGetHeight(imageView_.frame) * scale);
	
	CGFloat imageEdgeLength = fitWidth ? CGRectGetHeight(imageView_.frame) : CGRectGetWidth(imageView_.frame);
	CGFloat viewEdgeLength = fitWidth ? height : width;
	
	if (imageEdgeLength > viewEdgeLength) {
		scale = viewEdgeLength / MAX(imageEdgeLength, 1);
		imageView_.frame = CGRectMake(0, 0, CGRectGetWidth(imageView_.frame) * scale , CGRectGetHeight(imageView_.frame) * scale);
	}
	
	imageView_.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
	self.contentSize = imageView_.frame.size;
	[self setZoomScale:1.0];
}

- (void)setImageSizeAsDisplayFit
{
	[imageView_ sizeToFit];
	CGFloat height = CGRectGetHeight(self.frame);
	CGFloat width = CGRectGetWidth(self.frame);
	if (height > width) {
		// when devicec orientation is portrait
		[self setImageSizeAsAspectFit];
	}
	else {
		CGFloat scale = width > height ? width / MAX(CGRectGetWidth(imageView_.frame), 1) : height / MAX(CGRectGetHeight(imageView_.frame), 1);
		imageView_.frame = CGRectMake(0, 0, CGRectGetWidth(imageView_.frame) * scale , CGRectGetHeight(imageView_.frame) * scale);
		self.contentSize = imageView_.frame.size;
		[self setZoomScale:1.0];
	}
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
