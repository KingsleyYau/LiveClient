//
//  QNTestViewController.m
//  livestream
//
//  Created by Max on 2017/9/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "QNTestViewController.h"
#import "KKNavigationController.h"
#import "MainViewController.h"

#import "LiveModule.h"

@interface QNTestViewController () <LiveModuleDelegate>
@property (nonatomic, strong) NSString* _Nullable token;
@end

@implementation QNTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadLoginParam];
    self.textField.text = self.token;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 注销
    [[LiveModule module] stop];
}

- (void)loginAction:(id)sender {
    // 关闭键盘输入
    [self.textField resignFirstResponder];
    
    if( self.textField.text.length > 0) {
        // 显示菊花
        self.activityView.hidden = NO;
        
        // 保存输入
        self.token = self.textField.text;
        [self saveLoginParam];
        
        // 开始登陆
        [[LiveModule module] stop];
        [[LiveModule module] setServiceManager:nil];
        [[LiveModule module] start:self.textField.text];
        [LiveModule module].delegate = self;
        
    } else {
        // 弹出提示
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"Input token cant be empty" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [vc addAction:ok];
        [self presentViewController:vc animated:NO completion:nil];
    }
}

- (IBAction)cancelAction:(id)sender {
    [[LiveModule module] stop];
    self.activityView.hidden = YES;
}

- (void)saveLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.token forKey:@"QNToken"];
    [userDefaults synchronize];
}

- (void)loadLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _token = [userDefaults stringForKey:@"QNToken"];
    if( !_token || _token.length == 0 ) {
        _token = MAX_TOKEN;
    }
}

- (void)moduleOnLogin:(LiveModule *)module {
    NSLog(@"QNTestViewController::moduleOnLogin()");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityView.hidden = YES;
        
        // 设置模块主界面
        UIViewController* vc = [LiveModule module].moduleViewController;
        [LiveModule module].fromVC = self;
        
        // 推进界面
        KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
        [nvc pushViewController:vc animated:YES gesture:NO];
    });
}

- (void)module:(LiveModule *)module onLogout:(BOOL)kick msg:(NSString *)msg {
    NSLog(@"QNTestViewController::onLogout( kick : %@, msg : %@ )", BOOL2YES(kick), msg);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if( msg.length > 0 ) {
            // 弹出提示
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [vc addAction:ok];
            [self presentViewController:vc animated:NO completion:nil];
        }
    });
}

@end
