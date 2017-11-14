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

/**
 bomb appid
 */
@property (nonatomic, copy) NSString* appId;


/**
 bomb appkey
 */
@property (nonatomic, copy) NSString* appKey;

/**
 bomb path
 */
@property (nonatomic, copy) NSString* path;
@property (nonatomic, readonly) BOOL isAutoStart;

/**
 default mininum is 3 mins
 */
@property (nonatomic) NSTimeInterval autoUploadTimeInterval;

/**
 start url auto upload
 */
- (void)startUrlAutoUpload;

/**
 stop url auto upload
 */
- (void)stopUrlAutoUpload;

/**
 custon upload to bomb

 @param dataList <NSString*, NSString*> TYPE
 @param path bomb path
 @param success success block
 @param failed failed block
 */
- (void)uploadDataList:(NSArray *)dataList path:(NSString *)path success:(CYAnalyzeUploaderSuccess)success failed:(CYAnalyzeUploaderFailed)failed;

@end
