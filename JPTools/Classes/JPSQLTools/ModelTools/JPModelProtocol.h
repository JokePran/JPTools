//
//  JPModelProtocol.h
//  JPSQLTool_Demo
//
//  Created by imac on 2019/7/26.
//  Copyright © 2019 Sancochip. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 用于配置数据库字段的协议类
 */
@protocol JPModelProtocol <NSObject>
@required
+ (NSString *)primaryKey;

@optional

/**
 忽略的不需要保存字段的数组

 @return 忽略的数组
 */
+ (NSArray *)ignoreColumnNames;

/**
 新字段名称-> 旧的字段名称的映射表格
 
 @return 映射表格
 */
+ (NSDictionary *)newNameToOldNameDic;
@end

NS_ASSUME_NONNULL_END
