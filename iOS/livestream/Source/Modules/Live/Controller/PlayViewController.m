//
//  PlayViewController.m
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PlayViewController.h"

#import "LiveFinshViewController.h"

#import "ChatFriendlyEmotionView.h"
#import "ChatEmotionChooseView.h"

#import "LiveModule.h"

#import "ChatTextLadyTableViewCell.h"
#import "ChatTextSelfTableViewCell.h"

#import "LiveStreamPlayer.h"
#import "CountTimeButton.h"

#import "FileCacheManager.h"
#import "ChatEmotionManager.h"
#import "SessionRequestManager.h"
#import "SendGiftTheQueueManager.h"
#import "BackpackSendGiftManager.h"

#import "AllGiftItem.h"
#import "SendGiftItem.h"

#import "ChatEmotion.h"
#import "ChatMessageObject.h"
#import "LiveGiftListManager.h"

#import "Dialog.h"
#import "DialogOK.h"
#import "DialogTip.h"

#import "TalentOnDemandViewController.h"

#define ComboTitleFont [UIFont boldSystemFontOfSize:30]
#define ToastUnderbalance @"Oops! Your don't have enough credits to send this pop-up message."

@interface PlayViewController () <UITextFieldDelegate, KKCheckButtonDelegate, IMLiveRoomManagerDelegate, IMManagerDelegate,
                                  PresentViewDelegate, IMLiveRoomManagerDelegate, LiveViewControllerDelegate, ChatEmotionChooseViewDelegate, ChatEmotionKeyboardViewDelegate, ChatFriendlyEmotionViewDelegate, ChatTextViewDelegate, GiftPresentViewDelegate, BackpackPresentViewDelegate, LiveSendBarViewDelegate, UIGestureRecognizerDelegate, LiveGiftDownloadManagerDelegate,SendGiftTheQueueManagerDelegate>

/** IM管理器 **/
@property (nonatomic, strong) IMManager *imManager;

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
@property (nonatomic, strong) ChatEmotionKeyboardView *chatEmotionKeyboardView;

/** 普通表情 */
@property (nonatomic, strong) ChatEmotionChooseView *chatNomalEmotionView;

/** 高亲密度表情 */
@property (nonatomic, strong) ChatFriendlyEmotionView *chatFriendlyEmotionView;

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

/** 本地信用点 */
@property (nonatomic, assign) float creditNum;

/** 本地用户返点 */
@property (nonatomic, assign) float cur_creditNum;

/** 表情转义符解析器 **/
@property (nonatomic, strong) ChatMessageObject *chatMessageObject;

/** 送礼队列管理类 **/
@property (nonatomic, strong) SendGiftTheQueueManager *sendGiftTheQueueManager;

/** 表情管理类 **/
@property (nonatomic, strong) ChatEmotionManager *emotionManager;

/** 背包礼物管理类 */
@property (nonatomic, strong) BackpackSendGiftManager *backGiftManager;

/** 接口管理器 **/
@property (nonatomic, strong) SessionRequestManager *sessionManager;

// 礼物列表管理器
@property (nonatomic, strong) LiveGiftListManager *listManager;

// 礼物下载管理器
@property (nonatomic, strong) LiveGiftDownloadManager *loadManager;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, assign) NSInteger presentRow;

@property (nonatomic, assign) NSInteger backRow;

@end

@implementation PlayViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PlayViewController::initCustomParam()");

    self.liveVC = [[LiveViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.liveVC];
    self.liveVC.liveDelegate = self;

    self.chatMessageObject = [[ChatMessageObject alloc] init];

    self.imManager = [IMManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    // 初始化管理器
    self.loginManager = [LoginManager manager];
    self.sessionManager = [SessionRequestManager manager];
    self.sendGiftTheQueueManager = [[SendGiftTheQueueManager alloc] init];
    self.emotionManager = [ChatEmotionManager emotionManager];
    self.backGiftManager = [BackpackSendGiftManager backpackGiftManager];
    self.listManager = [LiveGiftListManager manager];
    self.loadManager = [LiveGiftDownloadManager manager];
    self.loadManager.managerDelegate = self;

    // 初始化控制变量
    self.isFirstLike = NO;    // 第一次点赞
    self.isKeyboradShow = NO; // 键盘是否弹出
    self.isMultiClick = NO;   // 是否是连击
    self.isComboing = NO;     // 是否正在连击

    // 记录连击ID初始化
    self.recordClickId = 0;
    
    self.presentRow = 0;
    self.backRow = 0;
}

- (void)dealloc {
    NSLog(@"PlayViewController::dealloc()");

    // 移除直播间监听代理
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];

    [self.sendGiftTheQueueManager removeAllSendGift];
}

- (void)viewDidLoad {
    [super viewDidLoad];

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
    [self.view sendSubviewToBack:self.bottomPeopleView];
    [self.view bringSubviewToFront:self.liveVC.tableSuperView];
    [self.view bringSubviewToFront:self.liveVC.previewVideoView];

    // 初始化礼物列表界面
    //    self.chooseGiftListView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH * 0.5 + 99);
    self.chooseGiftListViewWidth.constant = SCREEN_WIDTH;
    self.chooseGiftListViewHeight.constant = SCREEN_WIDTH * 0.5 + 99;

    self.creditNum = 10000000;

    UIWindow *window = AppDelegate().window;
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setBackgroundColor:Color(0, 0, 0, 0.7)];
    [self.backBtn addTarget:self action:@selector(hiddenCreditView) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn.hidden = YES;
    [window addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window);
    }];

    self.creditView = [CreditView creditView];
    self.creditView.hidden = YES;
    [window addSubview:self.creditView];
    [self.creditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(window);
        make.height.equalTo(@(259));
        make.bottom.equalTo(window);
    }];

    // 加载普通表情
    [self.emotionManager reloadEmotion];
    
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

    self.bottomView.hidden = YES;
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
    
    // 停止连击
    [self.presentView.comboBtn stop];
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化输入框
    [self setupInputMessageView];

    // 初始化表情列表
    [self setupEmotionInputView];

    // 初始化礼物列表
    [self setupGiftListView];
}

- (void)hiddenCreditView {

    self.backBtn.hidden = YES;
    self.creditView.hidden = YES;
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
    
    float userCredit = self.liveRoom.roomCredit + self.liveRoom.imLiveRoom.rebateInfo.curCredit;
    if (userCredit) {
        
        if ([self.liveVC sendMsg:self.liveSendBarView.inputTextField.fullText isLounder:self.liveSendBarView.louderBtn.selected]) {
            self.liveSendBarView.inputTextField.fullText = nil;
            [self.liveSendBarView sendButtonNotUser];
        }
    } else {
        DialogOK *dialogOKView = [DialogOK dialog];
        dialogOKView.tipsLabel.text = ToastUnderbalance;
        [dialogOKView showDialog:self.view actionBlock:^{
            NSLog(@"没钱了。。");
        }];
    }
}

#pragma mark - 初始化表情输入控件
- (void)setupEmotionInputView {
    // 普通表情
    if (self.chatNomalEmotionView == nil) {
        self.chatNomalEmotionView = [ChatEmotionChooseView emotionChooseView:self];
        self.chatNomalEmotionView.delegate = self;
        self.chatNomalEmotionView.emotions = self.emotionManager.emotionArray;
        [self.chatNomalEmotionView reloadData];
    }

    // 高亲密度表情
    if (self.chatFriendlyEmotionView == nil) {
        self.chatFriendlyEmotionView = [ChatFriendlyEmotionView friendlyEmotionView:self];
        self.chatFriendlyEmotionView.delegate = self;
        self.chatFriendlyEmotionView.emotions = self.emotionManager.emotionArray;
        [self.chatFriendlyEmotionView reloadData];
    }

    // 表情选择器
    if (self.chatEmotionKeyboardView == nil) {
        self.chatEmotionKeyboardView = [ChatEmotionKeyboardView chatEmotionKeyboardView:self];
        self.chatEmotionKeyboardView.delegate = self;

        [self.view addSubview:self.chatEmotionKeyboardView];

        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.inputMessageView.mas_width);
            make.height.equalTo(@262);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.inputMessageView.mas_bottom).offset(5);
        }];
        
        NSMutableArray *array = [NSMutableArray array];
        
        UIColor *normalColor = [UIColor whiteColor];
        UIColor *selectColor = [UIColor blackColor];
        NSString *title = @"Standard";
        UIButton *button = [self setupChooserBarBtnType:0 normalImage:nil selectImage:nil bgNormalImage:nil bgSelectImage:nil titleText:title titleNormalColor:normalColor titleSelectColor:selectColor];
        [array addObject:button];

        title = @"Advanced";
        UIButton *btn = [self setupChooserBarBtnType:0 normalImage:nil selectImage:nil bgNormalImage:nil bgSelectImage:nil titleText:title titleNormalColor:normalColor titleSelectColor:selectColor];
        [array addObject:btn];

        self.chatEmotionKeyboardView.buttons = array;
    }
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
        self.giftListView = [ChatEmotionKeyboardView chatEmotionKeyboardView:self];
        self.giftListView.delegate = self;
        [self.chooseGiftListView addSubview:self.giftListView];
        [self.giftListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.chooseGiftListView);
        }];
    }
    UIImage *bgSelectImage = [[UIImage alloc] createImageWithColor:COLOR_WITH_16BAND_RGB(0x2b2b2b) imageRect:CGRectMake(0, 0, 1, 1)];
    UIImage *bgNormalImage = [[UIImage alloc] createImageWithColor:COLOR_WITH_16BAND_RGB(0x000000) imageRect:CGRectMake(0, 0, 1, 1)];
    UIImage *normalImage = [UIImage imageNamed:@"live_giftList_normal"];
    UIImage *selectImage = [UIImage imageNamed:@"live_giftList_select"];
    UIColor *titleNormalColor = COLOR_WITH_16BAND_RGB(0xffffff);
    UIColor *titlrSelectColor = COLOR_WITH_16BAND_RGB(0xf7cd3a);
    NSString *titleText = @"  Store";
    
    NSMutableArray *array = [NSMutableArray array];
    UIButton *button = [self setupChooserBarBtnType:1 normalImage:normalImage selectImage:selectImage bgNormalImage:bgNormalImage bgSelectImage:bgSelectImage titleText:titleText titleNormalColor:titleNormalColor titleSelectColor:titlrSelectColor];
    [array addObject:button];
    
    
    normalImage = [UIImage imageNamed:@"live_backlist_normal"];
    selectImage = [UIImage imageNamed:@"live_backlist_select"];
    titleText = @"  Backpack";
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
        [button setBackgroundImage:bgNormalImage forState:UIControlStateNormal];
        [button setBackgroundImage:bgSelectImage forState:UIControlStateSelected];
        [button setBackgroundImage:bgSelectImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button setTitleColor:selectColor forState:UIControlStateSelected];
    [button setTitleColor:selectColor forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setTitle:titleText forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = NO;
    
    return button;
}

#pragma mark - 获取直播间礼物列表
- (void)getLiveRoomGiftList {

    // TODO:获取礼物列表
    [self.loadManager getLiveRoomAllGiftListHaveNew:NO request:^(BOOL success, NSMutableArray *liveRoomGiftList) {
        if (success) {
            // 发送获取直播间礼物列表请求
            [self sendLiveRoomGiftListRequest];
        }
    }];

    // 判断本地是否有背包礼物
    if (!self.backGiftManager.roombackGiftArray && !self.backGiftManager.roombackGiftArray.count) {
        self.backpackView.requestFailView.hidden = NO;
        [self sendBackpackGiftListRequest];

    } else {
        self.backpackView.requestFailView.hidden = YES;
        self.backpackView.giftIdArray = self.backGiftManager.roombackGiftArray;
    }
}

- (void)sendLiveRoomGiftListRequest {
    [self.listManager theLiveGiftListRequest:self.liveRoom.roomId
                                finshHandler:^(BOOL success, NSMutableArray *roomShowGiftList, NSMutableArray *roomGiftList) {
                                    if (success) {
                                        self.presentView.giftIdArray = roomShowGiftList;

                                        if (self.loadManager.giftMuArray.count) {
                                            self.presentView.requestFailView.hidden = YES;
                                        } else {
                                            self.presentView.requestFailView.hidden = NO;
                                        }

                                        // 回调获取礼物成功
                                        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetLiveRoomGiftList:)]) {
                                            [self.delegate onGetLiveRoomGiftList:[self.presentView.canSendIndexArray mutableCopy]];
                                        }

                                    } else {
                                        self.presentView.requestFailView.hidden = NO;
                                    }

                                }];
}

- (void)sendBackpackGiftListRequest {
    // TODO:请求背包礼物列表
    [self.backGiftManager getBackpackListRequest:^(BOOL success, NSMutableArray *backArray) {
        if (success) {
            self.backpackView.requestFailView.hidden = YES;
            self.backpackView.giftIdArray = backArray;
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
    if( [self.delegate respondsToSelector:@selector(onReEnterRoom:)] ) {
        [self.delegate onReEnterRoom:self];
    }
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
            }

        } else {
            // 礼物数量不够，发送失败
            NSString *tip = [NSString stringWithFormat:@"You don't have enough %@ to send.", sendItem.giftItem.infoItem.name];
            [[DialogTip dialogTip] showDialogTip:self.view tipText:tip];
        }

    } else {
        // 发送礼物列表礼物
        [self.sendGiftTheQueueManager sendLiveRoomGiftRequestWithGiftItem:sendItem];
    }
    return bFlag;
}

#pragma mark - SendGiftTheQueueManagerDelegate
- (void)sendGiftFailWithItem:(SendGiftItem *)item {
    
    NSString *tip = [NSString stringWithFormat:@"Failed to send %@. Please try again.",item.giftItem.infoItem.name];
    [[DialogTip dialogTip] showDialogTip:self.view tipText:tip];
}

#pragma mark - IM回调
- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"PlayViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);
    // 移除所有送礼队列
    [self.sendGiftTheQueueManager removeAllSendGift];
}

#pragma mark - 界面事件
- (void)favourAction:(id)sender {
}

- (IBAction)giftAction:(id)sender {
    // 请求礼物列表
    [self sendLiveRoomGiftListRequest];

    // 隐藏底部输入框
    [self hiddenBottomView];

    // 显示礼物列表
    [self showChooseGiftListView];
}

#pragma mark - 界面显示/隐藏
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
            if (self.presentView.buttonBar.height) {
                [self.presentView hideButtonBar];
            }
            if (self.backpackView.buttonBar.height) {
                [self.backpackView hideButtonBar];
            }
        }];
}

/** 显示系统键盘 **/
- (void)showKeyboardView {
    self.liveSendBarView.inputTextField.inputView = nil;
    [self.liveSendBarView.inputTextField becomeFirstResponder];
}

/** 显示表情选择 **/
- (void)showEmotionView {
    // 关闭系统键盘
    [self.liveSendBarView.inputTextField resignFirstResponder];

    if (self.inputMessageViewBottom.constant != -self.chatEmotionKeyboardView.frame.size.height) {
        // 未显示则显示
        [self moveInputBarWithKeyboardHeight:self.chatEmotionKeyboardView.frame.size.height withDuration:0.25];
    }
    [self.chatEmotionKeyboardView reloadData];
}

- (void)closeAllInputView {
    // 关闭表情输入
    if (self.liveSendBarView.emotionBtn.selected == YES) {
        self.liveSendBarView.emotionBtn.selected = NO;
        [self moveInputBarWithKeyboardHeight:0 withDuration:0.25];
        [self showInputMessageView];
    }
    // 关闭键盘输入
    [self.liveSendBarView.inputTextField resignFirstResponder];
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
    [self closeChooseGiftListView];

    [self.creditView updateUserBalance:self.liveRoom.roomCredit];
    self.backBtn.hidden = NO;
    self.creditView.hidden = NO;
}

- (void)presentViewSendBtnClick:(PresentView *)presentView andSender:(id)sender {
    self.sendBtn = sender;
    
    // 标记已经点击
    self.isFirstClick = YES;

    if (self.presentView.buttonBar.height) {
        [self.presentView hideButtonBar];
    }

    // 个人信用点和返点
    float userCredit = self.liveRoom.roomCredit + self.liveRoom.imLiveRoom.rebateInfo.curCredit;
    
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
            
            DialogOK *dialogOKView = [DialogOK dialog];
            dialogOKView.tipsLabel.text = ToastUnderbalance;
            [dialogOKView showDialog:self.view actionBlock:^{
                NSLog(@"没钱了。。");
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
    [self sendRoomGiftFormAllGiftItem:presentView.selectCellItem andGiftNum:_giftNum starNum:_starNum endNum:_endNum isBack:NO];
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

- (void)presentViewReloadList:(PresentView *)presentView {
    // 请求所有礼物
    [self getLiveRoomGiftList];
}

- (void)presentViewDidScroll:(PresentView *)PresentViewView currentPageNumber:(NSInteger)page {
}

#pragma mark - 礼物背包界面回调(BackpackPresentViewDelegate)
- (void)backpackPresentViewShowBalance:(BackpackPresentView *)backpackView {
    [self closeChooseGiftListView];

    [self.creditView updateUserBalance:self.liveRoom.roomCredit];
    self.backBtn.hidden = NO;
    self.creditView.hidden = NO;
}

- (void)backpackPresentViewSendBtnClick:(BackpackPresentView *)backpackView andSender:(id)sender {
    self.sendBtn = sender;
    self.isBackpackFirstClick = YES;
    
    if (self.backpackView.buttonBar.height) {
        [self.backpackView hideButtonBar];
    }

    if (backpackView.isCellSelect) {
        // 生成连击ID
        [self getTheClickID];

        if (backpackView.selectCellItem.infoItem.type == GIFTTYPE_COMMON) {
            if (backpackView.selectCellItem.infoItem.multiClick) {
                self.backpackView.sendView.hidden = YES;
                backpackView.comboBtn.hidden = NO;
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
    [self sendRoomGiftFormAllGiftItem:backpackView.selectCellItem andGiftNum:_giftNum starNum:_starNum endNum:_endNum isBack:YES];
    self.selectCellItem = backpackView.selectCellItem;

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

#pragma mark - 普通表情选择回调 (ChatEmotionChooseViewDelegate)
- (void)chatEmotionChooseView:(ChatEmotionChooseView *)chatEmotionChooseView didSelectNomalItem:(NSInteger)item {
    if (self.liveSendBarView.inputTextField.fullText.length < 70) {
        // 插入表情描述到输入框
        ChatEmotion *emotion = [self.emotionManager.emotionArray objectAtIndex:item];
        [self.liveSendBarView.inputTextField insertEmotion:emotion];

        [self.liveSendBarView sendButtonCanUser];
    }
}

#pragma mark - 高亲密度表情选择回调 (ChatFriendlyEmotionViewDelegate)
- (void)chatFriendlyEmotionView:(ChatFriendlyEmotionView *)chatFriendlyEmotionView didSelectNomalItem:(NSInteger)item {
    if (self.liveSendBarView.inputTextField.fullText.length < 70) {
        // 插入表情描述到输入框
        ChatEmotion *emotion = [self.emotionManager.emotionArray objectAtIndex:item];
        [self.liveSendBarView.inputTextField insertEmotion:emotion];

        [self.liveSendBarView sendButtonCanUser];
    }
}

#pragma mark - 表情、礼物键盘选择回调 (ChatEmotionKeyboardViewDelegate)
- (NSUInteger)pagingViewCount:(ChatEmotionKeyboardView *)chatEmotionKeyboardView {
    return 2;
}

- (Class)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView classForIndex:(NSUInteger)index {
    Class cls = nil;

    if (chatEmotionKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
            // 普通表情
            cls = [ChatEmotionChooseView class];

        } else if (index == 1) {
            // 高亲密度表情
            cls = [ChatFriendlyEmotionView class];
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

- (UIView *)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView pageViewForIndex:(NSUInteger)index {
    UIView *view = nil;

    if (chatEmotionKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
            // 普通礼物列表
            view = self.chatNomalEmotionView;
            view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);

        } else if (index == 1) {
            // 背包礼物列表
            view = self.chatFriendlyEmotionView;
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

- (void)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    if (chatEmotionKeyboardView == self.chatEmotionKeyboardView) {
        if (index == 0) {
            // 普通表情
            [self.chatNomalEmotionView reloadData];

        } else if (index == 1) {
            // 高级表情
            [self.chatFriendlyEmotionView reloadData];
        }

    } else {
        if (index == 0) {
            //            [self.presentView reloadData];
        } else if (index == 1) {
            //            [self.backpackView reloadData];
        }
    }
}

- (void)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView didShowPageViewForDisplay:(NSUInteger)index {
    if (chatEmotionKeyboardView == self.chatEmotionKeyboardView) {
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
    [self.view layoutIfNeeded];

    if (height != 0) {

        // 弹出键盘
        self.liveVC.msgSuperViewTop.constant = 5 - height;
        self.inputMessageViewBottom.constant = -height;

        self.liveVC.barrageView.backgroundColor = Color(255, 255, 255, 0);
        self.liveVC.barrageView.layer.shadowColor = [UIColor clearColor].CGColor;

        bFlag = YES;

    } else {
        // 收起键盘
        self.inputMessageViewBottom.constant = -5;
        self.liveVC.msgSuperViewTop.constant = 5;
//        self.liveVC.barrageView.backgroundColor = Color(255, 255, 255, 0.9);
        self.liveVC.barrageView.backgroundColor = self.liveVC.roomStyleItem.barrageBgColor;// Color(255, 255, 255, 0);
        self.liveVC.barrageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.liveVC.barrageView.layer.shadowOffset = CGSizeMake(0, 1);
        self.liveVC.barrageView.layer.shadowRadius = 1;
        self.liveVC.barrageView.layer.shadowOpacity = 0.5;
    }

    [UIView animateWithDuration:duration
                     animations:^{
                         // Make all constraint changes here, Called on parent view
                         [self.view layoutIfNeeded];

                     }
                     completion:^(BOOL finished){

                     }];
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
