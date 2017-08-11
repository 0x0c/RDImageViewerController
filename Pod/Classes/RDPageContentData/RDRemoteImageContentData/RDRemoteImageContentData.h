//
//  RDRemoteImageContentData.h
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/18/16.
//  Copyright © 2016 Akira Matsuda. All rights reserved.
//

#import "RDImageContentData.h"

@interface RDRemoteImageContentData : RDImageContentData

@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, strong) NSURLSessionConfiguration *configuration;
@property (nonatomic, copy) void (^requestCompletionHandler)(NSURLResponse *response, NSData *data, NSError *connectionError);
@property (nonatomic, copy) UIImage *(^imageDecodeHandler)(NSData *data);

- (instancetype)initWithRequest:(NSURLRequest *)request;

@end
