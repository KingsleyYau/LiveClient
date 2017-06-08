//
//  ForgotPasswordController.m
//  livestream
//
//  Created by randy on 17/5/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ForgotPasswordController.h"
#import "SelectCountryController.h"
#import "Country.h"
#import "LoginManager.h"

@interface ForgotPasswordController ()<SelectCountryControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation ForgotPasswordController

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.navigationTitle = NSLocalizedString(@"Forgot Password", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
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
    
    self.countryNameLabel.text = [LoginManager manager].fullName;
    self.textFieldZone.text = [NSString stringWithFormat:@"+%@",[LoginManager manager].zipCode];
}

- (void)selectCountryWithController{
    SelectCountryController *countryController = [[SelectCountryController alloc]init];
    countryController.delegate = self;
    [self.navigationController pushViewController:countryController animated:YES];
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

- (void)closeAllInputView {
    [self.textFieldZone resignFirstResponder];
    [self.textFieldPhone resignFirstResponder];
}

#pragma mark - 输入回调
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == self.textFieldPhone ) {
        [self closeAllInputView];
    }
    
    return YES;
}

- (IBAction)forgorNext:(id)sender {
    
    
}

- (IBAction)textFieldDidChange:(BLTextField *)textField {
    
    if (self.textFieldZone.text.length > 0) {
        
        if (textField.text.length > 0) {
            
            [self.btnNext setBackgroundColor:COLOR_WITH_16BAND_RGB(0x5d0e86)];
            self.btnNext.userInteractionEnabled = YES;
        }else{
            [self.btnNext setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
            self.btnNext.userInteractionEnabled = NO;
        }
    }
}


#pragma mark - SelectCountryControllerDelegate
- (void)sendCounty:(Country *)items {
    self.countryNameLabel.text = items.fullName;
    
    NSString *areCodeStr = [NSString stringWithFormat:@"+%@",items.zipCode];
    
    if ( areCodeStr.length > 4 ) {
        self.textFieldZone.textAlignment = NSTextAlignmentRight;
    }else{
        self.textFieldZone.textAlignment = NSTextAlignmentCenter;
    }
    
    self.textFieldZone.text = areCodeStr;
    
    if ( areCodeStr.length > 0 ) {
        if ( self.textFieldPhone.text.length > 0 ) {
            
            [self.btnNext setBackgroundColor:COLOR_WITH_16BAND_RGB(0x5d0e86)];
            self.btnNext.userInteractionEnabled = YES;
        }else{
            [self.btnNext setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
            self.btnNext.userInteractionEnabled = NO;
        }
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

@end
