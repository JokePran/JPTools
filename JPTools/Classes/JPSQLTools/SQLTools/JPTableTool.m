//
//  JPTableTool.m
//  JPSQLTool_Demo
//
//  Created by imac on 2019/7/26.
//  Copyright © 2019 Sancochip. All rights reserved.
//

#import "JPTableTool.h"
#import "JPModelTool.h"
#import "JPSQLTool.h"

@implementation JPTableTool
+ (NSArray *)tableSortedColumnNames:(Class)cls uid:(NSString *)uid{
    NSString *tableName = [JPModelTool tableName:cls];
    //通过sqlite_master管理数据库获取要找的库的字段
    NSString *queryCreateSqlStr = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'", tableName];
    NSMutableDictionary *dic = [JPSQLTool querySqlite:queryCreateSqlStr uid:uid].firstObject;
    NSString *createTableSql = dic[@"sql"];
    if (createTableSql.length == 0) {
        return nil;
    }
    createTableSql = [createTableSql stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
    createTableSql = [createTableSql stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    createTableSql = [createTableSql stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    createTableSql = [createTableSql stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSString *nameTypeStr = [createTableSql componentsSeparatedByString:@"("][1];
    
    NSArray *nameTypeArray = [nameTypeStr componentsSeparatedByString:@","];
    NSMutableArray *names = [NSMutableArray array];
    for (NSString *nameType in nameTypeArray) {
        
        if ([nameType containsString:@"primary"]) {
            continue;
        }
        NSString *nameType2 = [nameType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        // age integer
        NSString *name = [nameType2 componentsSeparatedByString:@" "].firstObject;
        [names addObject:name];
    }
    
    //将数组元素升序排序
    [names sortUsingComparator:^NSComparisonResult(NSString *obj1,NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    return names;
}

+ (BOOL)isTableExists:(Class)cls uid:(NSString *)uid {
    
    NSString *tableName = [JPModelTool tableName:cls];
    NSString *queryCreateSqlStr = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'", tableName];
    
    NSMutableArray *result = [JPSQLTool querySqlite:queryCreateSqlStr uid:uid];
    
    return result.count > 0;
}
@end
