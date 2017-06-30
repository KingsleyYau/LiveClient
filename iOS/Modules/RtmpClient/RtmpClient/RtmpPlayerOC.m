//
//  RtmpPlayerOC.m
//  RtmpPlayerOC
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RtmpPlayerOC.h"

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

#pragma mark - 渲染器
#include <rtmpdump/iOS/VideoRendererImp.h>
#include <rtmpdump/iOS/AudioRendererImp.h>

#pragma mark - 软解码器
#include <rtmpdump/VideoDecoderH264.h>
#include <rtmpdump/AudioDecoderAAC.h>

#pragma mark - 硬解码器
#include <rtmpdump/iOS/VideoHardDecoder.h>

#pragma mark - 硬渲染器
#include <rtmpdump/iOS/VideoHardRendererImp.h>

#include <rtmpdump/PlayerController.h>
using namespace coollive;

class PlayerStatusCallbackImp;

@interface RtmpPlayerOC () <VideoRendererDelegate, VideoHardRendererDelegate> {
    BOOL _useHardDecoder;
}

#pragma mark - 播放器
@property (assign) PlayerController* player;
#pragma mark - 状态回调
@property (assign) PlayerStatusCallbackImp* statusCallback;

#pragma mark - 软渲染器
@property (assign) VideoRenderer* videoRenderer;
@property (assign) AudioRenderer* audioRenderer;

#pragma mark - 解码器
@property (assign) VideoDecoder* videoDecoder;
@property (assign) AudioDecoder* audioDecoder;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackGround;

@end

//#pragma mark - RrmpPlayer回调
//class RtmpPlayerCallbackImp : public RtmpPlayerCallback {
//public:
//    RtmpPlayerCallbackImp(RtmpPlayerOC* player) {
//        mpPlayer = player;
//    };
//
//    ~RtmpPlayerCallbackImp(){};
//    
//    void OnDisconnect(RtmpPlayer* player) {
//        NSLog(@"RtmpPlayerOC::OnDisconnect( player : %p )", player);
//    }
//    
//    void OnPlayVideoFrame(RtmpPlayer* player, void* frame) {
//        if( mpPlayer.useHardDecoder ) {
//            // 硬解码
//            CVPixelBufferRef buffer = (CVPixelBufferRef)frame;
//            [mpPlayer.delegate rtmpPlayerOCOnRecvVideoBuffer:mpPlayer buffer:buffer];
//            CFRelease(buffer);
//            
//        } else {
//            // 软解码
////            VideoBuffer* videoFrame = (VideoBuffer *)frame;
//            CVPixelBufferRef buffer = [mpPlayer createPixelBufferByRGBData:(const unsigned char*)videoFrame->GetBuffer()
//                                                                      size:videoFrame->mBufferLen
//                                                                     width:videoFrame->mWidth
//                                                                    height:videoFrame->mHeight];
////
//            [mpPlayer.delegate rtmpPlayerOCOnRecvVideoBuffer:mpPlayer buffer:buffer];
//            CFRelease(buffer);
////
////            // 释放Buffer
////            VideoDecoderH264* decoder = (VideoDecoderH264 *)mpPlayer.player->GetVideoDecoder();
////            decoder->ReleaseBuffer(videoFrame);
//        }
//    }
//    
//    void OnDropVideoFrame(RtmpPlayer* player, void* frame) {
//        if( mpPlayer.useHardDecoder ) {
//            // 硬解码
//            CVPixelBufferRef buffer = (CVPixelBufferRef)frame;
//            CFRelease(buffer);
//            
//        } else {
//            // 软解码
////            VideoBuffer* videoFrame = (VideoBuffer *)frame;
////            
////            // 释放Buffer
////            VideoDecoderH264* decoder = (VideoDecoderH264 *)mpPlayer.player->GetVideoDecoder();
////            decoder->ReleaseBuffer(videoFrame);
//        }
//    }
//    
//    void OnPlayAudioFrame(RtmpPlayer* player, void* frame) {
//        if( mpPlayer.useHardDecoder ) {
//            // 硬解码
//            CFDataRef dataRef = (CFDataRef)frame;
//            //        OSStatus status = noErr;
//            //        if( mpPlayer.audioFileStream ) {
//            //            status = AudioFileStreamParseBytes(mpPlayer.audioFileStream, (UInt32)CFDataGetLength(dataRef), CFDataGetBytePtr(dataRef), 0);
//            //            if( status != noErr ) {
//            //                NSLog(@"RtmpPlayerOC::OnPlayAudioFrame( [Fail], status : %ld )", (long)status);
//            //            }
//            //        }
//            CFRelease(dataRef);
//        } else {
//            // 软解码
////            coollive::AudioBuffer* audioFrame = (coollive::AudioBuffer *)frame;
////            
//////            AudioStreamBasicDescription asbd;
//////            
//////            AudioStreamPacketDescription desc;
//////            [mpPlayer.audioPlayer playAudioFrame:(const unsigned char*)audioFrame->GetBuffer() size:audioFrame->mBufferLen desc:desc];
//////            
//////            // 释放Buffer
//////            AudioDecoderAAC* decoder = (AudioDecoderAAC *)mpPlayer.player->GetAudioDecoder();
////            decoder->ReleaseBuffer(audioFrame);
//        }
//    }
//    
//    void OnDropAudioFrame(RtmpPlayer* player, void* frame) {
//        if( mpPlayer.useHardDecoder ) {
//            // 硬解码
//            CFDataRef dataRef = (CFDataRef)frame;
//            CFRelease(dataRef);
//            
//        } else {
//            // 软解码
//            
//        }
//    }
//    
//private:
//    RtmpPlayerOC* mpPlayer;
//
//};

#pragma mark - PlayerStatusCallback回调
class PlayerStatusCallbackImp : public PlayerStatusCallback {
public:
    PlayerStatusCallbackImp(RtmpPlayerOC* rtmpPlayerOC) {
        mpRtmpPlayerOC = rtmpPlayerOC;
    }
    
    ~PlayerStatusCallbackImp() {
        
    }
    
    void OnPlayerDisconnect(PlayerController* pc) {
        if( [mpRtmpPlayerOC.delegate respondsToSelector:@selector(rtmpPlayerOnDisconnect:)] ) {
            [mpRtmpPlayerOC.delegate rtmpPlayerOnDisconnect:mpRtmpPlayerOC];
        }
    }
    
private:
    __weak typeof(RtmpPlayerOC) *mpRtmpPlayerOC;
};

@implementation RtmpPlayerOC

#pragma mark - 获取实例
+ (instancetype)instance {
    RtmpPlayerOC *obj = [[[self class] alloc] init];
    return obj;
}

- (instancetype)init {
    if(self = [super init] ) {
        // 默认在前台
        _isBackGround = NO;

        // 创建播放控制器
        self.player = new PlayerController();
        self.statusCallback = new PlayerStatusCallbackImp(self);
        self.player->SetStatusCallback(self.statusCallback);
        
        // 默认使用软解码
        _useHardDecoder = NO;
        // 创建解码器和渲染器
        [self createDecoders];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];

    }
    
    return self;
}

- (void)dealloc {
    if( self.statusCallback ) {
        delete self.statusCallback;
    }
    
    [self destroyDecoders];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 对外接口
- (BOOL)playUrl:(NSString * _Nonnull)url recordFilePath:(NSString *)recordFilePath recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString * _Nullable)recordAACFilePath {
    BOOL bFlag = YES;
    
    NSLog(@"RtmpPlayerOC::playUrl( url : %@, recordFilePath : %@, recordH264FilePath : %@, recordAACFilePath : %@ )", url, recordFilePath, recordH264FilePath, recordAACFilePath);
    
    bFlag = self.player->PlayUrl([url UTF8String], [recordFilePath UTF8String], [recordH264FilePath UTF8String], [recordAACFilePath UTF8String]);
    
    if( bFlag ) {
    }
    
    return bFlag;
}

- (void)stop {
    self.player->Stop();
}

#pragma mark - 私有方法
- (BOOL)useHardDecoder {
    return _useHardDecoder;
}

- (void)setUseHardDecoder:(BOOL)useHardDecoder {
    if( _useHardDecoder != useHardDecoder ) {
        [self destroyDecoders];
        
        _useHardDecoder = useHardDecoder;
    
        [self createDecoders];
    }
}

- (void)renderVideoFrame:(CVPixelBufferRef _Nonnull)buffer {
    if( !self.isBackGround ) {
        [self.delegate rtmpPlayerRenderVideoFrame:self buffer:buffer];
    }

}

- (void)createDecoders {
    if( _useHardDecoder ) {
        // 硬解码
        
        // 创建硬渲染器
        self.videoRenderer = new VideoHardRendererImp(self);
        
        // 创建硬解码器
        self.videoDecoder = new VideoHardDecoder();


    } else {
        // 软解码
        
        // 创建软渲染器
        self.videoRenderer = new VideoRendererImp(self);
        self.audioRenderer = new AudioRendererImp();

        // 创建解码器
        self.videoDecoder = new VideoDecoderH264();
        self.audioDecoder = new AudioDecoderAAC();

    }
    
    // 替换解码器
    self.player->SetVideoRenderer(self.videoRenderer);
    self.player->SetAudioRenderer(self.audioRenderer);
    // 替换渲染器
    self.player->SetVideoDecoder(self.videoDecoder);
    self.player->SetAudioDecoder(self.audioDecoder);
}

- (void)destroyDecoders {
    if( self.videoRenderer ) {
        delete self.videoRenderer;
    }
    
    if( self.audioRenderer ) {
        delete self.audioRenderer;
    }
    
    if( self.videoDecoder ) {
        delete self.videoDecoder;
    }
    
    if( self.audioDecoder ) {
        delete self.audioDecoder;
    }
}

#pragma mark - 视频采集后台
- (void)willEnterBackground:(NSNotification *)notification {
    @synchronized (self) {
        if( _isBackGround == NO ) {
            _isBackGround = YES;
            
            // 销毁硬解码器
            self.videoDecoder->Pause();
        }
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    @synchronized (self) {
        if( _isBackGround == YES ) {
            _isBackGround = NO;
            
            // 重置硬视频解码器
            self.videoDecoder->Reset();
        }
    }
}

@end
