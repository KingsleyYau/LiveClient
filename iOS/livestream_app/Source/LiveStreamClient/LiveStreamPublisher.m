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

#import "LiveStreamSession.h"

#pragma mark - 摄像头采集分辨率
#define VIDEO_CAPTURE_WIDTH 240
#define VIDEO_CAPTURE_HEIGHT 320

@interface LiveStreamPublisher() <AVCaptureAudioDataOutputSampleBufferDelegate, RtmpPublisherOCDelegate>

@property (strong) NSString * _Nonnull url;
@property (strong) NSString * _Nullable recordH264FilePath;
@property (strong) NSString * _Nullable recordAACFilePath;

@property (assign) BOOL isStart;
@property (assign) BOOL isConnected;

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
@property (nonatomic, strong) GPUImageRawDataOutput *output;

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

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;

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
        NSLog(@"LiveStreamPublisher::init( self : %p )", self);
        
        self.publisher = [RtmpPublisherOC instance:VIDEO_CAPTURE_WIDTH height:VIDEO_CAPTURE_HEIGHT];
        self.publisher.delegate = self;
        
        _isConnected = NO;
        _isStart = NO;
        _beauty = YES;
        
//        [self initVideoCapture];
//        [self initAudioCapture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"LiveStreamPublisher::dealloc( self : %p )",self);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

#pragma mark - 对外接口
- (void)initCapture {
    NSLog(@"LiveStreamPublisher::initCapture( self : %p )", self);
    
    [self initVideoCapture];
    [self initAudioCapture];
}

- (BOOL)pushlishUrl:(NSString * _Nonnull)url recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString *)recordAACFilePath {
    NSLog(@"LiveStreamPublisher::pushlishUrl( self : %p, url : %@ )", self, url);
    
    BOOL bFlag = YES;
    
    self.url = url;
    self.recordH264FilePath = recordH264FilePath;
    self.recordAACFilePath = recordAACFilePath;
    
    [self cancel];
    [self run];
    
    return bFlag;
}

- (void)stop {
    NSLog(@"LiveStreamPublisher::stop( self : %p )", self);
    
    [self cancel];
}

- (void)rotateCamera {
    // TODO:1.切换前后摄像头
    [self.videoCaptureSession rotateCamera];
    // TODO:2.设置后置摄像头不水平反转
    self.videoCaptureSession.horizontallyMirrorRearFacingCamera = NO;
    // TODO:3.设置前置摄像头水平反转
    self.videoCaptureSession.horizontallyMirrorFrontFacingCamera = YES;
    // TODO:4.设置帧数
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
    // TODO:切换美颜
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

- (BOOL)mute {
    return self.publisher.mute;
}

- (void)setMute:(BOOL)mute {
    // TODO:切换静音
    NSLog(@"LiveStreamPublisher::setMute( mute : %@ )", BOOL2YES(mute));
    
    if( self.publisher.mute != mute ) {
        self.publisher.mute = mute;
    }
}

- (void)run {
    NSLog(@"LiveStreamPublisher::run( self : %p )", self);
    
    @synchronized (self) {
        if( !self.isStart ) {
            self.isStart = YES;
            // 开启音频服务
            [[LiveStreamSession session] startCapture];
            
            // 开始采集音视频
            [self startCapture];
            
            // 开始推流
            self.isConnected = [self.publisher publishUrl:self.url recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
        }
    }
    
    NSLog(@"LiveStreamPublisher::run( [Finish], self : %p )", self);
}

- (void)cancel {
    NSLog(@"LiveStreamPublisher::cancel( self : %p )", self);
    
    BOOL bHandle = NO;
    @synchronized (self) {
        if (self.isStart) {
            self.isStart = NO;
            bHandle = YES;
        }
    }
    
    if( bHandle ) {
        // 停止采集音视频
        [self stopCapture];
        
        // 停止推流
        [self.publisher stop];
        
        // 停止音频服务
        [[LiveStreamSession session] stopCapture];
    }
    
    NSLog(@"LiveStreamPublisher::cancel( [Finish], self : %p )", self);
}

- (void)reconnect {
    BOOL bHandle = NO;
    
    @synchronized (self) {
        if (self.isStart && !self.isConnected && !_isBackground) {
            // 1.已经手动开始, 2.连接还没连接上
            bHandle = YES;
        }
    }
    
    if( bHandle ) {
        NSLog(@"LiveStreamPublisher::reconnect( [Start], self : %p )", self);
        
        [self.publisher stop];
        
        // 是否需要切换URL
        if( [self.delegate respondsToSelector:@selector(publisherShouldChangeUrl:)] ) {
            self.url = [self.delegate publisherShouldChangeUrl:self];
        }
        
        @synchronized (self) {
            self.isConnected = [self.publisher publishUrl:self.url recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
        }
        
        NSLog(@"LiveStreamPublisher::reconnect( [Finish], self : %p )", self);
    }
}

#pragma mark - 音视频采集
- (void)initVideoCapture {
    if( !self.videoCaptureSession ) {
        NSLog(@"LiveStreamPublisher::initVideoCapture( self : %p )", self);
        
        // 创建视频采集器
        // TODO:1.设置前置摄像头
        self.videoCaptureSession = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
        // TODO:2.设置摄像头图像输出顺时针旋转90度
        self.videoCaptureSession.outputImageOrientation = UIInterfaceOrientationPortrait;
        // TODO:3.设置后置摄像头不水平反转
        self.videoCaptureSession.horizontallyMirrorRearFacingCamera = NO;
        // TODO:4.设置前置摄像头水平反转
        self.videoCaptureSession.horizontallyMirrorFrontFacingCamera = YES;
        // TODO:5.设置帧数
        self.videoCaptureSession.frameRate = FPS;
        
        // TODO:6.创建输出处理
        self.output = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(VIDEO_CAPTURE_WIDTH, VIDEO_CAPTURE_HEIGHT) resultsInBGRAFormat:YES];
        
        WeakObject(self, weakSelf);
        WeakObject(self.output, weakOutput);
        [self.output setNewFrameAvailableBlock:^{
            [weakOutput lockFramebufferForReading];
            
            GLubyte *outputBytes = [weakOutput rawBytesForImage];
            NSInteger bytesPerRow = [weakOutput bytesPerRowInOutput];
            
            CVPixelBufferRef pixelBuffer = NULL;
            CVReturn ret = kCVReturnSuccess;
            
            ret = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, VIDEO_CAPTURE_WIDTH, VIDEO_CAPTURE_HEIGHT, kCVPixelFormatType_32BGRA, outputBytes, bytesPerRow, nil, nil, nil, &pixelBuffer);
            if( ret == kCVReturnSuccess ) {
                // 编码并发送视频帧
                [weakSelf.publisher pushVideoFrame:pixelBuffer];
                CVPixelBufferRelease(pixelBuffer);
            } else {
                NSLog(@"LiveStreamPublisher::initVideoCapture( [Fail], self : %p, error : %d )", weakSelf, ret);
            }
            
            [weakOutput unlockFramebufferAfterReading];
        }];
        
        // TODO:7.创建美颜滤镜
        self.beautyFilter = [[LFGPUImageBeautyFilter alloc] init];
        self.beautyFilter.beautyLevel = 0.5;
        //    self.beautyFilter = [[GPUImageBeautifyFilter alloc] init];
        
        if( _beauty ) {
            [self.videoCaptureSession addTarget:self.beautyFilter];
            [self.beautyFilter addTarget:self.output];
        } else {
            [self.videoCaptureSession addTarget:self.output];
        }
    }
}

- (void)initAudioCapture {
    if( !self.audioCaptureSession ) {
        NSLog(@"LiveStreamPublisher::initAudioCapture( self : %p )", self);
        
        // TODO:1.创建音频采集队列
        self.audio_capture_queue = dispatch_queue_create("_audio_capture_queue", NULL);
        self.audioCaptureSession = [[AVCaptureSession alloc] init];
        self.audioCaptureSession.automaticallyConfiguresApplicationAudioSession = NO;
        
        // TODO:2.获取音频设备
        NSArray* audioDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
        if( audioDevices.count > 0 ) {
            self.audioCaptureDevice = [audioDevices lastObject];
            
            // TODO:3.创建音频采集处理
            self.audioCaptureInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioCaptureDevice error:nil];
            if( [self.audioCaptureSession canAddInput:self.audioCaptureInput] ) {
                [self.audioCaptureSession addInput:self.audioCaptureInput];
            }
            
            // TODO:4.创建音频输出处理
            self.audioCaptureOutput = [[AVCaptureAudioDataOutput alloc] init];
            if ([self.audioCaptureSession canAddOutput:self.audioCaptureOutput]) {
                [self.audioCaptureSession addOutput:self.audioCaptureOutput];
            }
            [self.audioCaptureOutput setSampleBufferDelegate:self queue:self.audio_capture_queue];
        }
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
//            @synchronized(self) {
//                if( self.isConnected ) {
                    [self.publisher pushAudioFrame:sampleBuffer];
//                }
//            }
        }
    }
}

#pragma mark - 视频接收处理
- (void)rtmpPublisherOCOnConnect:(RtmpPublisherOC * _Nonnull)rtmpClient {

}

- (void)rtmpPublisherOCOnDisconnect:(RtmpPublisherOC * _Nonnull)rtmpClient {
    NSLog(@"LiveStreamPublisher::rtmpPublisherOCOnDisconnect( self : %p )", self);
    
    @synchronized (self) {
        self.isConnected = NO;
        if (!self.isStart) {
            // 停止拉流
            NSLog(@"LiveStreamPublisher::rtmpPublisherOCOnDisconnect( [Disconnect], self : %p )", self);
            
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 断线重新拉流
                NSLog(@"LiveStreamPublisher::rtmpPublisherOCOnDisconnect( [Delay Check], self : %p )", self);
                
                // 重连
                [self reconnect];
            });
            
        }
    }
}

#pragma mark - 视频采集后台
- (void)willEnterBackground:(NSNotification *)notification {
    BOOL bHandle = NO;
    
    @synchronized (self) {
        if (_isBackground == NO) {
            _isBackground = YES;
            bHandle = YES;
        }
    }
    
    if( bHandle ) {
        // 暂停摄像头采集队列
        [self.videoCaptureSession pauseCameraCapture];
        
        // 直接断开连接
        [self.publisher stop];
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    BOOL bHandle = NO;
    
    @synchronized (self) {
        if (_isBackground == YES) {
            _isBackground = NO;
            bHandle = YES;
        }
    }
    
    if( bHandle ) {
        // 恢复摄像头采集队列
        [self.videoCaptureSession resumeCameraCapture];
        
        // 重连
        [self reconnect];
    }
}

@end
