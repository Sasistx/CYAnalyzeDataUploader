//
//  CYUrlAnalyseModel.h
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/8/1.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const CYUrlModelStatusCode;
extern NSString* const CYUrlModelErrorInfo;
extern NSString* const CYUrlModelMimeType;
extern NSString* const CYUrlModelReqUid;
extern NSString* const CYUrlModelHttpMethod;
extern NSString* const CYUrlModelReqUrl;
extern NSString* const CYUrlModelReqBody;
extern NSString* const CYUrlModelReqHeaderFields;
extern NSString* const CYUrlModelReqHeaderLength;
extern NSString* const CYUrlModelReqBodyLength;
extern NSString* const CYUrlModelResponseUrl;
extern NSString* const CYUrlModelResponseBody;
extern NSString* const CYUrlModelResponseContent;
extern NSString* const CYUrlModelResponseTime;
extern NSString* const CYUrlModelRespHeaderFields;
extern NSString* const CYUrlModelRespHeaderLength;
extern NSString* const CYUrlModelRespBodyLength;
extern NSString* const CYUrlModelStartDate;
extern NSString* const CYUrlModelEndDate;
extern NSString* const CYUrlModelReqPath;
extern NSString* const CYUrlModelRespPath;

@interface CYUrlAnalyseModel : NSObject

@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong) NSDictionary* errorInfo;
@property (nonatomic, copy) NSString* mimeType;
@property (nonatomic, copy) NSString* requestUid;
@property (nonatomic, copy) NSString* httpMethod;
@property (nonatomic, copy) NSString* requestUrl;
@property (nonatomic, copy) NSString* requestBody;
@property (nonatomic, copy) NSString* requestPath;
@property (nonatomic, strong) NSDictionary* requestHeaderFields;
@property (nonatomic) double requestHeaderLength;   //kb
@property (nonatomic) double requestBodyLength;     //kb

@property (nonatomic, copy) NSString* responseUrl;
@property (nonatomic, copy) NSString* responseBody;
@property (nonatomic, copy) NSString* responseContent;
@property (nonatomic, copy) NSString* responsePath;
@property (nonatomic, strong) NSDictionary* responseHeaderFields;
@property (nonatomic) NSTimeInterval responseTime;
@property (nonatomic) double responseHeaderLength;  //kb
@property (nonatomic) double responseBodyLength;    //kb

@property (nonatomic, copy) NSDate* startDate;
@property (nonatomic, copy) NSDate* endDate;

- (NSDictionary *)transformToDictionary;
+ (NSDictionary *)convertToDictionary:(NSString *)jsonString;
+ (NSDate *)convertToDate:(NSString *)dateString;
+ (double)convertToDouble:(NSString *)length;

@end
