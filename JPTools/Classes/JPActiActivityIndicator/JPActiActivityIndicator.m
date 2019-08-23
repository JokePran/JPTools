//
//  SCCActiActivityIndicator.m
//
//  Created by imac on 2019/8/1.
//  Copyright © 2019 Sancochip. All rights reserved.
//

#import "JPActiActivityIndicator.h"

@implementation JPActiActivityIndicator
static UIActivityIndicatorView *_indicator;
+ (void)popActivityIndicator:(BOOL)isPop{
    UIViewController *topViewController = [[[UIApplication sharedApplication].delegate window] rootViewController];
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_indicator startAnimating];
        _indicator.center = topViewController.view.center;
        _indicator.color = kRGB(255,255,255);
    }

    if (isPop) {
        topViewController.view.userInteractionEnabled = NO;
        [topViewController.view addSubview:_indicator];
    }else{
        topViewController.view.userInteractionEnabled = YES;
        [_indicator removeFromSuperview];
    }
}
@end
