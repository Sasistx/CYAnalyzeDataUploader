//
//  CYAnalyzeUploader.h
//  CYAnalyzeDataUploader
//
//  Created by 高天翔 on 2017/11/8.
//  Copyright © 2017年 chunyu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CYAnalyzeUploaderSuccess)(NSURLResponse *response, NSData *data);
typedef void(^CYAnalyzeUploaderFailed)(NSURLResponse *response, NSError *error);

@interface CYAnalyzeUploader : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString* appId;
@property (nonatomic, copy) NSString* appKey;
@property (nonatomic, copy) NSString* path;
@property (nonatomic, readonly) BOOL isAutoStart;
@property (nonatomic) NSTimeInterval autoUploadTimeInterval;

- (void)startUrlAutoUpload;

- (void)stopUrlAutoUpload;

- (void)uploadDataList:(NSArray *)dataList path:(NSString *)path success:(CYAnalyzeUploaderSuccess)success failed:(CYAnalyzeUploaderFailed)failed;

@end
