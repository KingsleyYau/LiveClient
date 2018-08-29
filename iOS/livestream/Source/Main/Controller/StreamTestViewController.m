//
//  StreamTestViewController.m
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "StreamTestViewController.h"

#import "LiveStreamSession.h"
#import "LiveStreamPlayer.h"
#import "LiveStreamPublisher.h"

#import "LSRequestManager.h"
#import "LSFileCacheManager.h"

@interface StreamTestViewController ()

@property (strong) NSArray<LiveStreamPlayer *> *playerArray;
@property (strong) NSArray<GPUImageView *> *playerPreviewArray;
@property (strong) NSArray<NSString *> *playerUrlArray;
@property (assign) NSUInteger playerCount;

@property (strong) LiveStreamPublisher *publisher;
@property (strong) NSString *publishUrl;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation StreamTestViewController
#pragma mark - 界面初始化
- (void)dealloc {
    NSLog(@"StreamTestViewController::dealloc()");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [LSRequestManager setLogEnable:YES];
    [LSRequestManager setLogDirectory:[[LSFileCacheManager manager] requestLogPath]];

    // 初始化播放
    self.playerPreviewArray = @[
        self.previewView0,
        self.previewView1,
        self.previewView2
    ];
    self.playerUrlArray = @[
        @"rtmp://172.25.32.17:19351/live/max0",
        @"rtmp://172.25.32.17:19351/live/max1",
        @"rtmp://172.25.32.17:19351/live/max2"
    ];
    NSMutableArray *playerArray = [NSMutableArray array];
    for (int i = 0; i < self.playerPreviewArray.count; i++) {
        LiveStreamPlayer *player = [LiveStreamPlayer instance];
        player.playView = self.playerPreviewArray[i];
        player.playView.fillMode = kGPUImageFillModePreserveAspectRatio;
        [playerArray addObject:player];
    }
    self.playerArray = playerArray;
    [self play:nil];

    // 初始化推送
    self.publishUrl = @"rtmp://172.25.32.17:19351/live/maxi";
    self.publisher = [LiveStreamPublisher instance:LiveStreamType_Audience_Mutiple];
    self.previewPublishView.fillMode = kGPUImageFillModePreserveAspectRatio;
    self.publisher.publishView = self.previewPublishView;

    self.textFieldAddress.text = [NSString stringWithFormat:@"%@", self.playerUrlArray[0], nil];
    self.textFieldPublishAddress.text = [NSString stringWithFormat:@"%@", self.publishUrl, nil];

    // 计算StatusBar高度
    if ([LSDevice iPhoneXStyle]) {
        self.previewTop.constant = 44;
    } else {
        self.previewTop.constant = 20;
    }

    [[LiveStreamSession session] checkAudio:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"请开启麦克风权限" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *_Nonnull action){

                                                                 }];
                [alertVC addAction:actionOK];
                [self presentViewController:alertVC animated:NO completion:nil];
            }
        });
    }];

    [[LiveStreamSession session] checkVideo:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"请开启摄像头权限" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *_Nonnull action){

                                                                 }];
                [alertVC addAction:actionOK];
                [self presentViewController:alertVC animated:NO completion:nil];
            }
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.alpha = 0.7;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
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

    // 停止流
    [self stopPlay:nil];
    [self stopPush:nil];

    // 允许锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)initCustomParam {
    [super initCustomParam];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    //    self.title = @"Self";
    self.tabBarItem.image = [UIImage imageNamed:@"TabBarSelf"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publish:(id)sender {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/%@", recordDir, @"publish.h264"];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/%@", recordDir, @"publish.aac"];

    BOOL bFlag = NO;

    //    bFlag = [[LiveStreamSession session] canCapture];
    //    if (bFlag) {
    //
    //    } else {
    //        // 无权限
    //        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"请开启摄像头和录音权限" preferredStyle:UIAlertControllerStyleAlert];
    //        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
    //                                                           style:UIAlertActionStyleDefault
    //                                                         handler:^(UIAlertAction *_Nonnull action){
    //
    //                                                         }];
    //        [alertVC addAction:actionOK];
    //        [self presentViewController:alertVC animated:NO completion:nil];
    //    }

    //    if (bFlag) {
    bFlag = [self.publisher pushlishUrl:self.textFieldPublishAddress.text recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
    //    }

    if (bFlag) {
        // 发布成功

    } else {
        // 发布失败
    }
}

- (IBAction)play:(id)sender {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    for (int i = 0; i < self.playerArray.count; i++) {
        // 开始转菊花
//        NSString *dateString = [LSDateFormatter toStringYMDHMSWithUnderLine:[NSDate date]];
        NSString *recordFilePath = @""; //[NSString stringWithFormat:@"%@/%@.flv", recordDir, dateString];
        NSString *recordH264FilePath = [NSString stringWithFormat:@"%@/play_%d.h264", recordDir, i];
        NSString *recordAACFilePath = @""; //[NSString stringWithFormat:@"%@/play_%d.aac", recordDir, i];

        BOOL bFlag = [self.playerArray[i] playUrl:self.playerUrlArray[i] recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
        if (bFlag) {
            // 播放成功
        } else {
            // 播放失败
        }
    }
}

- (IBAction)stopPlay:(id)sender {
    for (int i = 0; i < self.playerArray.count; i++) {
        [self.playerArray[i] stop];
    }
}

- (IBAction)stopPush:(id)sender {
    [self.publisher stop];
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

#pragma mark - 静音
- (IBAction)mute0:(id)sender {
    self.playerArray[0].mute = !self.playerArray[0].mute;
}

- (IBAction)mute1:(id)sender {
    self.playerArray[1].mute = !self.playerArray[1].mute;
}

- (IBAction)mute2:(id)sender {
    self.playerArray[2].mute = !self.playerArray[2].mute;
}

#pragma mark - 单击屏幕
- (void)addSingleTap {
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
        self.singleTap.delegate = nil;
    }
}

- (void)singleTapAction {
    [self.textFieldAddress resignFirstResponder];
    [self.textFieldPublishAddress resignFirstResponder];

    self.navigationController.navigationBar.alpha = 0.7;
    self.navigationController.navigationBar.hidden = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1
            animations:^{
                self.navigationController.navigationBar.alpha = 0;
            }
            completion:^(BOOL finished) {
                self.navigationController.navigationBar.hidden = YES;
            }];
    });
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

@end
