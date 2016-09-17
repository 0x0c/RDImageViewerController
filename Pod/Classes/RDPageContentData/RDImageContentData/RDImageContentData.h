//
//  RDImageContentData.h
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/18/16.
//  Copyright © 2016 Akira Matsuda. All rights reserved.
//

#import "RDPageContentData.h"
#import "RDImageScrollView.h"

@interface RDImageContentData : RDPageContentData

@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, assign) RDImageScrollViewResizeMode landscapeMode;
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImageName:(NSString *)imageName;

@end
