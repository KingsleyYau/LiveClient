//
//  PreLiveViewController.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PreLiveViewController.h"

#import "PublicViewController.h"

#import "IMManager.h"
#import "SessionRequestManager.h"

#import "RecommandCollectionViewCell.h"

#import "GetPromoAnchorListRequest.h"

// 180秒后退出界面
#define INVITE_TIMEOUT 30
// 10秒后显示退出按钮
#define CANCEL_BUTTON_TIMEOUT 3

@interface PreLiveViewController () <IMLiveRoomManagerDelegate, IMManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
// IM管理器
@property (nonatomic, strong) IMManager *imManager;
// 接口管理器
@property (nonatomic, strong) SessionRequestManager *sessionManager;
// 上次发送返回的邀请
@property (nonatomic, strong) NSString *inviteId;
// 强制发送邀请
@property (nonatomic, assign) BOOL inviteForce;

#pragma mark - 倒数控制
// 开播前倒数
@property (nonatomic, strong) dispatch_queue_t enterRoomQueue;
@property (atomic, strong) NSRunLoop *enterRoomLoop;
@property (atomic, strong) NSTimer *enterRoomTimer;
// 开播前倒数剩余时间
@property (nonatomic, assign) int enterRoomLeftSecond;

#pragma mark - 总超时控制
// 总超时倒数
@property (nonatomic, strong) dispatch_queue_t handleQueue;
@property (atomic, strong) NSRunLoop *handleLoop;
@property (atomic, strong) NSTimer *handleTimer;
// 总超时剩余时间
@property (nonatomic, assign) int exitLeftSecond;
// 显示退出按钮时间
@property (nonatomic, assign) int showExitBtnLeftSecond;
// 能否显示退出按钮
@property (nonatomic, assign) BOOL canShowExitButton;

#pragma mark - 推荐逻辑
@property (atomic, strong) NSArray *recommandItems;
@end

@implementation PreLiveViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PreLiveViewController::initCustomParam()");

    // 初始化管理器
    self.imManager = [IMManager manager];
    [self.imManager addDelegate:self];
    self.sessionManager = [SessionRequestManager manager];

}

- (void)dealloc {
    NSLog(@"PreLiveViewController::dealloc()");

    [self.imManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 重置参数
    [self reset];
    
    self.ladyNameLabel.text = self.liveRoom.userName;
    self.cancelButton.hidden = YES;

//    self.tipsLabel.text = @"";
    self.handleCountDownLabel.text = [NSString stringWithFormat:@"%d s", self.exitLeftSecond, nil];
    self.countDownLabel.text = @"";
    
//    self.loadingView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
    // 禁止导航栏后退手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 直接进入直播间
    [self enterPublicRoom];
    
//    // 发起请求
//    [self startRequest];
//
//    // 开始计时
//    [self startHandleTimer];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 停止计时
    [self stopEnterRoomTimer];
    [self stopHandleTimer];
}

- (void)setupContainView {
    [super setupContainView];
    
    // 初始化推荐
    [self setupRecommandView];
    // 初始化背景
    [self setupBgImageView];
    // 初始化主播头像
    [self setupLadyImageView];
}

- (void)setupRecommandView {
    UINib *nib = [UINib nibWithNibName:@"RecommandCollectionViewCell" bundle:nil];
    [self.recommandCollectionView registerNib:nib forCellWithReuseIdentifier:[RecommandCollectionViewCell cellIdentifier]];
    self.recommandViewHeight.constant = 0;
}

- (void)setupBgImageView {
    // 设置模糊
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualView.frame = CGRectMake(0, 0, self.bgImageView.width, self.bgImageView.height);
    [self.bgImageView addSubview:visualView];
}

- (void)setupLadyImageView {
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.width / 2;
    self.ladyImageView.layer.masksToBounds = YES;
}

#pragma mark - 数据逻辑
- (void)startRequest {
    NSString *roomId = self.liveRoom.roomId;
    NSString *userId = self.liveRoom.userId;
    LiveRoomType roomType = self.liveRoom.roomType;
    
    NSLog(@"PreLiveViewController::startRequest( roomType : %d, roomId : %@, userId : %@ )", roomType, roomId, userId);

    if (roomId > 0) {
        self.statusLabel.text = [NSString stringWithFormat:@"正在进入指定直播间(roomId : %@)...", roomId];

        // TODO:发起进入指定直播间
        [self.imManager enterRoom:roomId
                    finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"PreLiveViewController::startRequest( [进入指定直播间, %@], roomId : %@, waitStart : %@ )", BOOL2SUCCESS(success), roomId, BOOL2YES(roomItem.waitStart));

                            if (success) {
                                // 请求进入成功
                                self.statusLabel.text = [NSString stringWithFormat:@"进入直播间成功"];

                                self.liveRoom.imLiveRoom = roomItem;

                                if (roomItem.waitStart) {
                                    // 等待主播进入
                                    self.statusLabel.text = @"等待主播进入直播间...";

                                } else {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        // 马上进入直播间
                                        [self enterRoom];
                                    });
                                }

                            } else {
                                // 请求进入失败, 进行错误处理
                                self.statusLabel.text = [NSString stringWithFormat:@"进入直播间失败"];
                                [self handleError:errType errMsg:errMsg];
                            }
                        });
                    }];
    } else {
        if (self.liveRoom.roomType == LiveRoomType_Public || self.liveRoom.roomType == LiveRoomType_Public_VIP) {
            self.statusLabel.text = [NSString stringWithFormat:@"正在进入公开直播间(userId : %@)...", userId];

            // TODO:发起进入公开直播间
            [self.imManager enterPublicRoom:userId
                              finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      NSLog(@"PreLiveViewController::startRequest( [进入公开直播间, %@], roomId : %@, waitStart : %@ )", BOOL2SUCCESS(success), roomId, BOOL2YES(roomItem.waitStart));

                                      if (success) {
                                          // 请求进入成功
                                          self.statusLabel.text = [NSString stringWithFormat:@"进入公开直播间成功"];

                                          self.liveRoom.imLiveRoom = roomItem;

                                          if (roomItem.waitStart) {
                                              // 等待主播进入
                                              self.statusLabel.text = @"等待主播进入公开直播间...";

                                          } else {
                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                  // 马上进入直播间
                                                  [self enterRoom];
                                              });
                                          }

                                      } else {
                                          // 请求进入失败, 进行错误处理
                                          self.statusLabel.text = [NSString stringWithFormat:@"进入公开直播间失败"];
                                          [self handleError:errType errMsg:errMsg];
                                      }
                                  });
                              }];

        } else {
            self.statusLabel.text = [NSString stringWithFormat:@"正在发起私密邀请..."];
            // TODO:发起私密直播邀请
            [self.imManager invitePrivateLive:self.liveRoom.userId
                                        logId:@""
                                        force:self.inviteForce
                                finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull invitationId, int timeout, NSString *_Nonnull roomId) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSLog(@"PreLiveViewController::startRequest( [发起私密邀请, %@], userId : %@, waitStart : %@ )", BOOL2SUCCESS(success), self.liveRoom.userId);
                                        
                                        if (success) {
                                            // TODO:私密邀请发送成功, 更新直播间Id
                                            self.liveRoom.roomId = roomId;
                                            self.inviteId = invitationId;

                                        } else {
                                            if( !self.inviteForce ) {
                                                // 未发送过强制邀请
                                                if (YES) {
                                                    // 主播正在私密直播中
                                                    
                                                    // 获取推荐列表
                                                    [self getAdvisementList];
                                                    
                                                    // 弹出选择对话框
                                                    [self handleError:LCC_ERR_PRI_LIVING errMsg:@"主播正在直播中"];
                                                    
                                                } else {
                                                    // 弹出错误提示(邀请失败)
                                                     [self handleError:LCC_ERR_FAIL errMsg:errMsg];
                                                }
                                                
                                            } else {
                                                // 弹出错误提示(邀请失败)
                                                [self handleError:LCC_ERR_FAIL errMsg:errMsg];
                                            }
                                        }
                                    });
                                }];
        }
    }
}

- (void)getAdvisementList {
    // TODO:获取推荐列表
    GetPromoAnchorListRequest *request = [[GetPromoAnchorListRequest alloc] init];
    request.number = 2;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> * _Nullable array) {
        if( success ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 刷新推荐列表
                self.recommandItems = array;
                [self reloadRecommandView];
            });
        }
    };
    [self.sessionManager sendRequest:request];
}

- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    // TODO:错误处理
    switch (errType) {
        case LCC_ERR_ROOM_FULL:{
            // 房间人满
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"出错啦, 直播间人满"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *_Nonnull action) {
                                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                     // 停止所有动作
                                                                     [self stopHandleTimer];
                                                                     [self stopEnterRoomTimer];
                                                                     self.statusLabel.text = @"出错啦, 直播间人满";
                                                                     self.retryButton.hidden = NO;
                                                                     self.bookButton.hidden = NO;
                                                                     self.loadingView.hidden = YES;
                                                                 });
                                                             }];
            [alertVC addAction:actionOK];
            [self presentViewController:alertVC animated:NO completion:nil];
            
        }break;
        case LCC_ERR_NO_CREDIT: {
            // 没钱, 弹出充点
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"无钱啦"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *_Nonnull action) {
                                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                     // 停止所有动作
                                                                     [self stopHandleTimer];
                                                                     [self stopEnterRoomTimer];
                                                                     self.statusLabel.text = @"出错啦, 无钱啦";
                                                                     self.retryButton.hidden = NO;
                                                                     self.bookButton.hidden = NO;
                                                                     self.loadingView.hidden = YES;
                                                                 });
                                                             }];
            [alertVC addAction:actionOK];
            [self presentViewController:alertVC animated:NO completion:nil];
        } break;
        case LCC_ERR_PRI_LIVING: {
            // 主播正在私密直播中
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"主播正在私密直播中"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *_Nonnull action){
                                                                 // 重新发送强制邀请
                                                                 self.inviteForce = YES;
                                                                 [self startRequest];
                                                             }];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *_Nonnull action) {
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         // 停止所有动作
                                                                         [self stopHandleTimer];
                                                                         [self stopEnterRoomTimer];
                                                                         self.statusLabel.text = @"出错啦, 主播正在私密直播中";
                                                                         self.retryButton.hidden = NO;
                                                                         self.bookButton.hidden = NO;
                                                                         self.loadingView.hidden = YES;
                                                                     });
                                                                 }];
            [alertVC addAction:actionOK];
            [alertVC addAction:actionCancel];
            [self presentViewController:alertVC animated:NO completion:nil];

        } break;
        default: {
            // 弹出普通提示
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                             message:errMsg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *_Nonnull action) {
                                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                     // 停止所有动作
                                                                     [self stopHandleTimer];
                                                                     [self stopEnterRoomTimer];
                                                                     self.statusLabel.text = [NSString stringWithFormat:@"出错啦, %@", errMsg];
                                                                     self.retryButton.hidden = NO;
                                                                     self.bookButton.hidden = NO;
                                                                     self.loadingView.hidden = YES;
                                                                 });
                                                             }];
            [alertVC addAction:actionOK];
            [self presentViewController:alertVC animated:NO completion:nil];

        } break;
    }
}

- (void)reset {
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
    // 隐藏重试按钮
    self.retryButton.hidden = YES;
    // 隐藏预约按钮
    self.bookButton.hidden = YES;
    // 显示菊花
    self.loadingView.hidden = NO;
}

#pragma mark - 界面事件
- (void)enterRoom {
    // TODO:根据服务器返回的直播间类型进入
    if( self.liveRoom.imLiveRoom.roomType == ROOMTYPE_FREEPUBLICLIVEROOM ) {
        // 免费公开直播间
        self.liveRoom.roomType = LiveRoomType_Public;
        [self enterPublicRoom];
        
    } else if( self.liveRoom.imLiveRoom.roomType == ROOMTYPE_CHARGEPUBLICLIVEROOM ) {
        // 付费公开直播间
        self.liveRoom.roomType = LiveRoomType_Public_VIP;
        [self enterPublicRoom];
        
    } else if( self.liveRoom.imLiveRoom.roomType == ROOMTYPE_COMMONPRIVATELIVEROOM ) {
        // 普通私密直播间
        self.liveRoom.roomType = LiveRoomType_Private;
        [self enterPrivateRoom];
        
    } else if( self.liveRoom.imLiveRoom.roomType == ROOMTYPE_LUXURYPRIVATELIVEROOM ) {
        // 豪华私密直播间
        self.liveRoom.roomType = LiveRoomType_Private_VIP;
        [self enterPrivateRoom];
    }
}

- (void)enterPublicRoom {
    // TODO:进入公开直播间界面
    PublicViewController *vc = [[PublicViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterPrivateRoom {
    // TODO:进入私密直播间界面
    PublicViewController *vc = [[PublicViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reloadRecommandView {
    UIImage *image1 = [UIImage imageNamed:@"Test_Lady_Head"];
    UIImage *image2 = [UIImage imageNamed:@"Test_User_Head"];
    self.recommandItems = @[image1, image2];
    
    self.recommandViewHeight.constant = (self.recommandItems.count > 0)?130:0;
    self.recommandViewWidth.constant = [RecommandCollectionViewCell cellWidth] * self.recommandItems.count;
    [self.recommandCollectionView reloadData];
    
    self.loadingView.hidden = (self.recommandItems.count > 0)?YES:NO;
}

- (IBAction)close:(id)sender {
    // TODO:关闭界面
    if (self.liveRoom.roomType == LiveRoomType_Private || self.liveRoom.roomType == LiveRoomType_Private_VIP) {
        // 私密直播, 发出取消请求
        if (self.inviteId) {
            if ([self.imManager cancelPrivateLive:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull roomId) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            // 取消成功
                            [self.navigationController popViewControllerAnimated:YES];

                        } else {
                            // 取消失败, 弹出错误提示
                            [self handleError:LCC_ERR_FAIL errMsg:errMsg];
                        }

                    });
                }]) {
                // 取消失败, 弹出错误提示
                [self handleError:LCC_ERR_FAIL errMsg:@"取消邀请失败"];
            }
        } else {
            // 未获得邀请Id, 直接退出
            [self.navigationController popViewControllerAnimated:YES];
        }

    } else {
        // 公开直播, 直接退出
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)retry:(id)sender {
    // TODO:重试
    
    // 重置参数
    [self reset];
    
    // 发起请求
    [self startRequest];
    
    // 开始计时
    [self stopHandleTimer];
    [self startHandleTimer];
}

- (IBAction)book:(id)sender {
    // TODO:预约
    
    // 重置参数
    [self reset];
    
}

#pragma mark - 直播间IM通知
- (void)onRecvWaitStartOverNotice:(NSString *_Nonnull)roomId leftSeconds:(int)leftSeconds {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PreLiveViewController::onRecvWaitStartOverNotice( roomId : %@, waitStart : %@ )", roomId, BOOL2YES(self.liveRoom.imLiveRoom.waitStart));

        self.statusLabel.text = @"主播已经进入直播间, 开始倒数...";

        // 当前直播间通知, 并且是需要等待主播进入的
        if ([roomId isEqualToString:self.liveRoom.roomId] && self.liveRoom.imLiveRoom.waitStart) {
            // 更新倒数时间
            self.enterRoomLeftSecond = leftSeconds;

            // 不能显示退出按钮
            self.canShowExitButton = NO;
            self.cancelButton.hidden = YES;

            if (self.enterRoomLeftSecond > 0) {
                // 开始倒数
                [self startEnterRoomTimer];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 马上进入直播间
                    [self enterRoom];
                });
            }
        }
    });
}

- (void)onRecvInstantInviteReplyNotice:(NSString *_Nonnull)inviteId replyType:(ReplyType)replyType roomId:(NSString *_Nonnull)roomId roomType:(RoomType)roomType anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PreLiveViewController::onRecvInstantInviteReplyNotice( roomId : %@, inviteId : %@ )", roomId, inviteId);

        // 当前直播间通知
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            if (replyType == REPLYTYPE_AGREE) {
                // 主播同意, 发起进入直播间请求
                self.statusLabel.text = @"主播同意私密邀请";

                [self startRequest];

            } else if (replyType == REPLYTYPE_REJECT) {
                // 主播结束拒绝, 弹出提示
                self.statusLabel.text = @"主播拒绝私密邀请";

                [self handleError:LCC_ERR_FAIL errMsg:@"主播拒绝了你的邀请"];
            }
        }
    });
}

- (void)onRecvInviteReply:(InviteIdItemObject *_Nonnull)item {
    NSLog(@"PreLiveViewController::onRecvInviteReply( roomId : %@, inviteId : %@, replyType : %d )", item.roomId, item.invitationId, item.replyType);

    // 当前直播间通知
    if ([item.roomId isEqualToString:self.liveRoom.roomId]) {
        if (item.replyType == HTTPREPLYTYPE_UNCONFIRM) {
            // 继续等待

        } else if (item.replyType == HTTPREPLYTYPE_AGREE) {
            // 主播同意, 发起进入直播间请求
            self.statusLabel.text = @"主播同意私密邀请";
            // 发送请求
            [self startRequest];

        } else if (item.replyType == HTTPREPLYTYPE_REJECT) {
            // 主播结束拒绝, 弹出提示
            self.statusLabel.text = @"主播拒绝私密邀请";
            // 显示错误提示
            [self handleError:LCC_ERR_FAIL errMsg:@"主播拒绝了你的邀请"];

        } else if (item.replyType == HTTPREPLYTYPE_CANCEL) {
            // 邀请取消的提示
            [self handleError:LCC_ERR_FAIL errMsg:@"观众/主播取消"];

        } else {
            // 普通错误提示
            [self handleError:LCC_ERR_FAIL errMsg:@"邀请已经失效"];
        }
    }
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
        self.countDownLabel.text = [NSString stringWithFormat:@"%d s", self.enterRoomLeftSecond];
    });
}

- (void)startEnterRoomTimer {
    NSLog(@"PreLiveViewController::startEnterRoomTimer()");
    
    if( !self.enterRoomQueue ) {
        self.enterRoomQueue = dispatch_queue_create("enterRoomQueue", DISPATCH_QUEUE_SERIAL);
    }
    WeakObject(self, weakSelf);
    dispatch_async(self.enterRoomQueue, ^{
        if (!weakSelf.enterRoomTimer) {
            weakSelf.enterRoomLoop = [NSRunLoop currentRunLoop];
            weakSelf.enterRoomTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                       target:weakSelf
                                                                     selector:@selector(enterRoomCountDown)
                                                                     userInfo:nil
                                                                      repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:weakSelf.enterRoomTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        }
    });
}

- (void)stopEnterRoomTimer {
    NSLog(@"PreLiveViewController::stopEnterRoomTimer()");

    self.enterRoomQueue = nil;
    [self.enterRoomTimer invalidate];
    self.enterRoomTimer = nil;

    if ([self.enterRoomLoop getCFRunLoop]) {
        CFRunLoopStop([self.enterRoomLoop getCFRunLoop]);
    }
}

#pragma mark - 总超时控制
- (void)handleCountDown {
    //    NSLog(@"PreLiveViewController::handleCountDown( enterRoomLeftSecond : %d )", self.exitLeftSecond);

    self.exitLeftSecond--;
    if (self.exitLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 倒数完成, 提示超时
            [self stopHandleTimer];
            [self handleError:LCC_ERR_INVITE_TIMEOUT errMsg:@"进入直播间超时"];
        });

    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.handleCountDownLabel.text = [NSString stringWithFormat:@"%d s", self.exitLeftSecond];
    });
    
    self.showExitBtnLeftSecond--;
    if (self.showExitBtnLeftSecond == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 允许显示退出按钮
            if( self.canShowExitButton ) {
                self.cancelButton.hidden = NO;
            }
        });
    }
}

- (void)startHandleTimer {
    NSLog(@"PreLiveViewController::startHandleTimer()");

    if( !self.handleQueue ) {
        self.handleQueue = dispatch_queue_create("handleQueue", DISPATCH_QUEUE_SERIAL);
    }
    WeakObject(self, weakSelf);
    dispatch_async(self.handleQueue, ^{
        if (!weakSelf.handleTimer) {
            weakSelf.handleLoop = [NSRunLoop currentRunLoop];
            weakSelf.handleTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                    target:weakSelf
                                                                  selector:@selector(handleCountDown)
                                                                  userInfo:nil
                                                                   repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:weakSelf.handleTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        }
    });
}

- (void)stopHandleTimer {
    NSLog(@"PreLiveViewController::stopHandleTimer()");

    self.handleQueue = nil;
    [self.handleTimer invalidate];
    self.handleTimer = nil;

    if ([self.handleLoop getCFRunLoop]) {
        CFRunLoopStop([self.handleLoop getCFRunLoop]);
    }
}

#pragma mark - 推荐逻辑
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommandItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommandCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RecommandCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    LiveRoomInfoItemObject *item = [self.recommandItems objectAtIndex:indexPath.row];
    
    cell.imageView.image = nil;
    [cell.imageViewLoader stop];
    [cell.imageViewLoader loadImageWithImageView:cell.imageView
                                         options:0 imageUrl:item.photoUrl
                                placeholderImage:[UIImage imageNamed:@"Test_Lady_Head"]];
    
    cell.nameLabel.text = item.nickName;
    
    return cell;
}

@end
