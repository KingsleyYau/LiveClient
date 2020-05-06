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

#import "LSChatPrepaidView.h"
#import "LSPrePaidPickerView.h"
#import "LSPrePaidManager.h"

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

    [LSConfigManager manager];

//        config.item.httpSvrUrl = @"http://demo-live.charmdate.com:3007";
//        config.item.imSvrUrl = @"ws://demo-live.charmdate.com:3006";

//    config.item.httpSvrUrl = @"http://172.25.32.17:8617";
//    config.item.imSvrUrl = @"ws://172.25.32.17:8617";
//    config.item.httpSvrUrl = @"http://192.168.88.17:8817";
//    config.item.imSvrUrl = @"ws://192.168.88.17:8816";

//    [[LiveModule module] setServiceManager:nil];
    [LiveModule module].delegate = self;
    
//    [[LiveModule module] setConfigUrl:@"http://172.25.32.17:8817"];
//    [[LiveModule module] setConfigUrl:@"http://172.25.32.17:8617"];

    [[LiveModule module] setConfigUrl:@"https://demo.charmlive.com"];
    

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
    _token = MAX_TOKEN;
}

- (void)moduleOnLogin:(LiveModule *)module {
    NSLog(@"LSTestViewController::moduleOnLogin()");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityView.hidden = YES;

        // 设置模块主界面
        UIViewController *vc = [LiveModule module].mainVC;
 
        // 推进界面
        LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
        [nvc pushViewController:vc animated:NO gesture:NO];
        
        
//        LSNavigationController * nvc = [[LSNavigationController alloc]initWithRootViewController:vc];
//        ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController = nvc;

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
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    });
}



@end
