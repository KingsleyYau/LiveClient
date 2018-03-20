//
//  VerifyPhoneViewController.m
//  livestream
//
//  Created by Max on 2017/5/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "VerifyPhoneViewController.h"
#import "RequestManager.h"
#import "LoginManager.h"

#define Time_Count 60

@interface VerifyPhoneViewController ()<LoginManagerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) RequestManager *manager;

@property (nonatomic, strong) LoginManager *loginManager;

@property (nonatomic, strong) NSString *prePasswordFieldTitle;

@property (nonatomic, copy) NSString *phoneNumber;

@property (nonatomic, copy) NSString *areno;

@property (nonatomic, strong) UILabel *timerLabel;

@property (nonatomic, assign) NSInteger timeCount;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation VerifyPhoneViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.navigationTitle = NSLocalizedString(@"Verification", nil);
    
    self.manager = [RequestManager manager];
    
    self.loginManager = [LoginManager manager];
    [self.loginManager addDelegate:self];
}

- (void)dealloc{

    [self.loginManager removeDelegate:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil phoneNumber:(NSString *)phoneNumber areno:(NSString *)areno {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        self.phoneNumber = phoneNumber;
        self.areno = areno;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // 获取验证码
    [self sendRegisterCode];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self.sendButton removeObserver:self forKeyPath:@"highlighted"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addSingleTap];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeSingleTap];
    // 关闭输入
    [self closeAllInputView];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
}

- (void)setupContainView {
    [super setupContainView];
    [self setupInputView];
}

#pragma mark - 界面事件
- (IBAction)checkCodeAction:(id)sender {
    
}

- (IBAction)signUpAction:(id)sender {
    [self closeAllInputView];
    
    if (self.textFieldPassword.text.length < 6) {
        
        NSString *str = @"please enter at least 6 characters";
        [self popUpPromptWithString:str];
        
    }else{
        // 注册账号 成功自动登录
        [self signUpUserNumber];
    }
}

- (void)popUpPromptWithString:(NSString*)tipStr {
    
    [MBProgressHUD showMessageWithTitle:nil message:tipStr toView:self.view];
}

- (void)closeAllInputView {
    [self.textFieldCheckcode resignFirstResponder];
    [self.textFieldPassword resignFirstResponder];
}

#pragma mark - 注册账号 成功自动登录
- (void)signUpUserNumber{
//    [self.manager registerPhone:self.phoneNumber areno:self.areno checkcode:self.textFieldCheckcode.text password:self.textFieldPassword.text deviceid:[self.manager getDeviceId] model:[[UIDevice currentDevice] model] manufacturer:@"Apple" finishHandler:^(BOOL success, int errnum, NSString * _Nonnull errmsg) {
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (success) {
//                [self.loginManager login:self.phoneNumber password:self.textFieldPassword.text areano:self.areno];
//                
//            } else {
//                NSLog(@"错误码：%ld 信息:%@",(long)errnum,errmsg);
//                [self popUpPromptWithString:errmsg];
//            }
//            
//        });
//        
//    }];
}

#pragma mark - 登陆管理器回调 (LoginManagerDelegate)
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSInteger)errnum errmsg:(NSString *)errmsg{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LoginViewController::onLogin( success : %d )", success);
        
        if( success ) {
            // 登录成功
            KKNavigationController *nvc = (KKNavigationController* )self.navigationController;
            [nvc dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            // 登陆失败
            
            // 弹出提示
            if( errmsg.length > 0 ) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errmsg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
                [alertView show];
            }
            
            KKNavigationController *nvc = (KKNavigationController* )self.navigationController;
            [nvc dismissViewControllerAnimated:YES completion:nil];
        }
    });
    
}

#pragma mark - 输入控件
- (void)setupInputView {
    
    [self.sendButton setTitle:@"Resend" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:COLOR_WITH_16BAND_RGB(0xf45bae) forState:UIControlStateNormal];
    [self.sendButton setTitleColor:Color(244, 91, 174, 0.7) forState:UIControlStateHighlighted];
    [self.sendButton setBackgroundColor:[UIColor clearColor]];
    self.sendButton.layer.masksToBounds = YES;
    self.sendButton.layer.cornerRadius = 15/4;
    [self.sendButton.layer setBorderWidth:1];
    [self.sendButton.layer setBorderColor:[COLOR_WITH_16BAND_RGB(0xf45bae) CGColor]];
    [self.sendButton addTarget:self action:@selector(sendRegisterCode) forControlEvents:UIControlEventTouchUpInside];
    // kvo监听sendButton是否高亮
    [self.sendButton addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    self.timerLabel = [[UILabel alloc] init];
    // 默认的时候，显示计时的Label是隐藏的
    self.timerLabel.textColor = [UIColor whiteColor];
    self.timerLabel.font = [UIFont systemFontOfSize:14];
    [self.timerLabel setHidden:YES];
    [self.view addSubview:self.timerLabel];
    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.sendButton);
    }];
    
    self.labelPhoneNumber.text = [NSString stringWithFormat:@"%@ %@",self.areno,self.phoneNumber];
    
    [self.btnSignup setTitleColor:Color(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
}

// 限制密码长度
- (IBAction)textFieldDidChange:(BLTextField *)sender {
    
    if (sender.text.length > 20) {
        
        sender.text = self.prePasswordFieldTitle;
    }
    self.prePasswordFieldTitle = self.textFieldPassword.text;
    
    if (self.textFieldCheckcode.text.length > 0 ) {
        
        if (sender.text.length > 0) {
            [self.btnSignup setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0x5d0e86)] forState:UIControlStateNormal];
            [self.btnSignup setBackgroundImage:[self imageWithColor:Color(80, 17, 121, 0.7)] forState:UIControlStateHighlighted];
            
            self.btnSignup.userInteractionEnabled = YES;
        }else{
            [self.btnSignup setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)] forState:UIControlStateNormal];
            self.btnSignup.userInteractionEnabled = NO;
        }
    }
    
}

- (IBAction)codeTextFieldChange:(BLTextField *)sender {
    
    if (sender.text.length > 0 ) {
        
        if (self.textFieldPassword.text.length > 0) {
            [self.btnSignup setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0x5d0e86)] forState:UIControlStateNormal];
            [self.btnSignup setBackgroundImage:[self imageWithColor:Color(80, 17, 121, 0.7)] forState:UIControlStateHighlighted];
            
            self.btnSignup.userInteractionEnabled = YES;
        }else{
            [self.btnSignup setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)] forState:UIControlStateNormal];
            self.btnSignup.userInteractionEnabled = NO;
        }
        
    } else{
        [self.btnSignup setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)] forState:UIControlStateNormal];
        self.btnSignup.userInteractionEnabled = NO;
    }
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

// kvo监听sendButton是否高亮回调
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if([keyPath isEqualToString:@"highlighted"] && object == self.sendButton) {
        
        long isHighlighted = [change[@"new"] integerValue];
        
        if (isHighlighted) {
            
            [self.sendButton.layer setBorderColor:[Color(244, 91, 174, 0.7) CGColor]];
            
        }else{
            
            [self.sendButton.layer setBorderColor:[COLOR_WITH_16BAND_RGB(0xf45bae) CGColor]];
        }
        
    }
}

#pragma mark - 获取验证码验证码
- (void)sendRegisterCode {
    NSLog(@"按钮isHeight状态%d",self.sendButton.isHighlighted);
    //重新开始计时
    self.timeCount = Time_Count;
    [self setSendCodeBtnInTimer];
    [self.timer invalidate];
    self.timer = nil;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeTimeLabel) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantPast]];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    // 获取验证码
//    [self.manager registerGetSMSCode:self.phoneNumber areno:self.areno finishHandler:^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg) {
//        
//    }];
}

- (void)changeTimeLabel {
    self.timerLabel.text = [NSString stringWithFormat:@"%lds",(long)_timeCount];
    _timeCount -= 1;
    
    if (_timeCount < 0) {
        
        [self.timer invalidate]; // 关闭
        self.timer = nil;
        // 关闭之后，重设计数
        _timeCount = Time_Count;
        [self setSendCodeBtnNormal];
    }
}

#pragma mark - 设置发送验证码按钮的状态
- (void)setSendCodeBtnNormal {
    // 正常的状态
    [self.sendButton setUserInteractionEnabled:YES];// 可交互
    [self.sendButton setTitle:@"Resend" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:COLOR_WITH_16BAND_RGB(0xf45bae) forState:UIControlStateNormal];
    [self.sendButton setBackgroundColor:[UIColor clearColor]];
    [self.sendButton.layer setBorderWidth:1];
    [self.sendButton.layer setBorderColor:[COLOR_WITH_16BAND_RGB(0xf45bae) CGColor]];
    [self.timerLabel setHidden:YES];
    
    NSLog(@"按钮isHeight状态%d",self.sendButton.isHighlighted);
}

- (void)setSendCodeBtnInTimer {
    // 计时的状态
    [self.sendButton setTitle:@"" forState:UIControlStateNormal];
    [self.sendButton setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
    [self.sendButton.layer setBorderWidth:0];
    [self.sendButton setUserInteractionEnabled:NO];// 不可交互
    [self.timerLabel setHidden:NO];
    NSLog(@"按钮isHeight状态%d",self.sendButton.isHighlighted);
}

- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllInputView)];
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if( self.singleTap ) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}

#pragma mark - 输入回调
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL bFlag = YES;
    return bFlag;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == self.textFieldPassword ) {
        [self closeAllInputView];
    }
    
    return YES;
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

@end
