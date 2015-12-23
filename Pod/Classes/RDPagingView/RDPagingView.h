//
//  RDPagingView.h
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/28/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RDPagingViewForwardDirectionVertical(x) (x == RDPagingViewForwardDirectionLeft || x == RDPagingViewForwardDirectionRight)

typedef NS_ENUM(NSInteger, RDPagingViewForwardDirection) {
	RDPagingViewForwardDirectionRight,
	RDPagingViewForwardDirectionLeft,
	RDPagingViewForwardDirectionUp,
	RDPagingViewForwardDirectionDown
};

typedef NS_ENUM(NSInteger, RDPagingViewMovingDirection) {
	RDPagingViewMovingDirectionForward = 1,
	RDPagingViewMovingDirectionBackward = -1
};

@interface UIView (RDPagingView)

@property (nonatomic, readonly) NSInteger indexOfPage;

@end

@class RDPagingView;

@protocol RDPagingViewDelegate <NSObject>

@required
- (UIView *)pagingView:(RDPagingView *)pageView viewForIndex:(NSInteger)index;
- (NSString *)paginView:(RDPagingView *)paginView reuseIdentifierForIndex:(NSInteger)index;

@optional
- (void)pagingView:(RDPagingView *)pagingView willChangeViewSize:(CGSize)size duration:(NSTimeInterval)duration visibleViews:(NSArray *)views;
- (void)pagingView:(RDPagingView *)pagingView willViewEnqueue:(UIView *)view;
- (void)pagingView:(RDPagingView *)pagingView willChangeIndexTo:(NSInteger)index;
- (void)pagingView:(RDPagingView *)pagingView didScrollToPosition:(CGFloat)position;
- (void)pagingViewWillBeginDragging:(RDPagingView *)pagingView;
- (void)pagingViewDidEndDragging:(RDPagingView *)pagingView willDecelerate:(BOOL)decelerate;
- (void)pagingViewWillBeginDecelerating:(RDPagingView *)pagingView;
- (void)pagingViewDidEndDecelerating:(RDPagingView *)pagingView;
- (void)pagingViewDidEndScrollingAnimation:(RDPagingView *)pagingView;

@end

@interface RDPagingView : UIScrollView

@property (nonatomic, assign) id<RDPagingViewDelegate> pagingDelegate;
@property (nonatomic, assign) RDPagingViewForwardDirection direction;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, readonly) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger preloadCount;

- (void)startRotation;
- (void)endRotation;
- (NSInteger)indexInScrollView:(NSInteger)index;
- (void)scrollAtPage:(NSInteger)page;
- (UIView *)dequeueViewWithReuseIdentifier:(NSString *)identifier;
- (void)resizeWithFrame:(CGRect)frame duration:(NSTimeInterval)duration;
- (UIView *)viewForIndex:(NSInteger)index;

@end
