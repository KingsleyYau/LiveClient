//
//  LSVIPLiveViewController.m
//  livestream
//
//  Created by Calvin on 2019/8/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSVIPLiveViewController.h"

#import "LiveFinshViewController.h"
#import "LiveWebViewController.h"
#import "LSAddCreditsViewController.h"

#import "LiveModule.h"
#import "LiveUrlHandler.h"

#import "LiveGobalManager.h"
#import "LiveStreamPublisher.h"

#import "MsgTableViewCell.h"
#import "TalentMsgCell.h"
#import "HangOutOpenDoorCell.h"
#import "LSInviteHangoutMsgCell.h"
#import "LSScheduleInviteCell.h"
#import "LSScheduleStatusTipCell.h"

#import "LSFileCacheManager.h"
#import "LiveStreamSession.h"
#import "LiveRoomCreditRebateManager.h"
#import "LSConfigManager.h"
#import "LSMinLiveManager.h"
#import "LSPrePaidManager.h"
#import "LSStreamSpeedManager.h"

#import "DialogChoose.h"
#import "DialogTip.h"
#import "DialogWarning.h"
#import "LSShadowView.h"
#import "LSCreditView.h"
#import "PrivateDriveView.h"

#import "LSUserInfoManager.h"

#define RECORD_START @"!record=1!"
#define RECORD_STOP @"!record=0!"

#define DEBUG_START @"!debug=1!"
#define DEBUG_STOP @"!debug=0!"

#define INPUTMESSAGEVIEW_MAX_HEIGHT 44.0 * 2

#define LevelFontSize 14
#define LevelFont [UIFont systemFontOfSize:LevelFontSize]
#define LevelGrayColor [LSColor colorWithIntRGB:56 green:135 blue:213 alpha:255]

#define MessageFontSize 16
#define MessageFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:MessageFontSize]

#define NameFontSize 14
#define NameFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:NameFontSize]

#define NameColor [LSColor colorWithIntRGB:255 green:210 blue:5 alpha:255]
#define MessageTextColor [UIColor whiteColor]

#define MessageCount 500

#define OpenDoorHeight 71

#pragma mark - 流[播放/推送]逻辑
#define STREAM_PLAYER_RECONNECT_MAX_TIMES 5
#define STREAM_PUBLISH_RECONNECT_MAX_TIMES STREAM_PLAYER_RECONNECT_MAX_TIMES

@interface LSVIPLiveViewController ()<UITextFieldDelegate, LSCheckButtonDelegate, GiftComboViewDelegate, IMLiveRoomManagerDelegate, IMManagerDelegate, DriveViewDelegate, MsgTableViewCellDelegate, LiveStreamPlayerDelegate, LiveStreamPublisherDelegate, LiveGobalManagerDelegate, TalentMsgCellDelegate, LSInviteHangoutMsgCellDelegate,LSCreditViewDelegate,BarrageViewDelegate,BarrageViewDataSouce,LSLiveVCManagerDelegate,LSChatPrepaidViewDelegate,LSPurchaseCreditsViewDelegate,LSLivePrepaidTipViewDelegate,LSScheduleListViewDelegate,LSPrePaidPickerViewDelegate,LSScheduleInviteCellDelegate,LSScheduleStatusTipCellDelegate>
#pragma mark - 流[播放/推送]管理
// 流播放地址
@property (nonatomic, strong) NSString *playUrl;
// 流播放组件
@property (nonatomic, strong) LiveStreamPlayer *player;
// 流播放重连次数
@property (nonatomic, assign) NSUInteger playerReconnectTime;

// 流推送地址
@property (nonatomic, strong) NSString *publishUrl;
// 流推送组件
@property (nonatomic, strong) LiveStreamPublisher *publisher;
// 流推送重连次数
@property (nonatomic, assign) NSUInteger publisherReconnectTime;

// 观众数组
@property (nonatomic, strong) NSMutableArray *audienArray;

/**
 用于显示的消息列表
 @description 注意在主线程操作
 */
@property (nonatomic, strong) NSMutableArray<MsgItem *> *msgShowArray;
/**
 用于保存真实的消息列表
 @description 注意在主线程操作
 */
@property (nonatomic, strong) NSMutableArray<MsgItem *> *msgArray;
/**
 是否需要刷新消息列表
 @description 注意在主线程操作
 */
@property (nonatomic, assign) BOOL needToReload;

// 礼物连击队列
@property (nonatomic, strong) NSMutableArray<GiftComboView *> *giftComboViews;
@property (nonatomic, strong) NSMutableArray<MASConstraint *> *giftComboViewsLeadings;

#pragma mark - 礼物管理器
@property (nonatomic, strong) GiftComboManager *giftComboManager;

#pragma mark - 礼物下载器
@property (nonatomic, strong) LSGiftManager *giftDownloadManager;

#pragma mark - 表情管理器
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

#pragma mark - 直播间管理器
@property (nonatomic, strong) LSLiveVCManager *liveManager;

#pragma mark - IM管理器
@property (nonatomic, strong) LSImManager *imManager;

#pragma mark - 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;

#pragma mark - 预付费管理器
@property (nonatomic, strong) LSPrePaidManager *paidManager;

// 视频按钮倒数
@property (nonatomic, strong) LSTimer *videoBtnTimer;
// 视频按钮消失倒数
@property (nonatomic, assign) int videoBtnLeftSecond;

// 图片下载器
@property (nonatomic, strong) LSImageViewLoader *headImageLoader;
@property (nonatomic, strong) LSImageViewLoader *giftImageLoader;
@property (nonatomic, strong) LSImageViewLoader *cellHeadImageLoader;

// 显示的弹幕数量 用于判断隐藏弹幕阴影
@property (nonatomic, assign) int showToastNum;

// 对话框
@property (nonatomic, strong) DialogTip *dialogProbationTip;
@property (nonatomic, strong) DialogWarning *dialogView;
@property (nonatomic, strong) DialogChoose *dialogChoose;

#pragma mark - 用于显示试用倦提示
@property (nonatomic, assign) BOOL showTip;

#pragma mark - 后台处理
@property (nonatomic, assign) BOOL isBackground;

// 是否已退入后台超时
@property (nonatomic, assign) BOOL isTimeOut;

// 是否邀请Hangout成功
@property (nonatomic, assign) BOOL isInviteHangout;
// 是否正在Hangout邀请
@property (nonatomic, assign) BOOL isInvitingHangout;
// HangOut邀请ID
@property (nonatomic, copy) NSString *hangoutInviteId;
// Hangout邀请主播名称 ID
@property (nonatomic, copy) NSString *recommendAnchorName;
@property (nonatomic, copy) NSString *recommendAnchorId;
// push跳转Url
@property (nonatomic, strong) NSURL *pushUrl;

@property (nonatomic, assign) BOOL isDriveShow;

@property (nonatomic, strong) LSCreditView *creditView;

@property (nonatomic, strong) PrivateDriveView *privateDriveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *liveHeadDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoTopDIstance;

// 记录收起前的消息行数
@property (nonatomic, assign) NSInteger msgPushDownLastRow;

@property (nonatomic, assign) BOOL isRoomFree;

// 选中主播发送的待确认预付费消息下标
@property (nonatomic, assign) NSInteger scheduleItemRow;

@property (nonatomic, assign) NSInteger scheduleCount;

@end

@implementation LSVIPLiveViewController

- (void)dealloc {
    NSLog(@"LSVIPLiveViewController::dealloc()");
    
    if (self.dialogChoose) {
        [self.dialogChoose removeFromSuperview];
    }
    
    // 去除大礼物结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftAnimationIsOver" object:nil];
    
    [self.giftComboManager removeManager];
    
    for (GiftComboView *giftView in self.giftComboViews) {
        [giftView stopGiftCombo];
    }
    
    [self removePrePaidPickerView];
    
    // 移除直播间后台代理监听
    [[LiveGobalManager manager] removeDelegate:self];
    [[LiveGobalManager manager] setupVIPLiveVC:nil orHangOutVC:nil];
    
    // 移除直播间IM代理监听
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    // 停止流
    [self stopPlay];
    [self stopPublish];
    
    //取消hangout邀请
    if (self.isInvitingHangout) {
        [self.liveManager sendCancelHangoutInvite:self.hangoutInviteId];
    }
    
    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (self.liveRoom.roomId.length > 0) {
        // 发送退出直播间
        NSLog(@"LSVIPLiveViewController::dealloc( [发送退出直播间], roomId : %@ )", self.liveRoom.roomId);
        [self.imManager leaveRoom:self.liveRoom];
    }
    
    [[LSPrePaidManager manager] removeScheduleListArray];
}

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    NSLog(@"LSVIPLiveViewController::initCustomParam()");
    
    self.isShowNavBar = YES;
    
    // 初始化流组件
    self.playUrl = @"rtmp://172.25.32.133:7474/test_flash/max_mv";
    self.player = [LiveStreamPlayer instance];
    self.player.delegate = self;
    self.playerReconnectTime = 0;
    
    self.publishUrl = @"rtmp://172.25.32.133:7474/test_flash/max_i";
    self.publisher = [LiveStreamPublisher instance:LiveStreamType_Audience_Private];
    self.publisher.delegate = self;
    self.publisherReconnectTime = 0;
    
    // 初始化消息
    self.msgArray = [NSMutableArray array];
    self.msgShowArray = [NSMutableArray array];
    self.needToReload = NO;
    
    // 初始化IM管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    // 初始化后台管理器
    [[LiveGobalManager manager] addDelegate:self];
    
    // 初始登录
    self.loginManager = [LSLoginManager manager];
    self.giftComboManager = [[GiftComboManager alloc] init];
    
    // 初始化礼物管理器
    self.giftDownloadManager = [LSGiftManager manager];
    
    // 初始化表情管理器
    self.emotionManager = [LSChatEmotionManager emotionManager];
    
    // 初始化余额及返点信息管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
    
    // 初始化直播间管理器
    self.liveManager = [LSLiveVCManager manager];
    
    // 初始化预付费管理器
    self.paidManager = [LSPrePaidManager manager];
    
    // 初始化大礼物播放队列
    self.bigGiftArray = [NSMutableArray array];
    
    // 初始化观众队列
    self.audienArray = [[NSMutableArray alloc] init];
    
    // 显示的弹幕数量
    self.showToastNum = 0;
    
    // 初始化视频控制按钮消失计时器
    self.videoBtnLeftSecond = 3;
    
    // 图片下载器
    self.headImageLoader = [LSImageViewLoader loader];
    self.giftImageLoader = [LSImageViewLoader loader];
    self.cellHeadImageLoader = [LSImageViewLoader loader];
    
    // 注册前后台切换通知
    _isBackground = NO;
    self.isTimeOut = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 注册大礼物结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationWhatIs:) name:@"GiftAnimationIsOver" object:nil];
    
    // 初始化计时器
    self.videoBtnTimer = [[LSTimer alloc] init];
    
    self.dialogProbationTip = [DialogTip dialogTip];
    self.showTip = YES;
    
    // 初始化是否邀请多人互动成功
    self.isInviteHangout = NO;
    // 初始化是否正在多人互动邀请
    self.isInvitingHangout = NO;
    
    self.recommendAnchorId = @"";
    self.recommendAnchorName = @"";
    
    // 聊天列表顶部间隔
    self.topInterval = 0;
    self.isMsgPushDown = NO;
    // 初始化上一条消息位置
    self.msgPushDownLastRow = -2;
    
    // 是否公开直播间免费提醒
    self.isRoomFree = YES;
    
    // 选中主播发送的待确认预付费消息下标
    self.scheduleItemRow = -1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 赋值到全局变量, 用于后台计时操作
    [LiveGobalManager manager].liveRoom = self.liveRoom;
    // 赋值到全局变量 用于观看信件或chat视频关闭直播声音
    [[LiveGobalManager manager] setupVIPLiveVC:self orHangOutVC:nil];
    
    // 禁止锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    // 直播间管理器赋值
    self.liveManager.liveRoom = self.liveRoom;
    self.liveManager.roomStyleItem = self.roomStyleItem;
    self.liveManager.delegate = self;
    
    // 初始化消息列表
    [self setupTableView];
    
    // 初始化连击控件
    [self setupGiftView];
    
    // 初始化视频界面
    self.videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.player addPlayView:self.videoView];
    if ([LSMinLiveManager manager].minView) {
        [self.player addPlayView:[LSMinLiveManager manager].minView.videoView];
    }
    
    // 隐藏互动直播ActivityView
    self.preActivityView.hidden = YES;
    
    // 公开/私密直播间样式切换
    self.scheduleBtn.layer.masksToBounds = YES;
    self.scheduleBtn.layer.cornerRadius = self.scheduleBtn.tx_height / 2;
    if (self.liveRoom.roomType == LiveRoomType_Public) {
        self.scheduleBtnViewBottom.constant = 0;
        self.camBtnHeight.constant = 0;
        self.camBtnBottom.constant = 0;
        self.stroeBtnHeight.constant = 0;
    } else {
        self.scheduleBtnViewBottom.constant = 5;
        self.camBtnHeight.constant = 48;
        self.camBtnBottom.constant = 5;
        
        //鲜花礼品按钮判断
        if (self.loginManager.loginItem.userPriv.isGiftFlowerPriv && self.loginManager.loginItem.isGiftFlowerSwitch) {
            self.stroeBtnHeight.constant = 48;
        }else {
            self.stroeBtnHeight.constant = 0;
            self.camBtnBottom.constant = 0;
        }
    }
    
    self.msgSuperViewH.constant = SCREEN_HEIGHT/2 - self.msgSuperViewBottom.constant;
    self.msgTableViewTop.constant = self.msgSuperViewH.constant;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
    [self hideNavigationBar];
    // 初始化预付费界面
    [self setupPrepaidView];
    // 获取主播信息(更新预付费权限 显示btn用)
    [self.liveManager getLiveRoomAnchorInfo:self.liveRoom.userId];
    // 获取当前直播间预付费列表
    [self.liveManager getScheduleList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.bigGiftArray = nil;
    [self.giftAnimationView removeFromSuperview];
    self.giftAnimationView = nil;
    
    if (self.dialogProbationTip.isShow) {
        [self.dialogProbationTip removeShow];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        // 刷新双向视频状态
        [self reloadVideoStatus];
        
        // 第一次进入,未播流显示蒙层
        self.bgView.hidden = NO;
        // 获取用户头像
        
        if (self.liveRoom.roomPhotoUrl.length > 0) {
            // 当前用户
            [self.headImageLoader loadImageFromCache:self.bgImageView
                                             options:SDWebImageRefreshCached
                                            imageUrl:self.liveRoom.roomPhotoUrl
                                    placeholderImage:nil
                                       finishHandler:^(UIImage *image){
                                       }];
        } else {
            
            [[LSUserInfoManager manager] getUserInfo:self.liveRoom.userId finishHandler:^(LSUserInfoModel *item) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 当前用户
                    [self.headImageLoader loadImageFromCache:self.bgImageView
                                                     options:SDWebImageRefreshCached
                                                    imageUrl:item.anchorInfo.roomPhotoUrl
                                            placeholderImage:nil
                                               finishHandler:^(UIImage *image){
                                               }];
                });
            }];
        
        }
        // 开始播放流
        [self play];
        
        // 自己座驾入场
        [self.liveManager getDriveInfo:self.loginManager.loginItem.userId];
        
        // 插入是否具有试聊卷
        [self.liveManager addVouchTipsToList];
    }
    
    // 开始计时器
    [self startVideoBtnTimer];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self removeAllCustonBox];
    // 停止计时器
    [self stopVideoBtnTimer];
}

- (void)setupContainView {
    [super setupContainView];
    
    // 初始化弹幕
    [self setupBarrageView];
    
    // 初始化预览界面
    [self setupPreviewView];
    
    // 初始化预付费邀请没点界面
    [self setupPurchaseCreditView];
    
    // 初始化预付费列表选择界面
    [self setupPrepaidTipView];
}

- (void)removeAllCustonBox {
    [self.dialogView hidenDialog];
    [self.dialogChoose hiddenCheckView];
    [self.prepaidView removeFromSuperview];
    self.prepaidView = nil;
    [self.pickerView removeFromSuperview];
    [self.scheduleListView removeFromSuperview];
    [self.prepaidInfoView removeFromSuperview];
    [self.purchaseCreditView removeShowCreditView];
}

- (void)bringSubviewToFrontFromView:(UIView *)view {
    [self.view bringSubviewToFront:self.giftView];
    [self.view insertSubview:view belowSubview:self.giftView];
}

- (void)setupPrepaidView {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 3.0;
    shadow.shadowOffset = CGSizeMake(0, 0);
    shadow.shadowColor = [UIColor whiteColor];
    NSAttributedString *shadowStr = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"LESSEN_TIP") attributes:@{NSShadowAttributeName:shadow}];
    self.lessenTipLabel.attributedText = shadowStr;
    self.lessenTipLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.lessenTipLabel.layer.shadowOffset = CGSizeMake(0, 1);
    self.lessenTipLabel.layer.shadowOpacity = 0.5;
    
    self.scheduleLessenView.layer.masksToBounds = YES;
    self.scheduleLessenView.layer.cornerRadius = 5;
    LSShadowView *view = [[LSShadowView alloc] init];
    view.shadowColor = [UIColor whiteColor];
    [view showShadowAddView:self.scheduleLessenView];
    self.scheduleLessenView.hidden = YES;
    
    self.prepaidView = [[LSChatPrepaidView alloc] init];
    self.prepaidView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.prepaidView.lessenBtn.hidden = NO;
    self.prepaidView.delegate = self;
}

- (void)setupPurchaseCreditView {
    self.purchaseCreditView = [[LSPurchaseCreditsView alloc] init];
    self.purchaseCreditView.delegate = self;
    [self.purchaseCreditView setupCreditView:self.liveRoom.photoUrl];
}

- (void)setupPrepaidTipView {
    self.prepaidTipViewBgBtn = [[UIButton alloc] init];
    self.prepaidTipViewBgBtn.hidden = YES;
    [self.prepaidTipViewBgBtn addTarget:self action:@selector(closeInputView:) forControlEvents:UIControlEventTouchUpInside];
    [self.liveRoom.superView addSubview:self.prepaidTipViewBgBtn];
    [self.prepaidTipViewBgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.liveRoom.superView);
    }];
    
    self.prepaidTipView = [[LSLivePrepaidTipView alloc] init];
    self.prepaidTipView.delegate = self;
    [self.prepaidTipViewBgBtn addSubview:self.prepaidTipView];
    CGFloat width = 281;
    if (SCREEN_WIDTH < 375) {
        width = 263;
    }
    [self.prepaidTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(width));
        make.height.equalTo(@(0));
        make.right.equalTo(self.scheduleBtn.mas_left);
        make.bottom.equalTo(self.scheduleBtn.mas_bottom).offset(75);
    }];
}

- (void)setupScheduleListView:(InvitedStatus)invitedStatus array:(NSMutableArray *)array {
    self.scheduleListView = [[LSScheduleListView alloc] init];
    self.scheduleListView.delegate = self;
    self.scheduleListView.invitedStatus = invitedStatus;
    [self.navigationController.view addSubview:self.scheduleListView];
    [self.scheduleListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.navigationController.view);
    }];
    [self.scheduleListView setListData:array];
}

/** 显示买点弹框 **/
- (void)showAddCreditsView:(NSString *)tip {
    if (self.viewIsAppear) {
        // 弹出没点弹层收起键盘
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        // 设置没点弹层的层级
        self.creditView = [LSCreditView initLSCreditView];
        self.creditView.delegate = self;
        [self.creditView showLSCreditViewInView:self.navigationController.view];
        self.creditView.tipLabel.text = tip;
    }
}

- (void)creditViewDidAddCredit {
    if ([self.liveDelegate respondsToSelector:@selector(noCreditPushTo:)]) {
        [self.liveDelegate noCreditPushTo:self];
    }
}

- (void)showManPushErrorView:(NSString *)msg retey:(BOOL)retey {
    // 显示开启/关闭双向视频错误弹框
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *closeAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (retey) {
            [self showManPushView:!retey];
        }
    }];
    
    UIAlertAction *retryAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.liveRoom) {
            [self sendVideoControl:retey];
        }
    }];
    [alertVC addAction:closeAC];
    [alertVC addAction:retryAC];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)showManPushView:(BOOL)start {
    // 显示双向视频界面
    self.camBtn.hidden = start;
    self.previewView.hidden = !start;
    self.shadowImageView.hidden = NO;
    if (start) {
        [self.view bringSubviewToFront:self.previewView];
    } else {
        [self stopPublish];
    }
}

#pragma mark - 界面事件

- (IBAction)pushDownChatList:(id)sender {
    @synchronized (self.msgShowArray) {
        if (!self.isMsgPushDown) {
            if (self.msgTableView.indexPathsForVisibleRows.count > 0) {
                self.msgPushDownLastRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
            }
            // 旋转180度
            self.pushDownBtn.transform = CGAffineTransformMakeRotation(M_PI);
            self.msgTableViewTop.constant = self.msgSuperViewH.constant;
            self.isMsgPushDown = YES;
        } else {
            // 按钮还原
            self.pushDownBtn.transform = CGAffineTransformIdentity;
            if (self.topInterval < self.msgSuperViewH.constant) {
                self.msgTableViewTop.constant = self.msgSuperViewH.constant - self.topInterval;
            } else {
                self.msgTableViewTop.constant = 0;
            }
            self.isMsgPushDown = NO;
            // 如果之前在最新消息则展开滑动到最底
            NSInteger lastRow = self.msgShowArray.count - 1;
            if (self.msgPushDownLastRow >= lastRow) {
                [self scrollToEnd:NO];
            }
        }
    }
}
 
- (IBAction)showBtnDid:(UIButton *)sender {
    self.stopVideoBtn.hidden = NO;
    //    self.muteBtn.hidden = NO;
    self.showBtn.hidden = YES;
    @synchronized(self) {
        self.videoBtnLeftSecond = 3;
    }
}

- (IBAction)startManPush:(id)sender {
    // TODO:点击开始视频互动

    // 关闭所有输入
    if ([self.liveDelegate respondsToSelector:@selector(closeAllInputView:)]) {
        [self.liveDelegate closeAllInputView:self];
    }
    
    [[LiveModule module].analyticsManager reportActionEvent:PrivateBroadcastClickVideo eventCategory:EventCategoryBroadcast];
    
    // 开始视频互动
    if (![LSConfigManager manager].dontShow2WayVideoDialog) {
        if (self.dialogChoose) {
            [self.dialogChoose removeFromSuperview];
            self.dialogChoose = nil;
        }
        self.dialogChoose = [DialogChoose dialog];
        NSString *price = [NSString stringWithFormat:@"%.2f", self.liveRoom.imLiveRoom.manPushPrice];
        NSString *tips = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"PUSH_TIPS"), price];
        self.dialogChoose.tipsLabel.text = tips;
        WeakObject(self, weakSelf);
        [self.dialogChoose showDialog:self.navigationController.view
                          cancelBlock:^{
                              // 保存参数
                              [LSConfigManager manager].dontShow2WayVideoDialog = weakSelf.dialogChoose.checkBox.on;
                              [[LSConfigManager manager] saveConfigParam];
                          }
                          actionBlock:^{
                              // 保存参数
                              [LSConfigManager manager].dontShow2WayVideoDialog = weakSelf.dialogChoose.checkBox.on;
                              [[LSConfigManager manager] saveConfigParam];
                              
                              // 开始视频互动
                              if (weakSelf.creditRebateManager.mCredit) {
                                  [weakSelf showManPushView:YES];
                                  [weakSelf sendVideoControl:YES];
                              } else {
                                  [weakSelf showAddCreditsView:NSLocalizedStringFromSelf(@"CAM_NO_CREDITS")];
                              }
                          }];
    } else {
        // 开始视频互动
        if (self.creditRebateManager.mCredit) {
            [self showManPushView:YES];
            [self sendVideoControl:YES];
        } else {
            [self showAddCreditsView:NSLocalizedStringFromSelf(@"CAM_NO_CREDITS")];
        }
    }
}

- (IBAction)stopVideoAction:(id)sender {
    // TODO:点击关闭视频互动
    if (self.dialogChoose) {
        [self.dialogChoose removeFromSuperview];
        self.dialogChoose = nil;
    }
    // 关闭所有输入
    if ([self.liveDelegate respondsToSelector:@selector(closeAllInputView:)]) {
        [self.liveDelegate closeAllInputView:self];
    }
    
    // 关闭视频互动
    [self sendVideoControl:NO];
}

- (void)reloadVideoStatus {
    NSLog(@"LSVIPLiveViewController::reloadVideoStatus( publishUrl : %@ )", self.liveRoom.publishUrl);
    if (self.liveRoom.publishUrl.length > 0) {
        // 已经有推流地址, 发送命令
        [self showManPushView:YES];
        [self sendVideoControl:YES];
    } else {
        // 停止推流
        [self stopPublish];
    }
}

- (void)stopCamVideo {
    // 关闭视频互动
    [self stopVideoAction:nil];
}

- (IBAction)storeBtnDid:(id)sender {
    if ([self.liveDelegate respondsToSelector:@selector(pushStoreVC:)]) {
        [self.liveDelegate pushStoreVC:self];
    }
}

- (IBAction)scheduleInvite:(id)sender {
    [self scheduleBtnAnimaiton:NO];

    if (self.scheduleCount > 0) {
        [self.liveManager getScheduleList];
        
        self.prepaidTipViewBgBtn.hidden = NO;
        [self.liveRoom.superView bringSubviewToFront:self.prepaidTipViewBgBtn];
    } else {
        if (!self.scheduleLessenView.isHidden) {
            self.scheduleLessenView.hidden = YES;
        }
        [self.navigationController.view addSubview:self.prepaidView];
    }
}

- (IBAction)showPrepaidView:(id)sender {
    self.scheduleLessenView.hidden = YES;
    [self.navigationController.view addSubview:self.prepaidView];
}

- (void)closeInputView:(id)sender {
    self.prepaidTipViewBgBtn.hidden = YES;
}

- (void)scheduleBtnAnimaiton:(BOOL)isStart {
    if (isStart) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        animation.repeatCount = MAXFLOAT;
        animation.autoreverses = YES;
        animation.duration = 1;
        animation.fromValue = (__bridge id _Nullable)(Color(0, 0, 0, 0.5).CGColor);
        animation.toValue = (__bridge id _Nullable)(Color(255, 255, 0, 0.5).CGColor);
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.scheduleBtn.layer addAnimation:animation forKey:@"backgroundColor"];
    } else {
        [self.scheduleBtn.layer removeAllAnimations];
        [self.scheduleBtn setBackgroundColor:Color(0, 0, 0, 0.5)];
    }
}

#pragma mark - 流[播放/推送]逻辑
- (void)play {
    self.playUrl = self.liveRoom.playUrl;
    NSLog(@"LSVIPLiveViewController::play( [开始播放流], playUrl : %@ )", self.playUrl);
   
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *dateString = [LSDateFormatter toStringYMDHMSWithUnderLine:[NSDate date]];
    NSString *recordFilePath = [LiveModule module].debug ? [NSString stringWithFormat:@"%@/%@_%@.flv", recordDir, self.liveRoom.userId, dateString] : @"";
    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/%@", recordDir, @"play.h264"];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/%@", recordDir, @"play.aac"];
    
    // 开始转菊花
    [LSMinLiveManager manager].minView.loadingView.hidden = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bFlag = [self.player playUrl:self.playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 停止菊花
            if (bFlag) {
                // 播放成功
              
            } else {
                // 播放失败
            }
        });
    });
}

- (void)stopPlay {
    NSLog(@"LSVIPLiveViewController::stopPlay()");
    
    [self.player stop];
}

- (void)initPublish {
    NSLog(@"LSVIPLiveViewController::initPublish( [初始化推送流] )");
    // 初始化采集
    [[LiveStreamSession session] checkAudio:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Open_Permissions_Tip") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *_Nonnull action){
                                                                     
                                                                 }];
                [alertVC addAction:actionOK];
                [self presentViewController:alertVC animated:NO completion:nil];
            }
        });
    }];
    
    [[LiveStreamSession session] checkVideo:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Open_Permissions_Tip") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *_Nonnull action){
                                                                     
                                                                 }];
                [alertVC addAction:actionOK];
                [self presentViewController:alertVC animated:NO completion:nil];
            }
        });
    }];
    
    // 初始化预览界面
    self.publisher.publishView = self.previewVideoView;
    self.publisher.publishView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
}

- (void)publish {
    self.publishUrl = self.liveRoom.publishUrl;
    NSLog(@"LSVIPLiveViewController::publish( [开始推送流], publishUrl : %@ )", self.publishUrl);
   
    [self.publisher pushlishUrl:self.publishUrl recordH264FilePath:@"" recordAACFilePath:@""];
}

- (void)stopPublish {
    NSLog(@"LSVIPLiveViewController::stopPublish()");
    [self.publisher stop];
}

#pragma mark - 流[播放/推送]通知
- (NSString *)playerShouldChangeUrl:(LiveStreamPlayer *)player {
    NSString *url = player.url;
    
    @synchronized(self) {
        if (self.playerReconnectTime++ > STREAM_PLAYER_RECONNECT_MAX_TIMES) {
            // 断线超过指定次数, 切换URL
            url = [self.liveRoom changePlayUrl];
            self.playerReconnectTime = 0;
            
            NSLog(@"LSVIPLiveViewController::playerShouldChangeUrl( [切换播放流URL], url : %@)", url);
        }
    }
    
    return url;
}

- (NSString *)publisherShouldChangeUrl:(LiveStreamPublisher *)publisher {
    NSString *url = publisher.url;
    
    @synchronized(self) {
        if (self.publisherReconnectTime++ > STREAM_PUBLISH_RECONNECT_MAX_TIMES) {
            // 断线超过指定次数, 切换URL
            url = [self.liveRoom changePublishUrl];
            self.publisherReconnectTime = 0;
            
            NSLog(@"LSVIPLiveViewController::publisherShouldChangeUrl( [切换推送流URL], url : %@)", url);
        }
    }
    
    return url;
}

- (void)playerOnConnect:(LiveStreamPlayer * _Nonnull)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 流媒体连接成功 上传拉流时间
        [[LSStreamSpeedManager manager] requestPushPullLogs:self.liveRoom.roomId];
        
        self.bgView.hidden = YES;
        [LSMinLiveManager manager].minView.loadingView.hidden = YES;
        
        if (self.isRoomFree && self.liveRoom.publicRoomFreeMsg.length > 0) {
            [self.dialogProbationTip showDialogTip:self.liveRoom.superView tipText:self.liveRoom.publicRoomFreeMsg];
            self.isRoomFree = NO;
        }
    });

}

- (void)playerOnDisconnect:(LiveStreamPlayer * _Nonnull)player {
    dispatch_async(dispatch_get_main_queue(), ^{

    });
//    self.bgView.hidden = NO;
}

- (void)publisherOnConnect:(LiveStreamPublisher * _Nonnull)publisher {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.shadowImageView.hidden = YES;
        if (!self.preActivityView.isHidden) {
            self.preActivityView.hidden = YES;
        }
    });
    NSString *url = publisher.url;
    NSLog(@"LSVIPLiveViewController::publisherOnConnect( [推送流URL], url : %@)", url);
}

- (void)publisherOnDisconnect:(LiveStreamPublisher *)publisher {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.preActivityView.isHidden) {
            self.preActivityView.hidden = NO;
        }
    });
}

#pragma mark - 关闭/开启直播间声音(LiveChat使用)
- (void)openOrCloseSuond:(BOOL)isClose {
    self.publisher.mute = isClose;
    self.player.mute = isClose;
}

#pragma mark - 初始化座驾控件
- (PrivateDriveView *)privateDriveView {
    if (!_privateDriveView) {
        _privateDriveView = [[PrivateDriveView alloc] init];
    }
    return _privateDriveView;
}

#pragma mark - 座驾（入场信息）
- (void)showDriveView:(AudienceModel *)model {
    self.privateDriveView.model = model;
    [self.view addSubview:self.privateDriveView];
    self.privateDriveView.alpha = 0;
    [self.privateDriveView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.offset(68);
        make.right.offset(-17);
        make.width.offset(83);
        make.height.offset(83);
    }];
   
    // 座驾动画
    [UIView animateWithDuration:1 animations:^{
        self.privateDriveView.alpha = 1;
    } completion:^(BOOL finished) {
        // 平移动画
        [self.privateDriveView showCarAnimation:CGPointMake(60, 211)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1 animations:^{
                self.privateDriveView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.privateDriveView removeFromSuperview];
                self.privateDriveView = nil;
            }];
        });
        
    }];
}

#pragma mark - 连击管理
- (void)setupGiftView {
    [self.giftView removeAllSubviews];
    
    self.giftComboViews = [NSMutableArray array];
    self.giftComboViewsLeadings = [NSMutableArray array];
    
    GiftComboView *preGiftComboView = nil;
    
    for (int i = 0; i < 2; i++) {
        GiftComboView *giftComboView = [GiftComboView giftComboView:self];
        [self.giftView addSubview:giftComboView];
        [self.giftComboViews addObject:giftComboView];
        
        giftComboView.tag = i;
        giftComboView.delegate = self;
        giftComboView.hidden = YES;
        
        UIImage *image = self.roomStyleItem.comboViewBgImage; // [UIImage imageNamed:@"Live_Public_Bg_Combo"]
        [giftComboView.backImageView setImage:image];
        giftComboView.numberView.numImageName = self.roomStyleItem.comboNumImageName;
        
        NSNumber *height = [NSNumber numberWithInteger:giftComboView.frame.size.height];
        
        if (!preGiftComboView) {
            [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.giftView);
                make.width.equalTo(@250);
                make.height.equalTo(height);
                MASConstraint *leading = make.left.equalTo(self.giftView.mas_left).offset(-250);
                [self.giftComboViewsLeadings addObject:leading];
            }];
            
        } else {
            [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(preGiftComboView.mas_top).offset(-5);
                make.width.equalTo(@250);
                make.height.equalTo(height);
                MASConstraint *leading = make.left.equalTo(self.giftView.mas_left).offset(-250);
                [self.giftComboViewsLeadings addObject:leading];
            }];
        }
        
        preGiftComboView = giftComboView;
    }
}

- (BOOL)showCombo:(GiftItem *)giftItem giftComboView:(GiftComboView *)giftComboView withUserID:(NSString *)userId {
    BOOL bFlag = YES;
    
    giftComboView.hidden = NO;
    
    // 发送人名 礼物名
    giftComboView.nameLabel.text = giftItem.nickname;
    giftComboView.sendLabel.text = [NSString stringWithFormat:@"sent gift \"%@\"",giftItem.giftname];
    
    
    // 数量
    giftComboView.beginNum = giftItem.multi_click_start;
    giftComboView.endNum = giftItem.multi_click_end;
    
    NSLog(@"LSVIPLiveViewController::showCombo( [显示连击礼物], beginNum : %ld, endNum: %ld, clickID : %ld )", (long)giftComboView.beginNum, (long)giftComboView.endNum, (long)giftItem.multi_click_id);
    
    // 连击礼物
    LSGiftManagerItem *item = [self.giftDownloadManager getGiftItemWithId:giftItem.giftid];
    NSString *imgUrl = item.infoItem.bigImgUrl;
    [self.giftImageLoader loadImageWithImageView:giftComboView.giftImageView
                                         options:0
                                        imageUrl:imgUrl
                                placeholderImage:
     [UIImage imageNamed:@"Live_Gift_Nomal"]
                                   finishHandler:nil];
    
    [self.headImageLoader loadImageWithImageView:giftComboView.iconImageView options:0 imageUrl:giftItem.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"] finishHandler:nil];
    
    giftComboView.item = giftItem;
    
    
    // 从左到右
    NSInteger index = giftComboView.tag;
    MASConstraint *giftComboViewsLeading = [self.giftComboViewsLeadings objectAtIndex:index];
    [giftComboViewsLeading uninstall];
    [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
        MASConstraint *newGiftComboViewLeading = make.left.equalTo(self.giftView.mas_left).offset(10);
        [self.giftComboViewsLeadings replaceObjectAtIndex:index withObject:newGiftComboViewLeading];
    }];
    
    [giftComboView reset];
    [giftComboView start];
    
    NSTimeInterval duration = 0.3;
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.giftView layoutIfNeeded];
                         
                     }
                     completion:^(BOOL finished) {
                         // 开始连击
                         [giftComboView playGiftCombo];
                     }];
    
    return bFlag;
}

- (void)addCombo:(GiftItem *)giftItem {
    // 寻找可用界面
    GiftComboView *giftComboView = nil;
    
    for (GiftComboView *view in self.giftComboViews) {
        if (!view.playing) {
            // 寻找空闲的界面
            giftComboView = view;
            
        } else {
            
            if ([view.item.itemId isEqualToString:giftItem.itemId]) {
                
                // 寻找正在播放同一个连击礼物的界面
                giftComboView = view;
                // 更新最后连击数字
                giftComboView.endNum = giftItem.multi_click_end;
                break;
            }
        }
    }
    
    if (giftComboView) {
        // 有空闲的界面
        if (!giftComboView.playing) {
            // 开始播放新的礼物连击
            [self showCombo:giftItem giftComboView:giftComboView withUserID:giftItem.fromid];
            NSLog(@"LSVIPLiveViewController::addCombo( [增加连击礼物, 播放], starNum : %ld, endNum : %ld, clickID : %ld )", (long)giftItem.multi_click_start, (long)giftItem.multi_click_end, (long)giftItem.multi_click_id);
        }
        
    } else {
        // 没有空闲的界面, 放到缓存
        [self.giftComboManager pushGift:giftItem];
        NSLog(@"LSVIPLiveViewController::addCombo( [增加连击礼物, 缓存], starNum : %ld, endNum : %ld, clickID : %ld )", (long)giftItem.multi_click_start, (long)giftItem.multi_click_end, (long)giftItem.multi_click_id);
    }
}

#pragma mark - 连击回调(GiftComboViewDelegate)
- (void)playComboFinish:(GiftComboView *)giftComboView {
    // 收回界面
    NSInteger index = giftComboView.tag;
    MASConstraint *giftComboViewsLeading = [self.giftComboViewsLeadings objectAtIndex:index];
    [giftComboViewsLeading uninstall];
    [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
        MASConstraint *newGiftComboViewLeading = make.left.equalTo(self.giftView.mas_left).offset(-220);
        [self.giftComboViewsLeadings replaceObjectAtIndex:index withObject:newGiftComboViewLeading];
    }];
    giftComboView.hidden = YES;
    [self.giftView layoutIfNeeded];
    
    // 显示下一个
    GiftItem *giftItem = [self.giftComboManager popGift:nil];
    if (giftItem) {
        // 开始播放新的礼物连击
        [self showCombo:giftItem giftComboView:giftComboView withUserID:giftItem.fromid];
    }
}

#pragma mark - 播放大礼物
- (void)starBigAnimationWithGiftID:(NSString *)giftID {
    self.giftAnimationView = [BigGiftAnimationView sharedObject];
    self.giftAnimationView.userInteractionEnabled = NO;
    
    LSGiftManagerItem *item = [self.giftDownloadManager getGiftItemWithId:giftID];
    LSYYImage *image = item.bigGiftImage;
    
    // 判断本地文件是否损伤 有则播放 无则删除重下播放下一个
    if (image) {
        self.giftAnimationView.contentMode = UIViewContentModeScaleAspectFit;
        self.giftAnimationView.image = image;
        [self.liveRoom.superView addSubview:self.giftAnimationView];
        [self.liveRoom.superView bringSubviewToFront:self.giftAnimationView];
        [self.giftAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.liveRoom.superView);
            make.width.height.equalTo(self.liveRoom.superView);
        }];
        [self bringLiveRoomSubView];
        
    } else {
        // 重新下载
        [item download];
        // 结束动画
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GiftAnimationIsOver" object:self userInfo:nil];
    }
}

// 遍历最外层控制器视图 将dialog放到最上层
- (void)bringLiveRoomSubView {
    for (UIView *view in self.liveRoom.superView.subviews) {
        if (IsDialog(view)) {
            [self.liveRoom.superView bringSubviewToFront:view];
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

#pragma mark - 弹幕管理
- (void)setupBarrageView {
    self.barrageView.delegate = self;
    self.barrageView.dataSouce = self;
}

#pragma mark - 弹幕回调(BarrageView)
- (NSUInteger)numberOfRowsInTableView:(BarrageView *)barrageView {
    return 1;
}

- (BarrageViewCell *)barrageView:(BarrageView *)barrageView cellForModel:(BarrageModel *)model {
    BarrageModelCell *cell = [BarrageModelCell cellWithBarrageView:barrageView];
    cell.model = model;
    
    [self.headImageLoader loadImageFromCache:cell.imageViewHeader options:SDWebImageRefreshCached imageUrl:model.url placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]
       finishHandler:^(UIImage *image){
    }];
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                    NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0xffd205)}];
    
    NSMutableAttributedString *message = [self.emotionManager parseMessageTextEmotion:[NSString stringWithFormat:@": %@",model.message] font:[UIFont boldSystemFontOfSize:14]];
    [message addAttributes:@{NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0xffffff)} range:NSMakeRange(0, message.length)];
    [name appendAttributedString:message];
    
    cell.labelMessage.attributedText = name;
    
    return cell;
}

- (void)barrageView:(BarrageView *)barrageView didSelectedCell:(BarrageViewCell *)cell {
}

- (void)barrageView:(BarrageView *)barrageView willDisplayCell:(BarrageViewCell *)cell {
    
}

- (void)barrageView:(BarrageView *)barrageView didEndDisplayingCell:(BarrageViewCell *)cell {
    
}

#pragma mark - LSChatPrepaidViewDelegate
- (void)chatPrepaidViewDidTimeBtn:(UIButton *)button {
    self.pickerView = [[LSPrePaidPickerView alloc] init];
    self.pickerView.delegate = self;
    [self.view.window addSubview:self.pickerView];
    self.pickerView.selectTimeRow = [self.prepaidView getSelectedRow:button];
    self.pickerView.items = [self.prepaidView getPickerData:button];
    [self.pickerView reloadData];
}

- (void)chatPrepaidViewDidClose {
    [self.prepaidView removeFromSuperview];
}

- (void)chatPrepaidViewDidLessen:(UIButton *)button {
    [self.prepaidView removeFromSuperview];
    self.scheduleLessenView.hidden = NO;
    [self.view bringSubviewToFront:self.scheduleLessenView];
}

- (void)chatPrepaidViewDidSend:(LSScheduleInviteItem *)item {
    self.prepaidView.sendBtn.userInteractionEnabled = NO;
    LSScheduleInviteItem * inviteItem = [[LSScheduleInviteItem alloc]init];
    if (self.liveRoom.roomType == LiveRoomType_Public) {
        inviteItem.type = LSSCHEDULEINVITETYPE_PUBLICLIVE;
    } else if (self.liveRoom.roomType == LiveRoomType_Private) {
        inviteItem.type = LSSCHEDULEINVITETYPE_PRIVATELIVE;
    }
    inviteItem.refId = self.liveRoom.roomId;
    inviteItem.anchorId = self.liveRoom.userId;
    inviteItem.timeZoneItem = self.paidManager.zoneItem;
    inviteItem.startTime = [self.paidManager getSendRequestTime:@"yyyy-MM-dd HH:00:00"];
    inviteItem.duration = [self.paidManager.duration intValue];
    [self.liveManager sendScheduleInviteToAnchor:inviteItem];
}

- (void)chatPrepaidViewDidHowWork {
    self.prepaidInfoView = nil;
    [self.prepaidInfoView removeFromSuperview];
    self.prepaidInfoView = [[LSPrepaidInfoView alloc] init];
    [self.navigationController.view addSubview:self.prepaidInfoView];
    [self.prepaidInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.navigationController.view);
    }];
}

#pragma mark - PrePaidPickerViewDelegate
- (void)removePrePaidPickerView {
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
    [self.prepaidView.deteView resetBtnState];
}

- (void)prepaidPickerViewSelectedRow:(NSInteger)row {
    BOOL isShowPrepaidView = NO;
    for (UIView *view in self.navigationController.view.subviews) {
        if ([view isKindOfClass:[LSChatPrepaidView class]]) {
            isShowPrepaidView = YES;
            break;
        }
    }
    if (isShowPrepaidView) {
        // 刷新发送卡片
        [self.prepaidView pickerViewSelectedRow:row];
    } else if (self.scheduleListView) {
        // 刷新预付费列表
        LSScheduleDurationItemObject *item = [self.paidManager.creditsArray objectAtIndex:row];
        [self.scheduleListView reloadSelectTime:item];
    } else {
        // 刷新主播邀请预付费消息
        LSScheduleDurationItemObject *item = [self.paidManager.creditsArray objectAtIndex:row];
        @synchronized (self.msgShowArray) {
            MsgItem *msgItem = self.msgShowArray[self.scheduleItemRow];
            if (msgItem.scheduleMsg.msg.duration != item.duration) {
                msgItem.scheduleMsg.msg.duration = item.duration;
                [self.msgTableView reloadData];
            }
        }
    }
     [self removePrePaidPickerView];
}

#pragma mark - LSPurchaseCreditsViewDelegate
- (void)purchaseDidAction {
    [self.purchaseCreditView removeShowCreditView];
    if ([self.liveDelegate respondsToSelector:@selector(noCreditPushTo:)]) {
        [self.liveDelegate noCreditPushTo:self];
    }
}

#pragma mark - LSLivePrepaidTipViewDelegate
- (void)prepaidTipViewDidConfirm {
    self.prepaidTipViewBgBtn.hidden = YES;
    [self setupScheduleListView:INVITEDSTATUS_CONFIRM array:self.paidManager.scheduleListConfirmedArray];
}

- (void)prepaidTipViewDidPending {
    self.prepaidTipViewBgBtn.hidden = YES;
    [self setupScheduleListView:INVITEDSTATUS_PENDING array:self.paidManager.scheduleListPendingdArray];
}

- (void)prepaidTipViewDidSendRequest {
    self.prepaidTipViewBgBtn.hidden = YES;
    if (!self.scheduleLessenView.isHidden) {
        self.scheduleLessenView.hidden = YES;
    }
    [self.navigationController.view addSubview:self.prepaidView];
}

#pragma mark - LSScheduleListViewDelegate
- (void)changeDurationForItem:(LSScheduleLiveInviteItemObject *)item {
    NSInteger selectRow = 0;
    for (int i = 0; i < self.paidManager.creditsArray.count; i++) {
        LSScheduleDurationItemObject * cItem = self.paidManager.creditsArray[i];
        if (cItem.duration == item.duration) {
            selectRow = i;
            break;
        }
    }
    
    self.pickerView = [[LSPrePaidPickerView alloc] init];
    self.pickerView.delegate = self;
    [self.view.window addSubview:self.pickerView];
    self.pickerView.selectTimeRow = selectRow;
    self.pickerView.items = [self.paidManager getCreditArray];
    [self.pickerView reloadData];
}

- (void)sendAcceptSchedule:(NSString *)inviteId duration:(int)duration item:(LSScheduleInviteItem *)item {
    [self closeScheduleListView];
    item.refId = self.liveRoom.roomId;
    [self.liveManager sendAcceptScheduleInviteToAnchor:inviteId duration:duration infoObj:item];
}

- (void)closeScheduleListView {
    [self.scheduleListView removeFromSuperview];
    self.scheduleListView = nil;
}

- (void)howWorkScheduleListView {
    [self chatPrepaidViewDidHowWork];
}

#pragma mark - 消息列表管理
- (void)setupTableView {
    self.scheduleNumLabel.layer.masksToBounds = YES;
    self.scheduleNumLabel.layer.cornerRadius = self.scheduleNumLabel.tx_height / 2;
    
    // 防止更改tableview高度cell跳动
    self.msgTableView.estimatedRowHeight = 0;
    self.msgTableView.estimatedSectionFooterHeight = 0;
    self.msgTableView.estimatedSectionHeaderHeight = 0;
    
    [self.msgTableView setTableFooterView:[UIView new]];
    
    self.msgTableView.clipsToBounds = YES;
    self.msgTableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    
    self.msgTipsView.clipsToBounds = YES;
    self.msgTipsView.hidden = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMsgTipsView:)];
    [self.msgTipsView addGestureRecognizer:singleTap];
}

- (BOOL)sendMsg:(NSString *)text isLounder:(BOOL)isLounder {
    BOOL bFlag = NO;
   
    NSString *str = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (str.length > 0) {
        bFlag = YES;
        if (isLounder) {
            // 发送弹幕
            [self.liveManager sendRoomToast:text];
        } else {
            // 发送直播间消息
            [self.liveManager sendLiveRoomChat:text at:nil];
        }
    }
    return bFlag;
}

- (void)addMsg:(MsgItem *)item replace:(BOOL)replace scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated {
    // 计算文本高度
    if (item.msgType == MsgType_Knock || item.msgType == MsgType_Recommend) {
        item.containerHeight = [self getInviteCellHeight:item];
    } else {
        if (!(item.msgType == MsgType_Schedule_Status_Tip || item.msgType == MsgType_Schedule)) {
            item.containerHeight = [self computeContainerHeight:item];
        }
    }
    
    @synchronized (self.msgArray) {
        @synchronized (self.msgShowArray) {
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
            
            // 改变tableview高度
            CGFloat time = 0;
            self.topInterval += item.containerHeight;
            if (!self.isMsgPushDown) {
                if (self.topInterval < self.msgSuperViewH.constant) {
                    self.msgTableViewTop.constant = self.msgSuperViewH.constant - self.topInterval;
                    time = 0.1;
                } else {
                    self.msgTableViewTop.constant = 0;
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (lastVisibleRow >= lastRow && !self.isMsgPushDown) {
                    // 如果消息列表当前能显示最新的消息
                    NSInteger count = self.msgArray.count - self.msgShowArray.count;
                    
                    // 直接刷新
                    [self.msgTableView beginUpdates];
                    if (deleteOldMsg) {
                        if (replace) {
                            // 删除一条最新消息
                            [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.msgShowArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        } else {
                            for (int index = 0; index < count; index++) {
                                // 超出最大消息限制, 删除列表一条旧消息
                                [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                            }
                        }
                    }
                    
                    // 替换显示的消息列表
                    self.msgShowArray = [NSMutableArray arrayWithArray:self.msgArray];
                    for (int index = 1; index < count+1; index++) {
                        // 增加列表一条新消息
                        [self.msgTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:lastVisibleRow + index inSection:0]] withRowAnimation:(deleteOldMsg && replace) ? UITableViewRowAnimationNone : UITableViewRowAnimationBottom];
                    }
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
            });
        }
    }
}

- (void)scrollToEnd:(BOOL)animated {
    NSInteger count = [self.msgTableView numberOfRowsInSection:0];
    if (count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
        [self.msgTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)chatListScrollToEnd {
    @synchronized (self.msgShowArray) {
        // 计算当前显示的位置
        NSInteger lastVisibleRow = -1;
        if (self.msgTableView.indexPathsForVisibleRows.count > 0) {
            lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
        }
        NSInteger lastRow = self.msgShowArray.count - 1;
        if (lastVisibleRow <= lastRow) {
            [self scrollToEnd:NO];
        }
    }
}

- (void)showUnReadMsg {
    self.unReadMsgCount++;
    
    if (!self.msgSuperView.hidden) {
        self.msgTipsView.hidden = NO;
    }
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld ", (long)self.unReadMsgCount]];
    [attString addAttributes:@{
                               NSFontAttributeName : [UIFont systemFontOfSize:12],
                               NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838)
                               }
                       range:NSMakeRange(0, attString.length)];
    
    NSMutableAttributedString *attStringMsg = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"UnRead_Messages")];
    [attStringMsg addAttributes:@{
                                  NSFontAttributeName : [UIFont systemFontOfSize:12],
                                  NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838)
                                  }
                          range:NSMakeRange(0, attStringMsg.length)];
    [attString appendAttributedString:attStringMsg];
    self.msgTipsLabel.attributedText = attString;
}

- (void)hideUnReadMsg {
    self.unReadMsgCount = 0;
    self.msgTipsView.hidden = YES;
}

- (void)tapMsgTipsView:(id)sender {
    if (self.msgTableViewTop.constant) {
        if (self.topInterval < self.msgSuperViewH.constant) {
            self.msgTableViewTop.constant = self.msgSuperViewH.constant - self.topInterval;
        } else {
            self.msgTableViewTop.constant = 0;
        }
        self.pushDownBtn.transform = CGAffineTransformIdentity;
        self.isMsgPushDown = NO;
    }
   
    if (self.msgShowArray.count > 0 && self.needToReload) {
        // 同步位置
        [self scrollToEnd:NO];
    }
}

- (CGFloat)computeContainerHeight:(MsgItem *)item {
    CGFloat height = 0;
    CGFloat width = 0;
    // 减去label对于背景左右边距
    if (item.msgType == MsgType_Gift || item.msgType == MsgType_Chat) {
        width = self.msgSuperView.frame.size.width - 11;
    } else {
        width = self.msgSuperView.frame.size.width - 18;
    }
    YYTextContainer *container = [[YYTextContainer alloc] init];
    container.size = CGSizeMake(width, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:item.attText];
    // label高度+对于背景上下边距+背景对于父view上下边距
    height = layout.textBoundingSize.height + 6 + 6;
    if (height < 25) {
        height = 25;
    }
    item.layout = layout;
    CGFloat y = (height - layout.textBoundingSize.height - 4) / 2;
    item.labelFrame = CGRectMake(0, y, layout.textBoundingSize.width, layout.textBoundingSize.height);
    return height;
}

- (CGFloat)getInviteCellHeight:(MsgItem *)item {
    CGFloat height = 0;
    CGFloat width = self.msgSuperView.frame.size.width;
    YYTextContainer *container = [[YYTextContainer alloc] init];
    container.size = CGSizeMake(width, CGFLOAT_MAX);
    if (!item.attText.string.length) {
        item.attText = [[NSMutableAttributedString alloc] initWithString:item.text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    }
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:item.attText];
    height = layout.textBoundingSize.height + 10 + 75;
    item.layout = layout;
    return height;
}

// 更新预付费消息状态
- (void)updateScheduleStatusTime:(NSInteger)statusUpdateTime scheduleInviteId:(NSString *)inviteId duration:(int)duration status:(IMScheduleSendStatus)status roomInfoItem:(ImScheduleRoomInfoObject *)roomInfoItem {
    @synchronized (self.msgShowArray) {
        for (MsgItem *msgItem in [[self.msgShowArray reverseObjectEnumerator] allObjects]) {
            if ([msgItem.scheduleMsg.privScheId isEqualToString:inviteId]) {
                if (status == IMSCHEDULESENDSTATUS_CONFIRMED) {
                    msgItem.scheduleType = ScheduleType_Confirmed;
                } else if (status == IMSCHEDULESENDSTATUSE_DECLINED) {
                     msgItem.scheduleType = ScheduleType_Declined;
                }
                msgItem.scheduleMsg.msg.statusUpdateTime = statusUpdateTime;
                msgItem.scheduleMsg.msg.status = status;
                msgItem.scheduleMsg.msg.duration = duration;
                msgItem.containerHeight = [LSScheduleInviteCell cellHeight:msgItem.isScheduleMore isAcceptView:NO isMinimum:msgItem.isMinimu];
                [self.msgTableView reloadData];
                break;
             }
        }
    }
    // 插入预付费状态更新消息
    MsgItem *item = [[MsgItem alloc] init];
    item.usersType = UsersType_Liver;
    item.scheduleMsg = roomInfoItem;
    if (status == IMSCHEDULESENDSTATUSE_DECLINED) {
        item.scheduleType = ScheduleType_Declined;
    } else {
        item.scheduleType = ScheduleType_Confirmed;
    }
    [self.liveManager addScheduleInviteReplyMsg:item];
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
    @synchronized (self.msgShowArray) {
        NSInteger number = self.msgShowArray ? self.msgShowArray.count : 0;
        
        return number;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @synchronized (self.msgShowArray) {
        MsgItem *item = [self.msgShowArray objectAtIndex:indexPath.row];
        CGFloat cellHeight = item.containerHeight;
        if (item.msgType == MsgType_Talent) {
            cellHeight = [TalentMsgCell cellHeight];
        }
        return cellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @synchronized (self.msgShowArray) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
        // 数据填充
        if (indexPath.row < self.msgShowArray.count) {
            MsgItem *item = [self.msgShowArray objectAtIndex:indexPath.row];
            
            switch (item.msgType) {
                case MsgType_Talent: {
                    TalentMsgCell *msgCell = [TalentMsgCell getUITableViewCell:tableView];
                    [msgCell updateMsg:item];
                    msgCell.talentCellDelegate = self;
                    cell = msgCell;
                } break;
                    
                case MsgType_Knock:
                case MsgType_Recommend: {
                    LSInviteHangoutMsgCell *msgCell = [LSInviteHangoutMsgCell getUITableViewCell:tableView];
                    msgCell.delagate = self;
                    [msgCell upDataInviteMessage:item];
                    
    //                HangOutOpenDoorCell *msgCell = [tableView dequeueReusableCellWithIdentifier:[HangOutOpenDoorCell cellIdentifier]];
    //                msgCell.delagate = self;
    //                [msgCell updataChatMessage:item];
                    cell = msgCell;
                } break;
                    
                case MsgType_Schedule:{
                    LSScheduleInviteCell *msgCell = [LSScheduleInviteCell getUITableViewCell:tableView];
                    msgCell.delegate = self;
                    if (item.isMinimu) {
                        [msgCell showMinimumView:item];
                    } else {
                        if (item.usersType == UsersType_Liver && item.scheduleType == ScheduleType_Pending) {
                            [msgCell updateAcceptData:item];
                        } else {
                            [msgCell updateCardData:item anchorName:self.liveRoom.userName];
                        }
                    }
                    cell = msgCell;
                }break;
                    
                case MsgType_Schedule_Status_Tip:{
                    LSScheduleStatusTipCell *msgCell = [LSScheduleStatusTipCell getUITableViewCell:tableView];
                    msgCell.delegate = self;
                    [msgCell updataInfo:item];
                    cell = msgCell;
                }break;
                
                default: {
                    MsgTableViewCell *msgCell = [tableView dequeueReusableCellWithIdentifier:[MsgTableViewCell cellIdentifier]];
                    if (!msgCell) {
                        msgCell = [[MsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MsgTableViewCell cellIdentifier]];
                    }
                    msgCell.clipsToBounds = YES;
                    msgCell.msgDelegate = self;
                    [msgCell setupChatMessage:item styleItem:self.roomStyleItem];
                    cell = msgCell;
                } break;
            }
        } else {
            if (!cell) {
                cell = [[UITableViewCell alloc] init];
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)talentMsgCellDid {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showTalentList" object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    @synchronized (self.msgShowArray) {
        NSInteger lastVisibleRow = -1;
        if (self.msgTableView.indexPathsForVisibleRows.count > 0) {
            lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
        }
        NSInteger lastRow = self.msgShowArray.count - 1;

        if (self.msgShowArray.count > 0 && lastVisibleRow >= lastRow) {
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
}

#pragma mark - MsgTableViewCellDelegate
- (void)msgCellRequestHttp:(NSString *)linkUrl {
    LiveWebViewController *webViewController = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
    webViewController.url = linkUrl;
    webViewController.isIntimacy = NO;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - LSInviteHangoutMsgCellDelegate
- (void)inviteHangoutAnchor:(MsgItem *)item {
    [[LiveModule module].analyticsManager reportActionEvent:ClickHangOutNow eventCategory:EventCategoryBroadcast];
    
    // 处理主播推荐好友请求
   if (!self.isInvitingHangout) {
       self.isInvitingHangout = YES;
       
       [self.liveManager sendHangoutInvite:item.recommendItem.recommendId recommendAnchorId:item.recommendItem.friendId recommendAnchorName:item.recommendItem.friendNickName];
   }
}

#pragma mark - LSScheduleInviteCellDelegate
- (void)liveScheduleInviteCellDidAccept:(LSScheduleInviteCell *)cell {
    NSIndexPath *indexPath = [self.msgTableView indexPathForCell:cell];
    @synchronized (self.msgShowArray) {
        MsgItem *item = self.msgShowArray[indexPath.row];
        if (item) {
            int duration = item.scheduleMsg.msg.duration;
            if (duration <= 0) {
                duration = item.scheduleMsg.msg.origintduration;
            }
            LSScheduleInviteItem *inviteItem = [[LSScheduleInviteItem alloc] init];
            inviteItem.refId = self.liveRoom.roomId;
            inviteItem.origintduration = item.scheduleMsg.msg.origintduration;
            inviteItem.period = item.scheduleMsg.msg.period;
            inviteItem.gmtStartTime = item.scheduleMsg.msg.startTime;
            inviteItem.sendTime = item.scheduleMsg.msg.sendTime;
            [self.liveManager sendAcceptScheduleInviteToAnchor:item.scheduleMsg.privScheId duration:duration infoObj:inviteItem];
        }
    }
}

- (void)liveScheduleInviteCellDidDurationRow:(LSScheduleInviteCell *)cell {
    NSIndexPath *indexPath = [self.msgTableView indexPathForCell:cell];
    self.scheduleItemRow = indexPath.row;
    @synchronized (self.msgShowArray) {
        MsgItem *item = self.msgShowArray[self.scheduleItemRow];
        if (item) {
            NSInteger selectRow = 0;
            int duration = item.scheduleMsg.msg.duration;
            if (duration == 0) {
                duration = item.scheduleMsg.msg.origintduration;
            }
            for (int i = 0;i<[LSPrePaidManager manager].creditsArray.count;i++) {
                LSScheduleDurationItemObject * cItem = [LSPrePaidManager manager].creditsArray[i];
                if (cItem.duration == duration) {
                    selectRow = i;
                    break;
                }
            }
            
            self.pickerView = [[LSPrePaidPickerView alloc]init];
            self.pickerView.delegate = self;
            [self.view.window addSubview:self.pickerView];
            self.pickerView.selectTimeRow = selectRow;
            self.pickerView.items = [self.paidManager getCreditArray];
            [self.pickerView reloadData];
        }
    }
}

- (void)liveScheduleInviteCellHidenDetalis:(LSScheduleInviteCell *)cell {
    NSIndexPath *indexPath = [self.msgTableView indexPathForCell:cell];
    @synchronized (self.msgShowArray) {
        MsgItem *item = self.msgShowArray[indexPath.row];
        if (item) {
            item.isScheduleMore = NO;
            BOOL isAcceptView = NO;
            if (item.usersType == UsersType_Liver && item.scheduleType == ScheduleType_Pending) {
                isAcceptView = YES;
            }
            item.containerHeight = [LSScheduleInviteCell cellHeight:item.isScheduleMore isAcceptView:isAcceptView isMinimum:item.isMinimu];
            [self.msgTableView reloadData];
        }
    }
}

- (void)liveScheduleInviteCellShowDetalis:(LSScheduleInviteCell *)cell {
    NSIndexPath *indexPath = [self.msgTableView indexPathForCell:cell];
    @synchronized (self.msgShowArray) {
        MsgItem *item = self.msgShowArray[indexPath.row];
        if (item) {
            item.isScheduleMore = YES;
            BOOL isAcceptView = NO;
            if (item.usersType == UsersType_Liver && item.scheduleType == ScheduleType_Pending) {
                isAcceptView = YES;
            }
            item.containerHeight = [LSScheduleInviteCell cellHeight:item.isScheduleMore isAcceptView:isAcceptView isMinimum:item.isMinimu];
            [self.msgTableView reloadData];
        }
    }
}

- (void)liveScheduleInviteCellDidOpenScheduleList {
    NSURL * url = [[LiveUrlHandler shareInstance]createScheduleList:LiveUrlScheduleListTypePending];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (void)liveScheduleInviteCellDidLearnHowWorks {
    [self chatPrepaidViewDidHowWork];
}

- (void)liveScheduleInviteCellDidMinimum:(LSScheduleInviteCell *)cell isMinimum:(BOOL)isMinimum {
    NSIndexPath *indexPath = [self.msgTableView indexPathForCell:cell];
    @synchronized (self.msgShowArray) {
        MsgItem *item = self.msgShowArray[indexPath.row];
        if (item) {
            item.isMinimu = isMinimum;
            BOOL isAcceptView = NO;
            if (item.usersType == UsersType_Liver && item.scheduleType == ScheduleType_Pending) {
                isAcceptView = YES;
            }
            item.containerHeight = [LSScheduleInviteCell cellHeight:item.isScheduleMore isAcceptView:isAcceptView isMinimum:item.isMinimu];
            [self.msgTableView reloadData];
        }
    }
}

#pragma mark - LSScheduleStatusTipCellDelegate
- (void)pushScheduleInviteDetail:(MsgItem *)item {
    NSURL *url = [[LiveUrlHandler shareInstance] createScheduleDetail:item.scheduleMsg.privScheId anchorId:self.liveRoom.userId refId:self.liveRoom.roomId];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

#pragma mark - 双向视频
- (void)sendVideoControl:(BOOL)start {
    // TODO: 请求开启双向视频
    self.preActivityView.hidden = NO;
    [self.preActivityView startAnimating];
    
    BOOL bFlag = [self.liveManager sendVideoControl:start];
    if (!bFlag) {
        NSString *msg = start ? NSLocalizedStringFromSelf(@"OPEN_MAN_PUSH_ERROR") : NSLocalizedStringFromSelf(@"CLOSE_MAN_PUSH_ERROR");
        [self showManPushErrorView:msg retey:start];
    }
}

#pragma mark - LSLiveVCManagerDelegate
// TODO: 多人互动邀请回调
- (void)onRecvInvitationHangout:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg inviteId:(NSString *)inviteId recommendId:(NSString *)recommendId recommendAnchorId:(NSString *)recommendAnchorId recommendAnchorName:(NSString *)recommendAnchorName {
    
    if (errnum == HTTP_LCC_ERR_SUCCESS) {
        // 显示提示控件
        [self.liveManager addTips:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITING_HANG_OUT"), self.liveRoom.userName]];
        
        self.hangoutInviteId = inviteId;
        self.recommendAnchorId = recommendId.length > 0 ? recommendAnchorId : @"";
        self.recommendAnchorName = recommendId.length > 0 ? recommendAnchorName : @"";
        
    } else {
        self.isInvitingHangout = NO;
        
        self.isInviteHangout = NO;
        self.hangoutInviteId = nil;
        
        // 如果没钱
        if (errnum == HTTP_LCC_ERR_NO_CREDIT) {
            [self showAddCreditsView:NSLocalizedStringFromSelf(@"SEND_INVITE_NO_CREDIT")];
        }else {
            // 发送邀请失败提示
            [self.dialogProbationTip showDialogTip:self.liveRoom.superView tipText:errmsg];
        }
    }
}

// TODO: 获取多人互动邀请状态回调
- (void)onRecvGetHangoutInvitStatus:(BOOL)success status:(HangoutInviteStatus)status roomId:(NSString *)roomId {
    if (success) {
        switch (status) {
            case IMREPLYINVITETYPE_AGREE: {
                self.isInvitingHangout = YES;
                self.isInviteHangout = YES;
                [self.liveManager addTips:NSLocalizedStringFromSelf(@"INVITE_SUCCESS_HANGOUT")];
                if (roomId.length > 0) {
                    // 拼接push跳转多人互动url
                    self.pushUrl = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:roomId inviteAnchorId:self.liveRoom.userId inviteAnchorName:self.liveRoom.userName recommendAnchorId:self.recommendAnchorId recommendAnchorName:self.recommendAnchorName];
                }
            } break;
                
            case IMREPLYINVITETYPE_NOCREDIT: {
                self.isInvitingHangout = NO;
                [self showAddCreditsView:NSLocalizedString(@"INVITE_HANGOUT_ADDCREDIT", nil)];
            } break;
                
            default: {
                self.isInvitingHangout = NO;
                self.isInviteHangout = NO;
                self.hangoutInviteId = nil;
                
                NSString * name = self.liveRoom.userName;
                if (name.length > 8) {
                    name = [NSString stringWithFormat:@"%@...",[name substringWithRange:NSMakeRange(0, 3)]];
                }
                NSString *tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_REJECT_HANGOUT"), name];
                [self.liveManager addTips:tip];
            } break;
        }
    }
}

// TODO: 开启双向视频回调
- (void)onRecvManPush:(LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg isStart:(BOOL)isStart manPushUrls:(NSArray<NSString *> *)manPushUrls {
    // 隐藏菊花
    self.preActivityView.hidden = YES;
    if (errnum == LCC_ERR_SUCCESS) {
        BOOL bSuccess = NO;
        
        // 开启视频互动
        if (isStart) {
            if (manPushUrls.count > 0) {
                bSuccess = YES;
                // 开始推流
                self.liveRoom.publishUrlArray = manPushUrls;
            } else {
                // 发送关闭命令 显示错误弹框
                [self.imManager controlManPush:self.liveRoom.roomId control:IMCONTROLTYPE_CLOSE finishHandler:nil];
                [self showManPushErrorView:NSLocalizedStringFromSelf(@"OPEN_MAN_PUSH_ERROR") retey:YES];
            }
        }
        
        // 改变界面状态
        if (bSuccess) {
            // 开始推流
            [self publish];
        } else {
            // 停止推流 还原双向视频界面
            [self stopPublish];
            [self showManPushView:NO];
        }
    } else {
        NSString *errStr = isStart ? @"开启视频互动失败" : @"关闭视频互动失败";
        NSLog(@"LSVIPLiveViewController::sendVideoControl( %@, errType : %d )", errStr, errnum);
        if (isStart) {
            NSString *tip = errmsg.length > 0 ? errmsg : NSLocalizedStringFromSelf(@"OPEN_MAN_PUSH_ERROR");
            if (errnum == LCC_ERR_NO_CREDIT || errnum == LCC_ERR_NO_CREDIT_DOUBLE_VIDEO) {
                // 没钱, 弹出充值
                [self showAddCreditsView:NSLocalizedStringFromSelf(@"CAM_NO_CREDITS")];
                [self showManPushView:NO];
            } else {
                // 开启失败错误提示
                [self showManPushErrorView:tip retey:YES];
            }
        } else {
            // 关闭失败错误提示
            NSString *tip = errmsg.length > 0 ? errmsg : NSLocalizedStringFromSelf(@"CLOSE_MAN_PUSH_ERROR");
            [self showManPushErrorView:tip retey:NO];
        }
    }
}

// TODO: 接收观众座驾入场
- (void)onRecvAudienceRideIn:(AudienceModel *)model {
    [self.audienArray addObject:model];
    if (!self.isDriveShow) {
        self.isDriveShow = YES;
        [self showDriveView:model];
    }
}

// TODO: 接收直播间礼物
- (void)onRecvSendGiftItem:(GiftItem *)giftItem {
    if (giftItem.giftItem.infoItem.type == GIFTTYPE_COMMON) {
        // 连击礼物
        [self addCombo:giftItem];
    } else {
        // 礼物添加到队列
        if (!self.bigGiftArray && self.viewIsAppear) {
            self.bigGiftArray = [NSMutableArray array];
        }
        for (int i = 0; i < giftItem.giftnum; i++) {
            [self.bigGiftArray addObject:giftItem.giftid];
        }
        
        // 防止动画播完view没移除
        if (!self.giftAnimationView.isAnimating) {
            [self.giftAnimationView removeFromSuperview];
            self.giftAnimationView = nil;
        }
        
        if (!self.giftAnimationView) {
            // 显示大礼物动画
            if (self.bigGiftArray.count > 0) {
                [self starBigAnimationWithGiftID:self.bigGiftArray[0]];
            }
        }
    }
}

// TODO: 接收直播间弹幕弹幕
- (void)onRecvSendToastBarrage:(BarrageModel *)model {
    NSArray *items = [NSArray arrayWithObjects:model, nil];
    [self.barrageView insertBarrages:items immediatelyShow:YES];
}

// TODO: 接收消息列表消息
- (void)onRecvMessageListItem:(MsgItem *)msgItem {
    // 如果为警告则弹框
    if (msgItem.msgType == MsgType_Warning) {
        if (self.dialogView) {
            [self.dialogView removeFromSuperview];
        }
        self.dialogView = [DialogWarning dialogWarning];
        self.dialogView.tipsLabel.text = msgItem.text;
        
        if (self.viewIsAppear) {
            [self.dialogView showDialogWarning:self.navigationController.view actionBlock:nil];
        }
    }
    // 插入到消息列表
    [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
}

// TODO: 接收预付费消息
- (void)onRecvScheduleMessageItem:(MsgItem *)msgItem {
    if (msgItem.msgType == MsgType_Schedule && msgItem.scheduleType != ScheduleType_Pending) {
        @synchronized (self.msgShowArray) {
            for (MsgItem *item in [[self.msgShowArray reverseObjectEnumerator] allObjects]) {
                if ([item.scheduleMsg.privScheId isEqualToString:msgItem.scheduleMsg.privScheId]) {
                    item.scheduleType = msgItem.scheduleType;
                    item.scheduleMsg = msgItem.scheduleMsg;
                    [self.msgTableView reloadData];
                    break;
                }
            }
        }
        // 插入预付费状态更新消息
        [self.liveManager addScheduleInviteReplyMsg:msgItem];
    } else {
        // 插入到消息列表
        [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
    }
}

// TODO: 接收发送预付费直播邀请回调
- (void)onRecvSendScheduleInviteToAnchor:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg item:(LSSendScheduleInviteItemObject *)item {
    self.prepaidView.sendBtn.userInteractionEnabled = YES;
    switch (errnum) {
        case HTTP_LCC_ERR_SUCCESS:{
            [self.prepaidView removeFromSuperview];
            // 刷新列表数
            [self.liveManager getScheduleList];
            // 插入消息
            ImScheduleRoomInfoObject * msgItem = [self.paidManager getSendScheduleInviteMsg:item];
            [self.liveManager addScheduleInviteMsg:self.loginManager.loginItem.userId item:msgItem];
        }break;
            
        case HTTP_LCC_ERR_SCHEDULE_NO_CREDIT:{
            [self.purchaseCreditView setupCreditTipIsAccept:NO name:self.liveRoom.userName credit:self.creditRebateManager.mCredit];
            [self.purchaseCreditView showLSCreditViewInView:self.navigationController.view];
        }break;
        case HTTP_LCC_ERR_SCHEDULE_NOTENOUGH_OR_OVER_TIEM:{
            [[LSPrePaidManager manager] getDateData];
            [self.dialogProbationTip showDialogTip:self.navigationController.view tipText:errmsg];
        }
        break;
        default:{
            [self.dialogProbationTip showDialogTip:self.navigationController.view tipText:errmsg];
        }break;
    }
}

// TODO: 接收接受预付费邀请回调
- (void)onRecvSendAcceptScheduleToAnchor:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg statusUpdateTime:(NSInteger)statusUpdateTime scheduleInviteId:(NSString *)inviteId duration:(int)duration roomInfoItem:(ImScheduleRoomInfoObject *)roomInfoItem {
    [self.liveManager getScheduleList];
    switch (errnum) {
        case HTTP_LCC_ERR_SUCCESS:{
            [self updateScheduleStatusTime:statusUpdateTime scheduleInviteId:inviteId duration:duration status:IMSCHEDULESENDSTATUS_CONFIRMED roomInfoItem:roomInfoItem];
        }break;
        // 已接受
        case HTTP_LCC_ERR_SCHEDULE_HAS_ACCEPTED:{
            [self.dialogProbationTip showDialogTip:self.liveRoom.superView tipText:errmsg];
            [self updateScheduleStatusTime:statusUpdateTime scheduleInviteId:inviteId duration:duration status:IMSCHEDULESENDSTATUS_CONFIRMED roomInfoItem:roomInfoItem];
        }break;
        // 已拒绝
        case HTTP_LCC_ERR_SCHEDULE_HAS_DECLINED:{
            [self.dialogProbationTip showDialogTip:self.liveRoom.superView tipText:errmsg];
            [self updateScheduleStatusTime:statusUpdateTime scheduleInviteId:inviteId duration:duration status:IMSCHEDULESENDSTATUSE_DECLINED roomInfoItem:roomInfoItem];
        }break;
        // 没信用点
        case HTTP_LCC_ERR_SCHEDULE_NO_CREDIT:{
            [self.purchaseCreditView setupCreditTipIsAccept:YES name:self.liveRoom.userName credit:self.creditRebateManager.mCredit];
            [self.purchaseCreditView showLSCreditViewInView:self.navigationController.view];
            [self.msgTableView reloadData];
        }break;
            
        default:{
            [self.dialogProbationTip showDialogTip:self.liveRoom.superView tipText:errmsg];
            [self.msgTableView reloadData];
        }break;
    }
}

// TODO: 接收女士发送预付费消息通知
- (void)onRecvAnchorSendScheduleToMeNotice:(ImScheduleRoomInfoObject *)item {
    self.scheduleBtnView.hidden = NO;
    [self.liveManager getScheduleList];
    // 插入或更新预付费消息
    [self.liveManager addAncherSendScheduleMsg:item];
    if (item.msg.status == IMSCHEDULESENDSTATUS_PENDING && self.prepaidTipViewBgBtn.isHidden) {
        [self scheduleBtnAnimaiton:YES];
    }
}

// TODO: 接收该直播预付费邀请列表数
- (void)onRecvGetScheduleList:(BOOL)success maxCount:(NSInteger)maxCount confirms:(NSInteger)confirms pendings:(NSInteger)pendings {
    if (success) {
        self.scheduleCount = maxCount;
        if (maxCount > 0) {
            self.scheduleNumLabel.hidden = NO;
            if (maxCount > 99) {
                self.scheduleNumLabel.text = [NSString stringWithFormat:@"..."];
            } else {
                self.scheduleNumLabel.text = [NSString stringWithFormat:@"%ld",(long)maxCount];
            }
            
        } else {
            self.scheduleNumLabel.hidden = YES;
        }
        // 改变预付费数量界面高度
        [self.prepaidTipView updateCount:confirms pcount:pendings];
        CGFloat viewH = 0;
        if (confirms > 0 && pendings > 0) {
            viewH = 335;
            self.prepaidTipView.confirmViewHeight.constant = 34;
            self.prepaidTipView.pendingViewHeight.constant = 34;
        } else if (confirms > 0 && pendings <= 0){
            viewH = 301;
            self.prepaidTipView.confirmViewHeight.constant = 34;
            self.prepaidTipView.pendingViewHeight.constant = 0;
        }else if (confirms <= 0 && pendings > 0){
            viewH = 301;
            self.prepaidTipView.confirmViewHeight.constant = 0;
            self.prepaidTipView.pendingViewHeight.constant = 34;
        } else {
            if (!self.prepaidTipView.isHidden) {
                viewH = 267;
                self.prepaidTipView.confirmViewHeight.constant = 0;
                self.prepaidTipView.pendingViewHeight.constant = 0;
            }
        }
        [self.prepaidTipView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(viewH));
        }];
    }
}

- (void)onRecvScheduleGetDateData {
     [self.prepaidView.deteView updateNewBeginTime];
}
// TODO: 接收获取男士/主播信息通知
- (void)onRecvUserOrAnchorInfo:(LSUserInfoModel *)item {
    if (item.isAnchor) {
        if (item.anchorInfo.anchorPriv.scheduleOneOnOneRecvPriv) {
            if (self.camBtnHeight.constant) {
                self.scheduleBtnViewBottom.constant = 5;
            } else {
                self.scheduleBtnViewBottom.constant = 0;
            }
            self.scheduleBtnView.hidden = NO;
        }
    } else {
        
    }
}

#pragma mark - IM通知
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"LSVIPLiveViewController::onLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    
    if (errType == LCC_ERR_SUCCESS) {
        // 重新进入直播间
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.liveRoom.roomId.length) {
                // 获取Hangout邀请回复状态
                [self.liveManager getHangoutInviteStatu:self.hangoutInviteId];
                
                [self.imManager enterRoom:self.liveRoom.roomId
                            finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString * errMsg, ImLiveRoomObject * roomItem, ImAuthorityItemObject * priv) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.liveRoom.priv = priv;
                                    if (success) {
                                        NSLog(@"LSVIPLiveViewController::onLogin( [IM登陆, 成功, 重新进入直播间], roomId : %@ isHasOneOnOneAuth :%d, isHasBookingAuth : %d)", self.liveRoom.roomId, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
                                        // 更新直播间信息
                                        [self.liveRoom reset];
                                        self.liveRoom.imLiveRoom = roomItem;
                                        
                                        // 重新推流
                                        [self stopPlay];
                                        [self play];
                                        
                                        // 刷新双向视频状态
                                        [self reloadVideoStatus];
                                        
                                        if ([self.liveDelegate respondsToSelector:@selector(onReEnterRoom:)]) {
                                            [self.liveDelegate onReEnterRoom:self];
                                        }
                                        
                                        // 设置余额及返点信息管理器
                                        IMRebateItem *imRebateItem = [[IMRebateItem alloc] init];
                                        imRebateItem.curCredit = roomItem.rebateInfo.curCredit;
                                        imRebateItem.curTime = roomItem.rebateInfo.curTime;
                                        imRebateItem.preCredit = roomItem.rebateInfo.preCredit;
                                        imRebateItem.preTime = roomItem.rebateInfo.preTime;
                                        [self.creditRebateManager setReBateItem:imRebateItem];
                                        [self.creditRebateManager setCredit:roomItem.credit];
                                        
                                    } else {
                                        NSLog(@"LSVIPLiveViewController::onLogin( [IM登陆, 成功, 但直播间已经关闭], roomId : %@ )", self.liveRoom.roomId);
                                        [[LSMinLiveManager manager]minLiveViewDidCloseBtn];
                                        // 如果是正在邀请Hangout状态 跳转Hangout直播间
                                        if (self.isInviteHangout) {
                                            [self stopPlay];
                                            [self stopPublish];
                                            
                                            LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
                                            [nvc forceToDismissAnimated:NO completion:nil];
                                            [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];
                                            
                                            [[LiveUrlHandler shareInstance] handleOpenURL:self.pushUrl];
                                        } else {
                                            if (errType != LCC_ERR_CONNECTFAIL) {
                                                // 停止推拉流、结束直播
                                                [self stopLiveWithErrtype:LCC_ERR_NOT_FOUND_ROOM errMsg:NSLocalizedStringFromSelf(@"LIVE_NOT_ROOM")];
                                            }
                                        }
                                    }
                                });
                            }];
            } else {
                // 停止推拉流、结束直播
                [self stopLiveWithErrtype:LCC_ERR_NOT_FOUND_ROOM errMsg:NSLocalizedStringFromSelf(@"LIVE_NOT_ROOM")];
            }
        });
    }
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LSVIPLiveViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@, playerReconnectTime : %lu, publisherReconnectTime : %lu )", errType, errmsg, (unsigned long)self.playerReconnectTime, (unsigned long)self.publisherReconnectTime);
    
    @synchronized(self) {
        // IM断开, 重置RTMP断开次数
        self.playerReconnectTime = 0;
        self.publisherReconnectTime = 0;
    }
}

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LSVIPLiveViewController::onSendGift( [发送直播间礼物消息], errmsg : %@, credit : %f, rebateCredit : %f )", errmsg, credit, rebateCredit);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            if (credit >= 0) {
                
                // 设置余额及返点信息管理器
                [self.creditRebateManager setCredit:credit];
            }
            [self.creditRebateManager updateRebateCredit:rebateCredit];
            
        } else if (errType == LCC_ERR_NO_CREDIT) {
            [self showAddCreditsView:NSLocalizedStringFromSelf(@"SENDTOSAT_ERR_ADD_CREDIT")];
        }
    });
}


- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LSVIPLiveViewController::onSendToast( [发送直播间弹幕消息, %@], errmsg : %@, credit : %f, rebateCredit : %f )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errmsg, credit, rebateCredit);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            if (credit >= 0) {
                // 设置余额及返点信息管理器
                [self.creditRebateManager setCredit:credit];
            }
            [self.creditRebateManager updateRebateCredit:rebateCredit];
            
        } else if (errType == LCC_ERR_NO_CREDIT) {
            [self showAddCreditsView:NSLocalizedStringFromSelf(@"POPUP_MESSAGE_ADD_CREDIT")];
        }
    });
}

- (void)onRecvRoomKickoffNotice:(NSString *)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *)errmsg credit:(double)credit priv:(ImAuthorityItemObject *)priv {
    NSLog(@"LSVIPLiveViewController::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ credit:%f, isHasOneOnOneAuth :%d, isHasBookingAuth : %d", roomId, credit, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.liveRoom.priv = priv;
            // 发送退出直播间
            [self.imManager leaveRoom:self.liveRoom];
            
            // 设置余额及返点信息管理器
            if (credit >= 0) {
                [self.creditRebateManager setCredit:credit];
            }
            
            LCC_ERR_TYPE type;
            if (errType == LCC_ERR_NO_CREDIT || errType == LCC_ERR_COUPON_FAIL) {
                type = errType;
            } else {
                type = LCC_ERR_ROOM_LIVEKICKOFF;
            }
            // 停止推拉流、显示结束直播间界面
            [self stopLiveWithErrtype:type errMsg:errmsg];
        }
    });
}

- (void)onRecvLackOfCreditNotice:(NSString *)roomId msg:(NSString *)msg credit:(double)credit errType:(LCC_ERR_TYPE)errType {
    NSLog(@"LSVIPLiveViewController::onRecvLackOfCreditNotice( [接收充值通知], roomId : %@ credit:%f errType:%d", roomId, credit, errType);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 设置余额及返点信息管理器
        if (credit >= 0) {
            [self.creditRebateManager setCredit:credit];
        }
        
        [self showAddCreditsView:NSLocalizedStringFromSelf(@"WATCHING_WILL_NO_MONEY")];
        
        if (errType == LCC_ERR_NO_CREDIT_DOUBLE_VIDEO_NOTICE) {
            [self sendVideoControl:NO];
        }
    });
}

- (void)onRecvCreditNotice:(NSString *)roomId credit:(double)credit {
    NSLog(@"LSVIPLiveViewController::onRecvCreditNotice( [接收定时扣费通知], roomId : %@, credit : %f ）", roomId, credit);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 设置余额及返点信息管理器
        if (credit >= 0) {
            [self.creditRebateManager setCredit:credit];
        }
    });
}

- (void)onRecvSendTalentNotice:(ImTalentReplyObject *)item {
    NSLog(@"LSVIPLiveViewController::onRecvSendTalentNotice( [接收直播间才艺点播回复通知], roomId : %@ )", item.roomId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (item.status == TALENTSTATUS_AGREE && item.credit >= 0) {
           
            [self starBigAnimationWithGiftID:item.giftId];
        }
    });
}

- (void)onRecvTalentPromptNotice:(NSString *)roomId introduction:(NSString *)introduction {
    NSLog(@"LSVIPLiveViewController::onRecvTalentPromptNotice( [接收直播间才艺点播提示公告通知], roomId : %@, introduction : %@ )", roomId, introduction);
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        if ([self.liveRoom.roomId isEqualToString:roomId]) {
    //            MsgItem *msgItem = [[MsgItem alloc] init];
    //            msgItem.msgType = MsgType_Talent;
    //            msgItem.honorUrl = self.liveRoom.photoUrl;
    //            msgItem.toName = self.liveRoom.userName;
    //            msgItem.text = introduction;
    //            [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
    //        }
    //    });
}

- (void)onRecvRoomCloseNotice:(NSString *)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg priv:(ImAuthorityItemObject *)priv {
    NSLog(@"LSVIPLiveViewController::onRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@, isHasOneOnOneAuth : %d, isHasOneOnOneAuth: %d )", roomId, errType, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.liveRoom.roomId) {
            if ([self.liveRoom.roomId isEqualToString:roomId]) {
                self.liveRoom.priv = priv;
                // 是否邀请Hangout
                if (self.isInviteHangout) {
                    [self stopPlay];
                    [self stopPublish];
                    
                    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
                    [nvc forceToDismissAnimated:NO completion:nil];
                    [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];
                    
                    [[LiveUrlHandler shareInstance] handleOpenURL:self.pushUrl];
                    
                } else {
                    // 停止流、显示结束直播页
                    [self stopLiveWithErrtype:errType errMsg:errmsg];
                }
            }
        }
    });
}

- (void)onRecvChangeVideoUrl:(NSString *)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString *> *)playUrl userId:(NSString *)userId {
    NSLog(@"LSVIPLiveViewController::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@ userId : %@ )", roomId, playUrl, userId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            // 更新流地址
            [self.liveRoom reset];
            self.liveRoom.playUrlArray = [playUrl copy];
            
            [self stopPlay];
            [self play];
        }
    });
}

- (void)onRecvDealInviteHangoutNotice:(IMRecvDealInviteItemObject *)item {
    NSLog(@"LSVIPLiveViewController::onRecvDealInviteHangoutNotice( [接收主播回复观众多人互动邀请通知] invteId : %@, roomId : %@,"
          "anchorId : %@, type : %d, anchorId : %@ )",
          item.inviteId, item.roomId, item.anchorId, item.type, item.anchorId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (item.type) {
            case IMREPLYINVITETYPE_AGREE: {
                self.isInvitingHangout = YES;
                self.isInviteHangout = YES;
                [self.liveManager addTips:NSLocalizedStringFromSelf(@"INVITE_SUCCESS_HANGOUT")];
                // 拼接push跳转多人互动url
                self.pushUrl = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:item.roomId inviteAnchorId:self.liveRoom.userId inviteAnchorName:self.liveRoom.userName recommendAnchorId:self.recommendAnchorId recommendAnchorName:self.recommendAnchorName];
                
            } break;
                
            case IMREPLYINVITETYPE_NOCREDIT: {
                self.isInvitingHangout = NO;
                [self showAddCreditsView:NSLocalizedString(@"INVITE_HANGOUT_ADDCREDIT", nil)];
            } break;
                
            default: {
                self.isInvitingHangout = NO;
                self.isInviteHangout = NO;
                self.hangoutInviteId = nil;
                
                NSString * name = item.nickName;
                if (name.length > 8) {
                    name = [NSString stringWithFormat:@"%@...",[name substringWithRange:NSMakeRange(0, 3)]];
                }
                NSString *tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_REJECT_HANGOUT"), name];
                [self.liveManager addTips:tip];
            } break;
        }
    });
}

#pragma mark - 倒数控制
- (void)setupPreviewView {
    // 计算StatusBar高度
    if (IS_IPHONE_X) {
        self.liveHeadDistance.constant = 44;
//        self.videoTopDIstance.constant = 44;
    } else {
        self.liveHeadDistance.constant = 0;
//        self.videoTopDIstance.constant = 0;
    }
    // 初始化预览界面
    self.previewView.hidden = YES;
}

- (void)videoBtnCountDown {
    @synchronized(self) {
        self.videoBtnLeftSecond--;
        if (self.videoBtnLeftSecond == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 隐藏视频静音和推送按钮
               self.stopVideoBtn.hidden = YES;
//                self.muteBtn.hidden = YES;
                self.showBtn.hidden = NO;
            });
        }
    }
}

- (void)startVideoBtnTimer {
    NSLog(@"LSVIPLiveViewController::startVideoBtnTimer()");
    WeakObject(self, weakSelf);
    [self.videoBtnTimer startTimer:nil
                      timeInterval:1.0 * NSEC_PER_SEC
                           starNow:YES
                            action:^{
                                [weakSelf videoBtnCountDown];
                            }];
}

- (void)stopVideoBtnTimer {
    NSLog(@"LSVIPLiveViewController::stopVideoBtnTimer()");
    
    [self.videoBtnTimer stopTimer];
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
                NSLog(@"LSVIPLiveViewController::willEnterForeground ( [接收后台关闭直播间]  IsTimeOut : %@ )", (self.isTimeOut == YES) ? @"Yes" : @"No");
                // 弹出直播间关闭界面
                [self showLiveFinshViewWithErrtype:LCC_ERR_BACKGROUND_TIMEOUT errMsg:NSLocalizedStringFromErrorCode(@"LIVE_ROOM_BACKGROUND_TIMEOUT")];
            }
        }
    }
}

#pragma mark - LiveGobalManagerDelegate
- (void)enterBackgroundTimeOut:(NSDate *)time {
    self.isTimeOut = YES;
    
    if (self.liveRoom.roomId.length > 0) {
        // 发送IM退出直播间命令
        [[LSImManager manager] leaveRoom:self.liveRoom];
    }
    
    if (self.player) {
        // 停止播放器
        [self.player stop];
    }
    if (self.publisher) {
        // 停止推流器
        [self.publisher stop];
    }
}

// 显示直播结束界面
- (void)showLiveFinshViewWithErrtype:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    if ([self.liveDelegate respondsToSelector:@selector(closeAllInputView:)]) {
        [self.liveDelegate closeAllInputView:self];
    }
    
    if (self.liveRoom.superView) {
        LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
        finshController.liveRoom = self.liveRoom;
        finshController.errType = errType;
        finshController.errMsg = errMsg;
        
        [self.liveRoom.superController addChildViewController:finshController];
        [self.liveRoom.superView addSubview:finshController.view];
        [finshController.view bringSubviewToFront:self.liveRoom.superView];
        [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.liveRoom.superView);
        }];
    }
    
    if (self.liveRoom.roomId.length > 0) {
        // 发送退出直播间
        NSLog(@"LSVIPLiveViewController::showLiveFinshView( [发送退出直播间], roomId : %@ )", self.liveRoom.roomId);
        [self.imManager leaveRoom:self.liveRoom];
    }
    // 清空直播间信息
    self.liveRoom = nil;
    // 移除礼物通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftAnimationIsOver" object:nil];
    // 关闭所有自定义弹框
    [self removeAllCustonBox];
}

// 直播结束停止推拉流并显示结束页
- (void)stopLiveWithErrtype:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    if (self.liveRoom) {
        [[LSMinLiveManager manager]minLiveViewDidCloseBtn];
        // 直接结束关闭直播间内的弹层
        [self closeAllPresentView];
        
        // 停止流
        [self stopPlay];
        [self stopPublish];
        
        // 弹出直播间关闭界面
        [self showLiveFinshViewWithErrtype:errType errMsg:errMsg];
    }
}


- (void)closeAllPresentView {
//    self.creditView.hidden = YES;
    if (self.creditView) {
        [self.creditView removeShowCreditView];
    }

    if (self.dialogView) {
        // 移除警告dialog
        [self.dialogView hidenDialog];
    }
}

@end
