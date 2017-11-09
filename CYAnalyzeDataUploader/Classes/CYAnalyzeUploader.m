//
//  CYAnalyzeUploader.m
//  CYAnalyzeDataUploader
//
//  Created by 高天翔 on 2017/11/8.
//  Copyright © 2017年 chunyu. All rights reserved.
//

#import "CYAnalyzeUploader.h"
#import "CYUrlDBManager.h"

static NSTimeInterval defaultInterval = 10 * 5;
static NSString* defaultAppKey = @"fe6350d50989d7bf6c7f121ddcaf10b4";
static NSString* defaultAppId = @"1d3f40fa8e33b4ba1e3c4a4cb047d6e5";
static NSString* defaultUrl = @"/1/classes/Url";

@interface CYAnalyzeUploader ()

@property (nonatomic, strong) NSTimer* timer;

@end

@implementation CYAnalyzeUploader

static CYAnalyzeUploader* sharedInstance = nil;

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)isAutoStart {
    
    return _timer ? YES : NO;
}

#pragma mark -
#pragma mark - url auto upload

- (void)startUrlAutoUpload {
    
    if (!_timer) {
        
        _autoUploadTimeInterval = (_autoUploadTimeInterval >= defaultInterval) ? _autoUploadTimeInterval : defaultInterval;
        _timer = [NSTimer scheduledTimerWithTimeInterval:_autoUploadTimeInterval target:self selector:@selector(autoUploadUrlData) userInfo:nil repeats:YES];
        [_timer fire];
    }
}

- (void)stopUrlAutoUpload {
    
    if (_timer) {
        
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)autoUploadUrlData {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __block NSInteger rowNum = 1;
        [[CYUrlDBManager sharedManager] getLatestRowId:^(NSString *rowId) {
            
            rowNum = [rowId integerValue];
        }];
        
        if ([self getProcessFromeFile] >= rowNum) {
            
            return;
            
        } else {
            
            [[CYUrlDBManager sharedManager] getDictListByRowId:[NSString stringWithFormat:@"%li", (long)rowNum] limit:50 isAsc:YES customDBKeys:[CYAnalyzeUploader urlDBKeys] callBack:^(NSArray<NSDictionary *> *dataList) {
                
                if (dataList.count == 0) {
                    
                    return;
                }
                
                [self uploadDataList:dataList path:nil success:^(NSURLResponse *response, NSData *data) {
                    
                    [self saveProcessToFile:rowNum + dataList.count];
                    
                } failed:^(NSURLResponse *response, NSError *error) {
                    
                    [self stopUrlAutoUpload];
                }];
            }];
        }
    });
}

#pragma mark -
#pragma mark - upload

- (void)uploadDataList:(NSArray *)dataList path:(NSString *)path success:(CYAnalyzeUploaderSuccess)success failed:(CYAnalyzeUploaderFailed)failed {
    
    if (!dataList || dataList.count == 0) {
        
        NSError* error = [NSError errorWithDomain:NSStringEncodingErrorKey code:100 userInfo:@{NSLocalizedDescriptionKey:@"数组为空"}];
        if (failed) {
            
            failed(nil, error);
        }
        return;
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[CYAnalyzeUploader httpBodyValue:dataList path:path]
                                                       options:kNilOptions
                                                         error:&error];
    if (error && failed) {
        
        failed(nil, error);
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.bmob.cn/1/batch"];
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:_appId ? _appId : defaultAppId forHTTPHeaderField:@"X-Bmob-Application-Id"];
    [request setValue:_appKey ? _appKey : defaultAppKey forHTTPHeaderField:@"X-Bmob-REST-API-Key"];
    request.HTTPBody = jsonData;
    NSURLSession* session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
            if (failed) {
                failed(response, error);
            }
            
        } else {
            
            success(response, data);
        }
    }];
    [task resume];
}

#pragma mark -
#pragma mark - save process

- (void)saveProcessToFile:(NSInteger)row {
    
    if (row <= 0) {
        row = 1;
    }
    NSDictionary* dict = @{@"process":@(row)};
    [dict writeToFile:[CYAnalyzeUploader processFilePath] atomically:YES];
}

- (NSInteger)getProcessFromeFile {
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[CYAnalyzeUploader processFilePath]]) {
        
        NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:[CYAnalyzeUploader processFilePath]];
        return [dict[@"process"] integerValue];
    } else {
        
        return 1;
    }
}

+ (NSString *)processFilePath {
    
    static NSString *processFilePath = nil;
    if (!processFilePath) {
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* name = [NSString stringWithFormat:@"%@.plist", @"cy_a_upload_process"];
        processFilePath = [cacheDirectory stringByAppendingPathComponent:name];
    }
    return processFilePath;
}

#pragma mark -
#pragma mark - package data

+ (NSDictionary *)httpBodyValue:(NSArray *)dataList path:(NSString *)path {
    
    if (!dataList || dataList.count == 0) {
        
        return nil;
    }
    
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    NSMutableArray* valueList = [NSMutableArray array];
    for (NSDictionary* data in dataList) {
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        dict[@"body"] = data;
        dict[@"path"] = path ? path : defaultUrl;
        dict[@"method"] = @"POST";
        [valueList addObject:dict];
    }
    
    result[@"requests"] = valueList;
    return result;
}

+ (NSArray *)urlDBKeys{
    
    NSArray* keys = @[CYUrlModelStatusCode,
                      CYUrlModelMimeType,
                      CYUrlModelErrorInfo,
                      CYUrlModelHttpMethod,
                      CYUrlModelReqUrl,
                      CYUrlModelReqPath,
                      CYUrlModelReqBody,
                      CYUrlModelReqHeaderFields,
                      CYUrlModelReqHeaderLength,
                      CYUrlModelReqBodyLength,
                      CYUrlModelResponseBody,
                      CYUrlModelResponseContent,
                      CYUrlModelResponseTime,
                      CYUrlModelRespHeaderLength,
                      CYUrlModelRespBodyLength,
                      CYUrlModelStartDate];
    
    return keys;
}

@end
