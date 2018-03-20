//
//  LSLoginViewController.m
//  livestream
//
//  Created by Calvin on 2017/12/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSLoginViewController.h"
#import "EMailLoginViewController.h"
#import "SignupViewController.h"
#import <AccountSDK/AccountSDK.h>
#import "LiveModule.h"
#import "LSConfigManager.h"
#import "LSYYImage.h"
#import "LSYYImageCoder.h"
#import "LSLoginManager.h"
#import "FacebookLoginHandler.h"
#import "FackBookLoginViewController.h"
#import "LSMainViewController.h"
#import "DialogTip.h"
#import "UserAgreementViewController.h"
#import "UpdateDialog.h"
@interface LSLoginViewController ()<LiveModuleDelegate,UITextViewDelegate,LoginManagerDelegate,FacebookLoginHandlerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *fbLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *mailLoginBtn;
@property (weak, nonatomic) IBOutlet UITextView *infoView;
@property (weak, nonatomic) IBOutlet LSYYAnimatedImageView *backgroundImageView;
@property (strong) AccountSDKManager *accountManager;
@property (nonatomic, strong) LSLoginManager * loginManager;
@property (nonatomic, strong) UpdateDialog * updateDialog;
@end

@implementation LSLoginViewController

- (void)dealloc
{
    [self.loginManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fbLoginBtn.layer.cornerRadius = 15;
    self.fbLoginBtn.layer.masksToBounds = YES;
    
    self.mailLoginBtn.layer.cornerRadius = 15;
    self.mailLoginBtn.layer.masksToBounds = YES;
    
    self.loginManager = [LSLoginManager manager];
    [self.loginManager addDelegate:self];
    
    self.accountManager = [AccountSDKManager shareInstance];
    
    [self setInfoViewText];
    
    self.updateDialog = [UpdateDialog dialog];
    
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.backgroundImageView.isOneRunloop = NO;
    LSYYImage *animaImage = [LSYYImage imageNamed:@"Romantic Rocket"];
    self.backgroundImageView.image = animaImage;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    //检测是否登录过，并且走自动登录逻辑
    if ([self.loginManager autoLogin]) {
        [self showLoading];
    }
    else
    {
        [[LSConfigManager manager] clean];
        [[LSConfigManager manager] synConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ConfigItemObject * _Nullable item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    
                    LSConfigManager *config = [LSConfigManager manager];
                    config.item = item;
                    
                    [[LSRequestManager manager] setWebSite:item.httpSvrUrl];
                    
                    NSInteger buildID = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue];
                    //判断是否有强制更新
                    if (item.minAavilableVer > buildID) {
                        self.updateDialog.tipsLabel.text = item.minAvailableMsg;
                        [self.updateDialog showDialog:self.view actionBlock:^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[LSConfigManager manager].item.downloadAppUrl]];
                        }];
                    }
                }
            });
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setInfoViewText
{
    NSString * str = NSLocalizedString(@"User agreement", nil);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[str rangeOfString:str]];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:[str rangeOfString:str]];
    
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"Terms://"
                             range:[[attributedString string] rangeOfString:NSLocalizedString(@"Terms and Conditions", nil)]];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[str rangeOfString:NSLocalizedString(@"Terms and Conditions", nil)]];//设置下划线
    [attributedString addAttribute:NSLinkAttributeName
                             value:@"Privacy://"
                             range:[[attributedString string] rangeOfString:NSLocalizedString(@"Privacy Policy", nil)]];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[str rangeOfString:NSLocalizedString(@"Privacy Policy", nil)]];//设置下划线
    self.infoView.attributedText = attributedString;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"Terms"]) {
        UserAgreementViewController * vc = [[UserAgreementViewController alloc] initWithNibName:nil bundle:nil];
        vc.isTermsOfUse = YES;
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    else if ([[URL scheme] isEqualToString:@"Privacy"])
    {
        UserAgreementViewController * vc = [[UserAgreementViewController alloc] initWithNibName:nil bundle:nil];
        vc.isTermsOfUse = NO;
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    else
    {
        return YES;
    }
    return YES;
}

- (IBAction)fbLoginBtnDid:(UIButton *)sender {
    [self showLoading];
    FacebookLoginHandler * fbLogin = [[FacebookLoginHandler alloc] initWithPresentVC:self];
    fbLogin.delegate = self;
    [self.loginManager login:fbLogin];
}

- (IBAction)emailLoginBtnDid:(UIButton *)sender {

//    NSString * token = ALEX_TOKEN;
//    [[LiveModule module] start:@"manId123" token:token];
//    [self showLoading];
//    return;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [self addActionTarget:alert title:NSLocalizedString(@"EMAIL_SIGNIN_TITLE", nil) color:COLOR_WITH_16BAND_RGB(0x383838) action:^(UIAlertAction *action) {
        [weakSelf pushLoginVC];
    } isCancelBtn:NO];
    [self addActionTarget:alert title:NSLocalizedString(@"EMAIL_SIGNUP_TITLE", nil) color:COLOR_WITH_16BAND_RGB(0x383838) action:^(UIAlertAction *action) {
        [weakSelf pushSginVC];
    } isCancelBtn:NO];
    
    [self addActionTarget:alert title:@"Cancel" color:COLOR_WITH_16BAND_RGB(0x8b8b8b) action:nil isCancelBtn:YES];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addActionTarget:(UIAlertController *)alertController title:(NSString *)title color:(UIColor *)color action:(void(^)(UIAlertAction *action))actionTarget isCancelBtn:(BOOL)isCancel
{
    if (isCancel) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:nil];
        [action setValue:color forKey:@"_titleTextColor"];
        [alertController addAction:action];
    }
    else
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            actionTarget(action);
        }];
        [action setValue:color forKey:@"_titleTextColor"];
        [alertController addAction:action];
    }
}

- (void)pushLoginVC
{
    EMailLoginViewController * vc = [[EMailLoginViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushSginVC
{
    SignupViewController * vc = [[SignupViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSManBaseInfoItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
        if (success) {
            LSMainViewController *mainVC =  [[LSMainViewController alloc] initWithNibName:nil bundle:nil];
            LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:mainVC];
            [LiveModule module].moduleVC = mainVC;
            [LiveModule module].fromVC = nvc;
            AppDelegate().window.rootViewController = nvc;

        }
        else
        {
            //Facebook没有邮箱
            if (errnum == HTTP_LCC_ERR_FACEBOOK_NO_MAILBOX) {
                FackBookLoginViewController * vc = [[FackBookLoginViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:vc animated:YES];
            }
            //强制更新
            else if (errnum == HTTP_LCC_ERR_FORCED_TO_UPDATE) {
                [self.navigationController popToRootViewControllerAnimated:NO];
                self.updateDialog.tipsLabel.text = [LSConfigManager manager].item.minAvailableMsg;
                [self.updateDialog showDialog:self.view actionBlock:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[LSConfigManager manager].item.downloadAppUrl]];
                }];
            }
            else
            {
               [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
            }
        }
    });
}

#pragma mark - FacebookLoginHandlerDelegate
- (void)facebookSDKLogin:(BOOL)success error:(NSError *)error {
    if (!success) {
        [self hideLoading];
    }
}

- (void)facebookUserLogin:(BOOL)success error:(NSError *)error errnum:(HTTP_LCC_ERR_TYPE)errnum errMsg:(NSString *)errMsg {
    if (errnum != HTTP_LCC_ERR_SUCCESS && errnum != HTTP_LCC_ERR_FACEBOOK_NO_MAILBOX) {
        [self hideLoading];
        if (errMsg) {
            [[DialogTip dialogTip]showDialogTip:self.view tipText:errMsg];
        } else {
            
        }
    }
}

@end
