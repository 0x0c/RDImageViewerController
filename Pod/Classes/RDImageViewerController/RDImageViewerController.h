//
//  RDImageViewerController.h
//
//  Created by Akira Matsuda on 2014/03/20.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDPagingView.h"
#import "RDImageScrollView.h"

@class RDImageViewerController;
@protocol RDImageViewerControllerDelegate <NSObject>
@optional
- (void)imageViewerController:(RDImageViewerController *)viewController willChangeIndexTo:(NSInteger)index;

@end

@interface RDImageViewerController : UIViewController <RDPagingViewDelegate, UIScrollViewDelegate>

extern NSString *const RDImageViewerControllerReuseIdentifierImage;
extern NSString *const RDImageViewerControllerReuseIdentifierRemoteImage;

@property (nonatomic, assign) id<RDImageViewerControllerDelegate>delegate;
@property (nonatomic) NSUInteger preloadCount;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, readonly) NSInteger numberOfPages;
@property (nonatomic, assign) NSTimeInterval autoBarsHiddenDuration;
@property (nonatomic, assign) CGSize contentMergin;
@property (nonatomic, assign) BOOL restoreBarsState;
@property (nonatomic, assign) BOOL pagingEnabled;
@property (nonatomic, assign) BOOL loadAsync;
@property (nonatomic, assign) BOOL precedenceLatestImageLoadRequest;
@property (nonatomic, assign) BOOL showSlider;
@property (nonatomic, assign) BOOL showPageNumberHud;
@property (nonatomic, assign) RDImageScrollViewResizeMode landscapeMode;
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, copy) UIColor *pageSliderMaximumTrackTintColor;
@property (nonatomic, copy) UIColor *pageSliderMinimumTrackTintColor;
@property (nonatomic, readonly) UILabel *currentPageHudLabel;
@property (nonatomic, copy) UIImage *(^imageHandler)(NSInteger pageIndex);
@property (nonatomic, copy) NSURLRequest *(^remoteImageHandler)(NSInteger pageIndex);
@property (nonatomic, copy) void (^requestCompletionHandler)(NSURLResponse *response, NSData *data, NSError *connectionError);
@property (nonatomic, copy) UIImage *(^imageDecodeHandler)(NSData *data, NSInteger pageIndex);
@property (nonatomic, copy) void(^imageViewConfigurationHandler)(NSInteger pageIndex, RDImageScrollView *imageView);
@property (nonatomic, copy) UIView *(^viewHandler)(NSString *identifier, NSInteger pageIndex, UIView *reusedView);
@property (nonatomic, copy) NSString *(^reuseIdentifierHandler)(NSInteger pageIndex);
@property (nonatomic, copy) void(^reloadViewHandler)(NSString *identifier, NSInteger pageIndex, UIView *view);
@property (nonatomic, copy) void(^contentViewWillAppearHandler)(NSInteger pageIndex, UIView *view);

- (instancetype)initWithNumberOfPages:(NSInteger)num direction:(RDPagingViewForwardDirection)direction;
- (instancetype)initWithImageHandler:(UIImage *(^)(NSInteger pageIndex))imageHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction;
- (instancetype)initWithViewHandler:(UIView *(^)(NSString *reuseIdentifier, NSInteger pageIndex, UIView *reusedView))viewHandler reuseIdentifier:(NSString *(^)(NSInteger pageIndex))reuseIdentifierHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction;
- (instancetype)initWithRemoteImageHandler:(NSURLRequest *(^)(NSInteger pageIndex))remoteImageHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction;
- (void)setRemoteImageHandler:(NSURLRequest *(^)(NSInteger pageIndex))remoteImageHandler completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))completionHandler decodeHandler:(UIImage *(^)(NSData *data, NSInteger pageIndex))decodeHandler;
- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setHudHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setPageHudNumberWithPageIndex:(NSInteger)pageIndex;
- (void)setBarHiddenByTapGesture;
- (void)cancelAutoBarHidden;
- (void)reloadViewAtIndex:(NSInteger)index;

@end
