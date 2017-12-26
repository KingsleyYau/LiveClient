//
//  LSTestViewController.m
//  livestream
//
//  Created by Max on 2017/9/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSTestViewController.h"
#import "LSNavigationController.h"
#import "LSMainViewController.h"
#import "StreamTestViewController.h"
#import "LSLiveGuideViewController.h"

#import "LiveModule.h"
#import "LSConfigManager.h"

@interface LSTestViewController () <LiveModuleDelegate>
@property (nonatomic, strong) NSString *_Nullable token;
@property (nonatomic, strong) NSString *_Nullable isShowGuide;
@property (strong, nonatomic) UIWindow *window;
@end

@implementation LSTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self loadLoginParam];
    self.textField.text = self.token;

    LSConfigManager *config = [LSConfigManager manager];

    config.item = [[ConfigItemObject alloc] init];
    //    config.item.httpSvrUrl = @"http://demo-live.charmdate.com:3007";
    //    config.item.imSvrUrl = @"ws://demo-live.charmdate.com:3006";
    config.item.httpSvrUrl = @"http://172.25.32.17:8817";
    config.item.imSvrUrl = @"ws://172.25.32.17:8816";

    [[LiveModule module] setServiceManager:nil];
    [LiveModule module].delegate = self;
    [[LiveModule module] setConfigUrl:@"http://172.25.32.17:8817"];
//    [[LiveModule module] setConfigUrl:@"https://demo-live.charmdate.com:446"];
}

- (void)initialiseSubwidge {
    [super initialiseSubwidge];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 注销
    [[LiveModule module] stop];

    self.navigationController.navigationBar.alpha = 1.0;
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)loginAction:(id)sender {
    // 关闭键盘输入
    [self.textField resignFirstResponder];

    if (self.textField.text.length > 0) {
        // 显示菊花
        self.activityView.hidden = NO;

        // 保存输入
        self.token = self.textField.text;
        [self saveLoginParam];

        // 开始登陆
        [[LiveModule module] start:@"manId123" token:self.textField.text];

    } else {
        // 弹出提示
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"Input token cant be empty" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action){
                                                   }];
        [vc addAction:ok];
        [self presentViewController:vc animated:NO completion:nil];
    }
}

- (IBAction)cancelAction:(id)sender {
    [[LiveModule module] stop];
    self.activityView.hidden = YES;
}

- (IBAction)testAction:(id)sender {
    StreamTestViewController *vc = [[StreamTestViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)saveLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.token forKey:@"QNToken"];
    [userDefaults synchronize];
}

- (void)loadLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _token = [userDefaults stringForKey:@"QNToken"];
    if (!_token || _token.length == 0) {
        _token = MAX_TOKEN;
    }
}

- (void)moduleOnLogin:(LiveModule *)module {
    NSLog(@"LSTestViewController::moduleOnLogin()");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityView.hidden = YES;

        // 设置模块主界面
        UIViewController *vc = [LiveModule module].moduleVC;
        [LiveModule module].fromVC = self;

        // 推进界面
        LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
        [nvc pushViewController:vc animated:YES gesture:NO];

    });
}

- (void)moduleOnLogout:(LiveModule *)module kick:(BOOL)kick msg:(NSString *)msg {
    NSLog(@"LSTestViewController::moduleOnLogout( kick : %@, msg : %@ )", BOOL2YES(kick), msg);

    dispatch_async(dispatch_get_main_queue(), ^{
        if (msg.length > 0) {
            // 弹出提示
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action){

                                                       }];
            [vc addAction:ok];
            [self presentViewController:vc animated:NO completion:nil];
        }
    });
}

- (void)moduleOnNotification:(LiveModule *)module {
    NSLog(@"LSTestViewController::moduleOnNotification()");

    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        
        UIViewController *vc = [LiveModule module].notificationVC;
        CGRect frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20 + 5, self.view.frame.size.width, vc.view.frame.size.height);
        self.window = [[UIWindow alloc] initWithFrame:frame];
        self.window.windowLevel = UIWindowLevelAlert + 1;
        UIWindow *parentView = self.window;
        [self.window addSubview:vc.view];
        [self.window makeKeyAndVisible];
        
        [vc.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(parentView).offset(0);
            make.left.equalTo(parentView).offset(10);
            make.right.equalTo(parentView).offset(-10);
            make.height.equalTo(@(vc.view.frame.size.height));
        }];
        
        // Keep the original keyWindow and avoid some unpredictable problems
        [keyWindow makeKeyWindow];
    });
}

- (void)moduleOnNotificationDisappear:(LiveModule *)module {
    NSLog(@"LSTestViewController::moduleOnNotificationDisappear()");
    self.window = nil;
}

- (void)moduleOnAdViewController:(LiveModule *)module {
    NSLog(@"LSTestViewController::moduleOnAdViewController()");
    dispatch_async(dispatch_get_main_queue(), ^{
                       //        UIWindow *parentView = [UIApplication sharedApplication].keyWindow;
                       //        UIViewController *vc = [LiveModule module].adVc;
                       //        [parentView.rootViewController addChildViewController:vc];

                   });
}
@end
