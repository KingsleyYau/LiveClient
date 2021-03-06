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

@implementation RtmpVideoParam
- (id)copyWithZone:(NSZone *)zone {
    RtmpVideoParam *copy = [[[self class] allocWithZone:zone] init];
    copy.width = self.width;
    copy.height = self.height;
    copy.fps = self.fps;
    copy.keyFrameInterval = self.keyFrameInterval;
    copy.bitrate = self.bitrate;
    return copy;
}
@end

class PublisherStatusCallbackImp;
@interface RtmpPublisherOC () {
    BOOL _useHardEncoder;
}

#pragma mark - 传输模块
@property (assign) PublisherController *publisher;

#pragma mark - 状态回调
@property (assign) PublisherStatusCallbackImp *statusCallback;

#pragma mark - 编码器
@property (assign) VideoEncoder *videoEncoder;
@property (assign) AudioEncoder *audioEncoder;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;
@property (nonatomic, strong) NSDate *enterBackgroundTime;
// 开始推流时间
@property (nonatomic, strong) NSDate *startTime;

#pragma mark - 视频参数
@property (strong) RtmpVideoParam *videoParam;
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
@property (assign) EncodeDecodeBuffer *mpMuteBuffer;

@end

#pragma mark - RrmpPublisher回调
class PublisherStatusCallbackImp : public PublisherStatusCallback {
  public:
    PublisherStatusCallbackImp(RtmpPublisherOC *publisher) {
        mpPublisher = publisher;
    };

    ~PublisherStatusCallbackImp(){};

    void OnPublisherConnect(PublisherController *pc) {
        if ([mpPublisher.delegate respondsToSelector:@selector(rtmpPublisherOCOnConnect:)]) {
            [mpPublisher.delegate rtmpPublisherOCOnConnect:mpPublisher];
        }
    }

    void OnPublisherDisconnect(PublisherController *pc) {
        if ([mpPublisher.delegate respondsToSelector:@selector(rtmpPublisherOCOnDisconnect:)]) {
            [mpPublisher.delegate rtmpPublisherOCOnDisconnect:mpPublisher];
        }
    }

    void OnPublisherError(PublisherController *pc, const string &code, const string &description) {
        if ([mpPublisher.delegate respondsToSelector:@selector(rtmpPublisherOCOnError:code:description:)]) {
            [mpPublisher.delegate rtmpPublisherOCOnError:mpPublisher code:[NSString stringWithUTF8String:code.c_str()] description:[NSString stringWithUTF8String:description.c_str()]];
        }
    }

  private:
    __weak typeof(RtmpPublisherOC) *mpPublisher;
};

@implementation RtmpPublisherOC
#pragma mark - 获取实例
+ (instancetype)instance:(RtmpVideoParam *)videoParam {
    RtmpPublisherOC *obj = [[[self class] alloc] initWithVideoParam:videoParam];
    return obj;
}

- (instancetype)initWithVideoParam:(RtmpVideoParam *)videoParam {
    NSLog(@"RtmpPublisherOC::initWithParam( width : %ld, height : %ld, fps : %ld, keyFrameInterval : %ld, bitrate : %ld )",
          (long)videoParam.width, (long)videoParam.height, (long)videoParam.fps, (long)videoParam.keyFrameInterval, (long)videoParam.bitrate);

    if (self = [super init]) {
        // 初始化参数
        self.videoParam = videoParam;

        _mute = NO;

        self.videoFrameLastPushTime = 0;
        self.videoFrameStartPushTime = 0;
        self.videoFrameIndex = 0;
        self.videoFrameInterval = 1000.0 / videoParam.fps;

        self.videoPause = NO;
        self.videoResume = YES;
        self.videoFramePauseTime = 0;

        self.startTime = [NSDate date];

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

        // 创建流推送器
        self.publisher = new PublisherController();
        // 设置状态回调
        self.statusCallback = new PublisherStatusCallbackImp(self);
        self.publisher->SetStatusCallback(self.statusCallback);
        // 设置编码器
        self.publisher->SetVideoEncoder(self.videoEncoder);
        self.audioEncoder->Create(44100, 1, 16);
        self.publisher->SetAudioEncoder(self.audioEncoder);
        // 设置视频参数
        self.publisher->SetVideoParam(self.videoParam.width,
                                      self.videoParam.height,
                                      self.videoParam.fps,
                                      self.videoParam.keyFrameInterval,
                                      self.videoParam.bitrate,
                                      VIDEO_FORMATE_BGRA);

        // 注册前后台切换通知
        _isBackground = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    NSLog(@"RtmpPublisherOC::dealloc()");
    // 销毁编码器
    [self destroyEncoders];

    // 销毁流推送器
    if (self.publisher) {
        delete self.publisher;
        self.publisher = NULL;
    }

    if (self.statusCallback) {
        delete self.statusCallback;
        self.statusCallback = NULL;
    }

    // 销毁影音Buffer
    if (self.mpMuteBuffer) {
        delete self.mpMuteBuffer;
        self.mpMuteBuffer = NULL;
    }

    // 注销前后台切换通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - 对外接口
- (BOOL)publishUrl:(NSString *_Nonnull)url
    recordH264FilePath:(NSString *)recordH264FilePath
     recordAACFilePath:(NSString *_Nullable)recordAACFilePath {
    BOOL bFlag = YES;

    NSLog(@"RtmpPublisherOC::publishUrl( url : %@ )", url);

    @synchronized(self) {
        self.videoPause = NO;
    }
    self.startTime = [NSDate date];
    // 开始推流连接
    bFlag = self.publisher->PublishUrl(url?[url UTF8String]:"", recordH264FilePath?[recordH264FilePath UTF8String]:"", recordAACFilePath?[recordAACFilePath UTF8String]:"");

    return bFlag;
}

- (void)stop {
    NSLog(@"RtmpPublisherOC::stop()");
    // 停止推流
    self.publisher->Stop();
}

- (BOOL)updateVideoParam:(RtmpVideoParam *)videoParam {
    NSLog(@"RtmpPublisherOC::updateVideoParam()");
    // 设置视频参数
    self.videoParam = videoParam;
    return self.publisher->SetVideoParam(self.videoParam.width, self.videoParam.height, self.videoParam.fps, self.videoParam.keyFrameInterval, self.videoParam.bitrate, VIDEO_FORMATE_BGRA);
}

- (void)pushVideoFrame:(CVPixelBufferRef _Nonnull)pixelBuffer {
    // 放到推流器
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    char *data = (char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    int size = (int)CVPixelBufferGetDataSize(pixelBuffer);
    self.publisher->PushVideoFrame(data, size, (void *)pixelBuffer);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

- (void)pausePushVideo {
    NSLog(@"RtmpPublisherOC::pausePushVideo()");
    self.publisher->PausePushVideo();
}

- (void)resumePushVideo {
    NSLog(@"RtmpPublisherOC::resumePushVideo()");
    self.publisher->ResumePushVideo();
}

- (void)pushAudioFrame:(CMSampleBufferRef _Nonnull)sampleBuffer {
    char *data = NULL;
    size_t size = 0;
    OSStatus status = noErr;

    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &size, &data);
    if (status == kCMBlockBufferNoErr) {
        void *buffer = data;

        if (_mute) {
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
    if (_mute != mute) {
        _mute = mute;
    }
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    if (_isBackground == NO) {
        _isBackground = YES;

        // 销毁硬编码器
        self.videoEncoder->Pause();
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (_isBackground == YES) {
        _isBackground = NO;

        // 重置视频编码器
        self.videoEncoder->Reset();
    }
}

#pragma mark - 私有方法
- (void)createEncoders {
    if (_useHardEncoder) {
        // 硬编码

        // 创建硬编码器
        self.videoEncoder = new VideoHardEncoder();
        self.audioEncoder = new AudioHardEncoder();

    } else {
        // 软解码
        self.videoEncoder = new VideoEncoderH264();
        self.audioEncoder = new AudioEncoderAAC();
    }
}

- (void)destroyEncoders {
    if (self.videoEncoder) {
        delete self.videoEncoder;
        self.videoEncoder = nil;
        self.publisher->SetVideoEncoder(NULL);
    }

    if (self.audioEncoder) {
        delete self.audioEncoder;
        self.audioEncoder = nil;
        self.publisher->SetAudioEncoder(NULL);
    }
}

- (void)writeDataToFile:(const void *)bytes length:(NSUInteger)length filePath:(NSString *)filePath {
    NSData *data = [NSData dataWithBytes:bytes length:length];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!fileHandle) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }

    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
    }
}

- (UIImage *)pixelBuffer2Image:(CVPixelBufferRef _Nonnull)pixelBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *cxt = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [cxt createCGImage:ciImage fromRect:CGRectMake(0,0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

@end
