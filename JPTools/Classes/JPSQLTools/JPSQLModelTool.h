//
//  JPSQLModelTool.h
//  JPTools
//
//  Created by imac on 2019/7/26.
//

#import <Foundation/Foundation.h>
#import "JPModelProtocol.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, ColumnNameToValueRelationType) {
    ColumnNameToValueRelationTypeMore,
    ColumnNameToValueRelationTypeLess,
    ColumnNameToValueRelationTypeEqual,
    ColumnNameToValueRelationTypeMoreEqual,//大于等于
    ColumnNameToValueRelationTypeLessEqual,//小于等于
};


/**
 用于操作模型和数据库的中间层工具
 */
@interface JPSQLModelTool : NSObject
+ (BOOL)createTable:(Class)cls uid:(NSString *)uid;

/**
 判断数据库中的属性是否需要更新（一旦用户修改了属性就需要更新）
 */
+ (BOOL)isTableRequiredUpdate:(Class)cls uid:(NSString *)uid;

/**
 更新数据库
 */
+ (BOOL)updateTable:(Class)cls uid:(NSString *)uid;

/**
 保存和更新数据库模型
 */
+ (BOOL)saveOrUpdateModel:(id)model uid:(NSString *)uid;

/**
 删除数据库模型
 */
+ (BOOL)deleteModel:(id)model uid:(NSString *)uid;

/**
 根据条件删除数据库（通过数据库语句）

 @param cls 类
 @param whereStr 数据库语句，例@"score <= 4"
 @param uid 数据库名
 @return 成功与否
 */
+ (BOOL)deleteModel:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid;


/**
 根据条件删除数据库（通过枚举来控制）

 @param cls 类
 @param name 字段名（属性）
 @param relation 大于，小于，等于之类的枚举
 @param value 关系大小，例：大于4就写4
 @param uid 数据库名
 @return 成功与否
 */
+ (BOOL)deleteModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(NSString *)uid;


/**
 查询所有存储在数据库中的数据，并返回相应Model

 @param cls 类
 @param uid 数据库名
 @return 返回这个类存在数据库中的Model数组
 */
+ (NSArray *)queryAllModels:(Class)cls uid:(NSString *)uid;

/**
 根据条件查询相应存储的数据并生成模型

 @param cls 类
 @param name 字段名（属性）
 @param relation 大于，小于，等于之类的枚举
 @param value 关系大小，例：大于4就写4
 @param uid 数据库名
 @return 返回的模型数组
 */
+ (NSArray *)queryModels:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(NSString *)uid;


/**
 根据传入的查询数据库命令查询并返回Model数组

 @param cls 类
 @param sql 数据库命令
 @param uid 数据库名
 @return 返回的模型数组
 */
+ (NSArray *)queryModels:(Class)cls WithSql:(NSString *)sql uid:(NSString *)uid;
@end

NS_ASSUME_NONNULL_END
