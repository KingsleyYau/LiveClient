//
//  StreamViewController.m
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "StreamViewController.h"
#import "StreamFileCollectionViewController.h"

#import "LiveStreamSession.h"
#import "LiveStreamPlayer.h"
#import "LiveStreamPublisher.h"

#import "LSImageVibrateFilter.h"

@interface StreamViewController () <LiveStreamPlayerDelegate, StreamFileCollectionViewControllerDelegate>

@property (strong) NSArray<GPUImageFilter *> *playerFilterArray;

@property (strong) LiveStreamPublisher *publisher;
@property (strong) LiveStreamPlayer *player;

@property (strong) UITapGestureRecognizer *singleTap;

@property (assign) BOOL isScale;
@property (assign) UIDeviceOrientation deviceOrientation;

@end

@implementation StreamViewController
#pragma mark - 界面初始化
- (void)dealloc {
    NSLog(@"StreamViewController::dealloc()");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.deviceOrientation = [UIDevice currentDevice].orientation;

    // 初始化播放
    self.playerFilterArray = @[
        [[LSImageVibrateFilter alloc] init],
        [[LSImageVibrateFilter alloc] init],
    ];
    self.player = [LiveStreamPlayer instance];
    self.player.delegate = self;
    self.player.playView = self.previewView;
    self.player.customFilter = self.playerFilterArray[0];
    self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatio;

    // 界面处理
    self.title = @"Stream Player";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    self.labelVideoSize.text = @"";
    self.labelFps.text = @"";
    [self.sliderCacheMS addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

    // 初始化推送
    self.publisher = [LiveStreamPublisher instance:LiveStreamType_480x320];
    self.previewPublishView.fillMode = kGPUImageFillModePreserveAspectRatio;
    self.publisher.publishView = self.previewPublishView;
    LSImageVibrateFilter *vibrateFilter = [[LSImageVibrateFilter alloc] init];
    self.publisher.customFilter = vibrateFilter;

    // Live
//    NSString *url = @"rtmp://198.211.27.71:4000/cdn_standard/max0";
    NSString *url = @"rtmp://52.196.96.7:4000/cdn_standard/max0";
    //    NSString *url = @"rtmp://18.194.23.38:4000/cdn_standard/max0";
    //    NSString *url = @"rtmp://172.25.32.133:4000/cdn_standard/max0";

    //    // Camshare
//        NSString *url = @"rtmp://52.196.96.7:1935/mediaserver/camsahre";
    //    NSString *url = @"rtmp://172.25.32.133:1935/mediaserver/camsahre";

    self.textFieldAddress.text = [NSString stringWithFormat:@"%@", url, nil];
    self.textFieldPublishAddress.text = [NSString stringWithFormat:@"%@", url, nil],

    [self play:nil];
    //    [[LiveStreamSession session] checkAudio:^(BOOL granted) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            if (!granted) {
    //                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"请开启麦克风权限" preferredStyle:UIAlertControllerStyleAlert];
    //                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
    //                                                                   style:UIAlertActionStyleDefault
    //                                                                 handler:^(UIAlertAction *_Nonnull action){
    //
    //                                                                 }];
    //                [alertVC addAction:actionOK];
    //                [self presentViewController:alertVC animated:NO completion:nil];
    //            }
    //        });
    //    }];
    //
    //    [[LiveStreamSession session] checkVideo:^(BOOL granted) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            if (!granted) {
    //                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"请开启摄像头权限" preferredStyle:UIAlertControllerStyleAlert];
    //                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
    //                                                                   style:UIAlertActionStyleDefault
    //                                                                 handler:^(UIAlertAction *_Nonnull action){
    //
    //                                                                 }];
    //                [alertVC addAction:actionOK];
    //                [self presentViewController:alertVC animated:NO completion:nil];
    //            }
    //        });
    //    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // 添加手势
    [self addSingleTap];

    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    // 去除手势
    [self removeSingleTap];

//    // 停止流
//    [self stopPlay:nil];
//    [self stopPush:nil];

    // 允许锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 播放相关
- (IBAction)scale:(id)sender {
    self.isScale = !self.isScale;
    [self changeOrientation];
}

- (IBAction)playbackRate1x:(id)sender {
    self.player.playbackRate = 1.0f;
}

- (IBAction)playbackRate2x:(id)sender {
    self.player.playbackRate = 2.0f;
}

- (IBAction)mutePlay:(id)sender {
    self.player.mute = !self.player.mute;
}

- (IBAction)filterPlay:(id)sender {
    if (self.player) {
        if (!self.player.customFilter) {
            self.player.customFilter = self.playerFilterArray[0];
        } else {
            self.player.customFilter = nil;
        }
    }
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.player.cacheMS = (int)roundf(slider.value);
    self.labelCacheMS.text = [NSString stringWithFormat:@"%ldms", self.player.cacheMS, nil];
}

- (IBAction)play:(id)sender {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *recordFilePath = @"";     //[NSString stringWithFormat:@"%@/%@.flv", recordDir, @"max"];
    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/play_%d.h264", recordDir, 0];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/play_%d.aac", recordDir, i];

    NSString *playUrl = [NSString stringWithFormat:@"%@", self.textFieldAddress.text];
    [self.player playUrl:playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
}

- (IBAction)playFile:(id)sender {
    StreamFileCollectionViewController *vc = [[StreamFileCollectionViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)stopPlay:(id)sender {
    [self.player stop];
}

#pragma mark - 播放器状态回调
- (void)playerOnInfoChange:(LiveStreamPlayer *_Nonnull)player videoDisplayWidth:(int)videoDisplayWidth vieoDisplayHeight:(int)vieoDisplayHeight {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelVideoSize.text = [NSString stringWithFormat:@"%dx%d", videoDisplayWidth, vieoDisplayHeight, nil];
    });
}

- (void)playerOnStats:(LiveStreamPlayer *_Nonnull)player fps:(unsigned int)fps bitrate:(unsigned int)bitrate {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelFps.text = [NSString stringWithFormat:@"fps:%u  %ukbps", fps, bitrate, nil];
    });
}

#pragma mark - 推流相关
- (IBAction)publish:(id)sender {
    self.previewPublishView.hidden = NO;

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/%@", recordDir, @"publish.h264"];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/%@", recordDir, @"publish.aac"];

    [self.publisher pushlishUrl:self.textFieldPublishAddress.text recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
}

- (IBAction)stopPush:(id)sender {
    [self.publisher stop];
    self.previewPublishView.hidden = YES;
}

- (IBAction)beauty:(id)sender {
    self.publisher.beauty = !self.publisher.beauty;
}

- (IBAction)mute:(id)sender {
    self.publisher.mute = !self.publisher.mute;
}

- (IBAction)roate:(id)sender {
    [self.publisher rotateCamera];
}

- (IBAction)startCam:(id)sender {
    [self.publisher startPreview];
}

- (IBAction)stopCam:(id)sender {
    [self.publisher stopPreview];
}

#pragma mark - 单击屏幕
- (void)addSingleTap {
    //    if (self.singleTap == nil) {
    //        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
    //        [self.view addGestureRecognizer:self.singleTap];
    //    }
}

- (void)removeSingleTap {
    //    if (self.singleTap) {
    //        [self.view removeGestureRecognizer:self.singleTap];
    //        self.singleTap = nil;
    //        self.singleTap.delegate = nil;
    //    }
}

- (void)singleTapAction {
    //    [self.textFieldAddress resignFirstResponder];
    //    [self.textFieldPublishAddress resignFirstResponder];
    //
    //    self.navigationController.navigationBar.alpha = 0.7;
    //    self.navigationController.navigationBar.hidden = NO;
    //
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [UIView animateWithDuration:1
    //            animations:^{
    //                self.navigationController.navigationBar.alpha = 0;
    //            }
    //            completion:^(BOOL finished) {
    //                self.navigationController.navigationBar.hidden = YES;
    //            }];
    //    });
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    //    BOOL bFlag = NO;

    // Ensures that all pending layout operations have been completed
    [self.view layoutIfNeeded];

    if (height != 0) {
        // 弹出键盘
        self.playBottom.constant = -(height + 20);

    } else {
        // 收起键盘
        self.playBottom.constant = -20;
    }

    [UIView animateWithDuration:duration
                     animations:^{
                         // Make all constraint changes here, Called on parent view
                         [self.view layoutIfNeeded];

                     }
                     completion:^(BOOL finished){

                     }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    // 动画收起键盘
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

#pragma mark - 旋转和全屏播放
- (void)deviceOrientationChange:(id)sender {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsValidInterfaceOrientation(deviceOrientation)) {
        self.deviceOrientation = deviceOrientation;
        [self changeOrientation];
    }
}

- (void)changeOrientation {
    UIDeviceOrientation deviceOrientation = self.deviceOrientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            // Device oriented vertically, home button on the bottom
            NSLog(@"StreamViewController::deviceOrientationChange( [Portrait] )");
        case UIDeviceOrientationPortraitUpsideDown: {
            // Device oriented vertically, home button on the top
            NSLog(@"StreamViewController::deviceOrientationChange( [PortraitUpsideDown] )");
            self.player.playView.fillMode = self.isScale ? kGPUImageFillModePreserveAspectRatioAndFill : kGPUImageFillModePreserveAspectRatio;
            [self hideControll:self.isScale];
        } break;
        case UIDeviceOrientationLandscapeLeft:
            // Device oriented horizontally, home button on the right
            NSLog(@"StreamViewController::deviceOrientationChange( [LandscapeLeft] )");
        case UIDeviceOrientationLandscapeRight: {
            // Device oriented horizontally, home button on the left
            NSLog(@"StreamViewController::deviceOrientationChange( [LandscapeRight] )");
            self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatio;
            [self hideControll:YES];
        } break;
        default:
            break;
    }
}

- (void)hideControll:(BOOL)hidden {
    [self.navigationController setNavigationBarHidden:hidden];
    self.controlView.hidden = hidden;

    if (hidden) {
        [NSLayoutConstraint deactivateConstraints:@[ self.previewViewRadio ]];
        [NSLayoutConstraint activateConstraints:@[ self.previewViewBottom ]];
    } else {
        [NSLayoutConstraint deactivateConstraints:@[self.previewViewBottom]];
        [NSLayoutConstraint activateConstraints:@[self.previewViewRadio]];
    }
}

#pragma mark - 播放本地文件
- (void)didSelectFile:(FileItem *)fileItem {
    [self.player playFilePath:fileItem.filePath];
}

@end
