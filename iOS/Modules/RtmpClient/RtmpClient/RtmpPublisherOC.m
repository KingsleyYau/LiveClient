//
//  RtmpPublisherOC.m
//  RtmpPublisherOC
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RtmpPublisherOC.h"

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

#pragma mark - 硬编码器
#include <rtmpdump/iOS/VideoHardEncoder.h>
#include <rtmpdump/iOS/AudioHardEncoder.h>

#pragma mark - 软编码器
#include <rtmpdump/video/VideoEncoderH264.h>
#include <rtmpdump/audio/AudioEncoderAAC.h>

#pragma mark - 发布控制器
#include <rtmpdump/PublisherController.h>

using namespace coollive;

class PublisherStatusCallbackImp;

@interface RtmpPublisherOC () {
    BOOL _useHardEncoder;

}

#pragma mark - 传输模块
@property (assign) PublisherController* publisher;

#pragma mark - 状态回调
@property (assign) PublisherStatusCallbackImp* statusCallback;

#pragma mark - 编码器
@property (assign) VideoEncoder* videoEncoder;
@property (assign) AudioEncoder* audioEncoder;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;
@property (nonatomic, strong) NSDate* enterBackgroundTime;
// 开始推流时间
@property (nonatomic, strong) NSDate* startTime;

#pragma mark - 视频参数
// 宽
@property (assign) int width;
// 高
@property (assign) int height;
// 第一次处理帧时间
@property (assign) long long videoFrameStartPushTime;
@property (assign) long long videoFrameLastPushTime;
// 由帧率得出的每帧间隔(ms)
@property (assign) int videoFrameInterval;
// 总处理帧数
@property (assign) int videoFrameIndex;

#pragma mark - 视频暂停控制
// 视频是否暂停采集
@property (assign) BOOL videoPause;
// 视频是否已经恢复采集
@property (assign) BOOL videoResume;
// 视频总暂停时长
@property (assign) long long videoFramePauseTime;

#pragma mark - 音频控制
@property (assign) EncodeDecodeBuffer* mpMuteBuffer;

@end

#pragma mark - RrmpPublisher回调
class PublisherStatusCallbackImp : public PublisherStatusCallback {
public:
    PublisherStatusCallbackImp(RtmpPublisherOC* publisher) {
        mpPublisher = publisher;
    };
    
    ~PublisherStatusCallbackImp(){};
    
    void OnPublisherConnect(PublisherController* pc) {
        if( [mpPublisher.delegate respondsToSelector:@selector(rtmpPublisherOCOnConnect:)] ) {
            [mpPublisher.delegate rtmpPublisherOCOnConnect:mpPublisher];
        }
    }
    
    void OnPublisherDisconnect(PublisherController* pc) {
        if( [mpPublisher.delegate respondsToSelector:@selector(rtmpPublisherOCOnDisconnect:)] ) {
            [mpPublisher.delegate rtmpPublisherOCOnDisconnect:mpPublisher];
        }
    }
    
private:
    __weak typeof(RtmpPublisherOC) *mpPublisher;
};

@implementation RtmpPublisherOC
#pragma mark - 获取实例
+ (instancetype)instance:(NSInteger)width height:(NSInteger)height {
    RtmpPublisherOC *obj = [[[self class] alloc] initWithWidthAndHeight:width height:height];
    return obj;
}

- (instancetype)initWithWidthAndHeight:(NSInteger)width height:(NSInteger)height {
    NSLog(@"RtmpPublisherOC::initWithWidthAndHeight( width : %ld, height : %ld )", (long)width, (long)height);
    
    if(self = [super init] ) {
        // 初始化参数
        _width = (int)width;
        _height = (int)height;
        _mute = NO;
        
        self.videoFrameLastPushTime = 0;
        self.videoFrameStartPushTime = 0;
        self.videoFrameIndex = 0;
        self.videoFrameInterval = 1000.0 / FPS;
        
        self.videoPause = NO;
        self.videoResume = YES;
        self.videoFramePauseTime = 0;
        
        self.startTime = [NSDate date];
        
        // 创建流推送器
        self.publisher = new PublisherController();
        self.publisher->SetVideoParam(_width, _height);
        self.statusCallback = new PublisherStatusCallbackImp(self);
        self.publisher->SetStatusCallback(self.statusCallback);
        
        // 创建静音Buffer
        self.mpMuteBuffer = new EncodeDecodeBuffer();
        
#if TARGET_OS_SIMULATOR
        // 模拟器, 默认使用软编码
        _useHardEncoder = NO;
#else
        // 真机, 默认使用硬编码
        _useHardEncoder = YES;
#endif

        // 创建解码器和渲染器
        [self createEncoders];
        
        // 注册前后台切换通知
        _isBackground = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"RtmpPublisherOC::dealloc()");
    // 销毁编码器
    [self destroyEncoders];
    
    // 销毁流推送器
    if( self.publisher ) {
        delete self.publisher;
        self.publisher = NULL;
    }
    
    if( self.statusCallback ) {
        delete self.statusCallback;
        self.statusCallback = NULL;
    }
    
    // 销毁影音Buffer
    if( self.mpMuteBuffer ) {
        delete self.mpMuteBuffer;
        self.mpMuteBuffer = NULL;
    }
    
    // 注销前后台切换通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 对外接口
- (BOOL)publishUrl:(NSString * _Nonnull)url
recordH264FilePath:(NSString *)recordH264FilePath
 recordAACFilePath:(NSString * _Nullable)recordAACFilePath {
    BOOL bFlag = YES;
    
    NSLog(@"RtmpPublisherOC::pushlishUrl( url : %@ )", url);
    
    @synchronized(self) {
        self.videoPause = NO;
    }
    self.startTime = [NSDate date];
    // 开始推流连接
    bFlag = self.publisher->PublishUrl([url UTF8String], [recordH264FilePath UTF8String], [recordAACFilePath UTF8String]);

    return bFlag;
}

- (void)stop {
    NSLog(@"RtmpPublisherOC::stop()");
    
    // 停止推流
    self.publisher->Stop();
    
    // 复位帧率控制
    self.videoFrameStartPushTime = 0;
    self.videoFrameIndex = 0;
    self.videoFramePauseTime = 0;
    self.videoFrameLastPushTime = 0;
    @synchronized(self) {
        self.videoResume = YES;
    }
}

- (void)pushVideoFrame:(CVPixelBufferRef _Nonnull)pixelBuffer {
    @synchronized(self) {
        // 视频是否暂停录制
        if( !self.videoPause ) {
            long long now = getCurrentTime();
            
            // 视频是否恢复
            if( !self.videoResume ) {
                // 视频未恢复
                self.videoResume = YES;
                // 更新上次暂停导致的时间差
                long long videoFrameDiffTime = now - self.videoFrameLastPushTime;
                videoFrameDiffTime -= self.videoFrameInterval;
                NSLog(@"RtmpPublisherOC::pushVideoFrame( [Video capture is resume], videoFrameDiffTime : %lld )", videoFrameDiffTime);
                self.publisher->AddVideoTimestamp((unsigned int)videoFrameDiffTime);
                self.videoFramePauseTime += videoFrameDiffTime;
            }
            
            // 控制帧率
            if( self.videoFrameStartPushTime == 0 ) {
                self.videoFrameStartPushTime = now;
            }
            long long diffTime = now - self.videoFrameStartPushTime;
            diffTime -= self.videoFramePauseTime;
            long long videoFrameInterval = diffTime - (self.videoFrameIndex * self.videoFrameInterval);
            
            if( videoFrameInterval >= 0 ) {
//                FileLevelLog(
//                             "rtmpdump",
//                             KLog::LOG_MSG,
//                             "RtmpPublisherOC::pushVideoFrame( "
//                             "[Video frame can be pushed], "
//                             "videoFrameInterval : %lld, "
//                             "diffTime : %lld, "
//                             "videoFrameIndex : %d "
//                             ")",
//                             videoFrameInterval,
//                             diffTime,
//                             self.videoFrameIndex
//                             );
                
                // 放到推流器
                CVPixelBufferLockBaseAddress(pixelBuffer, 0);
                char* data = (char *)CVPixelBufferGetBaseAddress(pixelBuffer);
                int size = (int)CVPixelBufferGetDataSize(pixelBuffer);
                self.publisher->PushVideoFrame(data, size, (void *)pixelBuffer);
                CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                
                // 更新最后处理帧数目
                self.videoFrameIndex++;
                // 更新最后处理时间
                self.videoFrameLastPushTime = now;
            }
        } else {
           NSLog(@"RtmpPublisherOC::pushVideoFrame( [Video capture is pausing] )");
        }
    }
}

- (void)pausePushVideo {
    NSLog(@"RtmpPublisherOC::pausePushVideo()");
    
    @synchronized(self) {
        self.videoPause = YES;
        self.videoResume = NO;
    }
}

- (void)resumePushVideo {
    NSLog(@"RtmpPublisherOC::resumePushVideo()");
    
    @synchronized(self) {
        self.videoPause = NO;
    }
}

- (void)pushAudioFrame:(CMSampleBufferRef _Nonnull)sampleBuffer {
    char* data = NULL;
    size_t size = 0;
    OSStatus status = noErr;
    
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &size, &data);
    if( status == kCMBlockBufferNoErr ) {
        void* buffer = data;
        
        if( _mute ) {
            // 静音
            self.mpMuteBuffer->RenewBufferSize((int)size);
            self.mpMuteBuffer->FillBufferWithChar(0);
            buffer = (void *)self.mpMuteBuffer->GetBuffer();
            
            CMBlockBufferReplaceDataBytes((const void *)buffer, blockBuffer, 0, size);
        }
        
        self.publisher->PushAudioFrame(buffer, (int)size, (void *)sampleBuffer);
    }
}

- (void)setMute:(BOOL)mute {
    if( _mute != mute ) {
        _mute = mute;
    }
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification*)notification {
    if( _isBackground == NO ) {
        _isBackground = YES;
        
        // 销毁硬编码器
        self.videoEncoder->Pause();
        
//        self.enterBackgroundTime = [NSDate date];
    }
}

- (void)willEnterForeground:(NSNotification*)notification {
    if( _isBackground == YES ) {
        _isBackground = NO;
        
        // 重置视频编码器
        self.videoEncoder->Reset();
        
//        if( (self.startTime == [self.enterBackgroundTime earlierDate:self.startTime]) ) {
//            // 开始时间比进入后台时间要早, 增加在后台的时间到视频的时间戳
//            NSDate* now = [NSDate date];
//            NSTimeInterval timeInterval = [now timeIntervalSinceDate:self.enterBackgroundTime];
//            NSUInteger timestamp = timeInterval * 1000;
//
//            self.publisher->AddVideoTimestamp((unsigned int)timestamp);
//        }

    }
}

#pragma mark - 私有方法
- (void)createEncoders {
    if( _useHardEncoder ) {
        // 硬编码
        
        // 创建硬编码器
        self.videoEncoder = new VideoHardEncoder();
        self.audioEncoder = new AudioHardEncoder();
        
    } else {
        // 软解码
        self.videoEncoder = new VideoEncoderH264();
        self.audioEncoder = new AudioEncoderAAC();
    }
    
    // 替换编码器
    self.videoEncoder->Create(self.width, self.height, BIT_RATE, KEY_FRAME_INTERVAL, FPS, VIDEO_FORMATE_BGRA);
    self.publisher->SetVideoEncoder(self.videoEncoder);
    
    self.audioEncoder->Create(44100, 1, 16);
    self.publisher->SetAudioEncoder(self.audioEncoder);
}

- (void)destroyEncoders {
    if( self.videoEncoder ) {
        delete self.videoEncoder;
        self.videoEncoder = nil;
        self.publisher->SetVideoEncoder(NULL);
    }
    
    if( self.audioEncoder ) {
        delete self.audioEncoder;
        self.audioEncoder = nil;
        self.publisher->SetAudioEncoder(NULL);
    }
}

- (void)writeDataToFile:(const void *)bytes length:(NSUInteger)length filePath:(NSString *)filePath {
    NSData* data = [NSData dataWithBytes:bytes length:length];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if( !fileHandle ) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    
    if( fileHandle ) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
    }
}

@end
