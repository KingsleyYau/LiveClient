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
#import "UserInfoManager.h"
#import "LiveModule.h"
#import "BookPrivateBroadcastViewController.h"
#import "LSShowListWithAnchorIdRequest.h"
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
    ShowButtonType_Reload, //显示Reload按钮
    ShowButtonType_Book, //显示预约按钮
    ShowButtonType_Add //显示购票按钮
}ShowButtonType;

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

@end

@implementation InterimShowViewController


- (void)dealloc {
    NSLog(@"InterimShowViewController::dealloc()");
    
    [[LiveGobalManager manager] removeDelegate:self];
    
    if (self.liveRoom.roomId.length > 0 && self.status != PreLiveStatus_EnterRoomAlready && self.status != PreLiveStatus_Error) {
        NSLog(@"leaveRoom:%@",self.liveRoom.roomId);
        [self.imManager leaveRoom:self.liveRoom.roomId];
    }
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    // 赋值到全局变量, 用于前台计时
    [LiveGobalManager manager].liveRoom = nil;
    
    // 注销前后台切换通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    NSLog(@"InterimShowViewController::initCustomParam()");
    
    // 初始化管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    // 初始化后台管理器
    [[LiveGobalManager manager] addDelegate:self];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.imageViewLoader = [LSImageViewLoader loader];
    
    // 初始化余额及返点信息管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
    
    // 注册前后台切换通知
    _isBackground = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 刷新女士名字
    self.nameLabel.text = @"";
    
    self.tipsLabel.text = @"";
    
    // 禁止导航栏后退手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    self.headImage.layer.cornerRadius = self.headImage.frame.size.height/2;
    self.headImage.layer.masksToBounds = YES;
    
    //获取用户信息
    [self getUserInfo];
    
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
    
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    if( !self.viewDidAppearEver || self.isAddCredit ) {
        self.isAddCredit = NO;
        self.closeBtn.hidden = YES;
        self.reloadBtn.hidden = YES;
        self.addBtn.hidden = YES;
        self.bookBtn.hidden = YES;
        self.tipsLabel.text = @"";
        self.loading.hidden = NO;
        [self getShowInfo];
        [self performSelector:@selector(closeBtnShow) withObject:self afterDelay:10];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeBtnShow
{
    self.closeBtn.hidden = NO;
}

#pragma mark 获取用户信息
- (void)getUserInfo {
    // 刷新女士名字
    if ( self.liveRoom.userName.length > 0 ) {
        self.nameLabel.text = self.liveRoom.userName;
    }
    
    // 刷新女士头像
    if ( self.liveRoom.photoUrl.length > 0 ) {
        [self.imageViewLoader refreshCachedImage:self.headImage options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    } else {
        // 请求并缓存主播信息
        if (self.liveRoom.userId.length > 0) {
            WeakObject(self, weakSelf);
            [[UserInfoManager manager] getUserInfo:self.liveRoom.userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 刷新女士头像
                    weakSelf.liveRoom.photoUrl = item.photoUrl;
                    [weakSelf.imageViewLoader refreshCachedImage:self.headImage options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
                    // 刷新女士名字
                    weakSelf.liveRoom.userName = item.nickName;
                    weakSelf.nameLabel.text = item.nickName;
                });
            }];
        }
    }
}
#pragma mark 获取可进入的节目信息接口
- (void)getShowInfo {
    self.loading.transform = CGAffineTransformMakeScale(2, 2) ;
    LSGetShowRoomInfoRequest * request = [[LSGetShowRoomInfoRequest alloc]init];
    request.liveShowId = self.liveRoom.showId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSProgramItemObject * _Nullable item, NSString * _Nonnull roomId)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loading.hidden = YES;
            NSLog(@"InterimShowViewController::getShowInfo( [请求进入指定直播间, %@], roomId : %@, leftSecToStart : %d )", BOOL2SUCCESS(success), roomId, item.leftSecToStart);
            if (success) {
                if (!self.liveRoom.httpLiveRoom) {
                    LiveRoomInfoItemObject *httpLiveRoom = [[LiveRoomInfoItemObject alloc]init];
                    self.liveRoom.httpLiveRoom = httpLiveRoom;
                }
                self.liveRoom.httpLiveRoom.showInfo = item;
                self.liveRoom.roomId = roomId;
                self.enterRoomLeftSecond = item.leftSecToStart;
                if (self.nameLabel.text.length == 0) {
                    [self getUserInfo];
                }
                if (self.enterRoomLeftSecond == 0) {
                    [self pushShowRoom];
                }
                else
                {
                    self.status = PreLiveStatus_CountingDownForEnterRoom;
                    
                    // 开始倒数
                    [self stopEnterRoomTimer];
                    [self startEnterRoomTimer];
                }
            }
            else
            {
                self.closeBtn.hidden = NO;
                self.status = PreLiveStatus_Error;
                if (errnum == HTTP_LCC_ERR_CONNECTFAIL) {
                    [self setButtonType:ShowButtonType_Reload];
                    [self handleError:LCC_ERR_CONNECTFAIL errMsg:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
                }
                else
                {
                    [self setButtonType:ShowButtonType_Book];
                    self.tipsLabel.text = errmsg;
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
            [self pushShowRoom];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.enterRoomLeftSecond > 0) {
            self.tipsLabel.text = [NSString stringWithFormat:@"Show \"%@\" is starting in %ds. Please wait.",self.liveRoom.showTitle,self.enterRoomLeftSecond];
        }
    });
}

- (void)startEnterRoomTimer {
    NSLog(@"InterimShowViewController::startEnterRoomTimer()");
    
    WeakObject(self, weakSelf);
    [self.enterRoomTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
        [weakSelf enterRoomCountDown];
    }];
}

- (void)stopEnterRoomTimer {
    NSLog(@"InterimShowViewController::stopEnterRoomTimer()");
    
    [self.enterRoomTimer stopTimer];
}

#pragma mark 取消按钮点击事件
- (IBAction)closeBtnDid:(UIButton *)sender {
    NSLog(@"InterimShowViewController::closeBtnDid() RoomId:%@",self.liveRoom.roomId);
    self.status = PreLiveStatus_Canceling;
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismiss:nvc.flag animated:YES completion:nil];
}

- (IBAction)bookBtnDid:(UIButton *)sender {
    
    BookPrivateBroadcastViewController * vc = [[BookPrivateBroadcastViewController alloc]initWithNibName:nil bundle:nil];
    vc.userId = self.liveRoom.userId;
    vc.userName = self.liveRoom.userName;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)addBtnDid:(UIButton *)sender {
    self.isAddCredit = YES;
    [self.navigationController pushViewController:[LiveModule module].addCreditVc animated:YES];
}

- (IBAction)reloadBtnDid:(UIButton *)sender {
     [self getUserInfo];
     [self getShowInfo];
}

#pragma mark 进入节目直播间
- (void)pushShowRoom {
    
    if (self.status == PreLiveStatus_Canceling) {
        return;
    }
    BOOL bFlag = NO;
    // TODO:发起进入指定直播间
    bFlag = [self.imManager enterRoom:self.liveRoom.roomId
                        finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"InterimShowViewController::startRequest( [请求进入指定直播间, %@], showId : %@, waitStart : %@ )", BOOL2SUCCESS(success), self.liveRoom.showId, BOOL2YES(roomItem.waitStart));
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
                [[UserInfoManager manager] setLiverInfoDic:item];
                
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
        }else {
           [self handleError:errType errMsg:errMsg];
        }
}

- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    
    self.tipsLabel.text = errMsg;
    self.closeBtn.hidden = NO;
    self.status = PreLiveStatus_Error;
    if (errType == LCC_ERR_NO_CREDIT) {
        [self setButtonType:ShowButtonType_Add];
    }
    else if (errType == LCC_ERR_CONNECTFAIL)
    {
        [self setButtonType:ShowButtonType_Reload];
    }
    else
    {
        [self setButtonType:ShowButtonType_Book];
    }
}

- (void)setButtonType:(ShowButtonType)type
{
    if (type == ShowButtonType_Reload) {
        self.reloadBtn.hidden = NO;
        self.bookBtn.hidden = YES;
        self.addBtn.hidden = YES;
    }else if (type == ShowButtonType_Add) {
        self.reloadBtn.hidden = YES;
        self.bookBtn.hidden = YES;
        self.addBtn.hidden = NO;
    }
    else
    {
        self.reloadBtn.hidden = YES;
        self.bookBtn.hidden = NO;
        self.addBtn.hidden = YES;
    }
}

- (void)enterRoom {
    self.status = PreLiveStatus_EnterRoomAlready;
    // 如果在后台记录进入时间
    if( self.isBackground ) {
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
        [LiveGobalManager manager].liveRoom = self.liveRoom;
    } else {
    
        // TODO:进入节目直播间
        self.isEnterRoom = YES;
        ShowLiveViewController *vc = [[ShowLiveViewController alloc] initWithNibName:nil bundle:nil];
        vc.liveRoom = self.liveRoom;
        self.vc = vc;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

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
            [self.imManager leaveRoom:self.liveRoom.roomId];
        }
    }
}

@end
