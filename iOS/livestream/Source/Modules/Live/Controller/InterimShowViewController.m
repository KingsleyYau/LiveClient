//
//  InterimShowViewController.m
//  livestream
//
//  Created by Calvin on 2018/5/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "InterimShowViewController.h"
#import "LSGetShowRoomInfoRequest.h"
#import "LSImManager.h"
#import "LSImageViewLoader.h"
#import "LiveGobalManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "LiveFinshViewController.h"
#import "ShowLiveViewController.h"
#import "LSRoomUserInfoManager.h"
#import "LiveModule.h"
#import "BookPrivateBroadcastViewController.h"
#import "LSShowListWithAnchorIdRequest.h"
#import "LSAddCreditsViewController.h"
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

typedef enum ShowButtonType {
    ShowButtonType_NO,     // 全部不显示
    ShowButtonType_Reload, //显示Reload按钮
    ShowButtonType_Book, //显示预约按钮
    ShowButtonType_Add //显示购票按钮
}ShowButtonType;

// 180秒后退出界面
#define INVITE_TIMEOUT 180
// 10秒后显示退出按钮
#define CANCEL_BUTTON_TIMEOUT 10

@interface InterimShowViewController ()<IMLiveRoomManagerDelegate, IMManagerDelegate,LiveGobalManagerDelegate>

// 当前状态
@property (nonatomic, assign) PreLiveStatus status;
// IM管理器
@property (nonatomic, strong) LSImManager *imManager;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;


#pragma mark - 倒数控制
// 开播前倒数
@property (strong) LSTimer *enterRoomTimer;
// 开播前倒数剩余时间
@property (nonatomic, assign) int enterRoomLeftSecond;

#pragma mark - 头像逻辑
@property (atomic, strong) LSImageViewLoader *imageViewLoader;

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

// 个人信息管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

@property (nonatomic) BOOL isAddCredit;
#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;
@property (nonatomic, strong) UIViewController *vc;

@property (nonatomic, assign) NSTimeInterval enterRoomTimeInterval;

//  是否进入直播间
@property (nonatomic, assign) BOOL isEnterRoom;

// 是否退入后台超时
@property (nonatomic, assign) BOOL isTimeOut;

@property (nonatomic, strong) LSProgramItemObject * showItem;
#pragma mark - 总超时控制
// 总超时倒数
@property (strong) LSTimer *handleTimer;
// 总超时剩余时间
@property (nonatomic, assign) int exitLeftSecond;
// 显示退出按钮时间
@property (nonatomic, assign) int showExitBtnLeftSecond;
// 能否显示退出按钮
@property (nonatomic, assign) BOOL canShowExitButton;
@end

@implementation InterimShowViewController


- (void)dealloc {
    NSLog(@"InterimShowViewController::dealloc()");
    
    [[LiveGobalManager manager] removeDelegate:self];
    
    if (self.liveRoom.roomId.length > 0 && self.status != PreLiveStatus_EnterRoomAlready && self.status != PreLiveStatus_Error) {
        NSLog(@"leaveRoom:%@",self.liveRoom.roomId);
    }
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    // 注销前后台切换通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [self stopAllTimer];
}

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    NSLog(@"InterimShowViewController::initCustomParam()");
    
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
    
    self.roomUserInfoManager = [LSRoomUserInfoManager manager];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.imageViewLoader = [LSImageViewLoader loader];
    
    // 初始化余额及返点信息管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
    
    // 注册前后台切换通知
    _isBackground = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 初始化计时器
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

- (void)reset {
    // TODO:重置参数
    // 180秒后退出界面
    self.exitLeftSecond = INVITE_TIMEOUT;
    // 10秒后显示退出按钮
    self.showExitBtnLeftSecond = CANCEL_BUTTON_TIMEOUT;
    // 能否显示退出按钮
    self.canShowExitButton = YES;
    // 标记当前状态
    self.status = PreLiveStatus_None;
    
    self.tipsLabel.text = @"";
    
    self.isAddCredit = NO;
    self.closeBtn.hidden = YES;
    self.reloadBtn.hidden = YES;
    self.addBtn.hidden = YES;
    self.bookBtn.hidden = YES;
    self.loadingView.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reset];
    
    // 刷新女士名字
    self.nameLabel.text = @"";
    
    self.tipsLabel.text = @"";
    
    self.headImage.layer.cornerRadius = self.headImage.tx_height / 2;
    self.headImage.layer.masksToBounds = YES;
    
    self.bookBtn.layer.cornerRadius = self.bookBtn.tx_height / 2;
    self.bookBtn.layer.masksToBounds = YES;
    
    self.reloadBtn.layer.cornerRadius = self.reloadBtn.tx_height / 2;
    self.reloadBtn.layer.masksToBounds = YES;
    
    self.addBtn.layer.cornerRadius = self.addBtn.tx_height / 2;
    self.addBtn.layer.masksToBounds = YES;
    
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
        [self.roomUserInfoManager getUserInfo:self.liveRoom.userId
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    if( !self.viewDidAppearEver || self.isAddCredit ) {
        // IM登录城成功才调用
        if ([LSImManager manager].isIMLogin){
            // 发起请求
            [self getShowInfo];
        }else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 发起请求
                [self getShowInfo];
            });
        }
        [self performSelector:@selector(closeBtnShow) withObject:self afterDelay:10];
    }
    [super viewDidAppear:animated];
    // 开始计时
    [self startHandleTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 设置允许显示立即邀请
    [[LiveGobalManager manager] setCanShowInvite:YES];
    
    // 移除退入后台通知
    [[LiveGobalManager manager] removeDelegate:self];
}

- (void)closeBtnShow {
    self.closeBtn.hidden = NO;
}

#pragma mark 获取用户信息
- (void)setupLiverHeadImageView {
    [self.imageViewLoader loadImageFromCache:self.headImage
                                     options:SDWebImageRefreshCached
                                    imageUrl:self.liveRoom.photoUrl
                            placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]
                               finishHandler:^(UIImage *image){
                               }];
}

- (void)setupLiverNameLabel {
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:self.liveRoom.userName
                                                                             attributes:@{
                                                        NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                                        NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0xffffff)}];
    
    NSMutableAttributedString *anchorId = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"(ID:%@)",self.liveRoom.userId] attributes:@{
                                                            NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                            NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0x999999)}];
    [name appendAttributedString:anchorId];
    self.nameLabel.attributedText = name;
}

#pragma mark - 总超时控制
- (void)handleCountDown {

    self.exitLeftSecond--;
    if (self.exitLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 倒数完成, 提示超时
            [self stopHandleTimer];
            [self handleError:LCC_ERR_INVITE_NO_RESPOND errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
            // 允许显示退出按钮
            [self closeBtnShow];
        });
    }
  
    self.showExitBtnLeftSecond--;
    if (self.showExitBtnLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 允许显示退出按钮
            if (self.canShowExitButton) {
                [self closeBtnShow];
            }
        });
    }
}

- (void)startHandleTimer {
    NSLog(@"InterimShowViewController::startHandleTimer()");
    WeakObject(self, weakSelf);
    [self.handleTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
        [weakSelf handleCountDown];
    }];
}

- (void)stopHandleTimer {
    NSLog(@"InterimShowViewController::stopHandleTimer()");
    [self.handleTimer stopTimer];
}

- (void)stopAllTimer {
    [self stopHandleTimer];
    [self stopEnterRoomTimer];
    [self closeBtnShow];
}

#pragma mark - 倒数控制
- (void)enterRoomCountDown {
    self.enterRoomLeftSecond--;
    if (self.enterRoomLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 倒数完成, 停止计时器
            [self stopEnterRoomTimer];
            // 进入直播间
            [self pushShowRoom];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.enterRoomLeftSecond > 0) {
            NSMutableAttributedString *showTip = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"SHOW") attributes:@{
                                                            NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                            NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0xffffff)}];
            NSMutableAttributedString *showName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"SHOW_NAME"),self.liveRoom.showTitle] attributes:@{
                                                            NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                            NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0xff8500)}];
            NSMutableAttributedString *startTime = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"STAER_IN"),self.enterRoomLeftSecond] attributes:@{
                                                            NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                            NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0xffffff)}];
            [showTip appendAttributedString:showName];
            [showTip appendAttributedString:startTime];
            self.tipsLabel.attributedText = showTip;
        }
    });
}

- (void)startEnterRoomTimer {
    NSLog(@"InterimShowViewController::startEnterRoomTimer()");
    self.loadingView.hidden = YES;
    WeakObject(self, weakSelf);
    [self.enterRoomTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
        [weakSelf enterRoomCountDown];
    }];
}

- (void)stopEnterRoomTimer {
    NSLog(@"InterimShowViewController::stopEnterRoomTimer()");
    [self.enterRoomTimer stopTimer];
}

#pragma mark 获取可进入的节目信息接口
- (void)getShowInfo {
    LSGetShowRoomInfoRequest * request = [[LSGetShowRoomInfoRequest alloc]init];
    request.liveShowId = self.liveRoom.showId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSProgramItemObject * _Nullable item, NSString * _Nonnull roomId, LSHttpAuthorityItemObject *_Nonnull privItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"InterimShowViewController::getShowInfo( [获取可进入的节目信息, %@], errnum : %d, errmsg : %@, roomId : %@, leftSecToStart : %d, isHasBookingAuth : %d)", BOOL2SUCCESS(success), errnum, errmsg, roomId, item.leftSecToStart,privItem.isHasBookingAuth);
            
            ImAuthorityItemObject * obj = [[ImAuthorityItemObject alloc]init];
            obj.isHasBookingAuth = privItem.isHasBookingAuth;
            obj.isHasOneOnOneAuth = privItem.isHasOneOnOneAuth;
            self.liveRoom.priv = obj;
            if (success) {
                if (!self.liveRoom.httpLiveRoom) {
                    LiveRoomInfoItemObject *httpLiveRoom = [[LiveRoomInfoItemObject alloc]init];
                    self.liveRoom.httpLiveRoom = httpLiveRoom;
                }
                self.liveRoom.httpLiveRoom.showInfo = item;
                self.liveRoom.roomId = roomId;
                self.enterRoomLeftSecond = item.leftSecToStart;
                if (self.enterRoomLeftSecond == 0) {
                    [self pushShowRoom];
                } else {
                    self.status = PreLiveStatus_CountingDownForEnterRoom;
                    // 开始倒数
                    [self stopEnterRoomTimer];
                    [self startEnterRoomTimer];
                }
            } else {
                self.status = PreLiveStatus_Error;
                [self httpHandleError:errnum errMsg:errmsg];
            }
        });
    };
    
    [self.sessionManager sendRequest:request];
}

#pragma mark 进入节目直播间
- (void)pushShowRoom {
    
    if (self.status == PreLiveStatus_Canceling) {
        return;
    }
    BOOL bFlag = NO;
    // TODO:发起进入指定直播间
    bFlag = [self.imManager enterRoom:self.liveRoom.roomId
                        finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem, ImAuthorityItemObject *_Nonnull priv) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"InterimShowViewController::startRequest( [请求进入指定直播间, %@], errnum : %d, errmsg : %@, roomId : %@, waitStart : %@ ,isHasOneOnOneAuth : %d, isHasBookingAuth : %d)", BOOL2SUCCESS(success), errType, errMsg, self.liveRoom.roomId, BOOL2YES(roomItem.waitStart),priv.isHasOneOnOneAuth,priv.isHasBookingAuth);
                                self.liveRoom.priv = priv;
                                self.liveRoom.imLiveRoom = roomItem;
                                [self handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
                            });
                        }];
    if (!bFlag) {
        NSLog(@"InterimShowViewController::startRequest( [请求进入指定直播间失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
       [self handleError:LCC_ERR_CONNECTFAIL errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
    }
}

#pragma mark - 界面事件
- (void)handleEnterRoom:(BOOL)success errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg roomItem:(ImLiveRoomObject *)roomItem {
    // TODO:处理进入直播间
        // 未超时
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
                [self.roomUserInfoManager setLiverInfoDic:item];
                
                // 进入成功不能显示退出按钮
                self.closeBtn.hidden = YES;
                
                if (roomItem.waitStart) {
                    // 等待主播进入
                    self.status = PreLiveStatus_WaitingEnterRoom;
                    self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_TIPS_INVITE_SUCCESS");
                } else {
                    if (roomItem.leftSeconds > 0) {
                        // 更新流地址
                        [self.liveRoom reset];
                        self.liveRoom.playUrlArray = [roomItem.videoUrls copy];
                        // 更新倒数时间
                        self.enterRoomLeftSecond = roomItem.leftSeconds;
                        self.status = PreLiveStatus_CountingDownForEnterRoom;
                        // 开始倒数
                        [self stopEnterRoomTimer];
                        [self startEnterRoomTimer];
                        
                    } else {
                        self.liveRoom.userId = roomItem.userId;
                        // 马上进入直播间
                        [self enterRoom];
                    }
                    
                    // 设置余额及返点信息管理器
                    IMRebateItem *imRebateItem = [[IMRebateItem alloc] init];
                    imRebateItem.curCredit = roomItem.rebateInfo.curCredit;
                    imRebateItem.curTime = roomItem.rebateInfo.curTime;
                    imRebateItem.preCredit = roomItem.rebateInfo.preCredit;
                    imRebateItem.preTime = roomItem.rebateInfo.preTime;
                    [self.creditRebateManager setReBateItem:imRebateItem];
                    [self.creditRebateManager setCredit:roomItem.credit];
                }
            } else {
                // 请求进入失败, 进行错误处理
                [self handleError:errType errMsg:errMsg];
            }
        }
    }
}

- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    [self stopAllTimer];
    if (errMsg.length == 0) {
        errMsg = NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP");
    }
    self.tipsLabel.text = errMsg;
    [self closeBtnShow];
    self.loadingView.hidden = YES;
    self.status = PreLiveStatus_Error;
    
    switch (errType) {
        case LCC_ERR_NO_CREDIT:{
            // 没信用点
            [self setButtonType:ShowButtonType_Add];
        }break;
            
        case LCC_ERR_CONNECTFAIL:{
            // 服务器连接失败
            [self setButtonType:ShowButtonType_Reload];
        }break;
        
        case LCC_ERR_ROOM_FULL:{
            // 房间满人
            [self setButtonType:ShowButtonType_Book];
        }break;
            
        default:{
            // 默认处理
            [self setButtonType:ShowButtonType_NO];
        }break;
    }
}

- (void)httpHandleError:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    
    [self stopAllTimer];
    if (errMsg.length == 0) {
        errMsg = NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP");
    }
    self.tipsLabel.text = errMsg;
    [self closeBtnShow];
    self.loadingView.hidden = YES;
    self.status = PreLiveStatus_Error;
    
    switch (errType) {
        case HTTP_LCC_ERR_NO_CREDIT:{
            // 没信用点
            [self setButtonType:ShowButtonType_Add];
        }break;
        
        case HTTP_LCC_ERR_CONNECTFAIL:{
            // 服务器连接失败
            [self setButtonType:ShowButtonType_Reload];
        }break;
        
        case HTTP_LCC_ERR_SHOW_HAS_ENDED:
        case HTTP_LCC_ERR_SHOW_HAS_CANCELLED:
        case HTTP_LCC_ERR_ANCHOR_NOCOME_SHOW_HAS_CLOSE:
        case HTTP_LCC_ERR_NO_BUY_SHOW_HAS_CANCELLED:{
            // 节目已经结束了、节目已经取消了(已购票)、主播缺席(已购票)、节目已经取消了(未购票)
            [self setButtonType:ShowButtonType_Book];
        }break;
            
        default:{
            // 默认处理
            [self setButtonType:ShowButtonType_NO];
        }break;
    }
}

- (void)setButtonType:(ShowButtonType)type {
    if (type == ShowButtonType_Reload) {
        self.reloadBtn.hidden = NO;
        self.bookBtn.hidden = YES;
        self.addBtn.hidden = YES;
    } else if (type == ShowButtonType_Add) {
        self.reloadBtn.hidden = YES;
        self.bookBtn.hidden = YES;
        self.addBtn.hidden = NO;
    } else if (type == ShowButtonType_Book) {
        self.reloadBtn.hidden = YES;
        self.bookBtn.hidden = !self.liveRoom.priv.isHasBookingAuth;
        self.addBtn.hidden = YES;
    } else {
        self.addBtn.hidden = YES;
        self.bookBtn.hidden = YES;
        self.reloadBtn.hidden = YES;
    }
}

- (void)enterRoom {
    self.status = PreLiveStatus_EnterRoomAlready;
    // 如果在后台记录进入时间
    if( self.isBackground ) {
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
    } else {
    
        // TODO:进入节目直播间
        self.isEnterRoom = YES;
        ShowLiveViewController *vc = [[ShowLiveViewController alloc] initWithNibName:nil bundle:nil];
        vc.liveRoom = self.liveRoom;
        self.vc = vc;
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 直播间IM通知
- (void)onRecvChangeVideoUrl:(NSString *_Nonnull)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString*> *_Nonnull)playUrl userId:(NSString * _Nonnull)userId{
    NSLog(@"InterimShowViewController::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@ userId:%@)", roomId, playUrl, userId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新流地址
        [self.liveRoom reset];
        self.liveRoom.playUrlArray = [playUrl copy];
    });
}

- (void)onRecvWaitStartOverNotice:(ImStartOverRoomObject *)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"InterimShowViewController::onRecvWaitStartOverNotice( [接收主播进入直播间通知], roomId : %@ )", item.roomId);
        // 当前直播间通知, 并且是需要等待主播进入的
        if ([item.roomId isEqualToString:self.liveRoom.roomId] && self.liveRoom.imLiveRoom.waitStart) {
            // 等待进入房间中才处理
            if (self.status == PreLiveStatus_WaitingEnterRoom) {
                // 更新流地址
                [self.liveRoom reset];
                self.liveRoom.playUrlArray = [item.playUrl copy];
                // 更新倒数时间
                self.enterRoomLeftSecond = item.leftSeconds;
                // 不能显示退出按钮
                self.closeBtn.hidden = YES;
                // 停止180s倒数
                [self stopHandleTimer];
                
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
    });
}

// 如果该主播在节目开始时未进入直播间,会收到关闭的通知,不接受该回调会导致节目过渡页无法关闭,一直处于等待状态  lance add
- (void)onRecvRoomCloseNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg priv:(ImAuthorityItemObject * _Nonnull)priv {
    NSLog(@"InterimShowViewController::onRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@, isHasOneOnOneAuth : %d, isHasOneOnOneAuth: %d )", roomId, errType, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            // 未进入房间并且未出现错误
            self.liveRoom.priv = priv;
            if( self.status != PreLiveStatus_EnterRoomAlready &&
               self.status != PreLiveStatus_Error
               ) {
                // 处理错误
                [self handleError:LCC_ERR_DEFAULT errMsg:NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP")];
                
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

#pragma mark 取消按钮点击事件
- (IBAction)closeBtnDid:(UIButton *)sender {
    NSLog(@"InterimShowViewController::closeBtnDid() RoomId:%@",self.liveRoom.roomId);
    self.status = PreLiveStatus_Canceling;
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:YES completion:nil];
}

- (IBAction)bookBtnDid:(UIButton *)sender {
    
    BookPrivateBroadcastViewController * vc = [[BookPrivateBroadcastViewController alloc]initWithNibName:nil bundle:nil];
    vc.userId = self.liveRoom.userId;
    vc.userName = self.liveRoom.userName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)addBtnDid:(UIButton *)sender {
    self.isAddCredit = YES;
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)reloadBtnDid:(UIButton *)sender {
    // 重置参数
    [self reset];
    
    // 开始计时
    [self stopHandleTimer];
    [self startHandleTimer];
    
    if (self.liveRoom.roomId.length > 0) {
        [self pushShowRoom];
    } else {
        [self getShowInfo];
    }
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
                NSLog(@"InterimShowViewController::willEnterForeground ( [接收后台关闭直播间]  IsTimeOut : %@ )",(self.isTimeOut == YES) ? @"Yes" : @"No");
                
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
