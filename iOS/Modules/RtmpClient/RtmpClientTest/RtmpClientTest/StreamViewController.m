//
//  StreamViewController.m
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "StreamViewController.h"
#import "PlayViewController.h"

#import "LiveStreamSession.h"
#import "LiveStreamPlayer.h"
#import "LiveStreamPublisher.h"

#import "LSImageVibrateFilter.h"

@interface StreamViewController ()

@property (strong) NSArray<LiveStreamPlayer *> *playerArray;
@property (strong) NSArray<GPUImageView *> *playerPreviewArray;
@property (strong) NSArray<NSString *> *playerUrlArray;
@property (strong) NSArray<GPUImageFilter *> *playerFilterArray;
@property (assign) NSUInteger playerCount;

@property (strong) LiveStreamPublisher *publisher;
@property (strong) NSString *publishUrl;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation StreamViewController
#pragma mark - 界面初始化
- (void)dealloc {
    NSLog(@"StreamViewController::dealloc()");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // 初始化播放
    self.playerPreviewArray = @[
        self.previewView0,
        self.previewView1,
        self.previewView2
    ];
    NSMutableArray *playerArray = [NSMutableArray array];
    self.playerFilterArray = @[
        [[LSImageVibrateFilter alloc] init],
        [[LSImageVibrateFilter alloc] init],
        [[LSImageVibrateFilter alloc] init]
    ];
    for (int i = 0; i < self.playerPreviewArray.count; i++) {
        LiveStreamPlayer *player = [LiveStreamPlayer instance];
        player.playView = self.playerPreviewArray[i];
        player.customFilter = self.playerFilterArray[i];

        player.playView.fillMode = kGPUImageFillModePreserveAspectRatio;
        [playerArray addObject:player];
    }
    self.playerArray = playerArray;

    // 初始化推送
    self.publishUrl = @"rtmp://172.25.32.17:19351/live/maxi";
    self.publisher = [LiveStreamPublisher instance:LiveStreamType_Audience_Mutiple];
    self.previewPublishView.fillMode = kGPUImageFillModePreserveAspectRatio;
    self.publisher.publishView = self.previewPublishView;
    LSImageVibrateFilter *vibrateFilter = [[LSImageVibrateFilter alloc] init];
    self.publisher.customFilter = vibrateFilter;

//    self.textFieldAddress.text = [NSString stringWithFormat:@"%@", @"rtmp://172.25.32.17:19351/live/max", nil];
//    self.textFieldAddress.text = [NSString stringWithFormat:@"%@", @"rtmp://52.196.96.7:4000/cdn_standard/max", nil];
    self.textFieldAddress.text = [NSString stringWithFormat:@"%@", @"rtmp://172.25.32.133:4000/cdn_standard/max", nil];
    self.textFieldPublishAddress.text = [NSString stringWithFormat:@"%@", self.publishUrl, nil];

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

    // 停止流
    [self stopPlay:nil];
    [self stopPush:nil];

    // 允许锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
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

    [self.publisher pushlishUrl:self.textFieldPublishAddress.text recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
}

- (IBAction)play:(id)sender {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    for (int i = 0; i < self.playerArray.count; i++) {
        NSString *recordFilePath = @"";     //[NSString stringWithFormat:@"%@/%@.flv", recordDir, dateString];
        NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/play_%d.h264", recordDir, i];
        NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/play_%d.aac", recordDir, i];

        NSString *playUrl = [NSString stringWithFormat:@"%@%d", self.textFieldAddress.text, i];
        [self.playerArray[i] playUrl:playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
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

- (IBAction)newPage:(id)sender {
    PlayViewController *vc = [[PlayViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - 播放
- (IBAction)play0:(id)sender {
    int i = 0;

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *dateString = [self toStringYMDHMSWithUnderLine:[NSDate date]];
    NSString *recordFilePath = @"";     //[NSString stringWithFormat:@"%@/record%d_%@.flv", recordDir, i, dateString];
    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/play_%d.h264", recordDir, i];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/play_%d.aac", recordDir, i];

    NSString *playUrl = [NSString stringWithFormat:@"%@%d", self.textFieldAddress.text, i];
    [self.playerArray[0] playUrl:playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
}

- (IBAction)play1:(id)sender {
    int i = 1;

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *dateString = [self toStringYMDHMSWithUnderLine:[NSDate date]];
    NSString *recordFilePath = @"";     //[NSString stringWithFormat:@"%@/record%d_%@.flv", recordDir, i, dateString];
    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/play_%d.h264", recordDir, i];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/play_%d.aac", recordDir, i];

    NSString *playUrl = [NSString stringWithFormat:@"%@%d", self.textFieldAddress.text, i];
    [self.playerArray[i] playUrl:playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
}

- (IBAction)play2:(id)sender {
    int i = 2;

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *dateString = [self toStringYMDHMSWithUnderLine:[NSDate date]];
    NSString *recordFilePath = @"";     //[NSString stringWithFormat:@"%@/record%d_%@.flv", recordDir, i, dateString];
    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/play_%d.h264", recordDir, i];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/play_%d.aac", recordDir, i];

    NSString *playUrl = [NSString stringWithFormat:@"%@%d", self.textFieldAddress.text, i];
    [self.playerArray[i] playUrl:playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
}

- (IBAction)stop0:(id)sender {
    int i = 0;
    
    if( self.playerArray[i] ) {
        if( !self.playerArray[i].customFilter ) {
            self.playerArray[i].customFilter = self.playerFilterArray[i];
        } else {
            self.playerArray[i].customFilter = nil;
        }
    }
}

- (IBAction)stop1:(id)sender {
    int i = 1;
    if( self.playerArray[i] ) {
        if( !self.playerArray[i].customFilter ) {
            self.playerArray[i].customFilter = self.playerFilterArray[i];
        } else {
            self.playerArray[i].customFilter = nil;
        }
    }
}

- (IBAction)stop2:(id)sender {
    int i = 2;
    if( self.playerArray[i] ) {
        if( !self.playerArray[i].customFilter ) {
            self.playerArray[i].customFilter = self.playerFilterArray[i];
        } else {
            self.playerArray[i].customFilter = nil;
        }
    }
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

- (NSString *)toStringYMDHMSWithUnderLine:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    NSInteger second = [comoponents second];

    return [NSString stringWithFormat:@"%ld_%ld_%ld_%ld_%.2ld_%.2ld", (long)year, (long)month, (long)day, (long)hour, (long)minute, (long)second];
}

@end
