//
//  ForgotPasswordViewController.m
//  livestream
//
//  Created by Calvin on 2017/12/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "DialogTip.h"
#import "DialogOK.h"
#import "LSFindPasswordRequest.h"
#import "LSGetVerificationCodeRequest.h"
@interface ForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UITextField *mailTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIImageView *codeImageView;
@property (nonatomic, strong) LSSessionRequestManager * sessionManager;
@property (weak, nonatomic) IBOutlet UIButton *relaodBtn;
@end

@implementation ForgotPasswordViewController

- (void)initCustomParam {
    [super initCustomParam];
    
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromSelf(@"FORGOT_PASSWORD_TITLE");
    
    self.nextBtn.layer.cornerRadius = 5;
    self.nextBtn.layer.masksToBounds = YES;
    
    [self getCode];
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
    if (self.mailTextField.text.length > 0 && self.codeTextField.text.length > 0)
    {
        [self.nextBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0x5d0e85)];
        self.nextBtn.userInteractionEnabled = YES;
    }
    else
    {
        [self.nextBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
        self.nextBtn.userInteractionEnabled = NO;
    }
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
    
    [self.view endEditing:YES];
    if ([self isValidateEmail:self.mailTextField.text]) {
        [self showLoading];
        LSFindPasswordRequest * request = [[LSFindPasswordRequest alloc]init];
        request.sendMail = self.mailTextField.text;
        request.checkCode = self.codeTextField.text;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                if (success) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"forgetEmail" object:self.mailTextField.text];
                    
                    DialogOK * logOK = [DialogOK dialog];
                    logOK.tipsLabel.text = NSLocalizedStringFromSelf(@"EMAIL_HAS_SEND");
                    [logOK.okButton setTitle:@"OK" forState:UIControlStateNormal];
                    [logOK showDialog:self.view actionBlock:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
                else
                {
                  [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                    //验证码失败
                    if (errnum == HTTP_LCC_ERR_FINDPASSWORD_VERIFICATION_WRONG) {
                       [self getCode];
                    }
                   
                }
            });
        };
        [self.sessionManager sendRequest:request];
    }
    else
    {
        [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"EMAIL_FORMAT_ERROR")];
    }
}
- (IBAction)reloadBtn:(UIButton *)sender {
    [self getCode];
}

- (void)getCode
{
    LSGetVerificationCodeRequest * request = [[LSGetVerificationCodeRequest  alloc] init];
    request.verifyType = VERIFYCODETYPE_FINDPW;
    request.useCode = NO;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, const char * _Nullable data, int len) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (len > 0) {
                UIImage * image = [UIImage imageWithData:[NSData dataWithBytes:data length:len]];
                self.codeImageView.image = image;
                self.relaodBtn.hidden = YES;
            }
            else
            {
                self.relaodBtn.hidden = NO;
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

@end
