//
//  CYUrlSessionConfiguration.h
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/10/20.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYUrlSessionConfiguration : NSObject

@property (nonatomic, strong) NSURLSessionConfiguration* configuration;

+ (CYUrlSessionConfiguration*)sharedConfiguration;

- (void)startSwizzing;

- (void)stopSwizzing;

@end
