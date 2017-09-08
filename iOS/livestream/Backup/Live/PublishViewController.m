//
//  PublishViewController.m
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PublishViewController.h"
#import "PublishEndViewController.h"

#import "LiveViewController.h"

#import "LiveStreamPublisher.h"

#import "CloseLiveRoomRequest.h"
#import "CheckLiveRoomRequest.h"

#import "PlayEndViewController.h"

#import "FileCacheManager.h"

@interface PublishViewController () <UITextFieldDelegate, KKCheckButtonDelegate,IMLiveRoomManagerDelegate>

/**
 推流组件
 */
@property (strong) LiveStreamPublisher* publisher;

/**
 显示界面
 */
@property (strong) LiveViewController* liveVC;

/**
 直播结束界面
 */
@property (strong) PublishEndViewController* publishEndVC;

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@property (strong) KKButtonBar* buttonBar;

/**
 *  多功能按钮约束
 */
@property (strong) MASConstraint* buttonBarBottom;

@end

@implementation PublishViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
//    self.url = @"rtmp://172.25.32.17/live/livestream";
    self.url = @"rtmp://172.25.32.17/live/max";
    
    self.sessionManager = [SessionRequestManager manager];
    
    // 添加直播间监听代理
    [[IMManager manager].client addDelegate:self];
    
    self.liveVC = [[LiveViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.liveVC];
}

- (void)dealloc {
    
    // 移除直播间监听代理
    [[IMManager manager].client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self.view addSubview:self.liveVC.view];
    [self.view sendSubviewToBack:self.liveVC.view];
    [self.liveVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
    }];
    
//    [self.liveVC.view removeConstraint:self.liveVC.msgTableViewBottom];
    [self.liveVC.tableSuperView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputMessageView.mas_top);
    }];

    // 初始化推流
    self.publisher = [LiveStreamPublisher instance];
    self.publisher.publishView = self.liveVC.videoView;
    self.publisher.beauty = YES;
    
    [self.inputTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    
    // 加载主播头像
//    [self.liveVC reloadLiverUserHeader:[LoginManager manager].loginItem.photoUrl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 关闭输入
    [self closeAllInputView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 添加手势
    [self addSingleTap];
    
    // 开始推流
    [self publish];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    // 去除手势
    [self removeSingleTap];
    
    // 停止推流
    [self stop];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupButtonBar];
    
    // 初始化输入框
    [self setupInputMessageView];

}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if (textField.text.length > 0) {
        
        self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0x0CEDF5);
        self.btnSend.userInteractionEnabled = YES;
    }else{
        self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
        self.btnSend.userInteractionEnabled = NO;
    }
}

#pragma mark - 直播间信息
- (NSString *)roomId {
    return self.liveVC.roomId;
}

- (void)setRoomId:(NSString *)roomId {
    self.liveVC.roomId = roomId;
}

#pragma mark - 数据逻辑
- (void)publish {
    //    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* recordH264FilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"publish.h264"];
    NSString* recordAACFilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"publish.aac"];
    
    // 开始转菊花
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bFlag = [self.publisher pushlishUrl:self.url recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 停止菊花
            if( bFlag ) {
                // 发布成功
                
            } else {
                // 发布失败
            }
        });
    });
}

- (void)stop {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.publisher stop];
    });
}

#pragma mark - 界面事件
- (IBAction)chatAction:(id)sender {
    if ( [self.inputTextField canBecomeFirstResponder] ) {
        [self.inputTextField becomeFirstResponder];
    }
}

- (IBAction)sendAction:(id)sender {
    if( [self.liveVC sendMsg:self.inputTextField.text isLounder:self.btnLouder.selected] ) {
        self.inputTextField.text = nil;
        
        if (self.inputTextField.text.length > 0) {
            
            self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0x0CEDF5);
            self.btnSend.userInteractionEnabled = YES;
        }else{
            self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
            self.btnSend.userInteractionEnabled = NO;
        }
    }
}

- (IBAction)beautyChangeAction:(id)sender {
    self.publisher.beauty = !self.publisher.beauty;
}

- (IBAction)cameraChangeAction:(id)sender {
    [self.publisher rotateCamera];
}

- (IBAction)giftAction:(id)sender {
    
}

- (IBAction)cancelAction:(id)sender {
    // 弹出确认窗
    [self showExitActionView];
}

- (void)closeAllInputView {
    [self.inputTextField resignFirstResponder];
}

#pragma mark - 文本和表情输入控件管理
- (void)setupInputMessageView {
    self.inputBackgroundView.layer.cornerRadius = self.inputBackgroundView.frame.size.height / 2;
    
    [self.btnLouder setImage:[UIImage imageNamed:@"Live_Input_Btn_Louder_Selected"] forState:UIControlStateSelected];
    [self.btnChat setImage:[UIImage imageNamed:@"Live_Publish_Btn_Chat_Highlighted"] forState:UIControlStateHighlighted];
    [self.btnShare setImage:[UIImage imageNamed:@"Live_Publish_Btn_Share_Highlighted"] forState:UIControlStateHighlighted];
    [self.btnConfig setImage:[UIImage imageNamed:@"Live_Publish_Btn_Config_Selected"] forState:UIControlStateSelected];
    
    self.btnSend.layer.cornerRadius = self.btnSend.frame.size.height / 2;
    UIEdgeInsets titleInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.btnSend setTitleEdgeInsets:titleInset];
    
    self.inputTextField.bottomLine.hidden = YES;
    self.inputTextField.font = PlaceholderFont;
    
    [self changePlaceholder:NO];
    
    [self showInputMessageView];
    
    [self.view bringSubviewToFront:self.inputMessageView];
}

- (void)showInputMessageView {
    self.btnChat.hidden = NO;
    self.btnChatWidth.constant = 40;
    self.btnShare.hidden = NO;
    self.btnShareWidth.constant = 40;
    self.btnConfig.hidden = NO;
    self.btnConfigWidth.constant = 40;
    self.inputBackgroundView.hidden = YES;
    self.btnSend.hidden = YES;
    self.btnSendWidth.constant = 0;
}

- (void)hideInputMessageView {
    self.btnChat.hidden = YES;
    self.btnChatWidth.constant = 0;
    self.btnShare.hidden = YES;
    self.btnShareWidth.constant = 0;
    self.btnConfig.hidden = YES;
    self.btnConfigWidth.constant = 0;
    self.inputBackgroundView.hidden = NO;
    self.btnSend.hidden = NO;
    self.btnSendWidth.constant = 65;

}

- (void)changePlaceholder:(BOOL)louder {
    UIFont* font = PlaceholderFont;
    UIColor* color = [UIColor whiteColor];
    
    if( louder ) {
        // 切换成弹幕
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"INPUT_LOUDER_PLACEHOLDER")];
        [attributeString addAttributes:@{
                                         NSFontAttributeName : font,
                                         NSForegroundColorAttributeName:color
                                         }
                                 range:NSMakeRange(0, attributeString.length)
         ];
        self.inputTextField.attributedPlaceholder = attributeString;
        self.inputBackgroundColorView.backgroundColor = COLOR_WITH_16BAND_RGB(0xFFD205);
        
    } else {
        // 切换成功普通
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"INPUT_PLACEHOLDER")];
        [attributeString addAttributes:@{
                                         NSFontAttributeName : font,
                                         NSForegroundColorAttributeName:color
                                         }
                                 range:NSMakeRange(0, attributeString.length)
         ];
        self.inputTextField.attributedPlaceholder = attributeString;
        self.inputBackgroundColorView.backgroundColor = COLOR_WITH_16BAND_RGB(0xFFFFFF);
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

#pragma mark - 多功能按钮管理
- (void)setupButtonBar {
    self.buttonBar = [[KKButtonBar alloc] init];
    [self.view addSubview:self.buttonBar];
    [self.buttonBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        make.left.equalTo(self.btnConfig.mas_left);
        make.right.equalTo(self.btnConfig.mas_right);
        self.buttonBarBottom = make.bottom.equalTo(self.inputMessageView.mas_bottom).offset(-6);
    }];
    
    self.buttonBar.isVertical = YES;
    
    NSMutableArray* items = [NSMutableArray array];
    
    UIButton* btnBeauty = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBeauty setImage:[UIImage imageNamed:@"Live_Publish_Btn_Beauty" ] forState:UIControlStateNormal];
    [btnBeauty setImage:[UIImage imageNamed:@"Live_Publish_Btn_Beauty_Highlighted" ] forState:UIControlStateHighlighted];
    [btnBeauty addTarget:self action:@selector(beautyChangeAction:) forControlEvents:UIControlEventTouchUpInside];
    [items addObject:btnBeauty];
    
    UIButton* btnFlash = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnFlash setImage:[UIImage imageNamed:@"Live_Publish_Btn_Flash" ] forState:UIControlStateNormal];
    [btnFlash setImage:[UIImage imageNamed:@"Live_Publish_Btn_Flash_Highlighted" ] forState:UIControlStateHighlighted];
    [items addObject:btnFlash];
    
    UIButton* btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCamera setImage:[UIImage imageNamed:@"Live_Publish_Btn_Camera" ] forState:UIControlStateNormal];
    [btnCamera setImage:[UIImage imageNamed:@"Live_Publish_Btn_Camera_Highlighted" ] forState:UIControlStateHighlighted];
    [btnCamera addTarget:self action:@selector(cameraChangeAction:) forControlEvents:UIControlEventTouchUpInside];
    [items addObject:btnCamera];
    
    self.buttonBar.items = items;
    [self.buttonBar reloadData:YES];
}

- (void)showButtonBar {
    [self.buttonBarBottom uninstall];
    
    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@180);
        self.buttonBarBottom = make.bottom.equalTo(self.inputMessageView.mas_top);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        // Make all constraint changes here, Called on parent view
        [self.view layoutIfNeeded];
        
        self.buttonBar.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideButtonBar {
    [self.buttonBarBottom uninstall];
    
    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        self.buttonBarBottom = make.bottom.equalTo(self.inputMessageView.mas_bottom).offset(-6);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        // Make all constraint changes here, Called on parent view
        [self.view layoutIfNeeded];
        
        self.buttonBar.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 选择按钮回调
- (void)selectedChanged:(id)sender {
    if( sender == self.btnLouder ) {
        [self changePlaceholder:self.btnLouder.selected];
    } else if( sender == self.btnConfig ) {
        if( self.btnConfig.selected ) {
            [self showButtonBar];
        } else {
            [self hideButtonBar];
        }
    }
}

#pragma mark - 文本输入回调
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    bool bFlag = YES;
    
    NSString *wholeString = textField.text;
    NSInteger wholeStringLength = wholeString.length - range.length + string.length;
    if( wholeStringLength >= MaxInputCount ) {
        // 超过字符限制
        bFlag = NO;
    }
    
    return bFlag;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    bool bFlag = NO;
    
    if( self.inputTextField.text.length > 0 ) {
        if( [self.liveVC sendMsg:textField.text isLounder:self.btnLouder.selected] ) {
            self.inputTextField.text = nil;
        }
        
        bFlag = YES;
    }
    
    return bFlag;
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    BOOL bFlag = NO;
    
    // Ensures that all pending layout operations have been completed
    [self.view layoutIfNeeded];
    
    if( height != 0 ) {
        // 弹出键盘
        self.inputMessageViewBottom.constant = -height;
        bFlag = YES;
        
    } else {
        // 收起键盘
        self.inputMessageViewBottom.constant = -5;
    }
    
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
    
    // 动画打开键盘
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
    
    // 改变控件状态
    [self hideInputMessageView];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // 动画收起键盘
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
    
    // 改变控件状态
    [self showInputMessageView];
}

#pragma mark - 退出按钮弹出式对话框
- (void)showExitActionView {
    // 关闭输入
    [self closeAllInputView];
    
    UIAlertController* exitAlertView = [UIAlertController alertControllerWithTitle:nil
                                                             message:NSLocalizedStringFromSelf(@"Are you sure you wish to end this live stream?")
                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = nil;
    // 取消
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [exitAlertView addAction:action];
    
    // 确认退出
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 发送结束直播请求
        [self endPublish];

    }];
    [exitAlertView addAction:action];
    
    [self presentViewController:exitAlertView animated:YES completion:nil];
}

#pragma mark - IM回调
- (void)onRecvRoomCloseBroad:(NSString *)roomId fansNum:(int)fansNum income:(int)income newFans:(int)newFans shares:(int)shares duration:(int)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 关闭输入
        [self closeAllInputView];
        
        // 弹出结束直播界面
        [self showPublishEndViewController:fansNum income:income newFans:newFans shares:shares duration:duration];
    });

}

#pragma mark - 结束直播控制
- (void)endPublish {
    // 开始菊花
    [self showLoading];
    
    CloseLiveRoomRequest* request = [[CloseLiveRoomRequest alloc] init];
    request.roomId = self.roomId;

    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 隐藏菊花
            [self hideLoading];

            // 弹出结束直播界面
            [self showPublishEndViewController:0 income:0 newFans:0 shares:0 duration:0];
        });
    };
    
    [self.sessionManager sendRequest:request];
}

- (void)showPublishEndViewController:(int)fansNum income:(int)income newFans:(int)newFans shares:(int)shares duration:(int)duration {
    if( self.publishEndVC == nil ) {
        // 只能出现一次
        self.publishEndVC = [[PublishEndViewController alloc] initWithNibName:nil bundle:nil];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"HH:MM:ss"];
        NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%d", duration]];
        NSString *time = [formatter stringFromDate:date];
        
        self.publishEndVC.viewerNumLabel.text = [NSString stringWithFormat:@"%d", fansNum];
        self.publishEndVC.diamondNumLabel.text = [NSString stringWithFormat:@"%d", income];
        self.publishEndVC.fanNewNumLabel.text = [NSString stringWithFormat:@"%d", newFans];
        self.publishEndVC.shareNumLabel.text = [NSString stringWithFormat:@"%d", shares];
        [self.publishEndVC.timeLabel setText:time];
        
        [self.view addSubview:self.publishEndVC.view];
        [self.publishEndVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(self.view);
        }];
        [self addChildViewController:self.publishEndVC];
        
        self.publishEndVC.view.alpha = 0;
        NSTimeInterval duration = 0.5;
        [UIView animateWithDuration:duration animations:^{
            self.publishEndVC.view.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - 获取直播间信息
- (void)loadRoomInfo {
    // 开始菊花
    [self showLoading];
    
    CheckLiveRoomRequest* request = [[CheckLiveRoomRequest alloc] init];
    
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, NSString * _Nonnull roomurl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 隐藏菊花
            [self hideLoading];
            
            if( success ) {
                // 重新发布流
                self.roomId = roomId;
                self.url = roomurl;
                
                [self publish];
                
            } else {
                // 获取失败, 结束直播
                [self endPublish];
                
            }

        });
    };
    
    [self.sessionManager sendRequest:request];
}

@end
