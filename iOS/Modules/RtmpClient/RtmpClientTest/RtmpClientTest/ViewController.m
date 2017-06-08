//
//  ViewController.m
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ViewController.h"
#import "RtmpClient.h"


@interface ViewController () <GPUImageInput>
@property (strong) RtmpClient* client;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *videoLayer;
@property (nonatomic, strong) NSString* url;

@property (nonatomic, strong) GPUImageVideoCamera* camera;

@property (nonatomic, strong) GPUImageFilter* filter;

@property (nonatomic, strong) GPUImageFramebuffer* inputFramebufferForDisplay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

//    self.videoLayer = [[AVSampleBufferDisplayLayer alloc] init];
//    self.videoLayer.frame = self.publishView.bounds;
//    self.videoLayer.position = CGPointMake(CGRectGetMidX(self.publishView.bounds), CGRectGetMidY(self.publishView.bounds));
//    self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    self.videoLayer.opaque = YES;
//    [self.publishView.layer addSublayer:self.videoLayer];
//    
    self.client = [RtmpClient instance];
//    self.client.videoPublishLayer = self.videoLayer;
    
//    self.url = @"rtmp://103.235.46.39:80/live/livestream";
    self.url = @"rtmp://172.25.32.17/live/livestream";
//    self.url = @"rtmp://192.168.88.17/live/livestream";
    
    self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorRearFacingCamera = YES;
    
//    GPUImageColorInvertFilter* ivrFilter = [[GPUImageColorInvertFilter alloc] init];
//    [self.camera addTarget:ivrFilter];
//    [ivrFilter addTarget:self.gpuImageView];
    
    GPUImageBulgeDistortionFilter* blendFilter = [[GPUImageBulgeDistortionFilter alloc] init];
    blendFilter.radius = 1.0;
    [blendFilter addTarget:self];
    [blendFilter addTarget:self.gpuImageView];

    self.filter = blendFilter;
    [self.camera addTarget:blendFilter];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publish:(id)sender {
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* recordH264FilePath = [NSString stringWithFormat:@"%@/%@", cacheDir, @"publish.h264"];
    
    [self.client pushlishUrl:self.url recordH264FilePath:recordH264FilePath];
    
    [self.camera startCameraCapture];
}

- (IBAction)play:(id)sender {
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* recordFilePath = [NSString stringWithFormat:@"%@/%@", cacheDir, @"play.flv"];
    NSString* recordH264FilePath = [NSString stringWithFormat:@"%@/%@", cacheDir, @"play.h264"];
    
    [self.client playUrl:self.url recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath];
}

- (IBAction)stop:(id)sender {
    [self.client stop];
}

+ (CVPixelBufferRef)pixelBufferFromImage:(CGImageRef)image {
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image)); // Not sure why this is even necessary, using CGImageGetWidth/Height in status/context seems to work fine too
    
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height, kCVPixelFormatType_32BGRA, nil, &pixelBuffer);
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, frameSize.width, frameSize.height, 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace, (CGBitmapInfo) kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
}

#pragma mark -
#pragma mark GPUInput protocol

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    CGImageRef imageRef = [self.inputFramebufferForDisplay newCGImageFromFramebufferContents];
    if( imageRef ) {
        CVPixelBufferRef imageBuffer = [ViewController pixelBufferFromImage:imageRef];
        [self.client sendImageBuffer:(CVImageBufferRef)imageBuffer];

        // self.inputFramebufferForDisplay will unlock by CGImageRelease
        CGImageRelease(imageRef);
        
    }
}

- (NSInteger)nextAvailableTextureIndex {
    return 0;
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    self.inputFramebufferForDisplay = newInputFramebuffer;
    [self.inputFramebufferForDisplay lock];
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {

}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {

}

- (CGSize)maximumOutputSize {
    return self.view.bounds.size;
}

- (void)endProcessing {
}

- (BOOL)shouldIgnoreUpdatesToThisTarget {
    return NO;
}

- (BOOL)wantsMonochromeInput {
    return NO;
}

- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue {
    
}

@end
