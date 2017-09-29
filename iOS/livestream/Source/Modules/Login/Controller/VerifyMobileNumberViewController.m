//
//  VerifyMobileNumberViewController.m
//  livestream
//
//  Created by Calvin on 17/9/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "VerifyMobileNumberViewController.h"
#import "SubmitPhoneVerifyCodeRequest.h"
@interface VerifyMobileNumberViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *resendBtn;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) int time;
@property (nonatomic, strong) SessionRequestManager* sessionManager;
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
    
    self.phoneLabel.text = [NSString stringWithFormat:@"%@-%@",self.countryStr,self.phoneStr];
    
    self.codeTextField.delegate = self;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTime) userInfo:nil repeats:YES];
    
    self.sessionManager = [SessionRequestManager manager];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length > 0) {
        self.verifyBtn.userInteractionEnabled = YES;
    }
    return YES;
}

- (void)countDownTime
{
    self.time += [self.timer timeInterval];
    [self.resendBtn setTitle:[NSString stringWithFormat:@"Resend in %ds",self.time] forState:UIControlStateNormal];
    self.resendBtn.userInteractionEnabled = NO;
    if (self.time >= 30.0f) {
        [self.resendBtn setTitle:@"Resend" forState:UIControlStateNormal];
        self.resendBtn.userInteractionEnabled = YES;
        [self.timer invalidate];
        self.timer = nil;
        self.time = 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ResendCode:(UIButton *)sender {
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTime) userInfo:nil repeats:YES];
}


- (IBAction)changeBtnDid:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
 
- (IBAction)verifyBtnDid:(UIButton *)sender {
    
    if (self.codeTextField.text.length > 0) {
        [self showLoading];
        SubmitPhoneVerifyCodeRequest * request = [[SubmitPhoneVerifyCodeRequest alloc]init];
        request.phoneNo = self.phoneStr;
        request.country = self.countryStr;
        request.verifyCode = self.codeTextField.text;
        request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self hideLoading];
                if (success) {
                    
                }
                else
                {
                    [self showErrorMessage:errmsg];
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
