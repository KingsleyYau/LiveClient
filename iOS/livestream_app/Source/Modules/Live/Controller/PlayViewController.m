//
//  PlayViewController.m
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PlayViewController.h"

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
#import "BackpackSendGiftManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "UserInfoManager.h"
#import "ShareManager.h"

#import "AllGiftItem.h"
#import "SendGiftItem.h"

#import "LSChatEmotion.h"
#import "LSChatMessageObject.h"
#import "LiveGiftListManager.h"

#import "DialogOK.h"
#import "DialogTip.h"

#import "TalentOnDemandViewController.h"
#import "LSAnalyticsManager.h"

#define ComboTitleFont [UIFont boldSystemFontOfSize:30]
#define CrrSysVer [[UIDevice currentDevice] systemVersion].doubleValue

@interface PlayViewController () <UITextFieldDelegate, LSCheckButtonDelegate, IMLiveRoomManagerDelegate, IMManagerDelegate,
                                  PresentViewDelegate, IMLiveRoomManagerDelegate, LiveViewControllerDelegate, LSLiveStandardEmotionViewDelegate, LSPageChooseKeyboardViewDelegate, LSLiveAdvancedEmotionViewDelegate, LSChatTextViewDelegate, BackpackPresentViewDelegate, LiveSendBarViewDelegate, UIGestureRecognizerDelegate, LiveGiftDownloadManagerDelegate, SendGiftTheQueueManagerDelegate,
                                  CreditViewDelegate, RewardViewDelegate, LiveRoomCreditRebateManagerDelegate,ShareViewDelegate>

/** IM管理器 **/
@property (nonatomic, strong) LSImManager *imManager;

/** 首次点赞 **/
@property (nonatomic, assign) BOOL isFirstLike;

/** 键盘弹出 **/
@property (nonatomic, assign) BOOL isKeyboradShow;

/** 礼物列表首次点击 **/
@property (nonatomic, assign) BOOL isFirstClick;

/** 背包礼物首次点击 */
@property (nonatomic, assign) BOOL isBackpackFirstClick;

/** 是否是连击 **/
@property (nonatomic, assign) BOOL isMultiClick;

/** 是否正在连击中 **/
@property (nonatomic, assign) BOOL isComboing;

/** 点击Id **/
@property (nonatomic, assign) int clickId;

/** 记录点击Id **/
@property (nonatomic, assign) int recordClickId;

/** 礼物列表发送连击Button **/
@property (nonatomic, strong) CountTimeButton *comboBtn;

@property (nonatomic, strong) UIButton *sendBtn;

/** 大礼物播放队列 **/
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

/** 表情选择器键盘 **/
@property (nonatomic, strong) LSPageChooseKeyboardView *LSPageChooseKeyboardView;

/** 普通表情 */
@property (nonatomic, strong) LSLiveStandardEmotionView *chatNomalEmotionView;

/** 高亲密度表情 */
@property (nonatomic, strong) LSLiveAdvancedEmotionView *LSLiveAdvancedEmotionView;

/** 键盘弹出高度 */
@property (nonatomic, assign) CGFloat keyboardHeight;

/** 礼物列表选中cell */
@property (nonatomic, strong) AllGiftItem *selectCellItem;

/** 是否倒计时中 */
@property (nonatomic, assign) int countdownSender;

/** 当前送礼数、送礼总数、开始数、结束数 */
@property (nonatomic, assign) int giftNum;
@property (nonatomic, assign) int totalGiftNum;
@property (nonatomic, assign) int starNum;
@property (nonatomic, assign) int endNum;

/** 本地用户返点 */
@property (nonatomic, assign) float cur_creditNum;

/** 表情转义符解析器 **/
@property (nonatomic, strong) LSChatMessageObject *chatMessageObject;

/** 送礼队列管理类 **/
@property (nonatomic, strong) SendGiftTheQueueManager *sendGiftTheQueueManager;

/** 表情管理类 **/
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;

/** 背包礼物管理类 */
@property (nonatomic, strong) BackpackSendGiftManager *backGiftManager;

/** 接口管理器 **/
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

// 礼物列表管理器
@property (nonatomic, strong) LiveGiftListManager *listManager;

// 礼物下载管理器
@property (nonatomic, strong) LiveGiftDownloadManager *loadManager;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, assign) NSInteger backRow;

#pragma mark - 返点控件
@property (nonatomic, strong) RewardView *rewardView;
#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

#pragma mark - 3秒toast控件
@property (nonatomic, strong) DialogTip *dialogTipView;
@property (strong) DialogOK *dialogGiftAddCredit;

#pragma mark - 用户信息管理器
@property (nonatomic, strong) UserInfoManager *userInfoManager;

#pragma mark - 分享管理器
@property (nonatomic, strong) ShareManager *shareManager;

// 返点详情约束
@property (nonatomic, assign) int creditOffset;
@property (strong) MASConstraint *creditViewBottom;
@property (strong) MASConstraint *emotionViewBottom;

@property (strong) NSDate *roominDate;

@end

@implementation PlayViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PlayViewController::initCustomParam()");

    self.liveVC = [[LiveViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.liveVC];
    self.liveVC.liveDelegate = self;

    // 初始化toast控件
    self.dialogTipView = [DialogTip dialogTip];

    self.chatMessageObject = [[LSChatMessageObject alloc] init];

    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    // 初始化管理器
    // 初始化余额及返点信息管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
    [self.creditRebateManager addDelegate:self];
    self.loginManager = [LSLoginManager manager];
    self.sessionManager = [LSSessionRequestManager manager];
    self.sendGiftTheQueueManager = [[SendGiftTheQueueManager alloc] init];
    self.emotionManager = [LSChatEmotionManager emotionManager];
    self.backGiftManager = [BackpackSendGiftManager backpackGiftManager];
    self.listManager = [LiveGiftListManager manager];
    self.loadManager = [LiveGiftDownloadManager manager];
    self.loadManager.managerDelegate = self;
    self.userInfoManager = [UserInfoManager manager];
    self.shareManager = [ShareManager manager];
    
    // 初始化控制变量
    self.isFirstLike = NO;    // 第一次点赞
    self.isKeyboradShow = NO; // 键盘是否弹出
    self.isMultiClick = NO;   // 是否是连击
    self.isComboing = NO;     // 是否正在连击

    // 记录连击ID初始化
    self.recordClickId = 0;

    self.presentRow = 0;
    self.backRow = 0;

    self.creditOffset = 0;
}

- (void)dealloc {
    NSLog(@"PlayViewController::dealloc()");

    // 移除直播间监听代理
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    [self.creditRebateManager removeDelegate:self];
    
    [self.sendGiftTheQueueManager removeAllSendGift];
    [self.backGiftManager.roombackGiftArray removeAllObjects];
    
    if (self.dialogGiftAddCredit) {
        [self.dialogGiftAddCredit removeFromSuperview];
    }
    [self.rewardView stopTime];
    
    // 停止连击
    [self.presentView.comboBtn stop];
    [self.backpackView.comboBtn stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.roominDate = [NSDate date];
    
    // 禁止导航栏后退手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

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
    //    self.chooseGiftListView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH * 0.5 + 99);
    self.chooseGiftListViewWidth.constant = SCREEN_WIDTH;
    self.chooseGiftListViewHeight.constant = SCREEN_WIDTH * 0.5 + 89;

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
    
    // 隐藏分享按钮
    self.shareBtnWidth.constant = 0;
    self.shareBtnTailing.constant = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    // 请求账户余额
    [self getLeftCreditRequest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 关闭输入
    [self closeAllInputView];

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

    // 移除所有送礼队列
    [self.sendGiftTheQueueManager removeAllSendGift];
    [self.sendGiftTheQueueManager unInit];
    
    // 切换界面收起礼物列表 隐藏连击按钮
    if (self.chooseGiftListViewTop.constant != 0) {
        [self closeChooseGiftListView];
    }
    if (self.shareViewTop.constant != 0) {
        [self closeShareView];
    }
    self.comboBtn.hidden = YES;
}

- (void)initialiseSubwidge {
    [super initialiseSubwidge];
    
    // 初始化表情控件
    [self setupEmotionInputView];
    
    // 初始化礼物列表
    [self setupGiftListView];
    
    // 初始化信用点详情控件
    [self initCreditView];
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化输入框
    [self setupInputMessageView];

    // 初始化信用点详情约束
    [self setupCreditView];
    
    self.shareView.delagate = self;
    self.shareManager.presentVC = self.liveRoom.superController;
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

#pragma mark - ShareViewDelegate(分享处理)
- (void)facebookShareAction:(ShareView *)shareView {
    [[LSAnalyticsManager manager] reportActionEvent:BroadcastClickShareFacebook eventCategory:EventCategoryBroadcast];
    [self closeShareView];
    [self.shareManager sendShareForUserId:self.loginManager.loginItem.userId anchorId:self.liveRoom.userId shareType:SHARETYPE_FACEBOOK shareHandler:^(BOOL success, NSString *errmsg, NSString *shareId) {
        
    }];
}

- (void)copyLinkShareAction:(ShareView *)shareView {
    [[LSAnalyticsManager manager] reportActionEvent:BroadcastClickCopylink eventCategory:EventCategoryBroadcast];
    [self closeShareView];
    if ([self.shareManager copyLinkToClipboard:self.liveRoom.imLiveRoom.shareLink]) {
        [self showDialogTipView:NSLocalizedStringFromSelf(@"COPY_LINK_SUCCESS")];
    }
}

- (void)moreShareAction:(ShareView *)shareView {
        [[LSAnalyticsManager manager] reportActionEvent:BroadcastClickShareMore eventCategory:EventCategoryBroadcast];
    [self closeShareView];
    [self.shareManager systemsShareForShareLink:self.liveRoom.imLiveRoom.shareLink finishHandler:^(BOOL success, NSError *error, __autoreleasing UIActivityType *type) {
        
    }];
}

#pragma mark - RewardViewDelegate
- (void)rewardViewCloseAction:(RewardView *)creditView {
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
    
    WeakObject(self, waekSelf);
    [self.userInfoManager getLiverInfo:self.loginManager.loginItem.userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
        [waekSelf.creditView updateUserBalanceCredit:waekSelf.creditRebateManager.mCredit userInfo:item];
    }];
}

#pragma mark -  CreditViewDelegate
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
    self.shareBtn.hidden = NO;

    self.liveSendBarView.hidden = YES;
}

- (void)hideInputMessageView {
    self.chatBtn.hidden = YES;
    self.talentBtn.hidden = YES;
    self.randomGiftBtn.hidden = YES;
    self.randomGiftImageView.hidden = YES;
    self.giftBtn.hidden = YES;
    self.shareBtn.hidden = YES;
    
    self.liveSendBarView.hidden = NO;
}

#pragma mark - LiveSendBarViewDelegate
- (void)sendBarLouserAction:(LiveSendBarView *)sendBarView isSelected:(BOOL)isSelected {
}

- (void)sendBarEmotionAction:(LiveSendBarView *)sendBarView isSelected:(BOOL)isSelected {
    if (isSelected) {
        // 弹出底部emotion的键盘
        [self showEmotionView];
    } else {
        // 切换成系统的的键盘
        [self showKeyboardView];
    }
}

// 发送聊天或者弹幕
- (void)sendBarSendAction:(LiveSendBarView *)sendBarView {

    NSDate* now = [NSDate date];
    NSTimeInterval betweenTime = [now timeIntervalSinceDate:self.roominDate];
    
    if (betweenTime >= 1) {
        NSString *str =  [self.liveSendBarView.inputTextField.fullText stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([self.liveVC sendMsg:self.liveSendBarView.inputTextField.fullText isLounder:self.liveSendBarView.louderBtn.selected] || !str.length) {
            self.liveSendBarView.inputTextField.fullText = nil;
            [self.liveSendBarView sendButtonNotUser];
        }
    } else {
        [self showDialogTipView:NSLocalizedStringFromSelf(@"SPEAK_TOO_FAST")];
    }
    self.roominDate = now;
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
    if (self.LSLiveAdvancedEmotionView == nil) {
        self.LSLiveAdvancedEmotionView = [LSLiveAdvancedEmotionView friendlyEmotionView:self];
        self.LSLiveAdvancedEmotionView.delegate = self;
        self.LSLiveAdvancedEmotionView.advanListItem = self.emotionManager.advanListItem;
        self.LSLiveAdvancedEmotionView.tipView.hidden = NO;
        self.LSLiveAdvancedEmotionView.tipLabel.text = self.emotionManager.advanListItem.errMsg;
        [self.LSLiveAdvancedEmotionView reloadData];
    }
    
    // 表情选择器
    if (self.LSPageChooseKeyboardView == nil) {
        self.LSPageChooseKeyboardView = [LSPageChooseKeyboardView LSPageChooseKeyboardView:self];
        self.LSPageChooseKeyboardView.delegate = self;
        [self.view addSubview:self.LSPageChooseKeyboardView];
        [self.LSPageChooseKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
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
        
        self.LSPageChooseKeyboardView.buttons = array;
    }
    // 请求表情列表
    [self getLiveRoomEmotionList];
}

#pragma mark - 初始化礼物列表选择控件
- (void)setupGiftListView {
    if (self.presentView == nil) {
        CGRect frame = CGRectMake(0, 0, 375, 272);
        self.presentView = [[PresentView alloc] initWithFrame:frame];
        self.presentView.manLevel = self.liveRoom.imLiveRoom.manLevel;
        self.presentView.loveLevel = self.liveRoom.imLiveRoom.loveLevel;
        self.presentView.presentDelegate = self;
    }

    if (self.backpackView == nil) {
        CGRect frame = CGRectMake(0, 0, 375, 272);
        self.backpackView = [[BackpackPresentView alloc] initWithFrame:frame];
        self.backpackView.manLevel = self.liveRoom.imLiveRoom.manLevel;
        self.backpackView.loveLevel = self.liveRoom.imLiveRoom.loveLevel;
        self.backpackView.backpackDelegate = self;
    }

    if (self.giftListView == nil) {
        self.giftListView = [LSPageChooseKeyboardView LSPageChooseKeyboardView:self];
        self.giftListView.delegate = self;
        [self.chooseGiftListView addSubview:self.giftListView];
        [self.giftListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.chooseGiftListView);
        }];
    }
    UIImage *bgSelectImage = [LSUIImageFactory createImageWithColor:COLOR_WITH_16BAND_RGB(0x2b2b2b) imageRect:CGRectMake(0, 0, 1, 1)];
    UIImage *bgNormalImage = [LSUIImageFactory createImageWithColor:COLOR_WITH_16BAND_RGB(0x000000) imageRect:CGRectMake(0, 0, 1, 1)];
    UIImage *normalImage = [UIImage imageNamed:@"live_giftList_normal"];
    UIImage *selectImage = [UIImage imageNamed:@"live_giftList_select"];
    UIColor *titleNormalColor = COLOR_WITH_16BAND_RGB_ALPHA(0x59ffffff);
    UIColor *titlrSelectColor = COLOR_WITH_16BAND_RGB(0xf7cd3a);
    NSString *titleText = NSLocalizedStringFromSelf(@"STORE");

    NSMutableArray *array = [NSMutableArray array];
    UIButton *button = [self setupChooserBarBtnType:1 normalImage:normalImage selectImage:selectImage bgNormalImage:bgNormalImage bgSelectImage:bgSelectImage titleText:titleText titleNormalColor:titleNormalColor titleSelectColor:titlrSelectColor];
    [array addObject:button];

    normalImage = [UIImage imageNamed:@"live_backlist_normal"];
    selectImage = [UIImage imageNamed:@"live_backlist_select"];
    titleText = NSLocalizedStringFromSelf(@"BACKPACK");
    UIButton *btn = [self setupChooserBarBtnType:1 normalImage:normalImage selectImage:selectImage bgNormalImage:bgNormalImage bgSelectImage:bgSelectImage titleText:titleText titleNormalColor:titleNormalColor titleSelectColor:titlrSelectColor];
    [array addObject:btn];

    self.giftListView.buttons = array;

    [self getLiveRoomGiftList];
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
            self.LSLiveAdvancedEmotionView.tipView.hidden = YES;
        } else {
            self.chatNomalEmotionView.tipView.hidden = YES;
        }
    }
}

#pragma mark - 请求账号余额
- (void)getLeftCreditRequest {
    GetLeftCreditRequest *request = [[GetLeftCreditRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, double credit) {
        NSLog(@"PlayViewController::getLeftCreditRequest( [获取账号余额请求结果], success:%d, errnum : %ld, errmsg : %@ credit : %f )", success, (long)errnum, errmsg, credit);
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

#pragma mark - 获取直播间礼物列表
- (void)getLiveRoomGiftList {

    // TODO:获取礼物列表
    [self.loadManager getLiveRoomAllGiftListHaveNew:NO
                                            request:^(BOOL success, NSMutableArray *liveRoomGiftList) {
                                                if (success) {
                                                    // 发送获取直播间礼物列表请求
                                                    [self sendLiveRoomGiftListRequest];
                                                }
                                            }];
}

- (void)sendLiveRoomGiftListRequest {
    [self.listManager theLiveGiftListRequest:self.liveRoom.roomId
                                finshHandler:^(BOOL success, NSMutableArray *roomShowGiftList, NSMutableArray *roomGiftList) {
                                    if (success) {
                                        self.presentView.giftIdArray = roomShowGiftList;

                                        if (self.loadManager.giftMuArray.count) {

                                            // 显示礼物列表
                                            [self.presentView showGiftListView];
                                        } else {
                                            // 显示没有礼物列表界面
                                            [self.presentView showNoListView];
                                        }

                                        // 回调获取礼物成功
                                        if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(onGetLiveRoomGiftList:)]) {
                                            [self.playDelegate onGetLiveRoomGiftList:[self.presentView.isPromoIndexArray mutableCopy]];
                                        }

                                    } else {
                                        // 显示请求礼物失败界面
                                        [self.presentView showRequestFailView];
                                    }

                                }];
}

- (void)sendBackpackGiftListRequest {
    // TODO:请求背包礼物列表
    [self.backGiftManager getBackpackListRequest:^(BOOL success, NSMutableArray *backArray) {
        if (success) {

            if (backArray.count) {
                [self.backpackView showGiftListView];
                self.backpackView.giftIdArray = backArray;

            } else {
                // 显示没有背包礼物列表
                [self.backpackView showNoListView];
            }

        } else {
            // 显示获取背包礼物失败
            [self.backpackView showRequestFailView];
        }
    }];
}

#pragma mark - 直播间信息
- (void)setLiveRoom:(LiveRoom *)liveRoom {
    self.liveVC.liveRoom = liveRoom;
}

- (LiveRoom *)liveRoom {
    return self.liveVC.liveRoom;
}

#pragma mark - LiveViewControllerDelegate
// 返回更新用户信用点余额
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

// 开始推流才初始化返点控件
- (void)liveViewIsPlay:(LiveViewController *)vc {
    // 初始化返点控件
    [self initRewardView];
}

#pragma mark - 请求数据逻辑
- (BOOL)sendRoomGiftFormAllGiftItem:(AllGiftItem *)item andGiftNum:(int)giftNum starNum:(int)starNum endNum:(int)endNum isBack:(BOOL)isBack {
    NSLog(@"PlayViewController::sendRoomGiftFormLiveItem( "
           "[发送礼物请求], "
           "roomId : %@, giftId : %@, giftNum : %d, starNum : %d, endNum : %d  multi_click_id : %d )",
          self.liveRoom.imLiveRoom.roomId, item.infoItem.giftId, giftNum, starNum, endNum, self.clickId);

    BOOL bFlag = YES;

    SendGiftItem *sendItem = [[SendGiftItem alloc] initWithGiftItem:item andGiftNum:giftNum starNum:starNum endNum:endNum clickID:self.clickId roomID:self.liveRoom.roomId isBackPack:isBack];

        if (isBack) {
            // 发送类型
            int type = [self.backGiftManager sendBackpackGiftWithSendGiftItem:sendItem];
            
            // 发送背包礼物
            if (type) {
                // 刷新背包礼物界面
                self.backpackView.giftIdArray = self.backGiftManager.roombackGiftArray;
                // 礼物送完了
                if (type == 2) {
                    self.comboBtn.hidden = YES;
                    self.backpackView.sendView.hidden = NO;
                    bFlag = NO;
                }
                // 背包礼物没了
                if (!self.backpackView.giftIdArray.count) {
                    [self.backpackView showNoListView];
                }
                
            } else {
                
                // 礼物数量不够，发送失败
                NSString *tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DONT_HAVE_ENOUGH"), sendItem.giftItem.infoItem.name];
                [self showDialogTipView:tip];
                bFlag = NO;
            }
            
        } else {
            // 发送礼物列表礼物
            [self.sendGiftTheQueueManager sendLiveRoomGiftRequestWithGiftItem:sendItem];
        }
    
    return bFlag;
}

#pragma mark - SendGiftTheQueueManagerDelegate
// 发送大礼物失败 提示
- (void)sendGiftFailWithItem:(SendGiftItem *)item {

    NSString *tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"BIG_GIFT_SEND_FAIL"), item.giftItem.infoItem.name];
    [self showDialogTipView:tip];
}

// 信用点不足礼物发送失败 隐藏连击按钮
- (void)sendGiftNoCredit:(SendGiftItem *)item {
    self.comboBtn.hidden = YES;
    self.presentView.sendView.hidden = NO;
}

#pragma mark - LiveRoomCreditRebateManagerDelegate
- (void)updataCredit:(double)credit {
    [self.creditView userCreditChange:credit];
}

#pragma mark - IM回调
- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"PlayViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LiveViewController::onSendGift( [发送直播间礼物消息], errmsg : %@, credit : %f, rebateCredit : %f )", errmsg, credit, rebateCredit);
    dispatch_async(dispatch_get_main_queue(), ^{

        if (success) {
            
            if ( credit > 0 ) {
                self.liveRoom.imLiveRoom.rebateInfo.curCredit = rebateCredit;
                
                // 更新返点控件
                [self.rewardView updataCredit:rebateCredit];
            }
            
        } else if (errType == LCC_ERR_NO_CREDIT) {
            // 钱不够清队列
            [self.sendGiftTheQueueManager removeAllSendGift];
        }
    });
}

- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"PlayViewController::onLogin( [IM登录], errType : %d, errmsg : %@ )", errType, errmsg);
    [self sendBackpackGiftListRequest];
}

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LiveViewController::onSendToast( [发送直播间弹幕消息, %@], errmsg : %@, credit : %f, rebateCredit : %f )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errmsg, credit, rebateCredit);
    dispatch_async(dispatch_get_main_queue(), ^{

        if (success) {
            
            if ( credit > 0 ) {
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
        
        self.presentView.manLevel = level;
        self.backpackView.manLevel = level;
    });
}

- (void)onRecvLoveLevelUpNotice:(int)loveLevel {
    NSLog(@"PlayViewController::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知], loveLevel : %d )", loveLevel);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.presentView.loveLevel = loveLevel;
        self.backpackView.loveLevel = loveLevel;
    });
}

- (void)onRecvSendTalentNotice:(ImTalentReplyObject *)item {
    NSLog(@"PlayViewController::onRecvSendTalentNotice( [接收直播间才艺点播回复通知] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!(item.credit < 0)) {
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
  
    [[LSAnalyticsManager manager] reportActionEvent:BroadcastClickGiftList eventCategory:EventCategoryBroadcast];
    // 请求礼物列表
    [self sendLiveRoomGiftListRequest];

    // 隐藏底部输入框
    [self hiddenBottomView];

    // 随机礼物按钮默认选中礼物列表
    if (sender == self.randomGiftBtn) {
        [self.giftListView toggleButtonSelect:0];
    }

    // 显示礼物列表
    [self showChooseGiftListView];
}

- (IBAction)shareAction:(id)sender {
    [[LSAnalyticsManager manager] reportActionEvent:BroadcastClickShare eventCategory:EventCategoryBroadcast];
    // 隐藏底部输入框
    [self hiddenBottomView];
    
    [self showShareView];
}

#pragma mark - 界面显示/隐藏
- (void)showShareView {
    [self.view layoutIfNeeded];
    self.shareViewTop.constant = -self.shareViewHeight.constant;
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
//                         self.liveVC.tableSuperView.hidden = YES;
//                         self.liveVC.msgTipsView.hidden = YES;
                     }];
}

- (void)closeShareView {
    [self.view layoutIfNeeded];
    self.shareViewTop.constant = 0;
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self showBottomView];
//                         self.liveVC.tableSuperView.hidden = NO;
//                         if (self.liveVC.unReadMsgCount) {
//                             self.liveVC.msgTipsView.hidden = NO;
//                         }
                     }];
}

/** 显示信用详情 **/
- (void)showCreditView {
    [self.creditViewBottom uninstall];
    self.creditOffset = -234;
    [self.creditView mas_updateConstraints:^(MASConstraintMaker *make) {
        self.creditViewBottom = make.top.equalTo(self.view.mas_bottom).offset(self.creditOffset);
    }];
    WeakObject(self, waekSelf);
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];

                     }
                     completion:^(BOOL finished){
                         [waekSelf.userInfoManager getLiverInfo:waekSelf.loginManager.loginItem.userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
                             [waekSelf.creditView updateUserBalanceCredit:waekSelf.creditRebateManager.mCredit userInfo:item];
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
                     completion:^(BOOL finished){

                     }];
}

/** 显示礼物列表 **/
- (void)showChooseGiftListView {

    [self.view layoutIfNeeded];
    self.chooseGiftListViewTop.constant = -self.chooseGiftListViewHeight.constant;
    [UIView animateWithDuration:0.25
        animations:^{
            //            self.chooseGiftListView.transform = CGAffineTransformMakeTranslation(0, -self.chooseGiftListView.frame.size.height);
            [self.view layoutIfNeeded];
            [self.giftListView reloadData];
        }
        completion:^(BOOL finished) {
            self.liveVC.tableSuperView.hidden = YES;
            self.liveVC.msgTipsView.hidden = YES;
        }];
}

/** 收起礼物列表 **/
- (void)closeChooseGiftListView {

    [self.view layoutIfNeeded];
    self.chooseGiftListViewTop.constant = 0;
    [UIView animateWithDuration:0.25
        animations:^{
            //            self.chooseGiftListView.transform = CGAffineTransformIdentity;
            [self.view layoutIfNeeded];
        }
        completion:^(BOOL finished) {
            [self showBottomView];
            self.liveVC.tableSuperView.hidden = NO;
            if (self.liveVC.unReadMsgCount) {
                self.liveVC.msgTipsView.hidden = NO;
            }
            if (self.presentView.buttonBar.frame.size.height) {
                [self.presentView hideButtonBar];
            }
            if (self.backpackView.buttonBar.frame.size.height) {
                [self.backpackView hideButtonBar];
            }
        }];
}

/** 显示系统键盘 **/
- (void)showKeyboardView {
    self.liveSendBarView.inputTextField.userInteractionEnabled = YES;
    self.liveSendBarView.inputTextField.inputView = nil;
    [self.liveSendBarView.inputTextField becomeFirstResponder];
}

/** 显示表情选择 **/
- (void)showEmotionView {
    // 关闭系统键盘
    self.liveSendBarView.inputTextField.inputView = [[UIView alloc] init];
    [self.liveSendBarView.inputTextField resignFirstResponder];
    
    if (self.inputMessageViewBottom.constant != -self.LSPageChooseKeyboardView.frame.size.height) {
        // 未显示则显示
        [self moveInputBarWithKeyboardHeight:self.LSPageChooseKeyboardView.frame.size.height withDuration:0.25];
        
        [self.LSPageChooseKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputMessageView.mas_bottom);
        }];
        
        if (CrrSysVer < 10) {
            self.liveSendBarView.inputTextField.userInteractionEnabled = NO;
        }
    }
    [self.LSPageChooseKeyboardView reloadData];
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
    } else {
        // 关闭键盘输入
        [self.liveSendBarView.inputTextField resignFirstResponder];
    }
}

- (void)hiddenBottomView {
    // 隐藏底部输入框
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.inputMessageView.transform = CGAffineTransformMakeTranslation(0, 54);
                     }];
}

- (void)showBottomView {
    // 显示底部输入框
    [UIView animateWithDuration:0.2
                          delay:0.25
                        options:0
                     animations:^{
                         self.inputMessageView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

// 显示3秒toas提示控件
- (void)showDialogTipView:(NSString *)tipText {
    [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:tipText];
}

#pragma mark - LiveGiftDownloadManagerDelegate
- (void)downloadState:(DownLoadState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == DOWNLOADEND) {
            [self.presentView.collectionView reloadData];
            [self.backpackView.collectionView reloadData];
        }
    });
}

#pragma mark - 礼物列表界面回调(PresentViewDelegate)
- (void)presentViewShowBalance:(PresentView *)backpackView {
    //    [self closeChooseGiftListView];
    [[LSAnalyticsManager manager] reportActionEvent:BroadcastClickMyBalance eventCategory:EventCategoryBroadcast];
    [self.view bringSubviewToFront:self.backBtn];
    [self.view bringSubviewToFront:self.creditView];
    self.backBtn.hidden = NO;
    [self showCreditView];
}

- (void)presentViewSendBtnClick:(PresentView *)presentView andSender:(id)sender {
    self.sendBtn = sender;

    // 标记已经点击
    self.isFirstClick = YES;

    if (self.presentView.buttonBar.frame.size.height) {
        [self.presentView hideButtonBar];
    }

    // 个人信用点和返点
    double userCredit = self.creditRebateManager.mCredit + self.liveRoom.imLiveRoom.rebateInfo.curCredit;
    
    NSLog(@"PlayViewController::presentViewSendBtnClick mCredit:%@ curCredit:%@ userCredit:%@" ,@(self.creditRebateManager.mCredit),@(self.liveRoom.imLiveRoom.rebateInfo.curCredit),@(userCredit));
    
    if (presentView.isCellSelect) {
        // 判断本地信用点是否够送礼
        if (userCredit - presentView.selectCellItem.infoItem.credit > 0) {

            // 生成连击ID
            [self getTheClickID];

            if (presentView.selectCellItem.infoItem.type == GIFTTYPE_COMMON) {
                if (presentView.selectCellItem.infoItem.multiClick) {
                    self.presentView.sendView.hidden = YES;
                    presentView.comboBtn.hidden = NO;
                    // 连击礼物
                    [self presentViewComboBtnInside:presentView andSender:presentView.comboBtn];

                } else {
                    // 普通不连击礼物
                    _giftNum = [presentView.sendView.selectNumLabel.text intValue];
                    [self sendRoomGiftFormAllGiftItem:presentView.selectCellItem andGiftNum:_giftNum starNum:1 endNum:_giftNum isBack:NO];
                }

            } else {
                // 发送大礼物
                _giftNum = [presentView.sendView.selectNumLabel.text intValue];
                [self sendRoomGiftFormAllGiftItem:presentView.selectCellItem andGiftNum:_giftNum starNum:1 endNum:1 isBack:NO];
            }

        } else {
            if (self.dialogGiftAddCredit) {
                [self.dialogGiftAddCredit removeFromSuperview];
            }
            WeakObject(self, weakSelf);
            self.dialogGiftAddCredit = [DialogOK dialog];
            self.dialogGiftAddCredit.tipsLabel.text = NSLocalizedStringFromSelf(@"SENDGIFT_ERR_ADD_CREDIT");
            [self.dialogGiftAddCredit showDialog:self.liveRoom.superView
                                     actionBlock:^{
                                         NSLog(@"没钱了。。");
                                         [[LSAnalyticsManager manager] reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
                                         if ([weakSelf.playDelegate respondsToSelector:@selector(pushToAddCredit:)]) {
                                             [weakSelf.playDelegate pushToAddCredit:weakSelf];
                                         }
                                     }];

            // 钱不够 清队列
            [self.sendGiftTheQueueManager removeAllSendGift];
        }
    }
}

- (void)presentViewComboBtnInside:(PresentView *)presentView andSender:(id)sender {
    // 是否第一次点击
    if (self.isFirstClick) {
        _starNum = 1;
        _endNum = [presentView.sendView.selectNumLabel.text intValue];
        _giftNum = [presentView.sendView.selectNumLabel.text intValue];
        _totalGiftNum = [presentView.sendView.selectNumLabel.text intValue];

        self.isFirstClick = NO;

    } else {
        _starNum = _totalGiftNum + 1;
        _endNum = _totalGiftNum + [presentView.sendView.selectNumLabel.text intValue];
        _giftNum = [presentView.sendView.selectNumLabel.text intValue];
        _totalGiftNum = _totalGiftNum + [presentView.sendView.selectNumLabel.text intValue];
    }

    // 发送连击礼物请求
    [self sendRoomGiftFormAllGiftItem:presentView.selectCellItem
                           andGiftNum:_giftNum
                              starNum:_starNum
                               endNum:_endNum
                               isBack:NO];
    self.selectCellItem = presentView.selectCellItem;

    self.comboBtn = sender;
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_cambo_nomal"] forState:UIControlStateNormal];

    [sender stopCountDown];
    [sender startCountDownWithSecond:30];

    // 连击按钮倒计时改变回调
    WeakObject(self, weakSelf);
    [sender countDownChanging:^NSAttributedString *(CountTimeButton *countDownButton, NSInteger second) {
        countDownButton.titleLabel.numberOfLines = 0;

//        weakSelf.countdownSender = 1;

        return [weakSelf appendComboButtonTitle:[NSString stringWithFormat:@"%ld", (long)second]];
    }];

    // 连击按钮倒计时结束回调
    [sender countDownFinished:^NSAttributedString *(CountTimeButton *countDownButton, NSInteger second) {
        if (second <= 0.0) {
            weakSelf.comboBtn.hidden = YES;
            weakSelf.presentView.sendView.hidden = NO;

//            weakSelf.countdownSender = 0;
            weakSelf.isFirstClick = YES;

            weakSelf.starNum = 0;
            weakSelf.endNum = 0;
            weakSelf.giftNum = 0;
            weakSelf.totalGiftNum = 0;
        }

        return [weakSelf appendComboButtonTitle:@"30"];
    }];
}

- (void)presentViewComboBtnDown:(PresentView *)presentView andSender:(id)sender {
    self.comboBtn = sender;
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_cambo_hight"] forState:UIControlStateHighlighted];
}

- (void)presentViewdidSelectItemWithSelf:(PresentView *)presentView numberList:(NSMutableArray *)list atIndexPath:(NSIndexPath *)indexPath {

    if (self.presentRow != indexPath.row) {
        self.comboBtn.hidden = YES;
        self.presentView.sendView.hidden = NO;
        [presentView setupButtonBar:list];
        self.presentRow = indexPath.row;
    }
}

- (void)presentViewdidSelectGiftLevel:(int)level loveLevel:(int)loveLevel {

    if (level > self.liveRoom.imLiveRoom.manLevel) {

        NSString *manLevelTip = [NSString stringWithFormat:@"%@%d%@", NSLocalizedStringFromSelf(@"NO_TENOUGH_LEVEL"), level, NSLocalizedStringFromSelf(@"OR_HIGHER")];
        [self showDialogTipView:manLevelTip];

    } else if (loveLevel > self.liveRoom.imLiveRoom.loveLevel) {

        NSString *loveTip = [NSString stringWithFormat:@"%@%d%@", NSLocalizedStringFromSelf(@"NO_TENOUGH_LOVE"), loveLevel, NSLocalizedStringFromSelf(@"OR_HIGHER")];
        [self showDialogTipView:loveTip];
    }
}

- (void)presentViewReloadList:(PresentView *)presentView {
    // 请求所有礼物
    [self getLiveRoomGiftList];
}

- (void)presentViewDidScroll:(PresentView *)PresentViewView currentPageNumber:(NSInteger)page {
}

#pragma mark - 礼物背包界面回调(BackpackPresentViewDelegate)
- (void)backpackPresentViewShowBalance:(BackpackPresentView *)backpackView {
    //    [self closeChooseGiftListView];
    [[LSAnalyticsManager manager] reportActionEvent:BroadcastClickMyBalance eventCategory:EventCategoryBroadcast];
    [self.view bringSubviewToFront:self.backBtn];
    [self.view bringSubviewToFront:self.creditView];
    self.backBtn.hidden = NO;
    [self showCreditView];
}

- (void)backpackPresentViewSendBtnClick:(BackpackPresentView *)backpackView andSender:(id)sender {
    self.sendBtn = sender;
    self.isBackpackFirstClick = YES;

    if (self.backpackView.buttonBar.frame.size.height) {
        [self.backpackView hideButtonBar];
    }

    if (backpackView.isCellSelect) {
        // 生成连击ID
        [self getTheClickID];

        if (backpackView.selectCellItem.infoItem.type == GIFTTYPE_COMMON) {
            if (backpackView.selectCellItem.infoItem.multiClick) {
                // 连击礼物
                [self backpackPresentViewComboBtnInside:backpackView andSender:backpackView.comboBtn];

            } else {

                // 普通不连击礼物
                _giftNum = [backpackView.sendView.selectNumLabel.text intValue];
                [self sendRoomGiftFormAllGiftItem:backpackView.selectCellItem andGiftNum:_giftNum starNum:1 endNum:_giftNum isBack:YES];
            }

        } else {
            // 大礼物
            _giftNum = [backpackView.sendView.selectNumLabel.text intValue];
            [self sendRoomGiftFormAllGiftItem:backpackView.selectCellItem andGiftNum:_giftNum starNum:1 endNum:1 isBack:YES];
        }
    }
}

- (void)backpackPresentViewComboBtnInside:(BackpackPresentView *)backpackView andSender:(id)sender {
    // 是否第一次点击
    if (self.isBackpackFirstClick) {
        _starNum = 1;
        _endNum = [backpackView.sendView.selectNumLabel.text intValue];
        _giftNum = [backpackView.sendView.selectNumLabel.text intValue];
        _totalGiftNum = [backpackView.sendView.selectNumLabel.text intValue];

        self.isBackpackFirstClick = NO;

    } else {
        _starNum = _totalGiftNum + 1;
        _endNum = _totalGiftNum + [backpackView.sendView.selectNumLabel.text intValue];
        _giftNum = [backpackView.sendView.selectNumLabel.text intValue];
        _totalGiftNum = _totalGiftNum + [backpackView.sendView.selectNumLabel.text intValue];
    }

    // 发送连击礼物请求
    BOOL bFlag = [self sendRoomGiftFormAllGiftItem:backpackView.selectCellItem
                                        andGiftNum:_giftNum
                                           starNum:_starNum
                                            endNum:_endNum
                                            isBack:YES];
    self.selectCellItem = backpackView.selectCellItem;

    if (bFlag) {

        self.backpackView.sendView.hidden = YES;
        backpackView.comboBtn.hidden = NO;

        self.comboBtn = sender;
        [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_cambo_nomal"] forState:UIControlStateNormal];

        [sender stopCountDown];
        [sender startCountDownWithSecond:30];

        // 连击按钮倒计时改变回调
        WeakObject(self, weakSelf);
        [sender countDownChanging:^NSAttributedString *(CountTimeButton *countDownButton, NSInteger second) {
            countDownButton.titleLabel.numberOfLines = 0;
            //        weakSelf.countdownSender = 1;
            return [weakSelf appendComboButtonTitle:[NSString stringWithFormat:@"%ld", (long)second]];
        }];

        // 连击按钮倒计时结束回调
        [sender countDownFinished:^NSAttributedString *(CountTimeButton *countDownButton, NSInteger second) {
            if (second <= 0.0) {
                weakSelf.comboBtn.hidden = YES;
                weakSelf.backpackView.sendView.hidden = NO;
                //            weakSelf.countdownSender = 0;
                weakSelf.isFirstClick = YES;

                weakSelf.starNum = 0;
                weakSelf.endNum = 0;
                weakSelf.giftNum = 0;
                weakSelf.totalGiftNum = 0;
            }
            return [weakSelf appendComboButtonTitle:@"30"];
        }];
    }
}

- (void)backpackPresentViewComboBtnDown:(BackpackPresentView *)backpackView andSender:(id)sender {
    self.comboBtn = sender;
    [self.comboBtn setBackgroundImage:[UIImage imageNamed:@"Live_cambo_hight"] forState:UIControlStateHighlighted];
}

- (void)backpackPresentViewDidSelectItemWithSelf:(BackpackPresentView *)backpackView numberList:(NSMutableArray *)list atIndexPath:(NSIndexPath *)indexPath {

    if (self.backRow != indexPath.row) {
        self.comboBtn.hidden = YES;
        self.backpackView.sendView.hidden = NO;
        [backpackView setupButtonBar:list];
        self.backRow = indexPath.row;
    }
}

- (void)backpackPresentViewdidSelectGiftLevel:(int)level loveLevel:(int)loveLevel canSend:(BOOL)canSend {

    if (!canSend) {
        [self showDialogTipView:NSLocalizedStringFromSelf(@"CANNOT_SEND_TIP")];

    } else {

        if (level > self.liveRoom.imLiveRoom.manLevel) {
            NSString *manLevelTip = [NSString stringWithFormat:@"%@%d%@", NSLocalizedStringFromSelf(@"NO_TENOUGH_LEVEL"), level, NSLocalizedStringFromSelf(@"OR_HIGHER")];
            [self showDialogTipView:manLevelTip];

        } else if (loveLevel > self.liveRoom.imLiveRoom.loveLevel) {
            NSString *loveTip = [NSString stringWithFormat:@"%@%d%@", NSLocalizedStringFromSelf(@"NO_TENOUGH_LOVE"), loveLevel, NSLocalizedStringFromSelf(@"OR_HIGHER")];
            [self showDialogTipView:loveTip];
        }
    }
}

- (void)backpackPresentViewReloadList:(BackpackPresentView *)presentView {
    // 请求所有礼物
    [self getLiveRoomGiftList];
}

- (void)backpackPresentViewDidScroll:(BackpackPresentView *)backpackView currentPageNumber:(NSInteger)page {
}

#pragma mark - 连击
- (void)getTheClickID {
    // TODO:生成连击ID
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    long long totalMilliseconds = currentTime * 1000;
    self.clickId = totalMilliseconds % 10000;
}

#pragma mark - 富文本
- (NSMutableAttributedString *)appendComboButtonTitle:(NSString *)title {
    // TODO:连击按钮标题富文本
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:title
                                                                                        attributes:
                                                                                            @{NSFontAttributeName : ComboTitleFont,
                                                                                              NSForegroundColorAttributeName : [UIColor blackColor]}];
    [attributeString appendAttributedString:[self parseMessage:@" \n combo" font:[UIFont systemFontOfSize:18] color:[UIColor blackColor]]];

    return attributeString;
}

- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    // TODO:聊天富文本
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
        NSFontAttributeName : font,
        NSForegroundColorAttributeName : textColor
    }
                             range:NSMakeRange(0, attributeString.length)];
    return attributeString;
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
    if (self.shareView.frame.origin.y < SCREEN_HEIGHT) {
        // 收起分享界面
        [self closeShareView];
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

    if (LSPageChooseKeyboardView == self.LSPageChooseKeyboardView) {
        if (index == 0) {
            // 普通表情
            cls = [LSLiveStandardEmotionView class];

        } else if (index == 1) {
            // 高亲密度表情
            cls = [LSLiveAdvancedEmotionView class];
        }

    } else {
        if (index == 0) {
            cls = [PresentView class];
            if (self.comboBtn) {
                self.comboBtn.countDownFinished(self.comboBtn, 0);
                [self.comboBtn stop];
                self.comboBtn.hidden = YES;
                self.comboBtn = nil;
            }
        } else if (index == 1) {
            
            if (self.backGiftManager.roombackGiftArray.count > 0) {
                self.backpackView.giftIdArray = self.backGiftManager.roombackGiftArray;
            } else {
                // 请求背包礼物
                [self sendBackpackGiftListRequest];
            }
            cls = [BackpackPresentView class];
            if (self.comboBtn) {
                self.comboBtn.countDownFinished(self.comboBtn, 0);
                [self.comboBtn stop];
                self.comboBtn.hidden = YES;
                self.comboBtn = nil;
            }
        }
    }
    return cls;
}

- (UIView *)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView pageViewForIndex:(NSUInteger)index {
    UIView *view = nil;

    if (LSPageChooseKeyboardView == self.LSPageChooseKeyboardView) {
        if (index == 0) {
            view = self.chatNomalEmotionView;
            view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);

        } else if (index == 1) {

            view = self.LSLiveAdvancedEmotionView;
            view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);
        }
    } else {
        if (index == 0) {
            view = self.presentView;
        } else if (index == 1) {
            view = self.backpackView;
        }
    }

    return view;
}

- (void)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    if (LSPageChooseKeyboardView == self.LSPageChooseKeyboardView) {
        if (index == 0) {
            // 普通表情
            [self.chatNomalEmotionView reloadData];

        } else if (index == 1) {
            // 高级表情
            [self.LSLiveAdvancedEmotionView reloadData];
        }

    } else {
        if (index == 0) {
        
        } else if (index == 1) {
            
        }
    }
}

- (void)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView didShowPageViewForDisplay:(NSUInteger)index {
    if (LSPageChooseKeyboardView == self.LSPageChooseKeyboardView) {
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

    // Ensures that all pending layout operations have been completed

    if (height != 0) {

        // 弹出键盘
        self.liveVC.msgSuperViewTop.constant = 10 - height;
        self.inputMessageViewBottom.constant = -height;

        self.liveVC.barrageView.backgroundColor = Color(255, 255, 255, 0);
        self.liveVC.barrageView.layer.shadowColor = [UIColor clearColor].CGColor;

        bFlag = YES;

    } else {
        // 收起键盘
        self.inputMessageViewBottom.constant = -5;
        self.liveVC.msgSuperViewTop.constant = 5;

        //        self.liveVC.barrageView.backgroundColor = Color(255, 255, 255, 0.9);
        self.liveVC.barrageView.backgroundColor = self.liveVC.roomStyleItem.barrageBgColor; // Color(255, 255, 255, 0);
        self.liveVC.barrageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.liveVC.barrageView.layer.shadowOffset = CGSizeMake(0, 1);
        self.liveVC.barrageView.layer.shadowRadius = 1;
        self.liveVC.barrageView.layer.shadowOpacity = 0.5;
        
//        [self.emotionViewBottom uninstall];
        [self.LSPageChooseKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputMessageView.mas_bottom).offset(5);
        }];
    }

//    [UIView animateWithDuration:duration
//                     animations:^{
//                         // Make all constraint changes here, Called on parent view
//                         [self.view layoutIfNeeded];
//
//                     }
//                     completion:^(BOOL finished){
//
//                     }];
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
