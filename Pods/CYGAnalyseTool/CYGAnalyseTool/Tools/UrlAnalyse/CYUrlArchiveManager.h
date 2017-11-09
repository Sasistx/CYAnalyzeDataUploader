//
//  CYUrlArchiveManager.h
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/8/24.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYUrlAnalyseModel.h"

@interface CYUrlArchiveManager : NSObject

- (void)archivePlistWithDataArray:(NSArray <CYUrlAnalyseModel *> *)array finishBlock:(void (^)(BOOL success))finishBlock;

- (void)archivePlistWithDB:(NSArray <CYUrlAnalyseModel *> *)array;

@end
