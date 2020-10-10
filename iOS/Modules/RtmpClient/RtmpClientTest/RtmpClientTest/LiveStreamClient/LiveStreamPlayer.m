//
//  LiveStreamPlayer.m
//  livestream
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveStreamPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

#import "RtmpPlayerOC.h"

#import "GPUImagePicture.h"

#import "ImageCVPixelBufferInput.h"

#import "LiveStreamSession.h"

@interface LiveStreamPlayer () <RtmpPlayerOCDelegate> {
    GPUImageFilter *_customFilter;
}
#pragma mark - 传输处理
@property (strong) RtmpPlayerOC *player;

/**
 显示界面
 */
@property (nonatomic, strong) AVSampleBufferDisplayLayer *videoLayer;

@property (nonatomic, strong) ImageCVPixelBufferInput *pixelBufferInput;

@property (strong) NSString *_Nonnull url;
@property (strong) NSString *_Nonnull recordFilePath;
@property (strong) NSString *_Nullable recordH264FilePath;
@property (strong) NSString *_Nullable recordAACFilePath;
@property (strong) NSString *_Nonnull filePath;

@property (assign) BOOL isStart;
@property (assign) BOOL isConnected;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;

@end

@implementation LiveStreamPlayer

#pragma mark - 获取实例
+ (instancetype)instance {
    LiveStreamPlayer *obj = [[[self class] alloc] init];
    return obj;
}

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"LiveStreamPlayer::init( self : %p )", self);

        _isConnected = NO;
        _isStart = NO;

        self.player = [RtmpPlayerOC instance];
        self.player.delegate = self;

        self.pixelBufferInput = [[ImageCVPixelBufferInput alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    NSLog(@"LiveStreamPlayer::dealloc( self : %p )", self);

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];

    if (_isBackground == YES) {
        _isBackground = NO;

        dispatch_queue_t videoProcessingQueue = [GPUImageContext sharedContextQueue];
        dispatch_resume(videoProcessingQueue);
    }
}

#pragma mark - 对外接口
- (BOOL)playUrl:(NSString *_Nonnull)url recordFilePath:(NSString *)recordFilePath recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString *_Nullable)recordAACFilePath {
    NSLog(@"LiveStreamPlayer::playUrl( self : %p, url : %@, recordFilePath : %@, recordH264FilePath : %@ )", self, url, recordFilePath, recordH264FilePath);

    BOOL bFlag = NO;

    [self cancel];

    self.url = url;
    self.recordFilePath = recordFilePath;
    self.recordH264FilePath = recordH264FilePath;
    self.recordAACFilePath = recordAACFilePath;

    if (self.url.length > 0) {
        [self run];
        bFlag = YES;
    }

    return bFlag;
}

- (BOOL)playFilePath:(NSString * _Nonnull)filePath {
    NSLog(@"LiveStreamPlayer::playUrl( self : %p, filePath : %@ )", self, filePath);

    BOOL bFlag = NO;

    [self cancel];

    self.filePath = filePath;

    if (self.filePath.length > 0) {
        [self run];
        bFlag = YES;
    }

    return bFlag;
}

- (void)stop {
    NSLog(@"LiveStreamPlayer::stop( self : %p )", self);
    
    self.url = @"";
    self.filePath = @"";
    [self cancel];
}

#pragma mark - 私有方法
- (GPUImageFilter *)customFilter {
    return _customFilter;
}

- (void)setCustomFilter:(GPUImageFilter *)customFilter {
    // TODO:切换美颜
    if (_customFilter != customFilter) {
        _customFilter = customFilter;
        
        [self installFilter];
    }
}

- (void)installFilter {
    // TODO:组装滤镜
    [self.pixelBufferInput removeAllTargets];
    [self.customFilter removeAllTargets];
    
    GPUImageFilter *filter = nil;
    if( _customFilter ) {
        [self.pixelBufferInput addTarget:_customFilter];
        filter = _customFilter;
    }
    if (_playView) {
        if( filter ) {
            [filter addTarget:_playView];
        } else {
            [self.pixelBufferInput addTarget:_playView];
        }
    }
}

- (NSInteger)cacheMS {
    return self.player.cacheMS;
}

- (void)setCacheMS:(NSInteger)cacheMS {
    self.player.cacheMS = cacheMS;
}

- (BOOL)mute {
    return self.player.mute;
}

- (void)setMute:(BOOL)mute {
    self.player.mute = mute;
}

- (void)setPlayView:(GPUImageView *)playView {
    if (_playView != playView) {
        _playView = playView;

        [self installFilter];
    }
}

- (void)run {
    NSLog(@"LiveStreamPlayer::run( self : %p )", self);

    @synchronized(self) {
        if (!self.isStart) {
            self.isStart = YES;

            // 开启音频服务
            [[LiveStreamSession session] startPlay];

            // 仅在前台才运行
            if (!_isBackground) {
                // 开始拉流
                if (self.filePath.length > 0) {
                    self.isConnected = [self.player playFilePath:self.filePath];
                } else {
                    self.isConnected = [self.player playUrl:self.url recordFilePath:self.recordFilePath recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
                }
            } else {
                NSLog(@"LiveStreamPlayer::run( [Player is in background], self : %p )", self);
            }
        }
    }

    NSLog(@"LiveStreamPlayer::run( [Finish], self : %p )", self);
}

- (void)cancel {
    NSLog(@"LiveStreamPlayer::cancel( self : %p )", self);

    BOOL bHandle = NO;

    @synchronized(self) {
        if (self.isStart) {
            self.isStart = NO;
            bHandle = YES;
        }
    }

    if (bHandle) {
        // 停止拉流
        [self.player stop];

        // 停止音频服务
        [[LiveStreamSession session] stopPlay];
    }

    NSLog(@"LiveStreamPlayer::cancel( [Finish], self : %p )", self);
}

- (void)reconnect {
    BOOL bHandle = NO;

    @synchronized(self) {
        if (self.isStart && !self.isConnected && !_isBackground) {
            // 1.已经手动开始, 2.连接还没连接上, 3.不在后台
            bHandle = YES;
        }
    }

    if (bHandle) {
        NSLog(@"LiveStreamPlayer::reconnect( [Start], self : %p )", self);

        [self.player stop];

        // 是否需要切换URL
        if ([self.delegate respondsToSelector:@selector(playerShouldChangeUrl:)]) {
            self.url = [self.delegate playerShouldChangeUrl:self];
        }

        @synchronized(self) {
            if (self.filePath.length > 0) {
                self.isConnected = [self.player playFilePath:self.filePath];
            } else {
                self.isConnected = [self.player playUrl:self.url recordFilePath:self.recordFilePath recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
            }
        }

        NSLog(@"LiveStreamPlayer::reconnect( [Finish], self : %p )", self);
    }
}

#pragma mark - 视频接收处理
- (void)rtmpPlayerRenderVideoFrame:(RtmpPlayerOC *_Nonnull)rtmpClient buffer:(CVPixelBufferRef _Nonnull)buffer {
    if (_isBackground == NO) {
        if (buffer) {
            // 这里显示视频
            [self.pixelBufferInput processCVPixelBuffer:buffer];
        }
    }
}

- (void)rtmpPlayerOnConnect:(RtmpPlayerOC *_Nonnull)rtmpPlayerOC {
    NSLog(@"LiveStreamPlayer::rtmpPlayerOnConnect( self : %p )", self);

    if ([self.delegate respondsToSelector:@selector(playerOnConnect:)]) {
        [self.delegate playerOnConnect:self];
    }
}

- (void)rtmpPlayerOnDisconnect:(RtmpPlayerOC *_Nonnull)player {
    NSLog(@"LiveStreamPlayer::rtmpPlayerOnDisconnect( self : %p )", self);

    if ([self.delegate respondsToSelector:@selector(playerOnDisconnect:)]) {
        [self.delegate playerOnDisconnect:self];
    }

    @synchronized(self) {
        self.isConnected = NO;
        if (!self.isStart) {
            // 停止拉流
            NSLog(@"LiveStreamPlayer::rtmpPlayerOnDisconnect( [Disconnect], self : %p )", self);

        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 断线重新拉流
                NSLog(@"LiveStreamPlayer::rtmpPlayerOnDisconnect( [Delay Check], self : %p )", self);

                // 重连
                [self reconnect];
            });
        }
    }
}

- (void)rtmpPlayerOnPlayerOnDelayMaxTime:(RtmpPlayerOC *_Nonnull)rtmpPlayerOC {
    NSLog(@"LiveStreamPlayer::rtmpPlayerOnPlayerOnDelayMaxTime( self : %p )", self);

    // 延迟导致断线
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player stop];
    });
}

- (void)rtmpPlayerOnInfoChange:(RtmpPlayerOC * _Nonnull)rtmpPlayerOC videoDisplayWidth:(int)videoDisplayWidth vieoDisplayHeight:(int)vieoDisplayHeight {
    NSLog(@"LiveStreamPlayer::rtmpPlayerOnInfoChange( self : %p, videoDisplayWidth : %d, vieoDisplayHeight : %d )", self, videoDisplayWidth, vieoDisplayHeight);
    
    if ([self.delegate respondsToSelector:@selector(playerOnInfoChange:videoDisplayWidth:vieoDisplayHeight:)]) {
        [self.delegate playerOnInfoChange:self videoDisplayWidth:videoDisplayWidth vieoDisplayHeight:vieoDisplayHeight];
    }
}

- (void)rtmpPlayerOnStats:(RtmpPlayerOC * _Nonnull)rtmpPlayerOC fps:(unsigned int)fps bitrate:(unsigned int)bitrate {
    if ([self.delegate respondsToSelector:@selector(playerOnStats:fps:bitrate:)]) {
        [self.delegate playerOnStats:self fps:fps bitrate:bitrate];
    }
}

#pragma mark - 视频采集后台
- (void)willEnterBackground:(NSNotification *)notification {
    BOOL bHandle = NO;

    @synchronized(self) {
        if (_isBackground == NO) {
            _isBackground = YES;
            bHandle = YES;
        }
    }

    if (bHandle) {
//        // 直接断开连接
//        [self.player stop];
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    BOOL bHandle = NO;

    @synchronized(self) {
        if (_isBackground == YES) {
            _isBackground = NO;
            bHandle = YES;
        }
    }

    if( bHandle ) {
//        // 重连
//        [self reconnect];
    }
}

@end
