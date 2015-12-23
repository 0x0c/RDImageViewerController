//
//  RDPagingView.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/28/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RDPagingView.h"
#import <objc/runtime.h>

typedef struct {
	BOOL pagingViewWillChangeViewSize;
	BOOL pagingViewWillViewEnqueue;
	BOOL pagingViewWillChangeIndexTo;
	BOOL pagingViewDidScrollToPosition;
	BOOL pagingViewWillBeginDragging;
	BOOL pagingViewDidEndDragging;
	BOOL pagingViewWillBeginDecelerating;
	BOOL pagingViewDidEndDecelerating;
	BOOL pagingViewDidEndScrollingAnimation;
} RDPagingViewDelegateFlag;

@implementation UIView (RDPagingView)

static NSString *const kRDPagingViewIndexOfPage = @"RDPagingViewIndexOfPage";
@dynamic indexOfPage;

- (NSInteger)indexOfPage
{
	return [(NSNumber *)objc_getAssociatedObject(self, (__bridge const void *)(kRDPagingViewIndexOfPage)) integerValue];
}

- (void)setIndexOfPage:(NSInteger)indexOfPage
{
	objc_setAssociatedObject(self, (__bridge const void *)(kRDPagingViewIndexOfPage), @(indexOfPage), OBJC_ASSOCIATION_RETAIN);
}

@end

@interface RDPagingView () <UIScrollViewDelegate>
{
	NSMutableDictionary *queueDictionary_;
	NSMutableSet *usingViews_;
	NSInteger pageIndex_;
	RDPagingViewDelegateFlag flag_;
	id<UIScrollViewDelegate> delegate_;
}

@end

@implementation RDPagingView

static NSInteger const kPreloadDefaultCount = 1;

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.delegate = self;
		self.pagingEnabled = YES;
		self.direction = RDPagingViewForwardDirectionRight;
		_preloadCount = kPreloadDefaultCount;
		_numberOfPages = 0;
		queueDictionary_ = [NSMutableDictionary new];
		usingViews_ = [NSMutableSet new];
	}
	
	return self;
}

- (void)willMoveToSuperview:(UIView *)subview
{
	[self preloadWithNumberOfViews:_preloadCount fromIndex:0];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
	if (RDPagingViewForwardDirectionVertical(self.direction)) {
		self.contentSize = CGSizeMake(self.bounds.size.width * numberOfPages, self.bounds.size.height);
	}
	else {
		self.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height * numberOfPages);
	}
	_numberOfPages = numberOfPages;
}

- (void)setPagingDelegate:(id<RDPagingViewDelegate>)pagingDelegate
{
	_pagingDelegate = pagingDelegate;
	
	flag_.pagingViewWillChangeViewSize = [pagingDelegate respondsToSelector:@selector(pagingView:willChangeViewSize:duration:visibleViews:)];
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

- (void)startRotation
{
	delegate_ = self.delegate;
	self.delegate = nil;
}

- (void)endRotation
{
	self.delegate = delegate_;
	delegate_ = nil;
}

- (NSInteger)indexInScrollView:(NSInteger)index
{
	NSInteger trueIndex = index;
	if (self.direction == RDPagingViewForwardDirectionLeft || self.direction == RDPagingViewForwardDirectionUp) {
		trueIndex = self.numberOfPages - index - 1;
	}
	
	return trueIndex;
}

- (void)setViewAsPrepared:(UIView *)view reuseIdentifier:(NSString *)identifier
{
	if (view) {
		[view removeFromSuperview];
		[usingViews_ removeObject:view];
		[queueDictionary_[identifier] addObject:view];
	}
}

- (void)setViewAsUsingView:(UIView *)view reuseIdentifier:(NSString *)identifier
{
	if (view) {
		[queueDictionary_[identifier] removeObject:view];
		[usingViews_ addObject:view];
	}
}

- (UIView *)dequeueViewWithReuseIdentifier:(NSString *)identifier
{
	NSMutableSet *set = queueDictionary_[identifier];
	if (set == nil) {
		set = [NSMutableSet new];
		queueDictionary_[identifier] = set;
	}
	
	return [set anyObject];
}

- (void)resizeWithFrame:(CGRect)frame duration:(NSTimeInterval)duration
{
	CGSize newSize = frame.size;
	if (flag_.pagingViewWillChangeViewSize) {
		[self.pagingDelegate pagingView:self willChangeViewSize:newSize duration:duration visibleViews:[usingViews_ allObjects]];
	}
	NSInteger currentPageIndex = [self indexInScrollView:self.currentPageIndex];
	if (RDPagingViewForwardDirectionVertical(self.direction)) {
		self.contentSize = CGSizeMake(self.numberOfPages * newSize.width, newSize.height);
	}
	else {
		self.contentSize = CGSizeMake(newSize.width, self.numberOfPages * newSize.height);
	}
	id delegate = self.delegate;
	self.delegate = nil;
	if (RDPagingViewForwardDirectionVertical(self.direction)) {
		[self setContentOffset:CGPointMake(currentPageIndex * newSize.width, 0)];
	}
	else {
		[self setContentOffset:CGPointMake(0, currentPageIndex * newSize.height)];
	}
	self.delegate = delegate;
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
	if (RDPagingViewForwardDirectionVertical(self.direction)) {
		[self setContentOffset:CGPointMake([self indexInScrollView:self.currentPageIndex] * self.frame.size.width, 0)];
	}
	else {
		[self setContentOffset:CGPointMake(0, [self indexInScrollView:self.currentPageIndex] * self.frame.size.height)];
	}
}

- (void)pageIndexWillChangeToIndex:(NSInteger)index
{
	RDPagingViewMovingDirection direction = index - self.currentPageIndex > 0 ? RDPagingViewMovingDirectionForward : (index - self.currentPageIndex < 0 ? RDPagingViewMovingDirectionBackward : 0);
	
	NSInteger maximumIndex = index + _preloadCount;
	NSInteger minimumIndex = index - _preloadCount;
	[usingViews_ enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		UIView *view = obj;
		if (view.indexOfPage < minimumIndex || view.indexOfPage > maximumIndex) {
			[self setViewAsPrepared:view reuseIdentifier:[self.pagingDelegate paginView:self reuseIdentifierForIndex:view.indexOfPage]];
		}
	}];
	
	if (direction != 0) {
		[self preloadWithNumberOfViews:_preloadCount fromIndex:index];
	}
	
	if (flag_.pagingViewWillChangeIndexTo) {
		[self.pagingDelegate pagingView:self willChangeIndexTo:index];
	}
}

- (void)preloadWithNumberOfViews:(NSInteger)num fromIndex:(NSInteger)index
{
	for (NSInteger i = MAX(index - num, 0); i < MIN(index + num + 1, self.numberOfPages); i++) {
		if ([self viewForIndex:i] == nil) {
			[self loadViewAtIndex:i];
		}
	}
}

- (void)loadViewAtIndex:(NSInteger)index
{
	UIView *view = [self.pagingDelegate pagingView:self viewForIndex:index];
	if (RDPagingViewForwardDirectionVertical(self.direction)) {
		view.frame = CGRectMake([self indexInScrollView:index] * CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
	}
	else {
		view.frame = CGRectMake(0, [self indexInScrollView:index] * CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
	}
	[view setIndexOfPage:index];
	[self setViewAsUsingView:view reuseIdentifier:[self.pagingDelegate paginView:self reuseIdentifierForIndex:index]];
	[self addSubview:view];
}

- (UIView *)viewForIndex:(NSInteger)index
{
	UIView *result = nil;
	for (UIView *view in usingViews_) {
		if (view.indexOfPage == index) {
			result = view;
			break;
		}
	}
	
	return result;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat position = 0;
	if (RDPagingViewForwardDirectionVertical(self.direction)) {
		position = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
	}
	else {
		position = scrollView.contentOffset.y / CGRectGetHeight(scrollView.frame);
	}

	self.currentPageIndex = [self indexInScrollView:position + 0.5];
	if (flag_.pagingViewDidScrollToPosition) {
		if (RDPagingViewForwardDirectionVertical(self.direction)) {
			[self.pagingDelegate pagingView:self didScrollToPosition:scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame)];
		}
		else {
			[self.pagingDelegate pagingView:self didScrollToPosition:scrollView.contentOffset.y / CGRectGetHeight(scrollView.frame)];
		}
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
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if (flag_.pagingViewDidEndScrollingAnimation) {
		[self.pagingDelegate pagingViewDidEndScrollingAnimation:self];
	}
}

@end
