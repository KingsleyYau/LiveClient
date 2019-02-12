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
#import "VerifyMobileNumberViewController.h"
@interface AddMobileNumberViewController ()<CountryCodeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *countryCodeBtn;
@property (nonatomic, strong) Country * countryItem;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@end

@implementation AddMobileNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedStringFromSelf(@"ADD_MOBILE_NUMBER");
    
    self.sendBtn.layer.cornerRadius = self.sendBtn.frame.size.height/2;
    self.sendBtn.layer.masksToBounds = NO;
    self.sendBtn.layer.shadowOffset = CGSizeMake(3, 3);
    self.sendBtn.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.sendBtn.layer.shadowRadius = 2;
    self.sendBtn.layer.shadowOpacity = 0.8;
    
    self.sessionManager = [LSSessionRequestManager manager];
    
   // self.countryItem = [Country findPhoneCodeByCountry];
    
    Country * country = [[Country alloc]init];
    country.zipCode = @"001";
    country.fullName = @"United States";
    country.shortName = @"US";
    self.countryItem = country;
    
    [self.countryCodeBtn setTitle:[NSString stringWithFormat:@"%@ (+%@)",self.countryItem.fullName,self.countryItem.zipCode] forState:UIControlStateNormal];
    
    self.sendBtn.userInteractionEnabled = NO;
    self.sendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
    self.infoLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(12)];
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
    [self hideLoading];
}

- (void)textChange:(NSNotification *)notifi
{
    if (self.phoneTextField.text.length > 0) {
        self.sendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x297AF3);
        self.sendBtn.userInteractionEnabled = YES;
    }
    else
    {
        self.sendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
        self.sendBtn.userInteractionEnabled = NO;
    }
}

- (void)initCustomParam {
//    self.backTitle = NSLocalizedString(@"", nil);
    [super initCustomParam];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)verifyCodeBtnDid:(UIButton *)sender {
    CountryCodeViewController * vc = [[CountryCodeViewController alloc]initWithNibName:nil bundle:nil];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
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
        [self showErrorMessage:NSLocalizedStringFromSelf(@"ENTER_PHONE_NUMBER")];
        return;
    }
    self.infoLabel.hidden = YES;
    [self showLoading];
    NSString * phone = self.phoneTextField.text;
    GetPhoneVerifyCodeRequest * request = [[GetPhoneVerifyCodeRequest alloc]init];
    request.country = self.countryItem.fullName;
    request.areaCode = self.countryItem.zipCode;
    request.phoneNo = phone;
    
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                VerifyMobileNumberViewController * vc = [[VerifyMobileNumberViewController alloc]initWithNibName:nil bundle:nil];
                vc.phoneStr = phone;
                vc.country = self.countryItem;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                [self showErrorMessage:errmsg];
            }
            self.sendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
            self.sendBtn.userInteractionEnabled = NO;
        });
        
    };
    [self.sessionManager sendRequest:request];
}

@end
