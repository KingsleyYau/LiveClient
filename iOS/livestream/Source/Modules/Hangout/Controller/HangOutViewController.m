//
//  HangOutViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangOutViewController.h"
#import "HangOutLiverViewController.h"
#import "HangOutUserViewController.h"
#import "LiveWebViewController.h"

#import "LSImManager.h"
#import "LSLoginManager.h"
#import "LSSessionRequestManager.h"
#import "LSGiftManager.h"
#import "LSChatEmotionManager.h"
#import "LiveStreamSession.h"
#import "LSUserInfoManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "HangoutMsgManager.h"
#import "LiveModule.h"
#import "LiveGobalManager.h"

#import "LSGiftManagerItem.h"
#import "AudienModel.h"
#import "GiftItem.h"

#import "HangOutControlView.h"
#import "SelectNumButton.h"
#import "DialogTip.h"
#import "DialogWarning.h"
#import "DialogOK.h"
#import "MsgTableViewCell.h"
#import "HangOutOpenDoorCell.h"
#import "BigGiftAnimationView.h"
#import "CreditView.h"
#import "HangoutGiftViewController.h"
#import "HangoutInvitePageViewController.h"
#import "HangOutFinshViewController.h"

#import "GetLeftCreditRequest.h"
#import "LSSendinvitationHangoutRequest.h"
#import "LSCancelInviteHangoutRequest.h"
#import "LSGetCanHangoutAnchorListRequest.h"
#import "LSDealKnockRequest.h"
#import "LSGetHangoutGiftListRequest.h"
#import "SendGiftTheQueueManager.h"
#import "LSAddCreditsViewController.h"

#import <objc/runtime.h>

#define MessageFontSize 16
#define MessageFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:MessageFontSize]

#define NameFontSize 14
#define NameFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:NameFontSize]

#define NameColor [LSColor colorWithIntRGB:255 green:210 blue:5 alpha:255]
#define MessageTextColor [UIColor whiteColor]

#define UnReadMsgCountFontSize 14
#define UnReadMsgCountColor NameColor
#define UnReadMsgCountFont [UIFont boldSystemFontOfSize:UnReadMsgCountFontSize]

#define UnReadMsgTipsFontSize 14
#define UnReadMsgTipsColor MessageTextColor
#define UnReadMsgTipsFont [UIFont boldSystemFontOfSize:UnReadMsgCountFontSize]

#define MessageCount 500

#define OpenDoorHeight 71

#define GiftViewHeight (SCREEN_WIDTH * 0.45 + 110)
#define InvitePageViewHeight (SCREEN_WIDTH * 0.45 + 110)

@interface HangOutViewController ()<IMManagerDelegate, IMLiveRoomManagerDelegate, HangOutLiverViewControllerDelegate,
                                    HangoutSendBarViewDelegate, LSCheckButtonDelegate, MsgTableViewCellDelegate, HangOutControlViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, HangOutOpenDoorCellDelegate
                                        ,HangoutGiftViewControllerDelegate, CreditViewDelegate, HangoutInviteDelegate, LiveGobalManagerDelegate, HangOutUserViewControllerDelegate, UIAlertViewDelegate>

// 管理空闲主播窗口队列
@property (nonatomic, strong) NSMutableArray<HangOutLiverViewController *> *hangoutArray;

// 管理正在使用的主播窗口字典
@property (nonatomic, strong) NSMutableDictionary *hangoutDic;

// 男士视屏窗口
@property (nonatomic, strong) HangOutUserViewController *userVC;

// 点击邀请按钮的主播窗口
@property (nonatomic, strong) HangOutLiverViewController *liverVC;

// 礼物列表控制器
@property (nonatomic, strong) HangoutGiftViewController *giftVC;
// 礼物列表顶部约束
@property (strong) MASConstraint *giftViewTop;

// 邀请主播列表控制器
@property (nonatomic, strong) HangoutInvitePageViewController *invitePageVC;
// 邀请列表顶部约束
@property (strong) MASConstraint *invitePageViewTop;

// 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;

// IM管理器
@property (nonatomic, strong) LSImManager *imManager;

// 请求管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

// 礼物列表下载管理器
@property (nonatomic, strong) LSGiftManager *giftDownloadManager;

// 表情列表管理器
@property (nonatomic, strong) LSChatEmotionManager *chatEmotionManager;

// 个人信息管理器
@property (nonatomic, strong) LSUserInfoManager *userInfoManager;

#pragma mark - 消息管理器
@property (nonatomic, strong) HangoutMsgManager *msgManager;

// 信用点管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditManager;

#pragma mark - 消息列表
/**
 用于显示的消息列表
 @description 注意在主线程操作
 */
@property (strong) NSMutableArray<MsgItem *> *msgShowArray;
/**
 用于保存真实的消息列表
 @description 注意在主线程操作
 */
@property (strong) NSMutableArray<MsgItem *> *msgArray;
/**
 是否需要刷新消息列表
 @description 注意在主线程操作
 */
@property (assign) BOOL needToReload;

// 多功能按钮
@property (strong) SelectNumButton* buttonBar;
/*
 *  多功能按钮约束
 */
@property (strong) MASConstraint *buttonBarBottom;
@property (nonatomic, assign) int buttonBarHeight;

// 聊天框被选中主播ID
@property (nonatomic, copy) NSString *chatUserId;
// 聊天指定接收者数组
@property (nonatomic, strong) NSMutableArray<NSString *> *atArray;
// 当前直播间主播队列
@property (nonatomic, strong) NSMutableArray<LSUserInfoModel *> *chatAnchorArray;

// 3秒提示框
@property (strong) DialogTip *dialogTipView;
// 警告提示框
@property (strong) DialogWarning *dialogView;
// 充值dialog
@property (strong) DialogOK *dialogGiftAddCredit;

// 控制台控件
@property (nonatomic, strong) HangOutControlView *controlView;

// 单击收起输入控件手势
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

#pragma mark - 大礼物展现界面
@property (nonatomic, strong) BigGiftAnimationView *giftAnimationView;

#pragma mark - 大礼物播放队列
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

#pragma mark - 礼物发送管理
// 是否私密发送
@property (nonatomic, assign) BOOL isPrivate;
// 礼物发送队列
@property (nonatomic, strong) SendGiftTheQueueManager *sendGiftManager;

// balanceView 充值view
@property (nonatomic, strong) CreditView *creditView;
@property (nonatomic, assign) int creditOffset;
@property (strong) MASConstraint *creditViewBottom;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;
// 是否已退入后台超时
@property (nonatomic) BOOL isTimeOut;

@property (nonatomic, strong) UIButton *backgroundBtn;

// 信用点不足提示
@property (nonatomic, strong) UIAlertView *alertView;

// 横竖分割线
@property (weak, nonatomic) IBOutlet UIView *verticalView;
@property (weak, nonatomic) IBOutlet UIView *horizontalView;

@property (nonatomic, assign) BOOL isFinshHangout;


@end

@implementation HangOutViewController

- (void)dealloc {
    NSLog(@"HangOutViewController:dealloc()");
    
    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    // 发送礼物管理器移除代理
    [self.sendGiftManager unInit];
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    [[LiveGobalManager manager] removeDelegate:self];
    
    [self.hangoutArray removeAllObjects];
    [self.hangoutDic removeAllObjects];
    
    if (self.dialogGiftAddCredit) {
        [self.dialogGiftAddCredit removeFromSuperview];
    }
    
    // 标记退出hangout直播间
    [LiveGobalManager manager].isHangouting = NO;
    
    // 发送退出多人互动直播间
    if (self.liveRoom.roomId.length > 0) {
        [self.imManager leaveHangoutRoom:self.liveRoom.roomId finishHandler:nil];
    }
    
    // 去除大礼物结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftAnimationIsOver" object:nil];
}

- (void)initCustomParam {
    [super initCustomParam];
    
    // 初始化控制器队列
    self.hangoutArray = [[NSMutableArray alloc] init];
    
    // 初始化代理管理器
    self.hangoutDic = [[NSMutableDictionary alloc] init];
    
    // 初始化登录管理器
    self.loginManager = [LSLoginManager manager];
    
    // 初始化im管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    // 初始化后台管理器
    [[LiveGobalManager manager] addDelegate:self];
    
    // 初始化请求管理器
    self.sessionManager = [LSSessionRequestManager manager];
    
    // 初始化礼物下载管理器
    self.giftDownloadManager = [LSGiftManager manager];
    
    // 初始化表情管理器
    self.chatEmotionManager = [LSChatEmotionManager emotionManager];
    
    // 初始化用户信息管理器
    self.userInfoManager = [LSUserInfoManager manager];
    
    // 初始化信用点管理器
    self.creditManager = [LiveRoomCreditRebateManager creditRebateManager];
    
    // 初始化文字管理器
    self.msgManager = [[HangoutMsgManager alloc] init];
    
    // 初始化消息
    self.msgArray = [NSMutableArray array];
    self.msgShowArray = [NSMutableArray array];
    self.needToReload = NO;
    
    // 3秒提示框
    self.dialogTipView = [DialogTip dialogTip];
    
    // @聊天管理数组
    self.atArray = [[NSMutableArray alloc] init];
    self.chatAnchorArray = [[NSMutableArray alloc] init];
    
    // 初始化大礼物播放队列
    self.bigGiftArray = [NSMutableArray array];
    
    // 初始化发送礼物管理器
    self.sendGiftManager = [SendGiftTheQueueManager manager];
    self.sendGiftManager.toUid = @"";
    
    // 标记正在hangout中
    [LiveGobalManager manager].isHangouting = YES;
    
    // 注册大礼物结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationWhatIs:) name:@"GiftAnimationIsOver" object:nil];
    
    // 注册前后台切换通知
    self.isBackground = NO;
    self.isTimeOut = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.isFinshHangout = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.liveRoom.superView = self.view;
    self.liveRoom.superController = self;
    
    // 缩小窗口按钮
    self.resetBtn.hidden = YES;
    
    // 赋值到全局变量, 用于后台计时操作
    [LiveGobalManager manager].liveRoom = self.liveRoom;
    
    // 初始化直播间文本样式
    [self setUpLiveRoomType];
    
    if (IS_IPHONE_X) {
        self.inputMessageViewBottom.constant = 35;
        self.videoBottomViewTop.constant = 44;
        self.openControlBtnBottom.constant = 93;
    } else {
        self.inputMessageViewBottom.constant = 0;
        self.videoBottomViewTop.constant = 0;
        self.openControlBtnBottom.constant = 58;
    }
    
    // 初始化充点提示控件
    self.alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"INVITE_HANGOUT_ADDCREDIT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"ADD_CREDITS", nil), nil];
    
    // 禁止锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)setupContainView {
    [super setupContainView];
    
    // 初始化窗口
    [self setupChildViewVC];
    
    // 初始化输入框
    [self setupInputMessageView];
    
    // 初始化多功能按钮
    [self setupButtonBar];
    
    // 初始化消息列表
    [self setupTableView];
    
    // 进入直播间 显示主播列表
    [self enterRoomAnchorList];
    
    // 进入直播间 显示礼物统计
    [self showBugforList];
    
    // 初始化控制台控件
    [self setupControlView];
    
    // 初始化信用点详情控件
    [self initCreditView];
    
    // 添加礼物视图
    [self setupGiftViewVC];
    
    // 添加邀请列表
    [self setupInvitePageVC];
    
    // 外部跳转邀请主播
    [self pushInviteAnchorHangout];
    
    // 初始化信用点详情约束
    [self setupCreditView];
    
    self.backgroundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backgroundBtn.hidden = YES;
    [self.backgroundBtn addTarget:self action:@selector(singleTapAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backgroundBtn];
    [self.backgroundBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 刷新吧台礼物统计默认图
    [self reloadWindowGiftCountView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 添加手势
    [self addSingleTap];
    
    // 请求账户余额
    [self getLeftCreditRequest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [self.dialogTipView removeShow];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    // 去除手势
    [self removeSingleTap];
    
    self.bigGiftArray = nil;
    [self.giftAnimationView removeFromSuperview];
    self.giftAnimationView = nil;
}

#pragma mark - 创建窗口界面
- (void)setupChildViewVC {
    
    CGFloat length = [UIScreen mainScreen].bounds.size.width / 2;
    for (int i = 0; i < 3; i++) {
        HangOutLiverViewController *liverVC = [[HangOutLiverViewController alloc] initWithNibName:nil bundle:nil];
        liverVC.index = i;
        liverVC.inviteDelegate = self;
        [self addChildViewController:liverVC];
        [self.videoBottomView addSubview:liverVC.view];
        
        switch (i) {
            case 1:{
                [liverVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.left.equalTo(self.videoBottomView);
                    make.width.height.equalTo(@(length));
                }];
            }break;
                
            case 2:{
                [liverVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.right.equalTo(self.videoBottomView);
                    make.width.height.equalTo(@(length));
                }];
            }break;
                
            default:{
                [liverVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.equalTo(self.videoBottomView);
                    make.width.height.equalTo(@(length));
                }];
            }break;
        }
        [self.hangoutArray addObject:liverVC];
    }
    
    self.userVC = [[HangOutUserViewController alloc] initWithNibName:nil bundle:nil];
    self.userVC.userDelegate = self;
    [self addChildViewController:self.userVC];
    [self.videoBottomView addSubview:self.userVC.view];
    self.userVC.liveRoom = self.liveRoom;
    [self.userVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.videoBottomView);
        make.width.height.equalTo(@(length));
    }];
    
    [self.videoBottomView bringSubviewToFront:self.verticalView];
    [self.videoBottomView bringSubviewToFront:self.horizontalView];
}

#pragma mark - 初始化礼物列表控制器
- (void)setupGiftViewVC {
    self.giftVC = [[HangoutGiftViewController alloc] initWithNibName:nil bundle:nil];
    self.giftVC.giftDelegate = self;
    self.giftVC.chatAnchorArray = self.chatAnchorArray;
    self.giftVC.liveRoom = self.liveRoom;
    self.giftVC.view.hidden = YES;
    [self addChildViewController:self.giftVC];
    [self.view addSubview:self.giftVC.view];
    [self.view bringSubviewToFront:self.giftVC.view];
    
    [self.giftVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        self.giftViewTop = make.top.equalTo(self.inputMessageView.mas_bottom);
        make.height.equalTo(@GiftViewHeight);
    }];
    [self.giftVC.view layoutSubviews];
    
    // 初始化是否私密
    self.isPrivate = self.giftVC.switchBtn.isOn;
}

#pragma mark - 获取所有礼物列表 刷新窗口统计礼物控件
- (void)reloadWindowGiftCountView {
    [self.giftDownloadManager getAllGiftList:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
        if (success) {
            if (self.hangoutDic.count > 0) {
                for (NSString *key in self.hangoutDic.allKeys) {
                    HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:key];
                    [liverVC reloadGiftCountView];
                }
            }
            [self.userVC reloadGiftCountView];
        }
    }];
}

#pragma mark - HangoutGiftViewControllerDelegate
- (void)showMyBalanceView:(HangoutGiftViewController *)vc {
    [self closeGiftView];
    [self showCreditView];
}

- (void)selectSecrettyState:(BOOL)state {
    self.isPrivate = state;
}

// 接收发送连击礼物代理
- (void)sendComboGiftForAnchor:(NSMutableArray *)anchors giftItem:(LSGiftManagerItem *)item clickId:(int)clickId {
    
    // 本地判断信用点是否够发礼物
    double credit = self.creditManager.mCredit - item.infoItem.credit;
    if (credit > 0) {
        
        if (anchors.count > 0) {
            for (NSString *anchorId in anchors) {
                HangOutLiverViewController *vc = [self.hangoutDic objectForKey:anchorId];
                if (vc) {
                    [vc sendHangoutComboGift:item clickId:clickId isPrivate:self.isPrivate];
                } else {
                    NSString *giftName = item.infoItem.name;
                    [self.userInfoManager getUserInfo:anchorId finishHandler:^(LSUserInfoModel * _Nonnull item) {
                        [self showdiaLog:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"SEND_GIFT_ANCHOR_LEAVE"),giftName ,item.nickName]];
                    }];
                }
            }
        } else {
            [self showdiaLog:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"SEND_GIFT_ERROR"),item.infoItem.name]];
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
                                     [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
                                     LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
                                     [weakSelf.navigationController pushViewController:vc animated:YES];
                                 }];
    }
}

// 接收发送礼物代理 (非连击礼物)
- (void)sendGiftForAnchor:(NSMutableArray *)anchors giftItem:(LSGiftManagerItem *)item clickId:(int)clickId {
    
    // 本地判断信用点是否够发礼物
    double credit = self.creditManager.mCredit - item.infoItem.credit;
    if (credit > 0) {
        
        if (item.infoItem.type == GIFTTYPE_CELEBRATE) {
            [self sendCelebrationGift:clickId item:item];
            
        } else {
            if (anchors.count > 0) {
                for (NSString *anchorId in anchors) {
                    HangOutLiverViewController *vc = [self.hangoutDic objectForKey:anchorId];
                    if (vc) {
                        [vc sendHangoutGift:item clickId:clickId isPrivate:self.isPrivate];
                    } else {
                        NSString *giftName = item.infoItem.name;
                        [self.userInfoManager getUserInfo:anchorId finishHandler:^(LSUserInfoModel * _Nonnull item) {
                            [self showdiaLog:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"SEND_GIFT_ANCHOR_LEAVE"),giftName ,item.nickName]];
                        }];
                    }
                }
            } else {
                [self showdiaLog:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"SEND_GIFT_ERROR"),item.infoItem.name]];
            }
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
                                     [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
                                     LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
                                     [weakSelf.navigationController pushViewController:vc animated:YES];
                                 }];
    }
}

#pragma mark - 初始化邀请列表控制器
- (void)setupInvitePageVC {
    self.invitePageVC = [[HangoutInvitePageViewController alloc] initWithNibName:nil bundle:nil];
    self.invitePageVC.inviteDelegate = self;
    self.invitePageVC.view.hidden = YES;
    [self addChildViewController:self.invitePageVC];
    [self.view addSubview:self.invitePageVC.view];
    
    [self.invitePageVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        self.invitePageViewTop = make.top.equalTo(self.inputMessageView.mas_bottom);
        make.height.equalTo(@(InvitePageViewHeight));
    }];
    [self.invitePageVC.view layoutSubviews];
    
    if (self.chatAnchorArray.count > 0) {
        NSMutableArray *anchors = [[NSMutableArray alloc] init];
        for (LSUserInfoModel *model in self.chatAnchorArray) {
            HangoutInviteAnchor *item = [[HangoutInviteAnchor alloc] init];
            item.anchorName = model.nickName;
            item.anchorId = model.userId;
            item.photoUrl = item.photoUrl;
            [anchors addObject:item];
        }
        self.invitePageVC.anchorIdArray = anchors;
    } else {
        self.invitePageVC.anchorIdArray = nil;
    }
}

#pragma mark - 信用点详情界面
- (void)initCreditView {
    self.creditOffset = 0;
    self.creditView = [CreditView creditView];
    self.creditView.delegate = self;
    self.creditView.hidden = YES;
    self.creditView.backButton.hidden = YES;
    [self.view addSubview:self.creditView];
}

- (void)setupCreditView {
    [self.creditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@SCREEN_WIDTH);
        make.height.equalTo(@234);
        make.left.equalTo(self.view);
        self.creditViewBottom = make.top.equalTo(self.inputMessageView.mas_bottom).offset(self.creditOffset);
    }];
    // 设置默认的用户id为登录使用用户的id
    self.creditView.userIdLabel.text = [NSString stringWithFormat:@"ID:%@",[LSLoginManager manager].loginItem.userId];
    NSString *nickName = [LSLoginManager manager].loginItem.nickName;
    if (nickName.length > 20) {
        nickName = [nickName substringToIndex:17];
        nickName = [NSString stringWithFormat:@"%@...",nickName];
    }
    self.creditView.nameLabel.text = nickName;
    WeakObject(self, waekSelf);
    [self.userInfoManager getFansBaseInfo:self.loginManager.loginItem.userId
                            finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                [waekSelf.creditView updateUserBalanceCredit:waekSelf.creditManager.mCredit userInfo:item];
                            }];
}

#pragma mark -  CreditViewDelegate
- (void)creditViewCloseAction:(CreditView *)creditView {
    [self closeCreditView];
}

- (void)rechargeCreditAction:(CreditView *)creditView {
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 初始化控制台
- (void)setupControlView {
    self.controlView = [HangOutControlView controlView];
    self.controlView.hidden = YES;
    self.controlView.delagate = self;
    [self.view addSubview:self.controlView];
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.videoBottomView.mas_bottom);
    }];
}

#pragma mark - HangOutControlViewDelegate
- (void)closeControlView:(HangOutControlView *)view {
    // TODO:关闭控制台界面
    self.controlView.hidden = YES;
    self.backgroundBtn.hidden = YES;
}

- (void)muteOrOpenMicrophone:(HangOutControlView *)view {
    // TODO:关闭话筒
    [self.userVC setThePublishMute:view.muteButton.isSelected];
    if (view.muteButton.isSelected) {
        [view.muteButton setImage:[UIImage imageNamed:@"Live_Mute_HangOut"] forState:UIControlStateNormal];
    } else {
        [view.muteButton setImage:[UIImage imageNamed:@"Live_Talkative_HangOut"] forState:UIControlStateNormal];
    }
    [view.muteButton setSelected:!view.muteButton.isSelected];
}

- (void)silentOrLoudSound:(HangOutControlView *)view {
    // TODO:关闭音量
    if (self.hangoutArray.count > 0) {
        for (HangOutLiverViewController *liverVC in self.hangoutArray) {
            [liverVC setThePlayMute:view.silentButton.isSelected];
        }
    }
    if (self.hangoutDic.count > 0) {
        NSArray *keys = self.hangoutDic.allKeys;
        for (int index = 0; index < keys.count; index++) {
            HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:keys[index]];
            [liverVC setThePlayMute:view.silentButton.isSelected];
        }
    }
    
    if (view.silentButton.isSelected) {
        [view.silentButton setImage:[UIImage imageNamed:@"Live_Silent_HangOut"] forState:UIControlStateNormal];
    } else {
        [view.silentButton setImage:[UIImage imageNamed:@"Live_Loud_HangOut"] forState:UIControlStateNormal];
    }
    [view.silentButton setSelected:!view.silentButton.isSelected];
}

- (void)endHangOutLiveRoom:(HangOutControlView *)view {
    // TODO:关闭Hangout直播间
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:YES completion:nil];
}

#pragma mark - 文本和表情输入控件管理
- (void)setupInputMessageView {
    self.hangoutSendBarView.delegate = self;
    self.inputMessageView.layer.shadowColor = Color(0, 0, 0, 0.7).CGColor;
    self.inputMessageView.layer.shadowOffset = CGSizeMake(0, -0.5);
    self.inputMessageView.layer.shadowOpacity = 0.5;
    self.inputMessageView.layer.shadowRadius = 1.0f;
    [self showInputMessageView];
    
    // 聊天输入框
    self.hangoutSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB_ALPHA(0x9EFFFFFF);
    self.hangoutSendBarView.inputTextField.textColor = COLOR_WITH_16BAND_RGB(0xffffff);
    // 隐藏表情按钮
    self.hangoutSendBarView.emotionBtnWidth.constant = 0;
}

- (void)showInputMessageView {
    self.chatBtn.hidden = NO;
    self.giftBtn.hidden = NO;
    
    self.hangoutSendBarView.hidden = YES;
}

- (void)hideInputMessageView {
    self.chatBtn.hidden = YES;
    self.giftBtn.hidden = YES;
    
    self.hangoutSendBarView.hidden = NO;
}

#pragma mark - 直播间文本样式
- (void)setUpLiveRoomType {
    self.roomStyleItem = [[RoomStyleItem alloc] init];
    // 消息列表界面
    self.roomStyleItem.myNameColor = Color(255, 109, 0, 1);
    self.roomStyleItem.liverNameColor = Color(93, 222, 126, 1);
    self.roomStyleItem.followStrColor = Color(249, 231, 132, 1);
    self.roomStyleItem.sendStrColor = Color(255, 210, 5, 1);
    self.roomStyleItem.chatStrColor = Color(255, 255, 255, 1);
    self.roomStyleItem.announceStrColor = Color(255, 109, 0, 1);
    self.roomStyleItem.riderStrColor = Color(255, 109, 0, 1);
    self.roomStyleItem.warningStrColor = Color(255, 77, 77, 1);
    self.roomStyleItem.textBackgroundViewColor = Color(191, 191, 191, 0.17);
}

#pragma mark - 初始化多功能按钮
- (void)setupButtonBar {
    self.chatAudienceView.layer.cornerRadius = self.chatAudienceView.frame.size.height / 2;
    
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

#pragma mark - 多功能按钮管理
- (void)setupButtonBar:(NSArray *)audienceArray {
    
    [self.buttonBar removeAllButton];
    
    UIImage *normalImage = [LSUIImageFactory createImageWithColor:COLOR_WITH_16BAND_RGB_ALPHA(0xCE05C775) imageRect:CGRectMake(0, 0, 1, 1)];
    UIImage *selectImage = [LSUIImageFactory createImageWithColor:COLOR_WITH_16BAND_RGB(0x0B7041) imageRect:CGRectMake(0, 0, 1, 1)];
    NSMutableArray *chatNameArray = [[NSMutableArray alloc] init];
    [chatNameArray addObjectsFromArray:audienceArray];
    
    LSUserInfoModel *item = [[LSUserInfoModel alloc] init];
    item.nickName = NSLocalizedStringFromSelf(@"CHAT_AUDIENCE_ALL");
    [chatNameArray insertObject:item atIndex:0];
    
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < chatNameArray.count; i++) {
        
        LSUserInfoModel *model = chatNameArray[i];
        
        NSString *title = [NSString stringWithFormat:@"      %@",model.nickName];
        UIButton *firstNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        objc_setAssociatedObject(firstNumBtn, @"userid", model.userId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [firstNumBtn setTitle:title forState:UIControlStateNormal];
        [firstNumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        firstNumBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        firstNumBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [firstNumBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        if ([self.chatUserId isEqualToString:model.userId] || (!self.chatUserId && !model.userId)) {
            [firstNumBtn setBackgroundImage:selectImage forState:UIControlStateNormal];
        } else {
            [firstNumBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
        }
        [firstNumBtn addTarget:self action:@selector(selectFirstNum:) forControlEvents:UIControlEventTouchUpInside];
        [items addObject:firstNumBtn];
    }
    self.buttonBar.items = items;
    [self.buttonBar reloadData:YES];
    self.buttonBarHeight = 22 * (int)chatNameArray.count;
}

- (void)selectFirstNum:(id)sender {
    UIButton *btn = sender;
    self.chatUserId = objc_getAssociatedObject(btn, @"userid");
    NSString *name = [btn.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.audienceNameLabel.text = [NSString stringWithFormat:@"@ %@",name];
    [self hiddenButtonBar];
}

#pragma mark - LSCheckButtonDelegate
- (void)selectedChanged:(id)sender {
    
    if (sender == self.selectBtn) {
        if (self.selectBtn.selected) {
            [self setupButtonBar:self.chatAnchorArray];
            [self showButtonBar];
        } else {
            [self hiddenButtonBar];
        }
    }
}

#pragma mark - 消息列表管理
- (void)setupTableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.msgTableView setTableFooterView:footerView];
    
    self.msgTableView.clipsToBounds = YES;
    self.msgTableView.backgroundView = nil;
    self.msgTableView.backgroundColor = [UIColor clearColor];
    self.msgTableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    [self.msgTableView registerClass:[MsgTableViewCell class] forCellReuseIdentifier:[MsgTableViewCell cellIdentifier]];
    [self.msgTableView registerClass:[HangOutOpenDoorCell class] forCellReuseIdentifier:[HangOutOpenDoorCell cellIdentifier]];
    
    self.msgTipsView.clipsToBounds = YES;
    self.msgTipsView.layer.cornerRadius = 6.0;
    self.msgTipsView.hidden = YES;
}


#pragma mark - 聊天文本消息管理
// 插入普通聊天消息
- (void)addChatMessageNickName:(NSString *)name text:(NSString *)text honorUrl:(NSString *)honorUrl
                        fromId:(NSString *)fromId at:(NSArray *)at {
    // 发送普通消息
    MsgItem *msgItem = [[MsgItem alloc] init];
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.usersType = UsersType_Me;
    } else {
        msgItem.usersType = UsersType_Liver;
    }
    msgItem.msgType = MsgType_Chat;
    msgItem.sendName = name;
    msgItem.text = text;
    msgItem.honorUrl = honorUrl;
    
    if (at.count > 0) {
        NSMutableArray *nameArray = [[NSMutableArray alloc] init];
        for (NSString *userId in at) {
            [self.userInfoManager getUserInfo:userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
                [nameArray addObject:item.nickName];
            }];
        }
        msgItem.nameArray = nameArray;
        if (text.length > 0) {
            NSMutableAttributedString *attributeString = [self.msgManager setupChatMessageStyle:self.roomStyleItem msgItem:msgItem];
            msgItem.attText = [self.chatEmotionManager parseMessageAttributedTextEmotion:attributeString font:MessageFont];
        }
        // 插入到消息列表
        [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
    } else {
        if (text.length > 0) {
            NSMutableAttributedString *attributeString = [self.msgManager setupChatMessageStyle:self.roomStyleItem msgItem:msgItem];
            msgItem.attText = [self.chatEmotionManager parseMessageAttributedTextEmotion:attributeString font:MessageFont];
        }
        // 插入到消息列表
        [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
    }
}

// 插入送礼消息
- (void)addGiftMessageSendName:(NSString *)sendName toUserId:(NSString *)toUserId giftID:(NSString *)giftID giftNum:(int)giftNum
                      giftName:(NSString *)giftName fromId:(NSString *)fromId {
    LSGiftManagerItem *item = [[LSGiftManager manager] getGiftItemWithId:giftID];
    
    MsgItem *msgItem = [[MsgItem alloc] init];
    // 判断是谁发送
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.usersType = UsersType_Me;
    } else {
        msgItem.usersType = UsersType_Liver;
    }
    msgItem.msgType = MsgType_Gift;
    msgItem.giftType = item.infoItem.type;
    msgItem.sendName = sendName;
    msgItem.giftName = giftName;
    
    LSGiftManagerItem *giftItem = [self.giftDownloadManager getGiftItemWithId:giftID];
    msgItem.smallImgUrl = giftItem.infoItem.smallImgUrl;
    
    msgItem.giftNum = giftNum;
    
    __block NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    if ([toUserId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.toName = self.loginManager.loginItem.nickName;
        attributeString = [self.msgManager setupGiftMessageStyle:self.roomStyleItem msgItem:msgItem];
        msgItem.attText = attributeString;
        [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
    } else {
        if (toUserId.length > 0) {
            [self.userInfoManager getUserInfo:toUserId finishHandler:^(LSUserInfoModel * _Nonnull item) {
                msgItem.toName = item.nickName;
                attributeString = [self.msgManager setupGiftMessageStyle:self.roomStyleItem msgItem:msgItem];
                msgItem.attText = attributeString;
                [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
            }];
        } else {
            attributeString = [self.msgManager setupGiftMessageStyle:self.roomStyleItem msgItem:msgItem];
            msgItem.attText = attributeString;
            [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
        }
    }
}

// 插入进入直播间消息
- (void)addJoinMessageNickName:(NSString *)nickName fromId:(NSString *)fromId {
    MsgItem *msgItem = [[MsgItem alloc] init];
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.usersType = UsersType_Me;
        
    } else {
        msgItem.usersType = UsersType_Liver;
    }
    msgItem.msgType = MsgType_Join;
    msgItem.sendName = nickName;
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
    msgItem.attText = attributeString;
    
    [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
}

#pragma mark - 消息列表界面处理
- (void)addMsg:(MsgItem *)item replace:(BOOL)replace scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated {
    
    // 计算文本高度
    if (item.msgType == MsgType_Knock || item.msgType == MsgType_Recommend) {
        item.containerHeight = OpenDoorHeight;
    } else {
        item.containerHeight = [self computeContainerHeight:item];
    }
    
    // 计算当前显示的位置
    NSInteger lastVisibleRow = -1;
    if (self.msgTableView.indexPathsForVisibleRows.count > 0) {
        lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
    }
    NSInteger lastRow = self.msgShowArray.count - 1;
    
    // 计算消息数量
    BOOL deleteOldMsg = NO;
    if (self.msgArray.count > 0) {
        if (replace) {
            deleteOldMsg = YES;
            // 删除一条最新消息
            [self.msgArray removeObjectAtIndex:self.msgArray.count - 1];
            
        } else {
            deleteOldMsg = (self.msgArray.count >= MessageCount);
            if (deleteOldMsg) {
                // 超出最大消息限制, 删除一条最旧消息
                [self.msgArray removeObjectAtIndex:0];
            }
        }
    }
    
    // 增加新消息
    [self.msgArray addObject:item];
    
    if (lastVisibleRow >= lastRow) {
        // 如果消息列表当前能显示最新的消息
        
        // 直接刷新
        [self.msgTableView beginUpdates];
        if (deleteOldMsg) {
            if (replace) {
                // 删除一条最新消息
                [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.msgShowArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                
            } else {
                // 超出最大消息限制, 删除列表一条旧消息
                
                [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        
        // 替换显示的消息列表
        self.msgShowArray = [NSMutableArray arrayWithArray:self.msgArray];
        
        // 增加列表一条新消息
        [self.msgTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.msgShowArray.count - 1 inSection:0]] withRowAnimation:(deleteOldMsg && replace) ? UITableViewRowAnimationNone : UITableViewRowAnimationBottom];
        
        [self.msgTableView endUpdates];
        
        // 拉到最底
        if (scrollToEnd) {
            [self scrollToEnd:animated];
        }
        
    } else {
        // 标记为需要刷新数据
        self.needToReload = YES;
        
        // 显示提示信息
        [self showUnReadMsg];
    }
}

- (void)scrollToEnd:(BOOL)animated {
    NSInteger count = [self.msgTableView numberOfRowsInSection:0];
    if (count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
        [self.msgTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)showUnReadMsg {
    self.unReadMsgCount++;
    
    if (!self.tableSuperView.hidden) {
        self.msgTipsView.hidden = NO;
    }
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld ", (long)self.unReadMsgCount]];
    [attString addAttributes:@{
                               NSFontAttributeName : UnReadMsgCountFont,
                               NSForegroundColorAttributeName : UnReadMsgCountColor
                               }
                       range:NSMakeRange(0, attString.length)];
    
    NSMutableAttributedString *attStringMsg = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"UnRead_Messages")];
    [attStringMsg addAttributes:@{
                                  NSFontAttributeName : UnReadMsgTipsFont,
                                  NSForegroundColorAttributeName : UnReadMsgTipsColor
                                  }
                          range:NSMakeRange(0, attStringMsg.length)];
    [attString appendAttributedString:attStringMsg];
    self.msgTipsLabel.attributedText = attString;
}

- (void)hideUnReadMsg {
    self.unReadMsgCount = 0;
    self.msgTipsView.hidden = YES;
}

- (IBAction)tapMsgTipsView:(id)sender {
    [self scrollToEnd:YES];
}

- (CGFloat)computeContainerHeight:(MsgItem *)item {
    CGFloat height = 0;
    CGFloat width = self.tableSuperView.frame.size.width;
    YYTextContainer *container = [[YYTextContainer alloc] init];
    if (item.msgType == MsgType_Gift) {
        width = width - 3;
    }
    container.size = CGSizeMake(width, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:item.attText];
    height = layout.textBoundingSize.height + 1;
    if (height < 22) {
        height = 22;
    }
    item.layout = layout;
    item.labelFrame = CGRectMake(0, 0, layout.textBoundingSize.width, height);
    return height;
}

#pragma mark - 消息列表列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = self.msgArray ? self.msgArray.count : 0;
    
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgItem *item = [self.msgShowArray objectAtIndex:indexPath.row];
    return item.containerHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // 数据填充
    if (indexPath.row < self.msgShowArray.count) {
        MsgItem *item = [self.msgShowArray objectAtIndex:indexPath.row];
        
        if (item.msgType == MsgType_Knock || item.msgType == MsgType_Recommend) {
            HangOutOpenDoorCell *msgCell = [tableView dequeueReusableCellWithIdentifier:[HangOutOpenDoorCell cellIdentifier]];
            msgCell.delagate = self;
            [msgCell updataChatMessage:item];
            cell = msgCell;
        } else {
            MsgTableViewCell *msgCell = [tableView dequeueReusableCellWithIdentifier:[MsgTableViewCell cellIdentifier]];
            msgCell.clipsToBounds = YES;
            msgCell.msgDelegate = self;
            [msgCell setTextBackgroundViewColor:self.roomStyleItem];
            [msgCell changeMessageLabelWidth:tableView.frame.size.width];
            [msgCell updataChatMessage:item];
            cell = msgCell;
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@""];
        if (!cell) {
            cell = [[UITableViewCell alloc] init];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger lastVisibleRow = -1;
    if (self.msgTableView.indexPathsForVisibleRows.count > 0) {
        lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
    }
    NSInteger lastRow = self.msgShowArray.count - 1;
    
    if (self.msgShowArray.count > 0 && lastVisibleRow <= lastRow) {
        // 已经拖动到最底, 刷新界面
        if (self.needToReload) {
            self.needToReload = NO;
            
            // 收起提示信息
            [self hideUnReadMsg];
            
            // 刷新消息列表
            self.msgShowArray = [NSMutableArray arrayWithArray:self.msgArray];
            [self.msgTableView reloadData];
            
            // 同步位置
            [self scrollToEnd:NO];
        }
    }
}

#pragma mark - MsgTableViewCellDelegate
- (void)msgCellRequestHttp:(NSString *)linkUrl {
    LiveWebViewController *webViewController = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
    webViewController.url = linkUrl;
    webViewController.isIntimacy = NO;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - HangOutOpenDoorCellDelegate
- (void)agreeAnchorKnock:(MsgItem *)item {
    [[LiveModule module].analyticsManager reportActionEvent:ClickOpenDoor eventCategory:EventCategoryBroadcast];
    
    HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:item.knockItem.anchorId];
    if (!liverVC) {
        // 处理主播敲门请求
        if (self.hangoutArray.count > 0) {
            [self sendAgreeKonck:item];
        } else {
            [self showdiaLog:NSLocalizedStringFromSelf(@"ROOM_IS_FULL")];
        }
    } else {
        switch ([liverVC getTheLiveType]) {
            case LIVETYPE_ONLIVRROOM:{
                [self showdiaLog:NSLocalizedStringFromSelf(@"ANCHOR_HAS_JOIN")];
            }break;
                
            case LIVETYPE_INVITING:{
                [self showdiaLog:NSLocalizedStringFromSelf(@"ANCHOR_IS_INVITINF")];
            }break;
                
            case LIVETYPE_OPENINGDOOR:{
                [self showdiaLog:NSLocalizedStringFromSelf(@"OPEN_DOOR_ALREADY")];
            }break;
                
            default:{
            }break;
        }
    }
}

- (void)inviteHangoutAnchor:(MsgItem *)item {
    [[LiveModule module].analyticsManager reportActionEvent:ClickHangOutNow eventCategory:EventCategoryBroadcast];
    // 处理主播推荐好友请求
    if (self.hangoutArray.count > 0) {
        HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:item.recommendItem.friendId];
        if (!liverVC) {
            HangOutLiverViewController *liverVC = self.hangoutArray[0];
            LSHangoutAnchorItemObject *obj = [[LSHangoutAnchorItemObject alloc] init];
            obj.anchorId = item.recommendItem.friendId;
            obj.nickName = item.recommendItem.friendNickName;
            
            LiveRoom *liveRoom = [[LiveRoom alloc] init];
            liveRoom.roomId = self.liveRoom.roomId;
            liveRoom.roomType = self.liveRoom.roomType;
            liveRoom.userId = item.recommendItem.friendId;
            liveRoom.userName = item.recommendItem.friendNickName;
            liveRoom.photoUrl = item.recommendItem.friendPhotoUrl;
            liverVC.liveRoom = liveRoom;
            
            // 将分配窗口移除空闲队列 并添加进窗口分发字典
            @synchronized(self.hangoutArray) {
                [self.hangoutArray removeObjectAtIndex:0];
            }
            @synchronized(self.hangoutDic) {
                [self.hangoutDic setObject:liverVC forKey:item.recommendItem.friendId];
            }
            
            [liverVC sendHangoutInvite:obj];
        }
    } else {
        [self showdiaLog:NSLocalizedStringFromSelf(@"ROOM_IS_FULL")];
    }
}

#pragma mark - 处理进入hangout直播间返回参数（直播间中主播列表、已收礼物列表）
- (void)enterRoomAnchorList {
    // IM10.3接口 返回其他主播数组是否有对象
    if (self.anchorArray.count > 0) {
        
        // 对比主播队列 如果本地主播信息与返回队列不同 则清除本地主播信息窗口
        [self compareIdUpdataHangoutDic:self.anchorArray];
        
        [self.chatAnchorArray removeAllObjects];
        
        // 如果有 遍历数组 分配窗口展示
        for (int index = 0; index < self.anchorArray.count; index++) {
            
            IMLivingAnchorItemObject *obj = self.anchorArray[index];
            if (obj.anchorStatus == LIVEANCHORSTATUS_ONLINE) {
                // 添加聊天@列表
                LSUserInfoModel *model = [[LSUserInfoModel alloc] init];
                model.userId = obj.anchorId;
                model.nickName = obj.nickName;
                model.photoUrl = obj.photoUrl;
                @synchronized(self) {
                    [self.chatAnchorArray addObject:model];
                }
            }
            
            LiveRoom *liveRoom = [[LiveRoom alloc] init];
            liveRoom.roomId = self.liveRoom.roomId;
            liveRoom.roomType = self.liveRoom.roomType;
            liveRoom.userId = obj.anchorId;
            liveRoom.userName = obj.nickName;
            liveRoom.photoUrl = obj.photoUrl;
            
            // 如果已分配窗口 则更新数据
            HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:obj.anchorId];
            if (liverVC) {
                liverVC.liveRoom = liveRoom;
                liverVC.anchorItem = obj;
                [liverVC showEnterRoomType];
            } else {
                // 如果未分配窗口 则分配空闲窗口
                if (self.hangoutArray.count > 0) {
                    HangOutLiverViewController *liverVC = self.hangoutArray.firstObject;
                    liverVC.liveRoom = liveRoom;
                    liverVC.anchorItem = obj;
                    [liverVC showEnterRoomType];
                    // 将分配窗口移除空闲队列 并添加进窗口分发字典
                    @synchronized(self.hangoutArray) {
                        [self.hangoutArray removeObjectAtIndex:0];
                    }
                    @synchronized(self.hangoutDic) {
                        [self.hangoutDic setObject:liverVC forKey:obj.anchorId];
                    }
                }
            }
        }
        // 遍历完 更新数组
        [self updataAnchorArray:self.chatAnchorArray];
    } else {
        self.anchorArray = [[NSMutableArray alloc] init];
    }
}

// TODO:本地主播队列与返回主播队列对比
- (void)compareIdUpdataHangoutDic:(NSMutableArray *)array {
    if (self.hangoutDic.count > 0) {
        NSMutableArray *idArray = [[NSMutableArray alloc] init];
        
        for (NSString *anchorId in self.hangoutDic.allKeys) {
            BOOL isEqualID = NO;
            for (int i = 0; i < array.count; i++) {
                IMLivingAnchorItemObject *obj = array[i];
                if ([anchorId isEqualToString:obj.anchorId]) {
                    isEqualID = YES;
                }
            }
            
            if (!isEqualID) {
                [idArray addObject:anchorId];
            }
        }
        
        for (NSString *anchorId in idArray) {
            HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:anchorId];
            [self resetAnchorWindow:liverVC userId:anchorId];
        }
    }
}

- (void)showBugforList {
    if (self.roomGiftList.count > 0) {
        for (IMRecvGiftItemObject *obj in self.roomGiftList) {
            if ([obj.userId isEqualToString:self.loginManager.loginItem.userId]) {
                [self.userVC showGiftCount:(NSMutableArray *)obj.buyforList];
            } else {
                HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:obj.userId];
                [liverVC showGiftCount:(NSMutableArray *)obj.buyforList];
            }
        }
    } else {
        self.roomGiftList = [[NSMutableArray alloc] init];
    }
}

- (void)pushInviteAnchorHangout {
    // TODO:邀请外部跳转主播
    if (self.inviteAnchorId.length > 0) {
        // 如果该主播已经在直播间 则不邀请
        HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:self.inviteAnchorId];
        if (!liverVC) {
            HangOutLiverViewController *liverVC = self.hangoutArray.firstObject;
            LiveRoom *liveRoom = [[LiveRoom alloc] init];
            liveRoom.roomId = self.liveRoom.roomId;
            liveRoom.roomType = self.liveRoom.roomType;
            liveRoom.userId = self.inviteAnchorId;
            liveRoom.userName = self.inviteAnchorName;
            liverVC.liveRoom = liveRoom;
            
            LSHangoutAnchorItemObject *obj = [[LSHangoutAnchorItemObject alloc] init];
            obj.anchorId = self.inviteAnchorId;
            obj.nickName = self.inviteAnchorName;
            [liverVC sendHangoutInvite:obj];
        }
    }
}

#pragma mark - HangoutInviteDelegate
- (void)didHangoutInviteAnchor:(HangoutInviteAnchor *)item {
    [[LiveModule module].analyticsManager reportActionEvent:ClickSendInviteBroadcast eventCategory:EventCategoryBroadcast];
    HangOutLiverViewController *liverVC = nil;
    if (self.hangoutDic.count > 0) {
        liverVC = [self.hangoutDic objectForKey:item.anchorId];
    }
    
    if (liverVC) {
        if ([liverVC getTheLiveType] == LIVETYPE_INVITING) {
            [self showdiaLog:NSLocalizedStringFromSelf(@"ANCHOR_IS_INVITINF")];
        } else if ([liverVC getTheLiveType] == LIVETYPE_ONLIVRROOM) {
            [self showdiaLog:NSLocalizedStringFromSelf(@"ANCHOR_HAS_JOIN")];
        }
    } else {
        LiveRoom *liveRoom = [[LiveRoom alloc] init];
        liveRoom.roomId = self.liveRoom.roomId;
        liveRoom.userId = item.anchorId;
        liveRoom.userName = item.anchorName;
        liveRoom.photoUrl = item.photoUrl;
        self.liverVC.liveRoom = liveRoom;
        
        // hangout邀请 分配空闲窗口
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (HangOutLiverViewController *vc in self.hangoutArray) {
            if (vc.index == self.liverVC.index) {
                @synchronized(self.hangoutDic) {
                    [self.hangoutDic setObject:self.liverVC forKey:item.anchorId];
                }
            } else {
                [array addObject:vc];
            }
        }
        @synchronized(self.hangoutArray) {
            self.hangoutArray = array;
        }
        
        LSHangoutAnchorItemObject *obj = [[LSHangoutAnchorItemObject alloc] init];
        obj.anchorId = item.anchorId;
        obj.nickName = item.anchorName;
        obj.photoUrl = item.photoUrl;
        [self.liverVC sendHangoutInvite:obj];
    }
    // 收起邀请列表
    [self closeInvitePageView];
}

#pragma mark - HangOutLiverViewControllerDelegate
// 点击hangout邀请按钮
- (void)inviteAnchorJoinHangOut:(HangOutLiverViewController *)liverVC {
    [[LiveModule module].analyticsManager reportActionEvent:ClickHangOutInviteBroadcaster eventCategory:EventCategoryBroadcast];
    self.liverVC = liverVC;
    // 显示邀请列表
    [self showInvitePageView];
}

// hangout邀请回调
- (void)invitationHangoutRequest:(HTTP_LCC_ERR_TYPE)errnum errMsg:(NSString *)errMsg anchorId:(NSString *)anchorId liverVC:(HangOutLiverViewController *)liverVC {
    if (errnum != HTTP_LCC_ERR_SUCCESS) {
        [self resetAnchorWindow:liverVC userId:anchorId];
        
        if (errnum == HTTP_LCC_ERR_NO_CREDIT) {
            [self.alertView show];
        } else {
            [self showdiaLog:errMsg];
        }
    }
}

// 取消hangout邀请
- (void)cancelInviteHangoutRequest:(BOOL)success errMsg:(NSString *)errMsg anchorId:(NSString *)anchorId liverVC:(HangOutLiverViewController *)liverVC {
    if (success) {
        [self resetAnchorWindow:liverVC userId:anchorId];
    } else {
        [self showdiaLog:errMsg];
    }
}

- (void)inviteHangoutNotAgreeNotice:(IMRecvDealInviteItemObject *)item liverVC:(HangOutLiverViewController *)liverVC {
    if (item.type == IMREPLYINVITETYPE_NOCREDIT) {
        [self.alertView show];
    } else if (item.type != IMREPLYINVITETYPE_CANCEL) {
        // 邀请主播Hangout拒绝或者超时回调
        MsgItem *msgModel = [[MsgItem alloc] init];
        msgModel.msgType = MsgType_Announce;
        msgModel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_HANGOUT_FAIL"),item.nickName];
        NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgModel];
        msgModel.attText = attributeString;
        [self addMsg:msgModel replace:NO scrollToEnd:YES animated:YES];
    }
    // 释放绑定的控制器
    [self resetAnchorWindow:liverVC userId:item.anchorId];
}

- (void)leaveHangoutRoomNotice:(HangOutLiverViewController *)liverVC {
    // 释放绑定的控制器
    [self resetAnchorWindow:liverVC userId:liverVC.liveRoom.userId];
}

- (void)liverLongPressTap:(HangOutLiverViewController *)liverVC isBoost:(BOOL)isBoost {
    CGFloat length = [UIScreen mainScreen].bounds.size.width / 2;
    if (isBoost) {
        if ([liverVC getTheLiveType] == LIVETYPE_ONLIVRROOM) {
            [self.videoBottomView bringSubviewToFront:self.resetBtn];
            [self.videoBottomView bringSubviewToFront:liverVC.view];
            
            self.resetBtn.hidden = NO;
            
            [liverVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@(length * 1.6));
            }];
        }
    } else {
        self.resetBtn.hidden = YES;
        
        [liverVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(length));
        }];
    }
}

#pragma mark - 管理主播窗口释放
- (void)resetAnchorWindow:(HangOutLiverViewController *)vc userId:(NSString *)userId {
    NSLog(@"释放正在使用窗口");
    if (userId.length) {
        @synchronized(self.hangoutArray) {
            [self.hangoutArray addObject:vc];
            // 窗口排序
            [self.hangoutArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                HangOutLiverViewController * oneVC = obj1;
                HangOutLiverViewController * twoVC = obj2;
                return [@(oneVC.index) compare:@(twoVC.index)];
            }];
        }
        @synchronized(self.hangoutDic) {
            [self.hangoutDic removeObjectForKey:userId];
        }
        NSLog(@"空闲窗口排序完成");
    }
}

#pragma mark - HangOutUserViewControllerDelegate
- (void)userLongPressTapBoost:(BOOL)isBoost {
    CGFloat length = [UIScreen mainScreen].bounds.size.width / 2;
    if (isBoost) {
        [self.videoBottomView bringSubviewToFront:self.resetBtn];
        [self.videoBottomView bringSubviewToFront:self.userVC.view];
        
        self.resetBtn.hidden = NO;
        [self.userVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(length * 1.6));
        }];
        
    } else {
        self.resetBtn.hidden = YES;
        [self.userVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(length));
        }];
    }
}

- (void)showManPushError:(NSString *)errmsg errNum:(LCC_ERR_TYPE)errNum {
    if (errNum == LCC_ERR_NO_CREDIT) {
        if (self.dialogGiftAddCredit) {
            [self.dialogGiftAddCredit removeFromSuperview];
        }
        WeakObject(self, weakSelf);
        self.dialogGiftAddCredit = [DialogOK dialog];
        self.dialogGiftAddCredit.tipsLabel.text = errmsg;
        [self.dialogGiftAddCredit showDialog:self.liveRoom.superView
                                 actionBlock:^{
                                     [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
                                     LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
                                     [weakSelf.navigationController pushViewController:vc animated:YES];
                                 }];
    } else {
        [self showdiaLog:errmsg];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:NO];
    }
}

#pragma mark - HangoutSendBarViewDelegate
- (void)sendBarEmotionAction:(HangoutSendBarView *)sendBarView isSelected:(BOOL)isSelected {
    // 表情/软键盘切换
}

- (void)sendBarSendAction:(HangoutSendBarView *)sendBarView {
    // 发送聊天
    NSString *str =  [sendBarView.inputTextField.fullText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([self sendMsg:sendBarView.inputTextField.fullText] || !str.length) {
        sendBarView.inputTextField.fullText = nil;
    }
}

#pragma mark - 播放大礼物
- (void)starBigAnimationWithGiftID:(NSString *)giftID {
    self.giftAnimationView = [BigGiftAnimationView sharedObject];
    self.giftAnimationView.userInteractionEnabled = NO;
    LSGiftManagerItem *item = [self.giftDownloadManager getGiftItemWithId:giftID];
    LSYYImage *image = [item bigGiftImage];
    // 判断本地文件是否损伤 有则播放 无则删除重下播放下一个
    if (image) {
        self.giftAnimationView.contentMode = UIViewContentModeScaleAspectFit;
        self.giftAnimationView.image = image;
        [self.view addSubview:self.giftAnimationView];
        [self.view bringSubviewToFront:self.giftAnimationView];
        [self.giftAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.view);
            make.width.height.equalTo(self.view);
        }];
        [self bringLiveRoomSubView];
        
    } else {
        [item download];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GiftAnimationIsOver" object:self userInfo:nil];
    }
}

// 遍历最外层控制器视图 将dialog放到最上层
- (void)bringLiveRoomSubView {
    for (UIView *view in self.view.subviews) {
        if (IsDialog(view)) {
            [self.view bringSubviewToFront:view];
        }
    }
}

#pragma mark - 通知大动画结束
- (void)animationWhatIs:(NSNotification *)notification {
    if (self.giftAnimationView) {
        [self.giftAnimationView removeFromSuperview];
        self.giftAnimationView = nil;
        
        if (self.bigGiftArray.count) {
            [self.bigGiftArray removeObjectAtIndex:0];
        }
    }
    if (self.bigGiftArray.count) {
        [self starBigAnimationWithGiftID:self.bigGiftArray[0]];
    }
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    if (_isBackground == NO) {
        _isBackground = YES;
        
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (_isBackground == YES) {
        _isBackground = NO;
        
        if (self.isTimeOut) {
            if (self.liveRoom) {
                NSLog(@"HangOutViewController::willEnterForeground ( [接收后台关闭直播间]  IsTimeOut : %@ )", (self.isTimeOut == YES) ? @"Yes" : @"No");
                // 弹出直播间关闭界面
                [self showFinshViewWithErrtype:HANGOUTERROR_BACKSTAGE errMsg:nil];
            }
        }
    }
}

#pragma mark - LiveGobalManagerDelegate
- (void)enterBackgroundTimeOut:(NSDate *_Nullable)time {
    
    self.isTimeOut = YES;
    
    if (self.liveRoom.roomId.length > 0) {
        // 发送IM退出直播间命令
        [[LSImManager manager] leaveHangoutRoom:self.liveRoom.roomId finishHandler:nil];
    }
    
    // 停止推流/置空
    [self.userVC stopPublish];
    self.userVC.liveRoom = nil;
    
    if (self.hangoutDic.count > 0) {
        NSArray *keys = self.hangoutDic.allKeys;
        for (NSString *key in keys) {
            HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:key];
            // 停止拉流/置空
            [liverVC resetPlayer];
            liverVC.liveRoom = nil;
        }
    }
    if (self.hangoutArray.count > 0) {
        for (HangOutLiverViewController *liverVC in self.hangoutArray) {
            // 停止拉流/置空
            [liverVC resetPlayer];
            liverVC.liveRoom = nil;
        }
    }
}

// 停止推拉流并显示结束直播页
- (void)stopLiveWithErrtype:(HANGOUTERROR)errType errMsg:(NSString *)errMsg {
    // 停止推流/置空
    [self.userVC stopPublish];
    self.userVC.liveRoom = nil;
    
    if (self.hangoutDic.count > 0) {
        NSArray *keys = self.hangoutDic.allKeys;
        for (NSString *key in keys) {
            HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:key];
            // 停止拉流/置空
            [liverVC resetPlayer];
            liverVC.liveRoom = nil;
        }
    }
    
    [self showFinshViewWithErrtype:errType errMsg:errMsg];
}

#pragma mark - 界面事件
- (IBAction)chatBtnAction:(id)sender {
    if ([self.hangoutSendBarView.inputTextField canBecomeFirstResponder]) {
        [self.hangoutSendBarView.inputTextField becomeFirstResponder];
    }
}

- (IBAction)giftBtnAction:(id)sender {
    [self showGiftView];
}

- (IBAction)openControlAction:(id)sender {
    self.backgroundBtn.hidden = NO;
    self.controlView.hidden = NO;
    [self.view bringSubviewToFront:self.controlView];
}

- (IBAction)resetViewAction:(id)sender {
    self.resetBtn.hidden = YES;
    CGFloat length = [UIScreen mainScreen].bounds.size.width / 2;
    
    if (self.hangoutDic.count > 0) {
        NSArray *keys = self.hangoutDic.allKeys;
        for (NSString *key in keys) {
            HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:key];
            [liverVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@(length));
            }];
            liverVC.isBoostView = NO;
        }
    }
    
    [self.userVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(length));
    }];
    self.userVC.isBoostView = NO;
}

#pragma mark - 界面显示/隐藏
/** 显示聊天选择框 **/
- (void)showButtonBar {
    [self updataAnchorArray:self.chatAnchorArray];
    self.backgroundBtn.hidden = NO;
    [self.view bringSubviewToFront:self.inputMessageView];
    [self.view bringSubviewToFront:self.buttonBar];
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
    if (IS_IPHONE_X) {
        if (self.inputMessageViewBottom.constant == 35) {
            self.backgroundBtn.hidden = YES;
        }
    } else {
        if (self.inputMessageViewBottom.constant == 0) {
            self.backgroundBtn.hidden = YES;
        }
    }
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

- (void)showdiaLog:(NSString *)tip {
    if (!self.isFinshHangout) {
        [self.dialogTipView showDialogTip:self.view tipText:tip];
    }
}

- (void)closeAllInputView {
    // 关闭表情输入
    if (self.hangoutSendBarView.emotionBtn.selected == YES) {
        if (self.hangoutSendBarView.inputTextField.isFirstResponder) {
            self.hangoutSendBarView.inputTextField.inputView = nil;
            [self.hangoutSendBarView.inputTextField resignFirstResponder];
        }
        self.hangoutSendBarView.inputTextField.userInteractionEnabled = YES;
        self.hangoutSendBarView.emotionBtn.selected = NO;
        self.hangoutSendBarView.inputTextField.inputView = nil;
        [self moveInputBarWithKeyboardHeight:0 withDuration:0.25];
        [self showInputMessageView];
        
    } else {
        // 关闭键盘输入
        [self.hangoutSendBarView.inputTextField resignFirstResponder];
    }
}

/** 显示礼物列表 **/
- (void)showGiftView {
    [self updataAnchorArray:self.chatAnchorArray];
    self.backgroundBtn.hidden = NO;
    self.giftVC.view.hidden = NO;
    [self.view bringSubviewToFront:self.giftVC.view];
    [self.giftViewTop uninstall];
    [self.giftVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        self.giftViewTop = make.top.equalTo(self.inputMessageView.mas_bottom).offset(-GiftViewHeight);
    }];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.tableSuperView.hidden = YES;
                     }];
}

/** 收起礼物列表 **/
- (void)closeGiftView {
    [self.giftViewTop uninstall];
    [self.giftVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        self.giftViewTop = make.top.equalTo(self.inputMessageView.mas_bottom);
    }];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.giftVC.view.hidden = YES;
                         self.tableSuperView.hidden = NO;
                     }];
}

/** 显示邀请主播列表 **/
- (void)showInvitePageView {
    [self updataAnchorArray:self.chatAnchorArray];
    [self.invitePageVC reloadData];
    self.backgroundBtn.hidden = NO;
    self.invitePageVC.view.hidden = NO;
    [self.view bringSubviewToFront:self.invitePageVC.view];
    [self.invitePageViewTop uninstall];
    [self.invitePageVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        self.invitePageViewTop = make.top.equalTo(self.inputMessageView.mas_bottom).offset(-InvitePageViewHeight);
    }];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
//                         self.tableSuperView.hidden = YES;
                     }];
}

/** 收起邀请主播列表 **/
- (void)closeInvitePageView {
    self.backgroundBtn.hidden = YES;
    [self.invitePageViewTop uninstall];
    [self.invitePageVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        self.invitePageViewTop = make.top.equalTo(self.inputMessageView.mas_bottom);
    }];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.invitePageVC.view.hidden = YES;
                     }];
}

/** 显示信用详情 **/
- (void)showCreditView {
    self.backgroundBtn.hidden = NO;
    self.creditView.hidden = NO;
    [self.view bringSubviewToFront:self.creditView];
    [self.creditViewBottom uninstall];
    self.creditOffset = -234;
    [self.creditView mas_updateConstraints:^(MASConstraintMaker *make) {
        self.creditViewBottom = make.top.equalTo(self.inputMessageView.mas_bottom).offset(self.creditOffset);
    }];
    // 设置默认的用户id为登录使用用户的id
    self.creditView.userIdLabel.text = [NSString stringWithFormat:@"ID:%@",[LSLoginManager manager].loginItem.userId];
    NSString *nickName = [LSLoginManager manager].loginItem.nickName;
    if (nickName.length > 20) {
        nickName = [nickName substringToIndex:17];
        nickName = [NSString stringWithFormat:@"%@...",nickName];
    }
    self.creditView.nameLabel.text = nickName;
    WeakObject(self, waekSelf);
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                         
                     }
                     completion:^(BOOL finished) {
                         [waekSelf.userInfoManager getLiverInfo:waekSelf.loginManager.loginItem.userId
                                                  finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                                      [waekSelf.creditView updateUserBalanceCredit:waekSelf.creditManager.mCredit userInfo:item];
                                                  }];
                     }];
}

/** 收起信用详情 **/
- (void)closeCreditView {
    self.backgroundBtn.hidden = YES;
    [self.creditViewBottom uninstall];
    self.creditOffset = 0;
    [self.creditView mas_updateConstraints:^(MASConstraintMaker *make) {
        self.creditViewBottom = make.top.equalTo(self.inputMessageView.mas_bottom).offset(self.creditOffset);
    }];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.creditView.hidden = YES;
                     }];
}

- (void)showFinshViewWithErrtype:(HANGOUTERROR)error errMsg:(NSString *)errMsg {
    self.isFinshHangout = YES;
    [self closeAllInputView];
    [self.bigGiftArray removeAllObjects];
    [self.view sendSubviewToBack:self.giftAnimationView];
    HangOutFinshViewController *finshVC = [[HangOutFinshViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:finshVC];
    [self.view addSubview:finshVC.view];
    [self.view bringSubviewToFront:finshVC.view];
    
    [finshVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
    
    [finshVC showError:error errMsg:errMsg];
    
    // 清空直播间信息
    self.liveRoom = nil;
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
    self.backgroundBtn.hidden = YES;
    // 单击关闭输入
    [self closeAllInputView];
    
    // 如果已经展开礼物列表
    
    if (!self.giftVC.view.isHidden) {
        [self closeGiftView];
    }
    
    if (!self.invitePageVC.view.isHidden) {
        [self closeInvitePageView];
    }
    
    if (!self.creditView.isHidden) {
        [self closeCreditView];
    }
    
    if (self.selectBtn.isSelected) {
        [self hiddenButtonBar];
    }
    self.controlView.hidden = YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint pt = [touch locationInView:self.view];
    if (!CGRectContainsPoint([self.giftVC.view frame], pt) && !CGRectContainsPoint([self.invitePageVC.view frame], pt)) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - HTTP请求
// 请求账号余额
- (void)getLeftCreditRequest {
    GetLeftCreditRequest *request = [[GetLeftCreditRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, double credit, int coupon, double postStamp) {
        NSLog(@"HangOutViewController::getLeftCreditRequest( [获取账号余额请求结果], success:%d, errnum : %ld, errmsg : %@ credit : %f coupon:%d, postStamp:%d)", success, (long)errnum, errmsg, credit, coupon, postStamp);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                [self.creditView userCreditChange:credit];
                [self.creditManager setCredit:credit];
            } else {
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

// 通知主播敲门请求
- (void)sendAgreeKonck:(MsgItem *)item {
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomId = item.knockItem.roomId;
    liveRoom.userId = item.knockItem.anchorId;
    liveRoom.userName = item.knockItem.nickName;
    liveRoom.photoUrl = item.knockItem.photoUrl;
    
    // 如果未分配窗口 则分配空闲窗口
    HangOutLiverViewController *liverVC = self.hangoutArray[0];
    liverVC.liveRoom = liveRoom;
    [liverVC showAnchorComingTip];
    
    // 将分配窗口移除空闲队列 并添加进窗口分发字典
    @synchronized(self.hangoutArray) {
        [self.hangoutArray removeObjectAtIndex:0];
    }
    @synchronized(self.hangoutDic) {
        [self.hangoutDic setObject:liverVC forKey:item.knockItem.anchorId];
    }
    
    LSDealKnockRequest *request = [[LSDealKnockRequest alloc] init];
    request.knockId = item.knockItem.knockId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        NSLog(@"HangOutViewController::agreeAnchorKnock( [同意主播敲门请求] success : %@, errnum : %d, errmsg : %@, knockId : %@ )", success == YES ? @"成功":@"失败", errnum, errmsg, item.knockItem.knockId);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 如果已分配窗口 则更新数据
            HangOutLiverViewController *liverVC = [self.hangoutDic objectForKey:item.knockItem.anchorId];
            if (success) {
                if ([item.knockItem.roomId isEqualToString:self.liveRoom.roomId]) {
                    [liverVC showAnchorLoading];
                }
            } else {
                [self resetAnchorWindow:liverVC userId:item.knockItem.anchorId];
                [liverVC resetView:YES];
                if (errnum == HTTP_LCC_ERR_NO_CREDIT) {
                    [self.alertView setMessage:errmsg];
                    [self.alertView show];
                } else {
                    [self showdiaLog:errmsg];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - IM请求
- (BOOL)sendMsg:(NSString *)text {
    BOOL bFlag = NO;
    NSString *str =  [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 发送IM文本
    if (str.length > 0) {
        bFlag = YES;
        // 调用IM命令(发送直播间消息)
        [self sendRoomMsgRequestFromText:text];
    }
    return bFlag;
}

- (void)sendRoomMsgRequestFromText:(NSString *)text {
    // TODO: 发送文本消息
    BOOL inRoom = NO;
    for (LSUserInfoModel *model in self.chatAnchorArray) {
        if ([model.userId isEqualToString:self.chatUserId]) {
            inRoom = YES;
        }
    }

    // 如果@用户不在直播间则弹提示
    if (!inRoom && self.atArray.count > 0) {
        [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"CONTACT_NOT_HAVE")];
    } else {
        // 发送直播间消息
        [self.imManager sendHangoutLiveChat:self.liveRoom.roomId nickName:self.loginManager.loginItem.nickName msg:text at:self.atArray];
    }
}

- (void)sendCelebrationGift:(int)clickId item:(LSGiftManagerItem *)item {
    // TODO: 发送庆祝礼物
    GiftItem *sendItem = [GiftItem hangoutRoomId:self.liveRoom.roomId
                                        nickName:[LSLoginManager manager].loginItem.nickName
                                     is_Backpack:NO
                                       isPrivate:NO
                                         giftNum:1
                                         starNum:1
                                          endNum:1
                                         clickID:clickId
                                        giftItem:item];
    [self.sendGiftManager sendHangoutGiftrRequestWithGiftItem:sendItem];
}

#pragma mark - IM通知
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"HangOutViewController::onLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errType == LCC_ERR_SUCCESS) {
            
            if (self.liveRoom.roomId.length > 0) {
                [self.imManager enterHangoutRoom:self.liveRoom.roomId finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString * _Nonnull errMsg, IMHangoutRoomItemObject * _Nonnull Item) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                       NSLog(@"HangOutViewController::enterHangoutRoom( [观众新建/进入多人互动直播间] success : %@, errType : %d, errMsg : %@, roomId : %@ )", BOOL2SUCCESS(success), errType, errMsg, Item.roomId);
                        if (success) {
                            if (Item.roomType == ROOMTYPE_HANGOUTROOM) {
                                self.liveRoom.roomType = LiveRoomType_Hang_Out;
                            }
                            self.liveRoom.hangoutLiveRoom = Item;
                            if (Item.otherAnchorList.count > 0) {
                                [self.anchorArray removeAllObjects];
                                [self.anchorArray addObjectsFromArray:Item.otherAnchorList];
                                [self enterRoomAnchorList];
                            }
                            if (Item.buyforList.count > 0) {
                                [self.roomGiftList removeAllObjects];
                                [self.roomGiftList addObjectsFromArray:Item.buyforList];
                                [self showBugforList];
                            }
                            
                            // 重置男士推流
                            self.userVC.liveRoom.publishUrlArray = Item.pushUrl;
                            [self.userVC reloadVideoStatus];
                            
                        } else {
                            [self stopLiveWithErrtype:HANGOUTERROR_NORMAL errMsg:errmsg];
                        }
                    });
                }];
            }
        } else {
            [self stopLiveWithErrtype:HANGOUTERROR_NORMAL errMsg:NSLocalizedStringFromSelf(@"CONNECT_SEVER_FAIL")];
        }
    });
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"HangOutViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

- (void)onRecvHangoutGiftNotice:(IMRecvHangoutGiftItemObject *)item {
    NSLog(@"HangOutViewController::onRecvHangoutGiftNotice( [接收多人互动直播间礼物通知] roomId : %@, fromId : %@, toUid : %@,"
          "giftId : %@ )",item.roomId, item.fromId, item.toUid, item.giftId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.liveRoom.roomId isEqualToString:item.roomId]) {
            // 插入送礼文本
            [self addGiftMessageSendName:item.nickName toUserId:item.toUid giftID:item.giftId giftNum:item.giftNum giftName:item.giftName fromId:item.fromId];
            
            LSGiftManagerItem *giftItem = [self.giftDownloadManager getGiftItemWithId:item.giftId];
            switch (giftItem.infoItem.type) {
                // 庆祝礼物 当前VC播放
                case GIFTTYPE_CELEBRATE:{
                    // 是否有详情
                    if (giftItem.infoItem) {
                        // 礼物添加到队列
                        if (!self.bigGiftArray && self.viewIsAppear) {
                            self.bigGiftArray = [NSMutableArray array];
                        }
                        for (int i = 0; i < item.giftNum; i++) {
                            [self.bigGiftArray addObject:item.giftId];
                        }
                        // 防止动画播完view没移除
                        if (!self.giftAnimationView.isAnimating) {
                            [self.giftAnimationView removeFromSuperview];
                            self.giftAnimationView = nil;
                        }
                        
                        if (!self.giftAnimationView) {
                            // 显示大礼物动画
                            if (self.bigGiftArray.count) {
                                [self starBigAnimationWithGiftID:self.bigGiftArray[0]];
                            }
                        }
                    }
                }break;
                    
                case GIFTTYPE_BAR:{ // 吧台礼物
                    // toUid有值发送给指定对象 无则发送给全部
                    if (item.toUid.length) {
                        HangOutLiverViewController *vc = [self.hangoutDic objectForKey:item.toUid];
                        if (vc) {
                            [vc onSendGiftNoticePlay:item];
                        }
                        
                    } else {
                        if (self.hangoutDic.count) {
                            NSArray *keys = [self.hangoutDic allKeys];
                            for (int i = 0; i < keys.count; i++) {
                                NSString *key = keys[i];
                                HangOutLiverViewController *vc = [self.hangoutDic objectForKey:key];
                                if (vc) {
                                    [vc onSendGiftNoticePlay:item];
                                }
                            }
                        }
                    }
                }break;
                    
                default:{
                    if (giftItem.infoItem) {
                        // toUid有值发送给指定对象 无则发送给全部
                        if (item.toUid.length) {
                            HangOutLiverViewController *vc = [self.hangoutDic objectForKey:item.toUid];
                            if (vc) {
                                [vc onSendGiftNoticePlay:item];
                            }
                            
                        } else {
                            if (self.hangoutDic.count) {
                                NSArray *keys = [self.hangoutDic allKeys];
                                for (int i = 0; i < keys.count; i++) {
                                    NSString *key = keys[i];
                                    HangOutLiverViewController *vc = [self.hangoutDic objectForKey:key];
                                    if (vc) {
                                        [vc onSendGiftNoticePlay:item];
                                    }
                                }
                            }
                        }
                    }
                }break;
            }
        }
    });
}

- (void)onRecvHangoutChatNotice:(IMRecvHangoutChatItemObject *)item {
    NSLog(@"HangOutViewController::onRecvHangoutChatNotice( [接收多人互动直播间文本消息] roomId : %@, msg : %@, at : %@ )",item.roomId, item.msg, item.at);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([item.roomId isEqualToString:self.liveRoom.roomId]) {
            // 插入聊天消息到列表
            [self addChatMessageNickName:item.nickName text:item.msg honorUrl:item.honorUrl fromId:item.fromId at:item.at];
        }
    });
}

- (void)onRecvSendSystemNotice:(NSString *_Nonnull)roomId msg:(NSString *_Nonnull)msg link:(NSString *_Nonnull)link type:(IMSystemType)type {
    NSLog(@"HangOutViewController::onRecvSendSystemNotice( [接收直播间公告消息], roomId : %@, msg : %@, link: %@ type:%d)", roomId, msg, link, type);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            MsgItem *msgItem = [[MsgItem alloc] init];
            if (type == IMSYSTEMTYPE_COMMON) {
                msgItem.text = msg;
                if ([link isEqualToString:@""] || link == nil) {
                    msgItem.msgType = MsgType_Announce;
                } else {
                    msgItem.msgType = MsgType_Link;
                    msgItem.linkStr = link;
                }
            } else {
                
                if (self.dialogView) {
                    [self.dialogView hidenDialog];
                }
                //            WeakObject(self, weakSelf);
                self.dialogView = [DialogWarning dialogWarning];
                self.dialogView.tipsLabel.text = msg;
                [self.dialogView showDialogWarning:self.view
                                       actionBlock:^{
                                           
                                       }];
                
                msgItem.text = msg;
                msgItem.msgType = MsgType_Warning;
            }
            NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
            msgItem.attText = attributeString;
            [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
        }
    });
}

- (void)onRecvRecommendHangoutNotice:(IMRecommendHangoutItemObject *)item {
    NSLog(@"HangOutViewController::onRecvRecommendHangoutNotice( [接收主播推荐好友通知] roomId : %@, anchorID : %@,"
          "nickName : %@, recommendId : %@, photourl : %@ )",item.roomId, item.anchorId, item.nickName, item.recommendId, item.photoUrl);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([item.roomId isEqualToString:self.liveRoom.roomId]) {
            MsgItem *msgModel = [[MsgItem alloc] init];
            msgModel.msgType = MsgType_Announce;
            msgModel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"RECOMMEND_JOIN_HANGOUT"), item.nickName, item.friendNickName];
            NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgModel];
            msgModel.attText = attributeString;
            [self addMsg:msgModel replace:NO scrollToEnd:YES animated:YES];
            
            MsgItem *msgItem = [[MsgItem alloc] init];
            msgItem.msgType = MsgType_Recommend;
            msgItem.sendName = item.nickName;
            msgItem.recommendItem = item;
            [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
        }
    });
}

- (void)onRecvKnockRequestNotice:(IMKnockRequestItemObject *)item {
    NSLog(@"HangOutViewController::onRecvKnockRequestNotice( [接收主播敲门通知] roomId : %@, anchorID : %@,"
          "nickName : %@, knockID : %@, photourl : %@ )",item.roomId, item.anchorId, item.nickName, item.knockId, item.photoUrl);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([item.roomId isEqualToString:self.liveRoom.roomId]) {
            MsgItem *msgModel = [[MsgItem alloc] init];
            msgModel.msgType = MsgType_Announce;
            msgModel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ANCHOR_KNOCKING_DOOR"),item.nickName];
            NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgModel];
            msgModel.attText = attributeString;
            [self addMsg:msgModel replace:NO scrollToEnd:YES animated:YES];
            
            MsgItem *msgItem = [[MsgItem alloc] init];
            msgItem.msgType = MsgType_Knock;
            msgItem.sendName = item.nickName;
            msgItem.knockItem = item;
            [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
        }
    });
}

- (void)onRecvEnterHangoutRoomNotice:(IMRecvEnterRoomItemObject *)item {
    BOOL isAnchor = item.isAnchor;
    BOOL isEqualUser = [item.userId isEqualToString:self.loginManager.loginItem.userId];
    BOOL isEqualRoom = [item.roomId isEqualToString:self.liveRoom.roomId];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"HangOutViewController::onRecvEnterHangoutRoomNotice( [接收观众/主播进入多人互动直播间] roomId : %@, userId : %@,"
              "nickName : %@, anchorId : %@ )",item.roomId, item.userId, item.nickName, item.userId);
        // 插入入场消息
        [self addJoinMessageNickName:item.nickName fromId:item.userId];
        
        if (isAnchor && !isEqualUser && isEqualRoom) {
            // 储存本地主播信息
            LSUserInfoModel *model = [[LSUserInfoModel alloc] init];
            model.userId = item.userId;
            model.nickName = item.nickName;
            model.photoUrl = item.photoUrl;
            model.isAnchor = item.isAnchor;
            [self.userInfoManager setLiverInfoDic:model];
            
            @synchronized(self) {
                BOOL isHave = YES;
                for (LSUserInfoModel *obj in self.chatAnchorArray) {
                    if ([obj.userId isEqualToString:item.userId]) {
                        isHave = NO;
                    }
                }
                if (isHave) {
                    [self.chatAnchorArray addObject:model];
                }
            }
        }
    });
}

- (void)onRecvLeaveHangoutRoomNotice:(IMRecvLeaveRoomItemObject *)item {
    BOOL isAnchor = item.isAnchor;
    BOOL isEqualUser = [item.userId isEqualToString:self.loginManager.loginItem.userId];
    BOOL isEqualRoom = [item.roomId isEqualToString:self.liveRoom.roomId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isAnchor && !isEqualUser && isEqualRoom) {
            NSLog(@"HangOutViewController::onRecvLeaveHangoutRoomNotice( [接收观众/主播退出多人互动直播间] roomId : %@, userId : %@, nickName : %@,"
                  "errNo : %d, errMsg : %@, anchorId : %@ )", item.roomId, item.userId, item.nickName, item.errNo, item.errMsg, item.userId);
            
            MsgItem *msgModel = [[MsgItem alloc] init];
            msgModel.msgType = MsgType_Announce;
            msgModel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ANCHOR_LEFT_HANGOUT"),item.nickName];
            NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgModel];
            msgModel.attText = attributeString;
            [self addMsg:msgModel replace:NO scrollToEnd:YES animated:YES];
            
            @synchronized(self) {
                // 刷新选择聊天对象数组
                NSMutableArray *array = [[NSMutableArray alloc] init];
                for (LSUserInfoModel *obj in self.chatAnchorArray) {
                    if (![obj.userId isEqualToString:item.userId]) {
                        [array addObject:obj];
                    }
                }
                self.chatAnchorArray = array;
            }
        }
    });
}

- (void)onRecvCreditNotice:(NSString *_Nonnull)roomId credit:(double)credit {
    NSLog(@"HangOutViewController::onRecvCreditNotice( [接收定时扣费通知], roomId : %@, credit : %f ）", roomId, credit);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            // 设置余额及返点信息管理器
            if (credit >= 0) {
                [self.creditManager setCredit:credit];
            }
        }
    });
}

- (void)onSendHangoutGift:(unsigned int)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg credit:(double)credit {
    NSLog(@"HangOutViewController::onSendHangoutGift( [发送多人互动直播间礼物消息, %@], err : %d, errMsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 显示错误提示框
        if (success) {
            if (credit >= 0) {
                // 更新信用点
                [self.creditManager setCredit:credit];
            }
        } else {
            [self showdiaLog:errMsg];
        }
    });
}

- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"LiveViewController::onRecvLevelUpNotice( [接收观众等级升级通知], level : %d )", level);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 插入观众等级升级文本
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Recv_Level_Up", @"Recv_Level_Up"), level];
        MsgItem *msgItem = [[MsgItem alloc] init];
        msgItem.text = msg;
        msgItem.msgType = MsgType_Announce;
        NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
        msgItem.attText = attributeString;
        [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
        
        self.liveRoom.imLiveRoom.manLevel = level;
    });
}

- (void)onRecvLoveLevelUpNotice:(IMLoveLevelItemObject *  _Nonnull)loveLevelItem {
    NSLog(@"HangOutViewController::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知], loveLevel : %d, anchorId: %@, anchorName: %@  )", loveLevelItem.loveLevel, loveLevelItem.anchorId, loveLevelItem.anchorName);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 插入观众等级升级文本
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Recv_Love_Up", @"Recv_Love_Up"), loveLevelItem.anchorName, loveLevelItem.loveLevel];
        MsgItem *msgItem = [[MsgItem alloc] init];
        msgItem.text = msg;
        msgItem.msgType = MsgType_Announce;
        NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
        msgItem.attText = attributeString;
        [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
    });
}

- (void)onRecvLackCreditHangoutNotice:(IMLackCreditHangoutItemObject *)item {
    BOOL isEqualUser = [item.anchorId isEqualToString:self.loginManager.loginItem.userId];
    BOOL isEqualRoom = [item.roomId isEqualToString:self.liveRoom.roomId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!isEqualUser && isEqualRoom) {
            NSLog(@"HangOutViewController::onRecvLackCreditHangoutNotice( [接收多人互动余额不足导致主播将要离开的通知] roomId : %@, anchorId : %@, nickName : %@, errNo : %d, errMsg : %@ )", item.roomId, item.anchorId, item.nickName, item.errNo, item.errMsg);
            MsgItem *msgModel = [[MsgItem alloc] init];
            msgModel.msgType = MsgType_Announce;
            msgModel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"NO_CREIDT_ANCHOR_LEFT"),item.nickName];
            NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgModel];
            msgModel.attText = attributeString;
            [self addMsg:msgModel replace:NO scrollToEnd:YES animated:YES];
        }
    });
}

- (void)onRecvRoomCloseNotice:(NSString *)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg priv:(ImAuthorityItemObject * _Nonnull)priv {
    NSLog(@"HangOutViewController::onRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@ , isHasOneOnOneAuth : %d, isHasOneOnOneAuth : %d )", roomId, errType, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.liveRoom.priv = priv;
        BOOL isEqualRoomId = [self.liveRoom.roomId isEqualToString:roomId];
        if (isEqualRoomId && !self.isBackground) {
            if (errType == LCC_ERR_NO_CREDIT) {
                [self stopLiveWithErrtype:HANGOUTERROR_NOCREDIT errMsg:errmsg];
            } else {
                [self stopLiveWithErrtype:HANGOUTERROR_NORMAL errMsg:errmsg];
            }
        }
    });
}

- (void)onRecvRoomKickoffNotice:(NSString *)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *)errmsg credit:(double)credit priv:(ImAuthorityItemObject * _Nonnull)priv{
    NSLog(@"LiveViewController::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ credit:%f", roomId, credit);
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isEqualRoomId = [self.liveRoom.roomId isEqualToString:roomId];
        if (isEqualRoomId) {
            self.liveRoom.priv = priv;
            // 设置余额及返点信息管理器
            if (credit >= 0) {
                [self.creditManager setCredit:credit];
            }
            
            if (self.liveRoom.roomId.length > 0) {
                // 发送IM退出直播间命令
                [[LSImManager manager] leaveHangoutRoom:self.liveRoom.roomId finishHandler:nil];
            }
            if (errType == LCC_ERR_NO_CREDIT) {
                [self stopLiveWithErrtype:HANGOUTERROR_NOCREDIT errMsg:errmsg];
            } else {
                [self stopLiveWithErrtype:HANGOUTERROR_NORMAL errMsg:errmsg];
            }
        }
    });
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    if (height != 0) {
        
        // 弹出键盘
        self.msgSuperViewTop.constant =  - height + 5;
        self.inputMessageViewBottom.constant = height;
        self.backgroundBtn.hidden = NO;
        [self.view bringSubviewToFront:self.inputMessageView];
    } else {
        self.backgroundBtn.hidden = YES;
        if (IS_IPHONE_X) {
            self.inputMessageViewBottom.constant = 35;
        } else {
            self.inputMessageViewBottom.constant = 0;
        }
        self.msgSuperViewTop.constant = 5;
        
        if (self.hangoutSendBarView.inputTextField.fullText.length) {
            [self.chatBtn setTitle:self.hangoutSendBarView.inputTextField.fullText forState:UIControlStateNormal];
        } else {
            [self.chatBtn setTitle:NSLocalizedStringFromSelf(@"INPUT_PLACEHOLDER") forState:UIControlStateNormal];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
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
    
    if( self.hangoutSendBarView.emotionBtn.selected != YES ) {
        // 改变控件状态
        [self showInputMessageView];
    }
}

#pragma mark - Setter/Getter
- (void)setChatUserId:(NSString *)chatUserId {
    _chatUserId = chatUserId;
    [self.atArray removeAllObjects];
    if (_chatUserId.length) {
        [self.atArray addObject:_chatUserId];
    }
}

- (void)updataAnchorArray:(NSMutableArray<LSUserInfoModel *> *)anchors {
    self.giftVC.chatAnchorArray = anchors;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (LSUserInfoModel *model in anchors) {
        HangoutInviteAnchor *item = [[HangoutInviteAnchor alloc] init];
        item.anchorName = model.nickName;
        item.anchorId = model.userId;
        item.photoUrl = model.photoUrl;
        [array addObject:item];
    }
    self.invitePageVC.anchorIdArray = array;
    [self.invitePageVC reloadData];
}

@end
