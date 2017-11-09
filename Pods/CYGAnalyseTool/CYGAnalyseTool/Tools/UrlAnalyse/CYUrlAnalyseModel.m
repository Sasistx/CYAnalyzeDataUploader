//
//  CYUrlAnalyseModel.m
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/8/1.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import "CYUrlAnalyseModel.h"
#import "CYUrlAnalyseManager.h"

NSString* const CYUrlModelStatusCode = @"Status_Code";
NSString* const CYUrlModelErrorInfo = @"Error_Info";
NSString* const CYUrlModelMimeType = @"MIME";
NSString* const CYUrlModelReqUid = @"Uid";
NSString* const CYUrlModelHttpMethod = @"Method";
NSString* const CYUrlModelReqUrl = @"Request_Url";
NSString* const CYUrlModelReqBody = @"Request_Body";
NSString* const CYUrlModelReqHeaderFields = @"Req_Header_fields";
NSString* const CYUrlModelReqHeaderLength = @"Req_Header_length";
NSString* const CYUrlModelReqBodyLength = @"Req_Body_length";
NSString* const CYUrlModelResponseUrl = @"Response_Url";
NSString* const CYUrlModelResponseBody = @"Response_Body";
NSString* const CYUrlModelResponseContent = @"Response_Content";
NSString* const CYUrlModelResponseTime = @"Response_time";
NSString* const CYUrlModelRespHeaderFields = @"Resp_Header_fields";
NSString* const CYUrlModelRespHeaderLength = @"Resp_Header_length";
NSString* const CYUrlModelRespBodyLength = @"Resp_Body_length";
NSString* const CYUrlModelStartDate = @"Start_date";
NSString* const CYUrlModelEndDate = @"End_date";

NSString* const CYUrlModelReqPath = @"Req_path";
NSString* const CYUrlModelRespPath = @"Resp_path";

@implementation CYUrlAnalyseModel

- (NSDictionary *)transformToDictionary {

    NSMutableDictionary* modelDict = [NSMutableDictionary dictionary];
    
    modelDict[CYUrlModelReqUid] = [CYUrlAnalyseModel ensureStrNotEmpty:self.requestUid];
    modelDict[CYUrlModelStatusCode] = @(self.statusCode);
    modelDict[CYUrlModelMimeType] = [CYUrlAnalyseModel ensureStrNotEmpty:self.mimeType];
    modelDict[CYUrlModelHttpMethod] = [CYUrlAnalyseModel ensureStrNotEmpty:self.httpMethod];
    modelDict[CYUrlModelReqUrl] = [CYUrlAnalyseModel ensureStrNotEmpty:self.requestUrl];
    modelDict[CYUrlModelReqBody] = [CYUrlAnalyseModel ensureStrNotEmpty:self.requestBody];
    modelDict[CYUrlModelReqHeaderLength] = [NSString stringWithFormat:@"%f kb", self.requestHeaderLength];
    modelDict[CYUrlModelReqBodyLength] = [NSString stringWithFormat:@"%f kb", self.requestBodyLength];
    
    modelDict[CYUrlModelResponseUrl] = [CYUrlAnalyseModel ensureStrNotEmpty:self.responseUrl];
    modelDict[CYUrlModelResponseBody] = [CYUrlAnalyseModel ensureStrNotEmpty:self.responseBody];
    modelDict[CYUrlModelResponseContent] = [CYUrlAnalyseModel ensureStrNotEmpty:self.responseContent];
    modelDict[CYUrlModelResponseTime] = [NSString stringWithFormat:@"%0.4fs", self.responseTime];
    modelDict[CYUrlModelRespHeaderLength] = [NSString stringWithFormat:@"%f kb", self.responseHeaderLength];
    modelDict[CYUrlModelRespBodyLength] = [NSString stringWithFormat:@"%f kb", self.responseBodyLength];
    NSString* reqPath = [CYUrlAnalyseModel pathFilter:self.requestPath];
    modelDict[CYUrlModelReqPath] = reqPath ? reqPath : @"";
    modelDict[CYUrlModelRespPath] = self.responsePath ? self.responsePath : @"";
    
    NSDictionary* reqHeaderFields = self.requestHeaderFields ? : @{};
    NSDictionary* respHeaderFields = self.responseHeaderFields ? : @{};
    
    modelDict[CYUrlModelReqHeaderFields] = [CYUrlAnalyseModel convertToJSONData:reqHeaderFields];
    modelDict[CYUrlModelRespHeaderFields] = [CYUrlAnalyseModel convertToJSONData:respHeaderFields];
    
    NSMutableString* errorString = [[NSMutableString alloc] initWithString:@""];
    if ([self.errorInfo isKindOfClass:[NSDictionary class]]) {
        
        [errorString appendString:@"\n\nError:\n\n"];
        NSDictionary* errorInfo = self.errorInfo;
        [errorString appendFormat:@"Url: %@\n\n", errorInfo[NSURLErrorFailingURLStringErrorKey]];
        [errorString appendFormat:@"Decription: %@\n\n", errorInfo[NSLocalizedDescriptionKey]];
        [errorString appendFormat:@"Other: %@\n\n", errorInfo[NSUnderlyingErrorKey]];
    }
    modelDict[CYUrlModelErrorInfo] = errorString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    modelDict[CYUrlModelStartDate] = [CYUrlAnalyseModel ensureStrNotEmpty:[dateFormatter stringFromDate:self.startDate]];
    modelDict[CYUrlModelEndDate] = [CYUrlAnalyseModel ensureStrNotEmpty:[dateFormatter stringFromDate:self.startDate]];
    
    return modelDict;
}

+ (NSString*)convertToJSONData:(id)infoDict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

+ (NSDictionary *)convertToDictionary:(NSString *)jsonString {
    
    if (!jsonString) {
        
        return @{};
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        
        return @{};
    }
    return dict;
}

+ (NSDate *)convertToDate:(NSString *)dateString {
    
    if (dateString) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        return [dateFormatter dateFromString:dateString];
    } else {
        return nil;
    }
}

+ (double)convertToDouble:(NSString *)length {
    
    if (length && length.length > 0) {
        
        NSString* temp = [length stringByReplacingOccurrencesOfString:@"kb" withString:@""];
        
        return [[temp stringByReplacingOccurrencesOfString:@"s" withString:@""] doubleValue];
    } else {
        
        return 0;
    }
}

+ (NSString *)pathFilter:(NSString *)path {
    
    if (path == nil || [path isEqualToString:@""]) {
        
        return nil;
    }
    
    NSString* result = nil;
    
    if ([CYUrlAnalyseManager defaultManager].pathFilters) {
        
        for (NSDictionary* filterDict in [CYUrlAnalyseManager defaultManager].pathFilters) {
            
            NSString* regexStr = filterDict[CYURLDBRegexKey];
            NSError* error = nil;
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            if (!error) {
                NSTextCheckingResult *match = [regex firstMatchInString:path
                                                                options:0
                                                                  range:NSMakeRange(0, [path length])];
                if (match) {
                    result = [self ensureStrNotEmpty:filterDict[CYURLDBValueKey]];
                    break;
                }
            } else {
                NSLog(@"error - %@", error);
            }
        }
    }
    return result;
}

+ (NSString *)ensureStrNotEmpty:(NSString *)str{

    if (![str isKindOfClass:[NSString class]]) {
        
        return @"";
    }
    
    if (str == nil) {
        
        return @"";
    }
    
    return str;
}

@end
