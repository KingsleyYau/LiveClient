//
//  LSLoginViewController.m
//  livestream_anchor
//
//  Created by Calvin on 2018/2/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSLoginViewController.h"
#import "LSConfigManager.h"
#import "LSLoginManager.h"
#import "LSMainViewController.h"
#import "LiveModule.h"
#import "DialogTip.h"
#import "StreamTestViewController.h"

@interface LSLoginViewController ()<LoginManagerDelegate,UITextFieldDelegate>

@property (nonatomic, copy) NSString * token;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pawTextfield;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@property (nonatomic, strong) LSLoginManager * loginManager;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *codeLoading;
@end

@implementation LSLoginViewController

- (void)dealloc
{
    [self.loginManager removeDelegate:self];
    
    [[DialogTip dialogTip] stopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.loginBtn.layer.cornerRadius = self.loginBtn.frame.size.height/2;
    self.loginBtn.layer.masksToBounds = YES;
    
    self.loginManager = [LSLoginManager manager];
    [self.loginManager addDelegate:self];
    
    self.emailTextField.text = self.loginManager.email;
    self.pawTextfield.text = self.loginManager.password;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.codeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.pawTextfield.delegate = self;
    self.codeTextField.delegate = self;
    
    NSString * email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    if (email.length > 0) {
        self.emailTextField.text = email;
    }
    
    __weak typeof(self) weakSelf = self;
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]addObserverForName:UIApplicationDidEnterBackgroundNotification  object:app queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf.view endEditing:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];

    [self registerNotification];
    [self getConfig];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     
}

#pragma mark -  添加对键盘的监听
- (void)registerNotification {
    //键盘即将显示时的监听
    [[NSNotificationCenter defaultCenter]addObserver:self
                                           selector:@selector(keyboardWillApprear:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    //键盘即将隐藏时的监听
    [[NSNotificationCenter defaultCenter]addObserver:self
                                           selector:@selector(keyboardWillDisAppear:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

#pragma mark 获取同步配置和验证码
- (void)getConfig
{
    [[LSConfigManager manager] clean];
    [[LSConfigManager manager] synConfig:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBConfigItemObject * _Nullable item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                
                LSConfigManager *config = [LSConfigManager manager];
                config.item = item;
                
                [[LSAnchorRequestManager manager] setWebSite:item.httpSvrUrl];
                [[LiveModule module] setConfigUrl:item.httpSvrUrl];
               
                [self getCheckCode];
               
                NSInteger buildID = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue];
                //判断是否有强制更新
                if (item.minAavilableVer > buildID) {
                    [self showUpdateAlertView];
                }
            }
            else
            {
                self.codeLoading.hidden = YES;
                self.reloadBtn.hidden = NO;
                [self.reloadBtn setBackgroundImage:[UIImage imageNamed:@"Reload"] forState:UIControlStateNormal];
            }
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 登录按钮点击方法
- (IBAction)loginBtnDid:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if (self.emailTextField.text.length == 0) {
        [[DialogTip dialogTip]showDialogTip:self.view tipText:NSLocalizedString(@"ID_MSG", nil)];
        return;
    }
    if (self.pawTextfield.text.length == 0) {
        [[DialogTip dialogTip]showDialogTip:self.view tipText:NSLocalizedString(@"PAW_MSG", nil)];
        return;
    }
    if (self.codeTextField.text.length == 0) {
        [[DialogTip dialogTip]showDialogTip:self.view tipText:NSLocalizedString(@"CODE_MSG", nil)];
        return;
    }
//    if (!ZBAppDelegate.isNetwork) {
//        [[DialogTip dialogTip]showDialogTip:self.view tipText:NSLocalizedString(@"NO_NETWORK", nil)];
//        return;
//    }
    // 保存输入
    self.token = self.emailTextField.text;
    
    NSString *emailStr = self.emailTextField.text;
    NSCharacterSet  *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    emailStr = [emailStr stringByTrimmingCharactersInSet:set];

    NSString *codeStr = self.codeTextField.text;
    codeStr = [codeStr stringByTrimmingCharactersInSet:set];
    
    // 开始登陆
    [[LSLoginManager manager]login:emailStr password:self.pawTextfield.text checkcode:codeStr];
    [self showLoading];
}

//重新请求验证码
- (IBAction)reloadBtnDid:(UIButton *)sender {
    self.codeLoading.hidden = NO;
    self.reloadBtn.hidden = YES;
    [self getConfig];
}

// 请求验证码
- (void)getCheckCode {
    NSLog(@"请求验证码");
    self.codeLoading.hidden = NO;
    self.reloadBtn.hidden = YES;
    LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
    [manager anchorGetVerificationCode:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, const char * _Nullable data, int len) {
        NSData * imageData = [[NSData alloc]initWithBytes:data length:len];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"获取验证码%d",len);
            self.codeLoading.hidden = YES;
            self.reloadBtn.hidden = NO;
                // 获取验证码成功
                if (len > 0) {
                UIImage *image = [UIImage imageWithData:imageData];
                    // 有验证码, 不能自动登陆
                    [self.reloadBtn setBackgroundImage:image forState:UIControlStateNormal];
                    
                } else {
                    // 无验证码
                    [self.reloadBtn setBackgroundImage:[UIImage imageNamed:@"Reload"] forState:UIControlStateNormal];
                }
        });
    }];
}

#pragma mark Login回调
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(ZBLSLoginItemObject * _Nullable)loginItem errnum:(ZBHTTP_LCC_ERR_TYPE)errnum errmsg:(NSString * _Nonnull)errmsg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
        if (success) {
            LSMainViewController *mainVC =  [[LSMainViewController alloc] initWithNibName:nil bundle:nil];
            LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:mainVC];
            [LiveModule module].moduleVC = mainVC;
            [LiveModule module].fromVC = nvc;
            ZBAppDelegate.window.rootViewController = nvc;
        }
        else
        {
            //强制更新
             if (errnum == ZBHTTP_LCC_ERR_FORCED_TO_UPDATE) {
                [self.navigationController popToRootViewControllerAnimated:NO];
                 [self showUpdateAlertView];
            }
            else
            {
                NSLog(@"登录失败获取验证码");
                [self getCheckCode];
                [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
            }
        }
    });
}

#pragma mark TextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.pawTextfield) {
        if (string.length == 0) return YES;
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 32) {
            return NO;
        }
    }
    if (textField == self.codeTextField) {
        if (string.length == 0) return YES;
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 4) {
            return NO;
        }
    }
    return YES;
}

#pragma mark -  键盘即将显示的时候调用
- (void)keyboardWillApprear:(NSNotification *)noti {
    
    CGFloat loginBtnMaxY = self.loginBtn.frame.origin.y + self.loginBtn.frame.size.height +20;
    // 取出通知中的信息
    NSDictionary *dict = noti.userInfo;
    // 键盘的高度
    // 停止后的Y值
    CGRect keyboardRect = [dict[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat keyboardEndY = keyboardRect.origin.y;

    if (loginBtnMaxY > keyboardEndY) {
        // 对 View 执行动画，向上平移
        [UIView animateWithDuration:0.3 animations:^{
            self.view.transform =CGAffineTransformMakeTranslation(0, (keyboardEndY - loginBtnMaxY));
        }];
    }
}

#pragma mark -  键盘即将隐藏的时候调用
- (void)keyboardWillDisAppear:(NSNotification *)noti {
    // 取出通知中的信息
    NSDictionary *dict = noti.userInfo;
    // 间隔时间
    NSTimeInterval interval = [dict[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    
    [UIView animateWithDuration:interval animations:^{
        // CGAffineTransformIdentity 恢复 transform的设置
        self.view.transform =CGAffineTransformIdentity;
    }];
}

#pragma mark 隐藏键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark 强制更新弹窗
- (void)showUpdateAlertView
{
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"showMandatoryUpdateDialog"] boolValue]) {

        UIAlertController * alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UPDATE_TITLE", nil) message:[LSConfigManager manager].item.minAvailableMsg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"UPDATE_UPDATE_NOW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[LSConfigManager manager].item.downloadAppUrl]];
        }];
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"showMandatoryUpdateDialog"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
