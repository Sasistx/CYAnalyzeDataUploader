//
//  CYUrlAnalyseProtocol.h
//  ChunyuClinic
//
//  Created by 高天翔 on 16/9/7.
//  Copyright © 2016年 SpringRain. All rights reserved.
//

@import Foundation;

@interface CYUrlAnalyseProtocol : NSURLProtocol

@property (atomic, strong, readwrite) NSURLSessionDataTask * task;

@end
