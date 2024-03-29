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
#import "LSImagePictureFilter.h"
#import "LSImageMovie.h"

#import "LiveStreamSession.h"

#pragma mark - 摄像头采集分辨率
#define VIDEO_CAPTURE_WIDTH 480
#define VIDEO_CAPTURE_HEIGHT 640
#define VIDEO_CAPTURE_FPS 30

@interface LiveStreamPublisher () <AVCaptureAudioDataOutputSampleBufferDelegate, RtmpPublisherOCDelegate, LSImageMovieDelegate> {
    GPUImageFilter *_customFilter;
    UIImage *_image;
}

@property (strong) NSString *_Nonnull url;
@property (strong) NSString *_Nullable filePath;
@property (strong) NSString *_Nullable recordH264FilePath;
@property (strong) NSString *_Nullable recordAACFilePath;

@property (assign) BOOL isStart;
@property (assign) BOOL isConnected;
@property (assign) BOOL isPreview;
@property (assign) CGSize videoSize;

#pragma mark - 传输处理
/**
 RTMP推拉流模块
 */
@property (strong) RtmpPublisherOC *publisher;
/**
 视频参数
 */
@property (strong) RtmpVideoParam *videoParam;
#pragma mark - 视频处理
/**
 视频采集
 */
@property (nonatomic, strong) GPUImageVideoCamera *videoCaptureSession;
@property (nonatomic, strong) LSImageMovie *videoMovieSession;
/**
 美颜滤镜
 */
@property (nonatomic, strong) LFGPUImageBeautyFilter *beautyFilter;
//@property (nonatomic, strong) GPUImageBeautifyFilter* beautyFilter;

/**
 图片输入
 */
@property (nonatomic, strong) LSImagePictureFilter *pictureFilter;
/**
 裁剪滤镜
 */
@property (nonatomic, strong) GPUImageCropFilter *cropFilter;
/**
 视频输出处理
 */
@property (nonatomic, strong) GPUImageRawDataOutput *output;
/**
 闪光灯
 */
@property (nonatomic, strong) AVCaptureSession *flashSession;

#pragma mark - 音频处理
/**
 音视频采集会话
 */
@property (strong) AVCaptureSession *audioCaptureSession;
/**
 音频采集设备
 */
@property (strong) AVCaptureDevice *audioCaptureDevice;
/**
 音频采集处理
 */
@property (strong) AVCaptureDeviceInput *audioCaptureInput;
/**
 音频采集处理
 */
@property (strong) AVCaptureAudioDataOutput *audioCaptureOutput;
/**
 音频采集队列
 */
@property (strong) dispatch_queue_t audio_capture_queue;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;

@end

@implementation LiveStreamPublisher
#pragma mark - 获取实例
+ (instancetype)instance:(LiveStreamType)liveStreamType {
    LiveStreamPublisher *obj = [[[self class] alloc] initWithType:liveStreamType];
    return obj;
}

- (instancetype)initWithType:(LiveStreamType)liveStreamType {
    if (self = [super init]) {
        NSLog(@"LiveStreamPublisher::initWithType( self : %p, liveStreamType : %d )", self, liveStreamType);
        
        // 初始化推流参数
        _videoParam = [self videoParamFromStreamParam:liveStreamType];
        
        // 创建推流器
        self.publisher = [RtmpPublisherOC instance:self.videoParam];
        self.publisher.delegate = self;

        self.isPreview = NO;
        self.isConnected = NO;
        self.isStart = NO;

        _beauty = YES;

        // 创建美颜滤镜
        self.beautyFilter = [[LFGPUImageBeautyFilter alloc] init];
        self.beautyFilter.beautyLevel = 0.5;
        
        // 创建输出处理
        self.output = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(self.videoParam.width, self.videoParam.height) resultsInBGRAFormat:YES];
        
        WeakObject(self, weakSelf);
        WeakObject(weakSelf.publisher, weakPublisher);
        WeakObject(self.output, weakOutput);
        [self.output setNewFrameAvailableBlock:^{
            if (weakSelf.isStart) {
                [weakOutput lockFramebufferForReading];
                
                GLubyte *outputBytes = [weakOutput rawBytesForImage];
                NSInteger bytesPerRow = [weakOutput bytesPerRowInOutput];
                
                CVPixelBufferRef pixelBuffer = NULL;
                CVReturn ret = kCVReturnSuccess;

                ret = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, weakSelf.videoParam.width, weakSelf.videoParam.height, kCVPixelFormatType_32BGRA, outputBytes, bytesPerRow, nil, nil, nil, &pixelBuffer);
                if (ret == kCVReturnSuccess) {
                    // 将视频帧放进推流器
                    [weakPublisher pushVideoFrame:pixelBuffer];
                    CVPixelBufferRelease(pixelBuffer);
                } else {
                    NSLog(@"LiveStreamPublisher::initWithType( self : %p, [Send Video Frame Fail], error : %d )", weakSelf, ret);
                }
                
                [weakOutput unlockFramebufferAfterReading];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    NSLog(@"LiveStreamPublisher::dealloc( self : %p )", self);

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 对外接口
- (BOOL)publishUrl:(NSString *_Nonnull)url recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString *)recordAACFilePath {
    NSLog(@"LiveStreamPublisher::publishUrl( self : %p, url : %@ )", self, url);

    BOOL bFlag = YES;

    self.url = url;
    self.filePath = @"";
    self.videoSize = CGSizeZero;
    self.recordH264FilePath = recordH264FilePath;
    self.recordAACFilePath = recordAACFilePath;

    [self cancel];
    [self run];

    return bFlag;
}

- (BOOL)publishUrl:(NSString *)url withVideo:(NSString *)filePath {
    NSLog(@"LiveStreamPublisher::publishUrl( self : %p, url : %@, filePath : %@ )", self, url, filePath);

    BOOL bFlag = YES;

    self.url = url;
    self.filePath = filePath;
    
    [self cancel];
    [self run];

    return bFlag;
}

- (void)stop {
    NSLog(@"LiveStreamPublisher::stop( self : %p )", self);

    [self cancel];
}

- (BOOL)updateVideoParam:(NSInteger)bitrate {
    NSLog(@"LiveStreamPublisher::updateVideoParam( self : %p, bitrate : %d )", self, (int)bitrate);
    RtmpVideoParam *videoParam = [self.videoParam copy];
    videoParam.bitrate = (int)bitrate;
    return [self.publisher updateVideoParam:videoParam];
}

- (void)initCapture {
    NSLog(@"LiveStreamPublisher::initCapture( self : %p )", self);

    [self initVideoCapture];
    [self initAudioCapture];
}

- (void)rotateCamera {
    NSLog(@"LiveStreamPublisher::rotateCamera( self : %p )", self);
    [self.publisher pausePushVideo];
    NSTimeInterval startTime = [NSDate date].timeIntervalSince1970;
    // TODO:1.切换前后摄像头
    [self.videoCaptureSession rotateCamera];
    // TODO:4.设置帧数
    self.videoCaptureSession.frameRate = VIDEO_CAPTURE_FPS;
    NSTimeInterval rotateTime = [NSDate date].timeIntervalSince1970 - startTime;
    [self.publisher resumePushVideo];
    NSLog(@"LiveStreamPublisher::rotateCamera( self : %p, roateTime : %f )", self, rotateTime);
}

- (void)startPreview {
    NSLog(@"LiveStreamPublisher::startPreview( self : %p )", self);

    // 开启音频服务
    [[LiveStreamSession session] startCapture];

    // 开始采集音视频
    [self startCapture];
}

- (void)stopPreview {
    NSLog(@"LiveStreamPublisher::stopPreview( self : %p )", self);

    // 停止采集音视频
    [self stopCapture];

    // 停止音频服务
    [[LiveStreamSession session] stopCapture];
}

- (void)openFlashlight {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && device.torchMode == AVCaptureTorchModeOff) {
        // Create an AV session
        AVCaptureSession *session = [[AVCaptureSession alloc] init];

        // Create device input and add to current session
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        [session addInput:input];

        // Create video output and add to current session
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
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
- (RtmpVideoParam *)videoParamFromStreamParam:(LiveStreamType)liveStreamType {
    RtmpVideoParam *param = [[RtmpVideoParam alloc] init];
    switch (liveStreamType) {
        case LiveStreamType_Audience_Private: {
            param.width = 240;
            param.height = 320;
            param.fps = 10;
            param.keyFrameInterval = 10;
            param.bitrate = 400 * 1000;
        }break;
        case LiveStreamType_Audience_Mutiple: {
            param.width = 240;
            param.height = 240;
            param.fps = 10;
            param.keyFrameInterval = 10;
            param.bitrate= 400 * 1000;
        }break;
        case LiveStreamType_ShowHost_Public:
        case LiveStreamType_ShowHost_Private: {
            param.width = 320;
            param.height = 320;
            param.fps = 12;
            param.keyFrameInterval = 12;
            param.bitrate= 700 * 1000;
        }break;
        case LiveStreamType_ShowHost_Mutiple: {
            param.width = 240;
            param.height = 240;
            param.fps = 12;
            param.keyFrameInterval = 12;
            param.bitrate= 500 * 1000;
        }break;
        case LiveStreamType_Camshare: {
            param.width = 176;
            param.height = 144;
            param.fps = 6;
            param.keyFrameInterval = 6;
            param.bitrate= 64 * 1000;
        }break;
        case LiveStreamType_480x640: {
            param.width = 480;
            param.height = 640;
            param.fps = 12;
            param.keyFrameInterval = 12;
            param.bitrate= 600 * 1000;
        }break;
        default: {
            return nil;
        }break;
    }
    return param;
}

// TODO:切换预览界面
- (void)setPublishView:(GPUImageView *)publishView {
    if (_publishView != publishView) {
        _publishView = publishView;

        [self installFilter];
    }
}

// TODO:切换美颜
- (void)setBeauty:(BOOL)beauty {
    if (_beauty != beauty) {
        _beauty = beauty;

        [self installFilter];
    }
}

// TODO:切换自定义滤镜
- (GPUImageFilter *)customFilter {
    return _customFilter;
}

- (void)setCustomFilter:(GPUImageFilter *)customFilter {
    if (_customFilter != customFilter) {
        _customFilter = customFilter;
        
        [self installFilter];
    }
}

// TODO:创建剪裁滤镜
- (GPUImageFilter *)resetCropFilter:(CGSize)src dst:(CGSize)dst {
    CGRect cropRegion = CGRectMake(0, 0, 1, 1);
    // 源比例
    double radioImage = 1.0 * src.width / src.height;
    // 目标比例
    double radioPreview = 1.0 * dst.width / dst.height;
    if ( radioPreview > radioImage ) {
        // 剪裁上下
        float radio = 1.0f * src.width / dst.width * dst.height / src.height;
        cropRegion = CGRectMake(0, (1 - radio) / 2, 1, radio);
    } else if (radioPreview < radioImage) {
        // 剪裁左右
        float radio = 1.0f * src.height / dst.height * dst.width / src.width;
        cropRegion = CGRectMake((1 - radio) / 2, 0, radio, 1);
    } else {
        // 不剪裁
    }
    
    if(self.cropFilter) {
        self.cropFilter.cropRegion = cropRegion;
    } else {
        self.cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:cropRegion];
    }
    
    return self.cropFilter;
}

// TODO:创建图片输入滤镜
- (GPUImageFilter *)resetPictureFilter {
    if (self.image) {
        self.pictureFilter = [[LSImagePictureFilter alloc] initWithImage:self.image];
    } else {
        self.pictureFilter = nil;
    }
    return self.pictureFilter;
}

// TODO:组装滤镜
- (void)installFilter {
    [self.videoMovieSession removeAllTargets];
    [self.videoCaptureSession removeAllTargets];
    [self.pictureFilter removeAllTargets];
    [self.cropFilter removeAllTargets];
    [self.beautyFilter removeAllTargets];
    [self.customFilter removeAllTargets];
    
    GPUImageFilter *filter = nil;
    // 是否图片
    if (self.pictureFilter) {
        [self.pictureFilter addTarget:self.cropFilter];
        filter = self.pictureFilter;
    } else {
        filter = self.cropFilter;
    }
    
    // 输入源
    if (self.filePath.length > 0) {
        [self.videoMovieSession addTarget:filter];
    } else {
        [self.videoCaptureSession addTarget:filter];
    }
    
    filter = self.cropFilter;
    if (_beauty) {
        [self.cropFilter addTarget:self.beautyFilter];
        filter = self.beautyFilter;
    }
    if( _customFilter ) {
        [filter addTarget:_customFilter];
        filter = _customFilter;
    }
    if (_publishView) {
        [filter addTarget:_publishView];
    }
    [filter addTarget:self.output];
}

// TODO:切换图片
- (UIImage *)image {
    return _image;
}

- (void)setImage:(UIImage *)image {
    NSLog(@"LiveStreamPublisher::setImage( image : %@ )", image);

    _image = image;
    if (self.image) {
        [self resetCropFilter:self.image.size dst:CGSizeMake(self.videoParam.width, self.videoParam.height)];
    } else {
        if (self.filePath.length > 0) {
            [self resetCropFilter:self.videoSize dst:CGSizeMake(self.videoParam.width, self.videoParam.height)];
        } else {
            [self resetCropFilter:CGSizeMake(VIDEO_CAPTURE_WIDTH, VIDEO_CAPTURE_HEIGHT) dst:CGSizeMake(self.videoParam.width, self.videoParam.height)];
        }
    }
    [self resetPictureFilter];
    [self installFilter];
}

// TODO:切换静音
- (BOOL)mute {
    return self.publisher.mute;
}

- (void)setMute:(BOOL)mute {
    NSLog(@"LiveStreamPublisher::setMute( mute : %@ )", BOOL2YES(mute));

    if (self.publisher.mute != mute) {
        self.publisher.mute = mute;
    }
}

- (NSInteger)bitrate {
    return self.videoParam.bitrate;
}

- (void)run {
    NSLog(@"LiveStreamPublisher::run( self : %p )", self);

    @synchronized(self) {
        if (!self.isStart) {
            self.isStart = YES;
            
            if ( self.filePath.length > 0 ) {
                [self startMovie];
            } else {
                // 开启音频服务
                [[LiveStreamSession session] startCapture];

                // 开始采集音视频
                [self startCapture];
            }

            // 仅在前台才运行
            if (!self.isBackground) {
                // 开始推流
                self.isConnected = [self.publisher publishUrl:self.url recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
            } else {
                NSLog(@"LiveStreamPublisher::run( self : %p, [Publisher is in background] )", self);
            }
        }
    }

    NSLog(@"LiveStreamPublisher::run( self : %p, [Finish] )", self);
}

- (void)cancel {
    NSLog(@"LiveStreamPublisher::cancel( self : %p )", self);

    BOOL bHandle = NO;
    @synchronized(self) {
        if (self.isStart) {
            self.isStart = NO;
            bHandle = YES;
        }
    }

    if (bHandle) {
        // 停止读取文件
        [self stopMovie];
        
        // 停止采集音视频
        [self stopCapture];

        // 停止推流
        [self.publisher stop];

        // 停止音频服务
        [[LiveStreamSession session] stopCapture];
    }

    NSLog(@"LiveStreamPublisher::cancel( self : %p, [Finish] )", self);
}

- (void)reconnect {
    BOOL bHandle = NO;

    @synchronized(self) {
        if (self.isStart && !self.isConnected && !self.isBackground) {
            // 1.已经手动开始, 2.连接还没连接上
            bHandle = YES;
        }
    }

    if (bHandle) {
        NSLog(@"LiveStreamPublisher::reconnect( self : %p, [Start] )", self);

        [self.publisher stop];

        // 是否需要切换URL
        if ([self.delegate respondsToSelector:@selector(publisherShouldChangeUrl:)]) {
            self.url = [self.delegate publisherShouldChangeUrl:self];
        }

        @synchronized(self) {
            self.isConnected = [self.publisher publishUrl:self.url recordH264FilePath:self.recordH264FilePath recordAACFilePath:self.recordAACFilePath];
        }

        NSLog(@"LiveStreamPublisher::reconnect( self : %p, [Finish] )", self);
    }
}

#pragma mark - 音视频采集
- (void)initVideoCapture {
    if (!self.videoCaptureSession) {
        NSLog(@"LiveStreamPublisher::initVideoCapture( self : %p )", self);

        // 创建视频采集器
        // TODO:1.设置前置摄像头
        self.videoCaptureSession = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
        // TODO:2.设置摄像头图像输出逆时针旋转90度
        self.videoCaptureSession.outputImageOrientation = UIInterfaceOrientationPortrait;
        // TODO:3.设置后置摄像头不水平反转
        self.videoCaptureSession.horizontallyMirrorRearFacingCamera = NO;
        // TODO:4.设置前置摄像头水平反转
        self.videoCaptureSession.horizontallyMirrorFrontFacingCamera = YES;
        // TODO:5.设置帧数
        self.videoCaptureSession.frameRate = VIDEO_CAPTURE_FPS;
    }
}

- (void)initAudioCapture {
    if (!self.audioCaptureSession) {
        NSLog(@"LiveStreamPublisher::initAudioCapture( self : %p )", self);

        // TODO:1.创建音频采集队列
        self.audio_capture_queue = dispatch_queue_create("_audio_capture_queue", NULL);
        self.audioCaptureSession = [[AVCaptureSession alloc] init];
        self.audioCaptureSession.automaticallyConfiguresApplicationAudioSession = NO;

        // TODO:2.获取音频设备
        NSArray *audioDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
        if (audioDevices.count > 0) {
            self.audioCaptureDevice = [audioDevices lastObject];

            // TODO:3.创建音频采集处理
            self.audioCaptureInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioCaptureDevice error:nil];
            if ([self.audioCaptureSession canAddInput:self.audioCaptureInput]) {
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
    self.isPreview = YES;

    if (self.image) {
        [self resetCropFilter:self.image.size dst:CGSizeMake(self.videoParam.width, self.videoParam.height)];
    } else {
        [self resetCropFilter:CGSizeMake(VIDEO_CAPTURE_WIDTH, VIDEO_CAPTURE_HEIGHT) dst:CGSizeMake(self.videoParam.width, self.videoParam.height)];
    }
    
    // 先初始化摄像头
    [self initCapture];
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [self.videoCaptureSession startCameraCapture];

    if (!self.audioCaptureSession.running) {
        [self.audioCaptureSession startRunning];
    }
    
    // 重新组装滤镜
    [self installFilter];
    //    });
}

- (void)stopCapture {
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    if (self.videoCaptureSession) {
        [self.videoCaptureSession stopCameraCapture];
    }

    if (self.audioCaptureSession.running) {
        [self.audioCaptureSession stopRunning];
    }

    self.isPreview = NO;
    //    });
}

#pragma mark - 视频文件处理
- (void)startMovie {
    self.isPreview = YES;
    
    self.videoMovieSession = [[LSImageMovie alloc] initWithURL:[NSURL fileURLWithPath:self.filePath]];
    self.videoMovieSession.delegate = self;
    self.videoMovieSession.playAtActualSpeed = YES;
    self.videoMovieSession.shouldRepeat = YES;
    [self.videoMovieSession startProcessing];
}

- (void)stopMovie {
    [self.videoMovieSession cancelProcessing];
    self.videoMovieSession = nil;
    self.isPreview = NO;
}

- (void)didLoadPlayingMovie {
    AVAssetTrack *videoTrack = [self.videoMovieSession.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CGSize videoSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    videoSize = CGSizeMake(fabs(videoSize.width), fabs(videoSize.height));
    self.videoSize = videoSize;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetCropFilter:videoSize dst:CGSizeMake(self.videoParam.width, self.videoParam.height)];
        [self installFilter];
    });
}

#pragma mark - 音频采集处理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.audioCaptureOutput == captureOutput) {
        if (sampleBuffer) {
            if (self.isStart) {
                // 获取到音频PCM
                [self.publisher pushAudioFrame:sampleBuffer];
            }
        }
    }
}

#pragma mark - 视频接收处理
- (void)rtmpPublisherOCOnConnect:(RtmpPublisherOC *_Nonnull)rtmpClient {
    NSLog(@"LiveStreamPublisher::rtmpPublisherOCOnConnect( self : %p )", self);

    if ([self.delegate respondsToSelector:@selector(publisherOnConnect:)]) {
        [self.delegate publisherOnConnect:self];
    }
}

- (void)rtmpPublisherOCOnDisconnect:(RtmpPublisherOC *_Nonnull)rtmpClient {
    NSLog(@"LiveStreamPublisher::rtmpPublisherOCOnDisconnect( self : %p )", self);

    if ([self.delegate respondsToSelector:@selector(publisherOnDisconnect:)]) {
        [self.delegate publisherOnDisconnect:self];
    }

    @synchronized(self) {
        self.isConnected = NO;
        if (!self.isStart) {
            // 停止拉流
            NSLog(@"LiveStreamPublisher::rtmpPublisherOCOnDisconnect( self : %p, [Disconnect] )", self);

        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 断线重新拉流
                NSLog(@"LiveStreamPublisher::rtmpPublisherOCOnDisconnect( self : %p, [Delay Check] )", self);

                // 重连
                [self reconnect];
            });
        }
    }
}

- (void)rtmpPublisherOCOnError:(RtmpPublisherOC * _Nonnull)rtmpClient code:(NSString * _Nullable)code description:(NSString * _Nullable)description {
    NSLog(@"LiveStreamPublisher::rtmpPublisherOCOnError( self : %p, code : %@, description : %@ )", self, code, description);

    if ([self.delegate respondsToSelector:@selector(publisherOnError:code:description:)]) {
        [self.delegate publisherOnError:self code:code description:description];
    }
}

#pragma mark - 视频采集后台
- (void)willEnterBackground:(NSNotification *)notification {
    BOOL bHandle = NO;

    @synchronized(self) {
        if (self.isBackground == NO) {
            self.isBackground = YES;
            bHandle = YES;
        }
    }

    if (bHandle) {
        if (self.isPreview) {
            // 暂停视频推送
            [self.publisher pausePushVideo];
            // 暂停摄像头采集队列
            [self.videoCaptureSession pauseCameraCapture];
        }
        
//        // 直接断开连接
//        [self.publisher stop];
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    BOOL bHandle = NO;
    
    @synchronized (self) {
        if (self.isBackground == YES) {
            self.isBackground = NO;
            bHandle = YES;
        }
    }
    
    if( bHandle ) {
        if (self.isPreview) {
            // 恢复摄像头采集队列
            [self.videoCaptureSession resumeCameraCapture];
            // 恢复视频推送
            [self.publisher resumePushVideo];
        }
        
//        // 重连
//        [self reconnect];
    }
}

@end
