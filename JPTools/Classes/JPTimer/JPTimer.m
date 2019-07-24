//
//  JPTimer.m
//  SCCLinkBuds
//
//  Created by imac on 2019/6/21.
//  Copyright © 2019 Sancochip. All rights reserved.
//

#import "JPTimer.h"
@implementation JPTimer
static NSMutableDictionary *timers_;
dispatch_semaphore_t semaphore_;//锁
+(void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers_ = [NSMutableDictionary dictionary];
        semaphore_ = dispatch_semaphore_create(1);//只允许一条线程进入
    });
}

+(NSString *)excuteStart:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async task:(void (^)(void))task{
    
    if (!task || start<0 || (interval <= 0 && repeats)) return nil;
    
    //创建队列
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    //创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //定时器设置时间
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    
    //修改字典，加锁
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    NSString *name = [NSString stringWithFormat:@"%zd", timers_.count];
    timers_[name] = timer;
    dispatch_semaphore_signal(semaphore_);
    
    //设置回调
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!async) {//不重复任务
            [self cancelTask:name];
        }
    });
    
    // 启动定时器
    dispatch_resume(timer);
    return name;
}

+(NSString *)excuteStart:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async target:(id)target selector:(SEL)selector{
    if (!target || !selector) return nil;
    
    return [self excuteStart:start interval:interval repeats:repeats async:async task:^{
        if ([target respondsToSelector:selector]) {
            //去掉警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector];
#pragma clang diagnostic pop
        }
    }];
}

+(void)cancelTask:(NSString *)name{
    if (name.length == 0) return;
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = timers_[name];
    if (timer) {
        dispatch_source_cancel(timer);
        [timers_ removeObjectForKey:name];
    }
    dispatch_semaphore_signal(semaphore_);
}


@end
