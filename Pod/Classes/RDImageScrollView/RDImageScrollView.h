//
//  RDImageScrollView.h
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/28/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDImageScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, getter=image, setter=setImage:) UIImage *image;

- (void)addGestureRecognizerPriorityHigherThanZoomGestureRecogniser:(UIGestureRecognizer *)gesture;

@end
