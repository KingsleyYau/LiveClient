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

#import "CountTimeButton.h"

#import "GetLiveRoomGiftListByUserIdRequest.h"
#import "LiveRoomGiftItemObject.h"

@interface PlayViewController () <UITextFieldDelegate, KKCheckButtonDelegate,IMLiveRoomManagerDelegate,
                                    UIGestureRecognizerDelegate,PresentViewDelegate,IMLiveRoomManagerDelegate>
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

#pragma mark - IM管理器
@property (nonatomic, strong) IMManager* imManager;

#pragma mark - 登录管理器
@property (nonatomic, strong) LoginManager* loginManager;

#pragma mark - 首次点赞
@property (nonatomic, assign) BOOL isFirstLike;

#pragma mark - 键盘弹出
@property (nonatomic, assign) BOOL isKeyboradShow;

#pragma mark - 首次点击
@property (nonatomic, assign) BOOL isFirstClick;

#pragma mark - 点击Id
@property (nonatomic, assign) int clickId;

#pragma mark - 发送连击Button
@property (nonatomic, strong) UIButton *comboBtn;

@property (nonatomic, strong) LiveRoomGiftItemObject *selectCellItem;

@property (nonatomic, assign) int countdownSender;
/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@end

static int giftNum;
static int totalGiftNum;
static int starNum;
static int endNum;

@implementation PlayViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    NSLog(@"PlayViewController::initCustomParam()");
    
//    self.url = @"rtmp://172.25.32.17/live/livestream";
//    self.url = @"rtmp://172.25.32.17/live/max";
    self.url = @"rtmp://172.25.32.17:1936/aac/max";
    
    self.liveVC = [[LiveViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.liveVC];
    
    // 添加直播间监听代理
    [[IMManager manager].client addDelegate:self];
    
    // 初始化管理器
    self.imManager = [IMManager manager];
    self.loginManager = [LoginManager manager];
    self.sessionManager = [SessionRequestManager manager];
    
    // 初始化控制变量
    self.isFirstLike = NO;
    self.isKeyboradShow = NO;
}

- (void)dealloc {
    NSLog(@"PlayViewController::dealloc()");
    
    // 添加直播间监听代理
    [[IMManager manager].client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 禁止导航栏后退手势
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
    
    // 初始化礼物列表界面
    self.presentView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH * 0.5 + 54);
    self.presentView.presentDelegate = self;
    
    // 初始化文本输入
    [self.inputTextField addTarget:self
                           action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
    
    // 发送请求到服务器
    [self sendEnterRequest];
    [self sendGetGiftListRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏导航栏
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    // 添加手势
    [self addSingleTap];
    
    // 开始播放
    [self play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
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
    // 停止推流
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.player stop];
    });
}

- (void)sendEnterRequest {
    NSLog(@"PlayViewController::sendEnterRequest( [发送粉丝进入直播间请求, roomId : %@ )", self.liveInfo.roomId);
    [self.liveVC.imManager.client fansRoomIn:self.liveVC.loginManager.loginItem.token roomId:self.liveInfo.roomId];
}

- (void)sendExitRequest {
    NSLog(@"PlayViewController::sendExitRequest( [发送粉丝退出直播间请求, roomId : %@ )", self.liveInfo.roomId);
    [self.liveVC.imManager.client fansRoomout:self.liveVC.loginManager.loginItem.token roomId:self.liveInfo.roomId];
}

- (void)sendRoomGiftFormLiveItem:(LiveRoomGiftItemObject *)item andGiftNum:(int)giftNum starNum:(int)starNum endNum:(int)endNum {
    NSLog(@"PlayViewController::sendRoomGiftFormLiveItem( "
          "[发送连击礼物请求], "
          "roomId : %@, giftId : %@, giftNum : %d, starNum : %d, endNum : %d "
          ")",
          self.liveInfo.roomId, item.giftId, giftNum, starNum, endNum);
    
    // 发送连击礼物请求
    [self.imManager.client sendRoomGift:self.liveInfo.roomId token:self.loginManager.loginItem.token nickName:self.loginManager.loginItem.nickName giftId:item.giftId giftName:item.name giftNum:giftNum multi_click:item.multi_click multi_click_start:starNum multi_click_end:endNum multi_click_id:self.clickId];
    
    // 本地展示连击礼物
    GiftItem *giftItem = [GiftItem item:self.liveInfo.roomId fromID:self.loginManager.loginItem.userId nickName:self.loginManager.loginItem.nickName giftID:item.giftId giftNum:giftNum multi_click:item.multi_click starNum:starNum endNum:endNum clickID:self.clickId];
    [self.liveVC addCombo:giftItem];
    
}

- (void)sendGetGiftListRequest {
    NSLog(@"PlayViewController::sendGetGiftListRequest( "
          "[发送获取礼物列表请求], "
          "roomId : %@ "
          ")",
          self.liveInfo.roomId);
    
    GetLiveRoomGiftListByUserIdRequest *request = [[GetLiveRoomGiftListByUserIdRequest alloc] init];
    request.roomId = _liveInfo.roomId;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<NSString *> * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"PlayViewController::sendGetGiftListRequest( "
                  "[发送获取礼物列表请求结果], "
                  "roomId : %@, "
                  "success : %s, "
                  "errnum : %d, "
                  "errmsg : %@ "
                  "array : %@ "
                  ")",
                  self.liveInfo.roomId,
                  success?"true":"false",
                  errnum,
                  errmsg,
                  array
                  );
            
            if (success) {
                if (array && array.count != 0) {
                    self.presentView.giftIdArray = array;
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - IM回调
- (void)onFansRoomIn:(BOOL)success reqId:(unsigned int)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl country:(NSString *)country videoUrls:(NSArray<NSString *> *)videoUrls fansNum:(int)fansNum contribute:(int)contribute fansList:(NSArray<RoomTopFanItemObject *> *)fansList {
    NSLog(@"PlayViewController::onFansRoomIn( [接收粉丝进入直播间回调], success : %s, errType : %d, errmsg : %@ )", success?"true":"false", errType, errmsg);

}

- (void)onRecvRoomCloseFans:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName fansNum:(int)fansNum {
    NSLog(@"PlayViewController::onRecvRoomCloseFans( [接收关闭直播间回调], roomId : %@, userId : %@, nickName : %@, fansNum : %d )", roomId, userId, nickName, fansNum);
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [roomId isEqualToString:self.liveInfo.roomId] ) {
            // 关闭输入
            [self closeAllInputView];
            
            // 显示直播结束界面
            [self showPlayEndViewWithLiverName:nickName andFansNum:fansNum];
        }
    });
}

- (void)onSendRoomFav:(BOOL)success reqId:(unsigned int)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"PlayViewController::onSendRoomFav( [发送点赞消息回调], success : %s, reqId : %d, errType : %d, errmsg : %@ )", success?"true":"false", reqId, errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if( success ) {
            [self.liveVC showLike];
        }
    });
}

- (void)onSendRoomGift:(BOOL)success reqId:(unsigned int)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg coins:(double)coins {
    NSLog(@"PlayViewController::onSendRoomGift( [发送连击礼物回调], success : %s, reqId : %d, errType : %d, errmsg : %@, coins : %f )", success?"true":"false", reqId, errType, errmsg, coins);
    dispatch_sync(dispatch_get_main_queue(), ^{
        if( success ) {
        }
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
    // 隐藏底部输入框
    [self hiddenBottomView];
    
    // 显示礼物列表
    [UIView animateWithDuration:0.25 animations:^{
        self.presentView.transform = CGAffineTransformMakeTranslation(0, -self.presentView.frame.size.height);
    } completion:^(BOOL finished) {
        self.liveVC.msgTableView.hidden = YES;
        self.liveVC.msgTipsView.hidden = YES;
    }];
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

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self sendExitRequest];
}

- (void)closeAllInputView {
    [self.inputTextField resignFirstResponder];
}

- (void)hiddenBottomView {
    // 隐藏底部输入框
    [UIView animateWithDuration:0.2 animations:^{
        self.inputMessageView.transform = CGAffineTransformMakeTranslation(0, 54);
    }];
}

- (void)showBottomView {
    // 显示底部输入框
    [UIView animateWithDuration:0.2 delay:0.25 options:0 animations:^{
        self.inputMessageView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

#pragma mark - 主播信息控件管理
- (void)setupRoomView {
    self.liveVC.favourBtn.hidden = NO;
    [self.liveVC.favourBtn addTarget:self action:@selector(favourAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)favourAction:(id)sender {
    
}

#pragma mark - 大礼物界面回调(PresentViewDelegate)
- (void)presentViewSendBtnClick:(PresentView *)presentView {
    // 标记已经点击
    _isFirstClick = YES;
    
    if ( presentView.isCellSelect ) {
        if ( presentView.selectCellItem.multi_click ) {
            self.presentView.sendView.hidden = YES;
            presentView.comboBtn.hidden = NO;
            [self.presentView hideButtonBar];
            
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval currentTime = [dat timeIntervalSince1970];
            self.clickId = (int)currentTime % 10000;
            
            [self.presentView.presentDelegate presentViewComboBtnInside:presentView andSender:presentView.comboBtn];
            
        } else {
            
        }
    }
}

- (void)presentViewComboBtnInside:(PresentView *)presentView andSender:(id)sender {
    // 是否第一次点击
    if (_isFirstClick) {
        starNum = 0;
        endNum = [presentView.sendView.selectNumLabel.text intValue];
        giftNum = [presentView.sendView.selectNumLabel.text intValue];
        totalGiftNum = [presentView.sendView.selectNumLabel.text intValue];
        
        _isFirstClick = NO;
        
    } else {
        starNum = totalGiftNum;
        endNum = starNum + 1;
        giftNum = 1;
        totalGiftNum = totalGiftNum + 1;
    }
    
    // 发送连击礼物请求
    [self sendRoomGiftFormLiveItem:presentView.selectCellItem andGiftNum:giftNum starNum:starNum endNum:endNum];
    _selectCellItem = presentView.selectCellItem;
    
    self.comboBtn = (UIButton *)sender;
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_cambo_nomal"] forState:UIControlStateNormal];

    [sender stopCountDown];
    [sender startCountDownWithSecond:30];
    
    // 连击按钮倒计时改变回调
    __weak typeof(self) weakSelf = self;
    [sender countDownChanging:^NSString *(CountTimeButton *countDownButton,NSInteger second) {
        countDownButton.titleLabel.numberOfLines = 0;
        
        weakSelf.countdownSender = 1;
        
        NSString *title = [NSString stringWithFormat:@"%zd \n combo", second];
        return title;
    }];
    
    // 连击按钮倒计时结束回调
    [sender countDownFinished:^NSString *(CountTimeButton *countDownButton, NSInteger second) {
        if (second <= 0.0) {
            weakSelf.comboBtn.hidden = YES;
            weakSelf.presentView.sendView.hidden = NO;
            
            weakSelf.countdownSender = 0;
            weakSelf.isFirstClick = YES;
            
            starNum = 0;
            endNum = 0;
            giftNum = 0;
            totalGiftNum = 0;
        }
        return @"30 \n combo";
    }];
}

- (void)presentViewComboBtnDown:(PresentView *)presentView andSender:(id)sender {
    self.comboBtn = (UIButton *)sender;
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_cambo_hight"] forState:UIControlStateHighlighted];
}


- (void)presentViewdidSelectItemWithSelf:(PresentView *)presentView atIndexPath:(NSIndexPath *)indexPath {
    if ([presentView.selectCellItem.giftId isEqualToString:_selectCellItem.giftId] && presentView.isCellSelect && _countdownSender) {
        self.comboBtn.hidden = NO;
        self.presentView.sendView.hidden = YES;
    } else {
    
        self.comboBtn.hidden = YES;
        self.presentView.sendView.hidden = NO;
    }
    
}

- (void)presentViewDidScroll:(PresentView *)PresentViewView currentPageNumber:(NSInteger)page{
    
}

#pragma mark - 文本和表情输入控件管理
- (void)setupInputMessageView {
    self.inputBackgroundView.layer.cornerRadius = self.inputBackgroundView.frame.size.height / 2;
    [self.btnLouder setImage:[UIImage imageNamed:@"Live_Input_Btn_Louder_Highlighted"] forState:UIControlStateSelected];
    
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
    self.saysomeLabel.hidden = NO;
//    self.btnChatWidth.constant = 40;
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
    self.saysomeLabel.hidden = YES;
//    self.btnChatWidth.constant = 0;
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
        [self.btnLouder setImage:[UIImage imageNamed:@"Live_Input_Btn_Louder_Selected"] forState:UIControlStateNormal];
        
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
        [self.btnLouder setImage:[UIImage imageNamed:@"Live_Input_Btn_Louder"] forState:UIControlStateNormal];
    }
}

#pragma mark - 单击屏幕
- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        self.singleTap.delegate = self;
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if( self.singleTap ) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
        self.singleTap.delegate = nil;
    }
}

- (void)singleTapAction {
    // 单击关闭输入
    [self closeAllInputView];
    
    // 如果已经展开礼物列表
    if (self.presentView.frame.origin.y < SCREEN_HEIGHT) {
        // 收起礼物列表
        [UIView animateWithDuration:0.25 animations:^{
            self.presentView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            [self showBottomView];
            self.liveVC.msgTableView.hidden = NO;
            if (self.liveVC.unReadMsgCount) {
                self.liveVC.msgTipsView.hidden = NO;
            }
        }];
    } else {
        // 如果没有打开键盘
        if (!_isKeyboradShow) {
            // 发送点赞请求
            [self.imManager.client sendRoomFav:self.liveInfo.roomId token:self.loginManager.loginItem.token nickName:self.loginManager.loginItem.nickName];
            
            // 第一次点赞, 插入本地文本
            if (!_isFirstLike) {
                _isFirstLike = YES;
                [self.liveVC addLikeMessage:self.loginManager.loginItem.nickName];
            }
        }
    }
}

#pragma mark - 手势事件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint pt = [touch locationInView:self.view];
    if (!CGRectContainsPoint([self.presentView frame], pt)) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 选择按钮回调
- (void)selectedChanged:(id)sender {
    if( sender == self.btnLouder ) {
        [self changePlaceholder:self.btnLouder.selected];
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

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0x0CEDF5);
        self.btnSend.userInteractionEnabled = YES;
    } else {
        self.btnSend.backgroundColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
        self.btnSend.userInteractionEnabled = NO;
    }
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

- (void)keyboardDidShow:(NSNotification *)notification{
    _isKeyboradShow = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification{
    _isKeyboradShow = NO;
}

#pragma mark - 结束直播界面
- (void)showPlayEndViewWithLiverName:(NSString *)nickName andFansNum:(int)fansNum {
    if( self.playEndVC == nil ) {
        // 只能出现一次
        self.playEndVC = [[PlayEndViewController alloc] initWithNibName:nil bundle:nil];
        
        self.playEndVC.liverNameLabel.text = nickName;
        self.playEndVC.viewverLabel.text = [NSString stringWithFormat:@"%d",fansNum];
        
        self.playEndVC.imageViewHeaderLoader = [ImageViewLoader loader];
        self.playEndVC.imageViewHeaderLoader.view = self.playEndVC.imageViewHeader;
        self.playEndVC.imageViewHeaderLoader.url = self.liveInfo.photoUrl;
        self.playEndVC.imageViewHeaderLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.playEndVC.imageViewHeaderLoader.url];
        [self.playEndVC.imageViewHeaderLoader loadImage];
//        self.playEndVC.imageViewHeaderLoader.sdWebImageView = self.playEndVC.imageViewHeader;
//        [self.playEndVC.imageViewHeaderLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
        
        
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
