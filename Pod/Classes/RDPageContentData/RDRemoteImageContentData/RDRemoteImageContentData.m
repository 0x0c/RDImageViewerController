//
//  RDRemoteImageContentData.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/18/16.
//  Copyright © 2016 Akira Matsuda. All rights reserved.
//

#import "RDRemoteImageContentData.h"
#import "RDImageScrollView.h"
#import "rd_M2DURLConnectionOperation.h"

@interface RDRemoteImageContentData ()

@property (nonatomic, strong) RDImageScrollView *imageView;
@property (nonatomic, strong) rd_M2DURLConnectionOperation *operation;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) void(^lazyConfigurationHandler)(UIImage *image);

@end

@implementation RDRemoteImageContentData

- (instancetype)initWithRequest:(NSURLRequest *)request pageIndex:(NSInteger)index
{
	self = [super init];
	if (self) {
		self.request = request;
		self.pageIndex = index;
	}
	
	return self;
}

- (void)stopPreloading
{
	[self.operation stop];
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
		self.imageView = nil;
		__weak typeof(self) bself = self;
		self.operation = [[rd_M2DURLConnectionOperation alloc] initWithRequest:self.request completeBlock:^(rd_M2DURLConnectionOperation *operation, NSURLResponse *response, NSData *data, NSError *error) {
			if (bself.requestCompletionHandler) {
				bself.requestCompletionHandler(response, data, error);
			}
			
			UIImage *image = nil;
			if (bself.imageDecodeHandler) {
				image = bself.imageDecodeHandler(data);
			}
			else {
				image = [[UIImage alloc] initWithData:data];
			}
			
			bself.image = image;
			if (bself.lazyConfigurationHandler) {
				bself.lazyConfigurationHandler(image);
			}
		}];
		self.operation.configuration = self.configuration;
		[self.operation sendRequest];
	}
}

- (void)reload
{
	self.image = nil;
	[self preload];
}

- (void)configureForView:(UIView * _Nonnull)view
{
	[super configureForView:view];
	if (self.image == nil) {
		RDImageScrollView *imageView = (RDImageScrollView *)view;
		self.imageView = imageView;
		__weak typeof(self) bself = self;
		__weak typeof(imageView) bimageView = imageView;
		self.lazyConfigurationHandler = ^(UIImage *image) {
			if (bimageView == bself.imageView) {
				dispatch_async(dispatch_get_main_queue(), ^{
					bimageView.image = image;
				});
			}
		};
	}
}

@end
