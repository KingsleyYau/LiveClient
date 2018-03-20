//
//  LoginPhoneViewController.m
//  livestream
//
//  Created by Max on 2017/5/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LoginPhoneViewController.h"
#import "SelectCountryController.h"
#import "LoginManager.h"
#import "RequestManager.h"
#import "Country.h"
#import "TTTAttributedLabel.h"
#import "ForgotPasswordController.h"

#define keyboardDuration 0.56

#define FORGOT_PASSWORD_URL @"FORGOT_PASSWORD_URL"

@interface LoginPhoneViewController () <LoginManagerDelegate,SelectCountryControllerDelegate,TTTAttributedLabelDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) LoginManager* loginManager;

@property (nonatomic, strong) TTTAttributedLabel* labelForgotPassword;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) NSString *prePasswordFieldTitle;

@end

@implementation LoginPhoneViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.navigationTitle = NSLocalizedString(@"Log in with Phone Number", nil);
    
    self.loginManager = [LoginManager manager];
    [self.loginManager addDelegate:self];
}

- (void)dealloc {
    [self.loginManager removeDelegate:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 显示导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // 设置导航栏返回按钮
    [self setBackleftBarButtonItemOffset:30];
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 判断是否登陆中
    switch (self.loginManager.status) {
        case NONE: {
            // 没登陆
            
        }break;
        case LOGINING:{
            // 登陆中
            [self showLoading];
            
//            // 显示上次登录密码
//            self.textFieldPhone.text = self.loginManager.lastInputEmail;
//            self.textFieldPassword.text = self.loginManager.lastInputPassword;
            
        }break;
        case LOGINED:{
            // 已经登陆
            
        }break;
        default:
            break;
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeSingleTap];
    
    // 关闭输入
    [self closeAllInputView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addSingleTap];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
        
}

- (void)setupContainView {
    [super setupContainView];
    [self setupInputView];
}

#pragma mark - 输入控件
- (void)setupInputView {
    // 初始化选择国家
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"Login_Set_country"] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(selectCountryWithController) forControlEvents:UIControlEventTouchUpInside];
    self.textFieldCountry.rightView = button;
    self.textFieldCountry.rightViewMode = UITextFieldViewModeAlways;
    self.textFieldCountry.tintColor = [UIColor clearColor];
    [self.textFieldCountry setValue:COLOR_WITH_16BAND_RGB(0x383838)  forKeyPath:@"_placeholderLabel.textColor"];
    
    // 初始化忘记密码
    self.labelForgotPassword = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.labelForgotPassword.textAlignment = NSTextAlignmentCenter;
    self.labelForgotPassword.linkAttributes = @{NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0x383838)
                                                ,NSUnderlineStyleAttributeName:@(1)};
    self.labelForgotPassword.activeLinkAttributes = @{NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0xbfbfbf)
                                                ,NSUnderlineStyleAttributeName:@(1)};
    self.labelForgotPassword.delegate = self;
    
    NSString* text = @"Forgot Password?";
    self.labelForgotPassword.text = text;
    [self.labelForgotPassword addLinkToURL:[NSURL URLWithString:FORGOT_PASSWORD_URL] withRange:NSMakeRange(0, text.length)];
    [self.view addSubview:self.labelForgotPassword];
    
    [self.labelForgotPassword mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.btnLogin.mas_bottom).offset(16);
        make.centerX.equalTo(self.btnLogin);
        make.height.equalTo(@(30));
    }];
    
    UIButton *countryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [countryBtn addTarget:self action:@selector(selectCountryWithController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:countryBtn];
    [countryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textFieldCountry);
    }];
    
    UIButton *zipCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [zipCodeBtn addTarget:self action:@selector(selectCountryWithController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zipCodeBtn];
    [zipCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textFieldZone);
    }];
    
    self.countryNameLabel.text = [LoginManager manager].fullName;
    self.textFieldZone.text = [NSString stringWithFormat:@"+%@",[LoginManager manager].zipCode];
    
    [self.btnLogin setTitleColor:Color(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
}

- (void)selectCountryWithController{

    SelectCountryController *countryController = [[SelectCountryController alloc]init];
    countryController.delegate = self;
    [self.navigationController pushViewController:countryController animated:YES];
}

- (IBAction)textFieldDidChange:(BLTextField *)textField {
    
    if (textField.text.length > 20) {
        
        textField.text = self.prePasswordFieldTitle;
    }
    self.prePasswordFieldTitle = self.textFieldPassword.text;
    
    if ( self.textFieldZone.text.length > 0) {
        
        if ( self.textFieldPhone.text.length > 0 && textField.text.length > 0 ) {
            
            [self.btnLogin setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0x5d0e86)] forState:UIControlStateNormal];
            [self.btnLogin setBackgroundImage:[self imageWithColor:Color(80, 17, 121, 0.7)] forState:UIControlStateHighlighted];
            
            self.btnLogin.userInteractionEnabled = YES;
        }else{
            [self.btnLogin setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)] forState:UIControlStateNormal];
            self.btnLogin.userInteractionEnabled = NO;
        }
    }
    
}


- (IBAction)phoneTextFieldChange:(BLTextField *)sender {
    
    if ( self.textFieldZone.text.length > 0) {
        
        if ( sender.text.length > 0 && self.textFieldPassword.text.length > 0 ) {
            
            [self.btnLogin setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0x5d0e86)] forState:UIControlStateNormal];
            [self.btnLogin setBackgroundImage:[self imageWithColor:Color(80, 17, 121, 0.7)] forState:UIControlStateHighlighted];
            
            self.btnLogin.userInteractionEnabled = YES;
        }else{
            [self.btnLogin setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)] forState:UIControlStateNormal];
            self.btnLogin.userInteractionEnabled = NO;
        }
    }
}

- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllInputView)];
        self.singleTap.delegate = self;
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if( self.singleTap ) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[TTTAttributedLabel class]]){
        TTTAttributedLabel *label = (TTTAttributedLabel *)touch.view;
        if ([label containslinkAtPoint:[touch locationInView:label]]){
            return NO;
        }else{
            return YES;
        }
    }else{
        return YES;
    }
}

#pragma mark - SelectCountryControllerDelegate
- (void)sendCounty:(Country *)items{

    self.countryNameLabel.text = items.fullName;
    NSString *areCodeStr = [NSString stringWithFormat:@"+%@",items.zipCode];
    
    if ( areCodeStr.length > 4 ) {
        self.textFieldZone.textAlignment = NSTextAlignmentRight;
    }else{
        self.textFieldZone.textAlignment = NSTextAlignmentCenter;
    }
    self.textFieldZone.text = areCodeStr;
    
    if ( areCodeStr.length > 0) {
        
        if ( self.textFieldPhone.text.length > 0 && self.textFieldPassword.text.length > 0 ) {
            
            [self.btnLogin setBackgroundColor:COLOR_WITH_16BAND_RGB(0x5d0e86)];
            self.btnLogin.userInteractionEnabled = YES;
        }else{
            [self.btnLogin setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
            self.btnLogin.userInteractionEnabled = NO;
        }
    }
}

#pragma mark - 界面事件
- (IBAction)selectCountryAction:(id)sender {
    

}

- (IBAction)loginAction:(id)sender {
    [self closeAllInputView];
    
    NSString *tipsEmail = NSLocalizedStringFromSelf(@"Tips_RegisterMessage_Email");
    NSString *tipsPassword = NSLocalizedStringFromSelf(@"Tips_RegisterMessage_Password");
    
    bool bFlag = YES;
    
    if ( bFlag && self.textFieldPhone.text.length == 0 ) {
        [self popUpPromptWithString:tipsEmail];
        bFlag = NO;
    }
    
    if ( bFlag && self.textFieldPassword.text.length == 0) {
        [self popUpPromptWithString:tipsPassword];
        bFlag = NO;
    }
    
//    if( bFlag && [self.loginManager login:self.textFieldPhone.text password:self.textFieldPassword.text areano:self.textFieldZone.text] == LOGINING ) {
//        // 显示菊花
//        [self showLoading];
//    }
    
    if( bFlag && self.loginManager.status == LOGINED ) {
        // 已经登陆
        // 收起菊花
        [self hideLoading];
        
        KKNavigationController *nvc = (KKNavigationController* )self.navigationController;
        [nvc dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)popUpPromptWithString:(NSString*)tipStr {
    
}

- (void)closeAllInputView {
    [self.textFieldZone resignFirstResponder];
    [self.textFieldPhone resignFirstResponder];
    [self.textFieldPassword resignFirstResponder];
}

//  颜色转换为背景图片
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 输入回调
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL bFlag = YES;
    
    if( textField == self.textFieldCountry || textField == self.textFieldZone ) {
        bFlag = NO;
        
        // 点击国家 或者区号
        [self selectCountryAction:textField];
        
    }
    
    return bFlag;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == self.textFieldPhone ) {
        [self.textFieldPassword becomeFirstResponder];
        
    } else if( textField == self.textFieldPassword ) {
        [self closeAllInputView];
    }

    return YES;
}

#pragma mark - 点击超链接回调
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    if( [[url absoluteString] isEqualToString:FORGOT_PASSWORD_URL] ) {
        // 点击忘记密码
        ForgotPasswordController *forgotController = [[ForgotPasswordController alloc]init];
        [self.navigationController pushViewController:forgotController animated:YES];
    }
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    // Ensures that all pending layout operations have been completed
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:duration animations:^{
        // Make all constraint changes here, Called on parent view
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

#pragma mark - 登陆管理器回调 (LoginManagerDelegate)
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSInteger)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LoginViewController::onLogin( [%@], errnum : %ld )", success?@"Success":@"Fail", (long)errnum);
        // 收起菊花
        [self hideLoading];
        
        if( success ) {
            // 登录成功
            KKNavigationController *nvc = (KKNavigationController* )self.navigationController;
            [nvc dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            // 登陆失败
            
            // 弹出提示
            if( errmsg.length > 0 ) {
                [self popUpPromptWithString:errmsg];
            }
        }
    });
}

- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)kick {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LoginViewController::onLogout( [%@] )", kick?@"手动注销/被踢":@"Session超时");
    });
}

@end
