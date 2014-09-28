//
//  RDPagingView.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/28/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RDPagingView.h"


typedef struct {
	BOOL pagingViewWillViewEnqueue;
	BOOL pagingViewWillChangeIndexTo;
	BOOL pagingViewDidScrollToPosition;
	BOOL pagingViewWillBeginDragging;
	BOOL pagingViewDidEndDragging;
	BOOL pagingViewWillBeginDecelerating;
	BOOL pagingViewDidEndDecelerating;
	BOOL pagingViewDidEndScrollingAnimation;
} RDPagingViewDelegateFlag;

@interface RDPagingView () <UIScrollViewDelegate>
{
	NSMutableSet *usingViews_;
	NSMutableSet *preparedViews_;
	NSInteger pageIndex_;
	RDPagingViewDelegateFlag flag_;
}

@end

@implementation RDPagingView

static NSInteger kSubViewTagOffset = 3;
static NSInteger kPreloadDefaultCount = 1;

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.delegate = self;
		self.pagingEnabled = YES;
		self.direction = RDPagingViewDirectionRight;
		_numberOfPages = 0;
		_preloadCount = kPreloadDefaultCount;
		
		usingViews_ = [NSMutableSet new];
		preparedViews_ = [NSMutableSet new];
	}
	
	return self;
}

- (void)willMoveToSuperview:(UIView *)subview
{
	[self preloadWithNumberOfViews:_preloadCount fromIndex:0];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
	self.contentSize = CGSizeMake(self.bounds.size.width * numberOfPages, self.bounds.size.height);
	_numberOfPages = numberOfPages;
}

- (void)setPagingDelegate:(id<RDPagingViewDelegate>)pagingDelegate
{
	_pagingDelegate = pagingDelegate;
	
	flag_.pagingViewWillViewEnqueue = [pagingDelegate respondsToSelector:@selector(pagingView:willViewEnqueue:)];
	flag_.pagingViewWillChangeIndexTo = [pagingDelegate respondsToSelector:@selector(pagingView:willChangeIndexTo:)];
	flag_.pagingViewDidScrollToPosition = [pagingDelegate respondsToSelector:@selector(pagingView:didScrollToPosition:)];
	flag_.pagingViewWillBeginDragging = [pagingDelegate respondsToSelector:@selector(pagingViewWillBeginDragging:)];
	flag_.pagingViewDidEndDragging = [pagingDelegate respondsToSelector:@selector(pagingViewDidEndDragging:willDecelerate:)];
	flag_.pagingViewWillBeginDecelerating = [pagingDelegate respondsToSelector:@selector(pagingViewWillBeginDecelerating:)];
	flag_.pagingViewDidEndDecelerating = [pagingDelegate respondsToSelector:@selector(pagingViewDidEndDecelerating:)];
	flag_.pagingViewDidEndScrollingAnimation = [pagingDelegate respondsToSelector:@selector(pagingViewDidEndScrollingAnimation:)];
}

#pragma mark -

- (NSInteger)indexInScrollView:(NSInteger)index
{
	NSInteger trueIndex = index;
	if (self.direction == RDPagingViewDirectionLeft) {
		trueIndex = self.numberOfPages - index - 1;
	}
	
	return trueIndex;
}

- (void)setViewPrepared:(UIView *)view
{
	[view removeFromSuperview];
	[usingViews_ removeObject:view];
	[preparedViews_ addObject:view];
}

- (void)setViewUsing:(UIView *)view
{
	[preparedViews_ removeObject:view];
	[usingViews_ addObject:view];
}

- (UIView *)dequeueView
{
	UIView *view = [preparedViews_ anyObject];
	if (view == nil) {
		NSLog(@"\tnew view");
	}
	else {
		NSLog(@"\treuse:%ld", view.tag);
	}
	return view;
}

- (NSInteger)currentPageIndex
{
	return pageIndex_;
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
	if (pageIndex_ - currentPageIndex != 0) {
		[self pageIndexWillChangeToIndex:currentPageIndex];
	}
	pageIndex_ = currentPageIndex;
}

- (void)scrollAtPage:(NSInteger)page
{
	self.currentPageIndex = page;
	[self setContentOffset:CGPointMake([self indexInScrollView:self.currentPageIndex] * self.frame.size.width, 0)];
}

- (void)pageIndexWillChangeToIndex:(NSInteger)index
{
	NSLog(@"--");
	NSLog(@"\twill change to %ld", index);
	
	NSInteger direction = index - self.currentPageIndex > 0 ? RDPagingViewMovingDirectionForward : (index - self.currentPageIndex < 0 ? RDPagingViewMovingDirectionBackward : 0);
	NSInteger offset = index - (direction * (_preloadCount + 1)) + kSubViewTagOffset;
	
	if (offset > 0) {
		NSInteger maximumIndex = index + _preloadCount + kSubViewTagOffset;
		NSInteger minimumIndex = index - (NSInteger)_preloadCount + kSubViewTagOffset;
		[usingViews_ enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
			UIView *view = obj;
			if (view.tag < minimumIndex || view.tag > maximumIndex) {
				NSLog(@"\t\tremoved view tag: %ld", view.tag);
				[self setViewPrepared:view];
			}
		}];
		
		if (direction != 0) {
			[self preloadWithNumberOfViews:_preloadCount fromIndex:index];
		}
	}
	
	if (flag_.pagingViewWillChangeIndexTo) {
		[self.pagingDelegate pagingView:self willChangeIndexTo:index];
	}
}

- (void)preloadWithNumberOfViews:(NSInteger)num fromIndex:(NSInteger)index
{
	NSLog(@"preload:%ld - %ld", MAX(index - num, 0) + kSubViewTagOffset, MIN(index + num + 1, self.numberOfPages - 1) - 1 + kSubViewTagOffset);
	for (NSInteger i = MAX(index - num, 0); i < MIN(index + num + 1, self.numberOfPages); i++) {
		if ([self viewWithTag:i + kSubViewTagOffset] == nil) {
			[self loadViewAtIndex:i];
		}
	}
}

- (void)loadViewAtIndex:(NSInteger)index
{
	UIView *view = [self.pagingDelegate pagingView:self viewForIndex:index];
	view.frame = CGRectMake([self indexInScrollView:index] * CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame) ,CGRectGetHeight(self.frame));
	view.tag = index + kSubViewTagOffset;
	[self setViewUsing:view];
	[self addSubview:view];
	
	NSLog(@"load view tag: %ld", view.tag);
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat position = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
	self.currentPageIndex = [self indexInScrollView:position + 0.5];
	if (flag_.pagingViewDidScrollToPosition) {
		[self.pagingDelegate pagingView:self didScrollToPosition:scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame)];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if (flag_.pagingViewWillBeginDragging) {
		[self.pagingDelegate pagingViewWillBeginDragging:self];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (flag_.pagingViewDidEndDragging) {
		[self.pagingDelegate pagingViewDidEndDragging:self willDecelerate:decelerate];
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	if (flag_.pagingViewWillBeginDecelerating) {
		[self.pagingDelegate pagingViewWillBeginDecelerating:self];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (flag_.pagingViewDidEndDecelerating) {
		[self.pagingDelegate pagingViewDidEndDecelerating:self];
	}
//	CGFloat page = self.contentOffset.x / CGRectGetWidth(pagingView_.frame);
//	[self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		UIScrollView *pageView = (UIScrollView *)obj;
//		if (page != CGRectGetMinX(pageView.frame) / CGRectGetWidth(pagingView_.frame)) {
//			pageView.zoomScale = 1.0;
//		}
//	}];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if (flag_.pagingViewDidEndScrollingAnimation) {
		[self.pagingDelegate pagingViewDidEndScrollingAnimation:self];
	}
}

@end
