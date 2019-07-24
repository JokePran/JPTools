//
//  JPAudioPlayer.m
//  JPLinkBuds
//
//  Created by imac on 2018/3/19.
//  Copyright © 2018年 Sancochip. All rights reserved.
//

#import "JPAudioPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

const NSNotificationName _Nonnull JPPlayStatusDidChangeNotification = @"JPPlayStatusDidChangeNotification";
const NSNotificationName _Nonnull JPPlayingItemDidChangeNotification = @"JPPlayingItemDidChangeNotification";
const NSNotificationName _Nonnull JPVolumeDidChangeNotification = @"JPVolumeDidChangeNotification";
@interface JPAudioPlayer()
@property (nonatomic, strong) AVPlayer *player;
@end
@implementation JPAudioPlayer
@synthesize musicList = _musicList;
@synthesize nowPlayingItem = _nowPlayingItem;

+ (instancetype)shareManager{
    static JPAudioPlayer *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JPAudioPlayer alloc] init];
        [manager createRemoteCommandCenter];
        [[MPMusicPlayerController applicationMusicPlayer] beginGeneratingPlaybackNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(playFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(systemVolumeChangeNotification) name:MPMusicPlayerControllerVolumeDidChangeNotification object:nil];
    });
    return manager;
}

- (void)play{
    if (!self.player.currentItem) {
        JPAudioItem *item = _musicList.firstObject;
        [self.player replaceCurrentItemWithPlayerItem:item.item];
        _nowPlayingItem = item;
        [[NSNotificationCenter defaultCenter] postNotificationName:JPPlayingItemDidChangeNotification object:nil];
    }
    [self showLockScreenTotaltime:self.totalPlaybackTime andCurrentTime:self.currentPlaybackTime WithItem:self.nowPlayingItem];
    [self.player play];
    self.status = JPPlayerStatusPlaying;
    [[NSNotificationCenter defaultCenter] postNotificationName:JPPlayStatusDidChangeNotification object:nil];
}
- (void)pause{
    [self.player pause];
    self.status = JPPlayerStatusPause;
    [[NSNotificationCenter defaultCenter] postNotificationName:JPPlayStatusDidChangeNotification object:nil];
}
- (void)stop{
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.status = JPPlayerStatusStop;
    [[NSNotificationCenter defaultCenter] postNotificationName:JPPlayStatusDidChangeNotification object:nil];
}

- (void)skipToNextItem{
    [self.player replaceCurrentItemWithPlayerItem:nil];
    if (_musicList.count) {
        switch (_playMode) {
            case JPPlayModeSingle:
            case JPPlayModeAll:{
                _currentIndex = (_currentIndex + 1)%_musicList.count;
            }
                break;
            case JPPlayModeRandom:{
                _currentIndex = arc4random()%_musicList.count;
            }
                break;
            default:
                break;
        }
        JPAudioItem *item = _musicList[_currentIndex];
        [self.player replaceCurrentItemWithPlayerItem:item.item];
        _nowPlayingItem = item;
        [[NSNotificationCenter defaultCenter] postNotificationName:JPPlayingItemDidChangeNotification object:nil];
    }
    [self skipToBeginning];
    [self play];
}

- (void)skipToPreviousItem{
    [self.player replaceCurrentItemWithPlayerItem:nil];
    if (_musicList.count) {
        switch (_playMode) {
            case JPPlayModeSingle:
            case JPPlayModeAll:{
                _currentIndex -= 1;
                if (_currentIndex < 0) {
                    _currentIndex = _musicList.count  - 1;
                }
            }
                break;
            case JPPlayModeRandom:{
                _currentIndex = arc4random()%_musicList.count;
            }
                break;
            default:
                break;
        }
        JPAudioItem *item = _musicList[_currentIndex];
        [self.player replaceCurrentItemWithPlayerItem:item.item];
        _nowPlayingItem = item;
        [[NSNotificationCenter defaultCenter] postNotificationName:JPPlayingItemDidChangeNotification object:nil];
    }
    [self skipToBeginning];
    [self play];
}

- (void)skipToBeginning{
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self play];
}

-(void)setCurrentIndex:(NSInteger)currentIndex{
    if (currentIndex < 0 || currentIndex >= _musicList.count) {
        return;
    }
    [self stop];
    _currentIndex = currentIndex;
    JPAudioItem *item = _musicList[currentIndex];
    [self.player replaceCurrentItemWithPlayerItem:item.item];
    _nowPlayingItem = item;
    [[NSNotificationCenter defaultCenter] postNotificationName:JPPlayingItemDidChangeNotification object:nil];
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self play];
}

-(BOOL)prepareToPlayWithIndex:(NSInteger)index{
    if (index < 0 || index >= _musicList.count) {
        return NO;
    }
    [self stop];
    _currentIndex = index;
    JPAudioItem *item = _musicList[index];
    [self.player replaceCurrentItemWithPlayerItem:item.item];
    _nowPlayingItem = item;
    [[NSNotificationCenter defaultCenter] postNotificationName:JPPlayingItemDidChangeNotification object:nil];
    return YES;
}

#pragma mark - Notification
-(void)playFinish{
    switch (_playMode) {
        case JPPlayModeAll:{
            [self skipToNextItem];
            break;
        }
        case JPPlayModeSingle:{
            [self skipToBeginning];
            break;
        }
        case JPPlayModeRandom:{
            [self setCurrentIndex:arc4random()%self.musicList.count];
            break;
        }
        default:
            break;
    }
}

-(void)systemVolumeChangeNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:JPVolumeDidChangeNotification object:nil];
}

#pragma mark - setter getter
-(AVPlayer *)player{
    __weak __typeof(self) weakSelf = self;
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [weakSelf showLockScreenTotaltime:weakSelf.totalPlaybackTime andCurrentTime:weakSelf.currentPlaybackTime WithItem:weakSelf.nowPlayingItem];
        }];
    }
    return _player;
}

-(void)setNowPlayingItem:(JPAudioItem *)nowPlayingItem{
    [self setCurrentIndex:[self.musicList indexOfObject:nowPlayingItem]];
}

-(JPAudioItem *)nowPlayingItem{
    if (_musicList.count > self.currentIndex) {
        return _musicList[self.currentIndex];
    }
    return nil;
}

-(void)setVolume:(CGFloat)volume{
    [MPMusicPlayerController systemMusicPlayer].volume = volume;
    [[NSNotificationCenter defaultCenter] postNotificationName:JPVolumeDidChangeNotification object:nil];
}
-(CGFloat)volume{
    return [MPMusicPlayerController systemMusicPlayer].volume;
}

-(NSTimeInterval)totalPlaybackTime{
    return self.player.currentItem.duration.value/self.player.currentItem.duration.timescale;
}
-(NSTimeInterval)currentPlaybackTime{
    NSTimeInterval time = 0;
    if (self.player.currentItem.currentTime.timescale) {
        time = self.player.currentItem.currentTime.value/self.player.currentItem.currentTime.timescale;
    }
    return time;
}
-(void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime{
    if (!self.player.currentItem) {
        return;
    }
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    [self.player.currentItem seekToTime:CMTimeMake((long)currentPlaybackTime * self.player.currentItem.currentTime.timescale, self.player.currentItem.currentTime.timescale) completionHandler:^(BOOL finished) {
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
    }];
}
-(void)setMusicList:(NSArray<JPAudioItem *> *)musicList{
    _musicList = musicList;
//    if (musicList.count>0) {
//        JPAudioItem *item = musicList.firstObject;
//        [self.player replaceCurrentItemWithPlayerItem:item.item];
//        _currentIndex = 0;
//    }
}

//展示锁屏歌曲信息：图片、歌词、进度、演唱者
- (void)showLockScreenTotaltime:(float)totalTime andCurrentTime:(float)currentTime WithItem:(JPAudioItem *)item{
    NSMutableDictionary * songDict = [[NSMutableDictionary alloc] init];
    //设置歌曲题目
    [songDict setObject:item.title?item.title:@"" forKey:MPMediaItemPropertyTitle];
    //设置歌手名
    [songDict setObject:item.artist?item.artist:@"" forKey:MPMediaItemPropertyArtist];
//    //设置专辑名
//    [songDict setObject:item.albumTitle?item.albumTitle:@"" forKey:MPMediaItemPropertyAlbumTitle];
    //设置歌曲时长
    [songDict setObject:[NSNumber numberWithDouble:self.totalPlaybackTime]  forKey:MPMediaItemPropertyPlaybackDuration];
    //设置已经播放时长
    [songDict setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    //设置显示的海报图片
//    [songDict setObject:item.albumImage?item.albumImage:[[MPMediaItemArtwork alloc] initWithImage:[UIImage new]]
//                 forKey:MPMediaItemPropertyArtwork];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songDict];
}

//锁屏界面开启和监控远程控制事件
- (void)createRemoteCommandCenter{
//    self.openRemoteCommandCenter = YES;
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    //添加不喜欢按钮，假装是“上一首”
    MPRemoteCommand *previousCommand = commandCenter.previousTrackCommand;
    previousCommand.enabled = YES;
    [previousCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"上一首");
        if (_openRemoteCommandCenter) {
            [self skipToPreviousItem];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    //标记
    MPRemoteCommand *nextCommand = commandCenter.nextTrackCommand;
    nextCommand.enabled = YES;
    [nextCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"下一首");
        if (_openRemoteCommandCenter) {
            [self skipToNextItem];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (_openRemoteCommandCenter) {
            [self pause];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (_openRemoteCommandCenter) {
            [self play];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    //    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
    //        NSLog(@"上一首");
    //        return MPRemoteCommandHandlerStatusSuccess;
    //    }];
    //快进
    //    MPSkipIntervalCommand *skipBackwardIntervalCommand = commandCenter.skipForwardCommand;
    //    skipBackwardIntervalCommand.preferredIntervals = @[@(54)];
    //    skipBackwardIntervalCommand.enabled = YES;
    //    [skipBackwardIntervalCommand addTarget:self action:@selector(skipBackwardEvent:)];
    
    //在控制台拖动进度条调节进度（仿QQ音乐的效果）
    if (@available(iOS 9.1, *)) {
        [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            CMTime totlaTime = self.player.currentItem.duration;
            MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
            [self.player seekToTime:CMTimeMake(totlaTime.value*playbackPositionEvent.positionTime/CMTimeGetSeconds(totlaTime), totlaTime.timescale) completionHandler:^(BOOL finished) {
            }];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
}
@end

@implementation JPAudioItem

@end
