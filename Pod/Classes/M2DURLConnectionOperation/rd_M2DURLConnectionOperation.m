//
//  M2DURLConnection.m
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/07.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import "rd_M2DURLConnectionOperation.h"

static dispatch_queue_t globalConnectionQueue;

@implementation rd_M2DURLConnectionOperation

+ (void)globalStop:(NSString *)identifier
{
	NSNotification *n = [NSNotification notificationWithName:identifier object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:n];
}

+ (dispatch_queue_t)globalConnectionQueue
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		globalConnectionQueue = dispatch_queue_create("M2DURLConnectionOperationGlobalConnectionQueue", NULL);
	});
	
	return globalConnectionQueue;
}

- (id)init
{
	self = [super init];
	if (self) {
		_identifier = [[NSProcessInfo processInfo] globallyUniqueString];
	}
	
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request
{
	self = [self init];
	if (self) {
		_request = [request copy];
	}
	
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request completeBlock:(void (^)(rd_M2DURLConnectionOperation *operation, NSURLResponse *response, NSData *data, NSError *error))completeBlock
{
	self = [self initWithRequest:request];
	if (self) {
		completeBlock_ = [completeBlock copy];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:_identifier object:nil];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[data_ appendData:data];
	if (progressBlock_) {
		progressBlock_((double)data_.length / (double)dataLength_);
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	response_ = response;
	data_ = [[NSMutableData alloc] init];
	dataLength_ = response.expectedContentLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (completeBlock_) {
		completeBlock_(self, response_, data_, nil);
	}
	if ([self.delegate respondsToSelector:@selector(connectionOperationDidComplete:connection:)]) {
		[self.delegate connectionOperationDidComplete:self connection:(NSURLConnection *)connection];
	}
	[self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	completeBlock_(self, response_, nil, error);
	[self finish];
}

#pragma mark -

- (void)stop
{
	[connection_ cancel];
	[self finish];
}

- (void)setProgressBlock:(void (^)(CGFloat progress))progressBlock
{
	progressBlock_ = [progressBlock copy];
}

- (NSString *)sendRequest
{
	return [self sendRequestWithCompleteBlock:completeBlock_];
}

- (NSString *)sendRequestWithCompleteBlock:(void (^)(rd_M2DURLConnectionOperation *operation, NSURLResponse *response, NSData *data, NSError *error))completeBlock
{
	return [self sendRequest:_request completeBlock:completeBlock];
}

- (NSString *)sendRequest:(NSURLRequest *)request completeBlock:(void (^)(rd_M2DURLConnectionOperation *operation, NSURLResponse *response, NSData *data, NSError *error))completeBlock
{
	completeBlock_ = [completeBlock copy];
	connection_ = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:_identifier object:nil];
	
	executing_ = YES;
	dispatch_async([[self class] globalConnectionQueue], ^{
		[connection_ start];
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (executing_);
	});
	
	return _identifier;
}

- (void)finish
{
	executing_ = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:connection_ name:_identifier object:nil];
}

@end
