//
//  LSInvitedToViewController.m
//  livestream
//
//  Created by randy on 2017/10/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSInvitedToViewController.h"
#import "LiveModule.h"

#import "BookPrivateBroadcastViewController.h"
#import "LiveFinshViewController.h"

#import "PrivateViewController.h"
#import "LSAddCreditsViewController.h"

#import "LiveRoomCreditRebateManager.h"
#import "LiveGobalManager.h"
#import "LSImManager.h"
#import "LSSessionRequestManager.h"
#import "LSImageViewLoader.h"
#import "LSRoomUserInfoManager.h"
#import "LSStreamSpeedManager.h"

#import "AcceptInstanceInviteRequest.h"
#import "HandleBookingRequest.h"
#import "LSGetUserInfoRequest.h"
#import "QNChatViewController.h"
#import "LiveUrlHandler.h"
// 180秒后退出界面
#define INVITE_TIMEOUT 183
// 10秒后显示退出按钮
#define CANCEL_BUTTON_TIMEOUT 10
// 按钮高度
#define BUTTONHEIGHT 44
#define BOOKBTNTOP 15

typedef enum PreLiveStatus {
    PreLiveStatus_None = 0,
    PreLiveStatus_Inviting,
    PreLiveStatus_WaitingEnterRoom,
    PreLiveStatus_CountingDownForEnterRoom,
    PreLiveStatus_EnterRoomAlready,
    PreLiveStatus_Canceling,
    PreLiveStatus_Error,
} PreLiveStatus;

@interface LSInvitedToViewController () <IMManagerDelegate, IMLiveRoomManagerDelegate, LiveGobalManagerDelegate>

// 当前状态
@property (nonatomic, assign) PreLiveStatus status;

// 顶部提示文本
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

#pragma mark - 头像逻辑
@property (atomic, strong) LSImageViewLoader *imageViewLoader;
@property (atomic, strong) LSImageViewLoader *imageViewLoaderBg;

// IM管理器
@property (nonatomic, strong) LSImManager *imManager;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

#pragma mark - 总超时控制
// 总超时倒数
@property (strong) LSTimer *handleTimer;
// 总超时剩余时间
@property (nonatomic, assign) int exitLeftSecond;
// 显示退出按钮时间
@property (nonatomic, assign) int showExitBtnLeftSecond;
// 能否显示退出按钮
@property (nonatomic, assign) BOOL canShowExitButton;

#pragma mark - 倒数控制
// 开播前倒数
@property (strong) LSTimer *enterRoomTimer;
// 开播前倒数剩余时间
@property (nonatomic, assign) int enterRoomLeftSecond;

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

#pragma mark - 用户信息管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;
@property (nonatomic, strong) UIViewController *vc;

@property (nonatomic, assign) NSTimeInterval enterRoomTimeInterval;

//  是否进入直播间
@property (nonatomic, assign) BOOL isEnterRoom;

// 是否已退入后台超时
@property (nonatomic, assign) BOOL isTimeOut;

@property (nonatomic, assign) BOOL isOnline;
@end

@implementation LSInvitedToViewController
- (void)initCustomParam {
    [super initCustomParam];

    // 隐藏导航栏
    self.isShowNavBar = NO;
    // 禁止导航栏后退手势
    self.canPopWithGesture = NO;

    // 初始化管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    [[LiveGobalManager manager] addDelegate:self];

    self.sessionManager = [LSSessionRequestManager manager];

    self.imageViewLoader = [LSImageViewLoader loader];
    self.imageViewLoaderBg = [LSImageViewLoader loader];

    // 初始化余额及返点信息管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];

    self.roomUserInfoManager = [LSRoomUserInfoManager manager];

    // 注册前后台切换通知
    _isBackground = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    // 初始化计时器
    self.enterRoomTimer = [[LSTimer alloc] init];
    self.handleTimer = [[LSTimer alloc] init];

    // 初始化进入后台时间
    self.enterRoomTimeInterval = 0;

    // 初始化是否进入直播间
    self.isEnterRoom = NO;

    // 初始化是否超时
    self.isTimeOut = NO;

    self.isOnline = YES;
}

- (void)dealloc {
    NSLog(@"LSInvitedToViewController::dealloc()");

    // 停止计时
    [self stopAllTimer];

    [[LiveGobalManager manager] removeDelegate:self];

    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];

    // 注销前后台切换通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self reset];

    self.bookPrivateBtn.layer.cornerRadius = self.bookPrivateBtn.tx_height / 2;
    self.bookPrivateBtn.layer.masksToBounds = YES;

    self.vipStartPrivateBtn.layer.cornerRadius = self.vipStartPrivateBtn.tx_height / 2;
    self.vipStartPrivateBtn.layer.masksToBounds = YES;

    self.addCreditBtn.layer.cornerRadius = self.addCreditBtn.tx_height / 2;
    self.addCreditBtn.layer.masksToBounds = YES;

    self.retryBtn.layer.cornerRadius = self.retryBtn.tx_height / 2;
    self.retryBtn.layer.masksToBounds = YES;

    self.liverHeadImageView.layer.cornerRadius = self.liverHeadImageView.tx_height / 2;
    self.liverHeadImageView.layer.masksToBounds = YES;

    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i <= 7; i++) {
        [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"Prelive_Loading%d", i]]];
    }
    self.loadingView.animationImages = array;
    self.loadingView.animationDuration = 0.6;
    [self.loadingView startAnimating];

    // 刷新女士名称
    if (self.liveRoom.userName.length > 0) {
        [self setupLiverNameLabel];
    }

    // 刷新女士头像
    if (self.liveRoom.photoUrl.length > 0) {
        [self setupLiverHeadImageView];
    } else {
        // 请求并缓存主播信息
        [self.roomUserInfoManager getLiverInfo:self.liveRoom.userId
                                 finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         // 刷新女士头像
                                         self.liveRoom.photoUrl = item.photoUrl;
                                         [self setupLiverHeadImageView];

                                         // 刷新女士名字
                                         self.liveRoom.userName = item.nickName;
                                         [self setupLiverNameLabel];
                                     });
                                 }];
    }

    // 设置不允许显示立即邀请
    [[LiveGobalManager manager] setCanShowInvite:NO];
    // 清除浮窗
    [[LiveModule module].notificationVC.view removeFromSuperview];
    [[LiveModule module].notificationVC removeFromParentViewController];
}

- (void)setupLiverHeadImageView {
    [self.imageViewLoader loadImageFromCache:self.liverHeadImageView
                                     options:SDWebImageRefreshCached
                                    imageUrl:self.liveRoom.photoUrl
                            placeholderImage:LADYDEFAULTIMG
                               finishHandler:^(UIImage *image){
                               }];
}

- (void)setupLiverNameLabel {
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:self.liveRoom.userName
                                                                             attributes:@{
                                                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                                                                 NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0xffffff)
                                                                             }];

    NSMutableAttributedString *anchorId = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"(ID:%@)", self.liveRoom.userId]
                                                                                 attributes:@{
                                                                                     NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                                                     NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x999999)
                                                                                 }];
    [name appendAttributedString:anchorId];
    self.liverNameLabel.attributedText = name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    // 第一次进入
    if (!self.viewDidAppearEver) {
        // 开始计时
        [self startHandleTimer];
        // IM登录城成功才调用
        if ([LSImManager manager].isIMLogin) {
            // 同意立即私密邀请
            [self requestHandleBookWithInvited:self.inviteId];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 同意立即私密邀请
                [self requestHandleBookWithInvited:self.inviteId];
            });
        }
    }

    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 设置允许显示立即邀请
    [[LiveGobalManager manager] setCanShowInvite:YES];
}

// 重置参数
- (void)reset {
    // 180秒后退出界面
    self.exitLeftSecond = INVITE_TIMEOUT;
    // 10秒后显示退出按钮
    self.showExitBtnLeftSecond = CANCEL_BUTTON_TIMEOUT;
    // 能否显示退出按钮
    self.canShowExitButton = YES;
    // 标记当前状态
    self.status = PreLiveStatus_None;
    // 隐藏退出按钮
    self.closeButton.hidden = YES;
    // 显示菊花
    self.loadingView.hidden = NO;
    // 隐藏底部动画
    self.vipView.hidden = YES;

    self.tipLabel.text = @"";
    self.handleCountDownLabel.text = @"";

    self.vipStartPrivateBtn.hidden = YES;
    self.retryBtn.hidden = YES;
    self.addCreditBtn.hidden = YES;
    self.bookPrivateBtn.hidden = YES;
}

- (void)stopAllTimer {
    [self stopHandleTimer];
    [self stopEnterRoomTimer];
    self.closeButton.hidden = NO;
    self.handleCountDownLabel.text = @"";
}

#pragma mark - 倒数控制
- (void)enterRoomCountDown {
    self.enterRoomLeftSecond--;
    if (self.enterRoomLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 倒数完成, 停止计时器
            [self stopEnterRoomTimer];
            // 进入直播间
            [self enterRoom];
        });
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.enterRoomLeftSecond > 0) {
            NSMutableAttributedString *tip = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"PRELIVE_TIPS_BOARDCAST_ACCEPT")
                                                                                    attributes:@{
                                                                                        NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                                        NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0xffffff)
                                                                                    }];

            NSMutableAttributedString *second = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ds", self.enterRoomLeftSecond]
                                                                                       attributes:@{
                                                                                           NSFontAttributeName : [UIFont boldSystemFontOfSize:22],
                                                                                           NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0xff8500)
                                                                                       }];
            [tip appendAttributedString:second];
            self.tipLabel.attributedText = tip;
        }
    });
}

- (void)startEnterRoomTimer {
    NSLog(@"LSInvitedToViewController::startEnterRoomTimer()");
    self.loadingView.hidden = YES;

    WeakObject(self, weakSelf);
    [self.enterRoomTimer startTimer:nil
                       timeInterval:1.0 * NSEC_PER_SEC
                            starNow:YES
                             action:^{
                                 [weakSelf enterRoomCountDown];
                             }];
}

- (void)stopEnterRoomTimer {
    NSLog(@"LSInvitedToViewController::stopEnterRoomTimer()");

    [self.enterRoomTimer stopTimer];
}

#pragma mark - 总超时控制
- (void)handleCountDown {
    //    NSLog(@"PreLiveViewController::handleCountDown( enterRoomLeftSecond : %d )", self.exitLeftSecond);
    self.exitLeftSecond--;
    if (self.exitLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 倒数完成, 提示超时
            [self stopHandleTimer];
            [self handleError:LCC_ERR_LOCAL_TIMEOUT errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT") onlineStatus:IMCHATONLINESTATUS_ONLINE];
            // 允许显示退出按钮
            self.closeButton.hidden = NO;
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.exitLeftSecond > 0) {
            NSString *str = [NSString stringWithFormat:@"%d s", self.exitLeftSecond];
            self.handleCountDownLabel.text = DEBUG_STRING(str);
        }
    });

    self.showExitBtnLeftSecond--;
    if (self.showExitBtnLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 允许显示退出按钮
            if (self.canShowExitButton) {
                self.closeButton.hidden = NO;
            }
        });
    }
}

- (void)startHandleTimer {
    NSLog(@"LSInvitedToViewController::startHandleTimer()");

    WeakObject(self, weakSelf);
    [self.handleTimer startTimer:nil
                    timeInterval:1.0 * NSEC_PER_SEC
                         starNow:YES
                          action:^{
                              [weakSelf handleCountDown];
                          }];
}

- (void)stopHandleTimer {
    NSLog(@"LSInvitedToViewController::stopHandleTimer()");

    [self.handleTimer stopTimer];
}

#pragma mark - 观众处理立即私密邀请
- (void)requestHandleBookWithInvited:(NSString *)inviteId {
    AcceptInstanceInviteRequest *request = [[AcceptInstanceInviteRequest alloc] init];
    request.inviteId = inviteId;
    request.isConfirm = YES;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, AcceptInstanceInviteItemObject *_Nonnull item, LSHttpAuthorityItemObject *priv) {
        NSLog(@"LSInvitedToViewController::requestHandleBookWithInvited [观众处理立即私密邀请] success : %d, roomId : %@, roomType : %d, errnum : %d, errmsg : %@,isHasOneOnOneAuth %d, isHasBookingAuth :%d", success, item.roomId, item.roomType, errnum, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);

        dispatch_async(dispatch_get_main_queue(), ^{
            // 请求成功
            if (success) {

                self.liveRoom.roomId = item.roomId;
                if (item.roomType == HTTPROOMTYPE_FREEPUBLICLIVEROOM || item.roomType == HTTPROOMTYPE_COMMONPRIVATELIVEROOM) {
                    self.liveRoom.roomType = LiveRoomType_Public;
                } else if (item.roomType == HTTPROOMTYPE_CHARGEPUBLICLIVEROOM || item.roomType == HTTPROOMTYPE_LUXURYPRIVATELIVEROOM) {
                    self.liveRoom.roomType = LiveRoomType_Private;
                } else {
                }
                // 发起请求
                [self startRequest];

            } else {
                ImAuthorityItemObject *obj = [[ImAuthorityItemObject alloc] init];
                obj.isHasBookingAuth = priv.isHasBookingAuth;
                obj.isHasOneOnOneAuth = priv.isHasOneOnOneAuth;
                self.liveRoom.priv = obj;

                if (errnum == HTTP_LCC_ERR_CONNECTFAIL || errnum == HTTP_LCC_ERR_ANCHOR_OFFLIVE) {
                    // 服务器连接失败、主播不在线
                    [self httpHandleError:errnum errMsg:errmsg onlineStatus:IMCHATONLINESTATUS_OFF];
                } else {
                    [self httpHandleError:errnum errMsg:errmsg onlineStatus:IMCHATONLINESTATUS_ONLINE];
                }
            }
        });

    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - 进入直播间
- (void)startRequest {
    BOOL bFlag = NO;
    NSLog(@"LSInvitedToViewController::startRequest( [请求进入指定直播间], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
    NSString *str = [NSString stringWithFormat:@"请求进入指定直播间(roomId : %@)...", self.liveRoom.roomId];
    self.statusLabel.text = DEBUG_STRING(str);

    // TODO:发起进入指定直播间
    bFlag = [self.imManager enterRoom:self.liveRoom.roomId
                        finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem, ImAuthorityItemObject *_Nonnull priv) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"LSInvitedToViewController::startRequest( [请求进入指定直播间, %@], errnum : %d, errmsg : %@, roomId : %@, waitStart : %@  ,isHasOneOnOneAuth : %d, isHasBookingAuth :%d)", BOOL2SUCCESS(success), errType, errMsg, self.liveRoom.roomId, BOOL2YES(roomItem.waitStart), priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
                                self.liveRoom.priv = priv;
                                [self handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
                            });
                        }];
    if (!bFlag) {
        NSLog(@"LSInvitedToViewController::startRequest( [请求进入指定直播间失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
        [self handleError:LCC_ERR_CONNECTFAIL errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT") onlineStatus:IMCHATONLINESTATUS_ONLINE];
    }
}

#pragma mark - 界面事件
- (void)handleEnterRoom:(BOOL)success errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg roomItem:(ImLiveRoomObject *)roomItem {
    // TODO:处理进入直播间
    if (self.exitLeftSecond > 0) {
        // 未超时
        if (self.status != PreLiveStatus_Error) {
            if (success) {
                // 请求进入成功
                // 上传测速结果
                [[LSStreamSpeedManager manager] requestSpeedResult:roomItem.roomId];

                // 更新本地登录信息
                [LSLoginManager manager].loginItem.level = roomItem.manLevel;
                self.liveRoom.imLiveRoom = roomItem;
                if (roomItem.photoUrl.length > 0) {
                    self.liveRoom.photoUrl = roomItem.photoUrl;
                }

                // 更新并缓存主播信息
                LSUserInfoModel *item = [[LSUserInfoModel alloc] init];
                item.userId = roomItem.userId;
                item.nickName = roomItem.nickName;
                item.photoUrl = roomItem.photoUrl;
                [self.roomUserInfoManager setLiverInfoDic:item];

                // 进入成功不能显示退出按钮
                self.closeButton.hidden = YES;
                self.canShowExitButton = NO;

                if (roomItem.waitStart) {
                    // 等待主播进入
                    self.statusLabel.text = DEBUG_STRING(@"等待主播进入直播间...");
                    self.status = PreLiveStatus_WaitingEnterRoom;
                    self.tipLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_INVITE_SUCCESS");
                } else {
                    self.statusLabel.text = DEBUG_STRING(@"进入直播间成功, 准备跳转...");
                    if (roomItem.leftSeconds > 0) {
                        self.tipLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_BOARDCAST_ACCEPT");
                        // 停止180s倒数
                        [self stopHandleTimer];
                        // 更新流地址
                        [self.liveRoom reset];
                        self.liveRoom.playUrlArray = [roomItem.videoUrls copy];
                        // 更新倒数时间
                        self.enterRoomLeftSecond = roomItem.leftSeconds;
                        if (self.enterRoomLeftSecond > 0) {
                            self.status = PreLiveStatus_CountingDownForEnterRoom;
                            // 开始倒数
                            [self stopEnterRoomTimer];
                            [self startEnterRoomTimer];

                            // 底部动画 产品需求暂时注释
                            /*
                            self.vipView.hidden = NO;
                            NSMutableArray *array = [NSMutableArray array];
                            for (int i = 1; i <= 12; i++) {
                                [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"TalentIcon%d", i]]];
                            }
                            for (int i = 1; i <= 6; i++) {
                                [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"TalentIcon%d", 12]]];
                            }
                            self.talentIcon.animationImages = array;
                            self.talentIcon.animationDuration = 0.9;
                            [self.talentIcon startAnimating];
                             */
                        }
                    } else {
                        // 马上进入直播间
                        [self enterRoom];
                    }
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
                // 请求进入失败, 进行错误处理
                self.statusLabel.text = DEBUG_STRING(@"进入直播间失败");
                [self handleError:errType errMsg:errMsg onlineStatus:IMCHATONLINESTATUS_ONLINE];
            }
        }
    }
}

- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg onlineStatus:(IMChatOnlineStatus)onlineStatus {
    // 改变状态为出错
    [self stopAllTimer];

    self.status = PreLiveStatus_Error;
    if (errMsg.length == 0) {
        errMsg = NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP");
    }
    self.isOnline = onlineStatus == IMCHATONLINESTATUS_ONLINE ? YES : NO;
    self.loadingView.hidden = YES;
    self.vipView.hidden = YES;
    [self.tipLabel setText:errMsg];

    if (errType != LCC_ERR_CONNECTFAIL && errType != LCC_ERR_INVITE_NO_RESPOND) {
        self.inviteId = nil;
    }

    switch (errType) {
        case LCC_ERR_NO_CREDIT: {
            self.vipStartPrivateBtn.hidden = YES;
            self.retryBtn.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.addCreditBtn.hidden = NO;
        } break;

        case LCC_ERR_CONNECTFAIL: {
            self.vipStartPrivateBtn.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
            self.retryBtn.hidden = NO;
        } break;

        case LCC_ERR_HANGOUT_EXIST_COUNTDOWN_PRIVITEROOM:
        case LCC_ERR_HANGOUT_EXIST_COUNTDOWN_HANGOUTROOM:
        case LCC_ERR_HANGOUT_EXIST_FOUR_MIN_SHOW:
        case LCC_ERR_KNOCK_EXIST_ROOM:
        case LCC_ERR_INVITE_FAIL_SHOWING:
        case LCC_ERR_INVITE_FAIL_BUSY:
        case LCC_ERR_SEND_RECOMMEND_HAS_SHOWING:
        case LCC_ERR_SEND_RECOMMEND_EXIT_HANGOUTROOM:
        case LCC_ERR_ANCHOR_OFFLINE: {
            [self showBookOneOnOne];
            self.vipStartPrivateBtn.hidden = YES;
            self.retryBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
        } break;

        default: {
            self.vipStartPrivateBtn.hidden = YES;
            self.retryBtn.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
        } break;
    }
}

- (void)httpHandleError:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg onlineStatus:(IMChatOnlineStatus)onlineStatus {
    // 改变状态为出错
    [self stopAllTimer];

    self.status = PreLiveStatus_Error;
    if (errMsg.length == 0) {
        errMsg = NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP");
    }
    self.isOnline = onlineStatus == IMCHATONLINESTATUS_ONLINE ? YES : NO;
    self.loadingView.hidden = YES;
    self.vipView.hidden = YES;
    [self.tipLabel setText:errMsg];

    if (errType != HTTP_LCC_ERR_CONNECTFAIL) {
        self.inviteId = nil;
    }

    self.vipStartPrivateBtnHeight.constant = BUTTONHEIGHT;
    self.bookPrivateBtnTop.constant = BOOKBTNTOP;

    switch (errType) {
        case HTTP_LCC_ERR_CONNECTFAIL: {
            // 服务器连接失败 (显示retry)
            self.vipStartPrivateBtn.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
            self.retryBtn.hidden = NO;
        } break;

        case HTTP_LCC_ERR_NO_CREDIT: {
            // 没信用点 (显示add credit)
            self.vipStartPrivateBtn.hidden = YES;
            self.retryBtn.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.addCreditBtn.hidden = NO;
        } break;

        case HTTP_LCC_ERR_ANCHOR_BUSY:
        case HTTP_LCC_ERR_ANCHOR_OFFLIVE: {
            // 主播繁忙、主播已离线 (显示book)
            [self showBookOneOnOne];
            self.vipStartPrivateBtn.hidden = YES;
            self.retryBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
        } break;

        case HTTP_LCC_ERR_INVITATION_HAS_EXPIRED:
        case HTTP_LCC_ERR_INVITATION_HAS_CANCELED: {
            // 主播邀请已过期、主播已取消邀请 (显示invite book)
            [self showBookOneOnOne];
            [self showStartOneOnOne];
            self.retryBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
        } break;

        default: {
            // 统一处理 不显示按钮
            self.vipStartPrivateBtn.hidden = YES;
            self.retryBtn.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
        } break;
    }
}

- (void)showStartOneOnOne {
    if (self.isOnline && self.liveRoom.priv.isHasOneOnOneAuth) {
        self.vipStartPrivateBtnHeight.constant = BUTTONHEIGHT;
        self.bookPrivateBtnTop.constant = BOOKBTNTOP;
        self.vipStartPrivateBtn.hidden = NO;
    } else {
        self.vipStartPrivateBtn.hidden = YES;
    }
}

- (void)showBookOneOnOne {
    // 关闭预约,隐藏按钮
    self.vipStartPrivateBtnHeight.constant = BUTTONHEIGHT;
    self.bookPrivateBtnTop.constant = BOOKBTNTOP;
    self.bookPrivateBtn.hidden = YES;

    //    if (self.liveRoom.priv.isHasBookingAuth) {
    //        self.vipStartPrivateBtnHeight.constant = 0;
    //        self.bookPrivateBtnTop.constant = 0;
    //        self.bookPrivateBtn.hidden = NO;
    //    } else {
    //        self.vipStartPrivateBtnHeight.constant = BUTTONHEIGHT;
    //        self.bookPrivateBtnTop.constant = BOOKBTNTOP;
    //        self.bookPrivateBtn.hidden = YES;
    //    }
}

- (void)enterRoom {
    self.status = PreLiveStatus_EnterRoomAlready;
    // 如果在后台记录进入时间
    if (self.isBackground) {
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
        [LiveGobalManager manager].liveRoom = self.liveRoom;
    } else {
        if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_COMMONPRIVATELIVEROOM || self.liveRoom.imLiveRoom.roomType == ROOMTYPE_LUXURYPRIVATELIVEROOM) {
            // 豪华私密直播间
            self.liveRoom.roomType = LiveRoomType_Private;
            [self enterPrivateVipRoom];

        } else {
            [self handleError:LCC_ERR_FAIL errMsg:NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP") onlineStatus:IMCHATONLINESTATUS_ONLINE];
        }
    }
}

- (void)enterPrivateVipRoom {
    // TODO:进入豪华私密直播间界面
    self.isEnterRoom = YES;
    PrivateViewController *vc = [[PrivateViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    self.vc = vc;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 直播间IM通知
- (void)onRecvWaitStartOverNotice:(ImStartOverRoomObject *_Nonnull)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSInvitedToViewController::onRecvWaitStartOverNotice( [直播间开播通知], roomId : %@, waitStart : %@, leftSeconds : %d )", item.roomId, BOOL2YES(self.liveRoom.imLiveRoom.waitStart), item.leftSeconds);
        // 没有进入直播间才处理
        if (self.exitLeftSecond > 0) {
            // 当前直播间通知, 并且是需要等待主播进入的
            if ([item.roomId isEqualToString:self.liveRoom.roomId] && self.liveRoom.imLiveRoom.waitStart) {
                // 等待进入房间中才处理
                if (self.status == PreLiveStatus_WaitingEnterRoom) {
                    self.statusLabel.text = DEBUG_STRING(@"主播已经进入直播间, 开始倒数...");

                    // 停止180s倒数
                    [self stopHandleTimer];

                    // 更新流地址
                    [self.liveRoom reset];
                    self.liveRoom.playUrlArray = [item.playUrl copy];

                    // 更新倒数时间
                    self.enterRoomLeftSecond = item.leftSeconds;

                    // 不能显示退出按钮
                    self.canShowExitButton = NO;
                    self.closeButton.hidden = YES;

                    if (self.enterRoomLeftSecond > 0) {
                        self.status = PreLiveStatus_CountingDownForEnterRoom;
                        // 开始倒数
                        [self stopEnterRoomTimer];
                        [self startEnterRoomTimer];

                        // 底部动画 产品需求暂时注释
                        /*
                        self.vipView.hidden = NO;
                        NSMutableArray *array = [NSMutableArray array];
                        for (int i = 1; i <= 12; i++) {
                            [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"TalentIcon%d", i]]];
                        }
                        for (int i = 1; i <= 6; i++) {
                            [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"TalentIcon%d", 12]]];
                        }
                        self.talentIcon.animationImages = array;
                        self.talentIcon.animationDuration = 0.9;
                        [self.talentIcon startAnimating];
                        */
                    } else {
                        // 马上进入直播间
                        [self enterRoom];
                    }
                }
            }
        }
    });
}

- (void)onRecvChangeVideoUrl:(NSString *_Nonnull)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString *> *_Nonnull)playUrl userId:(NSString *_Nonnull)userId {
    NSLog(@"LSInvitedToViewController::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@ userId:%@)", roomId, playUrl, userId);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新流地址
        [self.liveRoom reset];
        self.liveRoom.playUrlArray = [playUrl copy];
    });
}

- (void)onRecvRoomCloseNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg priv:(ImAuthorityItemObject *_Nonnull)priv {
    NSLog(@"LSInvitedToViewController::onRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@, isHasOneOnOneAuth : %d, isHasOneOnOneAuth: %d )", roomId, errType, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.liveRoom.priv = priv;
            // 未进入房间并且未出现错误
            if (self.status != PreLiveStatus_EnterRoomAlready &&
                self.status != PreLiveStatus_Error) {
                // 处理错误
                [self handleError:LCC_ERR_DEFAULT errMsg:NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP") onlineStatus:IMCHATONLINESTATUS_ONLINE];

                // 弹出直播间关闭界面
                LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
                finshController.liveRoom = self.liveRoom;
                finshController.errType = errType;
                finshController.errMsg = errmsg;

                [self addChildViewController:finshController];
                [self.view addSubview:finshController.view];
                [finshController.view bringSubviewToFront:self.view];
                [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view);
                }];
            }
        }
    });
}

- (void)onRecvRoomKickoffNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *_Nonnull)errmsg credit:(double)credit priv:(ImAuthorityItemObject *_Nonnull)priv {
    NSLog(@"LSInvitedToViewController::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ credit:%f isHasBookingAuth: %d, isHasOneOnOneAuth : %d", roomId, credit, priv.isHasBookingAuth, priv.isHasOneOnOneAuth);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.liveRoom.priv = priv;
            if (self.status != PreLiveStatus_EnterRoomAlready &&
                self.status != PreLiveStatus_Error) {
                // 设置余额及返点信息管理器
                if (!(credit < 0)) {
                    [self.creditRebateManager setCredit:credit];
                }
                // 弹出直播间关闭界面
                LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
                finshController.liveRoom = self.liveRoom;
                finshController.errType = LCC_ERR_ROOM_LIVEKICKOFF;
                finshController.errMsg = errmsg;

                [self addChildViewController:finshController];
                [self.view addSubview:finshController.view];
                [finshController.view bringSubviewToFront:self.view];
                [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view);
                }];
            }
        }
    });
}

#pragma mark - 按钮事件
- (IBAction)retryAction:(id)sender {

    [self reset];

    self.status = PreLiveStatus_Inviting;
    // 开始计时
    [self stopHandleTimer];
    [self startHandleTimer];

    // 如果有roomid直接进直播间 没有则重新处理私密邀请
    if (self.liveRoom.roomId.length > 0) {
        [self startRequest];

    } else {
        if (self.inviteId) {
            [self requestHandleBookWithInvited:self.inviteId];
        }
    }
}

#pragma mark - 开始私密
- (IBAction)startVipPrivate:(id)sender {
    // 停止所有计时
    [self stopAllTimer];

    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" anchorName:self.liveRoom.userName anchorId:self.liveRoom.userId roomType:LiveRoomType_Private];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}

#pragma mark - 预约
- (IBAction)bookPrivateAction:(id)sender {

    // 跳转预约
    BookPrivateBroadcastViewController *vc = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    vc.userId = self.liveRoom.userId;
    vc.userName = self.liveRoom.userName;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 充值
- (IBAction)addCreditAction:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
    NSURL *url = [[LiveUrlHandler shareInstance] createBuyCredit];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    if (_isBackground == NO) {
        _isBackground = YES;

        // 如果已经进入直播间成功, 更新切换后台时间
        if (self.status == PreLiveStatus_EnterRoomAlready) {
            [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
            [LiveGobalManager manager].liveRoom = self.liveRoom;
        } else {
            [LiveGobalManager manager].enterRoomBackgroundTime = nil;
        }
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (_isBackground == YES) {
        _isBackground = NO;

        if (self.enterRoomTimeInterval < BACKGROUND_TIMEOUT && !self.enterRoomLeftSecond && self.status == PreLiveStatus_EnterRoomAlready && !self.isEnterRoom) {
            [self enterRoom];
        }

        if (self.isTimeOut) {
            // 退出直播间
            [self.navigationController popToRootViewControllerAnimated:NO];
            if (self.liveRoom) {
                NSLog(@"PreLiveViewController::willEnterForeground ( [接收后台关闭直播间]  IsTimeOut : %@ )", (self.isTimeOut == YES) ? @"Yes" : @"No");

                // 弹出直播间关闭界面
                LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
                finshController.liveRoom = self.liveRoom;
                finshController.errType = LCC_ERR_BACKGROUND_TIMEOUT;
                finshController.errMsg = NSLocalizedStringFromErrorCode(@"LIVE_ROOM_BACKGROUND_TIMEOUT");
                
                [self addChildViewController:finshController];
                [self.view addSubview:finshController.view];
                [finshController.view bringSubviewToFront:self.view];
                [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view);
                }];
                
                self.liveRoom = nil;
            }
        }
    }
}

#pragma mark - LiveGobalManagerDelegate
- (void)enterBackgroundTimeOut:(NSDate * _Nullable)time {
    NSDate* now = [NSDate date];
    if( [LiveGobalManager manager].enterRoomBackgroundTime ) {
        self.enterRoomTimeInterval = [now timeIntervalSinceDate:time];
    }
    
    if( self.status == PreLiveStatus_EnterRoomAlready ) {
        self.status = PreLiveStatus_Error;
        
        self.isTimeOut = YES;
        
        if (self.liveRoom.roomId.length > 0) {
            [self.imManager leaveRoom:self.liveRoom];
        }
    }
}

- (IBAction)closeAction:(id)sender {
    
    if (self.inviteId.length) {
        [self.imManager cancelPrivateLive:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull roomId) {
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }];
    }
    // 清空邀请
    self.inviteId = nil;
    
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:YES completion:nil];
}



@end
