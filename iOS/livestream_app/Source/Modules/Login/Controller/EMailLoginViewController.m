//
//  EMailLoginViewController.m
//  livestream
//
//  Created by Calvin on 2017/12/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "EMailLoginViewController.h"
#import "SignupViewController.h"
#import "ForgotPasswordViewController.h"
#import "LSLoginManager.h"
#import "MailLoginHandler.h"
#import "DialogTip.h"
@interface EMailLoginViewController ()<UITextFieldDelegate,LoginManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField * mailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pawTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) LSLoginManager * loginManager;
@end

@implementation EMailLoginViewController

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.loginManager removeDelegate:self];
}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromSelf(@"EMAIL_LOGIN_TITLE");
    
    self.loginBtn.layer.cornerRadius = 5;
    self.loginBtn.layer.masksToBounds = YES;
    
    self.pawTextField.delegate = self;
    
    self.loginManager = [LSLoginManager manager];
    [self.loginManager addDelegate:self];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"LoginEmail"]) {
       self.mailTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"LoginEmail"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forgetEmail:) name:@"forgetEmail" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    NSDictionary * loginDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginInfo"];
    if ([[loginDic objectForKey:@"Type"] isEqualToString:@"Email"]) {
        self.mailTextField.text = [loginDic objectForKey:@"Email"];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [self hideLoading];
}

- (void)forgetEmail:(NSNotification *)notifi
{
    self.mailTextField.text = notifi.object;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)textDidChange:(NSNotification *)notifi
{
    if (self.mailTextField.text.length >= 4 && self.pawTextField.text.length >= 4)
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


- (IBAction)loginBtnDid:(UIButton *)sender {
    
    [self.view endEditing:YES];
    MailLoginHandler * mailLogin = [[MailLoginHandler alloc] initWithUserId:self.mailTextField.text andPassword:self.pawTextField.text];
    [self.loginManager login:mailLogin];
    [self showLoading];
}

- (IBAction)forgotPawBtnDid:(UIButton *)sender {
    ForgotPasswordViewController * vc = [[ForgotPasswordViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)signUpBtnDid:(UIButton *)sender {
    SignupViewController * vc = [[SignupViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSManBaseInfoItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!success) {
            [self hideLoading];
            [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
        }
    });
}
@end
