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

#import "LiveModule.h"
#import "ZBLSImManager.h"
#import "LSImageViewLoader.h"
#import "LiveGobalManager.h"
#import "LiveBundle.h"
#import "UserInfoManager.h"
#import "PreInviteToHandler.h"
#import "PreRoomInHandler.h"
#import "PreAcceptHandler.h"

// 180秒后退出界面
#define INVITE_TIMEOUT 180
// 10秒后显示退出按钮
#define CANCEL_BUTTON_TIMEOUT 10

@interface PreLiveViewController () <ZBIMLiveRoomManagerDelegate, ZBIMManagerDelegate,LiveGobalManagerDelegate>
// IM管理器
@property (nonatomic, strong) ZBLSImManager *imManager;
// 上次发送返回的邀请
@property (nonatomic, strong) NSString *inviteId;

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

#pragma mark - 头像逻辑
@property (atomic, strong) LSImageViewLoader *imageViewLoader;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;
@property (nonatomic, strong) UIViewController *vc;

@property (nonatomic, assign) NSTimeInterval enterRoomTimeInterval;

//  是否进入直播间
@property (nonatomic, assign) BOOL isEnterRoom;

// 是否退入后台超时
@property (nonatomic, assign) BOOL isTimeOut;

@end

@implementation PreLiveViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PreLiveViewController::initCustomParam()");

    // 初始化管理器
    self.imManager = [ZBLSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    // 初始化后台管理器
    [[LiveGobalManager manager] addDelegate:self];

    self.imageViewLoader = [LSImageViewLoader loader];
    
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

    [[LiveGobalManager manager] removeDelegate:self];
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    // 赋值到全局变量, 用于前台计时
    [LiveGobalManager manager].liveRoom = nil;
    [LiveGobalManager manager].player = nil;
    [LiveGobalManager manager].publisher = nil;
    
    // 注销前后台切换通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 重置参数
    [self reset];
    
    // 刷新女士名字
    self.ladyNameLabel.text = @"";

    // 禁止导航栏后退手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    // 主播姓名
    self.ladyNameLabel.text = self.liveRoom.userName;
    
    // 刷新女士头像
    [self.imageViewLoader refreshCachedImage:self.ladyImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
//    if ( self.liveRoom.photoUrl.length > 0 ) {
//        [self.imageViewLoader refreshCachedImage:self.ladyImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
//    } else {
        // 请求并缓存主播信息
//        WeakObject(self, weakSelf);
//        [[UserInfoManager manager] getUserInfo:self.liveRoom.userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // 刷新女士头像
//                weakSelf.liveRoom.photoUrl = item.photoUrl;
//                [weakSelf.imageViewLoader refreshCachedImage:self.ladyImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
//                // 刷新女士名字
//                weakSelf.liveRoom.userName = item.nickName;
//                weakSelf.ladyNameLabel.text = item.nickName;
//            });
//        }];
//    }
    
    // 清除浮窗
    [[LiveModule module].notificationVC.view removeFromSuperview];
    [[LiveModule module].notificationVC removeFromParentViewController];
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
    // 开始计时
    [self startHandleTimer];
    
    // 发起请求
    [self startRequest];
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 停止计时
    [self stopAllTimer];
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化主播头像
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.frame.size.width / 2;
    self.ladyImageView.layer.masksToBounds = YES;
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

#pragma mark - 数据逻辑
- (void)startRequest {
    BOOL bFlag = NO;

    if (self.liveRoom.roomId.length > 0) {
        NSLog(@"PreLiveViewController::startRequest( [请求进入指定直播间], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
        NSString *str = [NSString stringWithFormat:@"请求进入指定直播间(roomId : %@)...", self.liveRoom.roomId];
        self.statusLabel.text = DEBUG_STRING(str);

        // TODO:发起进入指定直播间
//        bFlag = [self.imManager enterRoom:self.liveRoom.roomId
//                            finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem) {
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    NSLog(@"PreLiveViewController::startRequest( [请求进入指定直播间, %@], roomId : %@, waitStart : %@ )", BOOL2SUCCESS(success), self.liveRoom.roomId, BOOL2YES(roomItem.waitStart));
//
//                                    [self handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
//                                });
//                            }];
        if (!bFlag) {
            NSLog(@"PreLiveViewController::startRequest( [请求进入指定直播间失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
            self.statusLabel.text = DEBUG_STRING(@"请求进入指定直播间失败");
            [self handleError:ZBLCC_ERR_CONNECTFAIL errMsg:@""];
        }

    } else {
        if (self.liveRoom.roomType == LiveRoomType_Public || self.liveRoom.roomType == LiveRoomType_Public_VIP) {
            NSLog(@"PreLiveViewController::startRequest( [请求进入公开直播间], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
            NSString *str = [NSString stringWithFormat:@"请求进入公开直播间(userId : %@)...", self.liveRoom.userId];
            self.statusLabel.text = DEBUG_STRING(str);

            // TODO:发起进入公开直播间
//            bFlag = [self.imManager enterPublicRoom:self.liveRoom.userId
//                                      finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem) {
//                                          dispatch_async(dispatch_get_main_queue(), ^{
//                                              NSLog(@"PreLiveViewController::startRequest( [请求进入公开直播间, %@], roomId : %@, waitStart : %@, errMsg : %@ )",
//                                                    BOOL2SUCCESS(success), roomItem.roomId, BOOL2YES(roomItem.waitStart), errMsg);
//
//                                              [self handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
//                                          });
//                                      }];

            if (!bFlag) {
                NSLog(@"PreLiveViewController::startRequest( [请求进入公开直播间失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
                self.statusLabel.text = DEBUG_STRING(@"请求进入公开直播间失败");
                [self handleError:ZBLCC_ERR_CONNECTFAIL errMsg:@""];
            }

        } else {
            NSLog(@"PreLiveViewController::startRequest( [请求私密邀请], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
            self.statusLabel.text = DEBUG_STRING([NSString stringWithFormat:@"请求私密邀请..."]);
            self.status = PreLiveStatus_Inviting;

            // TODO:发起私密直播邀请
//            bFlag = [self.imManager invitePrivateLive:self.liveRoom.userId
//                                                logId:@""
//                                                force:self.inviteForce
//                                        finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull invitationId, int timeout, NSString *_Nonnull roomId) {
//                                            dispatch_async(dispatch_get_main_queue(), ^{
//                                                NSLog(@"PreLiveViewController::startRequest( [请求私密邀请, %@], userId : %@, invitationId : %@, roomId : %@, errType : %d, errMsg : %@ )", BOOL2SUCCESS(success), self.liveRoom.userId, invitationId, roomId, errType, errMsg);
//                                                if (self.exitLeftSecond > 0) {
//                                                    // 未超时
//                                                    if (success) {
//                                                        // TODO:私密邀请发送成功
//                                                        self.statusLabel.text = DEBUG_STRING([NSString stringWithFormat:@"请求私密邀请成功, 等待对方确认..."]);
//                                                        self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_INVITE_SUCCESS");
//
//                                                        if (roomId.length > 0) {
//                                                            // 有roomId直接进入
//                                                            NSLog(@"PreLiveViewController::startRequest( [请求私密邀请成功, 有roomId直接进入私密直播间], userId : %@, roomId : %@ )", self.liveRoom.userId, roomId);
//                                                            self.liveRoom.roomId = roomId;
//                                                            [self startRequest];
//
//                                                        } else if (invitationId.length > 0) {
//                                                            // 更新邀请Id
//                                                            NSLog(@"PreLiveViewController::startRequest( [请求私密邀请成功, 更新邀请Id], userId : %@, invitationId : %@ )", self.liveRoom.userId, invitationId);
//                                                            self.inviteId = invitationId;
//                                                        } else {
//                                                            // 没法处理, 弹出错误提示(邀请失败)
//                                                            self.statusLabel.text = DEBUG_STRING(@"没有inviteId或者roomId");
//                                                            [self handleError:errType errMsg:errMsg];
//                                                        }
//
//                                                    } else {
//                                                        if (!self.inviteForce) {
//                                                            // 未发送过强制邀请
//                                                            if (errType == LCC_ERR_ANCHOR_PLAYING) {
//                                                                // 主播正在私密直播中
//
//                                                                // 弹出选择对话框
//                                                                self.statusLabel.text = DEBUG_STRING(@"主播正在直播中");
//                                                                [self handleError:errType errMsg:errMsg];
//
//                                                            } else {
//                                                                // 弹出错误提示(邀请失败)
//                                                                [self handleError:errType errMsg:errMsg];
//                                                            }
//
//                                                        } else {
//                                                            // 弹出错误提示(邀请失败)
//                                                            [self handleError:errType errMsg:errMsg];
//                                                        }
//                                                    }
//                                                }
//
//                                            });
//                                        }];

            if (!bFlag) {
                NSLog(@"PreLiveViewController::startRequest( [请求私密邀请失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
                self.statusLabel.text = DEBUG_STRING(@"请求私密邀请失败");
//                [self handleError:LCC_ERR_INVITE_FAIL errMsg:@""];
            }
        }
    }
}


- (void)handleError:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    // TODO:错误处理
//    self.statusLabel.text = DEBUG_STRING(@"出错啦");
    // 改变状态为出错
    self.status = PreLiveStatus_Error;
    // 隐藏菊花
    self.loadingView.hidden = YES;
    // 清空邀请
    self.inviteId = nil;

    [self stopAllTimer];

//    switch (errType) {
//        case LCC_ERR_NO_CREDIT: {
//            // TODO:1.没有信用点
//            self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_ERR_ADD_CREDIT");
//
//            // 显示充点按钮
//            self.addCreditButtonTop.constant = 15;
//            self.addCreditButtonHeight.constant = 33;
//
//        } break;
//        case LCC_ERR_ANCHOR_PLAYING: {
//            // TODO:2.主播正在私密直播中
//            self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_ERR_BOARDCAST_LIVING");
//
//            // 显示强制邀请按钮
//            self.inviteButtonTop.constant = 15;
//            self.inviteButtonHeight.constant = 33;
//
//            // 获取推荐列表
//            [self getAdvisementList];
//
//        } break;
//        case LCC_ERR_ANCHOR_OFFLINE: {
//            // TODO:3.主播不在线
//
//            NSString *tips = @"";
//            if(errMsg.length > 0) {
//                tips = [NSString stringWithFormat:@"%@", errMsg];
//            } else {
//                tips = NSLocalizedStringFromSelf(@"PRELIVE_ERR_BOARDCAST_OFFLINE");
//            }
//            self.tipsLabel.text = tips;
//
//            // 显示预约按钮
//            [self showBook];
//
//        } break;
//        case LCC_ERR_INVITE_NO_RESPOND: {
//            // TODO:4.主播未确认,180秒超时
//            self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_NO_RESPONE");
//
//            // 显示预约按钮
//            [self showBook];
//
//        } break;
//        case LCC_ERR_INVITE_FAIL: {
//            // TODO:5.发送邀请失败
//            self.tipsLabel.text = NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT");//NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_FAIL");
//
//            // 显示重试
//            [self showRetry];
//
//        } break;
//        // TODO:6.重连获取主播邀请状态拒绝
//        case LCC_ERR_INVITATION_EXPIRE:
//        case LCC_ERR_INVITE_REJECT:{
//            // TODO:7.主播拒绝
//            NSString *tips = @"";
//            if(errMsg.length > 0) {
//                tips = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_REJECT"), errMsg];
//            } else {
//                tips = NSLocalizedStringFromSelf(@"PRELIVE_ERR_INVITE_NO_RESPONE");
//            }
//
//            self.tipsLabel.text = tips;
//
//            // 显示预约按钮
//            [self showBook];
//
//        }break;
//        case LCC_ERR_CONNECTFAIL: {
//            // TODO:8.网络中断
//            self.tipsLabel.text = NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT");
//
//            // 显示重试
//            [self showRetry];
//
//        } break;
//        case LCC_ERR_ROOM_FULL: {
//            // 进入付费公开直播间房间满人
//
//            self.tipsLabel.text = NSLocalizedStringFromSelf(@"LIVE_ROOM_FULL");
//            // 显示立即私密
//            self.vipStartButtonTop.constant = 15;
//            self.vipStartButtonTop.constant = 35;
//
//            // 显示预约按钮
//            [self showBook];
//
//        }break;
//        default: {
//            // TODO:9.普通错误提示
//            NSString *tip = @"";
//            if (errMsg.length > 0) {
//                tip = errMsg;
//            } else {
//                tip = NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP");
//            }
//            self.tipsLabel.text = tip;
//
//            // 显示预约按钮
//            [self showBook];
//
//        } break;
//    }
}

- (void)reset {
    // TODO:重置参数
    // 180秒后退出界面
    self.exitLeftSecond = INVITE_TIMEOUT;
    // 10秒后显示退出按钮
    self.showExitBtnLeftSecond = CANCEL_BUTTON_TIMEOUT;
    // 能否显示退出按钮
    self.canShowExitButton = YES;
    // 清空邀请Id
    self.inviteId = nil;
    // 清空roomId
//    self.liveRoom.roomId = nil;
    // 标记当前状态
    self.status = PreLiveStatus_None;

    // 还原状态提示
    self.tipsLabel.text = @"";
    self.statusLabel.text = @"";
    self.handleCountDownLabel.text = @"";
    self.countDownLabel.text = @"";
    // 显示菊花
    self.loadingView.hidden = NO;
    // 隐藏退出按钮
    self.cancelButton.hidden = YES;

    // 隐藏按钮
    self.retryButtonHeight.constant = 0;
    self.closeButtonHeight.constant = 0;
}

- (void)stopAllTimer {
    [self stopHandleTimer];
    [self stopEnterRoomTimer];
    self.cancelButton.hidden = NO;
    self.handleCountDownLabel.text = @"";
}

#pragma mark - 界面事件
- (void)handleEnterRoom:(BOOL)success errType:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errMsg roomItem:(ZBImLiveRoomObject *)roomItem {
    // TODO:处理进入直播间
    if (self.exitLeftSecond > 0) {
        // 未超时
        if( self.status != PreLiveStatus_Error ) {
            if (success) {
                // 请求进入成功
                // 更新本地登录信息
                self.liveRoom.imLiveRoom = roomItem;
        
                // 进入成功不能显示退出按钮
                self.canShowExitButton = NO;
                self.cancelButton.hidden = YES;
                
//                if (roomItem.waitStart) {
//                    // 等待主播进入
//                    self.statusLabel.text = DEBUG_STRING(@"等待主播进入直播间...");
//                    self.status = PreLiveStatus_WaitingEnterRoom;
//                    self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_INVITE_SUCCESS");
//
//                } else {
//                    self.statusLabel.text = DEBUG_STRING([NSString stringWithFormat:@"进入直播间成功, 准备跳转..."]);
//                    if (roomItem.leftSeconds > 0) {
//                        self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_BOARDCAST_ACCEPT");
//
//                        // 停止180s倒数
//                        [self stopHandleTimer];
//
//                        // 更新流地址
//                        [self.liveRoom reset];
//                        self.liveRoom.playUrlArray = [roomItem.videoUrls copy];
//
//                        // 更新倒数时间
//                        self.enterRoomLeftSecond = roomItem.leftSeconds;
//
//                        if (self.enterRoomLeftSecond > 0) {
//                            self.status = PreLiveStatus_CountingDownForEnterRoom;
//
//                            // 开始倒数
//                            [self stopEnterRoomTimer];
//                            [self startEnterRoomTimer];
//                        }
//                    } else {
//                        self.liveRoom.userId = roomItem.userId;
//                        // 马上进入直播间
//                        [self enterRoom];
//
//                    }
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        // 马上进入直播间
//                        [self enterRoom];
//                    });
//                }
                
            } else {
                // 请求进入失败, 进行错误处理
                self.statusLabel.text = DEBUG_STRING([NSString stringWithFormat:@"进入直播间失败"]);
                [self handleError:errType errMsg:errMsg];
            }
        }
    }
}

- (void)enterRoom {
//    self.status = PreLiveStatus_EnterRoomAlready;
    // 如果在后台记录进入时间
    if( self.isBackground ) {
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
        [LiveGobalManager manager].liveRoom = self.liveRoom;
    } else {
        // TODO:根据服务器返回的直播间类型进入
//        if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_FREEPUBLICLIVEROOM) {
//            // 免费公开直播间
//            self.liveRoom.roomType = LiveRoomType_Public;
//            [self enterPublicRoom];
//
//        } else if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_CHARGEPUBLICLIVEROOM) {
//            // 付费公开直播间
//            self.liveRoom.roomType = LiveRoomType_Public_VIP;
//            [self enterPublicVipRoom];
//
//        } else if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_COMMONPRIVATELIVEROOM) {
//            // 普通私密直播间
//            //        self.liveRoom.roomType = LiveRoomType_Private;
//            //        [self enterPrivateRoom];
//            self.liveRoom.roomType = LiveRoomType_Private_VIP;
//            [self enterPrivateVipRoom];
//
//        } else if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_LUXURYPRIVATELIVEROOM) {
//            // 豪华私密直播间
//            self.liveRoom.roomType = LiveRoomType_Private_VIP;
//            [self enterPrivateVipRoom];
//        } else {
//            [self handleError:LCC_ERR_FAIL errMsg:NSLocalizedStringFromSelf(@"UNKNOW_ROOM_TYPE")];
//        }
    }
}

- (void)enterPublicRoom {
    // TODO:进入免费公开直播间界面
    self.isEnterRoom = YES;
    PublicViewController *vc = [[PublicViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
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



- (void)showRetry {
    // TODO:显示重试按钮
    self.retryButtonHeight.constant = 35;
    self.loadingView.hidden = YES;
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

    if (self.liveRoom.roomType == LiveRoomType_Private || self.liveRoom.roomType == LiveRoomType_Private_VIP) {
        if (self.inviteId.length) {
//            [self.imManager cancelPrivateLive:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull roomId) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                               });
//            }];
        }
    }

    // 清空邀请
    self.inviteId = nil;

    // 公开直播, 直接退出
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark - 直播间IM通知
//- (void)onRecvWaitStartOverNotice:(ImStartOverRoomObject *_Nonnull)item {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"PreLiveViewController::onRecvWaitStartOverNotice( [接收主播进入直播间通知], roomId : %@, waitStart : %@, leftSeconds : %d )", item.roomId, BOOL2YES(self.liveRoom.imLiveRoom.waitStart), item.leftSeconds);
//
//        // 没有进入直播间才处理
//        if (self.exitLeftSecond > 0) {
//            // 当前直播间通知, 并且是需要等待主播进入的
//            if ([item.roomId isEqualToString:self.liveRoom.roomId] && self.liveRoom.imLiveRoom.waitStart) {
//                // 等待进入房间中才处理
//                if (self.status == PreLiveStatus_WaitingEnterRoom) {
//                    self.statusLabel.text = DEBUG_STRING(@"主播已经进入直播间, 开始倒数...");
//                    self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_BOARDCAST_ACCEPT");
//
//                    // 停止180s倒数
//                    [self stopHandleTimer];
//
//                    // 更新流地址
//                    [self.liveRoom reset];
//                    self.liveRoom.playUrlArray = [item.playUrl copy];
//
//                    // 更新倒数时间
//                    self.enterRoomLeftSecond = item.leftSeconds;
//
//                    // 不能显示退出按钮
//                    self.canShowExitButton = NO;
//                    self.cancelButton.hidden = YES;
//
//                    if (self.enterRoomLeftSecond > 0) {
//                        self.status = PreLiveStatus_CountingDownForEnterRoom;
//
//                        // 开始倒数
//                        [self stopEnterRoomTimer];
//                        [self startEnterRoomTimer];
//
//                    } else {
//                        // 马上进入直播间
//                        [self enterRoom];
//                    }
//                }
//            }
//        }
//    });
//}
//
//- (void)onRecvInstantInviteReplyNotice:(NSString *_Nonnull)inviteId replyType:(ReplyType)replyType roomId:(NSString *_Nonnull)roomId roomType:(RoomType)roomType anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"PreLiveViewController::onRecvInstantInviteReplyNotice( [立即私密邀请回复通知], roomId : %@, inviteId : %@, replyType : %d )", roomId, inviteId, replyType);
//
//        // 没有进入直播间才处理
//        if (self.exitLeftSecond > 0) {
//            // 当前邀请通知
//            if ([inviteId isEqualToString:self.inviteId]) {
//                // 邀请中才处理
//                if (self.status == PreLiveStatus_Inviting) {
//                    self.status = PreLiveStatus_WaitingEnterRoom;
//
//                    if (replyType == REPLYTYPE_AGREE) {
//                        // 主播同意
//                        self.statusLabel.text = DEBUG_STRING(@"主播同意私密邀请");
//
//                        // 更新直播间Id, 发起进入直播间请求
//                        self.liveRoom.roomId = roomId;
//                        [self startRequest];
//
//                    } else if (replyType == REPLYTYPE_REJECT) {
//                        // 主播结束拒绝, 弹出提示
//                        self.statusLabel.text = DEBUG_STRING(@"主播拒绝私密邀请");
//                        [self handleError:LCC_ERR_INVITE_REJECT errMsg:msg];
//                    }
//
//                    // 清空邀请
//                    self.inviteId = nil;
//                }
//            }
//        }
//
//    });
//}
//
//- (void)onRecvInviteReply:(ImInviteIdItemObject *_Nonnull)item {
//    NSLog(@"PreLiveViewController::onRecvInviteReply( [断线重登陆获取到的邀请状态], roomId : %@, inviteId : %@, replyType : %d )", item.roomId, item.invitationId, item.replyType);
//
//    // 没有进入直播间才处理
//    if (self.exitLeftSecond > 0) {
//        // 当前邀请通知
//        if ([item.invitationId isEqualToString:self.inviteId]) {
//            if (self.status == PreLiveStatus_Inviting) {
//                if (item.replyType == HTTPREPLYTYPE_UNCONFIRM) {
//                    // 继续等待
//
//                } else if (item.replyType == HTTPREPLYTYPE_AGREE) {
//                    // 主播同意, 发起进入直播间请求
//                    self.status = PreLiveStatus_WaitingEnterRoom;
//
//                    self.statusLabel.text = DEBUG_STRING(@"主播同意私密邀请");
//
//                    // 清空邀请
//                    self.inviteId = nil;
//
//                    // 重新发送请求
//                    [self startRequest];
//
//                } else if (item.replyType == HTTPREPLYTYPE_REJECT) {
//                    // 主播结束拒绝
//
//                    // 清空邀请
//                    self.inviteId = nil;
//
//                    // 显示错误提示
//                    [self handleError:LCC_ERR_INVITATION_EXPIRE errMsg:@""];
//
//                } else if (item.replyType == HTTPREPLYTYPE_CANCEL) {
//                    // 邀请已经取消
//
//                    // 清空邀请
//                    self.inviteId = nil;
//
//                    // 显示错误提示
//                    [self handleError:LCC_ERR_INVITATION_EXPIRE errMsg:@""];
//
//                } else {
//                    // 继续等待
//                }
//            }
//        }
//    }
//}
//
//- (void)onRecvChangeVideoUrl:(NSString *_Nonnull)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString*> *_Nonnull)playUrl {
//    NSLog(@"PreLiveViewController::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@ )", roomId, playUrl);
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        // 更新流地址
//        [self.liveRoom reset];
//        self.liveRoom.playUrlArray = [playUrl copy];
//    });
//
//}
//
//- (void)onRecvRoomCloseNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
//    NSLog(@"PreLiveViewController::onRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@ )", roomId, errType, errmsg);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([roomId isEqualToString:self.liveRoom.roomId]) {
//            // 未进入房间并且未出现错误
//            if( self.status != PreLiveStatus_EnterRoomAlready &&
//               self.status != PreLiveStatus_Error
//               ) {
//                // 处理错误
//                [self handleError:LCC_ERR_DEFAULT errMsg:@""];
//
//                // 弹出直播间关闭界面
//                LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
//                finshController.liveRoom = self.liveRoom;
//                finshController.errType = errType;
//                finshController.errMsg = errmsg;
//
//                [self addChildViewController:finshController];
//                [self.view addSubview:finshController.view];
//                [finshController.view bringSubviewToFront:self.view];
//                [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.edges.equalTo(self.view);
//                }];
//            }
//        }
//    });
//}
//
//- (void)onRecvRoomKickoffNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *_Nonnull)errmsg credit:(double)credit {
//    NSLog(@"PreLiveViewController::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ credit:%f", roomId, credit);
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        if ([roomId isEqualToString:self.liveRoom.roomId]) {
//
//            if( self.status != PreLiveStatus_EnterRoomAlready &&
//               self.status != PreLiveStatus_Error
//               ) {
//                // 设置余额及返点信息管理器
//                if (!(credit < 0)) {
//                    [self.creditRebateManager setCredit:credit];
//                }
//                // 弹出直播间关闭界面
//                LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
//                finshController.liveRoom = self.liveRoom;
//                finshController.errType = LCC_ERR_ROOM_LIVEKICKOFF;
//                finshController.errMsg = errmsg;
//
//                [self addChildViewController:finshController];
//                [self.view addSubview:finshController.view];
//                [finshController.view bringSubviewToFront:self.view];
//                [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.edges.equalTo(self.view);
//                }];
//            }
//        }
//    });
//}

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
            self.countDownLabel.text = [NSString stringWithFormat:@"%d s", self.enterRoomLeftSecond];
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

    self.exitLeftSecond--;
    if (self.exitLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 倒数完成, 提示超时
            [self stopHandleTimer];
//            [self handleError:LCC_ERR_INVITE_NO_RESPOND errMsg:@""];
            // 允许显示退出按钮
            self.cancelButton.hidden = NO;
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if( self.exitLeftSecond > 0 ) {
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
    [self.handleTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
        [weakSelf handleCountDown];
    }];
}

- (void)stopHandleTimer {
    NSLog(@"PreLiveViewController::stopHandleTimer()");

    [self.handleTimer stopTimer];
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    if( _isBackground == NO ) {
        _isBackground = YES;
        
        // 如果已经进入直播间成功, 更新切换后台时间
//        if( self.status == PreLiveStatus_EnterRoomAlready ) {
//            [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
//            [LiveGobalManager manager].liveRoom = self.liveRoom;
//        } else {
//            [LiveGobalManager manager].enterRoomBackgroundTime = nil;
//        }
        
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if( _isBackground == YES ) {
        _isBackground = NO;
        
//        if ( self.enterRoomTimeInterval < BACKGROUND_TIMEOUT && !self.enterRoomLeftSecond
//            && self.status == PreLiveStatus_EnterRoomAlready && !self.isEnterRoom ) {
//            [self enterRoom];
//        }
        
        if (self.isTimeOut) {
            // 退出直播间
            [self.navigationController popToRootViewControllerAnimated:NO];
            if (self.liveRoom) {
                NSLog(@"PreLiveViewController::willEnterForeground ( [接收后台关闭直播间]  IsTimeOut : %@ )",(self.isTimeOut == YES) ? @"Yes" : @"No");
                
                // 弹出直播间关闭界面
                LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
                finshController.liveRoom = self.liveRoom;
//                finshController.errType = LCC_ERR_BACKGROUND_TIMEOUT;
                
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
    
//    if( self.status == PreLiveStatus_EnterRoomAlready ) {
//        self.status = PreLiveStatus_Error;
//
//        // 已超时
//        self.isTimeOut = YES;
//    }
}

@end
