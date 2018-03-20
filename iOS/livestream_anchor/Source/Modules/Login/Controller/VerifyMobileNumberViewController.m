//
//  VerifyMobileNumberViewController.m
//  livestream
//
//  Created by Calvin on 17/9/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "VerifyMobileNumberViewController.h"
#import "SubmitPhoneVerifyCodeRequest.h"
#import "GetPhoneVerifyCodeRequest.h"
@interface VerifyMobileNumberViewController ()

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *resendBtn;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) int time;
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@end

@implementation VerifyMobileNumberViewController

- (void)dealloc
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromSelf(@"VERIFY_TITLE");
    
    self.changeBtn.layer.cornerRadius = 5;
    self.changeBtn.layer.masksToBounds = YES;
    self.verifyBtn.layer.cornerRadius = self.verifyBtn.frame.size.height/2;
    self.verifyBtn.layer.masksToBounds = NO;
    self.verifyBtn.layer.shadowOffset = CGSizeMake(3, 3);
    self.verifyBtn.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.verifyBtn.layer.shadowRadius = 2;
    self.verifyBtn.layer.shadowOpacity = 0.8;
    
    self.resendBtn.layer.cornerRadius = self.resendBtn.frame.size.height/2;
    
    self.resendBtn.layer.masksToBounds = YES;
    self.resendBtn.layer.borderColor = COLOR_WITH_16BAND_RGB(0x666666).CGColor;
    self.resendBtn.layer.borderWidth = 1;
    
    CGRect rect = self.codeTextField.frame;
    rect.size.width = screenSize.width - self.resendBtn.frame.size.width - 50;
    self.codeTextField.frame = rect;
    
    [self setPhoneLabelText];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTime) userInfo:nil repeats:YES];
    self.time = 30;
    
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)setPhoneLabelText
{
    self.phoneLabel.text = [NSString stringWithFormat:@"+%@-%@",self.country.zipCode,self.phoneStr];
    
    CGFloat phoneW = [self.phoneLabel.text sizeWithAttributes:@{NSFontAttributeName:self.phoneLabel.font}].width;
    
    CGRect phoneRect = self.phoneLabel.frame;
    phoneRect.size.width = phoneW;
    self.phoneLabel.frame = phoneRect;
    
    CGRect btnRect = self.changeBtn.frame;
    CGFloat right = self.phoneLabel.frame.origin.x + self.phoneLabel.frame.size.width + 10;
    btnRect.origin.x = right;
    self.changeBtn.frame = btnRect;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)textChange:(NSNotification *)notifi
{
    if (self.codeTextField.text.length > 0) {
        self.verifyBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x297AF3);
        self.verifyBtn.userInteractionEnabled = YES;
    }
    else
    {
        self.verifyBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
        self.verifyBtn.userInteractionEnabled = NO;
    }
}

- (void)countDownTime
{
    self.time -= [self.timer timeInterval];
    NSString *times = [NSString stringWithFormat:@"%d",self.time];
    [self.resendBtn setTitle:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"RESEND_IN"),times] forState:UIControlStateNormal];
    [self.resendBtn setTitleColor:COLOR_WITH_16BAND_RGB(0x666666) forState:UIControlStateNormal];
    self.resendBtn.backgroundColor = [UIColor whiteColor];
    self.resendBtn.layer.borderColor = COLOR_WITH_16BAND_RGB(0x666666).CGColor;
    self.resendBtn.layer.borderWidth = 1;
    self.resendBtn.userInteractionEnabled = NO;
    if (self.time <= 0.0f) {
        [self.resendBtn setTitle:NSLocalizedStringFromSelf(@"RESEND_END") forState:UIControlStateNormal];
        [self.resendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.resendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x297AF3);
        self.resendBtn.userInteractionEnabled = YES;
        self.resendBtn.layer.borderWidth = 0;
        [self.timer invalidate];
        self.timer = nil;
        self.time = 30;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ResendCode:(UIButton *)sender {
    
    [self showLoading];
    self.resendBtn.userInteractionEnabled = NO;
    GetPhoneVerifyCodeRequest * request = [[GetPhoneVerifyCodeRequest alloc]init];
    request.country = self.country.fullName;
    request.areaCode = self.country.zipCode;
    request.phoneNo = self.phoneStr;
    
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
              self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTime) userInfo:nil repeats:YES];
            }
            else
            {
                [self showErrorMessage:errmsg];
                self.resendBtn.userInteractionEnabled = YES;
            }
        });
        
    };
    [self.sessionManager sendRequest:request];
    
 
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)changeBtnDid:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
 
- (IBAction)verifyBtnDid:(UIButton *)sender {
    
    if (self.codeTextField.text.length > 0) {
        [self showLoading];
        SubmitPhoneVerifyCodeRequest * request = [[SubmitPhoneVerifyCodeRequest alloc]init];
        request.phoneNo = self.phoneStr;
        request.country = self.country.shortName;
        request.areaCode = self.country.zipCode;
        request.verifyCode = self.codeTextField.text;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self hideLoading];
                if (success) {
                    for (UIViewController * vc in self.navigationController.viewControllers) {
                        if ([vc isKindOfClass:NSClassFromString(@"BookPrivateBroadcastViewController")]) {
                            [self.navigationController popToViewController:vc animated:YES];
                        }
                    }
                }
                else
                {
                    if (errnum == HTTP_LCC_ERR_MORE_TWENTY_PHONE) {
                        self.errorView.hidden = NO;
                    }
                    else
                    {
                      [self showErrorMessage:errmsg];
                    }
                    
                }
            });
        };
        
        [self.sessionManager sendRequest:request];
    }
}

- (void)showErrorMessage:(NSString *)message
{
    self.errorLabel.hidden = NO;
    self.errorLabel.text = message;
}
@end
