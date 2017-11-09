//
//  CYUrlSessionConfiguration.m
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/10/20.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import "CYUrlSessionConfiguration.h"
#import <objc/runtime.h>
#import "CYUrlAnalyseProtocol.h"

@interface CYUrlSessionConfiguration ()
@property (nonatomic) BOOL swizzing;
@end

@implementation CYUrlSessionConfiguration

+ (CYUrlSessionConfiguration*)sharedConfiguration {
    
    static CYUrlSessionConfiguration* sharedConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedConfiguration = [[CYUrlSessionConfiguration alloc] init];
    });
    
    return sharedConfiguration;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return self;
}

- (void)startSwizzing {
    
    @synchronized(self) {
        
        if (self.swizzing) {
            
            return;
        }
        self.swizzing = YES;
        Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
        [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
    }
}

- (void)stopSwizzing {
    
    @synchronized(self) {
        
        self.swizzing = NO;
        Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
        [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
    }
}

- (void)swizzleSelector:(SEL)selector fromClass:(Class)original toClass:(Class)stub {
    
    self.swizzing = NO;
    Method originalMethod = class_getInstanceMethod(original, selector);
    Method stubMethod = class_getInstanceMethod(stub, selector);
    NSAssert(originalMethod && stubMethod, @"CYUrlSessionConfiguration Wrong swizzing");
    method_exchangeImplementations(originalMethod, stubMethod);
}

- (NSArray *)protocolClasses {
    
    NSArray* protocols = _configuration.protocolClasses;
    NSMutableArray* mutableProtocols = [[NSMutableArray alloc] initWithArray:protocols];
    [mutableProtocols addObject:[CYUrlAnalyseProtocol class]];
    return mutableProtocols;
}

@end
