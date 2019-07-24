//
//  JPProgressHUD.m
//  BLEProject
//
//  Created by jp on 2016/12/9.
//  Copyright © 2016年 jp. All rights reserved.
//

#import "JPProgressHUD.h"

@interface JPProgressHUD ()

@property (nonatomic,strong) NSTimer *timer;

@end

@implementation JPProgressHUD



+(void)showMessage:(NSString *)message{

    dispatch_async(dispatch_get_main_queue(), ^{
        JPProgressHUD *currentHUD = [JPProgressHUD sharedView];
        [currentHUD removeFromSuperview];
        UILabel *currentLabel = [JPProgressHUD sharedLabel];
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        currentLabel.frame = CGRectMake(10, 10, currentWindow.bounds.size.width, 10);
        currentLabel.text = message;
        currentLabel.font = [UIFont systemFontOfSize:15];
        currentLabel.textColor = [UIColor whiteColor];
        currentLabel.textAlignment = NSTextAlignmentCenter;
        [currentLabel sizeToFit];
        currentHUD.center = currentWindow.center;
        currentHUD.bounds = CGRectMake(0, 0, currentLabel.bounds.size.width+20, currentLabel.bounds.size.height+20);
        currentHUD.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        currentHUD.layer.masksToBounds = YES;
        currentHUD.layer.cornerRadius = 10.0f;
        [currentHUD addSubview:currentLabel];
        [currentWindow addSubview:currentHUD];
        [currentHUD timerStart];
    });
}

- (NSTimer *)timer {
    
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(removeHUD:) userInfo:nil repeats:NO];
    }
    return _timer;
}

- (void)timerStart {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [self timer];
}

- (void)removeHUD:(NSTimer *)timer {
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[JPProgressHUD sharedView] removeFromSuperview];
    });
}

+ (JPProgressHUD*)sharedView{
    static dispatch_once_t once;
    
    static JPProgressHUD *sharedView;
    

    dispatch_once(&once, ^{
        
        sharedView = [[self alloc] init];

    });

    return sharedView;
}


+ (UILabel *)sharedLabel{
    static dispatch_once_t once;
    
    static UILabel *shareLabel;
    
    
    dispatch_once(&once, ^{
        
        shareLabel = [[UILabel alloc] init];
        
    });
    
    return shareLabel;

}






@end
