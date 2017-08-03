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
@property (assign) BOOL isConnected;

#pragma mark - 重连线程
@property (strong) dispatch_queue_t reconnect_queue;

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
        
        self.reconnect_queue = dispatch_queue_create("_reconnect_queue", NULL);
        
        _isConnected = NO;
        _isStart = NO;
        
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
    
    BOOL bFlag = YES;
    
    self.url = url;
    self.recordFilePath = recordFilePath;
    self.recordH264FilePath = recordH264FilePath;
    self.recordAACFilePath = recordAACFilePath;

    [self cancel];
    [self run];
    
    return bFlag;
}

- (void)stop {
    NSLog(@"LiveStreamPlayer::stop( url : %@ )", self.url);
    
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
        self.isStart = YES;
    }
    
    // 开始拉流
    [self.player playUrl:self.url recordFilePath:self.recordFilePath recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
}

- (void)cancel {
    NSLog(@"LiveStreamPlayer::cancel()");
    
    @synchronized (self) {
        self.isStart = NO;
    }
    
    // 停止推流
    [self.player stop];
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
    
    @synchronized (self) {
        self.isConnected = NO;
        
        if( self.isStart ) {
            // 断线重新拉流
            dispatch_async(self.reconnect_queue, ^{
                NSLog(@"LiveStreamPlayer::rtmpPlayerOnDisconnect( [Reconnect] )");
                [self.player playUrl:self.url recordFilePath:self.recordFilePath recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
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

@end
