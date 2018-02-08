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

@property (strong) LiveStreamPlayer *palyer;
@property (strong) LiveStreamPublisher *publisher;

@property (nonatomic, strong) NSString *url;

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
    
    self.previewView.fillMode = kGPUImageFillModePreserveAspectRatio;

    self.publisher = [LiveStreamPublisher instance];
    [self.publisher initCapture];
    self.publisher.publishView = self.previewPublishView;

    self.palyer = [LiveStreamPlayer instance];
    self.palyer.playView = self.previewView;

//    self.url = @"rtmp://52.196.96.7:7474/test_flash/max";
    self.url = @"rtmp://172.25.32.230:1935/live/max";
    
    self.textFieldAddress.text = [NSString stringWithFormat:@"%@", self.url, nil];
    self.textFieldPublishAddress.text = [NSString stringWithFormat:@"%@_i", self.url, nil];
    
//    self.textFieldAddress.text = @"rtmp://172.25.32.133:7474/test_flash/test";
//    self.textFieldAddress.text = @"rtmp://52.196.96.7:7474/test_flash/test";
//    self.textFieldAddress.text = @"rtmp://52.196.96.7:4000/cdn_standard/fansi_CM42137154_6507";
//    self.textFieldPublishAddress.text = @"rtmp://172.25.32.133:7474/test_flash/test";
//    self.textFieldPublishAddress.text = @"rtmp://52.196.96.7:7474/test_flash/test";
//    self.textFieldPublishAddress.text = @"rtmp://52.196.96.7:4000/cdn_standard/fansi_CM42137154_6507";
    
    // 计算StatusBar高度
    if ([LSDevice iPhoneXStyle]) {
        self.previewTop.constant = 44;
    } else {
        self.previewTop.constant = 20;
    }
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
    [self stop:nil];
    
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

    bFlag = [[LiveStreamSession session] canCapture];
    if (bFlag) {

    } else {
        // 无权限
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"请开启摄像头和录音权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action){

                                                         }];
        [alertVC addAction:actionOK];
        [self presentViewController:alertVC animated:NO completion:nil];
    }

    if (bFlag) {
        bFlag = [self.publisher pushlishUrl:self.textFieldPublishAddress.text recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
    }

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

//    NSString *dateString = [LSDateFormatter toStringYMDHMSWithUnderLine:[NSDate date]];
//    NSString *recordFilePath = [NSString stringWithFormat:@"%@/%@.flv", recordDir, dateString];
    NSString *recordFilePath = [NSString stringWithFormat:@"%@/%@", recordDir, @"play.flv"];
    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/%@", recordDir, @"play.h264"];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/%@", recordDir, @"play.aac"];

    // 开始转菊花
    BOOL bFlag = [self.palyer playUrl:self.textFieldAddress.text recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
    if (bFlag) {
        // 播放成功

    } else {
        // 播放失败
    }
}

- (IBAction)stop:(id)sender {
    [self.palyer stop];
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
    BOOL bFlag = NO;
    
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
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // 动画收起键盘
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

@end
