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

@interface LiveStreamPlayer() <RtmpPlayerOCDelegate>
#pragma mark - 传输处理
@property (strong) RtmpPlayerOC* player;

/**
 显示界面
 */
@property (nonatomic, strong) AVSampleBufferDisplayLayer *videoLayer;

@property (nonatomic, strong) ImageCVPixelBufferInput* pixelBufferInput;

@property (strong) NSString * _Nonnull url;
@property (strong) NSString * _Nonnull recordFilePath;
@property (strong) NSString * _Nullable recordH264FilePath;
@property (strong) NSString * _Nullable recordAACFilePath;

@property (assign) BOOL isStart;
@property (assign) BOOL isConnected;

#pragma mark - 重连线程
@property (strong) dispatch_queue_t reconnect_queue;

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
    if(self = [super init] ) {
        NSLog(@"LiveStreamPlayer::init()");
        
        self.reconnect_queue = dispatch_queue_create("_reconnect_queue", NULL);
        
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
    NSLog(@"LiveStreamPlayer::dealloc()");
    
    [self stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 对外接口
- (BOOL)playUrl:(NSString * _Nonnull)url recordFilePath:(NSString *)recordFilePath recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString * _Nullable)recordAACFilePath {
    NSLog(@"LiveStreamPlayer::playUrl( url : %@, recordFilePath : %@, recordH264FilePath : %@ )", url, recordFilePath, recordH264FilePath);
    
    BOOL bFlag = NO;
    
    [self cancel];
    
    self.url = url;
    self.recordFilePath = recordFilePath;
    self.recordH264FilePath = recordH264FilePath;
    self.recordAACFilePath = recordAACFilePath;

    if( self.url.length > 0 ) {
        [self run];
        bFlag = YES;
    }
    
    return bFlag;
}

- (void)stop {
    NSLog(@"LiveStreamPlayer::stop()");
    
    [self cancel];
}

#pragma mark - 私有方法
- (void)setPlayView:(GPUImageView *)playView {
    if( _playView != playView ) {
        _playView = playView;
        
        [self.pixelBufferInput removeAllTargets];
        [self.pixelBufferInput addTarget:_playView];
    }
}

- (void)run {
    NSLog(@"LiveStreamPlayer::run()");
    
    @synchronized (self) {
        if( !self.isStart ) {
            self.isStart = YES;
            [[LiveStreamSession session] startPlay];
        }
    }
    
    // 开始拉流
    [self.player playUrl:self.url recordFilePath:self.recordFilePath recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
}

- (void)cancel {
    NSLog(@"LiveStreamPlayer::cancel()");
    
    @synchronized (self) {
        if( self.isStart ) {
            self.isStart = NO;
            
            [[LiveStreamSession session] stopPlay];
        }
    }
    
    // 停止推流
    [self.player stop];
}

#pragma mark - 视频接收处理
- (void)rtmpPlayerRenderVideoFrame:(RtmpPlayerOC * _Nonnull)rtmpClient buffer:(CVPixelBufferRef _Nonnull)buffer {
    if( buffer ) {
        @synchronized (self) {
            if( !_isBackground ) {
                // 这里显示视频
                [self.pixelBufferInput processCVPixelBuffer:buffer];
            }
        }
    }
}

- (void)rtmpPlayerOnDisconnect:(RtmpPlayerOC * _Nonnull)player {
    NSLog(@"LiveStreamPlayer::rtmpPlayerOnDisconnect()");
    
    @synchronized (self) {
        self.isConnected = NO;
        
        if( self.isStart ) {
            // 断线重新拉流
            dispatch_async(self.reconnect_queue, ^{
                [self.player stop];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), self.reconnect_queue, ^{
                    NSLog(@"LiveStreamPlayer::rtmpPlayerOnDisconnect( [Reconnect] )");
                    
                    // 是否需要切换URL
                    if( [self.delegate respondsToSelector:@selector(playerShouldChangeUrl:)] ) {
                        self.url = [self.delegate playerShouldChangeUrl:self];
                    }
                    
                    [self.player playUrl:self.url recordFilePath:self.recordFilePath recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
                });
            });
            
        } else {
            // 停止推流
            dispatch_async(self.reconnect_queue, ^{
                NSLog(@"LiveStreamPlayer::rtmpPublisherOCOnDisconnect( [Disconnect] )");
                [self.player stop];
            });
        }
    }
}

- (void)rtmpPlayerOnPlayerOnDelayMaxTime:(RtmpPlayerOC * _Nonnull)rtmpPlayerOC {
    NSLog(@"LiveStreamPlayer::rtmpPlayerOnPlayerOnDelayMaxTime()");
    
    @synchronized (self) {
        // 断线重新拉流
        dispatch_async(self.reconnect_queue, ^{
            NSLog(@"LiveStreamPlayer::rtmpPlayerOnPlayerOnDelayMaxTime( [Disconnect] )");
            [self.player stop];
        });
    }
}

#pragma mark - 视频采集后台
#pragma mark - 视频采集后台
- (void)willEnterBackground:(NSNotification *)notification {
    @synchronized (self) {
        if( _isBackground == NO ) {
            _isBackground = YES;
            
            dispatch_queue_t videoProcessingQueue = [GPUImageContext sharedContextQueue];
            dispatch_suspend(videoProcessingQueue);
            glFinish();
        }
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    @synchronized (self) {
        if( _isBackground == YES ) {
            _isBackground = NO;
            
            dispatch_queue_t videoProcessingQueue = [GPUImageContext sharedContextQueue];
            dispatch_resume(videoProcessingQueue);
        }
    }
}

@end
