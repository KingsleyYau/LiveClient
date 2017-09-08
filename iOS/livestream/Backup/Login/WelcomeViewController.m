//
//  WelcomeViewController.m
//  livestream
//
//  Created by Max on 2017/5/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "WelcomeViewController.h"

#import "LoginManager.h"

#define DELAY 3

@interface WelcomeViewController () <LoginManagerDelegate>

@property (nonatomic, strong) LoginManager* loginManager;

@end

@implementation WelcomeViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.loginManager = [LoginManager manager];
    [self.loginManager addDelegate:self];
}

- (void)dealloc {
    [self.loginManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 3秒后进入
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [self dismissViewControllerAnimated:YES completion:nil];
                   }
                   );

    // 自动登录
    [self.loginManager autoLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 登陆管理器回调 (LoginManagerDelegate)
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSInteger)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"WelcomeViewController::onLogin( [%@] )", success?@"Success":@"Fail");
        
        // 不管成功失败, 直接跳转
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)kick {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"WelcomeViewController::onLogout( [%@] )", kick?@"手动注销/被踢":@"Session超时");
    });
}

@end
