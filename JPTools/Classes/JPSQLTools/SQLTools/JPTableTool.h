//
//  JPTableTool.h
//  JPSQLTool_Demo
//
//  Created by imac on 2019/7/26.
//  Copyright © 2019 Sancochip. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 用于对数据库表操作的工具类
 */
@interface JPTableTool : NSObject

/**
 获取表格中所有的排序后字段
 
 @param cls 类名
 @param uid 用户唯一标识
 @return 字段数组
 */
+ (NSArray *)tableSortedColumnNames:(Class)cls uid:(NSString *)uid;


/**
 判断该模型是否在数据库中存在

 @param cls 类
 @param uid 数据库
 @return 是否存在
 */
+ (BOOL)isTableExists:(Class)cls uid:(NSString *)uid;
@end

NS_ASSUME_NONNULL_END
