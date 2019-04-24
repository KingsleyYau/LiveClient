//
//  PlayViewController.m
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PlayViewController.h"

#import "TalentOnDemandViewController.h"

#import "LSLiveAdvancedEmotionView.h"
#import "LSLiveStandardEmotionView.h"
#import "RewardView.h"

#import "LiveModule.h"

#import "LiveStreamPlayer.h"
#import "CountTimeButton.h"

#import "GetLeftCreditRequest.h"

#import "LSFileCacheManager.h"
#import "LSChatEmotionManager.h"
#import "LSSessionRequestManager.h"
#import "SendGiftTheQueueManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "LSRoomUserInfoManager.h"

#import "LSGiftManagerItem.h"

#import "LSChatEmotion.h"
#import "LSChatMessageObject.h"

#import "DialogTip.h"

#define CrrSysVer [[UIDevice currentDevice] systemVersion].doubleValue

@interface PlayViewController () <UITextFieldDelegate, LSCheckButtonDelegate, IMLiveRoomManagerDelegate, IMManagerDelegate,
                                  IMLiveRoomManagerDelegate, LiveViewControllerDelegate, LSLiveStandardEmotionViewDelegate, LSPageChooseKeyboardViewDelegate, LSLiveAdvancedEmotionViewDelegate, LiveSendBarViewDelegate, UIGestureRecognizerDelegate, LSGiftManagerDelegate, CreditViewDelegate, RewardViewDelegate, LiveRoomCreditRebateManagerDelegate, GiftPageViewControllerDelegate>

/** 键盘弹出 **/
@property (nonatomic, assign) BOOL isKeyboradShow;

@property (nonatomic, strong) UIButton *sendBtn;

/** 大礼物播放队列 **/
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

/** 表情选择器键盘 **/
@property (nonatomic, strong) LSPageChooseKeyboardView *chatEmotionKeyboardView;

/** 普通表情 */
@property (nonatomic, strong) LSLiveStandardEmotionView *chatNomalEmotionView;

/** 高亲密度表情 */
@property (nonatomic, strong) LSLiveAdvancedEmotionView *chatAdvancedEmotionView;

/** 键盘弹出高度 */
@property (nonatomic, assign) CGFloat keyboardHeight;

/** 是否倒计时中 */
@property (nonatomic, assign) int countdownSender;

/** 本地用户返点 */
@property (nonatomic, assign) float cur_creditNum;

@property (nonatomic, strong) UIButton *backBtn;

#pragma mark - 管理器
// IM管理器
@property (nonatomic, strong) LSImManager *imManager;
// 表情管理类
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 礼物下载管理器
@property (nonatomic, strong) LSGiftManager *giftManager;
// 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

#pragma mark - 返点控件
@property (nonatomic, strong) RewardView *rewardView;

#pragma mark - 3秒toast控件
@property (nonatomic, strong) DialogTip *dialogTipView;

#pragma mark - 用户信息管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

// 返点详情约束
@property (nonatomic, assign) int creditOffset;
@property (strong) MASConstraint *creditViewBottom;
@property (strong) MASConstraint *emotionViewBottom;

// 进入直播间时间
@property (strong) NSDate *roomInDate;

@end

@implementation PlayViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PlayViewController::initCustomParam()");

    // 隐藏导航栏
    self.isShowNavBar = NO;
    // 禁止导航栏后退手势
    self.canPopWithGesture = NO;

    // 直播间展现管理器
    self.liveVC = [[LiveViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.liveVC];
    self.liveVC.liveDelegate = self;

    // 礼物管理器
    self.giftVC = [[GiftPageViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.giftVC];
    self.giftVC.vcDelegate = self;

    // 初始化toast控件
    self.dialogTipView = [DialogTip dialogTip];

    // 初始化Im管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    // 初始化余额管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
    [self.creditRebateManager addDelegate:self];

    // 初始化登录管理器
    self.loginManager = [LSLoginManager manager];
    // 初始化接口管理器
    self.sessionManager = [LSSessionRequestManager manager];
    // 初始化表情管理器
    self.emotionManager = [LSChatEmotionManager emotionManager];
    // 初始化用户信息管理器
    self.roomUserInfoManager = [LSRoomUserInfoManager manager];

    // 初始化键盘是否弹出
    self.isKeyboradShow = NO; // 键盘是否弹出

    self.creditOffset = 0;
    self.msgSuperTabelTop = 0;
}

- (void)dealloc {
    NSLog(@"PlayViewController::dealloc()");

    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];

    [self.creditRebateManager removeDelegate:self];

    [self.rewardView stopTime];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化直播间界面管理器
    self.liveVC.liveRoom = self.liveRoom;
    // 初始化礼物列表界面管理器
    self.giftVC.liveRoom = self.liveRoom;
    // 初始化进入房间时间
    self.roomInDate = [NSDate date];

    // 初始化公共界面
    [self.view addSubview:self.liveVC.view];

    [self.liveVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    [self.liveVC.tableSuperView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.inputMessageView.mas_top).offset(-10);
    }];

    [self.view sendSubviewToBack:self.liveVC.view];
    [self.view bringSubviewToFront:self.liveVC.tableSuperView];
    [self.view bringSubviewToFront:self.liveVC.previewVideoView];

    // 初始化礼物列表界面
    [self.chooseGiftListView addSubview:self.giftVC.view];
    self.chooseGiftListView.hidden = YES;

    // 初始化输入栏
    self.liveSendBarView.liveRoom = self.liveRoom;
    WeakObject(self, weakSelf);
    [self.chatBtn addTapBlock:^(id obj) {
        if ([weakSelf.liveSendBarView.inputTextField canBecomeFirstResponder]) {
            [weakSelf.liveSendBarView.inputTextField becomeFirstResponder];
        }
    }];

    // 隐藏才艺点播
    self.talentBtnWidth.constant = 0;
    self.talentBtnTailing.constant = 0;

    // 隐藏随机礼物
    self.randomGiftBtnWidth.constant = 0;
    self.randomGiftBtnBgWidth.constant = 0;
    self.randomGiftBtnTailing.constant = 0;

    // 初始化表情控件
    [self setupEmotionInputView];
    // 初始化信用点详情控件
    [self initCreditView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 请求账户余额
    [self getLeftCreditRequest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 关闭输入
    [self closeAllInputView];

    // 清除提示
    [self.dialogTipView removeShow];
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

    [self.giftVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.chooseGiftListView);
        make.width.equalTo(self.chooseGiftListView);
        make.bottom.equalTo(self.chooseGiftListView);
        make.height.equalTo(@(self.giftVC.viewHeight));
    }];
    // 使约束生效
    [self.giftVC.view layoutSubviews];
    self.chooseGiftListViewHeight.constant = self.giftVC.viewHeight;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    // 去除手势
    [self removeSingleTap];

    // 切换界面收起礼物列表 隐藏连击按钮
    if (self.chooseGiftListViewTop.constant != 0) {
        [self closeChooseGiftListView];
    }
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化输入框
    [self setupInputMessageView];
    // 初始化信用点详情约束
    [self setupCreditView];
}

#pragma mark - 返点控件
- (void)initRewardView {
    IMRebateItem *item = [[IMRebateItem alloc] init];
    item.curTime = self.liveRoom.imLiveRoom.rebateInfo.curTime;
    item.curCredit = self.liveRoom.imLiveRoom.rebateInfo.curCredit;
    item.preTime = self.liveRoom.imLiveRoom.rebateInfo.preTime;
    item.preCredit = self.liveRoom.imLiveRoom.rebateInfo.preCredit;

    // 初始化返点界面
    self.rewardView = [RewardView rewardView];
    self.rewardView.delegate = self;
    [self.rewardView setupTimeAndCredit:item];
    self.rewardView.hidden = YES;
    [self.view addSubview:self.rewardView];

    [self.rewardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@280);
        make.height.equalTo(@250);
    }];
}

#pragma mark - 返点控件 (RewardViewDelegate)
- (void)rewardViewCloseAction:(RewardView *)creditView {
    // TODO:
    [self hiddenPushSubView];
}

#pragma mark - 信用点详情界面
- (void)initCreditView {
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setBackgroundColor:Color(0, 0, 0, 0.4)];
    [self.backBtn addTarget:self action:@selector(hiddenPushSubView) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn.hidden = YES;
    [self.view addSubview:self.backBtn];

    self.creditView = [CreditView creditView];
    self.creditView.delegate = self;
    self.creditView.hidden = YES;
    self.creditView.closeButton.hidden = YES;
    [self.view addSubview:self.creditView];
}

- (void)setupCreditView {
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(self.view);
        make.width.equalTo(@SCREEN_WIDTH);
        make.height.equalTo(@SCREEN_HEIGHT);
    }];

    [self.creditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@SCREEN_WIDTH);
        make.height.equalTo(@234);
        make.left.equalTo(self.view);
        self.creditViewBottom = make.top.equalTo(self.view.mas_bottom).offset(self.creditOffset);
    }];
    // 设置默认的用户id为登录使用用户的id
    self.creditView.userIdLabel.text = [NSString stringWithFormat:@"ID:%@", [LSLoginManager manager].loginItem.userId];
    NSString *nickName = [LSLoginManager manager].loginItem.nickName;
    if (nickName.length > 20) {
        nickName = [nickName substringToIndex:17];
        nickName = [NSString stringWithFormat:@"%@...", nickName];
    }
    self.creditView.nameLabel.text = nickName;
    WeakObject(self, weakSelf);
    [self.roomUserInfoManager getFansBaseInfo:self.loginManager.loginItem.userId
                                finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                    [weakSelf.creditView updateUserBalanceCredit:weakSelf.creditRebateManager.mCredit userInfo:item];
                                }];
}

#pragma mark - 买点 (CreditViewDelegate)
- (void)creditViewCloseAction:(CreditView *)creditView {
    [self hiddenPushSubView];
}

- (void)rechargeCreditAction:(CreditView *)creditView {
    if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(pushToAddCredit:)]) {
        [self.playDelegate pushToAddCredit:self];
    }
}

- (void)hiddenPushSubView {
    self.backBtn.hidden = YES;
    self.rewardView.hidden = YES;
    if (self.creditOffset != 0) {
        [self closeCreditView];
    }
}

#pragma mark - 文本和表情输入控件管理
- (void)setupInputMessageView {
    self.liveSendBarView.delegate = self;
    [self showInputMessageView];
}

- (void)showInputMessageView {
    self.chatBtn.hidden = NO;
    self.talentBtn.hidden = NO;
    self.randomGiftBtn.hidden = NO;
    self.randomGiftImageView.hidden = NO;
    self.giftBtn.hidden = NO;

    self.liveSendBarView.hidden = YES;
}

- (void)hideInputMessageView {
    self.chatBtn.hidden = YES;
    self.talentBtn.hidden = YES;
    self.randomGiftBtn.hidden = YES;
    self.randomGiftImageView.hidden = YES;
    self.giftBtn.hidden = YES;

    self.liveSendBarView.hidden = NO;
}

#pragma mark - 发送栏委托 (LiveSendBarViewDelegate)
- (void)sendBarLouserAction:(LiveSendBarView *)sendBarView isSelected:(BOOL)isSelected {
}

- (void)sendBarEmotionAction:(LiveSendBarView *)sendBarView isSelected:(BOOL)isSelected {
    // TODO:点击表情
    if (isSelected) {
        // 弹出底部emotion的键盘
        [self showEmotionView];
    } else {
        // 切换成系统的的键盘
        [self showKeyboardView];
    }
}

- (void)sendBarSendAction:(LiveSendBarView *)sendBarView {
    // TODO:点击发送按钮
    NSDate *now = [NSDate date];
    NSTimeInterval betweenTime = [now timeIntervalSinceDate:self.roomInDate];

    if (betweenTime >= 1) {
        NSString *str = [self.liveSendBarView.inputTextField.fullText stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([self.liveVC sendMsg:self.liveSendBarView.inputTextField.fullText isLounder:self.liveSendBarView.louderBtn.selected] || !str.length) {
            self.liveSendBarView.inputTextField.fullText = nil;
            [self.liveSendBarView sendButtonNotUser];
        }
    } else {
        [self showDialogTipView:NSLocalizedStringFromSelf(@"SPEAK_TOO_FAST")];
    }
    self.roomInDate = now;
}

#pragma mark - 初始化表情输入控件
- (void)setupEmotionInputView {
    // 普通表情
    if (self.chatNomalEmotionView == nil) {
        self.chatNomalEmotionView = [LSLiveStandardEmotionView emotionChooseView:self];
        self.chatNomalEmotionView.delegate = self;
        self.chatNomalEmotionView.stanListItem = self.emotionManager.stanListItem;
        self.chatNomalEmotionView.tipView.hidden = NO;
        self.chatNomalEmotionView.tipLabel.text = self.emotionManager.stanListItem.errMsg;
        [self.chatNomalEmotionView reloadData];
    }

    // 高亲密度表情
    if (self.chatAdvancedEmotionView == nil) {
        self.chatAdvancedEmotionView = [LSLiveAdvancedEmotionView friendlyEmotionView:self];
        self.chatAdvancedEmotionView.delegate = self;
        self.chatAdvancedEmotionView.advanListItem = self.emotionManager.advanListItem;
        self.chatAdvancedEmotionView.tipView.hidden = NO;
        self.chatAdvancedEmotionView.tipLabel.text = self.emotionManager.advanListItem.errMsg;
        [self.chatAdvancedEmotionView reloadData];
    }

    // 表情选择器
    if (self.chatEmotionKeyboardView == nil) {
        self.chatEmotionKeyboardView = [LSPageChooseKeyboardView LSPageChooseKeyboardView:self];
        self.chatEmotionKeyboardView.delegate = self;
        self.chatEmotionKeyboardView.hidden = YES;
        [self.view addSubview:self.chatEmotionKeyboardView];
        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.inputMessageView.mas_width);
            make.height.equalTo(@219);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.inputMessageView.mas_bottom).offset(5);
        }];

        NSMutableArray *array = [NSMutableArray array];

        UIImage *bgSelectImage = [LSUIImageFactory createImageWithColor:COLOR_WITH_16BAND_RGB(0x2b2b2b) imageRect:CGRectMake(0, 0, 1, 1)];
        UIImage *bgNormalImage = [LSUIImageFactory createImageWithColor:COLOR_WITH_16BAND_RGB(0x000000) imageRect:CGRectMake(0, 0, 1, 1)];
        UIColor *titleNormalColor = COLOR_WITH_16BAND_RGB_ALPHA(0x59ffffff);
        UIColor *titlrSelectColor = COLOR_WITH_16BAND_RGB(0xf7cd3a);

        NSString *title = NSLocalizedStringFromSelf(@"STANDARD");
        UIButton *button = [self setupChooserBarBtnType:0 normalImage:nil selectImage:nil bgNormalImage:bgNormalImage bgSelectImage:bgSelectImage titleText:title titleNormalColor:titleNormalColor titleSelectColor:titlrSelectColor];
        [array addObject:button];

        title = NSLocalizedStringFromSelf(@"ADVANCE");
        UIButton *btn = [self setupChooserBarBtnType:0 normalImage:nil selectImage:nil bgNormalImage:bgNormalImage bgSelectImage:bgSelectImage titleText:title titleNormalColor:titleNormalColor titleSelectColor:titlrSelectColor];
        [array addObject:btn];

        self.chatEmotionKeyboardView.buttons = array;
    }
    // 请求表情列表
    [self getLiveRoomEmotionList];
}

- (UIButton *)setupChooserBarBtnType:(int)type normalImage:(UIImage *)normalImage selectImage:(UIImage *)selectImage bgNormalImage:(UIImage *)bgNormalImage bgSelectImage:(UIImage *)bgSelectImage titleText:(NSString *)titleText titleNormalColor:(UIColor *)normalColor titleSelectColor:(UIColor *)selectColor {

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    if (type) {
        [button setImage:normalImage forState:UIControlStateNormal];
        [button setImage:selectImage forState:UIControlStateSelected];
        [button setImage:selectImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    [button setBackgroundImage:bgNormalImage forState:UIControlStateNormal];
    [button setBackgroundImage:bgSelectImage forState:UIControlStateSelected];
    [button setBackgroundImage:bgSelectImage forState:UIControlStateSelected | UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button setTitleColor:selectColor forState:UIControlStateSelected];
    [button setTitleColor:selectColor forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setTitle:titleText forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = NO;

    return button;
}

#pragma mark - 显示直播间可发送表情
- (void)getLiveRoomEmotionList {
    for (NSNumber *i in self.liveRoom.imLiveRoom.emoTypeList) {
        if ([i intValue] == 1) {
            self.chatAdvancedEmotionView.tipView.hidden = YES;
        } else {
            self.chatNomalEmotionView.tipView.hidden = YES;
        }
    }
}

#pragma mark - 请求账号余额
- (void)getLeftCreditRequest {
    GetLeftCreditRequest *request = [[GetLeftCreditRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, double credit, int coupon, double postStamp) {
        NSLog(@"PlayViewController::getLeftCreditRequest( [获取账号余额请求结果], success:%d, errnum : %ld, errmsg : %@ credit : %f coupon : %d, postStamp : %f)", success, (long)errnum, errmsg, credit, coupon, postStamp);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.creditView userCreditChange:credit];
                [self.creditRebateManager setCredit:credit];
            } else {
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - LiveViewControllerDelegate
- (void)onReEnterRoom:(LiveViewController *)vc {
    if ([self.playDelegate respondsToSelector:@selector(onReEnterRoom:)]) {
        [self.playDelegate onReEnterRoom:self];
    }
}

- (void)bringRewardViewInTop:(LiveViewController *)vc {
    [self.view bringSubviewToFront:self.backBtn];
    [self.view bringSubviewToFront:self.rewardView];
    self.backBtn.hidden = NO;
    self.rewardView.hidden = NO;
}

- (void)noCreditPushTo:(LiveViewController *)vc {
    if ([self.playDelegate respondsToSelector:@selector(pushToAddCredit:)]) {
        [self.playDelegate pushToAddCredit:self];
    }
}

- (void)liveViewIsPlay:(LiveViewController *)vc {
    // 初始化返点控件
    [self initRewardView];
}

- (void)liveFinshViewIsShow:(LiveViewController *)vc {
    [self closeAllInputView];
}

- (void)showHangoutTipView:(LiveViewController *)vc {
    // 公开直播间弹出hangout提示控件
    if ([self.playDelegate respondsToSelector:@selector(showPubilcHangoutTipView:)]) {
        [self.playDelegate showPubilcHangoutTipView:self];
    }
}

#pragma mark - 请求数据逻辑

#pragma mark - LiveRoomCreditRebateManagerDelegate
- (void)updataCredit:(double)credit {
    [self.creditView userCreditChange:credit];
}

#pragma mark - IM回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"PlayViewController::onLogin( [IM登录], errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"PlayViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"PlayViewController::onSendGift( [发送直播间礼物消息], errmsg : %@, credit : %f, rebateCredit : %f )", errmsg, credit, rebateCredit);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            if (credit > 0) {
                [self.creditRebateManager setCredit:credit];

                self.liveRoom.imLiveRoom.rebateInfo.curCredit = rebateCredit;
                // 更新返点控件
                [self.rewardView updataCredit:rebateCredit];
            }
        }
    });
}

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"PlayViewController::onSendToast( [发送直播间弹幕消息, %@], errmsg : %@, credit : %f, rebateCredit : %f )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errmsg, credit, rebateCredit);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            if (credit > 0) {
                self.liveRoom.imLiveRoom.rebateInfo.curCredit = rebateCredit;
                // 更新返点控件
                [self.rewardView updataCredit:rebateCredit];
            }
        } else if (errType == LCC_ERR_NO_CREDIT) {
        }
    });
}

- (void)onRecvRebateInfoNotice:(NSString *_Nonnull)roomId rebateInfo:(RebateInfoObject *_Nonnull)rebateInfo {
    NSLog(@"PlayViewController::onRecvRebateInfoNotice( [接收返点通知], roomId : %@", roomId);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 设置余额及返点信息管理器
        IMRebateItem *imRebateItem = [[IMRebateItem alloc] init];
        imRebateItem.curCredit = rebateInfo.curCredit;
        imRebateItem.curTime = rebateInfo.curTime;
        imRebateItem.preCredit = rebateInfo.preCredit;
        imRebateItem.preTime = rebateInfo.preTime;

        // 更新本地返点信息
        self.liveRoom.imLiveRoom.rebateInfo = rebateInfo;
        // 更新返点控件
        @synchronized(self) {
            [self.rewardView setupTimeAndCredit:imRebateItem];
        }
    });
}

- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"PlayViewController::onRecvLevelUpNotice( [接收观众等级升级通知], level : %d )", level);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新blanceview等级
        [self.creditView userLevelUp:level];
    });
}

- (void)onRecvLoveLevelUpNotice:(IMLoveLevelItemObject *_Nonnull)loveLevelItem {
    NSLog(@"PlayViewController::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知],  loveLevel : %d, anchorId: %@, anchorName: %@ )", loveLevelItem.loveLevel, loveLevelItem.anchorId, loveLevelItem.anchorName);
    dispatch_async(dispatch_get_main_queue(), ^{
                   });
}

- (void)onRecvSendTalentNotice:(ImTalentReplyObject *)item {
    NSLog(@"PlayViewController::onRecvSendTalentNotice( [接收直播间才艺点播回复通知] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (item.credit >= 0) {
            [self.creditRebateManager setCredit:item.credit];
        }
        [self.creditRebateManager updateRebateCredit:item.rebateCredit];
        // 更新返点控件
        [self.rewardView updataCredit:item.rebateCredit];
    });
}

#pragma mark - 界面事件
- (void)favourAction:(id)sender {
}

- (IBAction)giftAction:(id)sender {
    // 隐藏底部输入框
    [self hiddenBottomView];

    // 随机礼物按钮默认选中礼物列表
    if (sender == self.randomGiftBtn) {
        [self.giftListKeyboardView toggleButtonSelect:0];
    } else {
        [[LiveModule module].analyticsManager reportActionEvent:BroadcastClickGiftList eventCategory:EventCategoryBroadcast];
    }

    // 显示礼物列表
    [self showChooseGiftListView];
}

#pragma mark - 界面显示/隐藏
/** 显示信用详情 **/
- (void)showCreditView {
    self.creditView.hidden = NO;
    [self.creditViewBottom uninstall];
    self.creditOffset = -234;
    [self.creditView mas_updateConstraints:^(MASConstraintMaker *make) {
        self.creditViewBottom = make.top.equalTo(self.view.mas_bottom).offset(self.creditOffset);
    }];
    // 设置默认的用户id为登录使用用户的id
    self.creditView.userIdLabel.text = [NSString stringWithFormat:@"ID:%@", [LSLoginManager manager].loginItem.userId];
    NSString *nickName = [LSLoginManager manager].loginItem.nickName;
    if (nickName.length > 20) {
        nickName = [nickName substringToIndex:17];
        nickName = [NSString stringWithFormat:@"%@...", nickName];
    }
    self.creditView.nameLabel.text = nickName;
    [UIView animateWithDuration:0.25
        animations:^{
            [self.view layoutIfNeeded];

        }
        completion:^(BOOL finished) {
            [self.roomUserInfoManager getLiverInfo:self.loginManager.loginItem.userId
                                         finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                             [self.creditView updateUserBalanceCredit:self.creditRebateManager.mCredit userInfo:item];
                                         }];
        }];
}

/** 收起信用详情 **/
- (void)closeCreditView {
    [self.creditViewBottom uninstall];
    self.creditOffset = 0;
    [self.creditView mas_updateConstraints:^(MASConstraintMaker *make) {
        self.creditViewBottom = make.top.equalTo(self.view.mas_bottom).offset(self.creditOffset);
    }];
    [UIView animateWithDuration:0.25
        animations:^{
            [self.view layoutIfNeeded];
        }
        completion:^(BOOL finished) {
            self.creditView.hidden = YES;
        }];
}

/** 显示礼物列表 **/
- (void)showChooseGiftListView {
    self.chooseGiftListView.hidden = NO;
    [self.view layoutIfNeeded];
    self.chooseGiftListViewTop.constant = -self.chooseGiftListViewHeight.constant;
    [UIView animateWithDuration:0.25
        animations:^{
            [self.view layoutIfNeeded];
            [self.giftListKeyboardView reloadData];
        }
        completion:^(BOOL finished) {
            self.liveVC.tableSuperView.hidden = YES;
            self.liveVC.msgTipsView.hidden = YES;
        }];
}

- (void)closeChooseGiftListView {
    // TODO:收起礼物列表
    [self.view layoutIfNeeded];
    self.chooseGiftListViewTop.constant = 0;
    [UIView animateWithDuration:0.25
        animations:^{
            [self.view layoutIfNeeded];
        }
        completion:^(BOOL finished) {
            self.chooseGiftListView.hidden = YES;
            [self showBottomView];

            self.liveVC.tableSuperView.hidden = NO;
            if (self.liveVC.unReadMsgCount) {
                self.liveVC.msgTipsView.hidden = NO;
            }

            [self.giftVC reset];

        }];
}

- (void)showKeyboardView {
    // TODO:显示系统键盘
    self.liveSendBarView.inputTextField.userInteractionEnabled = YES;
    self.liveSendBarView.inputTextField.inputView = nil;
    [self.liveSendBarView.inputTextField becomeFirstResponder];
}

/** 显示表情选择 **/
- (void)showEmotionView {
    // 关闭系统键盘
    self.liveSendBarView.inputTextField.inputView = [[UIView alloc] init];
    [self.liveSendBarView.inputTextField resignFirstResponder];

    if (self.inputMessageViewBottom.constant != -self.chatEmotionKeyboardView.frame.size.height) {
        self.chatEmotionKeyboardView.hidden = NO;

        if (IS_IPHONE_X) {
            CGFloat height = self.chatEmotionKeyboardView.frame.size.height + 35;
            [self moveInputBarWithKeyboardHeight:height withDuration:0.25];
        } else {
            // 未显示则显示
            [self moveInputBarWithKeyboardHeight:self.chatEmotionKeyboardView.frame.size.height withDuration:0.25];
        }

        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputMessageView.mas_bottom);
        }];

        if (CrrSysVer < 10) {
            self.liveSendBarView.inputTextField.userInteractionEnabled = NO;
        }
    }
    [self.chatEmotionKeyboardView reloadData];
}

- (void)closeAllInputView {
    // 关闭表情输入
    if (self.liveSendBarView.emotionBtn.selected == YES) {
        if (self.liveSendBarView.inputTextField.isFirstResponder) {
            self.liveSendBarView.inputTextField.inputView = nil;
            [self.liveSendBarView.inputTextField resignFirstResponder];
        }
        self.liveSendBarView.inputTextField.userInteractionEnabled = YES;
        self.liveSendBarView.emotionBtn.selected = NO;
        self.liveSendBarView.inputTextField.inputView = nil;
        [self moveInputBarWithKeyboardHeight:0 withDuration:0.25];
        [self showInputMessageView];
        self.chatEmotionKeyboardView.hidden = YES;
    } else {
        // 关闭键盘输入
        [self.liveSendBarView.inputTextField resignFirstResponder];
    }
}

- (void)hiddenBottomView {
    if (IS_IPHONE_X) {
        self.inputMessageView.hidden = YES;
    } else {
        // 隐藏底部输入框
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.inputMessageView.transform = CGAffineTransformMakeTranslation(0, 54);
                         }];
    }
}

- (void)showBottomView {
    if (IS_IPHONE_X) {
        self.inputMessageView.hidden = NO;
    } else {
        // 显示底部输入框
        [UIView animateWithDuration:0.2
                              delay:0.25
                            options:0
                         animations:^{
                             self.inputMessageView.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
    }
}

// 显示3秒toas提示控件
- (void)showDialogTipView:(NSString *)tipText {
    [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:tipText];
}

#pragma mark - 礼物列表界面回调(GiftPageViewControllerDelegate)
- (void)didBalanceAction:(GiftPageViewController *)vc {
    // TODO:点击余额
    [[LiveModule module].analyticsManager reportActionEvent:BroadcastClickMyBalance eventCategory:EventCategoryBroadcast];
    [self.view bringSubviewToFront:self.backBtn];
    [self.view bringSubviewToFront:self.creditView];
    self.backBtn.hidden = NO;
    [self showCreditView];
}

- (void)didCreditAction:(GiftPageViewController *)vc {
    // TODO:点击买点
    [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
    if ([self.playDelegate respondsToSelector:@selector(pushToAddCredit:)]) {
        [self.playDelegate pushToAddCredit:self];
    }
}

- (void)didChangeGiftList:(GiftPageViewController *)vc {
    if ([self.playDelegate respondsToSelector:@selector(didChangeGiftList:)]) {
        [self.playDelegate didChangeGiftList:self];
    }
}

#pragma mark - 手势事件 (单击屏幕)
- (void)addSingleTap {
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        self.singleTap.delegate = self;
        [self.liveVC.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
        [self.liveVC.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
        self.singleTap.delegate = nil;
    }
}

- (void)singleTapAction {
    // 单击关闭输入
    [self closeAllInputView];

    // 如果已经展开礼物列表
    if (self.chooseGiftListView.frame.origin.y < SCREEN_HEIGHT) {
        // 收起礼物列表
        [self closeChooseGiftListView];
    }
    //    else {
    //        // 如果没有打开键盘
    //        if (!_isKeyboradShow) {
    //            // 发送点赞请求
    //            [self sendActionLikeRequest];
    //
    //            // 第一次点赞, 插入本地文本
    //            if (!_isFirstLike) {
    //                _isFirstLike = YES;
    //                [self.liveVC addLikeMessage:self.loginManager.loginItem.nickName];
    //            }
    //        }
    //    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint pt = [touch locationInView:self.view];
    if (!CGRectContainsPoint([self.chooseGiftListView frame], pt)) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 普通表情选择回调 (LSLiveStandardEmotionViewDelegate)
- (void)LSLiveStandardEmotionView:(LSLiveStandardEmotionView *)LSLiveStandardEmotionView didSelectNomalItem:(NSInteger)item {
    LSChatEmotion *emotion = [self.emotionManager.stanEmotionList objectAtIndex:item];
    NSUInteger textLength = emotion.text.length + self.liveSendBarView.inputTextField.fullText.length;
    if (textLength <= 70) {
        // 插入表情描述到输入框
        [self.liveSendBarView.inputTextField insertEmotion:emotion];
        if (CrrSysVer >= 10) {
            [self.liveSendBarView.inputTextField becomeFirstResponder];
        }
        [self.liveSendBarView sendButtonCanUser];
    }
}

#pragma mark - 高亲密度表情选择回调 (LSLiveAdvancedEmotionViewDelegate)
- (void)LSLiveAdvancedEmotionView:(LSLiveAdvancedEmotionView *)LSLiveAdvancedEmotionView didSelectNomalItem:(NSInteger)item {

    LSChatEmotion *emotion = [self.emotionManager.advanEmotionList objectAtIndex:item];
    NSUInteger textLength = emotion.text.length + self.liveSendBarView.inputTextField.fullText.length;
    if (textLength <= 70) {
        // 插入表情描述到输入框
        [self.liveSendBarView.inputTextField insertEmotion:emotion];
        if (CrrSysVer >= 10) {
            [self.liveSendBarView.inputTextField becomeFirstResponder];
        }
        [self.liveSendBarView sendButtonCanUser];
    }
}

#pragma mark - 表情、礼物键盘选择回调 (LSPageChooseKeyboardViewDelegate)
- (NSUInteger)pagingViewCount:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView {
    return 2;
}

- (Class)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView classForIndex:(NSUInteger)index {
    Class cls = nil;

    if (LSPageChooseKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
            // 普通表情
            cls = [LSLiveStandardEmotionView class];
        } else if (index == 1) {
            // 高亲密度表情
            cls = [LSLiveAdvancedEmotionView class];
        }

    } else {
    }
    return cls;
}

- (UIView *)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView pageViewForIndex:(NSUInteger)index {
    UIView *view = nil;

    if (LSPageChooseKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
            view = self.chatNomalEmotionView;
            view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);
        } else if (index == 1) {
            view = self.chatAdvancedEmotionView;
            view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);
        }
    } else {
        //        if (index == 0) {
        //            view = self.presentView;
        //        } else if (index == 1) {
        //            view = self.backpackView;
        //        }
    }
    return view;
}

- (void)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    if (LSPageChooseKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
            // 普通表情
            [self.chatNomalEmotionView reloadData];

        } else if (index == 1) {
            // 高级表情
            [self.chatAdvancedEmotionView reloadData];
        }
    } else {
        if (index == 0) {
        } else if (index == 1) {
        }
    }
}

- (void)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView didShowPageViewForDisplay:(NSUInteger)index {
    if (LSPageChooseKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
        } else if (index == 1) {
        }
    } else {
        if (index == 0) {
        } else if (index == 1) {
        }
    }
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    BOOL bFlag = NO;

    if (height != 0) {
        // 弹出键盘
        self.liveVC.msgSuperViewTop.constant = 5 - self.msgSuperTabelTop - height;

        if (IS_IPHONE_X) {
            self.inputMessageViewBottom.constant = -height + 35;
        } else {
            self.inputMessageViewBottom.constant = -height;
        }

        self.liveVC.barrageView.backgroundColor = Color(255, 255, 255, 0);
        self.liveVC.barrageView.layer.shadowColor = [UIColor clearColor].CGColor;
        self.liveVC.startOneView.hidden = YES;

        bFlag = YES;

    } else {
        self.chatEmotionKeyboardView.hidden = YES;

        // 收起键盘
        self.inputMessageViewBottom.constant = -5;
        self.liveVC.msgSuperViewTop.constant = self.msgSuperTabelTop;

        self.liveVC.barrageView.backgroundColor = self.liveVC.roomStyleItem.barrageBgColor;
        self.liveVC.barrageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.liveVC.barrageView.layer.shadowOffset = CGSizeMake(0, 1);
        self.liveVC.barrageView.layer.shadowRadius = 1;
        self.liveVC.barrageView.layer.shadowOpacity = 0.5;
        
        self.liveVC.startOneView.hidden = NO;
        
        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputMessageView.mas_bottom).offset(5);
        }];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    self.keyboardHeight = keyboardRect.size.height;
    // 从表情键盘切换成系统键盘,保存普通表情的富文本属性
    //    self.emotionAttributedString = self.inputTextField.attributedText;
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
    
    if( self.liveSendBarView.emotionBtn.selected != YES ) {
        // 改变控件状态
        [self showInputMessageView];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    _isKeyboradShow = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    _isKeyboradShow = NO;
}

@end
