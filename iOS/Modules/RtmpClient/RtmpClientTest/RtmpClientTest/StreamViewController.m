//
//  StreamViewController.m
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AppDelegate.h"

#import "StreamViewController.h"
#import "StreamFileCollectionViewController.h"
#import "PronViewController.h"

#import "LiveStreamSession.h"
#import "LiveStreamPlayer.h"
#import "LiveStreamPublisher.h"

#import "LSImageVibrateFilter.h"

#import <MediaPlayer/MediaPlayer.h>

@interface StreamViewController () <LiveStreamPlayerDelegate, StreamFileCollectionViewControllerDelegate, PronViewControllerDelegate>

@property (strong) NSArray<GPUImageFilter *> *playerFilterArray;

@property (strong) LiveStreamPublisher *publisher;
@property (strong) LiveStreamPlayer *player;

@property (strong) UITapGestureRecognizer *singleTap;

@property (assign) BOOL isScale;
@property (assign) UIDeviceOrientation deviceOrientation;

@property (strong) NSArray<FileItem *> *fileItemArray;
@property (strong) FileItem *fileItem;
@property (assign) NSInteger fileItemIndex;

@property (assign) float playbackRate;

@end

@implementation StreamViewController
#pragma mark - 界面初始化
- (void)dealloc {
    NSLog(@"StreamViewController::dealloc()");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 界面处理
    self.title = @"Stream Player";
    // 信息
    self.labelVideoSize.text = @"";
    self.labelFps.text = @"";
    [self.sliderCacheMS addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.sliderCacheMS.value = 2000;
    // TODO:旋转
    self.deviceOrientation = [UIDevice currentDevice].orientation;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    // TODO:手势 - 单击收起键盘
    UITapGestureRecognizer *tapCloseKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCloseKeyboardGesture:)];
    tapCloseKeyboard.numberOfTapsRequired = 1;
    [self.previewView addGestureRecognizer:tapCloseKeyboard];
    // TODO:手势 - 双击全屏
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tap.numberOfTapsRequired = 2;
    [self.previewView addGestureRecognizer:tap];
    // TODO:手势 - 长按2倍速度播放
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    longPress.minimumPressDuration = 0.5;
    [self.previewView addGestureRecognizer:longPress];
    // TODO:线控/Airpod控制事件
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.pauseCommand.enabled = NO;
    [commandCenter.pauseCommand addTarget:self action:@selector(pauseCommand)];
    commandCenter.playCommand.enabled = NO;
    [commandCenter.playCommand addTarget:self action:@selector(playCommand)];
    commandCenter.nextTrackCommand.enabled = YES;
    [commandCenter.nextTrackCommand addTarget:self action:@selector(nextTrackCommand)];
    commandCenter.previousTrackCommand.enabled = YES;
    [commandCenter.previousTrackCommand addTarget:self action:@selector(previousTrackCommand)];

    // TODO:初始化播放
    self.playbackRate = 1.0;
    self.playerFilterArray = @[
        [[LSImageVibrateFilter alloc] init],
        [[LSImageVibrateFilter alloc] init],
    ];
    self.player = [LiveStreamPlayer instance];
    self.player.useHardDecoder = YES;
    self.player.delegate = self;
    self.player.playView = self.previewView;
    //    self.player.customFilter = self.playerFilterArray[0];
    self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatio;

    // TODO:初始化推送
    self.publisher = [LiveStreamPublisher instance:LiveStreamType_480x320];
    self.previewPublishView.fillMode = kGPUImageFillModePreserveAspectRatio;
    self.publisher.publishView = self.previewPublishView;
    LSImageVibrateFilter *vibrateFilter = [[LSImageVibrateFilter alloc] init];
    self.publisher.customFilter = vibrateFilter;

    // TODO:链接地址
    NSString *url = @"rtmp://198.211.27.71:4000/cdn_standard/max0";
    //        NSString *url = @"rtmp://52.196.96.7:4000/cdn_standard/max0";
    //    NSString *url = @"rtmp://18.194.23.38:4000/cdn_standard/max0";
    //    NSString *url = @"rtmp://172.25.32.133:4000/cdn_standard/max0";

    //    // Camshare
    //        NSString *url = @"rtmp://52.196.96.7:1935/mediaserver/camsahre";
    //        NSString *url = @"rtmp://172.25.32.133:1935/mediaserver/camsahre";

    self.textFieldAddress.text = [NSString stringWithFormat:@"%@", url, nil];
    self.textFieldPublishAddress.text = [NSString stringWithFormat:@"%@", url, nil];

    //    [self play:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    // 允许锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 播放相关
- (IBAction)playbackRate0_5x:(UIButton *)sender {
    [sender setSelected:YES];
    [self.button1x setSelected:NO];
    [self.button2x setSelected:NO];
    
    self.playbackRate = 0.5f;
    self.player.playbackRate = 0.5f;
}

- (IBAction)playbackRate1x:(UIButton *)sender {
    [sender setSelected:YES];
    [self.button0_5x setSelected:NO];
    [self.button2x setSelected:NO];
    
    self.playbackRate = 1.0f;
    self.player.playbackRate = 1.0f;
}

- (IBAction)playbackRate2x:(UIButton *)sender {
    [sender setSelected:YES];
    [self.button0_5x setSelected:NO];
    [self.button1x setSelected:NO];
    
    self.playbackRate = 2.0f;
    self.player.playbackRate = 2.0f;
}

- (IBAction)scale:(UIButton *)sender {
    self.player.playView.fillMode++;
    self.player.playView.fillMode %= (kGPUImageFillModePreserveAspectRatioAndFill + 1);
}

- (IBAction)mutePlay:(UIButton *)sender {
    self.player.mute = !self.player.mute;
}

- (IBAction)filterPlay:(UIButton *)sender {
    if (self.player) {
        if (!self.player.customFilter) {
            self.player.customFilter = self.playerFilterArray[0];
        } else {
            self.player.customFilter = nil;
        }
    }
}

- (void)sliderValueChanged:(UISlider *)sender {
    UISlider *slider = (UISlider *)sender;
    self.player.cacheMS = (int)roundf(slider.value);
    self.labelCacheMS.text = [NSString stringWithFormat:@"%ldms", self.player.cacheMS, nil];
}

- (IBAction)play:(UIButton *)sender {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *recordFilePath = @"";     //[NSString stringWithFormat:@"%@/%@.flv", recordDir, @"max"];
    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/play_%d.h264", recordDir, 0];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/play_%d.aac", recordDir, i];

    self.player.cacheMS = (int)roundf(self.sliderCacheMS.value);
    NSString *playUrl = [NSString stringWithFormat:@"%@", self.textFieldAddress.text];
    [self.player playUrl:playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
}

- (IBAction)playFile:(UIButton *)sender {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *inputDir = [NSString stringWithFormat:@"%@", cacheDir];
    StreamFileCollectionViewController *vc = [[StreamFileCollectionViewController alloc] init];
    vc.delegate = self;
    vc.inputDir = inputDir;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)stopPlay:(UIButton *)sender {
    self.fileItemArray = nil;
    [self.player stop];
}

#pragma mark - 播放器状态回调
- (void)playerOnInfoChange:(LiveStreamPlayer *_Nonnull)player videoDisplayWidth:(int)videoDisplayWidth vieoDisplayHeight:(int)vieoDisplayHeight {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelVideoSize.text = [NSString stringWithFormat:@"%dx%d", videoDisplayWidth, vieoDisplayHeight, nil];
    });
}

- (void)playerOnFastPlaybackError:(LiveStreamPlayer *_Nonnull)player {
    NSLog(@"StreamViewController::playerOnFastPlaybackError()");
}

- (void)playerOnStats:(LiveStreamPlayer *_Nonnull)player fps:(unsigned int)fps bitrate:(unsigned int)bitrate {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelFps.text = [NSString stringWithFormat:@"fps:%u  %ukbps", fps, bitrate, nil];
    });
}

- (void)playerOnFinish:(LiveStreamPlayer *_Nonnull)player {
    NSLog(@"StreamViewController::playerOnFinish(), self.fileItemIndex: %ld", self.fileItemIndex);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self playNextFileItem];
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

    [self changeNowPlayingInfo:self.fileItem];
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
    self.previewPublishView.hidden = NO;
    [self.publisher startPreview];
}

- (IBAction)stopCam:(id)sender {
    self.previewPublishView.hidden = YES;
    [self.publisher stopPreview];
}

#pragma mark - 浏览器
- (IBAction)pronAction:(UIButton *)sender {
    PronViewController *vc = [[PronViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 输入回调
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL result = YES;
    [textField resignFirstResponder];
    return result;
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    //    BOOL bFlag = NO;

    // Ensures that all pending layout operations have been completed
    [self.view layoutIfNeeded];

    if (height != 0) {
        // 弹出键盘
        self.controlBottom.constant = -(height + 20);
        
    } else {
        // 收起键盘
        self.controlBottom.constant = -20;
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
        [NSLayoutConstraint deactivateConstraints:@[ self.previewViewBottom ]];
        [NSLayoutConstraint activateConstraints:@[ self.previewViewRadio ]];
    }
}

#pragma mark - 手势
- (void)tapCloseKeyboardGesture:(UITapGestureRecognizer *)sender {
    [self.textFieldAddress resignFirstResponder];
    [self.textFieldPublishAddress resignFirstResponder];
}

- (void)tapGesture:(UITapGestureRecognizer *)sender {
    self.isScale = !self.isScale;
    [self changeOrientation];
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.player.playbackRate = 2.0;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        self.player.playbackRate = self.playbackRate;
    }
}

#pragma mark - 耳机事件
- (MPRemoteCommandHandlerStatus)pauseCommand {
    NSLog(@"StreamViewController::pauseCommand()");
    BOOL result = true; //[self pause];
    if (result) {
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusCommandFailed;
    }
}

- (MPRemoteCommandHandlerStatus)playCommand {
    NSLog(@"StreamViewController::playCommand()");
    BOOL result = true;
    if (result) {
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusCommandFailed;
    }
}

- (MPRemoteCommandHandlerStatus)nextTrackCommand {
    NSLog(@"StreamViewController::nextTrackCommand()");
    [self.player stop];
    BOOL result = true;
    if (result) {
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusCommandFailed;
    }
}

- (MPRemoteCommandHandlerStatus)previousTrackCommand {
    NSLog(@"StreamViewController::previousTrackCommand()");
    [self.player stop];
    BOOL result = true;
    if (result) {
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusCommandFailed;
    }
}

- (void)playNextFileItem {
    if (self.fileItemArray.count > 0) {
        self.fileItemIndex++;
        self.fileItemIndex %= self.fileItemArray.count;
        NSLog(@"StreamViewController::playNextFileItem(), self.fileItemIndex: %ld", self.fileItemIndex);

        self.fileItem = self.fileItemArray[self.fileItemIndex];
        [self changeNowPlayingInfo:self.fileItem];
        [self.player playFilePath:self.fileItem.filePath];
    }
}

- (void)changeNowPlayingInfo:(FileItem *)fileItem {
    NSMutableDictionary *songInfo = nil;
    if (fileItem) {
        songInfo = [NSMutableDictionary dictionary];
        UIImage *image = fileItem.image;
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size
                                                                      requestHandler:^UIImage *_Nonnull(CGSize size) {
                                                                          CGImageRef sourceImageRef = [image CGImage];
                                                                          CGRect rect = CGRectMake(image.size.width / 3, 0, image.size.width / 2.5, image.size.width / 2.5);
                                                                          CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
                                                                          UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                                                                          return newImage;
                                                                      }];
        [songInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
        [songInfo setObject:@"Title" forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:fileItem.fileName forKey:MPMediaItemPropertyArtist];
    }
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    [center setNowPlayingInfo:songInfo];
}

#pragma mark - 播放本地文件
- (void)didSelectFile:(FileItem *)fileItem {
    self.fileItemArray = nil;
    self.fileItem = fileItem;

    [self changeNowPlayingInfo:self.fileItem];

    self.player.cacheMS = 50;
    [self.player playFilePath:self.fileItem.filePath];
}

- (void)didSelectAllFile:(NSArray<FileItem *> *)fileItemArray {
    self.fileItemArray = fileItemArray;
    self.player.cacheMS = 50;
    
    if (self.fileItemArray.count > 0) {
        self.fileItemIndex = arc4random() % self.fileItemArray.count;
        [self playNextFileItem];
    }
}

- (void)downloadTaskPercent:(NSString *)percentString {
    if ( percentString.length > 0 ) {
        self.title = [NSString stringWithFormat:@"Stream Player %@", percentString];
    } else {
        self.title = @"Stream Player";
    }
}
@end
