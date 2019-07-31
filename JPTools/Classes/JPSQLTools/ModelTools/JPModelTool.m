//
//  JPModelTool.m
//  JPTools
//
//  Created by imac on 2019/7/26.
//

#import "JPModelTool.h"
#import "JPModelProtocol.h"
#import <objc/runtime.h>

@implementation JPModelTool
+ (NSString *)tableName:(Class)cls{
    return NSStringFromClass(cls);
}
+ (NSString *)tmpTableName:(Class)cls{
    return [NSStringFromClass(cls) stringByAppendingString:@"_tmp"];
}

+ (NSDictionary *)classIvarNameTypeDic:(Class)cls{
    unsigned int outCount = 0;
    Ivar *varList = class_copyIvarList(cls, &outCount);
    NSMutableDictionary *nameTypeDic = [NSMutableDictionary dictionary];
    
    NSArray *ignoreNames = nil;
    if ([cls respondsToSelector:@selector(ignoreColumnNames)]) {
        ignoreNames = [cls ignoreColumnNames];
    }
    
    for (int i=0; i<outCount; i++) {
        Ivar ivar = varList[i];
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([ivarName hasPrefix:@"_"]) {
            ivarName = [ivarName substringFromIndex:1];
        }
        if([ignoreNames containsObject:ivarName]) {
            continue;
        }
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        type = [type stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        [nameTypeDic setValue:type forKey:ivarName];
    }
    return nameTypeDic;
}


+ (NSDictionary *)classIvarNameSqliteTypeDic:(Class)cls{
    NSMutableDictionary *dic = [[self classIvarNameTypeDic:cls] mutableCopy];
    NSDictionary *typeDic = [self ocTypeToSqliteTypeDic];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString *obj, BOOL * _Nonnull stop) {
        dic[key] = typeDic[obj];
    }];
    return dic;
}

+ (NSString *)columnNamesAndTypesStr:(Class)cls{
    NSDictionary *nameTypeDic = [self classIvarNameTypeDic:cls];
    NSMutableArray *appendArr = [NSMutableArray array];
    [nameTypeDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        [appendArr addObject:[NSString stringWithFormat:@"%@ %@", key, obj]];
    }];
    return [appendArr componentsJoinedByString:@","];
}

+ (NSArray *)allTableSortedIvarNames:(Class)cls{
    NSDictionary *dic = [self classIvarNameTypeDic:cls];
    NSArray *keys = dic.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    return keys;
}

#pragma mark - private method
#pragma mark - OC和数据库映射表
+ (NSDictionary *)ocTypeToSqliteTypeDic {
    return @{
             @"d": @"real", // double
             @"f": @"real", // float
             
             @"i": @"integer",  // int
             @"q": @"integer", // long
             @"Q": @"integer", // long long
             @"B": @"integer", // bool
             
             @"NSData": @"blob",
             @"NSDictionary": @"text",
             @"NSMutableDictionary": @"text",
             @"NSArray": @"text",
             @"NSMutableArray": @"text",
             
             @"NSString": @"text"
             };
    
}
@end
