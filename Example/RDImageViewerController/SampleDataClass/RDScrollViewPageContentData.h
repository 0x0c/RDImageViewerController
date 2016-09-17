//
//  RDScrollViewPageContentData.h
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/18/16.
//  Copyright © 2016 Akira Matsuda. All rights reserved.
//

#import "RDPageContentData.h"

@interface RDScrollViewPageContentData : RDPageContentData

@property (nonatomic, strong) NSString *labelString;

- (instancetype)initWithString:(NSString *)string;

@end
