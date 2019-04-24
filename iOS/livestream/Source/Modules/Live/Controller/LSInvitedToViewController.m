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
#import "PrivateVipViewController.h"
#import "LSAddCreditsViewController.h"

#import "LiveRoomCreditRebateManager.h"
#import "LiveGobalManager.h"
#import "LSImManager.h"
#import "LSSessionRequestManager.h"
#import "LSImageViewLoader.h"
#import "LSRoomUserInfoManager.h"

#import "AcceptInstanceInviteRequest.h"
#import "HandleBookingRequest.h"
#import "LSGetUserInfoRequest.h"
#import "QNChatViewController.h"
#import "LiveUrlHandler.h"
// 180秒后退出界面
#define INVITE_TIMEOUT 180
// 10秒后显示退出按钮
#define CANCEL_BUTTON_TIMEOUT 10

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

- (void)setupContainView {
    [super setupContainView];

    // 设置背景模糊
    //    [self setupBgImageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self reset];

    // 刷新女士名称
    if (self.liveRoom.userName.length > 0) {
        self.liverNameLabel.text = self.liveRoom.userName;
    }

    // 刷新背景
    if (self.liveRoom.roomPhotoUrl.length > 0) {
        [self.imageViewLoaderBg loadImageWithImageView:self.bgImageView options:0 imageUrl:self.liveRoom.photoUrl placeholderImage:nil finishHandler:nil];
    }

    // 刷新女士头像
    if (self.liveRoom.photoUrl.length > 0) {
        [self.imageViewLoader loadImageFromCache:self.liverHeadImageView
                                         options:SDWebImageRefreshCached
                                        imageUrl:self.liveRoom.photoUrl
                                placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]
                                   finishHandler:^(UIImage *image){
                                   }];
    } else {
        // 请求并缓存主播信息
        [self.roomUserInfoManager getUserInfo:self.liveRoom.userId
                                finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        // 刷新女士头像
                                        self.liveRoom.photoUrl = item.photoUrl;
                                        [self.imageViewLoader loadImageFromCache:self.liverHeadImageView
                                                                         options:SDWebImageRefreshCached
                                                                        imageUrl:self.liveRoom.photoUrl
                                                                placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]
                                                                   finishHandler:^(UIImage *image){
                                                                   }];
                                        // 刷新女士名字
                                        self.liveRoom.userName = item.nickName;
                                        self.liverNameLabel.text = item.nickName;
                                    });
                                }];
    }

    // 刷新女士头像 背景
    self.liverHeadImageView.layer.cornerRadius = 50;
    self.liverHeadImageView.layer.masksToBounds = YES;

    // 设置不允许显示立即邀请
    [[LiveGobalManager manager] setCanShowInvite:NO];
    // 清除浮窗
    [[LiveModule module].notificationVC.view removeFromSuperview];
    [[LiveModule module].notificationVC removeFromParentViewController];
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

- (void)setupBgImageView {
    // 设置模糊
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.bgImageView addSubview:visualView];

    [visualView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgImageView);
        make.left.equalTo(self.bgImageView);
        make.width.equalTo(self.bgImageView);
        make.height.equalTo(self.bgImageView);
    }];
}

// 观众处理立即私密邀请
- (void)requestHandleBookWithInvited:(NSString *)inviteId {
    AcceptInstanceInviteRequest *request = [[AcceptInstanceInviteRequest alloc] init];
    request.inviteId = inviteId;
    request.isConfirm = YES;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, AcceptInstanceInviteItemObject *_Nonnull item, LSHttpAuthorityItemObject *priv) {

        NSLog(@"LSInvitedToViewController::requestHandleBookWithInvited [观众处理立即私密邀请] success : %d, roomId : %@, roomType : %d, errmsg : %@,isHasOneOnOneAuth %d, isHasBookingAuth :%d", success, item.roomId, item.roomType, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);

        dispatch_async(dispatch_get_main_queue(), ^{
            // 请求成功
            if (success) {

                self.liveRoom.roomId = item.roomId;
                if (item.roomType == HTTPROOMTYPE_FREEPUBLICLIVEROOM) {

                    self.liveRoom.roomType = LiveRoomType_Public;

                } else if (item.roomType == HTTPROOMTYPE_COMMONPRIVATELIVEROOM) {

                    self.liveRoom.roomType = LiveRoomType_Public_VIP;

                } else if (item.roomType == HTTPROOMTYPE_CHARGEPUBLICLIVEROOM) {

                    self.liveRoom.roomType = LiveRoomType_Private;

                } else if (item.roomType == HTTPROOMTYPE_LUXURYPRIVATELIVEROOM) {

                    self.liveRoom.roomType = LiveRoomType_Private_VIP;
                }
                // 发起请求
                [self startRequest];

            } else {
                ImAuthorityItemObject *obj = [[ImAuthorityItemObject alloc] init];
                obj.isHasBookingAuth = priv.isHasBookingAuth;
                obj.isHasOneOnOneAuth = priv.isHasOneOnOneAuth;
                self.liveRoom.priv = obj;

                if (errnum == HTTP_LCC_ERR_CONNECTFAIL) {
                    // 发请求断网
                    [self handleError:LCC_ERR_CONNECTFAIL errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT") onlineStatus:IMCHATONLINESTATUS_OFF];

                } else if (errnum == HTTP_LCC_ERR_NO_CREDIT) {
                    // 没钱
                    [self handleError:LCC_ERR_NO_CREDIT errMsg:errmsg onlineStatus:IMCHATONLINESTATUS_ONLINE];
                } else if (errnum == HTTP_LCC_ERR_ANCHOR_OFFLIVE) {
                    // 主播不在线
                    [self handleError:LCC_ERR_ANCHOR_OFFLINE errMsg:errmsg onlineStatus:IMCHATONLINESTATUS_ONLINE];
                } else {
                    // 所有错误统一处理
                    [self handleError:LCC_ERR_INVITE_FAIL errMsg:errmsg onlineStatus:IMCHATONLINESTATUS_ONLINE];
                }
            }
        });

    };
    [self.sessionManager sendRequest:request];
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
            self.countDownLabel.text = [NSString stringWithFormat:@"%d s", self.enterRoomLeftSecond];
        }
    });
}

- (void)startEnterRoomTimer {
    NSLog(@"LSInvitedToViewController::startEnterRoomTimer()");

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
            [self handleError:LCC_ERR_INVITE_NO_RESPOND errMsg:NSLocalizedStringFromSelf(@"INVITE_NO_RESPOND") onlineStatus:IMCHATONLINESTATUS_ONLINE];
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
                                NSLog(@"LSInvitedToViewController::startRequest( [请求进入指定直播间, %@], roomId : %@, waitStart : %@  ,isHasOneOnOneAuth : %d, isHasBookingAuth :%d)", BOOL2SUCCESS(success), self.liveRoom.roomId, BOOL2YES(roomItem.waitStart), priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
                                self.liveRoom.priv = priv;
                                [self handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
                            });
                        }];
    if (!bFlag) {
        NSLog(@"LSInvitedToViewController::startRequest( [请求进入指定直播间失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
        [self handleError:LCC_ERR_CONNECTFAIL errMsg:@"请求进入指定直播间失败" onlineStatus:IMCHATONLINESTATUS_ONLINE];
    }
}

- (void)inviteLiverPrivate {
    self.status = PreLiveStatus_Inviting;
    BOOL bFlag = NO;
    bFlag = [self.imManager invitePrivateLive:self.liveRoom.userId
                                        logId:@""
                                        force:NO
                                finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull invitationId, int timeout, NSString *_Nonnull roomId, ImInviteErrItemObject *_Nonnull inviteErrItem) {

                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        self.isOnline = inviteErrItem.status == IMCHATONLINESTATUS_ONLINE ? YES : NO;
                                        self.liveRoom.priv = inviteErrItem.priv;
                                        if (success) {
                                            self.tipLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_INVITE_SUCCESS");

                                            if (roomId.length > 0) {
                                                // 有roomId直接进入
                                                NSLog(@"LSInvitedToViewController::inviteLiverPrivate( [请求私密邀请成功, 有roomId直接进入私密直播间], userId : %@, roomId : %@ )", self.liveRoom.userId, roomId);
                                                self.liveRoom.roomId = roomId;
                                                [self startRequest];

                                            } else if (invitationId.length > 0) {
                                                // 更新邀请Id
                                                NSLog(@"LSInvitedToViewController::inviteLiverPrivate( [请求私密邀请成功, 更新邀请Id], userId : %@, invitationId : %@ )", self.liveRoom.userId, invitationId);
                                                self.inviteId = invitationId;

                                            } else {
                                                // 没法处理, 弹出错误提示(邀请失败)
                                                [self handleError:errType errMsg:NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP") onlineStatus:IMCHATONLINESTATUS_ONLINE];
                                            }
                                        }

                                    });
                                }];
    if (!bFlag) {
        NSLog(@"LSInvitedToViewController::inviteLiverPrivate( [请求私密邀请失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
        [self handleError:LCC_ERR_CONNECTFAIL errMsg:NSLocalizedStringFromSelf(@"c1g-oJ-bRc.text") onlineStatus:IMCHATONLINESTATUS_ONLINE];
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
    self.status = PreLiveStatus_Error;
    if (errMsg.length == 0) {
        errMsg = NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP");
    }
    self.isOnline = onlineStatus == IMCHATONLINESTATUS_ONLINE ? YES : NO;
    self.loadingView.hidden = YES;
    [self.tipLabel setText:errMsg];

    if (errType != LCC_ERR_CONNECTFAIL && errType != LCC_ERR_INVITE_NO_RESPOND) {
        self.inviteId = nil;
    }

    [self stopAllTimer];

    switch (errType) {
        case LCC_ERR_NO_CREDIT: {
            self.addCreditHeight.constant = 33;
        } break;

        case LCC_ERR_INVITE_NO_RESPOND: {
            //本地超时不显示按钮
        } break;
        case LCC_ERR_CONNECTFAIL: {
            self.retryBtnHeight.constant = 33;
        } break;

        case LCC_ERR_ANCHOR_OFFLINE: {
            [self showBookOneOnOne];
        } break;
        case LCC_ERR_ROOM_FULL: {
            [self showStartOneOnOne];
        } break;
        case LCC_ERR_INVITE_FAIL: {
            // 显示立即私密按钮
            [self showStartOneOnOne];
            [self showBookOneOnOne];
        } break;

        case LCC_ERR_INVITE_REJECT: {
            // TODO:7.主播拒绝
            NSString *tips = @"";
            if (errMsg.length > 0) {
                tips = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_REJECT"), errMsg];
            } else {
                tips = NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_NO_RESPONE");
            }
            self.tipLabel.text = tips;
            [self showBookOneOnOne];
        } break;
        case LCC_ERR_PRIVTE_INVITE_AUTHORITY: {

            self.chatNowBtnH.constant = 36;
            if (self.isOnline) {
                [self.chatNowBtn setImage:[UIImage imageNamed:@"Home_ChatNow"] forState:UIControlStateNormal];
            } else {
                [self.chatNowBtn setImage:[UIImage imageNamed:@"Home_SendＭail"] forState:UIControlStateNormal];
            }

        } break;
        default: {
            // 显示立即私密按钮
            [self showStartOneOnOne];
            [self showBookOneOnOne];
        } break;
    }
}

- (void)showStartOneOnOne {
    if (self.isOnline && self.liveRoom.priv.isHasOneOnOneAuth) {
        self.startPrivateHeight.constant = 35;
    }
}

- (void)showBookOneOnOne {
    if (self.liveRoom.priv.isHasBookingAuth) {
        self.bookPrivateHeight.constant = 35;
    }
}

- (void)enterRoom {
    self.status = PreLiveStatus_EnterRoomAlready;
    // 如果在后台记录进入时间
    if (self.isBackground) {
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
        [LiveGobalManager manager].liveRoom = self.liveRoom;
    } else {
        if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_COMMONPRIVATELIVEROOM) {
            // 普通私密直播间
            //        self.liveRoom.roomType = LiveRoomType_Private;
            //        [self enterPrivateRoom];
            self.liveRoom.roomType = LiveRoomType_Private_VIP;
            [self enterPrivateVipRoom];

        } else if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_LUXURYPRIVATELIVEROOM) {
            // 豪华私密直播间
            self.liveRoom.roomType = LiveRoomType_Private_VIP;
            [self enterPrivateVipRoom];
        } else {
            [self handleError:LCC_ERR_FAIL errMsg:NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP") onlineStatus:IMCHATONLINESTATUS_ONLINE];
        }
    }
}

- (void)enterPrivateRoom {
    // TODO:进入私密直播间界面
    self.isEnterRoom = YES;
    PrivateViewController *vc = [[PrivateViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    self.vc = vc;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterPrivateVipRoom {
    // TODO:进入豪华私密直播间界面
    self.isEnterRoom = YES;
    PrivateVipViewController *vc = [[PrivateVipViewController alloc] initWithNibName:nil bundle:nil];
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
                    self.tipLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_INVITE_SUCCESS");

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

                        [self.tipLabel setText:NSLocalizedStringFromSelf(@"PRELIVE_TIPS_BOARDCAST_ACCEPT")];

                        // 开始倒数
                        [self stopEnterRoomTimer];
                        [self startEnterRoomTimer];

                    } else {
                        // 马上进入直播间
                        [self enterRoom];
                    }
                }
            }
        }
    });
}

- (void)onRecvInstantInviteReplyNotice:(ImInviteReplyItemObject *_Nonnull)replyItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSInvitedToViewController::onRecvInstantInviteReplyNotice( [立即私密邀请回复通知], roomId : %@, inviteId : %@, replyType : %d )", replyItem.roomId, replyItem.inviteId, replyItem.replyType);
        self.liveRoom.priv = replyItem.priv;
        // 没有进入直播间才处理
        if (self.exitLeftSecond > 0) {
            // 当前邀请通知
            if ([replyItem.inviteId isEqualToString:self.inviteId]) {
                // 邀请中才处理
                if (self.status == PreLiveStatus_Inviting) {
                    self.status = PreLiveStatus_WaitingEnterRoom;

                    if (replyItem.replyType == REPLYTYPE_AGREE) {
                        // 主播同意
                        self.statusLabel.text = DEBUG_STRING(@"主播同意私密邀请");
                        // 更新直播间Id, 发起进入直播间请求
                        self.liveRoom.roomId = replyItem.roomId;
                        [self startRequest];

                    } else if (replyItem.replyType == REPLYTYPE_REJECT) {
                        // 主播结束拒绝, 弹出提示
                        self.statusLabel.text = DEBUG_STRING(@"主播拒绝私密邀请");
                        [self handleError:LCC_ERR_INVITE_REJECT errMsg:replyItem.msg onlineStatus:replyItem.status];
                    }
                    // 清空邀请
                    self.inviteId = nil;
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
    if (self.liveRoom.roomId) {
        [self startRequest];

    } else {
        if (self.inviteId) {
            [self requestHandleBookWithInvited:self.inviteId];
        }
    }
}

#pragma mark - 点击进入聊天室
- (IBAction)chatNowBtnDid:(id)sender {

    if (self.isOnline) {
        QNChatViewController *vc = [[QNChatViewController alloc] initWithNibName:nil bundle:nil];
        vc.womanId = self.liveRoom.userId;
        vc.photoURL = self.liveRoom.photoUrl;
        vc.firstName = self.liveRoom.userName;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSURL *url = [[LiveUrlHandler shareInstance] createSendmailByanchorId:self.liveRoom.userId anchorName:self.liveRoom.userName];
        [[LiveUrlHandler shareInstance] handleOpenURL:url];
    }
}
#pragma mark - 开始私密
- (IBAction)startVipPrivate:(id)sender {

    [self reset];
    // 开始计时
    [self stopHandleTimer];
    [self startHandleTimer];

    [self inviteLiverPrivate];
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
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
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

    self.tipLabel.text = @"";
    self.countDownLabel.text = @"";
    self.handleCountDownLabel.text = @"";

    self.retryBtnHeight.constant = 0;
    self.startPrivateHeight.constant = 0;
    self.bookPrivateHeight.constant = 0;
    self.addCreditHeight.constant = 0;

    self.chatNowBtnH.constant = 0;
}

- (void)stopAllTimer {
    [self stopHandleTimer];
    [self stopEnterRoomTimer];
    self.closeButton.hidden = NO;
    self.handleCountDownLabel.text = @"";
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
                NSLog(@"PreLiveViewController::willEnterForeground ( [接收后台关闭直播间]  IsTimeOut : %@ )",(self.isTimeOut == YES) ? @"Yes" : @"No");
                
                // 弹出直播间关闭界面
                LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
                finshController.liveRoom = self.liveRoom;
                finshController.errType = LCC_ERR_BACKGROUND_TIMEOUT;
                
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
    
    // 公开直播, 直接退出
//    [self.navigationController dismissViewControllerAnimated:YES completion:^{
//
//    }];
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:YES completion:nil];
}



@end
