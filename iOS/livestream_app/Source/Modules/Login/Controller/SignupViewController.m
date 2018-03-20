//
//  SignupViewController.m
//  livestream
//
//  Created by Calvin on 2017/12/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SignupViewController.h"
#import "DialogTip.h"
#import "CompleteInformationViewController.h"
#import "LSCheckMailRequest.h"
#import "MailLoginHandler.h"
#import "LSLoginManager.h"
@interface SignupViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *mailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pawTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;
@property (strong, nonatomic) LSSessionRequestManager *sessionManager;
@end

@implementation SignupViewController

- (void)initCustomParam {
    [super initCustomParam];
    
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromSelf(@"EMAIL_SIGNUP_TITLE");
    
    self.signUpBtn.layer.cornerRadius = 5;
    self.signUpBtn.layer.masksToBounds = YES;
    
    self.pawTextField.delegate = self;
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
    if (self.mailTextField.text.length > 0 && self.pawTextField.text.length >= 4)
    {
        [self.signUpBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0x5d0e85)];
        self.signUpBtn.userInteractionEnabled = YES;
    }
    else
    {
        [self.signUpBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
        self.signUpBtn.userInteractionEnabled = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.pawTextField) {
        if (string.length == 0) return YES;
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 12) {
            return NO;
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//是否邮箱格式
- (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//是否只有字母和数字
- (BOOL)isValidatePassword:(NSString *)password {
    NSString *emailRegex = @"[a-zA-Z0-9]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:password];
}

- (IBAction)signUpBtnDid:(UIButton *)sender {
    
    [self.view endEditing:YES];
    if ([self isValidateEmail:self.mailTextField.text]) {
        if ([self isValidatePassword:self.pawTextField.text]) {
          [self checkMail];
        }
        else
        {
            [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"PASSWORD_TYPE_ERROR")];
        }
    }
    else{
        [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"EMAIL_FORMAT_ERROR")];
    }
}

- (void)checkMail
{
    LSCheckMailRequest * request = [[LSCheckMailRequest alloc]init];
    request.email = self.mailTextField.text;
    [self showLoading];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                
                MailLoginHandler * handler = [[MailLoginHandler alloc]initWithUserId:self.mailTextField.text andPassword:self.pawTextField.text];
                [LSLoginManager manager].loginHandler = handler;
                
                CompleteInformationViewController * vc = [[CompleteInformationViewController alloc] initWithNibName:nil bundle:nil];
                vc.isEmailRegister = YES;
                LiveLoginInfo * loginInfo = [[LiveLoginInfo alloc]init];
                loginInfo.email = self.mailTextField.text;
                loginInfo.password = self.pawTextField.text;
                vc.loginInfo = loginInfo;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
               [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

@end
