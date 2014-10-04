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

- (CGSize)rd_displayScaledSize;

@end

@interface RDImageScrollView : UIScrollView <UIScrollViewDelegate, RDPagingViewProtocol>

@property (nonatomic, getter=image, setter=setImage:) UIImage *image;

- (void)addGestureRecognizerPriorityHigherThanZoomGestureRecogniser:(UIGestureRecognizer *)gesture;

@end
