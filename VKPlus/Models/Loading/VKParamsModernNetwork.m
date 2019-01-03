//
//  VKParamsModernNetwork.m
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsModernNetwork.h"

@interface VKParamsModernNetwork () <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) NSURLResponse *urlResponse;
@property (strong, nonatomic) NSMutableData *receivedData;

@property (strong, nonatomic, readonly) NSURLSession *defaultSession;

@end

@implementation VKParamsModernNetwork
@synthesize defaultSession = _defaultSession;
static NSString *const kVKP_ProcessingRequestKey = @"vkp_processing";

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:kVKP_ProcessingRequestKey inRequest:request])
        return NO;
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSMutableURLRequest *const newRequest = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:kVKP_ProcessingRequestKey inRequest:newRequest];
    
    self.dataTask = [self.defaultSession dataTaskWithRequest:newRequest];
    [self.dataTask resume];
}

- (void)stopLoading
{
    [self.dataTask cancel];
    self.dataTask = nil;
    self.receivedData = nil;
    self.urlResponse = nil;
}

- (NSURLSession *)defaultSession
{
    if (!_defaultSession) {
        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        configuration.allowsCellularAccess = YES;
        _defaultSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    
    return _defaultSession;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
                                  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    self.urlResponse = response;
    self.receivedData = [NSMutableData data];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
    
    [self.receivedData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    if (error && error.code != NSURLErrorCancelled) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

@end
