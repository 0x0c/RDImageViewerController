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

extern NSString *const RDImageViewerControllerReuseIdentifierImage;

@property (nonatomic) NSUInteger preloadCount;
@property (nonatomic, assign) BOOL pagingEnabled;
@property (nonatomic, assign) BOOL loadAsync;
@property (nonatomic, assign) BOOL showSlider;
@property (nonatomic, assign) BOOL showPageNumberHud;
@property (nonatomic, assign) RDImageViewerControllerLandscapeMode landscapeMode;
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, readonly) UISlider *pageSlider;
@property (nonatomic, copy) UIImage *(^imageHandler)(NSInteger pageIndex);
@property (nonatomic, copy) UIView *(^viewHandler)(NSInteger pageIndex, UIView *reusedView);
@property (nonatomic, copy) NSString *(^reuseIdentifierHandler)(NSInteger pageIndex);

- (instancetype)initWithNumberOfPages:(NSInteger)num direction:(RDPagingViewForwardDirection)direction;
- (instancetype)initWithImageHandler:(UIImage *(^)(NSInteger pageIndex))imageHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction;
- (instancetype)initWithViewHandler:(UIView *(^)(NSInteger pageIndex, UIView *reusedView))viewHandler reuseIdentifier:(NSString *(^)(NSInteger pageIndex))reuseIdentifierHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction;

@end
