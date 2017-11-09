//
//  CYUrlDBManager.m
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/11/2.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import "CYUrlDBManager.h"

#import "FMDB.h"

static NSString* kCYGUrlDBName = @"CYG_Url";
static NSString* kCYGUrlTableName = @"Url";

@interface CYUrlDBManager ()
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) NSArray* customKeys;
@end

@implementation CYUrlDBManager

+ (CYUrlDBManager *)sharedManager {
    
    static CYUrlDBManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CYUrlDBManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self createDB];
        [self createTable];
    }
    return self;
}

- (void)createDB {
    
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self databasePath]];
    [_dbQueue openFlags];
}

- (void)createTable {
    
    __block NSString* sql = [self getTableSql];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        if (![db tableExists:kCYGUrlTableName]) {
            NSError* error = nil;
            [db executeUpdate:sql withErrorAndBindings:&error];
            if (error) {
                
            }
        }
    }];
}

- (NSString *)getTableSql {
    
    NSString* uid = [NSString stringWithFormat:@"%@ TEXT unique not null", CYUrlModelReqUid];
    NSString* statusCode = [NSString stringWithFormat:@"%@ INTEGER", CYUrlModelStatusCode];
    NSString* mime = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelMimeType];
    NSString* errorInfo = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelErrorInfo];
    NSString* method = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelHttpMethod];
    NSString* requestUrl = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelReqUrl];
    NSString* requestPath = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelReqPath];
    NSString* reqBody = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelReqBody];
    NSString* reqHeaderFields = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelReqHeaderFields];
    NSString* reqHeaderLength = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelReqHeaderLength];
    NSString* reqBodyLength = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelReqBodyLength];
    NSString* respUrl = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelResponseUrl];
    NSString* respPath = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelRespPath];
    NSString* respBody = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelResponseBody];
    NSString* respContent = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelResponseContent];
    NSString* respTime = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelResponseTime];
    NSString* respHeaderFields = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelRespHeaderFields];
    NSString* respHeaderLength = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelRespHeaderLength];
    NSString* respBodyLength = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelRespBodyLength];
    NSString* startDate = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelStartDate];
    NSString* endDate = [NSString stringWithFormat:@"%@ TEXT", CYUrlModelEndDate];
    
    NSArray* array = @[uid, statusCode, mime, errorInfo, method, requestUrl, requestPath, reqBody, reqHeaderFields, reqHeaderLength, reqBodyLength, respUrl, respPath, respBody, respContent, respTime, respHeaderFields, respHeaderLength, respBodyLength, startDate, endDate];
    
    NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@)",kCYGUrlTableName, [array componentsJoinedByString:@","]];
    
    return sql;
}

- (NSString *)getTransactionSql {
    
    NSMutableArray* tempKeys = [NSMutableArray array];
    for (NSString* key in [self dbKeys]) {
        
        NSString* tempKey = [NSString stringWithFormat:@":%@", key];
        [tempKeys addObject:tempKey];
    }
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ values (%@)",kCYGUrlTableName, [tempKeys componentsJoinedByString:@","]];
    return sql;
}

- (NSArray *)dbKeys{
    
    NSArray* keys = @[CYUrlModelReqUid,
                      CYUrlModelStatusCode,
                      CYUrlModelMimeType,
                      CYUrlModelErrorInfo,
                      CYUrlModelHttpMethod,
                      CYUrlModelReqUrl,
                      CYUrlModelReqPath,
                      CYUrlModelReqBody,
                      CYUrlModelReqHeaderFields,
                      CYUrlModelReqHeaderLength,
                      CYUrlModelReqBodyLength,
                      CYUrlModelResponseUrl,
                      CYUrlModelRespPath,
                      CYUrlModelResponseBody,
                      CYUrlModelResponseContent,
                      CYUrlModelResponseTime,
                      CYUrlModelRespHeaderFields,
                      CYUrlModelRespHeaderLength,
                      CYUrlModelRespBodyLength,
                      CYUrlModelStartDate,
                      CYUrlModelEndDate];
    
    return keys;
}

- (NSString *)databasePath {
    static NSString *databasePath = nil;
    if (!databasePath) {
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* name = [NSString stringWithFormat:@"%@.db", kCYGUrlDBName];
        databasePath = [cacheDirectory stringByAppendingPathComponent:name];
    }
    return databasePath;
}

- (void)insertOrUpdateDataToDB:(CYUrlAnalyseModel *)model {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        __block NSString* sqlStr = [self getTransactionSql];
        __block NSDictionary* dict = [model transformToDictionary];
        [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            [db executeUpdate:sqlStr withParameterDictionary:dict];
        }];
    });
}

- (void)insertOrUpdateDataListToDB:(NSArray <CYUrlAnalyseModel *> *)list {
    
    NSArray* dataList  = [list copy];
    [dataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CYUrlAnalyseModel * model = obj;
        [self insertOrUpdateDataToDB:model];
    }];
}

- (void)getModelListByRowId:(NSString *)rowId limit:(NSInteger)limit isAsc:(BOOL)isAsc callBack:(ListModelCallBack)callBack {
    
    if (!rowId || [rowId isEqualToString:@""]) {
        
        rowId = @"1";
    }
    
    if (limit <= 0 || limit > 50) {
        
        limit = 50;
    }
    
    NSString* sequence = isAsc ? @"asc" : @"desc";
    
    NSString* sqlStr = [NSString stringWithFormat:@"select * from %@ where rowid>=? order by rowid %@ limit %zi ", kCYGUrlTableName, sequence, limit];
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet* rs = [db executeQuery:sqlStr withArgumentsInArray:@[rowId]];
        NSArray* dataList = [self getDataModelListByResulteSet:rs];
        if (callBack) {
            callBack(dataList);
        }
    }];
}

- (CYUrlAnalyseModel *)getModelByResulteSet:(FMResultSet* )rs {
    
    CYUrlAnalyseModel * model = [[CYUrlAnalyseModel alloc] init];
    model.statusCode = [rs intForColumn:CYUrlModelStatusCode];
    model.requestUid = [rs stringForColumn:CYUrlModelReqUid];
    model.mimeType = [rs stringForColumn:CYUrlModelMimeType];
    model.errorInfo = [CYUrlAnalyseModel convertToDictionary:[rs stringForColumn:CYUrlModelErrorInfo]];
    model.httpMethod = [rs stringForColumn:CYUrlModelHttpMethod];
    model.requestUrl = [rs stringForColumn:CYUrlModelReqUrl];
    model.requestPath = [rs stringForColumn:CYUrlModelReqPath];
    model.requestBody = [rs stringForColumn:CYUrlModelReqBody];
    model.requestHeaderFields = [CYUrlAnalyseModel convertToDictionary:[rs stringForColumn:CYUrlModelReqHeaderFields]];
    model.requestHeaderLength = [CYUrlAnalyseModel convertToDouble:[rs stringForColumn:CYUrlModelReqHeaderLength]];
    model.requestBodyLength = [CYUrlAnalyseModel convertToDouble:[rs stringForColumn:CYUrlModelReqBodyLength]];
    model.responseUrl = [rs stringForColumn:CYUrlModelResponseUrl];
    model.responsePath = @"";
    model.responseBody = [rs stringForColumn:CYUrlModelResponseBody];
    model.responseContent = [rs stringForColumn:CYUrlModelResponseContent];
    model.responseTime = [CYUrlAnalyseModel convertToDouble:[rs stringForColumn:CYUrlModelResponseTime]];
    model.responseHeaderFields = [CYUrlAnalyseModel convertToDictionary:[rs stringForColumn:CYUrlModelRespHeaderFields]];
    model.responseHeaderLength = [CYUrlAnalyseModel convertToDouble:[rs stringForColumn:CYUrlModelRespHeaderLength]];
    model.responseBodyLength = [CYUrlAnalyseModel convertToDouble:[rs stringForColumn:CYUrlModelRespBodyLength]];
    model.startDate = [CYUrlAnalyseModel convertToDate:[rs stringForColumn:CYUrlModelStartDate]];
    model.endDate = [CYUrlAnalyseModel convertToDate:[rs stringForColumn:CYUrlModelEndDate]];
    
    return model;
}

- (NSArray <CYUrlAnalyseModel *> *)getDataModelListByResulteSet:(FMResultSet* )rs {
    
    NSMutableArray *result = [NSMutableArray array];
    while ([rs next]) {
        CYUrlAnalyseModel * model = [self getModelByResulteSet:rs];
        [result addObject:model];
    }
    [rs close];
    return result;
}

- (void)getDictListByRowId:(NSString *)rowId limit:(NSInteger)limit isAsc:(BOOL)isAsc customDBKeys:(NSArray <NSString *> *)keys callBack:(ListDictCallBack)callBack {
    
    self.customKeys = keys;
    
    if (!rowId || [rowId isEqualToString:@""]) {
        
        rowId = @"1";
    }
    
    if (limit <= 0 || limit > 50) {
        
        limit = 50;
    }
    
    NSString* sequence = isAsc ? @"asc" : @"desc";
    
    NSString* sqlStr = [NSString stringWithFormat:@"select * from %@ where rowid>=? order by rowid %@ limit %zi ", kCYGUrlTableName, sequence, limit];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet* rs = [db executeQuery:sqlStr withArgumentsInArray:@[rowId]];
        NSArray* dataList = [self getDataDictListByResulteSet:rs];
        if (callBack) {
            callBack(dataList);
        }
    }];
    
}

- (NSArray <NSDictionary *> *)getDataDictListByResulteSet:(FMResultSet* )rs {
    
    NSMutableArray *result = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary * dict = [self getDictByResulteSet:rs];
        [result addObject:dict];
    }
    [rs close];
    return result;
}

- (NSDictionary *)getDictByResulteSet:(FMResultSet* )rs {
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSArray* keys = (_customKeys && _customKeys.count > 0) ? _customKeys : [self dbKeys];
    for (NSString* key in keys) {
        NSString* value = [rs stringForColumn:key];
        dict[key] = value ? value : @"";
    }
    return dict;
}

- (void)getLatestRowId:(ListRowIdCallBack)callBack {
    
    NSString* sqlStr = [NSString stringWithFormat:@"select rowid, * from %@ order by rowid desc limit 1", kCYGUrlTableName];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet* rs = [db executeQuery:sqlStr];
        NSString* rowId = @"";
        while ([rs next]) {
            rowId = [rs stringForColumn:@"rowid"];
            break;
        }
        if (callBack) {
            callBack(rowId);
        }
        [rs close];
    }];
}

@end
