//
//  JPModelTool.h
//  JPTools
//
//  Created by imac on 2019/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 用于动态获取Model类中信息的工具类
 */
@interface JPModelTool : NSObject

/**
 Model的数据库表名
 */
+ (NSString *)tableName:(Class)cls;
/**
 Model的临时数据库表名
 */
+ (NSString *)tmpTableName:(Class)cls;
/**
 获取类中所有成员变量，以及成员变量对应的类型

 @param cls 类
 @return 成员变量字典
 */
+ (NSDictionary *)classIvarNameTypeDic:(Class)cls;

/**
 获取类中所有成员变量，以及成员变量映射到数据库里面对应的类型
 
 @param cls 类
 @return 成员变量字典
 */
+ (NSDictionary *)classIvarNameSqliteTypeDic:(Class)cls;

/**
 用于将类的属性拼接成为数据库字段

 @param cls 类
 @return 拼接后的数据库字符串
 */
+ (NSString *)columnNamesAndTypesStr:(Class)cls;

/**
 用于将类中的属性名进行升序排序

 @param cls 类
 @return 属性名升序排序后的数组
 */
+ (NSArray *)allTableSortedIvarNames:(Class)cls;
@end



NS_ASSUME_NONNULL_END
