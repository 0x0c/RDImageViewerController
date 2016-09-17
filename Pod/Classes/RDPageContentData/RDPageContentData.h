//
//  RDPageContentData.h
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/18/16.
//  Copyright © 2016 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RDPageContentDataDelegate <NSObject>

+ (UIView * _Nonnull)contentViewWithFrame:(CGRect)frame;
- (void)preload;
- (void)stopPreloading;
- (void)reload;
- (void)configureForView:(UIView * _Nonnull)view;

@end

@interface RDPageContentData : NSObject <RDPageContentDataDelegate>

@end
