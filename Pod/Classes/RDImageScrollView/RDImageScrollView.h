//
//  RDImageScrollView.h
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/28/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDPagingView.h"

@interface UIImage (RDImageView)

- (CGSize)rd_scaledSize:(CGSize)size;

@end

typedef NS_ENUM(NSUInteger, RDImageScrollViewResizeMode) {
	RDImageScrollViewResizeModeAspectFit,
	RDImageScrollViewResizeModeDisplayFit,
};

@interface RDImageScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, getter=image, setter=setImage:) UIImage *image;
@property (nonatomic, assign) RDImageScrollViewResizeMode mode;

- (void)addGestureRecognizerPriorityHigherThanZoomGestureRecogniser:(UIGestureRecognizer *)gesture;
- (void)setImageFrame:(CGRect)frame;
- (void)setImageSizeAspectFit;
- (void)setImageSizeDisplayFit;
- (void)setImageSize:(CGSize)size;

@end
