//
//  DoorViewController.m
//  livestream
//
//  Created by Max on 2019/6/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DoorViewController.h"
#import "LSNavigationController.h"
#import "DoorTableViewController.h"

#import "LSConfigManager.h"
#import "LSLoginManager.h"

@interface DoorViewController () <LoginManagerDelegate>
@property (strong, nonatomic) UIWindow *window;

@end

@implementation DoorViewController
- (void)initCustomParam {
    [super initCustomParam];
}

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadLoginParam];

    [LSRequestManager setLogEnable:NO];
    [[LSRequestManager manager] setConfigWebSite:@"https://www.charmlive.com"];
    [[LSLoginManager manager] addDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[LSLoginManager manager] logout:LogoutTypeActive];
    [self loginAction:nil];
}

- (void)loginAction:(id)sender {
    // 关闭键盘输入
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.checkcodeTextField resignFirstResponder];
    
    if (self.usernameTextField.text.length > 0 && self.passwordTextField.text.length > 0) {
        // 显示菊花
        self.activityView.hidden = NO;

        // 保存输入
        [self saveLoginParam];

        // 开始登陆
        [[LSLoginManager manager] login:self.usernameTextField.text password:self.passwordTextField.text checkcode:self.checkcodeTextField.text userId:nil token:nil];

    } else {
        // 弹出提示
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"Input token cant be empty" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                   }];
        [vc addAction:ok];
        [self presentViewController:vc animated:NO completion:nil];
    }
}

- (IBAction)cancelAction:(id)sender {
}

- (void)saveLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.usernameTextField.text forKey:@"Username"];
    [userDefaults setObject:self.passwordTextField.text forKey:@"Password"];
    [userDefaults synchronize];
}

- (void)loadLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults stringForKey:@"Username"];
    self.usernameTextField.text = username;

    NSString *password = [userDefaults stringForKey:@"Password"];
    self.passwordTextField.text = password;
}

- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    NSLog(@"DoorViewController::onLogin( [Http登录通知], success : %@, msg : %@ )", BOOL2SUCCESS(success), errmsg);

    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityView.hidden = YES;

        if (success) {
            [self saveLoginParam];
            // 设置模块主界面
            DoorTableViewController *vc = [[DoorTableViewController alloc] initWithNibName:nil bundle:nil];

            // 推进界面
            LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
            [nvc pushViewController:vc animated:NO gesture:NO];
        } else {
            [[LSRequestManager manager] getValidateCode:NO
                                          finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, const char *data, int len) {
                                              UIImage *image = nil;
                                              if (success) {
                                                  if (data && len > 0) {
                                                      image = [UIImage imageWithData:[NSData dataWithBytes:data length:len]];
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          self.checkcodeImageView.image = image;
                                                      });
                                                  }
                                              }
                                          }];
        }
    });
}

- (void)manager:(LSLoginManager *)manager onLogout:(LogoutType)type msg:(NSString *)msg {
    NSLog(@"DoorViewController::onLogout( [Http注销通知], type : %d, msg : %@ )", type, msg);
}

@end
