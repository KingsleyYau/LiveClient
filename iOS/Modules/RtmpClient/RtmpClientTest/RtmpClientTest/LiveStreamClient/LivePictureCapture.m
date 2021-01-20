//
//  LivePictureCapture.m
//  RtmpClientTest
//
//  Created by Max on 2021/1/12.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import "LivePictureCapture.h"

@interface LivePictureCapture ()
@property (nonatomic, strong) CaptureFinish captureFinish;
/**
 视频采集
 */
@property (nonatomic, strong) GPUImageVideoCamera *videoCaptureSession;
/**
 视频输出处理
 */
@property (nonatomic, strong) GPUImageRawDataOutput *output;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int time;
@property (nonatomic, strong) UIImage *image;
@end

@implementation LivePictureCapture
- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"LivePictureCapture::init( self: %p )", self);
        // 先初始化摄像头
        [self initVideoCapture];
    }
    return self;
}

- (void)dealloc {
}

- (void)initVideoCapture {
    if (!self.videoCaptureSession) {
        NSLog(@"LivePictureCapture::initVideoCapture( self: %p )", self);

        // 创建视频采集器
        // TODO:1.设置前置摄像头
        self.videoCaptureSession = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset3840x2160 cameraPosition:AVCaptureDevicePositionBack];
        // TODO:2.设置摄像头图像输出逆时针旋转90度
        self.videoCaptureSession.outputImageOrientation = UIInterfaceOrientationPortrait;
        // TODO:3.设置后置摄像头不水平反转
        self.videoCaptureSession.horizontallyMirrorRearFacingCamera = NO;
        // TODO:4.设置前置摄像头水平反转
        self.videoCaptureSession.horizontallyMirrorFrontFacingCamera = YES;
        // TODO:5.设置帧数
        self.videoCaptureSession.frameRate = 30;
        
        NSError *error;
        [self.videoCaptureSession.inputCamera lockForConfiguration:&error];
        [self.videoCaptureSession.inputCamera setFlashMode:AVCaptureFocusModeAutoFocus];
        [self.videoCaptureSession.inputCamera unlockForConfiguration];
    }
}

- (void)capture:(UIInterfaceOrientation)orientation captureFinish:(CaptureFinish)captureFinish {
    // TODO:2.设置摄像头图像输出逆时针旋转90度
    self.videoCaptureSession.outputImageOrientation = orientation;
    
    @synchronized (self) {
        self.captureFinish = captureFinish;
        self.time = 0;
        self.image = 0;
    }
    
    [self createOutputFilter];
    [self startCapture];
}

- (void)startCapture {
    NSLog(@"LivePictureCapture::startCapture( self: %p )", self);
    
    [self.videoCaptureSession startCameraCapture];
    
    // 重新组装滤镜
    [self installFilter];
}

- (void)stopCapture {
    NSLog(@"LivePictureCapture::stopCapture( self: %p )", self);
    
    if (self.videoCaptureSession) {
        [self.videoCaptureSession stopCameraCapture];
    }
}

- (void)createOutputFilter {
    // 创建输出处理
    self.width = 2160;
    self.height = 3840;
    
    if ( UIInterfaceOrientationIsLandscape(self.videoCaptureSession.outputImageOrientation) ) {
        self.width = 3840;
        self.height = 2160;
    }
    self.output = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(self.width, self.height) resultsInBGRAFormat:YES];
    
    WeakObject(self, weakSelf);
    WeakObject(self.output, weakOutput);
    [self.output setNewFrameAvailableBlock:^{
        [weakOutput lockFramebufferForReading];
        
        GLubyte *outputBytes = [weakOutput rawBytesForImage];
        NSInteger bytesPerRow = [weakOutput bytesPerRowInOutput];
        
        CVPixelBufferRef pixelBuffer = NULL;
        CVReturn ret = kCVReturnSuccess;

        NSString *filePath = @"";
        ret = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, weakSelf.width, weakSelf.height, kCVPixelFormatType_32BGRA, outputBytes, bytesPerRow, nil, nil, nil, &pixelBuffer);
        if (ret == kCVReturnSuccess) {
            // 生成图片
            if (weakSelf.time++ >= 5 && !weakSelf.image) {
                UIImage *image = [weakSelf pixelBuffer2Image:pixelBuffer];
                filePath = [weakSelf saveImage:image];
                NSLog(@"LivePictureCapture::init( self: %p, [Capture Finish], filePath: %@ )", weakSelf, filePath);
                
                @synchronized (weakSelf) {
                    weakSelf.image = image;
                    if ( weakSelf.image ) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.captureFinish(filePath);
                            [weakSelf stopCapture];
                        });
                    }
                }
            }
            CVPixelBufferRelease(pixelBuffer);
        } else {
            NSLog(@"LivePictureCapture::init( self: %p, error: %d )", weakSelf, ret);
        }
        
        [weakOutput unlockFramebufferAfterReading];
    }];
}

// TODO:组装滤镜
- (void)installFilter {
    [self.videoCaptureSession removeAllTargets];
    [self.videoCaptureSession addTarget:self.output];
}

- (UIImage *)pixelBuffer2Image:(CVPixelBufferRef _Nonnull)pixelBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *cxt = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [cxt createCGImage:ciImage fromRect:CGRectMake(0,0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

- (NSString *)saveImage:(UIImage *)image {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *captureDir = [NSString stringWithFormat:@"%@/capture", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:captureDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSDate* now = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyyMMdd_hhmmss"];
    NSString *dateString = [fmt stringFromDate:now];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@_%@.png", captureDir, @"C", dateString];
    
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    return filePath;
}

@end
