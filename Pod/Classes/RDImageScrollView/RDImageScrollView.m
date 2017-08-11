//
//  RDImageScrollView.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/28/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RDImageScrollView.h"

static CGSize kZoomRect = {100, 100};

@interface RDImageScrollView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITapGestureRecognizer *zoomGesture;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation RDImageScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.mode = RDImageScrollViewResizeModeAspectFit;
		
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		
		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		self.imageView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
		self.imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		self.imageView.layer.borderColor = [UIColor blackColor].CGColor;
		self.imageView.layer.borderWidth = 0.5;

		[self addSubview:self.imageView];
		
		self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		self.indicator.center = self.imageView.center;
		self.indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self.indicator startAnimating];
		[self addSubview:self.indicator];
		
		self.zoomGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomeImageView:)];
		self.zoomGesture.numberOfTapsRequired = 2;
		self.zoomGesture.numberOfTouchesRequired = 1;
		[self addGestureRecognizer:self.zoomGesture];
	}
	
	return self;
}

- (UIImage *)image
{
	return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
	self.imageView.image = image;
	if (image == nil) {
		[self.indicator startAnimating];
	}
	else {
		[self.indicator stopAnimating];
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
	self.imageView.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor
{
	return [UIColor colorWithCGColor:self.imageView.layer.borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
	self.imageView.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth
{
	return self.imageView.layer.borderWidth;
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
	[self.imageView sizeToFit];
	CGFloat height = CGRectGetHeight(self.frame);
	CGFloat width = CGRectGetWidth(self.frame);
	CGFloat scale = 1;
	
	BOOL fitWidth = NO;
	if (width < height) {
		scale = width / MAX(CGRectGetWidth(self.imageView.frame), 1);
		fitWidth = YES;
	}
	else {
		scale = height / MAX(CGRectGetHeight(self.imageView.frame), 1);
	}
	self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.imageView.frame) * scale , CGRectGetHeight(self.imageView.frame) * scale);
	
	CGFloat imageEdgeLength = fitWidth ? CGRectGetHeight(self.imageView.frame) : CGRectGetWidth(self.imageView.frame);
	CGFloat viewEdgeLength = fitWidth ? height : width;
	
	if (imageEdgeLength > viewEdgeLength) {
		scale = viewEdgeLength / MAX(imageEdgeLength, 1);
		self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.imageView.frame) * scale , CGRectGetHeight(self.imageView.frame) * scale);
	}
	
	self.imageView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
	self.contentSize = self.imageView.frame.size;
	[self setZoomScale:1.0];
}

- (void)setImageSizeAsDisplayFit
{
	[self.imageView sizeToFit];
	CGFloat height = CGRectGetHeight(self.frame);
	CGFloat width = CGRectGetWidth(self.frame);
	if (height > width) {
		// when devicec orientation is portrait
		[self setImageSizeAsAspectFit];
	}
	else {
		CGFloat scale = width > height ? width / MAX(CGRectGetWidth(self.imageView.frame), 1) : height / MAX(CGRectGetHeight(self.imageView.frame), 1);
		self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.imageView.frame) * scale , CGRectGetHeight(self.imageView.frame) * scale);
		self.contentSize = self.imageView.frame.size;
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
	[gesture requireGestureRecognizerToFail:self.zoomGesture];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	UIView *subView = [scrollView.subviews objectAtIndex:0];
	CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
	CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
	subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end
