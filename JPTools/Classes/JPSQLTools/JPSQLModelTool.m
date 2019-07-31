//
//  JPSQLModelTool.m
//  JPTools
//
//  Created by imac on 2019/7/26.
//

#import "JPSQLModelTool.h"
#import "JPModelTool.h"
#import "JPSQLTool.h"
#import "JPTableTool.h"

@implementation JPSQLModelTool
+ (BOOL)createTable:(Class)cls uid:(NSString *)uid{
    //1.创建表格：create table if not exists 表名(字段1 字段1类型, 字段2 字段2类型 (约束),...., primary key(字段))
    //1.1获取表名
    NSString *tableName = [JPModelTool tableName:cls];
  
    //1.2获取类中所有属性
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"需要实现协议，从而传入主键");
        return NO;
    }
    NSString *primaryKey = [cls primaryKey];
    
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@))", tableName, [JPModelTool columnNamesAndTypesStr:cls], primaryKey];
    //2.执行数据库命令
    return [JPSQLTool deal:createTableSql uid:uid];
}


+ (BOOL)isTableRequiredUpdate:(Class)cls uid:(NSString *)uid {
    //当前类模型
    NSArray *modelNames = [JPModelTool allTableSortedIvarNames:cls];
    //数据库中的表模型
    NSArray *tableNames = [JPTableTool tableSortedColumnNames:cls uid:uid];
    
    return ![modelNames isEqualToArray:tableNames];
}

+ (BOOL)updateTable:(Class)cls uid:(NSString *)uid{
    //获取临时表格名称：
    NSString *tmpTableName = [JPModelTool tmpTableName:cls];
    NSString *tableName = [JPModelTool tableName:cls];
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"如果想要操作这个模型, 必须要实现+ (NSString *)primaryKey;这个方法, 告知主键信息");
        return NO;
    }
    
    //创建用于保存每一个数据库操作步骤的数组（防止有一步不成功能够回滚）
    NSMutableArray *execSqls = [NSMutableArray array];
    NSString *primaryKey = [cls primaryKey];
    //创建临时表
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@));", tmpTableName, [JPModelTool columnNamesAndTypesStr:cls], primaryKey];
    [execSqls addObject:createTableSql];
    
    //将原来表中存的主键的数据放入临时表中
    NSString *insertPrimaryKeyData = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@;", tmpTableName, primaryKey, primaryKey, tableName];
    [execSqls addObject:insertPrimaryKeyData];
    
    //获取原来表中的属性名
    NSArray *oldNames = [JPTableTool tableSortedColumnNames:cls uid:uid];
    //获取当前模型属性名称
    NSArray *newNames = [JPModelTool allTableSortedIvarNames:cls];
    
    //获取要直接改名的字典
    NSDictionary *newNameToOldNameDic = @{};
    if ([cls respondsToSelector:@selector(newNameToOldNameDic)]) {
        newNameToOldNameDic = [cls newNameToOldNameDic];
    }
    
    for (NSString *columnName in newNames) {
        NSString *oldName = columnName;
        //找到原来的需要更改名字前老的字段名称
        if ([newNameToOldNameDic[columnName] length] != 0) {
            oldName = newNameToOldNameDic[columnName];
        }
        
        if ((![oldNames containsObject:columnName] && ![oldNames containsObject:oldName]) || [columnName isEqualToString:primaryKey]) {
            continue;
        }
        //将除了主键以外的需要更新的属性名的值全部移动到临时表
        // update 临时表 set 新字段名称 = (select 旧字段名 from 旧表 where 临时表.主键 = 旧表.主键)
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@)", tmpTableName, columnName, oldName, tableName, tmpTableName, primaryKey, tableName, primaryKey];
        [execSqls addObject:updateSql];
    }
    //删除老表
    NSString *deleteOldTable = [NSString stringWithFormat:@"drop table if exists %@", tableName];
    [execSqls addObject:deleteOldTable];
    
    //将临时表名称更换
    NSString *renameTableName = [NSString stringWithFormat:@"alter table %@ rename to %@", tmpTableName, tableName];
    [execSqls addObject:renameTableName];
    
    return [JPSQLTool dealSqls:execSqls uid:uid];
}


+ (BOOL)saveOrUpdateModel:(id)model uid:(NSString *)uid {
    // 如果用户再使用过程中, 直接调用这个方法, 去保存模型
    // 保存一个模型
    Class cls = [model class];
    // 1. 判断表格是否存在, 不存在, 则创建
    if (![JPTableTool isTableExists:cls uid:uid]) {
        [self createTable:cls uid:uid];
    }
    // 2. 检测表格是否需要更新, 需要, 更新
    if ([self isTableRequiredUpdate:cls uid:uid]) {
        [self updateTable:cls uid:uid];
    }
    
    // 3. 判断记录是否存在, 主键
    // 从表格里面, 按照主键, 进行查询该记录, 如果能够查询到
    NSString *tableName = [JPModelTool tableName:cls];
    
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"如果想要操作这个模型, 必须要实现+ (NSString *)primaryKey;这个方法, 来告诉我主键信息");
        return NO;
    }
    NSString *primaryKey = [cls primaryKey];
    id primaryValue = [model valueForKeyPath:primaryKey];
    
    NSString *checkSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'", tableName, primaryKey, primaryValue];
    NSArray *result = [JPSQLTool querySqlite:checkSql uid:uid];
    
    
    // 获取字段数组
    NSArray *columnNames = [JPModelTool classIvarNameTypeDic:cls].allKeys;
    
    // 获取值数组
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *columnName in columnNames) {
        id value = [model valueForKeyPath:columnName];
        
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            //将数组和字典变成字符串存入数据库
            //字典和数组转成NSData
            NSData *data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
            value = [[NSString alloc] initWithData:data encoding:kCFStringEncodingUTF8];
        }
        [values addObject:value];
    }
    
    NSInteger count = columnNames.count;
    NSMutableArray *setValueArray = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        NSString *name = columnNames[i];
        id value = values[i];
        NSString *setStr = [NSString stringWithFormat:@"%@='%@'", name, value];
        [setValueArray addObject:setStr];
    }
    
    // 更新
    // 字段名称, 字段值
    // update 表名 set 字段1=字段1值,字段2=字段2的值... where 主键 = '主键值'
    NSString *execSql = @"";
    if (result.count > 0) {
        execSql = [NSString stringWithFormat:@"update %@ set %@  where %@ = '%@'", tableName, [setValueArray componentsJoinedByString:@","], primaryKey, primaryValue];
        
        
    }else {
        // insert into 表名(字段1, 字段2, 字段3) values ('值1', '值2', '值3')
        // '   值1', '值2', '值3   '
        // 插入
        // text sz 'sz' 2 '2'
        execSql = [NSString stringWithFormat:@"insert into %@(%@) values('%@')", tableName, [columnNames componentsJoinedByString:@","], [values componentsJoinedByString:@"','"]];
    }
    return [JPSQLTool deal:execSql uid:uid];
}

+ (BOOL)deleteModel:(id)model uid:(NSString *)uid{
    Class cls = [model class];
    NSString *tableName = [JPModelTool tableName:cls];
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"如果想要操作这个模型, 必须要实现+ (NSString *)primaryKey;这个方法, 来告诉我主键信息");
        return NO;
    }
    NSString *primaryKey = [cls primaryKey];
    id primaryValue = [model valueForKeyPath:primaryKey];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'", tableName, primaryKey, primaryValue];
    
    return [JPSQLTool deal:deleteSql uid:uid];
    
}

+ (BOOL)deleteModel:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid {
    NSString *tableName = [JPModelTool tableName:cls];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@", tableName];
    if (whereStr.length > 0) {
        deleteSql = [deleteSql stringByAppendingFormat:@" where %@", whereStr];
    }
    return [JPSQLTool deal:deleteSql uid:uid];
    
}

+ (BOOL)deleteModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(NSString *)uid{
    NSString *tableName = [JPModelTool tableName:cls];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ %@ '%@'", tableName, name, self.ColumnNameToValueRelationTypeDic[@(relation)], value];
    // 假设肯定传
    return [JPSQLTool deal:deleteSql uid:uid];
}


+ (NSArray *)queryAllModels:(Class)cls uid:(NSString *)uid{
    NSString *tableName = [JPModelTool tableName:cls];
    NSString *sql = [NSString stringWithFormat:@"select * from %@", tableName];
    //获取数据库中存的数据组成的字典数组
    NSArray <NSDictionary *>*results = [JPSQLTool querySqlite:sql uid:uid];
    //根据字典生成Model
    return [self parseResults:results withClass:cls];
}

+ (NSArray *)queryModels:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(NSString *)uid{
    NSString *tableName = [JPModelTool tableName:cls];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ %@ '%@' ", tableName, name, self.ColumnNameToValueRelationTypeDic[@(relation)], value];
    NSArray <NSDictionary *>*results = [JPSQLTool querySqlite:sql uid:uid];
    return [self parseResults:results withClass:cls];
}

+ (NSArray *)queryModels:(Class)cls WithSql:(NSString *)sql uid:(NSString *)uid{
    NSArray <NSDictionary *>*results = [JPSQLTool querySqlite:sql uid:uid];
    return [self parseResults:results withClass:cls];
}

#pragma mark - Private Method
+ (NSArray *)parseResults:(NSArray <NSDictionary *>*)results withClass:(Class)cls {
    NSMutableArray *models = [NSMutableArray array];
    NSDictionary *nameTypeDic = [JPModelTool classIvarNameTypeDic:cls];
    for (NSDictionary *modelDic in results) {
        id model = [[cls alloc] init];
        [models addObject:model];
        [modelDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString *type = nameTypeDic[key];
            id resultValue = obj;
            if ([type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSDictionary"]) {
                //反序列化，把数据库中的字符串转回数组和字典
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                //kNilOptions 转化成不可变的集合
                resultValue = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            }else if ([type isEqualToString:@"NSMutableArray"] || [type isEqualToString:@"NSMutableDictionary"]){
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                //NSJSONReadingMutableContainers 转化成可变的集合
                resultValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            
            [model setValue:resultValue forKey:key];
        }];
    }
    return models;
}

//数据库判断关系映射表
+ (NSDictionary *)ColumnNameToValueRelationTypeDic {
    return @{
             @(ColumnNameToValueRelationTypeMore):@">",
             @(ColumnNameToValueRelationTypeLess):@"<",
             @(ColumnNameToValueRelationTypeEqual):@"=",
             @(ColumnNameToValueRelationTypeMoreEqual):@">=",
             @(ColumnNameToValueRelationTypeLessEqual):@"<="
             };
}


@end
