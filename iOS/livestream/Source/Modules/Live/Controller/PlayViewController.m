//
//  PlayViewController.m
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PlayViewController.h"

#import "LiveViewController.h"
#import "PlayEndViewController.h"

#import "LiveStreamPlayer.h"

#import "FileCacheManager.h"

#import "LikeView.h"

@interface PlayViewController () <UITextFieldDelegate, KKCheckButtonDelegate,IMLiveRoomManagerDelegate>
/**
 拉流地址
 */
@property (nonatomic, strong) NSString* url;

/**
 推流组件
 */
@property (strong) LiveStreamPlayer* player;

/**
 显示界面
 */
@property (strong) LiveViewController* liveVC;

/**
 直播结束界面(观众)
 */
@property (strong) PlayEndViewController* playEndVC;

@end

@implementation PlayViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.url = @"rtmp://172.25.32.17/live/livestream";
    
    self.liveVC = [[LiveViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.liveVC];
    
    // 添加直播间监听代理
    [[IMManager manager].client addDelegate:self];
}

- (void)dealloc {
    // 添加直播间监听代理
    [[IMManager manager].client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self.view addSubview:self.liveVC.view];
    [self.liveVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
    }];
    
    [self.liveVC.view removeConstraint:self.liveVC.msgTableViewBottom];
    [self.liveVC.msgTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputMessageView.mas_top);
    }];
    
    // 初始化推流
    self.player = [LiveStreamPlayer instance];
    self.player.playView = self.liveVC.videoView;
    
    [self.view sendSubviewToBack:self.liveVC.view];
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
    [self play];
    
    // 发送IM进入命令
    [self sendEnterRequest];
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

- (void)setupContainView {
    [super setupContainView];
    
    // 初始化主播信息控件
    [self setupRoomView];
    
    // 初始化输入框
    [self setupInputMessageView];
    
    // 初始化退出
    [self.liveVC.btnCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 直播间信息
- (void)setLiveInfo:(LiveRoomInfoItemObject *)liveInfo {
    _liveInfo = liveInfo;
    self.liveVC.roomId = _liveInfo.roomId;
}

#pragma mark - 数据逻辑
- (void)play {
    NSString* cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* recordFilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.flv"];
    NSString* recordH264FilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.h264"];
    NSString* recordAACFilePath = @"";//[NSString stringWithFormat:@"%@/%@", cacheDir, @"play.aac"];
    
    // 开始转菊花
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bFlag = [self.player playUrl:self.url recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 停止菊花
            if( bFlag ) {
                // 播放成功
                
            } else {
                // 播放失败
            }
        });
    });
}

- (void)stop {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.player stop];
    });
}

- (void)sendEnterRequest {
    [self.liveVC.imManager.client fansRoomIn:self.liveVC.loginManager.loginItem.token roomId:self.liveVC.roomId];
}

- (void)sendExitRequest {
    [self.liveVC.imManager.client fansRoomout:self.liveVC.loginManager.loginItem.token roomId:self.liveVC.roomId];
}

#pragma mark - IMLiveRoomManagerDelegate(观众接收关闭直播间通知)
- (void)onRecvRoomCloseFans:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName fansNum:(int)fansNum {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 关闭输入
        [self closeAllInputView];
        
        // 显示直播结束界面
        [self showPlayEndViewWithLiverName:nickName andFansNum:fansNum];
    });
}

#pragma mark - 界面事件
- (IBAction)chatAction:(id)sender {
    if ( [self.inputTextField canBecomeFirstResponder] ) {
        [self.inputTextField becomeFirstResponder];
    }
}

- (IBAction)shareAction:(id)sender {

}

- (IBAction)giftAction:(id)sender {
    
}

- (IBAction)sendAction:(id)sender {
    if( [self.liveVC sendMsg:self.inputTextField.text isLounder:self.btnLouder.selected] ) {
        self.inputTextField.text = nil;
    }
}

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
    [self sendExitRequest];
}

- (void)closeAllInputView {
    [self.inputTextField resignFirstResponder];
}

#pragma mark - 主播信息控件管理
- (void)setupRoomView {
    self.liveVC.favourBtn.hidden = NO;
    [self.liveVC.favourBtn addTarget:self action:@selector(favourAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)favourAction:(id)sender {
    
}

#pragma mark - 点赞控件管理
- (void)showLike {
    NSInteger width = 36;
    LikeView* heart = [[LikeView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
    [self.view addSubview:heart];
    
    // 起始位置
    CGPoint fountainSource = CGPointMake(self.view.bounds.size.width - 20 - width/2.0, self.view.bounds.size.height - width /2.0 - 20);
    heart.center = fountainSource;
    
    // 生成图片
    int randomNum = arc4random_uniform(5);
    NSString *imageName = [NSString stringWithFormat:@"like_%d", randomNum];
    
    // 礼物
    UIImageView *likeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [heart setupImage:likeImageView];
    
    if ( randomNum != 4 ) {
        // 心心
        [heart setupShakeAnimation:likeImageView];
        [heart setupHeatBeatAnim:likeImageView];
    }
    
    // 显示
    [heart addSubview:likeImageView];
    [heart animateInView:self.view];
}

#pragma mark - 文本和表情输入控件管理
- (void)setupInputMessageView {
    self.inputBackgroundView.layer.cornerRadius = self.inputBackgroundView.frame.size.height / 2;
    [self.btnLouder setImage:[UIImage imageNamed:@"Live_Input_Btn_Louder_Highlighted"] forState:UIControlStateSelected];
    
    [self.btnChat setImage:[UIImage imageNamed:@"Live_Publish_Btn_Chat_Highlighted"] forState:UIControlStateHighlighted];
    [self.btnShare setImage:[UIImage imageNamed:@"Live_Publish_Btn_Share_Highlighted"] forState:UIControlStateHighlighted];
    
    self.btnSend.layer.cornerRadius = self.btnSend.frame.size.height / 2;
    UIEdgeInsets titleInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.btnSend setTitleEdgeInsets:titleInset];
    
    self.inputTextField.bottomLine.hidden = YES;
    self.inputTextField.font = PlaceholderFont;
    
    [self changePlaceholder:NO];
    
    [self showInputMessageView];
}

- (void)showInputMessageView {
    self.btnChat.hidden = NO;
    self.btnChatWidth.constant = 40;
    self.btnShare.hidden = NO;
    self.btnShareWidth.constant = 40;
    self.btnGift.hidden = NO;
    self.btnGiftWidth.constant = 40;
    self.inputBackgroundView.hidden = YES;
    self.btnSend.hidden = YES;
    self.btnSendWidth.constant = 0;
    
}

- (void)hideInputMessageView {
    self.btnChat.hidden = YES;
    self.btnChatWidth.constant = 0;
    self.btnShare.hidden = YES;
    self.btnShareWidth.constant = 0;
    self.btnGift.hidden = YES;
    self.btnGiftWidth.constant = 0;
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

#pragma mark - 单击屏幕
- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if( self.singleTap ) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}

- (void)singleTapAction {
    [self showLike];
    [self closeAllInputView];
}

#pragma mark - 选择按钮回调
- (void)selectedChanged:(id)sender {
    if( sender == self.btnLouder ) {
        [self changePlaceholder:self.btnLouder.selected];
    }
}

#pragma mark - 文本输入回调
- (void)textViewDidChange:(UITextView *)textView {
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    BOOL bFlag = YES;
    return bFlag;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL bFlag = YES;
    
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length - 1, textView.text.length)];
    
    return bFlag;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
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

#pragma mark - 结束直播界面
- (void)showPlayEndViewWithLiverName:(NSString *)nickName andFansNum:(int)fansNum {
    if( self.playEndVC == nil ) {
        // 只能出现一次
        self.playEndVC = [[PlayEndViewController alloc] initWithNibName:nil bundle:nil];
        
        self.playEndVC.liverNameLabel.text = nickName;
        self.playEndVC.viewverLabel.text = [NSString stringWithFormat:@"%d",fansNum];
        
        self.playEndVC.imageViewHeaderLoader = [ImageViewLoader loader];
        self.playEndVC.imageViewHeaderLoader.sdWebImageView = self.playEndVC.imageViewHeader;
        self.playEndVC.imageViewHeaderLoader.url = self.liveInfo.photoUrl;
//        self.playEndVC.imageViewHeaderLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.playEndVC.imageViewHeaderLoader.url];
        [self.playEndVC.imageViewHeaderLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
        
        
        [self.view addSubview:self.playEndVC.view];
        [self.playEndVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(self.view);
        }];
        [self addChildViewController:self.playEndVC];
        
        self.playEndVC.view.alpha = 0;
        NSTimeInterval duration = 0.5;
        [UIView animateWithDuration:duration animations:^{
            self.playEndVC.view.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

@end
