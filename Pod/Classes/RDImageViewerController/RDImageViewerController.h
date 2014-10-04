//
//  RDImageViewerController.h
//
//  Created by Akira Matsuda on 2014/03/20.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDPagingView.h"
#import "RDImageScrollView.h"

@interface RDImageViewerController : UIViewController <RDPagingViewDelegate, UIScrollViewDelegate>

@property (nonatomic) NSUInteger preloadCount;
@property (nonatomic, assign) BOOL pagingEnabled;

- (instancetype)initWithImageHandler:(UIImage *(^)(NSInteger pageIndex))imageHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction;
- (instancetype)initWithAsynchronousImageHandler:(void (^)(RDImageScrollView *imageView, NSInteger pageIndex))asyncHandler numberOfImages:(NSInteger)pageCount direction:(RDPagingViewForwardDirection)direction;

@end
