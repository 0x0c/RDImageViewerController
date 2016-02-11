//
//  M2DURLConnection.m
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/07.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import "rd_M2DURLConnectionOperation.h"

static NSOperationQueue *globalConnectionQueue;

@interface rd_M2DURLConnectionOperation ()
{
	void (^completeBlock_)(rd_M2DURLConnectionOperation *op, NSURLResponse *response, NSData *data, NSError *error);
	void (^progressBlock_)(CGFloat progress);
	CGFloat dataLength_;
	NSMutableData *data_;
	NSURLSessionDataTask *task_;
	NSURLResponse *response_;
	BOOL executing_;
}

@end

@implementation rd_M2DURLConnectionOperation

+ (void)globalStop:(NSString *)identifier
{
	NSNotification *n = [NSNotification notificationWithName:identifier object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:n];
}

+ (NSOperationQueue *)globalConnectionQueue
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		globalConnectionQueue = [NSOperationQueue new];
	});
	
	return globalConnectionQueue;
}

- (id)init
{
	self = [super init];
	if (self) {
		self.configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		_identifier = [NSString stringWithFormat:@"%p", self];
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

- (id)initWithRequest:(NSURLRequest *)request completeBlock:(void (^)(rd_M2DURLConnectionOperation *op, NSURLResponse *response, NSData *data, NSError *error))completeBlock
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

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
	response_ = response;
	data_ = [[NSMutableData alloc] init];
	dataLength_ = response.expectedContentLength;
	completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
	[data_ appendData:data];
	if (progressBlock_) {
		progressBlock_((double)data_.length / (double)dataLength_);
	}
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	[self.delegate connectionOperationDidComplete:self session:session task:task error:error];
	if (error) {
		completeBlock_(self, response_, nil, error);
	}
	else {
		if (completeBlock_) {
			completeBlock_(self, response_, data_, nil);
		}
	}
	[self finish];
}

#pragma mark -

- (void)stop
{
	[task_ cancel];
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

- (NSString *)sendRequestWithCompleteBlock:(void (^)(rd_M2DURLConnectionOperation *op, NSURLResponse *response, NSData *data, NSError *error))completeBlock
{
	return [self sendRequest:_request completeBlock:completeBlock];
}

- (NSString *)sendRequest:(NSURLRequest *)request completeBlock:(void (^)(rd_M2DURLConnectionOperation *op, NSURLResponse *response, NSData *data, NSError *error))completeBlock
{
	completeBlock_ = [completeBlock copy];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration delegate:self delegateQueue:[[self class] globalConnectionQueue]];
	task_ = [session dataTaskWithRequest:request];
	[task_ resume];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:_identifier object:nil];
	
	return _identifier;
}

- (void)finish
{
	executing_ = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:_identifier object:nil];
}

@end
