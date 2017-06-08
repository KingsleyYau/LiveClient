//
//  LiveStreamPublisher.m
//  livestream
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveStreamPublisher.h"

#import "RtmpPublisherOC.h"

#import "GPUImageBeautifyFilter.h"
#import "LFGPUImageBeautyFilter.h"

#define VIDEO_CAPTURE_WIDTH 640
#define VIDEO_CAPTURE_HEIGHT 480

@interface LiveStreamPublisher() <AVCaptureAudioDataOutputSampleBufferDelegate, RtmpPublisherOCDelegate>

@property (assign) BOOL isStart;
@property (assign) BOOL isRunning;
@property (strong) NSString * _Nonnull url;
@property (strong) NSString * _Nullable recordH264FilePath;
@property (strong) NSString * _Nullable recordAACFilePath;

#pragma mark - 传输处理
/**
 RTMP推拉流模块
 */
@property (strong) RtmpPublisherOC* publisher;

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
 视频输出处理
 */
@property (nonatomic , strong) GPUImageRawDataOutput *output;

@property(nonatomic, strong) AVCaptureSession * flashSession;

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

@implementation LiveStreamPublisher
#pragma mark - 获取实例
+ (instancetype)instance
{
    LiveStreamPublisher *obj = [[[self class] alloc] init];
    return obj;
}

- (instancetype)init
{
    if(self = [super init] ) {
        self.publisher = [RtmpPublisherOC instance];
        self.publisher.delegate = self;
        
        _isRunning = NO;
        _isStart = NO;
        _beauty = YES;
        
        [self initVideoCapture];
        [self initAudioCapture];
        
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
- (BOOL)pushlishUrl:(NSString * _Nonnull)url recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString *)recordAACFilePath {
    NSLog(@"LiveStreamPublisher::pushlishUrl( url : %@, recordH264FilePath : %@, recordAACFilePath : %@ )", url, recordH264FilePath, recordAACFilePath);
    
    self.url = url;
    self.recordH264FilePath = recordH264FilePath;
    self.recordAACFilePath = recordAACFilePath;

    [self stop];
    
    BOOL bFlag = NO;
    @synchronized (self) {
        self.isStart = YES;
        bFlag = [self start];
    }
    
    return bFlag;
}

- (void)stop {
    @synchronized (self) {
        self.isStart = NO;
        [self cancel];
    }
}

- (void)rotateCamera {
    [self.videoCaptureSession rotateCamera];
    // 设置后置摄像头不水平反转
    self.videoCaptureSession.horizontallyMirrorRearFacingCamera = NO;
    // 设置前置摄像头水平反转
    self.videoCaptureSession.horizontallyMirrorFrontFacingCamera = YES;
    // 设置帧数
    self.videoCaptureSession.frameRate = FPS;
}

- (void)openFlashlight {
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ( device && device.torchMode == AVCaptureTorchModeOff ) {
        // Create an AV session
        AVCaptureSession * session = [[AVCaptureSession alloc] init];
        
        // Create device input and add to current session
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        [session addInput:input];
        
        // Create video output and add to current session
        AVCaptureVideoDataOutput * output = [[AVCaptureVideoDataOutput alloc]init];
        [session addOutput:output];
        
        // Start session configuration
        [session beginConfiguration];
        [device lockForConfiguration:nil];
        
        // Set torch to on
        [device setTorchMode:AVCaptureTorchModeOn];
        
        [device unlockForConfiguration];
        [session commitConfiguration];
        
        // Start the session
        [session startRunning];
        
        self.flashSession = session;
    }
}

- (void)closeFlashlight {
    [self.flashSession stopRunning];
}

#pragma mark - 私有方法
- (void)setPublishView:(GPUImageView *)publishView {
    if( _publishView != publishView ) {
        _publishView = publishView;
        
        [self.videoCaptureSession removeAllTargets];
        
        if( _beauty ) {
            [self.videoCaptureSession addTarget:self.beautyFilter];
            [self.beautyFilter addTarget:self.output];
            
            if( _publishView ) {
                [self.beautyFilter addTarget:_publishView];
            }
            
        } else {
            [self.videoCaptureSession addTarget:self.output];
            
            if( _publishView ) {
                [self.videoCaptureSession addTarget:_publishView];
            }
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

- (void)cancel {
    NSLog(@"LiveStreamPublisher::cancel()");

    if( self.isRunning == YES ) {
        self.isRunning = NO;
        
        // 先停止采集
        [self stopCapture];
        
        // 销毁编码器
        [self.publisher stop];
    }

}

- (BOOL)start {
    NSLog(@"LiveStreamPublisher::start()");
    
    BOOL bFlag = YES;

    if( self.isRunning == NO ) {
        self.isRunning = YES;
        
        bFlag = [self.publisher publishUrl:self.url width:VIDEO_CAPTURE_WIDTH height:VIDEO_CAPTURE_HEIGHT recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
        if( bFlag ) {
            // 开始采集音视频
            [self startCapture];
        }
    }    
    
    return bFlag;
}

#pragma mark - 音视频采集
- (void)initVideoCapture {
    // 创建视频采集器
    self.videoCaptureSession = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCaptureSession.outputImageOrientation = UIInterfaceOrientationPortrait;
    // 设置后置摄像头不水平反转
    self.videoCaptureSession.horizontallyMirrorRearFacingCamera = NO;
    // 设置前置摄像头水平反转
    self.videoCaptureSession.horizontallyMirrorFrontFacingCamera = YES;
    // 设置帧数
    self.videoCaptureSession.frameRate = FPS;
    
    // 创建输出处理
    self.output = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(VIDEO_CAPTURE_WIDTH, VIDEO_CAPTURE_HEIGHT) resultsInBGRAFormat:YES];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.output) weakOutput = self.output;
    [self.output setNewFrameAvailableBlock:^{
        [weakOutput lockFramebufferForReading];
        
        GLubyte *outputBytes = [weakOutput rawBytesForImage];
        NSInteger bytesPerRow = [weakOutput bytesPerRowInOutput];
        
        CVPixelBufferRef pixelBuffer = NULL;
        CVReturn ret = kCVReturnSuccess;
        
        ret = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, VIDEO_CAPTURE_WIDTH, VIDEO_CAPTURE_HEIGHT, kCVPixelFormatType_32BGRA, outputBytes, bytesPerRow, nil, nil, nil, &pixelBuffer);
        if( ret == kCVReturnSuccess ) {
            // 编码并发送视频帧
            [weakSelf.publisher sendVideoFrame:pixelBuffer];
            CVPixelBufferRelease(pixelBuffer);
            
        } else {
            NSLog(@"LiveStreamPublisher::initVideoCapture( [Fail] : %d )", ret);
        }
        
        [weakOutput unlockFramebufferAfterReading];
    }];
    
    // 创建美颜滤镜
    self.beautyFilter = [[LFGPUImageBeautyFilter alloc] init];
    self.beautyFilter.beautyLevel = 1.0;
    //    self.beautyFilter = [[GPUImageBeautifyFilter alloc] init];
    
    if( _beauty ) {
        [self.videoCaptureSession addTarget:self.beautyFilter];
        [self.beautyFilter addTarget:self.output];
    } else {
        [self.videoCaptureSession addTarget:self.output];
    }
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
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.audioCaptureSession startRunning];
        [self.videoCaptureSession startCameraCapture];
//    });
}

- (void)stopCapture {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if( self.audioCaptureSession.running ) {
            [self.audioCaptureSession stopRunning];
        }
        
        if( self.videoCaptureSession ) {
            [self.videoCaptureSession stopCameraCapture];
        }
//    });
}

#pragma mark - 音频采集处理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if( self.audioCaptureOutput == captureOutput ) {
        if( sampleBuffer ) {
            // 获取到音频PCM
            [self.publisher sendAudioFrame:sampleBuffer];
        }
    }
}

#pragma mark - 视频接收处理
- (void)rtmpPublisherOCOnDisconnect:(RtmpPublisherOC * _Nonnull)publisher {
    NSLog(@"LiveStreamPublisher::rtmpPublisherOCOnDisconnect()");
//    dispatch_async(dispatch_get_main_queue(), ^{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @synchronized (self) {
            // 先停止
            [self cancel];
            
            // 断线重连
            if( self.isStart ) {
                // 重连
                [self start];
            }
        }
    });
}

#pragma mark - 视频采集后台
- (void)willEnterBackground:(NSNotification *)notification {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.videoCaptureSession pauseCameraCapture];
}

- (void)willEnterForeground:(NSNotification *)notification {
    [self.videoCaptureSession resumeCameraCapture];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

@end
