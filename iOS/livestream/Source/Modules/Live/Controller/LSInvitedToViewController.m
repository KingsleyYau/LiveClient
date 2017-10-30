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

#import "LiveRoomCreditRebateManager.h"
#import "LiveGobalManager.h"
#import "LSImManager.h"
#import "LSSessionRequestManager.h"
#import "LSImageViewLoader.h"

#import "AcceptInstanceInviteRequest.h"

typedef enum PreLiveStatus {
    PreLiveStatus_None,
    PreLiveStatus_Inviting,
    PreLiveStatus_WaitingEnterRoom,
    PreLiveStatus_CountingDownForEnterRoom,
    PreLiveStatus_EnterRoomAlready,
    PreLiveStatus_Canceling,
    PreLiveStatus_Error,
} PreLiveStatus;

@interface LSInvitedToViewController ()<IMManagerDelegate,IMLiveRoomManagerDelegate>

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

#pragma mark - 倒数控制
// 开播前倒数
@property (nonatomic, strong) dispatch_queue_t enterRoomQueue;
@property (atomic, strong) NSRunLoop *enterRoomLoop;
@property (atomic, strong) NSTimer *enterRoomTimer;
// 开播前倒数剩余时间
@property (nonatomic, assign) int enterRoomLeftSecond;

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;
@property (nonatomic, strong) UIViewController *vc;

@end

@implementation LSInvitedToViewController
- (void)initCustomParam {
    [super initCustomParam];
    
    // 初始化管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.imageViewLoader = [LSImageViewLoader loader];
    self.imageViewLoaderBg = [LSImageViewLoader loader];
    
    // 初始化余额及返点信息管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
    
    // 注册前后台切换通知
    _isBackground = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    NSLog(@"LSInvitedToViewController::dealloc()");
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    // 注销前后台切换通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setupContainView {
    [super setupContainView];
    
    // 设置背景模糊
    [self setupBgImageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipLabel.hidden = YES;
    self.countDownLabel.hidden = YES;
    self.startPrivateBtn.hidden = YES;
    self.bookPrivateBtn.hidden = YES;
    self.retryBtn.hidden = YES;
    self.addCreditBtn.hidden = YES;
    
    // 禁止导航栏后退手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    
    // 刷新女士名称
    self.liverNameLabel.text = self.liveRoom.userName;
    
    // 刷新女士头像 背景
    self.liverHeadImageView.layer.cornerRadius = 50;
    self.liverHeadImageView.layer.masksToBounds = YES;
    
    [self.imageViewLoader loadImageWithImageView:self.liverHeadImageView options:0 imageUrl:self.avatarUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    [self.imageViewLoader loadImageWithImageView:self.bgImageView options:0 imageUrl:self.avatarUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    // 测试用 同意立即私密邀请
    [self requestHandleBookWithInvited:self.inviteId];
}

// 观众处理立即私密邀请
- (void)requestHandleBookWithInvited:(NSString *)inviteId {
    AcceptInstanceInviteRequest *request = [[AcceptInstanceInviteRequest alloc] init];
    request.inviteId = inviteId;
    request.isConfirm = YES;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg,
                              AcceptInstanceInviteItemObject * _Nonnull item) {
        
        NSLog(@"LSInvitedToViewController::requestHandleBookWithInvited [观众处理立即私密邀请] success : %d, roomId : %@, roomType : %d, errmsg : %@",success, item.roomId, item.roomType, errmsg);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 请求成功
            if (success) {
                
                self.liveRoom.roomId = item.roomId;
                if ( item.roomType == HTTPROOMTYPE_FREEPUBLICLIVEROOM ) {
                    
                    self.liveRoom.roomType = LiveRoomType_Public;
                    
                } else if ( item.roomType == HTTPROOMTYPE_COMMONPRIVATELIVEROOM ) {
                    
                    self.liveRoom.roomType = LiveRoomType_Public_VIP;
                    
                }else if ( item.roomType == HTTPROOMTYPE_CHARGEPUBLICLIVEROOM ) {
                    
                    self.liveRoom.roomType = LiveRoomType_Private;
                    
                }else if ( item.roomType == HTTPROOMTYPE_LUXURYPRIVATELIVEROOM ) {
                    
                    self.liveRoom.roomType = LiveRoomType_Private_VIP;
                }
                // 发起请求
                [self startRequest];
                
                
            } else {
                
                if ( errnum == LCC_ERR_CONNECTFAIL ) {
                    // 发请求断网
                    [self handleError:LCC_ERR_CONNECTFAIL errMsg:NSLocalizedStringFromSelf(@"c1g-oJ-bRc.text")];
                    
                } else if ( errnum ==  LCC_ERR_NO_CREDIT ) {
                    // 所有错误
                    [self handleError:LCC_ERR_NO_CREDIT errMsg:NSLocalizedStringFromSelf(@"PRELIVE_ERR_ADD_CREDIT")];
                } else {
                    // 所有错误
                    [self handleError:LCC_ERR_INVITE_FAIL errMsg:NSLocalizedStringFromSelf(@"INVIATE_REQUEST_FAILE")];
                }
            }
        });
        
    };
    [self.sessionManager sendRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 停止计时
//    [self stopAllTimer];
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
    
    if (!self.enterRoomQueue) {
        self.enterRoomQueue = dispatch_queue_create("enterRoomQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    dispatch_async(self.enterRoomQueue, ^{
        self.enterRoomLoop = [NSRunLoop currentRunLoop];
        @synchronized(self) {
            if (!self.enterRoomTimer) {
                self.enterRoomTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                       target:self
                                                                     selector:@selector(enterRoomCountDown)
                                                                     userInfo:nil
                                                                      repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:self.enterRoomTimer forMode:NSDefaultRunLoopMode];
            }
        }
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)stopEnterRoomTimer {
    NSLog(@"LSInvitedToViewController::stopEnterRoomTimer()");
    
    self.enterRoomQueue = nil;
    
    @synchronized(self) {
        [self.enterRoomTimer invalidate];
        self.enterRoomTimer = nil;
    }
    
    if ([self.enterRoomLoop getCFRunLoop]) {
        CFRunLoopStop([self.enterRoomLoop getCFRunLoop]);
    }
}


#pragma mark - 进入直播间
- (void)startRequest {
    BOOL bFlag = NO;
    
    NSLog(@"LSInvitedToViewController::startRequest( [请求进入指定直播间], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
    self.statusLabel.text = [NSString stringWithFormat:@"请求进入指定直播间(roomId : %@)...", self.liveRoom.roomId];
    
    // TODO:发起进入指定直播间
    bFlag = [self.imManager enterRoom:self.liveRoom.roomId
                        finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"LSInvitedToViewController::startRequest( [请求进入指定直播间, %@], roomId : %@, waitStart : %@ )", BOOL2SUCCESS(success), self.liveRoom.roomId, BOOL2YES(roomItem.waitStart));
                                
                                [self handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
                            });
                        }];
    if (!bFlag) {
        NSLog(@"LSInvitedToViewController::startRequest( [请求进入指定直播间失败], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);
        [self handleError:LCC_ERR_DEFAULT errMsg:@"请求进入指定直播间失败"];
    }

}

#pragma mark - 界面事件
- (void)handleEnterRoom:(BOOL)success errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg roomItem:(ImLiveRoomObject *)roomItem {
    // TODO:处理进入直播间
    // 未超时
    if( self.status != PreLiveStatus_Error ) {
        if (success) {
            // 请求进入成功
            self.liveRoom.imLiveRoom = roomItem;
            self.tipLabel.hidden = YES;
            
            if (roomItem.waitStart) {
                // 等待主播进入
                self.statusLabel.text = @"等待主播进入直播间...";
                self.status = PreLiveStatus_WaitingEnterRoom;
                
            } else {
                self.statusLabel.text = [NSString stringWithFormat:@"进入直播间成功, 准备跳转..."];
                self.status = PreLiveStatus_EnterRoomAlready;
                
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
            
        } else {
            // 请求进入失败, 进行错误处理
            self.statusLabel.text = [NSString stringWithFormat:@"进入直播间失败"];
            [self handleError:errType errMsg:errMsg];
        }
    }
}

- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    // 改变状态为出错
    self.status = PreLiveStatus_Error;
    
    self.loadingView.hidden = YES;
    
    switch (errType) {
        case LCC_ERR_NO_CREDIT:{
            
            self.tipLabel.hidden = NO;
            [self.tipLabel setText:errMsg];
            self.countDownLabel.hidden = YES;
            self.startPrivateBtn.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.retryBtn.hidden = YES;
            self.addCreditBtn.hidden = NO;
        }break;
            
        case LCC_ERR_CONNECTFAIL:{
            
            self.tipLabel.hidden = NO;
            [self.tipLabel setText:errMsg];
            self.countDownLabel.hidden = YES;
            self.startPrivateBtn.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.retryBtn.hidden = NO;
            self.addCreditBtn.hidden = YES;
        }break;
            
        case LCC_ERR_INVITE_FAIL:{
            
            self.tipLabel.hidden = NO;
            [self.tipLabel setText:errMsg];
            self.countDownLabel.hidden = YES;
            self.startPrivateBtn.hidden = NO;
            self.bookPrivateBtn.hidden = NO;
            self.retryBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
        }break;
            
        default:
            break;
    }
    
}

- (void)enterRoom {
    // 如果在后台记录进入时间
    if( self.isBackground ) {
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
    }
    
    if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_COMMONPRIVATELIVEROOM) {
        // 普通私密直播间
        self.liveRoom.roomType = LiveRoomType_Private;
        [self enterPrivateRoom];
        
    } else if (self.liveRoom.imLiveRoom.roomType == ROOMTYPE_LUXURYPRIVATELIVEROOM) {
        // 豪华私密直播间
        self.liveRoom.roomType = LiveRoomType_Private_VIP;
        [self enterPrivateVipRoom];
    } else {
        [self handleError:LCC_ERR_FAIL errMsg:@"错误的直播间类型"];
    }
}

- (void)enterPrivateRoom {
    // TODO:进入私密直播间界面
    PrivateViewController *vc = [[PrivateViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    self.vc = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterPrivateVipRoom {
    // TODO:进入豪华私密直播间界面
    PrivateVipViewController *vc = [[PrivateVipViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    self.vc = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 直播间IM通知
- (void)onRecvWaitStartOverNotice:(ImStartOverRoomObject *_Nonnull)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSInvitedToViewController::onRecvWaitStartOverNotice( [直播间开播通知], roomId : %@, waitStart : %@, leftSeconds : %d )", item.roomId, BOOL2YES(self.liveRoom.imLiveRoom.waitStart), item.leftSeconds);
        
        // 当前直播间通知, 并且是需要等待主播进入的
        if ([item.roomId isEqualToString:self.liveRoom.roomId] && self.liveRoom.imLiveRoom.waitStart) {
            // 等待进入房间中才处理
            if (self.status == PreLiveStatus_WaitingEnterRoom) {
                self.statusLabel.text = @"主播已经进入直播间, 开始倒数...";
                self.tipLabel.text = [NSString stringWithFormat:@"%@ %@", self.liveRoom.userName, NSLocalizedStringFromSelf(@"PRELIVE_TIPS_BOARDCAST_ACCEPT")];
                
                // 更新流地址
                [self.liveRoom reset];
                self.liveRoom.playUrlArray = [item.playUrl copy];
                
                // 更新倒数时间
                self.enterRoomLeftSecond = item.leftSeconds;
                
                if (self.enterRoomLeftSecond > 0) {
                    self.status = PreLiveStatus_CountingDownForEnterRoom;
                    
                    self.tipLabel.hidden = NO;
                    [self.tipLabel setText:NSLocalizedStringFromSelf(@"INCIATE_WAIT_IN_LIVE")];
                    self.countDownLabel.hidden = NO;
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

#pragma mark - 按钮事件
#pragma 刷新
- (IBAction)retryAction:(id)sender {
    
    [self reset];
    
    self.status = PreLiveStatus_Inviting;
    // 发起请求
    [self startRequest];
}

#pragma mark - 开始私密
- (IBAction)startPrivateAction:(id)sender {
    
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
    
}

// 重置参数
- (void)reset {
    self.loadingView.hidden = NO;
    self.countDownLabel.hidden = YES;
    self.retryBtn.hidden = YES;
    self.startPrivateBtn.hidden = YES;
    self.bookPrivateBtn.hidden = YES;
    self.addCreditBtn.hidden = YES;
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    if( _isBackground == NO ) {
        _isBackground = YES;
        
        // 如果已经进入直播间成功, 更新切换后台时间
        if( self.status == PreLiveStatus_EnterRoomAlready ) {
            [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
        } else {
            [LiveGobalManager manager].enterRoomBackgroundTime = nil;
        }
        
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if( _isBackground == YES ) {
        _isBackground = NO;
        
        NSDate* now = [NSDate date];
        NSTimeInterval enterRoomTimeInterval = 0;
        if( [LiveGobalManager manager].enterRoomBackgroundTime ) {
            enterRoomTimeInterval = [now timeIntervalSinceDate:[LiveGobalManager manager].enterRoomBackgroundTime];
        }
        NSUInteger enterRoomBgTime = enterRoomTimeInterval;
        
        NSLog(@"LSInvitedToViewController::willEnterForeground( enterRoomBgTime : %lu )", (unsigned long)enterRoomBgTime);
        
        // 后台超过60秒
        if( enterRoomBgTime > BACKGROUND_TIMEOUT ) {
            if( self.status == PreLiveStatus_EnterRoomAlready ) {
                self.status = PreLiveStatus_Error;
                
                // 退出直播间
                [self.navigationController popToRootViewControllerAnimated:NO];
                
                // 弹出直播间关闭界面
                LiveFinshViewController *finshController = [[LiveFinshViewController alloc] init];
                finshController.liveRoom = self.liveRoom;
                finshController.errType = LCC_ERR_BACKGROUND_TIMEOUT;
                [self.navigationController pushViewController:finshController animated:NO];
            }
            
        }
    }
}

- (IBAction)closeAction:(id)sender {
    
    if (self.liveRoom.roomType == LiveRoomType_Private || self.liveRoom.roomType == LiveRoomType_Private_VIP) {
        if (self.inviteId.length) {
            [self.imManager cancelPrivateLive:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull roomId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            }];
        }
    }
    // 清空邀请
    self.inviteId = nil;
    
    // 公开直播, 直接退出
    [self.navigationController dismissViewControllerAnimated:YES completion:^{

    }];
}



@end
