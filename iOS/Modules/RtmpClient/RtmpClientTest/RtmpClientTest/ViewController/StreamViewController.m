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
#import "StreamHlsViewController.h"
#import "SettingViewController.h"
#import "GoProViewController.h"

#import "LiveStreamSession.h"
#import "LiveStreamPlayer.h"
#import "LiveStreamPublisher.h"

#import "LSImageVibrateFilter.h"
#import "LivePictureCapture.h"

#import <MediaPlayer/MediaPlayer.h>

@import GoogleMobileAds;

@interface StreamViewController () <LiveStreamPlayerDelegate, LiveStreamPublisherDelegate, StreamFileCollectionViewControllerDelegate>
@property (strong) NSString *playUrl;
@property (strong) NSString *publishUrl;

@property (strong) NSArray<GPUImageFilter *> *playerFilterArray;
@property (strong) LiveStreamPlayer *player;

@property (strong) GPUImageFilter *publisherFilter;
@property (strong) LiveStreamPublisher *publisher;

@property (strong) UITapGestureRecognizer *singleTap;

@property (assign) BOOL isScale;
@property (assign) UIDeviceOrientation deviceOrientation;
@property (assign) BOOL isKeyboardShow;

@property (strong) UIImage *publishImage;
/**
 播放文件
 */
@property (strong) NSArray<FileItem *> *fileItemArray;
@property (strong) FileItem *fileItem;
@property (assign) NSInteger fileItemIndex;
/**
 播放速率
 */
@property (assign) float playbackRate;
/**
 播放器数组
 */
@property (strong) NSMutableArray<LiveStreamPlayer *> *playerArray;
@property (strong) LivePictureCapture *pictureCapture;
@end

@implementation StreamViewController
#pragma mark - 界面初始化
- (void)dealloc {
    NSLog(@"StreamViewController::dealloc()");

    [self.player removePlayView:self.previewView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Nav-SettingButton"] style:UIBarButtonItemStylePlain target:self action:@selector(settingAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Pro" style:UIBarButtonItemStylePlain target:self action:@selector(proAction:)];
    
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
        NSLog(@"Google Ad init finish status: %@", status.adapterStatusesByClassName);
    }];
    
    // 界面处理
    self.title = @"Super Live";
    if (@available(iOS 11.0, *)) {
        self.navigationItem.backButtonTitle = @"Back";
    }
    // 信息
    self.labelVideoSize.text = @"";
    self.labelFps.text = @"";
    [self.sliderBitrate addTarget:self action:@selector(sliderBitrateValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.sliderBitrate.continuous = NO;
    [self.sliderCacheMS addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.sliderCacheMS.continuous = NO;
    self.sliderCacheMS.value = 1000;
    self.labelCacheMS.text = [NSString stringWithFormat:@"%dms", (int)(self.sliderCacheMS.value), nil];
    self.isKeyboardShow = NO;
    
    [self.buttonPlayMute setImage:[UIImage imageNamed:@"MuteSmallButton"] forState:UIControlStateSelected];
    [self.buttonPublish setImage:[UIImage imageNamed:@"StopButton"] forState:UIControlStateSelected];
    [self.buttonPublishMute setImage:[UIImage imageNamed:@"MuteButton"] forState:UIControlStateSelected];
    [self.buttonPlay setImage:[UIImage imageNamed:@"StopButton"] forState:UIControlStateSelected];
    
    // TODO:拍照
    self.pictureCapture = [[LivePictureCapture alloc] init];
    // TODO:是否录制
    [self.buttonRecord setImage:[UIImage imageNamed:@"CheckButtonSelected"] forState:UIControlStateSelected];
    // TODO:旋转
    self.deviceOrientation = [UIDevice currentDevice].orientation;

    // TODO:手势 - 切换展现方式
    UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inputChangeAction:)];
    [self.imageViewInput addGestureRecognizer:tapImageView];
    self.imageViewInput.userInteractionEnabled = YES;
    // TODO:手势 - 单击收起键盘
    UITapGestureRecognizer *tapSingleGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSingleGuestureAction:)];
    tapSingleGuesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapSingleGuesture];
    // TODO:手势 - 双击全屏
    UITapGestureRecognizer *tapDoubleGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDoubleGestureAction:)];
    tapDoubleGuesture.numberOfTapsRequired = 2;
    [self.previewView addGestureRecognizer:tapDoubleGuesture];
    // 双击取消单击手势
    [tapSingleGuesture requireGestureRecognizerToFail:tapDoubleGuesture];
    // TODO:手势 - 长按2倍速度播放
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
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

//    self.sliderBitrate.maximumValue = self.publisher.bitrate;
    self.sliderBitrate.maximumValue = 2000 * 1000;
    self.sliderBitrate.value = self.publisher.bitrate;
    self.labelBitrate.text = [NSString stringWithFormat:@"%dkbps", (int)(self.sliderBitrate.value / 1000), nil];

    // TODO:链接地址
    NSDictionary<NSString *, NSString *> *urls = @{
        @"tn" : @"rtmp://81.71.134.206:4000/cdn_standard/max0", // Live
        @"ra" : @"rtmp://198.211.27.71:4000/cdn_standard/max0",
        @"demo1" : @"rtmp://52.196.96.7:4000/cdn_standard/max0",
        @"demo2" : @"rtmp://18.194.23.38:4000/cdn_standard/max0",
        @"local" : @"rtmp://172.25.32.133:4000/cdn_standard/max0",
        @"cam_demo" : @"rtmp://52.196.96.7:1935/mediaserver/camsahre?uid=MM32145&room=C771475|||N_PC4|||4 &site=4", // Camshare
        @"cam_local" : @"rtmp://172.25.32.133:1935/mediaserver/camsahre?uid=WW0&room=WW0|||N_PC4|||4|||v123456&site=4",
        @"cam_pd" : @"rtmp://52.203.25.17:1935/mediaserver/camsahre?uid=MM54321&room=C773186|||N_PC4|||4|||&site=4",
    };
    NSString *url = urls[@"tn"];;
    if (self.playUrl.length == 0) {
        self.textFieldAddress.text = [NSString stringWithFormat:@"%@", url, nil];
//        self.textFieldAddress.text = @"rtmp://81.71.134.206:4000/cdn_standard/max0";
        // 湖南卫视
        self.textFieldAddress.text = @"rtmp://58.200.131.2:1935/livetv/hunantv";
        // GoodTV
        //@"rtmp://mobliestream.c3tv.com:554/live/goodtv.sdp";
        // USA
        //@"rtmp://ns8.indexforce.com/home/mystream"
        //@"rtmp://media3.scctv.net/live/scctv_800"
    } else {
        self.textFieldAddress.text = self.playUrl;
    }
    if (self.publishUrl.length == 0) {
        self.textFieldPublishAddress.text = [NSString stringWithFormat:@"%@", url, nil];
        self.textFieldPublishAddress.text = @"";
    } else {
        self.textFieldPublishAddress.text = self.publishUrl;
    }

    //    [self playbackRate2x:nil];
    //    [self play:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.viewDidAppearEver) {
        // TODO:初始化播放
        self.playbackRate = 1.0;
        self.playerFilterArray = @[
            [[LSImageVibrateFilter alloc] init],
            [[LSImageVibrateFilter alloc] init],
        ];
        self.player = [LiveStreamPlayer instance];
        self.player.useHardDecoder = YES;
        self.player.delegate = self;
        //    self.player.customFilter = self.playerFilterArray[0];
        self.previewView.fillMode = kGPUImageFillModePreserveAspectRatio;
        [self.player addPlayView:self.previewView];

        // TODO:初始化推送
        self.publisher = [LiveStreamPublisher instance:LiveStreamType_480x640];
        self.publisher.delegate = self;
        self.previewPublishView.fillMode = kGPUImageFillModePreserveAspectRatio;
        self.publisher.publishView = self.previewPublishView;
        self.publisherFilter = [[LSImageVibrateFilter alloc] init];
    //    self.publisher.customFilter = self.publisherFilter;
    }
    
    if (AppShareDelegate().pornhubActive) {
        self.pornhubButtonWidth.constant = 30;
    } else {
        self.pornhubButtonWidth.constant = 0;
    }
    
    if (AppShareDelegate().tvActive) {
        self.tvButtonWidth.constant = 30;
    } else {
        self.tvButtonWidth.constant = 0;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 添加旋转事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 去除旋转事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

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

#pragma mark - 持久化
- (NSString *)playUrl {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *playUrl = [userDefaults objectForKey:@"playUrl"];
    return playUrl;
}

- (void)setPlayUrl:(NSString *)playUrl {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:playUrl forKey:@"playUrl"];
    [userDefaults synchronize];
}

- (NSString *)publishUrl {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *publishUrl = [userDefaults objectForKey:@"publishUrl"];
    return publishUrl;
}

- (void)setPublishUrl:(NSString *)publishUrl {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:publishUrl forKey:@"publishUrl"];
    [userDefaults synchronize];
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
    self.previewView.fillMode++;
    self.previewView.fillMode %= (kGPUImageFillModePreserveAspectRatioAndFill + 1);
}

- (IBAction)mutePlayAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.player.mute = !self.player.mute;
}

- (IBAction)filterPlayAction:(UIButton *)sender {
    if (self.player) {
        if (!self.player.customFilter) {
            self.player.customFilter = self.playerFilterArray[0];
        } else {
            self.player.customFilter = nil;
        }
    }
}

- (void)sliderBitrateValueChanged:(UISlider *)sender {
    UISlider *slider = (UISlider *)sender;
    int bitrate = (int)roundf(slider.value);
    self.labelBitrate.text = [NSString stringWithFormat:@"%dkbps", (int)(bitrate / 1000), nil];
    [self.publisher updateVideoParam:bitrate];
}

- (void)sliderValueChanged:(UISlider *)sender {
    UISlider *slider = (UISlider *)sender;
    self.player.cacheMS = (int)roundf(slider.value);
    self.labelCacheMS.text = [NSString stringWithFormat:@"%dms", (int)(self.player.cacheMS), nil];
}

- (IBAction)record:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)playAction:(UIButton *)sender {
    if (!sender.selected) {
        if (self.textFieldAddress.text > 0) {
//            [self tryAllAD:^(BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.playUrl = self.textFieldAddress.text;
                    [self play];
                    sender.selected = !sender.selected;
                });
//            }];
        } else {
            [self toast:@"请输入拉流地址"];
        }
    } else {
        [self stopPlay];
        sender.selected = !sender.selected;
    }
}

- (void)play {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];

    NSString *recordFilePath = @"";     //[NSString stringWithFormat:@"%@/%@.flv", recordDir, @"max"];
    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/play_%d.h264", recordDir, 0];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/play_%d.aac", recordDir, i];

    if (self.buttonRecord.selected) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

        NSDate *now = [NSDate date];
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        [fmt setDateFormat:@"yyyyMM_ddhhmmss"];
        NSString *dateString = [fmt stringFromDate:now];
        recordFilePath = [NSString stringWithFormat:@"%@/%@_%@.flv", recordDir, @"record", dateString];
    }

    self.player.cacheMS = (int)roundf(self.sliderCacheMS.value);
    NSString *playUrl = [NSString stringWithFormat:@"%@", self.textFieldAddress.text];
    [self.player playUrl:playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
    self.loadingView.hidden = NO;
}

- (IBAction)stopPlay {
    self.fileItemArray = nil;
    [self.player stop];
    self.loadingView.hidden = YES;
}

#pragma mark - 播放器状态回调
- (void)playerOnConnect:(LiveStreamPlayer *_Nonnull)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingView.hidden = YES;
    });
}

- (void)playerOnDisconnect:(LiveStreamPlayer *_Nonnull)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.player.filePath.length == 0 && self.player.url.length > 0) {
            self.loadingView.hidden = NO;
        }
    });
}

- (void)playerOnInfoChange:(LiveStreamPlayer *_Nonnull)player videoDisplayWidth:(int)videoDisplayWidth vieoDisplayHeight:(int)vieoDisplayHeight {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelVideoSize.text = [NSString stringWithFormat:@"%dx%d", videoDisplayWidth, vieoDisplayHeight, nil];
    });
}

- (void)playerOnError:(LiveStreamPlayer *_Nonnull)player code:(NSString *)code description:(NSString *)description {
    NSLog(@"StreamViewController::playerOnError(), code: %@, description: %@", code, description);
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
- (IBAction)publishAction:(UIButton *)sender {
    if (!sender.selected) {
        if (self.textFieldPublishAddress.text.length > 0) {
//            [self tryAllAD:^(BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.publishUrl = self.textFieldPublishAddress.text;
                    [self publish];
                    sender.selected = !sender.selected;
                });
//            }];
        } else {
            [self toast:@"请输入推流地址"];
        }
    } else {
        [self stopPush];
        sender.selected = !sender.selected;
    }
}

- (void)publish {
    self.previewPublishView.hidden = NO;

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];

//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/%@", recordDir, @"publish.h264"];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/%@", recordDir, @"publish.aac"];

    [self.publisher publishUrl:self.textFieldPublishAddress.text recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
}

- (IBAction)stopPush {
    [self.publisher stop];
    self.previewPublishView.hidden = YES;

    [self changeNowPlayingInfo:self.fileItem];
}

- (IBAction)beauty:(id)sender {
    self.publisher.beauty = !self.publisher.beauty;
}

- (IBAction)mutePublishAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.publisher.mute = !self.publisher.mute;
}

- (IBAction)roateAction:(UIButton *)sender {
    [self.pictureCapture rotateCamera];
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

- (IBAction)filterPublishAction:(id)sender {
    if (self.publisher) {
        if (!self.publisher.customFilter) {
            self.publisher.customFilter = self.publisherFilter;
        } else {
            self.publisher.customFilter = nil;
        }
    }
}
- (IBAction)inputChangeAction:(id)sender {
    if (self.publisher) {
        UIImage *image = nil;
        if (!self.publisher.image) {
            image = self.publishImage ? self.publishImage : [UIImage imageNamed:@"P0"];
            self.publisher.image = image;
        } else {
            image = [UIImage imageNamed:@"C"];
            self.publisher.image = nil;
        }
        self.imageViewInput.image = image;
    }
}

#pragma mark - 推流器状态回调
- (void)publisherOnConnect:(LiveStreamPublisher *)publisher {
    NSLog(@"StreamViewController::publisherOnConnect()");
}

- (void)publisherOnDisconnect:(LiveStreamPublisher *)publisher {
    NSLog(@"StreamViewController::publisherOnDisconnect()");
}

- (void)publisherOnError:(LiveStreamPublisher *)publisher code:(NSString *_Nullable)code description:(NSString *_Nullable)description {
    NSLog(@"StreamViewController::publisherOnError(), code: %@, description: %@", code, description);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self toast:description];
    });
}

#pragma mark - 文件
- (IBAction)fileAction:(UIButton *)sender {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *inputDir = [NSString stringWithFormat:@"%@", cacheDir];
    StreamFileCollectionViewController *vc = [[StreamFileCollectionViewController alloc] init];
    vc.delegate = self;
    vc.inputDir = inputDir;
    [self.navigationController pushViewController:vc animated:YES];
    self.loadingView.hidden = YES;
}

#pragma mark - 浏览器
- (IBAction)browserAction:(UIButton *)sender {
    self.buttonPublish.selected = NO;
    [self stopPush];
    self.buttonPlay.selected = NO;
    [self stopPlay];
    
    PronViewController *vc = [[PronViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TV
- (IBAction)tvAction:(UIButton *)sender {
    self.buttonPublish.selected = NO;
    [self stopPush];
    self.buttonPlay.selected = NO;
    [self stopPlay];
    
    StreamHlsViewController *vc = [[StreamHlsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NFC
- (IBAction)nfcAction:(UIButton *)sender {
}

#pragma mark - 设置
- (IBAction)settingAction:(UIButton *)sender {
    SettingViewController *vc = [[SettingViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - 订阅
- (IBAction)proAction:(UIButton *)sender {
    GoProViewController *vc = [[GoProViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    if (@available(iOS 13.0, *)) {
        nvc.modalInPresentation = YES;
        nvc.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - 拍照
- (IBAction)captureAction:(UIButton *)sender {
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    switch (self.deviceOrientation) {
        case UIDeviceOrientationPortrait: {
            orientation = UIInterfaceOrientationPortrait;
        } break;
        case UIDeviceOrientationPortraitUpsideDown: {
            orientation = UIInterfaceOrientationPortraitUpsideDown;
        } break;
        case UIDeviceOrientationLandscapeLeft: {
            orientation = UIInterfaceOrientationLandscapeRight;
        } break;
        case UIDeviceOrientationLandscapeRight: {
            orientation = UIInterfaceOrientationLandscapeLeft;
        } break;
    }

    [self.pictureCapture capture:orientation
                   captureFinish:^(NSString *_Nonnull filePath) {
                       [self toast:@"OK"];
                   }];
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
        self.previewViewGroup.hidden = YES;
    } else {
        // 收起键盘
        self.controlBottom.constant = -20;
        self.previewViewGroup.hidden = NO;
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
    self.isKeyboardShow = YES;
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.isKeyboardShow = NO;
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
            self.previewView.fillMode = self.isScale ? kGPUImageFillModePreserveAspectRatioAndFill : kGPUImageFillModePreserveAspectRatio;
            [self hideControll:self.isScale];
        } break;
        case UIDeviceOrientationLandscapeLeft:
            // Device oriented horizontally, home button on the right
            NSLog(@"StreamViewController::deviceOrientationChange( [LandscapeLeft] )");
        case UIDeviceOrientationLandscapeRight: {
            // Device oriented horizontally, home button on the left
            NSLog(@"StreamViewController::deviceOrientationChange( [LandscapeRight] )");
            self.previewView.fillMode = kGPUImageFillModePreserveAspectRatio;
            [self hideControll:YES];
        } break;
        default:
            break;
    }
}

- (void)hideControll:(BOOL)hidden {
    if ([self.navigationController.topViewController isEqual:self]) {
        [self.navigationController setNavigationBarHidden:hidden];
    }
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
- (void)tapSingleGuestureAction:(UITapGestureRecognizer *)sender {
    if (self.isKeyboardShow) {
        [self.textFieldAddress resignFirstResponder];
        [self.textFieldPublishAddress resignFirstResponder];
    } else {
        [self captureAction:nil];
    }
}

- (void)tapDoubleGestureAction:(UITapGestureRecognizer *)sender {
    self.isScale = !self.isScale;
    [self changeOrientation];
}

- (void)longPressGestureAction:(UILongPressGestureRecognizer *)sender {
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
- (void)didPlayFile:(FileItem *)fileItem {
    self.fileItemArray = nil;
    self.fileItem = fileItem;

    [self changeNowPlayingInfo:self.fileItem];

    self.player.cacheMS = 50;
    [self.player playFilePath:self.fileItem.filePath];
    self.loadingView.hidden = YES;
}

- (void)didPlayAllFile:(NSArray<FileItem *> *)fileItemArray {
    self.fileItemArray = fileItemArray;
    self.player.cacheMS = 50;

    if (self.fileItemArray.count > 0) {
        self.fileItemIndex = arc4random() % self.fileItemArray.count;
        [self playNextFileItem];
    }
    self.loadingView.hidden = YES;
}

#pragma mark - 推送本地文件
- (void)didPublishFile:(FileItem *)fileItem {
    self.previewPublishView.hidden = NO;
    if (fileItem.isVideo) {
        self.publisher.image = nil;
        self.imageViewInput.image = [UIImage imageNamed:@"C"];
        [self.publisher publishUrl:self.textFieldPublishAddress.text withVideo:fileItem.filePath];
    } else {
        self.publishImage = fileItem.image;
        self.publisher.image = self.publishImage;
        self.imageViewInput.image = self.publisher.image;
        [self publishAction:nil];
    }
}
@end
