//
//  RegisterPhoneViewController.m
//  livestream
//
//  Created by Max on 2017/5/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RegisterPhoneViewController.h"
#import "LoginPhoneViewController.h"
#import "VerifyPhoneViewController.h"
#import "RequestManager.h"
#import "SelectCountryController.h"
#import "Country.h"
#import "LoginManager.h"
#import "PromptView.h"

@interface RegisterPhoneViewController ()<SelectCountryControllerDelegate,PromptViewDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) RequestManager *manager;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnNextHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnNextWidth;

@property (nonatomic, strong) PromptView *promptView;

@end

@implementation RegisterPhoneViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.navigationTitle = NSLocalizedString(@"Sign up with Phone Number", nil);
    self.manager = [RequestManager manager];
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
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
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

- (IBAction)nextAction:(id)sender {
    [self closeAllInputView];
    
    // 判断是否已注册
    [self registerFinishHandler];

}


- (void)closeAllInputView {
    [self.textFieldPhone resignFirstResponder];
}

#pragma mark - 判断是否已注册
- (void)registerFinishHandler {
    __weak typeof(self) weakSelf = self;
    [self.manager registerCheckPhone:self.textFieldPhone.text areno:self.textFieldZone.text finishHandler:
     ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, int isRegistered) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (success) {
                 if (isRegistered) {
                     
                     // 弹出提示框
                     [weakSelf.promptView promptViewShow];
                     
                 } else {
                     
                     VerifyPhoneViewController* vc = [[VerifyPhoneViewController alloc] initWithNibName:nil bundle:nil phoneNumber:self.textFieldPhone.text areno:self.textFieldZone.text];
                     [weakSelf.navigationController pushViewController:vc animated:YES];
                 }
             } else {
                 NSLog(@"错误码：%ld 提示：%@", (long)errnum, errmsg);
             }
         });
    }];
}

- (void)addTipsPopup {
    NSString *tipsRegistered = NSLocalizedStringFromSelf(@"This account has already been registered");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:tipsRegistered
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Log in" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        
    LoginPhoneViewController* vc = [[LoginPhoneViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    
    self.countryLabel.text = [LoginManager manager].fullName;
    self.textFieldZone.text = [NSString stringWithFormat:@"+%@",[LoginManager manager].zipCode];
    
    CGRect rect = CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.promptView = [[PromptView alloc]initWithFrame:rect];
    self.promptView.promptDelegate = self;
    
    [self.btnNext setTitleColor:Color(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
}

- (void)selectCountryWithController{
    SelectCountryController *countryController = [[SelectCountryController alloc]init];
    countryController.delegate = self;
    [self.navigationController pushViewController:countryController animated:YES];
}

- (IBAction)textFieldDidChange:(BLTextField *)textField {
    
    if (self.textFieldZone.text.length > 0) {
        
        if (textField.text.length > 0) {
            
            [self.btnNext setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0x5d0e86)] forState:UIControlStateNormal];
            [self.btnNext setBackgroundImage:[self imageWithColor:Color(80, 17, 121, 0.7)] forState:UIControlStateHighlighted];
            
            self.btnNext.userInteractionEnabled = YES;
        }else{
            [self.btnNext setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)] forState:UIControlStateNormal];
            self.btnNext.userInteractionEnabled = NO;
        }
    }
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
    
    if( textField == self.textFieldCountry || textField == self.textFieldZone ) {
        bFlag = NO;
    
    }
    
    return bFlag;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == self.textFieldPhone ) {
        [self closeAllInputView];
    }
    
    return YES;
}

#pragma mark - SelectCountryControllerDelegate
- (void)sendCounty:(Country *)items {
    self.countryLabel.text = items.fullName;
    
    NSString *areCodeStr = [NSString stringWithFormat:@"+%@",items.zipCode];
    
    if ( areCodeStr.length > 4 ) {
        self.textFieldZone.textAlignment = NSTextAlignmentRight;
    }else{
        self.textFieldZone.textAlignment = NSTextAlignmentCenter;
    }
    
    self.textFieldZone.text = areCodeStr;
    
    if ( areCodeStr.length > 0 ) {
        if ( self.textFieldPhone.text.length > 0 ) {
            
            [self.btnNext setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0x5d0e86)] forState:UIControlStateNormal];
            [self.btnNext setBackgroundImage:[self imageWithColor:Color(80, 17, 121, 0.7)] forState:UIControlStateHighlighted];
            
            self.btnNext.userInteractionEnabled = YES;
        }else{
            [self.btnNext setBackgroundImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)] forState:UIControlStateNormal];
            self.btnNext.userInteractionEnabled = NO;
        }
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

#pragma mark - PromptViewDelegate
- (void)pushToLogin{
    
    [self.promptView cancelPrompt];
    LoginPhoneViewController* vc = [[LoginPhoneViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
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
