#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "JPAudioPlayer.h"
#import "JPPermenantThead.h"
#import "JPProgressHUD.h"
#import "JPSQLTools.h"
#import "JPTimer.h"

FOUNDATION_EXPORT double JPToolsVersionNumber;
FOUNDATION_EXPORT const unsigned char JPToolsVersionString[];

