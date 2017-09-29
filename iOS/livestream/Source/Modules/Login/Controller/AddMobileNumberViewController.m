//
//  AddMobileNumberViewController.m
//  testDemo
//
//  Created by Calvin on 17/9/28.
//  Copyright © 2017年 dating. All rights reserved.
//

#import "AddMobileNumberViewController.h"
#import "CountryCodeViewController.h"
#import "Country.h"
#import "GetPhoneVerifyCodeRequest.h"
@interface AddMobileNumberViewController ()<CountryCodeViewControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *countryCodeBtn;
@property (nonatomic, strong) Country * countryItem;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, strong) SessionRequestManager* sessionManager;
@end

@implementation AddMobileNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Add Mobile Number";
    
    self.phoneTextField.delegate = self;
    
    self.sessionManager = [SessionRequestManager manager];
}

- (void)initCustomParam {
    self.backTitle = NSLocalizedString(@"", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return YES;
}

- (IBAction)verifyCodeBtnDid:(UIButton *)sender {
    CountryCodeViewController * vc = [[CountryCodeViewController alloc]initWithNibName:nil bundle:nil];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)countryCode:(Country *)item
{
    self.countryItem = item;
    
    [self.countryCodeBtn setTitle:[NSString stringWithFormat:@"%@ (+%@)",item.fullName,item.zipCode] forState:UIControlStateNormal];
}

- (void)showErrorMessage:(NSString *)message
{
    self.infoLabel.hidden = NO;
    self.infoLabel.text = message;
}

- (IBAction)sendBtn:(UIButton *)sender {
    
    if (self.phoneTextField.text.length == 0) {
        [self showErrorMessage:@"Please enter a valid phone number."];
        return;
    }
    self.infoLabel.hidden = YES;
    [self showLoading];
    GetPhoneVerifyCodeRequest * request = [[GetPhoneVerifyCodeRequest alloc]init];
    request.country = self.countryItem.fullName;
    request.areaCode = self.countryItem.zipCode;
    request.phoneNo = self.phoneTextField.text;
    
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

@end
