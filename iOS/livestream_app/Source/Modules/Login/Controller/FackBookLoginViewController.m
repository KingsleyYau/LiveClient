//
//  FackBookLoginViewController.m
//  livestream
//
//  Created by Calvin on 2017/12/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "FackBookLoginViewController.h"
#import "DialogTip.h"
#import "LSCheckMailRequest.h"
#import "FacebookLoginHandler.h"
#import "LSLoginManager.h"
#import "CompleteInformationViewController.h"


@interface FackBookLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *noEMailView;
@property (weak, nonatomic) IBOutlet UIView *mailView;
@property (weak, nonatomic) IBOutlet UILabel *mailLabel;
@property (weak, nonatomic) IBOutlet UITextField *pawTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@end

@implementation FackBookLoginViewController

- (void)dealloc {
    NSLog(@"FackBookLoginViewController:dealloc()");
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)backAction:(id)sender {
    [super backAction:sender];
    
    [[LSLoginManager manager].loginHandler logout:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromSelf(@"LOGIN_FACEBOOK_TITLE");
    
    self.pawTextField.delegate = self;
    BOOL isAddEmail = NO;
    if (self.email.length > 0) {
        self.mailView.hidden = NO;
        self.noEMailView.hidden = YES;
        NSString * str = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:NSLocalizedStringFromSelf(@"EMAIL_REGISTER_TIP"),self.email]];
             NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        
         [attributedString addAttribute:NSExpansionAttributeName value:@1 range:[str rangeOfString:self.email]];
        
       self.mailLabel.attributedText = attributedString;
    }
    else
    {
        self.mailView.hidden = YES;
        self.noEMailView.hidden = NO;
        isAddEmail = YES;
    }
    
    [self reportDidShowPage:isAddEmail];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)textDidChange:(NSNotification *)notifi
{
    if (self.emailTextField.text.length > 0)
    {
        [self.nextBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0x5d0e85)];
        self.nextBtn.userInteractionEnabled = YES;
    }
    else
    {
        [self.nextBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
        self.nextBtn.userInteractionEnabled = NO;
    }
    
    if (self.pawTextField.text.length > 0)
    {
        [self.loginBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0x5d0e85)];
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
    if (textField == self.pawTextField) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//邮箱
- (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (IBAction)nextBtnDid:(UIButton *)sender {
    
    [self showLoading];
    if ([self isValidateEmail:self.emailTextField.text]) {
        self.email = self.emailTextField.text;
        [LSLoginManager manager].loginHandler.loginInfo.email = self.email;
        
        LSCheckMailRequest *request = [[LSCheckMailRequest alloc] init];
        request.email = self.emailTextField.text;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                if (success) { // Facebook邮箱注册成功
                    CompleteInformationViewController * vc = [[CompleteInformationViewController alloc] initWithNibName:nil bundle:nil];
                    vc.isEmailRegister = NO;
                    if ([LSLoginManager manager].loginHandler.loginInfo) {
                        vc.loginInfo = [LSLoginManager manager].loginHandler.loginInfo;
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                    
                } else if (errnum == HTTP_LCC_ERR_MAILREGISTER_EXIST_QN_MAILBOX) {// 邮箱已在QN注册
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                    
                } else if (errnum == HTTP_LCC_ERR_MAILREGISTER_EXIST_LS_MAILBOX){// 邮箱已在直播独立站注册
                    self.mailView.hidden = NO;
                    self.noEMailView.hidden = YES;
                    NSString * str = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:NSLocalizedStringFromSelf(@"EMAIL_REGISTER_TIP"),self.email]];
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
                    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:[str rangeOfString:self.email]];
                    self.mailLabel.attributedText = attributedString;
                }
            });
        };
        [self.sessionManager sendRequest:request];
    }
    else
    {
        //不是邮箱
        [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"EMAIL_FORMAT_ERROR")];
    }
}

- (IBAction)loginBtnDid:(UIButton *)sender {
    FacebookLoginHandler *handler = (FacebookLoginHandler *)[LSLoginManager manager].loginHandler;
    
    LiveLoginInfo *info = [[LiveLoginInfo alloc] init];
    info.email = self.email;
    info.password = self.pawTextField.text;
    info.token = handler.token;
    
    handler.loginInfo = info;
    [self showLoading];
    [handler bingdingHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull userSid) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self hideLoading];
            if (success) {
                [LSLoginManager manager].loginHandler.loginInfo.password = self.pawTextField.text;
                [[LSLoginManager manager] login:handler];
            }else
             {
                 [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
             }
        });
    }];
}


@end
