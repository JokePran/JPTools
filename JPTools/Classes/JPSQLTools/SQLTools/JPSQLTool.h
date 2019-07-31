//
//  JPSQLTool.h
//  JPTools
//
//  Created by imac on 2019/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 专门用于操作数据库的类：
 需要导入libsqlite3.0.tdb动态库
 */
@interface JPSQLTool : NSObject

/**
 操作数据库

 @param sql 数据库操作命令,包括增删改记录, 创建删除表格等等无结果集操作
 @param uid 要操作的数据库名称
 @return 成功或者失败
 */
+ (BOOL)deal:(NSString *)sql uid:(NSString *)uid;

/**
 查询数据库

 @param sql 数据库操作命令
 @param uid 要操作的数据库名称
 @return 返回一行数据的数组
 */
+ (NSMutableArray <NSMutableDictionary *>*)querySqlite:(NSString *)sql uid:(NSString *)uid;

/**
 同时处理多条语句,数据库事务操作

 @param sqls 所有要操作数据库步骤的数组
 @param uid 数据库名
 @return 成功与否
 */
+ (BOOL)dealSqls:(NSArray <NSString *>*)sqls uid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
