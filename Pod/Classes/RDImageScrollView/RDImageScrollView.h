//
//  RDImageScrollView.h
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/28/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDPagingView.h"

typedef NS_ENUM(NSUInteger, RDImageScrollViewResizeMode) {
	RDImageScrollViewResizeModeAspectFit,
	RDImageScrollViewResizeModeDisplayFit,
};

@interface RDImageScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, getter=image, setter=setImage:) UIImage *image;
@property (nonatomic, assign) RDImageScrollViewResizeMode mode;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;

- (void)addGestureRecognizerPriorityHigherThanZoomGestureRecogniser:(UIGestureRecognizer *)gesture;
- (void)adjustContentAspect;
- (void)setImageSizeAsAspectFit;
- (void)setImageSizeAsDisplayFit;

@end
