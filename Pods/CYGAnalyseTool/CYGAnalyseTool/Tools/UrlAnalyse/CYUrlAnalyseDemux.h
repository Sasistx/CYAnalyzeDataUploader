//
//  CYUrlAnalyseDemux.h
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/7/17.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYUrlAnalyseDemux : NSObject

@property (atomic, strong, readonly) NSURLSession* session;

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration*)config;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id <NSURLSessionDataDelegate>)delegate;

@end


@interface CYUrlAnalyseTaskInfo : NSObject

- (instancetype)initWithTask:(NSURLSessionTask *)task delegate:(id <NSURLSessionDataDelegate>) delegate;

- (void)invalidate;

@property (atomic, strong, readonly) NSURLSessionTask* task;
@property (atomic, strong, readonly) id <NSURLSessionDataDelegate> delegate;

@end
