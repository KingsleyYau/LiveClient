//
//  TestViewController.m
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "TestViewController.h"

#import "LiveStreamPlayer.h"
#import "LiveStreamPublisher.h"

#import "RequestManager.h"

@interface TestViewController ()

@property (strong) LiveStreamPlayer* palyer;
@property (strong) LiveStreamPublisher* publisher;

@property (nonatomic, strong) NSString* url;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation TestViewController
#pragma mark - 界面初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.previewView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    self.publisher = [LiveStreamPublisher instance];
    self.publisher.publishView = self.previewView;
    
    self.palyer = [LiveStreamPlayer instance];
    self.palyer.playView = self.previewView;
    
//    self.url = @"rtmp://103.235.46.39:80/live/livestream";
    self.url = @"rtmp://172.25.32.17/live/max";
//    self.url = @"rtmp://172.25.32.17:1936/aac/max";

    self.textFieldAddress.text = self.url;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent= NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 添加手势
    [self addSingleTap];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除手势
    [self removeSingleTap];
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
    [self stop:self];
    
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* recordH264FilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"publish.h264"];
    NSString* recordAACFilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"publish.aac"];
    
    BOOL bFlag = [self.publisher pushlishUrl:self.textFieldAddress.text recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
    if( bFlag ) {
        // 发布成功

    } else {
        // 发布失败
    }
}

- (IBAction)play:(id)sender {
    [self stop:self];
    
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* recordFilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.flv"];
    NSString* recordH264FilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.h264"];
    NSString* recordAACFilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.aac"];
    
    // 开始转菊花
    BOOL bFlag = [self.palyer playUrl:self.textFieldAddress.text recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
    if( bFlag ) {
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

#pragma mark - 单击屏幕
- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if( self.singleTap ) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
        self.singleTap.delegate = nil;
    }
}

- (void)singleTapAction {
    [self.textFieldAddress resignFirstResponder];
    
}

@end
