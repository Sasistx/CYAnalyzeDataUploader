//
//  CYUrlAnalyseDemux.m
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/7/17.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import "CYUrlAnalyseDemux.h"

@interface CYUrlAnalyseDemux () <NSURLSessionDataDelegate>
@property (atomic, strong) NSMutableDictionary* taskInfos;
@end

@implementation CYUrlAnalyseDemux

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration*)config {

    self = [super init];
    if (self) {
        
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _session.sessionDescription = @"CYUrlAnalyseDemux";
        _taskInfos = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<NSURLSessionDataDelegate>)delegate {

    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request];
    CYUrlAnalyseTaskInfo* taskInfo = [[CYUrlAnalyseTaskInfo alloc] initWithTask:task delegate:delegate];
    @synchronized (self) {
        _taskInfos[@(task.taskIdentifier)] = taskInfo;
    }
    return task;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    CYUrlAnalyseTaskInfo* taskInfo = [self taskInfoForTask:dataTask];
    
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
        
        [taskInfo.delegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    CYUrlAnalyseTaskInfo* taskInfo = [self taskInfoForTask:dataTask];
    
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        
        [taskInfo.delegate URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    CYUrlAnalyseTaskInfo* taskInfo = [self taskInfoForTask:task];
    
    @synchronized (self) {
    
        [self.taskInfos removeObjectForKey:@(task.taskIdentifier)];
    }
    
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        
        [taskInfo.delegate URLSession:session task:task didCompleteWithError:error];

    }
    
    [taskInfo invalidate];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler
{
    CYUrlAnalyseTaskInfo* taskInfo = [self taskInfoForTask:dataTask];
    
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)]) {
        
        [taskInfo.delegate URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
    }
    completionHandler(proposedResponse);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    CYUrlAnalyseTaskInfo* taskInfo = [self taskInfoForTask:task];
    
    if ([taskInfo.delegate respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)]) {
        
        [taskInfo.delegate URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
    }
}

- (CYUrlAnalyseTaskInfo *)taskInfoForTask:(NSURLSessionTask *)task {

    CYUrlAnalyseTaskInfo * taskInfo;
    @synchronized (self) {
        
        taskInfo = _taskInfos[@(task.taskIdentifier)];
    }
    
    return taskInfo;
}

@end

@implementation CYUrlAnalyseTaskInfo

- (instancetype)initWithTask:(NSURLSessionTask *)task delegate:(id <NSURLSessionDataDelegate>) delegate {
    
    self = [super init];
    if (self) {
        
        _delegate = delegate;
        _task = task;
    }
    return self;
}

- (void)invalidate {

    _delegate = nil;
}

@end
