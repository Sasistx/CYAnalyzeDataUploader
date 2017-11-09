//
//  CYUrlDBManager.h
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/11/2.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYUrlAnalyseModel.h"

typedef void(^ListModelCallBack)(NSArray <CYUrlAnalyseModel *> * dataList);
typedef void(^ListDictCallBack)(NSArray <NSDictionary *> * dataList);
typedef void(^ListRowIdCallBack)(NSString* rowId);

@interface CYUrlDBManager : NSObject

+ (CYUrlDBManager *)sharedManager;

- (void)insertOrUpdateDataToDB:(CYUrlAnalyseModel *)model;

- (void)insertOrUpdateDataListToDB:(NSArray <CYUrlAnalyseModel *> *)list;

- (void)getModelListByRowId:(NSString *)rowId limit:(NSInteger)limit isAsc:(BOOL)isAsc callBack:(ListModelCallBack)callBack;

- (void)getDictListByRowId:(NSString *)rowId limit:(NSInteger)limit isAsc:(BOOL)isAsc customDBKeys:(NSArray <NSString *> *)keys callBack:(ListDictCallBack)callBack;

- (void)getLatestRowId:(ListRowIdCallBack)callBack;

@end
