//
//  PlayViewController.m
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PlayViewController.h"
#import <objc/runtime.h>

#import "LSLiveAdvancedEmotionView.h"
#import "LSLiveStandardEmotionView.h"
#import "RewardView.h"

#import "LiveModule.h"

#import "LiveStreamPlayer.h"
#import "CountTimeButton.h"

#import "LSFileCacheManager.h"
#import "LSChatEmotionManager.h"
#import "LSSessionRequestManager.h"
#import "SendGiftTheQueueManager.h"
#import "BackpackSendGiftManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "UserInfoManager.h"

#import "AllGiftItem.h"
#import "SendGiftItem.h"
#import "AudienModel.h"

#import "LSChatEmotion.h"
#import "LSChatMessageObject.h"
#import "LiveGiftListManager.h"

#import "DialogOK.h"
#import "DialogTip.h"

#import "TalentOnDemandViewController.h"

//#import "LSImManager.h"
#import "ZBLSImManager.h"

#define ComboTitleFont [UIFont boldSystemFontOfSize:30]
#define CrrSysVer [[UIDevice currentDevice] systemVersion].doubleValue

@interface PlayViewController () <UITextFieldDelegate, LSCheckButtonDelegate, ZBIMLiveRoomManagerDelegate, ZBIMManagerDelegate,
                                   LiveViewControllerDelegate, LSLiveStandardEmotionViewDelegate, LSPageChooseKeyboardViewDelegate, LSLiveAdvancedEmotionViewDelegate, LSChatTextViewDelegate, BackpackPresentViewDelegate, LiveSendBarViewDelegate, UIGestureRecognizerDelegate, LiveGiftDownloadManagerDelegate,ManDetailViewDelegate, LiveRoomCreditRebateManagerDelegate,LSCheckButtonDelegate>

/** IM管理器 **/
@property (nonatomic, strong) ZBLSImManager *imManager;

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

@property (nonatomic, assign) NSInteger backRow;

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

#pragma mark - 3秒toast控件
@property (nonatomic, strong) DialogTip *dialogTipView;
@property (strong) DialogOK *dialogGiftAddCredit;

#pragma mark - 用户信息管理器
@property (nonatomic, strong) UserInfoManager *userInfoManager;

// 返点详情约束
@property (nonatomic, assign) int manDetailOffset;
@property (strong) MASConstraint *manDetailViewBottom;
@property (strong) MASConstraint *emotionViewBottom;

@property (strong) NSDate *roominDate;

// 多功能按钮
@property (strong) SelectNumButton* buttonBar;
/*
 *  多功能按钮约束
 */
@property (strong) MASConstraint *buttonBarBottom;
@property (nonatomic, assign) int buttonBarHeight;

// 聊天框被选中名字
@property (nonatomic, copy) NSString *selectName;

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

    self.imManager = [ZBLSImManager manager];
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
    
    // 初始化控制变量
    self.isFirstLike = NO;    // 第一次点赞
    self.isKeyboradShow = NO; // 键盘是否弹出
    self.isMultiClick = NO;   // 是否是连击
    self.isComboing = NO;     // 是否正在连击
    
    // 记录连击ID初始化
    self.recordClickId = 0;

    self.presentRow = 0;
    self.backRow = 0;

    self.manDetailOffset = 0;
}

- (void)dealloc {
    NSLog(@"PlayViewController::dealloc()");

    // 移除直播间监听代理
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    [self.creditRebateManager removeDelegate:self];
    
    [self.sendGiftTheQueueManager removeAllSendGift];
    [self.backGiftManager.backGiftArray removeAllObjects];
    
    if (self.dialogGiftAddCredit) {
        [self.dialogGiftAddCredit removeFromSuperview];
    }
    
    // 停止连击
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
    self.chooseGiftListViewHeight.constant = SCREEN_WIDTH * 0.5 + 59;

    self.liveSendBarView.liveRoom = self.liveRoom;
    
    self.chatAudienceView.layer.cornerRadius = self.chatAudienceView.frame.size.height / 2;
    
    // 初始化聊天框被选中名字
    self.selectName = self.audienceNameLabel.text;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
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
    self.comboBtn.hidden = YES;
}

- (void)initialiseSubwidge {
    [super initialiseSubwidge];
    
    // 初始化表情控件
    [self setupEmotionInputView];
    
    // 初始化礼物列表
    [self setupGiftListView];
    
    // 初始化信用点详情控件
    [self initManDetailView];
    
    // 初始化多功能按钮
    [self setupButtonBar];
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化输入框
    [self setupInputMessageView];

    // 初始化信用点详情约束
    [self setupManDetailView];
}

#pragma mark - 多功能按钮管理
- (void)setupButtonBar:(NSArray *)audienceArray {
    
    [self.buttonBar removeAllButton];
    
    UIImage *normalImage = [LSUIImageFactory createImageWithColor:Color(41, 122, 243, 0.81) imageRect:CGRectMake(0, 0, 1, 1)];
    
    NSMutableArray *chatNameArray = [[NSMutableArray alloc] init];
    [chatNameArray addObjectsFromArray:audienceArray];
    
    AudienModel *item = [[AudienModel alloc] init];
    item.nickName = NSLocalizedStringFromSelf(@"CHAT_AUDIENCE_ALL");
    [chatNameArray insertObject:item atIndex:0];
    
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < chatNameArray.count; i++) {
        
        AudienModel *model = chatNameArray[i];
        
        NSString *title = [NSString stringWithFormat:@"      %@",model.nickName];
        UIButton *firstNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        objc_setAssociatedObject(firstNumBtn, @"userid", model.userId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [firstNumBtn setTitle:title forState:UIControlStateNormal];
        [firstNumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        firstNumBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        firstNumBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [firstNumBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [firstNumBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
        [firstNumBtn addTarget:self action:@selector(selectFirstNum:) forControlEvents:UIControlEventTouchUpInside];
        [items addObject:firstNumBtn];
    }
    self.buttonBar.items = items;
    [self.buttonBar reloadData:YES];
    self.buttonBarHeight = 22 * (int)chatNameArray.count;
}

- (void)selectFirstNum:(id)sender {
    UIButton *btn = sender;
    self.liveVC.chatUserId = objc_getAssociatedObject(btn, @"userid");
    NSString *name = [btn.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.audienceNameLabel.text = [NSString stringWithFormat:@"@ %@",name];
    self.selectName = self.audienceNameLabel.text;
    [self hiddenButtonBar];
}

#pragma mark - LSCheckButtonDelegate
- (void)selectedChanged:(id)sender {
    
    if (sender == self.selectBtn) {
        if (self.selectBtn.selected) {
            [self setupButtonBar:self.liveVC.chatAudienceArray];
            [self showButtonBar];
        } else {
            [self hiddenButtonBar];
        }
    }
}

#pragma mark - 信用点详情界面
- (void)initManDetailView {
    
    self.manDetailView = [ManDetailView manDetailView];
    self.manDetailView.delegate = self;
    [self.view addSubview:self.manDetailView];
}

- (void)setupManDetailView {
    
    [self.manDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@SCREEN_WIDTH);
        make.height.equalTo(@173);
        make.left.equalTo(self.view);
        self.manDetailViewBottom = make.top.equalTo(self.view.mas_bottom).offset(self.manDetailOffset);
    }];
}

#pragma mark -  ManDetailViewDelegate
- (void)manDetailViewCloseAction:(ManDetailView *)manDetailView {
    if (self.manDetailOffset != 0) {
        [self closeManDetailView];
        self.liveVC.isCanTouch = YES;
    }
}

- (void)inviteToOneAction:(NSString *)userId userName:(NSString *)userName {
    [self.liveVC sendInstantInviteUser:userId userName:userName];
    [self closeManDetailView];
}

#pragma mark - 文本和表情输入控件管理
- (void)setupInputMessageView {
    self.liveSendBarView.delegate = self;
    self.inputMessageView.layer.shadowColor = Color(0, 0, 0, 0.7).CGColor;
    self.inputMessageView.layer.shadowOffset = CGSizeMake(0, -0.5);
    self.inputMessageView.layer.shadowOpacity = 0.5;
    self.inputMessageView.layer.shadowRadius = 1.0f;
    [self showInputMessageView];
}

- (void)showInputMessageView {
    self.chatBtn.hidden = NO;
    self.giftBtn.hidden = NO;

    self.liveSendBarView.hidden = YES;
}

- (void)hideInputMessageView {
    self.chatBtn.hidden = YES;
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

// 发送聊天
- (void)sendBarSendAction:(LiveSendBarView *)sendBarView {

    NSDate* now = [NSDate date];
    NSTimeInterval betweenTime = [now timeIntervalSinceDate:self.roominDate];
    
    if (betweenTime >= 1) {
        NSString *str =  [self.liveSendBarView.inputTextField.fullText stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([self.liveVC sendMsg:self.liveSendBarView.inputTextField.fullText] || !str.length) {
            self.liveSendBarView.inputTextField.fullText = nil;
        }

    } else {
        [self showDialogTipView:NSLocalizedStringFromSelf(@"SPEAK_TOO_FAST")];
    }
    self.roominDate = now;
}

#pragma mark - 初始化多功能按钮
- (void)setupButtonBar {
    self.buttonBar = [[SelectNumButton alloc] init];
    [self.view addSubview:self.buttonBar];
    [self.buttonBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        make.left.equalTo(self.chatAudienceView.mas_left);
        make.right.equalTo(self.chatAudienceView.mas_right);
        self.buttonBarBottom = make.bottom.equalTo(self.chatAudienceView.mas_bottom);
    }];
    self.buttonBar.isVertical = YES;
    self.buttonBar.clipsToBounds = YES;
    
    self.selectBtn.selectedChangeDelegate = self;
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
    if (self.backpackView == nil) {
        CGRect frame = CGRectMake(0, 0, 375, 272);
        self.backpackView = [[BackpackPresentView alloc] initWithFrame:frame];
        self.backpackView.backpackDelegate = self;
        [self.chooseGiftListView addSubview:self.backpackView];
        [self.backpackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.chooseGiftListView);
        }];
    }

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
    self.LSLiveAdvancedEmotionView.tipView.hidden = YES;
    self.chatNomalEmotionView.tipView.hidden = YES;
}

#pragma mark - 获取直播间礼物列表
- (void)getLiveRoomGiftList {
    // TODO:获取礼物列表
    [self.loadManager getLiveRoomAllGiftListHaveNew:NO
                                            request:^(BOOL success, NSMutableArray *liveRoomGiftList) {
                                                if (success) {
                                                    // 发送获取直播间礼物列表请求
                                                    [self sendBackpackGiftListRequest];
                                                }
                                            }];
}

- (void)sendBackpackGiftListRequest {
    // TODO:请求背包礼物列表
    [self.backGiftManager getGiftListWithRoomid:self.liveRoom.roomId finshCallback:^(BOOL success, NSMutableArray *backArray) {
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

// 开始推流
- (void)liveViewIsPlay:(LiveViewController *)vc {

}

// 发送关闭直播间
- (void)liveRoomIsClose:(LiveViewController *)vc {
    if ([self.playDelegate respondsToSelector:@selector(onCloseLiveRoom:)]) {
        [self.playDelegate onCloseLiveRoom:self];
    }
}

- (void)audidenveViewDidSelectItem:(AudienModel *)model indexPath:(NSIndexPath *)indexPath {
    if (model.userId.length) {
        if (self.manDetailOffset < 0) {
            [self closeManDetailView];
        } else {
            [self.manDetailView updateManDataInfo:model];
            [self showManDetailView];
        }
    }
}

#pragma mark - IM请求
- (BOOL)sendRoomGiftFormAllGiftItem:(AllGiftItem *)item andGiftNum:(int)giftNum starNum:(int)starNum endNum:(int)endNum isBack:(BOOL)isBack {
    NSLog(@"PlayViewController::sendRoomGiftFormLiveItem( "
           "[发送礼物请求], "
           "roomId : %@, giftId : %@, giftNum : %d, starNum : %d, endNum : %d  multi_click_id : %d )",
          self.liveRoom.roomId, item.infoItem.giftId, giftNum, starNum, endNum, self.clickId);

    BOOL bFlag = YES;

    SendGiftItem *sendItem = [[SendGiftItem alloc] initWithGiftItem:item andGiftNum:giftNum starNum:starNum endNum:endNum clickID:self.clickId roomID:self.liveRoom.roomId isBackPack:isBack];

        // 发送类型
        int type = [self.backGiftManager sendBackpackGiftWithSendGiftItem:sendItem];
    
        // 发送背包礼物
        if (type) {
            // 刷新背包礼物界面
            self.backpackView.giftIdArray = self.backGiftManager.backGiftArray;
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
    
    return bFlag;
}

#pragma mark - SendGiftTheQueueManagerDelegate
// 发送大礼物失败 提示
- (void)sendGiftFailWithItem:(SendGiftItem *)item {

    NSString *tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"BIG_GIFT_SEND_FAIL"), item.giftItem.infoItem.name];
    [self showDialogTipView:tip];
}

#pragma mark - IM回调
- (void)onZBLogin:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ZBImLoginReturnObject *)item {
    NSLog(@"PlayViewController::onZBLogin( [IM登录], errType : %d, errmsg : %@ )", errType, errmsg);
    // 断线重连,重新请求礼物列表
    [self getLiveRoomGiftList];
}

- (void)onZBLogout:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"PlayViewController::onZBLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);
}

- (void)onZBSendGift:(BOOL)success reqId:(unsigned int)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LiveViewController::onZBSendGift( [发送直播间礼物消息], %@ , errmsg : %@ )", (success == YES) ? @"成功" : @"失败" ,errmsg);
}

#pragma mark - 界面事件
- (IBAction)giftAction:(id)sender {
  
    if (self.buttonBar.frame.size.height) {
        [self hiddenButtonBar];
    }
    
    [[LiveModule module].analyticsManager reportActionEvent:BroadcastClickGiftList eventCategory:EventCategoryBroadcast];
    // 请求礼物列表
    [self sendBackpackGiftListRequest];

    // 隐藏底部输入框
    [self hiddenBottomView];

    // 显示礼物列表
    [self showChooseGiftListView];
}

- (IBAction)chatAction:(id)sender {
    
//    if (self.buttonBar.frame.size.height) {
//        [self hiddenButtonBar];
//    }
    
    if ([self.liveSendBarView.inputTextField canBecomeFirstResponder]) {
        [self.liveSendBarView.inputTextField becomeFirstResponder];
    }
}

#pragma mark - 界面显示/隐藏
/** 显示聊天选择框 **/
- (void)showButtonBar {
    self.liveVC.isCanTouch = NO;
    
    [self.buttonBarBottom uninstall];
    self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, -M_PI);
    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.buttonBarHeight));
        self.buttonBarBottom = make.bottom.equalTo(self.chatAudienceView.mas_top).offset(-2);
    }];
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.buttonBar.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         self.selectBtn.selected = YES;
                     }];
}

/** 收起聊天选择框 **/
- (void)hiddenButtonBar {
    [self.buttonBarBottom uninstall];
    self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, M_PI);
    [self.buttonBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        self.buttonBarBottom = make.bottom.equalTo(self.chatAudienceView.mas_bottom);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.buttonBar.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.selectBtn.selected = NO;
    }];
}

/** 显示男士资料 **/
- (void)showManDetailView {
    self.liveVC.isCanTouch = NO;
    
    [self.manDetailViewBottom uninstall];
    self.manDetailOffset = -173;
    [self.manDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
        self.manDetailViewBottom = make.top.equalTo(self.view.mas_bottom).offset(self.manDetailOffset);
    }];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                     }];
}

/** 收起男士资料 **/
- (void)closeManDetailView {
    [self.manDetailViewBottom uninstall];
    self.manDetailOffset = 0;
    [self.manDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
        self.manDetailViewBottom = make.top.equalTo(self.view.mas_bottom).offset(self.manDetailOffset);
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
    self.liveVC.isCanTouch = NO;
    
    [self.view layoutIfNeeded];
    self.chooseGiftListViewTop.constant = -self.chooseGiftListViewHeight.constant;
    [UIView animateWithDuration:0.25
        animations:^{
            //            self.chooseGiftListView.transform = CGAffineTransformMakeTranslation(0, -self.chooseGiftListView.frame.size.height);
            [self.view layoutIfNeeded];
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
            [self.backpackView.collectionView reloadData];
        }
    });
}

#pragma mark - 礼物背包界面回调(BackpackPresentViewDelegate)
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
                [self sendRoomGiftFormAllGiftItem:backpackView.selectCellItem andGiftNum:_giftNum starNum:1 endNum:_giftNum isBack:NO];
            }

        } else {
            // 大礼物
            _giftNum = [backpackView.sendView.selectNumLabel.text intValue];
            [self sendRoomGiftFormAllGiftItem:backpackView.selectCellItem andGiftNum:_giftNum starNum:1 endNum:1 isBack:NO];
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
                                            isBack:NO];
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
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
        self.singleTap.delegate = nil;
    }
}

- (void)singleTapAction {
    // 单击关闭输入
    [self closeAllInputView];

    // 收起礼物列表
    if (self.chooseGiftListView.frame.origin.y < SCREEN_HEIGHT) {
        [self closeChooseGiftListView];
    }
    
    // 收起聊天选择框
    if (self.buttonBar.frame.size.height) {
        [self hiddenButtonBar];
    }
    
    // 收起男士资料
    if (self.manDetailOffset != 0) {
        [self closeManDetailView];
    }
    
    self.liveVC.isCanTouch = YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // 底部控件弹起时,触发手势
    if (self.chooseGiftListView.frame.origin.y < SCREEN_HEIGHT || self.liveSendBarView.emotionBtn.selected == YES ||
        self.liveSendBarView.inputTextField.isFirstResponder || self.buttonBar.frame.size.height || self.manDetailOffset != 0) {
        
        // 如果点击范围在礼物列表上，手势不触发
        CGPoint pt = [touch locationInView:self.view];
        if (CGRectContainsPoint([self.chooseGiftListView frame], pt) || CGRectContainsPoint([self.manDetailView frame], pt)) {
            return NO;
        }
        
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
    }
}

- (void)LSPageChooseKeyboardView:(LSPageChooseKeyboardView *)LSPageChooseKeyboardView didShowPageViewForDisplay:(NSUInteger)index {
    if (LSPageChooseKeyboardView == self.LSPageChooseKeyboardView) {
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
        self.liveVC.msgSuperViewTop.constant =  - height;
        self.inputMessageViewBottom.constant = - height;

//        self.liveVC.barrageView.backgroundColor = Color(255, 255, 255, 0);
        self.liveVC.barrageView.layer.shadowColor = [UIColor clearColor].CGColor;
        self.liveVC.startOneView.hidden = YES;
        self.liveVC.isCanTouch = NO;
        bFlag = YES;

    } else {
        // 收起键盘
        self.inputMessageViewBottom.constant = 0;
        self.liveVC.msgSuperViewTop.constant = 0;

//        self.liveVC.barrageView.backgroundColor = self.liveVC.roomStyleItem.barrageBgColor;
        self.liveVC.barrageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.liveVC.barrageView.layer.shadowOffset = CGSizeMake(0, 1);
        self.liveVC.barrageView.layer.shadowRadius = 1;
        self.liveVC.barrageView.layer.shadowOpacity = 0.5;
        
        self.liveVC.startOneView.hidden = NO;
        
        [self.LSPageChooseKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
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
