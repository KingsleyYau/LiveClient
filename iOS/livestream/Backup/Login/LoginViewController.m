//
//  LoginViewController.m
//  dating
//
//  Created by Max on 16/2/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LoginViewController.h"

#import "LoginPhoneViewController.h"
#import "RegisterPhoneViewController.h"

#import "LoginManager.h"
#import "RequestManager.h"

#define keyboardDuration 0.56

@interface LoginViewController () <LoginManagerDelegate, UIActionSheetDelegate>

@end

@implementation LoginViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
//    self.backTitle = NSLocalizedString(@"Login", nil);

}

- (void)dealloc {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
}

- (void)setupContainView {
    [super setupContainView];

}

#pragma mark - 电话注册登录
- (void)showActionView {
    UIAlertController* phoneAlertView = [UIAlertController alertControllerWithTitle:nil
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = nil;
    // 取消
    action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [phoneAlertView addAction:action];
    
    // 登录
    action = [UIAlertAction actionWithTitle:@"Login with Phone" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginPhoneViewController* vc = [[LoginPhoneViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [phoneAlertView addAction:action];
    
    // 注册
    action = [UIAlertAction actionWithTitle:@"Sign up with Phone" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        RegisterPhoneViewController* vc = [[RegisterPhoneViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [phoneAlertView addAction:action];
    
    [self presentViewController:phoneAlertView animated:YES completion:nil];
}

- (IBAction)phoneLoginAction:(id)sender {
    [self showActionView];
}

@end
