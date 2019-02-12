//
//  PreLiveViewController.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PreLiveViewController.h"

#import "PublicViewController.h"
#import "PublicVipViewController.h"
#import "PrivateViewController.h"
#import "PrivateVipViewController.h"
#import "BookPrivateBroadcastViewController.h"
#import "LiveFinshViewController.h"
#import "AnchorPersonalViewController.h"
#import "ShowLiveViewController.h"
#import "LSAddCreditsViewController.h"

#import "LiveModule.h"
#import "LSImManager.h"
#import "LSSessionRequestManager.h"
#import "LSImageViewLoader.h"
#import "LiveRoomCreditRebateManager.h"
#import "LiveGobalManager.h"
#import "LiveBundle.h"
#import "LSUserInfoManager.h"
#import "LiveUrlHandler.h"

#import "RecommandCollectionViewCell.h"

#import "GetPromoAnchorListRequest.h"
#import "LSGetUserInfoRequest.h"
#import "QNChatViewController.h"
// 180秒后退出界面
#define INVITE_TIMEOUT 180
// 10秒后显示退出按钮
#define CANCEL_BUTTON_TIMEOUT 10

typedef enum PreLiveStatus {
    PreLiveStatus_None,
    PreLiveStatus_Inviting,
    PreLiveStatus_WaitingEnterRoom,
    PreLiveStatus_CountingDownForEnterRoom,
    PreLiveStatus_EnterRoomAlready,
    PreLiveStatus_Canceling,
    PreLiveStatus_Error,
} PreLiveStatus;

@interface PreLiveViewController () <IMLiveRoomManagerDelegate, IMManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate,LiveGobalManagerDelegate>
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
@property (atomic, strong) NSArray *recommandItems;

#pragma mark - 头像逻辑
@property (atomic, strong) LSImageViewLoader *imageViewLoader;
@property (atomic, strong) LSImageViewLoader *imageViewLoaderBg;

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

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
@end

@implementation PreLiveViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PreLiveViewController::initCustomParam()");

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
    
    // 注册前后台切换通知
    _isBackground = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
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
    
    //已有RoomId 进入直播间
    if (self.liveRoom.roomId.length > 0) {
        //退出直播间
        [self.imManager leaveRoom:self.liveRoom];
    }
    else
    {
        //未有RoomId 取消邀请
        if (self.liveRoom.roomType == LiveRoomType_Private || self.liveRoom.roomType == LiveRoomType_Private_VIP) {
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 重置参数
    [self reset];
    
    // 刷新女士名字
    self.ladyNameLabel.text = @"";
    // 放大菊花
//    self.loadingView.transform = CGAffineTransformMakeScale(2.0, 2.0);

    // 禁止导航栏后退手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    // 刷新女士名字
    if ( self.liveRoom.userName.length > 0 ) {
        self.ladyNameLabel.text = self.liveRoom.userName;
    }
    
    // 刷新背景
    if ( self.liveRoom.roomPhotoUrl.length > 0 ) {
        [self.imageViewLoaderBg loadImageWithImageView:self.bgImageView options:0 imageUrl:self.liveRoom.roomPhotoUrl placeholderImage:nil];
    }
    
    // 刷新女士头像
    if ( self.liveRoom.photoUrl.length > 0 ) {
        [self.imageViewLoader refreshCachedImage:self.ladyImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    } else {
        // 请求并缓存主播信息
        WeakObject(self, weakSelf);
        [[LSUserInfoManager manager] getUserInfo:self.liveRoom.userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 刷新女士头像
                weakSelf.liveRoom.photoUrl = item.photoUrl;
                [weakSelf.imageViewLoader refreshCachedImage:self.ladyImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
                // 刷新女士名字
                weakSelf.liveRoom.userName = item.nickName;
                weakSelf.ladyNameLabel.text = item.nickName;
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
        self.closeBtnTop.constant = 39;
    } else {
        self.closeBtnTop.constant = 15;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    // 第一次进入, 或者进入了买点界面
    if( !self.viewDidAppearEver || self.isAddCredit ) {
        self.isAddCredit = NO;
        
//        self.liveRoom.roomId = @"1";
//        self.liveRoom.roomType = LiveRoomType_Private_VIP;
//        [self enterPrivateVipRoom];
        // 开始计时
        [self startHandleTimer];
        
        // IM登录城成功才调用
        if ([LSImManager manager].isIMLogin){
            // 发起请求
            [self startRequest];
        }else {
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

    // 停止计时
    [self stopAllTimer];
    
    // 设置允许显示立即邀请
    [[LiveGobalManager manager] setCanShowInvite:YES];
    
    // 移除退入后台通知
    [[LiveGobalManager manager] removeDelegate:self];
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化推荐
    [self setupRecommandView];
    // 初始化背景
//    [self setupBgImageView];
    // 初始化主播头像
    [self setupLadyImageView];
}

- (void)setupRecommandView {
    NSBundle *bundle = [LiveBundle mainBundle];
    UINib *nib = [UINib nibWithNibName:@"RecommandCollectionViewCell" bundle:bundle];
    [self.recommandCollectionView registerNib:nib forCellWithReuseIdentifier:[RecommandCollectionViewCell cellIdentifier]];
    self.recommandViewHeight.constant = 0;
    self.recommandCollectionView.alwaysBounceVertical = NO;
    self.recommandCollectionView.alwaysBounceHorizontal = NO;
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

- (void)setupLadyImageView {
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.frame.size.width / 2;
    self.ladyImageView.layer.masksToBounds = YES;
}

#pragma mark - 数据逻辑
- (void)startRequest {
    BOOL bFlag = NO;
    WeakObject(self, waekSelf);
    if (self.liveRoom.roomId.length > 0) {
        NSLog(@"PreLiveViewController::startRequest( [请求进入指定直播间], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
        NSString *str = [NSString stringWithFormat:@"请求进入指定直播间(roomId:%@)", self.liveRoom.roomId];
        self.statusLabel.text = DEBUG_STRING(str);

        // TODO:发起进入指定直播间
        bFlag = [self.imManager enterRoom:self.liveRoom.roomId
                            finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem, ImAuthorityItemObject *_Nonnull priv) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"PreLiveViewController::startRequest( [请求进入指定直播间, %@], roomId : %@, waitStart : %@ ,isHasOneOnOneAuth %d, isHasBookingAuth : %d)", BOOL2SUCCESS(success), waekSelf.liveRoom.roomId, BOOL2YES(roomItem.waitStart),priv.isHasOneOnOneAuth,priv.isHasBookingAuth);
                                    waekSelf.liveRoom.priv = priv;
                                    [waekSelf handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
                                });
                            }];
        if (!bFlag) {
            NSLog(@"PreLiveViewController::startRequest( [请求进入指定直播间失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
            NSString *str = [NSString stringWithFormat:@"请求进入指定直播间失败(roomId:%@)", self.liveRoom.roomId];
            self.statusLabel.text = DEBUG_STRING(str);
            [self handleError:LCC_ERR_CONNECTFAIL errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT") onlineStatus:IMCHATONLINESTATUS_ONLINE];
        }

    } else {
        if (self.liveRoom.roomType == LiveRoomType_Public || self.liveRoom.roomType == LiveRoomType_Public_VIP) {
            NSLog(@"PreLiveViewController::startRequest( [请求进入公开直播间], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
            NSString *str = [NSString stringWithFormat:@"请求进入公开直播间"];
            self.statusLabel.text = DEBUG_STRING(str);

            // TODO:发起进入公开直播间
            bFlag = [self.imManager enterPublicRoom:self.liveRoom.userId
                                      finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem, ImAuthorityItemObject *_Nonnull priv) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSLog(@"PreLiveViewController::startRequest( [请求进入公开直播间, %@], roomId : %@, waitStart : %@, errMsg : %@ isHasOneOnOneAuth : %d, isHasBookingAuth : %d)",
                                                    BOOL2SUCCESS(success), roomItem.roomId, BOOL2YES(roomItem.waitStart), errMsg, priv.isHasOneOnOneAuth,priv.isHasBookingAuth);
                                              waekSelf.liveRoom.priv = priv;
                                              [waekSelf handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
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
            
            self.vipView.hidden = NO;
            
            NSMutableArray * array = [NSMutableArray array];
            for (int i = 1; i <= 12; i++) {
                [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"TalentIcon%d",i]]];
            }
            for (int i = 1; i <= 6; i++) {
               [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"TalentIcon%d",12]]];
            }
        
            self.talentIcon.animationImages = array;
            self.talentIcon.animationDuration = 0.9;
            [self.talentIcon startAnimating];
            
            // TODO:发起私密直播邀请
            bFlag = [self.imManager invitePrivateLive:self.liveRoom.userId
                                                logId:@""
                                                force:self.inviteForce
            finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull invitationId, int timeout, NSString *_Nonnull roomId, ImInviteErrItemObject*_Nonnull inviteErrItem) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"PreLiveViewController::startRequest( [请求私密邀请, %@], userId : %@, invitationId : %@, roomId : %@, errType : %d, errMsg : %@ ,chatOnlineStatus : %d, isHasOneOnOneAuth : %d, isHasBookingAuth: %d )", BOOL2SUCCESS(success), waekSelf.liveRoom.userId, invitationId, roomId, errType, errMsg, inviteErrItem.status,inviteErrItem.priv.isHasOneOnOneAuth,inviteErrItem.priv.isHasBookingAuth);
                    waekSelf.liveRoom.priv = inviteErrItem.priv;
                    if (waekSelf.exitLeftSecond > 0) {
                        // 未超时
                        if (success) {
                            // TODO:私密邀请发送成功
                            NSString *str = [NSString stringWithFormat:@"请求私密邀请成功, 等待对方确认"];
                            waekSelf.statusLabel.text = DEBUG_STRING(str);
                            waekSelf.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_INVITE_SUCCESS");

                            if (roomId.length > 0) {
                                // 有roomId直接进入
                                NSLog(@"PreLiveViewController::startRequest( [请求私密邀请成功, 有roomId直接进入私密直播间], userId : %@, roomId : %@ )", waekSelf.liveRoom.userId, roomId);
                                waekSelf.liveRoom.roomId = roomId;
                                [waekSelf startRequest];

                            } else if (invitationId.length > 0) {
                                // 更新邀请Id
                                NSLog(@"PreLiveViewController::startRequest( [请求私密邀请成功, 更新邀请Id], userId : %@, invitationId : %@ )", waekSelf.liveRoom.userId, invitationId);
                                waekSelf.inviteId = invitationId;
                            } else {
                                // 没法处理, 弹出错误提示(邀请失败)
                                NSString *str = [NSString stringWithFormat:@"请求私密邀请失败,没有inviteId或者roomId"];
                                waekSelf.statusLabel.text = DEBUG_STRING(str);
                                [waekSelf handleError:errType errMsg:errMsg onlineStatus:inviteErrItem.status];
                            }

                        } else {
                            // 弹出错误提示(邀请失败)
                            [waekSelf handleError:errType errMsg:errMsg onlineStatus:inviteErrItem.status];
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

- (void)getAdvisementList {
    WeakObject(self, waekSelf);
    // TODO:获取推荐列表
    GetPromoAnchorListRequest *request = [[GetPromoAnchorListRequest alloc] init];
    request.number = 2;
    request.type = PROMOANCHORTYPE_LIVEROOM;
    request.userId = self.liveRoom.userId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( waekSelf.status == PreLiveStatus_Error ) {
                    // 刷新推荐列表
                    waekSelf.recommandItems = array;
                    [waekSelf reloadRecommandView];
                }
            });
        }
    };
    [self.sessionManager sendRequest:request];
}

- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg onlineStatus:(IMChatOnlineStatus)onlineStatus {
    // TODO:错误处理
//    self.statusLabel.text = DEBUG_STRING(@"出错啦");
    // 改变状态为出错
    self.status = PreLiveStatus_Error;
    
    self.isOnline = onlineStatus == IMCHATONLINESTATUS_ONLINE?YES:NO;
    // 隐藏菊花
    self.loadingView.hidden = YES;
    // 隐藏VIP界面2
    self.vipView.hidden = YES;
    // 清空邀请
    self.inviteId = nil;
    
    if (errMsg.length == 0) {
        errMsg = NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP");
    }

    [self stopAllTimer];

    switch (errType) {
        case LCC_ERR_NO_CREDIT: {
            // TODO:1.没有信用点
            self.tipsLabel.text = errMsg;
            
            // 显示充点按钮
            self.addCreditButtonTop.constant = 15;
            self.addCreditButtonHeight.constant = 33;

        } break;
        case LCC_ERR_ANCHOR_PLAYING: {
            // TODO:2.主播正在私密直播中
            self.tipsLabel.text = errMsg;
            
            if (self.liveRoom.priv.isHasOneOnOneAuth) {
                self.inviteButtonTop.constant = 15;
                self.inviteButtonHeight.constant = 33;
            }
            
            // 获取推荐列表
            [self getAdvisementList];
            
        } break;
        case LCC_ERR_ANCHOR_OFFLINE: {
            // TODO:3.主播不在线
            
            self.tipsLabel.text = errMsg;

            // 显示预约按钮
            [self showBook];

        } break;
        case LCC_ERR_INVITE_NO_RESPOND: {
            // TODO:4.主播未确认,180秒超时
            self.tipsLabel.text = errMsg;
        } break;
        case LCC_ERR_INVITATION_EXPIRE:
            // TODO:5.重连获取主播邀请状态拒绝
        case LCC_ERR_INVITE_REJECT:{
            // TODO:6.主播拒绝
            self.tipsLabel.text = errMsg;
            
            // 显示预约按钮
            [self showBook];
            
        }break;
        case LCC_ERR_CONNECTFAIL: {
            // TODO:7.网络中断
            self.tipsLabel.text = errMsg;

            // 显示重试
            [self showRetry];

        } break;
        case LCC_ERR_ROOM_FULL: {
            // TODO:8.进入付费公开直播间房间满人
            
            self.tipsLabel.text = errMsg;
            // 显示立即私密
//            self.vipStartButtonTop.constant = 15;
//            self.vipStartButtonHeight.constant = 35;
            
            // 显示预约按钮
            [self showBook];
            
        }break;
        case LCC_ERR_PRIVTE_INVITE_AUTHORITY: {
            //TODO:9.主播无立即私密邀请权限
            
            self.tipsLabel.text = errMsg;
            
            self.chatNowBtn.hidden = NO;
            
            if (self.isOnline) {
                [self.chatNowBtn setImage:[UIImage imageNamed:@"Home_ChatNow"] forState:UIControlStateNormal];
            }
            else {
              [self.chatNowBtn setImage:[UIImage imageNamed:@"Home_SendＭail"] forState:UIControlStateNormal];
            }
            
        }break;
        default: {
            // TODO:普通错误提示
            self.tipsLabel.text = errMsg;
            
            // 显示预约按钮
            [self showBook];
            
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
    self.inviteForce = NO;
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
    self.countDownLabel.text = @"";
    // 显示菊花
    self.loadingView.hidden = NO;
    // 隐藏退出按钮
    self.cancelButton.hidden = YES;

    self.chatNowBtn.hidden = YES;
    // 隐藏按钮
    self.retryButtonHeight.constant = 0;

    self.vipStartButtonTop.constant = 0;
    self.vipStartButtonHeight.constant = 0;

    self.bookButtonTop.constant = 0;
    self.bookButtonHeight.constant = 0;

    self.inviteButtonTop.constant = 0;
    self.inviteButtonHeight.constant = 0;

    self.addCreditButtonTop.constant = 0;
    self.addCreditButtonHeight.constant = 0;

    self.viewProfileButtonTop.constant = 0;
    self.viewProfileButtonHeight.constant = 0;

    self.viewBoardcastButtonTop.constant = 0;
    self.viewBoardcastButtonHeight.constant = 0;
}

- (void)stopAllTimer {
    [self stopHandleTimer];
    [self stopEnterRoomTimer];
    self.cancelButton.hidden = NO;
    self.handleCountDownLabel.text = @"";
}

#pragma mark - 界面事件
- (void)handleEnterRoom:(BOOL)success errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg roomItem:(ImLiveRoomObject *)roomItem {
    // TODO:处理进入直播间
    if (self.exitLeftSecond > 0) {
        // 未超时
        if( self.status != PreLiveStatus_Error ) {
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
                [[LSUserInfoManager manager] setLiverInfoDic:item];
                
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
    if( self.isBackground ) {
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
        [LiveGobalManager manager].liveRoom = self.liveRoom;
    } else {
        // TODO:根据服务器返回的直播间类型进入
        if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_FREEPUBLICLIVEROOM) {
            // 免费公开直播间
            self.liveRoom.roomType = LiveRoomType_Public;
            [self enterPublicRoom];
            
        } else if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_CHARGEPUBLICLIVEROOM) {
            // 付费公开直播间
            self.liveRoom.roomType = LiveRoomType_Public_VIP;
            [self enterPublicVipRoom];
            
        } else if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_COMMONPRIVATELIVEROOM) {
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
            [self handleError:LCC_ERR_FAIL errMsg:NSLocalizedStringFromSelf(@"UNKNOW_ROOM_TYPE") onlineStatus:IMCHATONLINESTATUS_ONLINE];
        }
    }
}

- (void)enterPublicRoom {
    // TODO:进入免费公开直播间界面
    self.isEnterRoom = YES;
    PublicViewController *vc = [[PublicViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    [[LiveGobalManager manager] removeDelegate:self];
    self.vc = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterPublicVipRoom {
    // TODO:进入付费公开直播间界面
    self.isEnterRoom = YES;
    PublicVipViewController *vc = [[PublicVipViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    self.vc = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterPrivateRoom {
    // TODO:进入私密直播间界面
    self.isEnterRoom = YES;
    PrivateViewController *vc = [[PrivateViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    self.vc = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterPrivateVipRoom {
    // TODO:进入豪华私密直播间界面
    self.isEnterRoom = YES;
    PrivateVipViewController *vc = [[PrivateVipViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    self.vc = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterShowLiveRoom {
    // TODO:进入节目直播间
    self.isEnterRoom = YES;
    ShowLiveViewController *vc = [[ShowLiveViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    self.vc = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reloadRecommandView {
    // TODO:刷新推荐列表
    self.recommandViewHeight.constant = (self.recommandItems.count > 0) ? 130 : 0;
    self.recommandViewWidth.constant = [RecommandCollectionViewCell cellWidth] * self.recommandItems.count + ((self.recommandItems.count - 1) * 20);
    [self.recommandCollectionView reloadData];

    self.loadingView.hidden = (self.recommandItems.count > 0) ? YES : NO;
}

- (void)showRetry {
    // TODO:显示重试按钮
    self.retryButtonHeight.constant = 33;
    self.loadingView.hidden = YES;
}

- (void)showBook {
    // TODO:显示预约按钮
    if( self.liveRoom.userId.length > 0 && self.liveRoom.priv.isHasBookingAuth) {
        self.bookButtonTop.constant = 15;
        self.bookButtonHeight.constant = 35;
    }
}

- (void)showStartOneOnOne {
    // TODO:显示立即私密按钮
    if (self.liveRoom.priv.isHasOneOnOneAuth) {
        // 显示强制邀请按钮
        self.vipStartButtonTop.constant = 15;
        self.vipStartButtonHeight.constant = 33;
    }
}
#pragma mark - 点击事件
- (IBAction)close:(id)sender {
    // TODO:点击关闭界面
    NSLog(@"PreLiveViewController::close()");

    //    if (self.liveRoom.roomType == LiveRoomType_Private || self.liveRoom.roomType == LiveRoomType_Private_VIP) {
    //        // 私密直播, 发出取消请求
    //        if (self.inviteId.length) {
    //            if( self.status == PreLiveStatus_Inviting ) {
    //                self.status = PreLiveStatus_Canceling;
    //
    //                if ([self.imManager cancelPrivateLive:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull roomId) {
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    //                        // 清空邀请
    //                        self.inviteId = nil;
    //
    //                        if (success) {
    //                            // 取消成功
    //                            self.statusLabel.text = @"取消邀请成功";
    //
    //                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //
    //                        } else {
    //                            // 取消失败, 弹出错误提示
    //                            [self handleError:LCC_ERR_FAIL errMsg:@"取消邀请失败"];
    //                        }
    //
    //                    });
    //                }]) {
    //                    self.statusLabel.text = @"发送取消邀请中...";
    //
    //                } else {
    //                    // 取消失败, 弹出错误提示
    //                    [self handleError:LCC_ERR_FAIL errMsg:@"取消邀请失败"];
    //                }
    //            } else {
    //                // 未获得邀请Id, 直接退出
    //                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //            }
    //
    //        } else {
    //            // 未获得邀请Id, 直接退出
    //            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //        }
    //
    //    } else {
    //        // 公开直播, 直接退出
    //        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //    }

    // 公开直播, 直接退出
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:YES completion:nil];
}

- (IBAction)addCreditAciton:(id)sender {
    // TODO:点击充值
    // 重置参数
    [self reset];
    
    self.isAddCredit = YES;
    [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
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
    self.recommandView.hidden = YES;
    // 重置参数
    [self reset];
    
    // 开始计时
    [self stopHandleTimer];
    [self startHandleTimer];
    
    self.inviteForce = YES;
    [self startRequest];
}

- (IBAction)startVipPrivate:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:BroadcastTransitionClickStartVip eventCategory:EventCategoryTransition];
    // 重置参数
    [self reset];
    
    // 开始计时
    [self stopHandleTimer];
    [self startHandleTimer];
    
    [self startRequest];
}

- (IBAction)chatNowBtnDid:(id)sender {
    // TODO:点击进入聊天或者发信
    if (self.isOnline) {
        QNChatViewController * vc = [[QNChatViewController alloc]initWithNibName:nil bundle:nil];
        vc.womanId = self.liveRoom.userId;
        vc.photoURL = self.liveRoom.photoUrl;
        vc.firstName = self.liveRoom.userName;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        NSURL *url = [[LiveUrlHandler shareInstance] createSendmailByanchorId:self.liveRoom.userId anchorName:self.liveRoom.userName];
        [[LiveUrlHandler shareInstance] handleOpenURL:url];
    }
    
}
#pragma mark - 直播间IM通知
- (void)onRecvWaitStartOverNotice:(ImStartOverRoomObject *_Nonnull)item {
    WeakObject(self, waekSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PreLiveViewController::onRecvWaitStartOverNotice( [接收主播进入直播间通知], roomId : %@, waitStart : %@, leftSeconds : %d )", item.roomId, BOOL2YES(waekSelf.liveRoom.imLiveRoom.waitStart), item.leftSeconds);

        // 没有进入直播间才处理
        if (waekSelf.exitLeftSecond > 0) {
            // 当前直播间通知, 并且是需要等待主播进入的
            if ([item.roomId isEqualToString:waekSelf.liveRoom.roomId] && waekSelf.liveRoom.imLiveRoom.waitStart) {
                // 等待进入房间中才处理
                if (waekSelf.status == PreLiveStatus_WaitingEnterRoom) {
                    waekSelf.statusLabel.text = DEBUG_STRING(@"主播已经进入直播间, 开始倒数...");
                    waekSelf.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_BOARDCAST_ACCEPT");
                    
                    // 停止180s倒数
                    [waekSelf stopHandleTimer];
                    
                    // 更新流地址
                    [waekSelf.liveRoom reset];
                    waekSelf.liveRoom.playUrlArray = [item.playUrl copy];
                    
                    // 更新倒数时间
                    waekSelf.enterRoomLeftSecond = item.leftSeconds;

                    // 不能显示退出按钮
                    waekSelf.canShowExitButton = NO;
                    waekSelf.cancelButton.hidden = YES;

                    if (waekSelf.enterRoomLeftSecond > 0) {
                        waekSelf.status = PreLiveStatus_CountingDownForEnterRoom;
                        
                        // 开始倒数
                        [waekSelf stopEnterRoomTimer];
                        [waekSelf startEnterRoomTimer];
                        
                    } else {
                        // 马上进入直播间
                        [waekSelf enterRoom];
                    }
                }
            }
        }
    });
}

- (void)onRecvInstantInviteReplyNotice:(ImInviteReplyItemObject* _Nonnull)replyItem  {
    WeakObject(self, waekSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PreLiveViewController::onRecvInstantInviteReplyNotice( [立即私密邀请回复通知], roomId : %@, inviteId : %@, replyType : %d, isHasOneOnOneAuth: %d, isHasBookingAuth : %d)", replyItem.roomId, replyItem.inviteId, replyItem.replyType,replyItem.priv.isHasOneOnOneAuth,replyItem.priv.isHasBookingAuth);
        waekSelf.liveRoom.priv = replyItem.priv;
        // 没有进入直播间才处理
        if (waekSelf.exitLeftSecond > 0) {
            // 当前邀请通知
            if ([replyItem.inviteId isEqualToString:waekSelf.inviteId]) {
                // 邀请中才处理
                if (waekSelf.status == PreLiveStatus_Inviting) {
                    waekSelf.status = PreLiveStatus_WaitingEnterRoom;

                    if (replyItem.replyType == REPLYTYPE_AGREE) {
                        // 主播同意
                        waekSelf.statusLabel.text = DEBUG_STRING(@"主播同意私密邀请");

                        // 更新直播间Id, 发起进入直播间请求
                        waekSelf.liveRoom.roomId = replyItem.roomId;
                        [waekSelf startRequest];

                    } else if (replyItem.replyType == REPLYTYPE_REJECT) {
                        // 主播结束拒绝, 弹出提示
                        waekSelf.statusLabel.text = DEBUG_STRING(@"主播拒绝私密邀请");
                        NSString *tips = @"";
                        if(replyItem.msg.length > 0) {
                            tips = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_REJECT"), replyItem.msg];
                        } else {
                            tips = NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_NO_RESPONE");
                        }
                        [waekSelf handleError:LCC_ERR_INVITE_REJECT errMsg:tips onlineStatus:replyItem.status];
                    }

                    // 清空邀请
                    waekSelf.inviteId = nil;
                }
            }
        }

    });
}

- (void)onRecvInviteReply:(ImInviteIdItemObject *_Nonnull)item {
    NSLog(@"PreLiveViewController::onRecvInviteReply( [断线重登陆获取到的邀请状态], roomId : %@, inviteId : %@, replyType : %d )", item.roomId, item.invitationId, item.replyType);
    WeakObject(self, waekSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 没有进入直播间才处理
        if (waekSelf.exitLeftSecond > 0) {
            // 当前邀请通知
            if ([item.invitationId isEqualToString:waekSelf.inviteId]) {
                if (waekSelf.status == PreLiveStatus_Inviting) {
                    if (item.replyType == HTTPREPLYTYPE_UNCONFIRM) {
                        // 继续等待
                        
                    } else if (item.replyType == HTTPREPLYTYPE_AGREE) {
                        // 主播同意, 发起进入直播间请求
                        waekSelf.status = PreLiveStatus_WaitingEnterRoom;
                        
                        waekSelf.statusLabel.text = DEBUG_STRING(@"主播同意私密邀请");
                        
                        // 清空邀请
                        waekSelf.inviteId = nil;
                        
                        // 重新发送请求
                        [waekSelf startRequest];
                        
                    } else if (item.replyType == HTTPREPLYTYPE_REJECT) {
                        // 主播已拒绝
                        
                        // 清空邀请
                        waekSelf.inviteId = nil;
                        
                        // 显示错误提示
                        [waekSelf handleError:LCC_ERR_INVITATION_EXPIRE errMsg:NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_NO_RESPONE") onlineStatus:IMCHATONLINESTATUS_ONLINE];
                        
                    } else if (item.replyType == HTTPREPLYTYPE_CANCEL) {
                        // 邀请已经取消
                        
                        // 清空邀请
                        waekSelf.inviteId = nil;
                        
                        // 显示错误提示
                        [waekSelf handleError:LCC_ERR_INVITATION_EXPIRE errMsg:NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_NO_RESPONE") onlineStatus:IMCHATONLINESTATUS_ONLINE];
                        
                    } else {
                        // 继续等待
                    }
                }
            }
        }
    });
}

- (void)onRecvChangeVideoUrl:(NSString *_Nonnull)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString*> *_Nonnull)playUrl userId:(NSString * _Nonnull)userId{
    NSLog(@"PreLiveViewController::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@ userId:%@)", roomId, playUrl, userId);
    WeakObject(self, waekSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新流地址
        [waekSelf.liveRoom reset];
        waekSelf.liveRoom.playUrlArray = [playUrl copy];
    });

}

- (void)onRecvRoomCloseNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg priv:(ImAuthorityItemObject * _Nonnull)priv {
    NSLog(@"PreLiveViewController::onRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@, isHasOneOnOneAuth : %d, isHasBookingAuth: %d )", roomId, errType, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    WeakObject(self, waekSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:waekSelf.liveRoom.roomId]) {
            waekSelf.liveRoom.priv = priv;
            // 未进入房间并且未出现错误
            if( waekSelf.status != PreLiveStatus_EnterRoomAlready &&
               waekSelf.status != PreLiveStatus_Error
               ) {
                // 处理错误
                [waekSelf handleError:LCC_ERR_DEFAULT errMsg:NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP") onlineStatus:IMCHATONLINESTATUS_ONLINE];
                
                // 弹出直播间关闭界面
                LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
                finshController.liveRoom = waekSelf.liveRoom;
                finshController.errType = errType;
                finshController.errMsg = errmsg;
                
                [waekSelf addChildViewController:finshController];
                [waekSelf.view addSubview:finshController.view];
                [finshController.view bringSubviewToFront:waekSelf.view];
                [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(waekSelf.view);
                }];
            }
        }
    });
}

- (void)onRecvRoomKickoffNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *_Nonnull)errmsg credit:(double)credit priv:(ImAuthorityItemObject * _Nonnull)priv {
    NSLog(@"PreLiveViewController::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ credit:%f isHasOneOnOneAuth : %d, isHasBookingAuth : %d", roomId, credit, priv.isHasOneOnOneAuth,priv.isHasBookingAuth);
    WeakObject(self, waekSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:waekSelf.liveRoom.roomId]) {
            waekSelf.liveRoom.priv = priv;
            if( waekSelf.status != PreLiveStatus_EnterRoomAlready &&
               waekSelf.status != PreLiveStatus_Error
               ) {
                // 设置余额及返点信息管理器
                if (!(credit < 0)) {
                    [waekSelf.creditRebateManager setCredit:credit];
                }
                // 弹出直播间关闭界面
                LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
                finshController.liveRoom = waekSelf.liveRoom;
                finshController.errType = LCC_ERR_ROOM_LIVEKICKOFF;
                finshController.errMsg = errmsg;
                
                [waekSelf addChildViewController:finshController];
                [waekSelf.view addSubview:finshController.view];
                [finshController.view bringSubviewToFront:waekSelf.view];
                [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(waekSelf.view);
                }];
            }
        }
    });
}

#pragma mark - 倒数控制
- (void)enterRoomCountDown {
    //    NSLog(@"PreLiveViewController::countDown( enterRoomLeftSecond : %d )", self.enterRoomLeftSecond);
    WeakObject(self, waekSelf);
    self.enterRoomLeftSecond--;
    if (self.enterRoomLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 倒数完成, 停止计时器
            [waekSelf stopEnterRoomTimer];
            // 进入直播间
            [waekSelf enterRoom];
        });
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (waekSelf.enterRoomLeftSecond > 0) {
            waekSelf.countDownLabel.text = [NSString stringWithFormat:@"%d s", waekSelf.enterRoomLeftSecond];
        }
    });
}

- (void)startEnterRoomTimer {
    NSLog(@"PreLiveViewController::startEnterRoomTimer()");

    WeakObject(self, weakSelf);
    [self.enterRoomTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
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
    WeakObject(self, waekSelf);
    self.exitLeftSecond--;
    if (self.exitLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 倒数完成, 提示超时
            [waekSelf stopHandleTimer];
            
            if(self.liveRoom.roomType == LiveRoomType_Private || self.liveRoom.roomType == LiveRoomType_Private_VIP) {
                // 主动邀请超时
                [waekSelf handleError:LCC_ERR_INVITE_NO_RESPOND errMsg:NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_NO_RESPONE") onlineStatus:IMCHATONLINESTATUS_ONLINE];
            } else {
                // 其他超时
                [waekSelf handleError:LCC_ERR_INVITE_NO_RESPOND errMsg:NSLocalizedStringFromSelf(@"RECONNECTION_TIMEOUT") onlineStatus:IMCHATONLINESTATUS_ONLINE];
            }
            
            // 允许显示退出按钮
            waekSelf.cancelButton.hidden = NO;
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if( waekSelf.exitLeftSecond > 0 ) {
            NSString *str = [NSString stringWithFormat:@"%d s", waekSelf.exitLeftSecond];
            waekSelf.handleCountDownLabel.text = DEBUG_STRING(str);
        }
    });

    self.showExitBtnLeftSecond--;
    if (self.showExitBtnLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 允许显示退出按钮
            if (waekSelf.canShowExitButton) {
                waekSelf.cancelButton.hidden = NO;
            }
        });
    }
}

- (void)startHandleTimer {
    NSLog(@"PreLiveViewController::startHandleTimer()");

    WeakObject(self, weakSelf);
    [self.handleTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
        [weakSelf handleCountDown];
    }];
}

- (void)stopHandleTimer {
    NSLog(@"PreLiveViewController::stopHandleTimer()");

    [self.handleTimer stopTimer];
}

#pragma mark - 推荐逻辑
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommandItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommandCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RecommandCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    LiveRoomInfoItemObject *item = [self.recommandItems objectAtIndex:indexPath.row];
    
    [cell.imageViewLoader refreshCachedImage:cell.imageView
                                         options:SDWebImageRefreshCached
                                        imageUrl:item.photoUrl
                                placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    cell.nameLabel.text = item.nickName;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //TODO:点击推荐主播
    [[LiveModule module].analyticsManager reportActionEvent:BroadcastTransitionClickRecommend eventCategory:EventCategoryTransition];
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoomInfoItemObject *item = [self.recommandItems objectAtIndex:indexPath.row];
    listViewController.anchorId = item.userId;
    listViewController.enterRoom = 0;
    [self.navigationController pushViewController:listViewController animated:YES];
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
