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

@property (strong) RequestManager* requestManager;

@property (nonatomic) NSInteger request;
           
@end

@implementation TestViewController
#pragma mark - 界面初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.publisher = [LiveStreamPublisher instance];
    self.publisher.publishView = self.publishView;
    
    self.palyer = [LiveStreamPlayer instance];
    self.palyer.playView = self.publishView;
    
//    self.url = @"rtmp://103.235.46.39:80/live/livestream";
//    self.url = @"rtmp://172.25.32.17/live/max";
    self.url = @"rtmp://172.25.32.17:1936/aac/max";

    self.requestManager = [RequestManager manager];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent= NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

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
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* recordH264FilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"publish.h264"];
    NSString* recordAACFilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"publish.aac"];
    
    // 开始转菊花
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bFlag = [self.publisher pushlishUrl:self.url recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 停止菊花
            if( bFlag ) {
                // 发布成功

            } else {
                // 发布失败
            }
        });
    });
}

- (IBAction)play:(id)sender {
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* recordFilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.flv"];
    NSString* recordH264FilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.h264"];
    NSString* recordAACFilePath = [NSString stringWithFormat:@"%@/%@", cacheDir, @"play.aac"];
    
    // 开始转菊花
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bFlag = [self.palyer playUrl:self.url recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 停止菊花
            if( bFlag ) {
                // 播放成功

            } else {
                // 播放失败
            }
        });
    });
}

- (IBAction)stop:(id)sender {
    [self.requestManager stopRequest:self.request];
    
    [self.palyer stop];
    [self.publisher stop];
    
}

- (IBAction)beauty:(id)sender {
    self.publisher.beauty = !self.publisher.beauty;
    
//    self.request = [self.requestManager login:@"userName" password:@"123456" checkcode:@"1234"
//                                finishHandler:^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, LoginItemObject * _Nonnull item) {
//
//    }];
    
    NSLog(@"TestViewController( request : %lld )", (long long)self.request);
}
@end
