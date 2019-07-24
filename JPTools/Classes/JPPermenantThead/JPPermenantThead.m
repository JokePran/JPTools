//
//  JPPermenantThead.m
//  SCCLinkBuds
//
//  Created by imac on 2019/6/13.
//  Copyright © 2019 Sancochip. All rights reserved.
//

#import "JPPermenantThead.h"
@interface JPPermenantThead()
@property (nonatomic, strong) NSThread *innerThread;
@property (nonatomic, assign) BOOL isStopped;
@end

@implementation JPPermenantThead
- (instancetype)init{
    self = [super init];
    if (self) {
        self.isStopped = NO;
        __weak typeof(self) weakSelf = self;
        if (@available(iOS 10.0, *)) {
            self.innerThread = [[NSThread alloc] initWithBlock:^{
                //给runloop加入source让其无法销毁
                [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
                //runloop一旦唤醒执行后重新进入休眠等待任务
                while (weakSelf && !weakSelf.isStopped) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
            }];
        } else {
            NSLog(@">>>>>>>仅用于iOS10以上<<<<<<<<<<");
        }
        [self.innerThread start];
    }
    return self;
}

-(void)executeTask:(void (^)(void))task{
    if (!self.innerThread || !task) return;
    [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];
}

-(void)stop{
    if (!self.innerThread) return;
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
    
}
//主动销毁当前线程
-(void)dealloc{
    [self stop];
}

#pragma mark - private methods
- (void)__stop{
    self.isStopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}

- (void)__executeTask:(void(^)(void))task{
    task();
}
@end
