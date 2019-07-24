//
//  JPAudioPlayer.h
//  JPLinkBuds
//
//  Created by imac on 2018/3/19.
//  Copyright © 2018年 Sancochip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    JPPlayModeAll,
    JPPlayModeSingle,
    JPPlayModeRandom
} JPPlayMode;

typedef enum : NSUInteger {
    JPPlayerStatusStop,
    JPPlayerStatusPlaying,
    JPPlayerStatusPause
} JPPlayerStatus;

extern const NSNotificationName JPPlayStatusDidChangeNotification;
extern const NSNotificationName JPPlayingItemDidChangeNotification;
extern const NSNotificationName JPVolumeDidChangeNotification;

@interface JPAudioItem : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *albumImageStr;
@property (nonatomic, strong) AVPlayerItem *item;
@property (nonatomic, strong) NSString *url;
@end

@interface JPAudioPlayer : NSObject
@property (nonatomic,assign) JPPlayerStatus status;
@property (nonatomic,assign) JPPlayMode playMode;

@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,strong) JPAudioItem *nowPlayingItem;

@property (nonatomic,strong) NSArray <JPAudioItem *> *musicList;
@property (nonatomic,assign) BOOL openRemoteCommandCenter;//是否接收控制台指令
@property (nonatomic,assign) NSTimeInterval currentPlaybackTime;
@property (nonatomic,assign,readonly) NSTimeInterval totalPlaybackTime;
@property (nonatomic,assign) CGFloat volume;

+ (instancetype)shareManager;

-(BOOL)prepareToPlayWithIndex:(NSInteger)index;
- (void)play;
- (void)pause;
- (void)stop;

- (void)skipToNextItem;
- (void)skipToBeginning;
- (void)skipToPreviousItem;

@end
