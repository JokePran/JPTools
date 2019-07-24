//
//  JPTimer.h
//  SCCLinkBuds
//
//  Created by imac on 2019/6/21.
//  Copyright © 2019 Sancochip. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPTimer : NSObject
/**
 通过SEL创建一个定时器任务
 */

+ (NSString *)excuteStart:(NSTimeInterval)start interval:(NSTimeInterval)interval
                  repeats:(BOOL)repeats
                    async:(BOOL)async target:(id)target selector:(SEL)selector;

/**
 通过block创建一个定时器任务
 */
+ (NSString *)excuteStart:(NSTimeInterval)start interval:(NSTimeInterval)interval
                  repeats:(BOOL)repeats
                    async:(BOOL)async task:(void(^)(void))task;

/**
 通过返回的标识取消定时器
 */
+ (void)cancelTask:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
