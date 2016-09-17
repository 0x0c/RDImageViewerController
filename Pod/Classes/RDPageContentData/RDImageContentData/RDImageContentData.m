//
//  RDImageContentData.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/18/16.
//  Copyright © 2016 Akira Matsuda. All rights reserved.
//

#import "RDImageContentData.h"

static CGFloat kDefaultMaximumZoomScale = 2.5;

@interface RDImageContentData ()

@property (nonatomic, strong) NSString *imageName;

@end

@implementation RDImageContentData

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.maximumZoomScale = kDefaultMaximumZoomScale;
		self.landscapeMode = RDImageScrollViewResizeModeAspectFit;
	}
	
	return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
	self = [self init];
	if (self) {
		self.image = image;
	}
	
	return self;
}

- (instancetype)initWithImageName:(NSString *)imageName
{
	self = [self init];
	if (self) {
		self.imageName = imageName;
	}
	
	return self;
}

#pragma mark - RDPageContentDataDelegate

+ (UIView * _Nonnull)contentViewWithFrame:(CGRect)frame
{
	RDImageScrollView *view = [[RDImageScrollView alloc] initWithFrame:frame];
	
	return view;
}

- (void)preload
{
	if (self.image == nil) {
		self.image = [UIImage imageNamed:self.imageName];
	}
}

- (void)reload
{
	if (self.imageName) {
		self.image = nil;
		[self preload];
	}
}

- (void)stopPreloading
{
	
}

- (void)configureForView:(UIView * _Nonnull)view
{
	RDImageScrollView *imageView = (RDImageScrollView *)view;
	imageView.maximumZoomScale = self.maximumZoomScale;
	imageView.mode = self.landscapeMode;
	[imageView setZoomScale:1.0];
	imageView.image = self.image;
}

@end
