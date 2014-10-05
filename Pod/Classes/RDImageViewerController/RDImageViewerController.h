//
//  RDImageViewerController.h
//
//  Created by Akira Matsuda on 2014/03/20.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDPagingView.h"
#import "RDImageScrollView.h"

typedef NS_ENUM(NSUInteger, RDImageViewerControllerLandscapeMode) {
	RDImageViewerControllerLandscapeModeAspectFit,
	RDImageViewerControllerLandscapeModeDisplayFit,
};

@interface RDImageViewerController : UIViewController <RDPagingViewDelegate, UIScrollViewDelegate>

@property (nonatomic) NSUInteger preloadCount;
@property (nonatomic, assign) BOOL pagingEnabled;
@property (nonatomic, assign) RDImageViewerControllerLandscapeMode landscapeMode;
@property (nonatomic, assign) BOOL loadAsync;
@property (nonatomic, assign) CGFloat maximumZoomScale;

- (instancetype)initWithImageHandler:(UIImage *(^)(NSInteger pageIndex))imageHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction;

@end
