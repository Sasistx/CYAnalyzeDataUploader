//
//  CYUrlAnalyseProtocol.m
//  ChunyuClinic
//
//  Created by 高天翔 on 16/9/7.
//  Copyright © 2016年 SpringRain. All rights reserved.
//

#import "CYUrlAnalyseProtocol.h"
#import "CYUrlAnalyseManager.h"
#import "CYUrlAnalyseDemux.h"
#import "CYUrlAnalyseModel.h"
#import "CYUrlDBManager.h"

@interface CYUrlAnalyseProtocol() <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) CYUrlAnalyseModel* urlModel;
@property (nonatomic, strong) NSMutableData* data;
@end

@implementation CYUrlAnalyseProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {

    NSString *scheme = [request.URL scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame))
    {
        if ([[request.URL absoluteString] containsString:@"localhost:"]) {
            
            return NO;
        }
        
        if ([NSURLProtocol propertyForKey:CYURLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    _urlModel = [[CYUrlAnalyseModel alloc] init];
    _urlModel.requestUid = [NSUUID UUID].UUIDString;
    _urlModel.startDate = [NSDate date];
    _data = [NSMutableData data];
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    [[self class] setProperty:@YES forKey:CYURLProtocolHandledKey inRequest:mutableReqeust];
    _urlModel.requestPath = mutableReqeust.URL.path;
    self.task = [[[self class] sharedDemux] dataTaskWithRequest:mutableReqeust delegate:self];
    [self.task resume];
}

- (void)stopLoading
{
    NSTimeInterval divTime = [[NSDate date] timeIntervalSinceDate:_urlModel.startDate];
    NSString* requestBody = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    
    _urlModel.responseTime = divTime;
    _urlModel.requestUrl = self.request.URL.absoluteString.stringByRemovingPercentEncoding;
    _urlModel.requestBody = requestBody.stringByRemovingPercentEncoding ? : @"";
    _urlModel.requestHeaderFields = self.request.allHTTPHeaderFields;
    _urlModel.requestBodyLength = self.request.HTTPBody.length / 1024.0;
    _urlModel.httpMethod = self.request.HTTPMethod;
    _urlModel.endDate = [NSDate date];
    if (_urlModel.requestHeaderFields) {
        NSData* data = [NSJSONSerialization dataWithJSONObject:_urlModel.requestHeaderFields options:NSJSONWritingPrettyPrinted error:nil];
        _urlModel.requestHeaderLength = data.length / 1024.0;
    }
    
    [[CYUrlAnalyseManager defaultManager] addObjectToUrlArray:_urlModel];
    
    if ([CYUrlAnalyseManager defaultManager].storageType == CYUrlStorageTypeAutoDB) {
        
        [[CYUrlDBManager sharedManager] insertOrUpdateDataToDB:_urlModel];
    }
    
    if (self.task != nil) {
        
        [self.task cancel];
        self.task = nil;
    }
}

+ (CYUrlAnalyseDemux *)sharedDemux {

    static dispatch_once_t onceToken;
    static CYUrlAnalyseDemux* analyseDemux;
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.protocolClasses = @[self];
        analyseDemux = [[CYUrlAnalyseDemux alloc] initWithConfiguration:config];
    });
    
    return analyseDemux;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler {

    NSMutableURLRequest* redirectRequest = [newRequest mutableCopy];
    
    [[self class] removePropertyForKey:CYURLProtocolHandledKey inRequest:redirectRequest];
    
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    [self.task cancel];
    
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSString* string = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    _urlModel.responseBody = string.stringByRemovingPercentEncoding ? : @"";
    _urlModel.responseUrl = response.URL.absoluteString;
    _urlModel.mimeType = response.MIMEType;
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        
        _urlModel.responseHeaderFields = ((NSHTTPURLResponse*)response).allHeaderFields;
        if (_urlModel.responseHeaderFields) {
            
            NSData* data = [NSJSONSerialization dataWithJSONObject:_urlModel.responseHeaderFields options:NSJSONWritingPrettyPrinted error:nil];
            _urlModel.responseHeaderLength = data.length / 1024.0;
        }
        
        _urlModel.statusCode = ((NSHTTPURLResponse*)response).statusCode;
    }
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {

    [_data appendData:data];
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error == nil) {
        
        if (_data) {
            
            _urlModel.responseBodyLength = _data.length / 1024.0;
            NSError* error = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:&error];
            
            if (!error && [NSJSONSerialization isValidJSONObject:jsonObject]) {
                
                NSError* jsonError = nil;
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&jsonError];
                if (!jsonError && jsonData) {
                    
                    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    _urlModel.responseContent = jsonString;
                }
            }
        }
        
        [[self client] URLProtocolDidFinishLoading:self];
    } else if ( [[error domain] isEqual:NSURLErrorDomain] && ([error code] == NSURLErrorCancelled) ) {
        
    } else {
        
        _urlModel.errorInfo = error.userInfo;
        [[self client] URLProtocol:self didFailWithError:error];
    }
    _data = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler
{
    completionHandler(proposedResponse);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {

        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end
