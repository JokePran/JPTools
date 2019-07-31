//
//  JPSqliteTest.m
//  JPTools_Example
//
//  Created by imac on 2019/7/26.
//  Copyright © 2019 jokepran@163.com. All rights reserved.
//

#import "JPSqliteTest.h"
#import <JPSQLTool.h>
#import <JPModelTool.h>
#import "JPStu.h"
@implementation JPSqliteTest
- (instancetype)init
{
    self = [super init];
    if (self) {
//        [self testDeal];
//        [self testQuery];
        [self testIvar];
    }
    return self;
}

-(void)testDeal{
    NSString *sql = @"create table if not exists t_stu(id integer primary key autoincrement, name text not null, age integer, score real)";
    BOOL result = [JPSQLTool deal:sql uid:@""];
    NSLog(@"%d",result);
}
-(void)testQuery{
    NSString *sql = @"select * from t_stu";
    NSMutableArray *result = [JPSQLTool querySqlite:sql uid:@""];
    NSLog(@"%@", result);
}
-(void)testIvar{
    NSLog(@"%@",[JPModelTool classIvarNameTypeDic:[JPStu class]]);
}

@end
