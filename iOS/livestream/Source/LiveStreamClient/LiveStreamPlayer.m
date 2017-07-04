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

@property (assign) BOOL isRunning;

@end

@implementation LiveStreamPlayer

#pragma mark - 获取实例
+ (instancetype)instance
{
    LiveStreamPlayer *obj = [[[self class] alloc] init];
    return obj;
}

- (instancetype)init
{
    if(self = [super init] ) {
        NSLog(@"LiveStreamPlayer::init()");
        
        self.player = [RtmpPlayerOC instance];
        self.player.delegate = self;
        
        self.pixelBufferInput = [[ImageCVPixelBufferInput alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"LiveStreamPlayer::dealloc()");
    [self stop];
}

#pragma mark - 对外接口
- (BOOL)playUrl:(NSString * _Nonnull)url recordFilePath:(NSString *)recordFilePath recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString * _Nullable)recordAACFilePath {
    NSLog(@"LiveStreamPlayer::playUrl( url : %@, recordFilePath : %@, recordH264FilePath : %@ )", url, recordFilePath, recordH264FilePath);
    
    self.url = url;
    self.recordFilePath = recordFilePath;
    self.recordH264FilePath = recordH264FilePath;
    self.recordAACFilePath = recordAACFilePath;

    [self stop];
    
    BOOL bFlag = YES;
    @synchronized (self) {
        self.isStart = YES;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @synchronized (self) {
            while (self.isStart && ![self start]) {
                NSLog(@"LiveStreamPlayer::rtmpPlayerOnDisconnect( [Connect Fail] )");
                usleep(1000 * 1000);
            }
        }
    });
    
    return bFlag;
}

- (void)stop {
    @synchronized (self) {
        self.isStart = NO;
        [self.player stop];
    }
}

#pragma mark - 私有方法
- (void)setPlayView:(GPUImageView *)playView {
    if( _playView != playView ) {
        _playView = playView;
        
        [self.pixelBufferInput removeAllTargets];
        [self.pixelBufferInput addTarget:_playView];
    }
}

- (BOOL)start {
    NSLog(@"LiveStreamPlayer::start()");
    BOOL bFlag = NO;

    bFlag = [self.player playUrl:self.url recordFilePath:self.recordFilePath recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];

    return bFlag;
}

#pragma mark - 视频接收处理
- (void)rtmpPlayerRenderVideoFrame:(RtmpPlayerOC * _Nonnull)rtmpClient buffer:(CVPixelBufferRef _Nonnull)buffer {
    if( buffer ) {
        // 这里显示视频
        [self.pixelBufferInput processCVPixelBuffer:buffer];
    }
}

- (void)rtmpPlayerOnDisconnect:(RtmpPlayerOC * _Nonnull)player {
    NSLog(@"LiveStreamPlayer::rtmpPlayerOnDisconnect()");
    
    // 断线重连
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @synchronized (self) {
            while (self.isStart && ![self start]) {
                NSLog(@"LiveStreamPlayer::rtmpPlayerOnDisconnect( [Reconnect Fail] )");
                usleep(1000 * 1000);
            }
        }
    });
}

@end
