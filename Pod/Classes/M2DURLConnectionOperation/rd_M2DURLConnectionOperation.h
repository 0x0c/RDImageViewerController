//
//  M2DURLConnection.h
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/07.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class rd_M2DURLConnectionOperation;

@protocol rd_M2DURLConnectionOperationDelegate <NSObject>

- (void)connectionOperationDidComplete:(rd_M2DURLConnectionOperation *)operation connection:(NSURLConnection *)connection;

@end

@interface rd_M2DURLConnectionOperation : NSObject <NSURLConnectionDataDelegate>
{
	void (^completeBlock_)(rd_M2DURLConnectionOperation *operation, NSURLResponse *response, NSData *data, NSError *error);
	void (^progressBlock_)(CGFloat progress);
	CGFloat dataLength_;
	NSMutableData *data_;
	NSURLConnection *connection_;
	NSURLResponse *response_;
	BOOL executing_;
}

@property id<rd_M2DURLConnectionOperationDelegate> delegate;
@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, readonly) NSString *identifier;

+ (void)globalStop:(NSString *)identifier;
- (void)stop;
- (id)initWithRequest:(NSURLRequest *)request;
- (id)initWithRequest:(NSURLRequest *)request completeBlock:(void (^)(rd_M2DURLConnectionOperation *operation,NSURLResponse *response, NSData *data, NSError *error))completeBlock;
- (void)setProgressBlock:(void (^)(CGFloat progress))progressBlock;
- (NSString *)sendRequest;
- (NSString *)sendRequestWithCompleteBlock:(void (^)(rd_M2DURLConnectionOperation *operation, NSURLResponse *response, NSData *data, NSError *error))completeBlock;
- (NSString *)sendRequest:(NSURLRequest *)request completeBlock:(void (^)(rd_M2DURLConnectionOperation *operation, NSURLResponse *response, NSData *data, NSError *error))completeBlock;

@end
