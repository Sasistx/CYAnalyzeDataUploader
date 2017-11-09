//
//  CYUrlArchiveManager.m
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/8/24.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import "CYUrlArchiveManager.h"
#import "CYUrlDBManager.h"

@interface CYUrlArchiveManager ()
@property (nonatomic) BOOL isWriting;
@end

@implementation CYUrlArchiveManager

- (void)archivePlistWithDataArray:(NSArray <CYUrlAnalyseModel *> *)array finishBlock:(void (^)(BOOL success))finishBlock {

    if (_isWriting) {
        
        if (finishBlock) {
            
            finishBlock(NO);
        } else {
            
            return;
        }
    }
    
    _isWriting = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSArray* targetArray = [array copy];
        NSMutableArray* dataArray = [NSMutableArray array];
        for (CYUrlAnalyseModel* model in targetArray) {
            
            NSDictionary* modelDict = [model transformToDictionary];
            [dataArray addObject:modelDict];
        }
        
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString* dateStr = [formatter stringFromDate:date];
        
        NSString* documentDomain = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString* filePath = [documentDomain stringByAppendingPathComponent:[NSString stringWithFormat:@"url_%@.plist", dateStr]];
        __block BOOL isSuccess = [dataArray writeToFile:filePath atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            _isWriting = NO;
            
            if (finishBlock) {
                
                finishBlock(isSuccess);
            }
        });
    });
}

- (void)archivePlistWithDB:(NSArray <CYUrlAnalyseModel *> *)array {
    
    [[CYUrlDBManager sharedManager] insertOrUpdateDataListToDB:array];
}

@end
