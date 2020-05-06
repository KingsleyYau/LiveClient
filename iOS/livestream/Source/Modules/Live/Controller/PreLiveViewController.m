//
//  PreLiveViewController.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PreLiveViewController.h"

#import "PublicVipViewController.h"
#import "PrivateViewController.h"
#import "PrivateViewController.h"
#import "BookPrivateBroadcastViewController.h"
#import "LiveFinshViewController.h"
#import "AnchorPersonalViewController.h"
#import "LSAddCreditsViewController.h"
#import "QNChatViewController.h"
#import "LSSendSayHiViewController.h"

#import "LiveModule.h"
#import "LSImManager.h"
#import "LSSessionRequestManager.h"
#import "LSImageViewLoader.h"
#import "LiveRoomCreditRebateManager.h"
#import "LiveGobalManager.h"
#import "LiveBundle.h"
#import "LSRoomUserInfoManager.h"
#import "LiveUrlHandler.h"
#import "LSUserInfoManager.h"

#import "GetPromoAnchorListRequest.h"
#import "LSGetUserInfoRequest.h"
#import "SetFavoriteRequest.h"
#import "LSUpQnInviteIdRequest.h"

// 183秒后退出界面
#define INVITE_TIMEOUT 183
// 10秒后显示退出按钮
#define CANCEL_BUTTON_TIMEOUT 10

#define RECOMMEND_ITEMS (self.recommandItems.count * 10000)

typedef enum PreLiveStatus {
    PreLiveStatus_None,
    PreLiveStatus_Inviting,
    PreLiveStatus_WaitingEnterRoom,
    PreLiveStatus_CountingDownForEnterRoom,
    PreLiveStatus_EnterRoomAlready,
    PreLiveStatus_Canceling,
    PreLiveStatus_Error,
} PreLiveStatus;

typedef enum ButtonStatus {
    ButtonStatus_None,
    ButtonStatus_Book,
    ButtonStatus_AddCredits,
    ButtonStatus_Retry,
    ButtonStatus_ChatNow,
    ButtonStatus_SendMail,
    ButtonStatus_Invite,
} ButtonStatus;

@interface PreLiveViewController () <IMLiveRoomManagerDelegate, IMManagerDelegate, LiveGobalManagerDelegate>
// 当前状态
@property (nonatomic, assign) PreLiveStatus status;
// IM管理器
@property (nonatomic, strong) LSImManager *imManager;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 上次发送返回的邀请
@property (nonatomic, strong) NSString *inviteId;
// 强制发送邀请
@property (nonatomic, assign) BOOL inviteForce;

#pragma mark - 倒数控制
// 开播前倒数
@property (strong) LSTimer *enterRoomTimer;
// 开播前倒数剩余时间
@property (nonatomic, assign) int enterRoomLeftSecond;

#pragma mark - 总超时控制
// 总超时倒数
@property (strong) LSTimer *handleTimer;
// 总超时剩余时间
@property (nonatomic, assign) int exitLeftSecond;
// 显示退出按钮时间
@property (nonatomic, assign) int showExitBtnLeftSecond;
// 能否显示退出按钮
@property (nonatomic, assign) BOOL canShowExitButton;

#pragma mark - 推荐逻辑
@property (nonatomic, strong) NSMutableArray *recommandItems;

#pragma mark - 头像逻辑
@property (atomic, strong) LSImageViewLoader *imageViewLoader;
@property (atomic, strong) LSImageViewLoader *imageViewLoaderBg;

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

#pragma mark - 用户信息管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;
@property (nonatomic, strong) UIViewController *vc;

#pragma mark - 充值处理
@property (nonatomic) BOOL isAddCredit;

@property (nonatomic, assign) NSTimeInterval enterRoomTimeInterval;

//  是否进入直播间
@property (nonatomic, assign) BOOL isEnterRoom;

// 是否退入后台超时
@property (nonatomic, assign) BOOL isTimeOut;
//私密直播间新UI
@property (weak, nonatomic) IBOutlet UIView *vipView;
@property (weak, nonatomic) IBOutlet UIImageView *talentIcon;
// 关闭按钮顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeBtnTop;

@property (nonatomic, assign) BOOL isOnline;

@property (assign, nonatomic) NSInteger currentItemIndex;

@end

@implementation PreLiveViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PreLiveViewController::initCustomParam()");

    // 隐藏导航栏
    self.isShowNavBar = NO;
    // 禁止导航栏后退手势
    self.canPopWithGesture = NO;

    // 初始化管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    // 初始化后台管理器
    [[LiveGobalManager manager] addDelegate:self];

    self.sessionManager = [LSSessionRequestManager manager];

    self.imageViewLoader = [LSImageViewLoader loader];
    self.imageViewLoaderBg = [LSImageViewLoader loader];

    // 初始化余额及返点信息管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];

    self.roomUserInfoManager = [LSRoomUserInfoManager manager];

    self.recommandItems = [[NSMutableArray alloc] init];

    // 注册前后台切换通知
    _isBackground = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    // 初始化计时器
    self.handleTimer = [[LSTimer alloc] init];
    self.enterRoomTimer = [[LSTimer alloc] init];

    // 初始化开播前倒数
    self.enterRoomLeftSecond = 0;

    // 初始化进入后台时间
    self.enterRoomTimeInterval = 0;

    // 初始化是否进入直播间
    self.isEnterRoom = NO;

    // 初始化是否超时
    self.isTimeOut = NO;
}

- (void)dealloc {
    NSLog(@"PreLiveViewController::dealloc()");

    // 停止计时
    [self stopAllTimer];

    //已有RoomId 进入直播间
    if (self.liveRoom.roomId.length > 0) {
        //退出直播间
        // [self.imManager leaveRoom:self.liveRoom];
    } else {
        //未有RoomId 取消邀请
        if (self.liveRoom.roomType == LiveRoomType_Private) {
            if (self.inviteId.length > 0) {
                [self.imManager cancelPrivateLive:nil];
            }
        }
        // 清空邀请
        self.inviteId = nil;
    }

    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];

    // 注销前后台切换通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 重置参数
    [self reset];

    self.bookButton.layer.cornerRadius = self.bookButton.tx_height / 2;
    self.bookButton.layer.masksToBounds = YES;

    self.vipStartButton.layer.cornerRadius = self.vipStartButton.tx_height / 2;
    self.vipStartButton.layer.masksToBounds = YES;

    self.addCreditButton.layer.cornerRadius = self.addCreditButton.tx_height / 2;
    self.addCreditButton.layer.masksToBounds = YES;

    self.retryButton.layer.cornerRadius = self.retryButton.tx_height / 2;
    self.retryButton.layer.masksToBounds = YES;

    self.chatNowBtn.layer.cornerRadius = self.chatNowBtn.tx_height / 2;
    self.chatNowBtn.layer.masksToBounds = YES;

    self.sendMailButton.layer.cornerRadius = self.sendMailButton.tx_height / 2;
    self.sendMailButton.layer.masksToBounds = YES;

    self.ladyImageView.layer.cornerRadius = self.ladyImageView.tx_height / 2;
    self.ladyImageView.layer.masksToBounds = YES;

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

    // 禁止锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    if (IS_IPHONE_X) {
        self.closeBtnTop.constant = 45;
    } else {
        self.closeBtnTop.constant = 30;
    }
}

- (void)setupLiverHeadImageView {
    [self.imageViewLoader loadImageFromCache:self.ladyImageView
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
    self.ladyNameLabel.attributedText = name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    // 第一次进入, 或者进入了买点界面
    if (!self.viewDidAppearEver || self.isAddCredit) {
        self.isAddCredit = NO;
        // 开始计时
        [self startHandleTimer];

        // IM登录城成功才调用
        if ([LSImManager manager].isIMLogin) {
            // 发起请求
            [self startRequest];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 发起请求
                [self startRequest];
            });
        }
    }

    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 设置允许显示立即邀请
    [[LiveGobalManager manager] setCanShowInvite:YES];

    // 移除退入后台通知
    [[LiveGobalManager manager] removeDelegate:self];
}

#pragma mark - 数据逻辑
- (void)startRequest {
    BOOL bFlag = NO;
    if (self.liveRoom.roomId.length > 0) {
        NSLog(@"PreLiveViewController::startRequest( [请求进入指定直播间], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
        NSString *str = [NSString stringWithFormat:@"请求进入指定直播间(roomId:%@)", self.liveRoom.roomId];
        self.statusLabel.text = DEBUG_STRING(str);

        // TODO:发起进入指定直播间
        bFlag = [self.imManager enterRoom:self.liveRoom.roomId
                            finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem, ImAuthorityItemObject *_Nonnull priv) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"PreLiveViewController::startRequest( [请求进入指定直播间, %@], roomId : %@, waitStart : %@, isHasOneOnOneAuth %d, isHasBookingAuth : %d)", BOOL2SUCCESS(success), self.liveRoom.roomId, BOOL2YES(roomItem.waitStart), priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
                                    self.liveRoom.priv = priv;
                                    [self handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
                                });
                            }];
        if (!bFlag) {
            NSLog(@"PreLiveViewController::startRequest( [请求进入指定直播间失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
            NSString *str = [NSString stringWithFormat:@"请求进入指定直播间失败(roomId:%@)", self.liveRoom.roomId];
            self.statusLabel.text = DEBUG_STRING(str);
            [self handleError:LCC_ERR_CONNECTFAIL errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT") onlineStatus:IMCHATONLINESTATUS_ONLINE];
        }

    } else {
        if (self.liveRoom.roomType == LiveRoomType_Public) {
            NSLog(@"PreLiveViewController::startRequest( [请求进入公开直播间], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
            NSString *str = [NSString stringWithFormat:@"请求进入公开直播间"];
            self.statusLabel.text = DEBUG_STRING(str);

            // TODO:发起进入公开直播间
            bFlag = [self.imManager enterPublicRoom:self.liveRoom.userId
                                      finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem, ImAuthorityItemObject *_Nonnull priv) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSLog(@"PreLiveViewController::startRequest( [请求进入公开直播间, %@], roomId : %@, waitStart : %@, errMsg : %@, isHasOneOnOneAuth : %d, isHasBookingAuth : %d)",
                                                    BOOL2SUCCESS(success), roomItem.roomId, BOOL2YES(roomItem.waitStart), errMsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
                                              self.liveRoom.priv = priv;
                                              [self handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
                                          });
                                      }];

            if (!bFlag) {
                NSLog(@"PreLiveViewController::startRequest( [请求进入公开直播间失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
                NSString *str = [NSString stringWithFormat:@"请求进入公开直播间失败"];
                self.statusLabel.text = DEBUG_STRING(str);
                [self handleError:LCC_ERR_CONNECTFAIL errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT") onlineStatus:IMCHATONLINESTATUS_ONLINE];
            }

        } else {
            NSLog(@"PreLiveViewController::startRequest( [请求私密邀请], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
            NSString *str = [NSString stringWithFormat:@"请求私密邀请"];
            self.statusLabel.text = DEBUG_STRING(str);
            self.status = PreLiveStatus_Inviting;

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

            // TODO:发起私密直播邀请
            bFlag = [self.imManager invitePrivateLive:self.liveRoom.userId
                                                logId:@""
                                                force:self.inviteForce
                                        finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull invitationId, int timeout, NSString *_Nonnull roomId, ImInviteErrItemObject *_Nonnull inviteErrItem) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                NSLog(@"PreLiveViewController::startRequest( [请求私密邀请, %@], userId : %@, invitationId : %@, roomId : %@, errType : %d, errMsg : %@, chatOnlineStatus : %d, isHasOneOnOneAuth : %d, isHasBookingAuth: %d )", BOOL2SUCCESS(success), self.liveRoom.userId, invitationId, roomId, errType, errMsg, inviteErrItem.status, inviteErrItem.priv.isHasOneOnOneAuth, inviteErrItem.priv.isHasBookingAuth);
                                                self.liveRoom.priv = inviteErrItem.priv;
                                                if (self.exitLeftSecond > 0) {
                                                    // 未超时
                                                    if (success) {
                                                        // TODO:私密邀请发送成功
                                                        NSString *str = [NSString stringWithFormat:@"请求私密邀请成功, 等待对方确认"];
                                                        self.statusLabel.text = DEBUG_STRING(str);
                                                        self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_INVITE_SUCCESS");

                                                        [self upQNInviteId:invitationId roomId:roomId anchorId:self.liveRoom.userId];

                                                        if (roomId.length > 0) {
                                                            // 有roomId直接进入
                                                            NSLog(@"PreLiveViewController::startRequest( [请求私密邀请成功, 有roomId直接进入私密直播间], userId : %@, roomId : %@ )", self.liveRoom.userId, roomId);
                                                            self.liveRoom.roomId = roomId;
                                                            [self startRequest];

                                                        } else if (invitationId.length > 0) {
                                                            // 更新邀请Id
                                                            NSLog(@"PreLiveViewController::startRequest( [请求私密邀请成功, 更新邀请Id], userId : %@, invitationId : %@ )", self.liveRoom.userId, invitationId);
                                                            self.inviteId = invitationId;
                                                        } else {
                                                            // 没法处理, 弹出错误提示(邀请失败)
                                                            NSString *str = [NSString stringWithFormat:@"请求私密邀请失败, 没有inviteId或者roomId"];
                                                            self.statusLabel.text = DEBUG_STRING(str);
                                                            [self handleError:errType errMsg:errMsg onlineStatus:inviteErrItem.status];
                                                        }

                                                    } else {
                                                        // 弹出错误提示(邀请失败)
                                                        [self handleError:errType errMsg:errMsg onlineStatus:inviteErrItem.status];
                                                    }
                                                }

                                            });
                                        }];

            if (!bFlag) {
                NSLog(@"PreLiveViewController::startRequest( [请求私密邀请失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
                NSString *str = [NSString stringWithFormat:@"请求私密邀请失败(userId:%@)", self.liveRoom.userId];
                self.statusLabel.text = DEBUG_STRING(str);
                [self handleError:LCC_ERR_CONNECTFAIL errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT") onlineStatus:IMCHATONLINESTATUS_ONLINE];
            }
        }
    }
}

- (void)upQNInviteId:(NSString *)inviteId roomId:(NSString *)roomId anchorId:(NSString *)anchorId {
    LSUpQnInviteIdRequest *request = [[LSUpQnInviteIdRequest alloc] init];
    request.manId = [LSLoginManager manager].loginItem.userId;
    request.anchorId = anchorId;
    request.inviteId = inviteId;
    request.roomId = roomId;
    request.inviteType = LSBUBBLINGINVITETYPE_ONEONONE;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        NSLog(@"PreLiveViewController::upQNInviteId( [更新邀请ID, %@], errnum : %d, errmsg : %@, roomId : %@, inviteId : %@ )", BOOL2SUCCESS(success), errnum, errmsg, roomId, inviteId);
    };
    [self.sessionManager sendRequest:request];
}

- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg onlineStatus:(IMChatOnlineStatus)onlineStatus {
    // TODO:错误处理
    //    self.statusLabel.text = DEBUG_STRING(@"出错啦");
    [self stopAllTimer];
    // 改变状态为出错
    self.status = PreLiveStatus_Error;

    self.isOnline = onlineStatus == IMCHATONLINESTATUS_ONLINE ? YES : NO;
    self.loadingView.hidden = YES;
    self.vipView.hidden = YES;
    // 清空邀请
    self.inviteId = nil;

    if (errMsg.length == 0) {
        errMsg = NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP");
    }
    self.tipsLabel.text = errMsg;

    switch (errType) {
        case LCC_ERR_NO_CREDIT: {
            // 没有信用点
            [self showErrorButton:ButtonStatus_AddCredits];
        } break;

        case LCC_ERR_INVITE_NO_RESPOND:
        case LCC_ERR_INVITATION_EXPIRE:
        case LCC_ERR_INVITE_REJECT:
        case LCC_ERR_ROOM_FULL:
        case LCC_ERR_ANCHOR_OFFLINE:
        case LCC_ERR_ROOM_CLOSE:
        case LCC_ERR_NOT_FOUND_ROOM:
        case LCC_ERR_ANCHOR_NO_ON_LIVEROOM:
        case LCC_ERR_ANCHOR_BUSY:
        case LCC_ERR_HANGOUT_EXIST_COUNTDOWN_PRIVITEROOM:
        case LCC_ERR_HANGOUT_EXIST_COUNTDOWN_HANGOUTROOM:
        case LCC_ERR_HANGOUT_EXIST_FOUR_MIN_SHOW:
        case LCC_ERR_KNOCK_EXIST_ROOM:
        case LCC_ERR_INVITE_FAIL_SHOWING:
        case LCC_ERR_INVITE_FAIL_BUSY:
        case LCC_ERR_SEND_RECOMMEND_HAS_SHOWING:
        case LCC_ERR_SEND_RECOMMEND_EXIT_HANGOUTROOM: {
            // 主播180s仍未同意、重连获取主播邀请状态拒绝、主播拒绝
            // 房间满人、主播不在线、预约已过期(找不到房间信息)、该主播不存在公开直播间、主播各种繁忙
            [self showErrorButton:ButtonStatus_Book];
        } break;

        case LCC_ERR_CONNECTFAIL: {
            // 连接服务器失败
            [self showErrorButton:ButtonStatus_Retry];
        } break;

        case LCC_ERR_PRIVTE_INVITE_AUTHORITY: {
            // 主播无立即私密邀请权限
            if (self.liveRoom.roomId.length > 0) {
                [self showErrorButton:ButtonStatus_None];
            } else {
                if (self.isOnline) {
                    [self showErrorButton:ButtonStatus_ChatNow];
                } else {
                    [self showErrorButton:ButtonStatus_SendMail];
                }
            }
        } break;

        default: {
            [self showErrorButton:ButtonStatus_None];
        } break;
    }
}

- (void)reset {
    // TODO:重置参数
    // 180秒后退出界面
    self.exitLeftSecond = INVITE_TIMEOUT;
    // 10秒后显示退出按钮
    self.showExitBtnLeftSecond = CANCEL_BUTTON_TIMEOUT;
    // 能否显示退出按钮
    self.canShowExitButton = YES;
    // 是否强制发送邀请
    self.inviteForce = YES;
    // 清空邀请Id
    self.inviteId = nil;
    // 清空roomId
    //    self.liveRoom.roomId = nil;
    // 标记当前状态
    self.status = PreLiveStatus_None;

    self.isOnline = YES;

    // 还原状态提示
    self.tipsLabel.text = @"";
    self.statusLabel.text = @"";
    self.handleCountDownLabel.text = @"";
    // 显示菊花
    self.loadingView.hidden = NO;
    // 隐藏按钮
    self.cancelButton.hidden = YES;
    self.retryButton.hidden = YES;
    self.addCreditButton.hidden = YES;
    self.bookButton.hidden = YES;
    self.vipStartButton.hidden = YES;
    self.chatNowBtn.hidden = YES;
    self.sendMailButton.hidden = YES;
}

- (void)stopAllTimer {
    [self stopHandleTimer];
    [self stopEnterRoomTimer];
    self.cancelButton.hidden = NO;
    self.handleCountDownLabel.text = @"";
}

- (void)showStartOneOnOne {
    if (self.isOnline && self.liveRoom.priv.isHasOneOnOneAuth) {
        self.vipStartButton.hidden = NO;
    } else {
        self.vipStartButton.hidden = YES;
    }
}

- (void)showBookOneOnOne {
    // 关闭预约,隐藏按钮
    self.bookButton.hidden = YES;
    //    if (self.liveRoom.priv.isHasBookingAuth) {
    //        self.bookButton.hidden = NO;
    //    } else {
    //        self.bookButton.hidden = YES;
    //    }
}

- (void)showErrorButton:(ButtonStatus)Status {
    switch (Status) {
        case ButtonStatus_Book: {
            [self showBookOneOnOne];
            self.retryButton.hidden = YES;
            self.addCreditButton.hidden = YES;
            self.vipStartButton.hidden = YES;
            self.chatNowBtn.hidden = YES;
            self.sendMailButton.hidden = YES;
        } break;

        case ButtonStatus_Retry: {
            self.retryButton.hidden = NO;
            self.addCreditButton.hidden = YES;
            self.bookButton.hidden = YES;
            self.vipStartButton.hidden = YES;
            self.chatNowBtn.hidden = YES;
            self.sendMailButton.hidden = YES;
        } break;

        case ButtonStatus_AddCredits: {
            self.addCreditButton.hidden = NO;
            self.retryButton.hidden = YES;
            self.bookButton.hidden = YES;
            self.vipStartButton.hidden = YES;
            self.chatNowBtn.hidden = YES;
            self.sendMailButton.hidden = YES;
        } break;

        case ButtonStatus_ChatNow: {
            self.chatNowBtn.hidden = NO;
            self.addCreditButton.hidden = YES;
            self.retryButton.hidden = YES;
            self.bookButton.hidden = YES;
            self.vipStartButton.hidden = YES;
            self.sendMailButton.hidden = YES;
        } break;

        case ButtonStatus_SendMail: {
            self.sendMailButton.hidden = NO;
            self.chatNowBtn.hidden = YES;
            self.addCreditButton.hidden = YES;
            self.retryButton.hidden = YES;
            self.bookButton.hidden = YES;
            self.vipStartButton.hidden = YES;
        } break;

        case ButtonStatus_Invite: {
            [self showStartOneOnOne];
            self.retryButton.hidden = YES;
            self.addCreditButton.hidden = YES;
            self.bookButton.hidden = YES;
            self.chatNowBtn.hidden = YES;
            self.sendMailButton.hidden = YES;
        } break;

        default: {
            self.retryButton.hidden = YES;
            self.addCreditButton.hidden = YES;
            self.bookButton.hidden = YES;
            self.vipStartButton.hidden = YES;
            self.chatNowBtn.hidden = YES;
            self.sendMailButton.hidden = YES;
        } break;
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
                self.liveRoom.liveShowType = roomItem.liveShowType;
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
                self.canShowExitButton = NO;
                self.cancelButton.hidden = YES;

                if (roomItem.waitStart) {
                    // 等待主播进入
                    self.statusLabel.text = DEBUG_STRING(@"等待主播进入直播间...");
                    self.status = PreLiveStatus_WaitingEnterRoom;
                    self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_INVITE_SUCCESS");

                } else {
                    self.statusLabel.text = DEBUG_STRING([NSString stringWithFormat:@"进入直播间成功, 准备跳转..."]);
                    if (roomItem.leftSeconds > 0) {
                        self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_BOARDCAST_ACCEPT");

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
                        self.liveRoom.userId = roomItem.userId;
                        // 马上进入直播间
                        [self enterRoom];
                    }
                    //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //                        // 马上进入直播间
                    //                        [self enterRoom];
                    //                    });
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
                self.statusLabel.text = DEBUG_STRING([NSString stringWithFormat:@"进入直播间失败"]);
                [self handleError:errType errMsg:errMsg onlineStatus:IMCHATONLINESTATUS_ONLINE];
            }
        }
    }
}

- (void)enterRoom {
    self.status = PreLiveStatus_EnterRoomAlready;
    // 如果在后台记录进入时间
    if (self.isBackground) {
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
        [LiveGobalManager manager].liveRoom = self.liveRoom;
    } else {
        // TODO:根据服务器返回的直播间类型进入
        if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_FREEPUBLICLIVEROOM || self.liveRoom.imLiveRoom.roomType == ROOMTYPE_CHARGEPUBLICLIVEROOM) {
            // 公开直播间
            self.liveRoom.roomType = LiveRoomType_Public;
            [self enterPublicVipRoom];

        } else if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_COMMONPRIVATELIVEROOM || self.liveRoom.imLiveRoom.roomType == ROOMTYPE_LUXURYPRIVATELIVEROOM) {
            // 私密直播间
            self.liveRoom.roomType = LiveRoomType_Private;
            [self enterPrivateRoom];
        } else {
            [self handleError:LCC_ERR_FAIL errMsg:NSLocalizedStringFromSelf(@"UNKNOW_ROOM_TYPE") onlineStatus:IMCHATONLINESTATUS_ONLINE];
        }
    }
}

- (void)enterPublicVipRoom {
    // TODO:进入付费公开直播间界面
    self.isEnterRoom = YES;
    PublicVipViewController *vc = [[PublicVipViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    self.vc = vc;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - 直播间IM通知
- (void)onRecvWaitStartOverNotice:(ImStartOverRoomObject *_Nonnull)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PreLiveViewController::onRecvWaitStartOverNotice( [接收主播进入直播间通知], roomId : %@, waitStart : %@, leftSeconds : %d )", item.roomId, BOOL2YES(self.liveRoom.imLiveRoom.waitStart), item.leftSeconds);

        // 没有进入直播间才处理
        if (self.exitLeftSecond > 0) {
            // 当前直播间通知, 并且是需要等待主播进入的
            if ([item.roomId isEqualToString:self.liveRoom.roomId] && self.liveRoom.imLiveRoom.waitStart) {
                // 等待进入房间中才处理
                if (self.status == PreLiveStatus_WaitingEnterRoom) {
                    self.statusLabel.text = DEBUG_STRING(@"主播已经进入直播间, 开始倒数...");
                    self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_BOARDCAST_ACCEPT");

                    // 停止180s倒数
                    [self stopHandleTimer];

                    // 更新流地址
                    [self.liveRoom reset];
                    self.liveRoom.playUrlArray = [item.playUrl copy];

                    // 更新倒数时间
                    self.enterRoomLeftSecond = item.leftSeconds;

                    // 不能显示退出按钮
                    self.canShowExitButton = NO;
                    self.cancelButton.hidden = YES;

                    if (self.enterRoomLeftSecond > 0) {
                        self.status = PreLiveStatus_CountingDownForEnterRoom;

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
        NSLog(@"PreLiveViewController::onRecvInstantInviteReplyNotice( [立即私密邀请回复通知], roomId : %@, inviteId : %@, replyType : %d, isHasOneOnOneAuth: %d, isHasBookingAuth : %d)", replyItem.roomId, replyItem.inviteId, replyItem.replyType, replyItem.priv.isHasOneOnOneAuth, replyItem.priv.isHasBookingAuth);
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
                        NSString *tips = @"";
                        if (replyItem.msg.length > 0) {
                            tips = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_REJECT"), replyItem.msg];
                        } else {
                            tips = NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_NO_RESPONE");
                        }
                        [self handleError:LCC_ERR_INVITE_REJECT errMsg:tips onlineStatus:replyItem.status];
                    }

                    // 清空邀请
                    self.inviteId = nil;
                }
            }
        }

    });
}

- (void)onRecvInviteReply:(ImInviteIdItemObject *_Nonnull)item {
    NSLog(@"PreLiveViewController::onRecvInviteReply( [断线重登陆获取到的邀请状态], roomId : %@, inviteId : %@, replyType : %d )", item.roomId, item.invitationId, item.replyType);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 没有进入直播间才处理
        if (self.exitLeftSecond > 0) {
            // 当前邀请通知
            if ([item.invitationId isEqualToString:self.inviteId]) {
                if (self.status == PreLiveStatus_Inviting) {
                    switch (item.replyType) {
                        case HTTPREPLYTYPE_AGREE: {
                            // 主播同意, 发起进入直播间请求
                            self.statusLabel.text = DEBUG_STRING(@"主播同意私密邀请");
                            self.status = PreLiveStatus_WaitingEnterRoom;

                            self.inviteId = nil;

                            if (item.roomId.length > 0) {
                                self.liveRoom.roomId = item.roomId;
                            }
                            [self startRequest];
                        } break;

                        case HTTPREPLYTYPE_REJECT:
                        case HTTPREPLYTYPE_CANCEL:
                        case HTTPREPLYTYPE_OUTTIME:
                        case HTTPREPLYTYPE_ANCHORABSENT:
                        case HTTPREPLYTYPE_FANSABSENT: {
                            // 清空邀请
                            self.inviteId = nil;

                            // 显示错误提示
                            [self handleError:LCC_ERR_INVITATION_EXPIRE errMsg:NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_NO_RESPONE") onlineStatus:IMCHATONLINESTATUS_ONLINE];
                        } break;

                        default: {
                        } break;
                    }
                }
            }
        }
    });
}

- (void)onRecvChangeVideoUrl:(NSString *_Nonnull)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString *> *_Nonnull)playUrl userId:(NSString *_Nonnull)userId {
    NSLog(@"PreLiveViewController::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@ userId:%@)", roomId, playUrl, userId);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新流地址
        [self.liveRoom reset];
        self.liveRoom.playUrlArray = [playUrl copy];
    });
}

- (void)onRecvRoomCloseNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg priv:(ImAuthorityItemObject *_Nonnull)priv {
    NSLog(@"PreLiveViewController::onRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@, isHasOneOnOneAuth : %d, isHasBookingAuth: %d )", roomId, errType, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
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
    NSLog(@"PreLiveViewController::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ credit:%f isHasOneOnOneAuth : %d, isHasBookingAuth : %d", roomId, credit, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
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

- (void)onRecvPublicRoomFreeMsgNotice:(NSString *)roomId message:(NSString *)message {
    NSLog(@"LSVIPLiveViewController::onRecvPublicRoomFreeMsgNotice( [接收公开直播间资费提示通知] roomId : %@, message : %@ )", roomId, message);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.liveRoom.publicRoomFreeMsg = message;
        }
    });
}

#pragma mark - 倒数控制
- (void)enterRoomCountDown {
    //    NSLog(@"PreLiveViewController::countDown( enterRoomLeftSecond : %d )", self.enterRoomLeftSecond);
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
            self.tipsLabel.attributedText = tip;
        }
    });
}

- (void)startEnterRoomTimer {
    NSLog(@"PreLiveViewController::startEnterRoomTimer()");
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
    NSLog(@"PreLiveViewController::stopEnterRoomTimer()");

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

            // 180s超时
            [self handleError:LCC_ERR_LOCAL_TIMEOUT errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT") onlineStatus:IMCHATONLINESTATUS_ONLINE];

            // 允许显示退出按钮
            self.cancelButton.hidden = NO;
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
                self.cancelButton.hidden = NO;
            }
        });
    }
}

- (void)startHandleTimer {
    NSLog(@"PreLiveViewController::startHandleTimer()");

    WeakObject(self, weakSelf);
    [self.handleTimer startTimer:nil
                    timeInterval:1.0 * NSEC_PER_SEC
                         starNow:YES
                          action:^{
                              [weakSelf handleCountDown];
                          }];
}

- (void)stopHandleTimer {
    NSLog(@"PreLiveViewController::stopHandleTimer()");

    [self.handleTimer stopTimer];
}

#pragma mark - 点击事件
- (IBAction)close:(id)sender {
    // TODO:点击关闭界面
    NSLog(@"PreLiveViewController::close()");

    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:YES completion:nil];
}

- (IBAction)addCreditAciton:(id)sender {
    // TODO:点击充值
    // 重置参数
    [self reset];

    self.isAddCredit = YES;
    [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
    NSURL *url = [[LiveUrlHandler shareInstance] createBuyCredit];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (IBAction)retry:(id)sender {
    // TODO:点击重试
    [[LiveModule module].analyticsManager reportActionEvent:BroadcastTransitionClickContinue eventCategory:EventCategoryTransition];
    // 重置参数
    [self reset];

    // 开始计时
    [self stopHandleTimer];
    [self startHandleTimer];

    // 发起请求
    [self startRequest];
}

- (IBAction)book:(id)sender {
    // TODO:点击预约私密
    // 重置参数
    //    [self reset];
    [[LiveModule module].analyticsManager reportActionEvent:SendRequestBooking eventCategory:EventCategoryenterBroadcast];
    // 跳转预约
    BookPrivateBroadcastViewController *vc = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    vc.userId = self.liveRoom.userId;
    vc.userName = self.liveRoom.userName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)invite:(id)sender {
    // TODO:点击强制邀请
    // 重置参数
    [self reset];

    // 开始计时
    [self stopHandleTimer];
    [self startHandleTimer];

    self.inviteForce = YES;
    [self startRequest];
}

- (IBAction)chatNowBtnDid:(id)sender {
    // TODO:点击进入聊天
    QNChatViewController *vc = [[QNChatViewController alloc] initWithNibName:nil bundle:nil];
    vc.womanId = self.liveRoom.userId;
    vc.photoURL = self.liveRoom.photoUrl;
    vc.firstName = self.liveRoom.userName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sendMailBtnDid:(id)sender {
    // TODO:点击进入发信
    NSURL *url = [[LiveUrlHandler shareInstance] createSendmailByanchorId:self.liveRoom.userId anchorName:self.liveRoom.userName emfiId:@""];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    if( _isBackground == NO ) {
        _isBackground = YES;
        
        // 如果已经进入直播间成功, 更新切换后台时间
        if( self.status == PreLiveStatus_EnterRoomAlready ) {
            [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
            [LiveGobalManager manager].liveRoom = self.liveRoom;
        } else {
            [LiveGobalManager manager].enterRoomBackgroundTime = nil;
        }
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if( _isBackground == YES ) {
        _isBackground = NO;
        
        if ( self.enterRoomTimeInterval < BACKGROUND_TIMEOUT && !self.enterRoomLeftSecond
            && self.status == PreLiveStatus_EnterRoomAlready && !self.isEnterRoom ) {
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
        
        // 已超时
        self.isTimeOut = YES;
        
        if (self.liveRoom.roomId.length > 0) {
            [self.imManager leaveRoom:self.liveRoom];
        }
    }
}

@end
