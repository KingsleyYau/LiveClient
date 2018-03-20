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
#import "UpdateDialog.h"
#import "LSMainViewController.h"
#import "LiveModule.h"
#import "DialogTip.h"

#import "StreamTestViewController.h"

@interface LSLoginViewController ()<UITextViewDelegate,LoginManagerDelegate,UITextFieldDelegate>

@property (nonatomic, copy) NSString * token;
@property (weak, nonatomic) IBOutlet UITextView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pawTextfield;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIImageView *checkcodeImageView;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@property (nonatomic, strong) UpdateDialog * updateDialog;
@property (nonatomic, strong) LSLoginManager * loginManager;
@end

@implementation LSLoginViewController

- (void)dealloc
{
    [self.loginManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.loginBtn.layer.cornerRadius = self.loginBtn.frame.size.height/2;
    self.loginBtn.layer.masksToBounds = YES;
    [self setInfoViewText];
    
    self.loginManager = [LSLoginManager manager];
    [self.loginManager addDelegate:self];
    
    self.emailTextField.text = self.loginManager.email;
    self.pawTextfield.text = self.loginManager.password;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.codeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.pawTextfield.delegate = self;
    
    self.updateDialog = [UpdateDialog dialog];
    
    
    NSString * email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    if (email.length > 0) {
        self.emailTextField.text = email;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self getConfig];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
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
                
                [[ZBLSRequestManager manager] setWebSite:item.httpSvrUrl];
                [[LiveModule module] setConfigUrl:item.httpSvrUrl];
                
                [self getCheckCode];
                
                NSInteger buildID = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue];
                //判断是否有强制更新
                if (item.minAavilableVer > buildID) {
                    self.updateDialog.tipsLabel.text = item.minAvailableMsg;
                    [self.updateDialog showDialog:self.view actionBlock:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[LSConfigManager manager].item.downloadAppUrl]];
                    }];
                }
            }
            else
            {
                self.reloadBtn.hidden = NO;
                self.checkcodeImageView.hidden = YES;
            }
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)audienceLogin:(UIButton *)sender {
    // Test
    StreamTestViewController *vc = [[StreamTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
//    // 开始登陆
//    [[LiveModule module] start:@"manId123" token:ALEX_TOKEN];
}

//登录按钮点击方法
- (IBAction)loginBtnDid:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    if (self.emailTextField.text.length > 0 && self.pawTextfield.text > 0 && self.codeTextField.text > 0) {
    
        // 保存输入
        self.token = self.emailTextField.text;
        
        NSString *emailStr = self.emailTextField.text;
        NSCharacterSet  *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        emailStr = [emailStr stringByTrimmingCharactersInSet:set];
 
        NSString *codeStr = self.codeTextField.text;
        codeStr = [codeStr stringByTrimmingCharactersInSet:set];
        
        // 开始登陆
        [[LSLoginManager manager]login:emailStr password:self.pawTextfield.text checkcode:codeStr];
        
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

//重新请求验证码
- (IBAction)reloadBtnDid:(UIButton *)sender {
    [self getConfig];
}

// 请求验证码
- (void)getCheckCode {
    __weak typeof(self) weakSelf = self;
    ZBLSRequestManager *manager = [ZBLSRequestManager manager];
    [manager anchorGetVerificationCode:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, const char * _Nullable data, int len) {

        __block UIImage *image = [UIImage imageWithData:[NSData dataWithBytes:data length:len]];
        dispatch_async(dispatch_get_main_queue(), ^{
                // 获取验证码成功
                if (len > 0) {
                    // 有验证码, 不能自动登陆
                    weakSelf.reloadBtn.hidden = YES;
                    weakSelf.checkcodeImageView.hidden = NO;
                    [weakSelf.checkcodeImageView setImage:image];
                    
                } else {
                    // 无验证码
                    weakSelf.reloadBtn.hidden = NO;
                    weakSelf.checkcodeImageView.hidden = YES;
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
                self.updateDialog.tipsLabel.text = [LSConfigManager manager].item.minAvailableMsg;
                [self.updateDialog showDialog:self.view actionBlock:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[LSConfigManager manager].item.downloadAppUrl]];
                }];
            }
            else
            {
                [self getCheckCode];
                [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
            }
        }
    });
}

#pragma mark TextViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"Terms"]) {
        
        return NO;
    }
    else
    {
        return YES;
    }
    return YES;
}

#pragma mark 设置下划线
- (void)setInfoViewText
{
    self.infoView.delegate = self;
    NSString * str = NSLocalizedString(@"User agreement", nil);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[str rangeOfString:str]];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:[str rangeOfString:str]];
    
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"Terms://"
                             range:[[attributedString string] rangeOfString:NSLocalizedString(@"Terms and Policies", nil)]];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[str rangeOfString:NSLocalizedString(@"Terms and Policies", nil)]];//设置下划线
    
    self.infoView.attributedText = attributedString;
}

#pragma mark TextField监听通知和回调
- (void)textDidChange:(NSNotification *)notifi
{
    if (self.emailTextField.text.length >= 4 && self.pawTextfield.text.length >= 4 && self.codeTextField.text.length > 0)
    {
        [self.loginBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0x297AF3)];
        self.loginBtn.userInteractionEnabled = YES;
    }
    else
    {
        [self.loginBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
        self.loginBtn.userInteractionEnabled = NO;
    }
}

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
    return YES;
}

#pragma mark 隐藏键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
