//
//  LiveStreamClient.m
//  livestream
//
//  Created by Max on 2017/4/8.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveStreamClient.h"
#import "RtmpClient.h"

#import "GPUImageBeautifyFilter.h"
#import "LFGPUImageBeautyFilter.h"

#define VIDEO_CAPTURE_WIDTH 640
#define VIDEO_CAPTURE_HEIGHT 480
#define VIDEO_CAPTURE_BYTEPERROW 2560 // 640 * 4

@interface LiveStreamClient() <GPUImageInput, AVCaptureAudioDataOutputSampleBufferDelegate, RtmpClientDelegate>
@property (assign) CVPixelBufferPoolRef pixelBufferPool;
#pragma mark - 传输处理
/**
 RTMP推拉流模块
 */
@property (strong) RtmpClient* client;

#pragma mark - 视频处理
/**
 视频采集
 */
@property (nonatomic, strong) GPUImageVideoCamera* videoCaptureSession;
/**
 滤镜处理后Buffer
 */
@property (nonatomic, strong) GPUImageFramebuffer* inputFramebuffer;
/**
 美颜滤镜
 */
@property (nonatomic, strong) LFGPUImageBeautyFilter* beautyFilter;
//@property (nonatomic, strong) GPUImageBeautifyFilter* beautyFilter;
/**
 <#Description#>
 */
@property (nonatomic , strong) GPUImageRawDataOutput *output;
/**
 是否推流
 */
@property (atomic, assign) BOOL isPublish;
/**
 <#Description#>
 */
@property (nonatomic, strong) AVSampleBufferDisplayLayer *videoLayer;

#pragma mark - 音频处理
/**
 音视频采集会话
 */
@property (strong) AVCaptureSession* audioCaptureSession;
/**
 音频采集设备
 */
@property (strong) AVCaptureDevice* audioCaptureDevice;
/**
 音频采集处理
 */
@property (strong) AVCaptureDeviceInput* audioCaptureInput;
/**
 音频采集处理
 */
@property (strong) AVCaptureAudioDataOutput* audioCaptureOutput;
/**
 音频采集队列
 */
@property (strong) dispatch_queue_t audio_capture_queue;

@end

@implementation LiveStreamClient

#pragma mark - 获取实例
+ (instancetype)instance
{
    LiveStreamClient *obj = [[[self class] alloc] init];
    return obj;
}

- (instancetype)init
{
    if(self = [super init] ) {
        self.client = [RtmpClient instance];
        self.client.delegate = self;
        
        _beauty = NO;
        self.isPublish = NO;

        [self initVideoCapture];
        [self initAudioCapture];

//        NSDictionary* poolAttributes = @{
//                                         (NSString *)kCVPixelBufferPoolAllocationThresholdKey : @1,
//                                         (NSString *)kCVPixelBufferPoolMinimumBufferCountKey : @30,
//                                         };
//        
//        NSDictionary* pixelBufferAttributes = @{
//                                                (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
//                                                (NSString *)kCVPixelBufferWidthKey : @VIDEO_CAPTURE_WIDTH,
//                                                (NSString *)kCVPixelBufferHeightKey : @VIDEO_CAPTURE_HEIGHT,
//                                                (NSString *)kCVPixelBufferBytesPerRowAlignmentKey : @VIDEO_CAPTURE_BYTEPERROW
//                                                };
//
//        CVReturn code = CVPixelBufferPoolCreate(kCFAllocatorDefault, (__bridge CFDictionaryRef)poolAttributes, (__bridge CFDictionaryRef)pixelBufferAttributes, &_pixelBufferPool);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 对外接口
- (BOOL)playUrl:(NSString * _Nonnull)url recordFilePath:(NSString *)recordFilePath recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString * _Nullable)recordAACFilePath {
    NSLog(@"LiveStreamClient::playUrl( url : %@, recordFilePath : %@, recordH264FilePath : %@ )", url, recordFilePath, recordH264FilePath);
    
    BOOL bFlag = YES;
    bFlag = [self.client playUrl:url recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
    
    return bFlag;
}

- (BOOL)pushlishUrl:(NSString * _Nonnull)url recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString *)recordAACFilePath {
    NSLog(@"LiveStreamClient::pushlishUrl( url : %@, recordH264FilePath : %@, recordAACFilePath : %@ )", url, recordH264FilePath, recordAACFilePath);
    
    BOOL bFlag = YES;
    bFlag = [self.client publishUrl:url recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
    if( bFlag ) {
        // 标记为发布
        self.isPublish = YES;

        // 开始采集音视频
        [self startCapture];
    }
    
    return bFlag;
}

- (void)stop {
    if( self.isPublish ) {
        self.isPublish = NO;
        [self stopCapture];
    }
    
    [self.client stop];
}

#pragma mark - 私有方法
- (void)setPublishView:(GPUImageView *)publishView {
    if( _publishView != publishView ) {
        if( _publishView != nil ) {
            [self.videoCaptureSession removeTarget:_publishView];
            _publishView = nil;
        }
        
        _publishView = publishView;
        [self.videoCaptureSession addTarget:_publishView];
    }
}

- (void)setPlayView:(UIImageView *)playView {
    if( _playView != playView ) {
        if( self.videoLayer ) {
            [self.videoLayer removeFromSuperlayer];
        }
        
        _playView = playView;
        if( _playView ) {
            self.videoLayer = [[AVSampleBufferDisplayLayer alloc] init];
            self.videoLayer.frame = _playView.bounds;
            self.videoLayer.position = CGPointMake(CGRectGetMidX(_playView.bounds), CGRectGetMidY(_playView.bounds));
            self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            self.videoLayer.opaque = YES;
            [_playView.layer addSublayer:self.videoLayer];
        }

    }
}

- (void)setBeauty:(BOOL)beauty {
    if( _beauty != beauty ) {
        _beauty = beauty;
        
        [self.videoCaptureSession removeAllTargets];
        
        if( _beauty ) {
            [self.videoCaptureSession addTarget:self.beautyFilter];
            [self.beautyFilter addTarget:self.output];
            if( _publishView ) {
                [self.beautyFilter addTarget:_publishView];
            }
            
        } else {
            if( _publishView ) {
                [self.videoCaptureSession addTarget:self.output];
                [self.videoCaptureSession addTarget:_publishView];
            }
        }
    }
}
#pragma mark - 音视频采集
- (void)initVideoCapture {
    // 创建视频采集器
    self.videoCaptureSession = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCaptureSession.outputImageOrientation = UIInterfaceOrientationPortrait;
//    // 设置后置摄像头不水平反转
//    self.videoCaptureSession.horizontallyMirrorRearFacingCamera = NO;
    // 设置前置摄像头水平反转
    self.videoCaptureSession.horizontallyMirrorFrontFacingCamera = YES;
    
    // 创建输出处理
    self.output = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(VIDEO_CAPTURE_WIDTH, VIDEO_CAPTURE_HEIGHT) resultsInBGRAFormat:YES];
    [self.videoCaptureSession addTarget:self.output];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.output) weakOutput = self.output;
    [self.output setNewFrameAvailableBlock:^{
        [weakOutput lockFramebufferForReading];
        
        GLubyte *outputBytes = [weakOutput rawBytesForImage];
        NSInteger bytesPerRow = [weakOutput bytesPerRowInOutput];
        
        CVPixelBufferRef pixelBuffer = NULL;
        CVReturn ret = kCVReturnSuccess;
        
//        ret = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, weakSelf.pixelBufferPool, &pixelBuffer);
//        if( ret == kCVReturnSuccess ) {
//            CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//            uint8_t *copyBaseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
////            NSLog(@" %p ", copyBaseAddress);
//            memcpy(copyBaseAddress, outputBytes, VIDEO_CAPTURE_HEIGHT * bytesPerRow);
//            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//            // 编码并发送视频帧
//            [weakSelf.client sendVideoFrame:pixelBuffer];
//            CVPixelBufferRelease(pixelBuffer);
//        }
//        
        ret = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, VIDEO_CAPTURE_WIDTH, VIDEO_CAPTURE_HEIGHT, kCVPixelFormatType_32BGRA, outputBytes, bytesPerRow, nil, nil, nil, &pixelBuffer);
        if( ret == kCVReturnSuccess ) {
            // 编码并发送视频帧
            [weakSelf.client sendVideoFrame:pixelBuffer];
            CVPixelBufferRelease(pixelBuffer);

        } else {
            NSLog(@"LiveStreamClient::initVideoCapture( [Fail] : %d )", ret);
        }

        [weakOutput unlockFramebufferAfterReading];
    }];
    
    // 创建美颜滤镜
    self.beautyFilter = [[LFGPUImageBeautyFilter alloc] init];
//    self.beautyFilter = [[GPUImageBeautifyFilter alloc] init];
}

- (void)initAudioCapture {
    // 创建音频采集队列
    self.audio_capture_queue = dispatch_queue_create("_audio_capture_queue", NULL);
    self.audioCaptureSession = [[AVCaptureSession alloc] init];
    
    // 获取音频设备
    NSArray* audioDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if( audioDevices.count > 0 ) {
        self.audioCaptureDevice = [audioDevices lastObject];
        
        // 增加音频采集处理
        self.audioCaptureInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioCaptureDevice error:nil];
        if( [self.audioCaptureSession canAddInput:self.audioCaptureInput] ) {
            [self.audioCaptureSession addInput:self.audioCaptureInput];
        }
        
        // 增加音频输出处理
        self.audioCaptureOutput = [[AVCaptureAudioDataOutput alloc] init];
        if ([self.audioCaptureSession canAddOutput:self.audioCaptureOutput]) {
            [self.audioCaptureSession addOutput:self.audioCaptureOutput];
        }
        [self.audioCaptureOutput setSampleBufferDelegate:self queue:self.audio_capture_queue];
    }
}

- (void)startCapture {
    [self.audioCaptureSession startRunning];
    [self.videoCaptureSession startCameraCapture];
}

- (void)stopCapture {
    [self.audioCaptureSession stopRunning];
    [self.videoCaptureSession stopCameraCapture];
}

#pragma mark - 音频采集处理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if( self.audioCaptureOutput == captureOutput ) {
        if( sampleBuffer ) {
            // 获取到音频PCM
            [self.client sendAudioFrame:sampleBuffer];
        }
    }
}

#pragma mark - 视频接收处理
- (void)rtmpClientOnRecvVideoBuffer:(RtmpClient * _Nonnull)rtmpClient sampleBuffer:(CMSampleBufferRef _Nonnull)sampleBuffer {
    if( sampleBuffer ) {
        // 这里显示视频, 可以替换成用OpenGL
        CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
        CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);

        if([self.videoLayer isReadyForMoreMediaData]) {
            dispatch_sync(dispatch_get_main_queue(),^{
                [self.videoLayer enqueueSampleBuffer:sampleBuffer];
            });
        }
    }
}

- (void)rtmpClientOnDisconnect:(RtmpClient * _Nonnull)rtmpClient {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.client stop];
    });
}

#pragma mark - 视频采集后台出炉
- (void)willEnterBackground:(NSNotification *)notification {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.videoCaptureSession pauseCameraCapture];
    runSynchronouslyOnVideoProcessingQueue(^{
        glFinish();
    });
}

- (void)willEnterForeground:(NSNotification *)notification {
    [self.videoCaptureSession resumeCameraCapture];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

@end
