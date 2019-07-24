//
//  JPPermenantThead.h
//  SCCLinkBuds
//
//  Created by imac on 2019/6/13.
//  Copyright © 2019 Sancochip. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPPermenantThead : NSObject
/**
 开启一个子线程执行任务:仅用于iOS10以上
 */
- (void)executeTask:(void(^)(void))task;

/**
 停止子线程
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
