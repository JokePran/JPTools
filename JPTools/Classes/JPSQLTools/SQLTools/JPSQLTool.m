//
//  JPSQLTool.m
//  JPTools
//
//  Created by imac on 2019/7/26.
//

#import "JPSQLTool.h"
#import "sqlite3.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
//#define kCachePath @"/Users/imac/Desktop"

@implementation JPSQLTool
sqlite3 *ppDb = nil;//存储打开对象地址

+ (BOOL)deal:(NSString *)sql uid:(NSString *)uid{
    
    if (![self openDB:uid]) {
        NSLog(@"数据库打开失败");
        return NO;
    }
    
    //执行数据库命令
    BOOL result = sqlite3_exec(ppDb, sql.UTF8String, nil, nil, nil) == SQLITE_OK;
    
    [self closeDB];
    return result;
}

+ (NSMutableArray <NSMutableDictionary *>*)querySqlite:(NSString *)sql uid:(NSString *)uid{
    [self openDB:uid];
    //1.创建准备语句(预处理)
    // 参数1: 一个已经打开的数据库
    // 参数2: 需要中的sql
    // 参数3: 参数2取出多少字节的长度 -1 自动计算 \0
    // 参数4: 准备语句
    // 参数5: 通过参数3, 取出参数2的长度字节之后, 剩下的字符串
    sqlite3_stmt *ppStmt = nil;//保存准备好的数据库对象
    if (sqlite3_prepare_v2(ppDb, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK) {
        NSLog(@"准备语句编译失败");
        return nil;
    }
    //2.执行
    NSMutableArray *rowDicArray = [NSMutableArray array];
    while (sqlite3_step(ppStmt) == SQLITE_ROW) {//将数据库指针向下移动一行
        //1.获取所有列个数
        int columeCount = sqlite3_column_count(ppStmt);
        
        NSMutableDictionary *rowDict = [NSMutableDictionary dictionary];
        [rowDicArray addObject:rowDict];
        //2.遍历所有列，获取列名和列值
        for (int i=0; i<columeCount; i++) {
            NSString *columeName = [NSString stringWithUTF8String:sqlite3_column_name(ppStmt, i)];
            
            //获取列类型：
            int type = sqlite3_column_type(ppStmt, i);
            id value = nil;
            switch (type) {
                case SQLITE_INTEGER:
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                case SQLITE_BLOB:
                    value = CFBridgingRelease(sqlite3_column_blob(ppStmt, i));
                    break;
                case SQLITE_NULL:
                    value = @"";
                    break;
                case SQLITE3_TEXT:
                    value = [NSString stringWithUTF8String: (const char *)sqlite3_column_text(ppStmt, i)];
                    break;
                    
                default:
                    break;
            }
            
            [rowDict setValue:value forKey:columeName];
        }
    }
    
    //3.释放资源
    sqlite3_finalize(ppStmt);
    [self closeDB];
    return rowDicArray;
}

+ (BOOL)dealSqls:(NSArray <NSString *>*)sqls uid:(NSString *)uid{
    [self beginTransaction:uid];
    for (NSString *sql in sqls) {
        BOOL result = [self deal:sql uid:uid];
        if (result == NO) {
            [self rollBackTransaction:uid];
            return NO;
        }
    }
    
    [self commitTransaction:uid];
    return YES;
}

#pragma mark - 事务操作
+ (void)beginTransaction:(NSString *)uid {
    [self deal:@"begin transaction" uid:uid];
}
+ (void)commitTransaction:(NSString *)uid {
    [self deal:@"commit transaction" uid:uid];
}
+ (void)rollBackTransaction:(NSString *)uid {
    [self deal:@"rollback transaction" uid:uid];
}


#pragma mark - private method
+ (BOOL)openDB:(NSString *)uid{
    NSString *dbName = @"common.sqlite";
    if (uid.length != 0) {
        dbName = [NSString stringWithFormat:@"%@.sqlite",uid];
    }
    NSString *dbPath = [kCachePath stringByAppendingPathComponent:dbName];
    
    //创建&打开数据库
    return sqlite3_open(dbPath.UTF8String, &ppDb) == SQLITE_OK;
}

+ (void)closeDB{
    //关闭数据库
    sqlite3_close(ppDb);
}


@end
