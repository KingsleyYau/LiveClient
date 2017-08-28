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
@property (nonatomic) BOOL isBackGround;
@property (nonatomic, strong) NSDate* enterBackgroundTime;
@property (nonatomic, strong) NSDate* startTime;

#pragma mark - 视频参数
@property (assign) int width;
@property (assign) int height;

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
        _isBackGround = NO;
        self.width = (int)width;
        self.height = (int)height;
        
        self.startTime = [NSDate date];
        
        self.publisher = new PublisherController();
        self.statusCallback = new PublisherStatusCallbackImp(self);
        self.publisher->SetStatusCallback(self.statusCallback);
        
        // 默认使用硬编码
        _useHardEncoder = YES;
        // 创建解码器和渲染器
        [self createEncoders];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"RtmpPublisherOC::dealloc()");
    
    [self destroyEncoders];
    
    if( self.publisher ) {
        delete self.publisher;
        self.publisher = NULL;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 对外接口
- (BOOL)publishUrl:(NSString * _Nonnull)url
recordH264FilePath:(NSString *)recordH264FilePath
 recordAACFilePath:(NSString * _Nullable)recordAACFilePath {
    BOOL bFlag = YES;
    
    NSLog(@"RtmpPublisherOC::pushlishUrl( url : %@ )", url);
    
    self.startTime = [NSDate date];
    bFlag = self.publisher->PublishUrl([url UTF8String], [recordH264FilePath UTF8String], [recordAACFilePath UTF8String]);
    if( bFlag ) {
    }
    
    return bFlag;
}

- (void)stop {
    NSLog(@"RtmpPublisherOC::stop()");
    
    self.publisher->Stop();
}

- (void)pushVideoFrame:(CVPixelBufferRef _Nonnull)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    char* data = (char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    int size = (int)CVPixelBufferGetDataSize(pixelBuffer);
    self.publisher->PushVideoFrame(data, size, (void *)pixelBuffer);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

- (void)pushAudioFrame:(CMSampleBufferRef _Nonnull)sampleBuffer {
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    
    char* data = NULL;
    size_t size = 0;
    OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &size, &data);
    if( status == kCMBlockBufferNoErr ) {
        self.publisher->PushAudioFrame(data, (int)size, (void *)sampleBuffer);
    }
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification*)notification {
    if( _isBackGround == NO ) {
        _isBackGround = YES;
        
        // 销毁硬编码器
        self.videoEncoder->Pause();
        
        self.enterBackgroundTime = [NSDate date];
    }
}

- (void)willEnterForeground:(NSNotification*)notification {
    if( _isBackGround == YES ) {
        _isBackGround = NO;
        
        // 重置视频编码器
        self.videoEncoder->Reset();
        
        if( (self.startTime == [self.enterBackgroundTime earlierDate:self.startTime]) ) {
            // 开始时间比进入后台时间要早, 增加在后台的时间到视频的时间戳
            NSDate* now = [NSDate date];
            NSTimeInterval timeInterval = [now timeIntervalSinceDate:self.enterBackgroundTime];
            NSUInteger timestamp = timeInterval * 1000;
            
            self.publisher->AddVideoBackgroundTime((unsigned int)timestamp);
        }

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
