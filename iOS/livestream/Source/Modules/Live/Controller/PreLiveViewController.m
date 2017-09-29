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

#import "IMManager.h"
#import "SessionRequestManager.h"
#import "ImageViewLoader.h"
#import "LiveRoomCreditRebateManager.h"

#import "RecommandCollectionViewCell.h"

#import "GetPromoAnchorListRequest.h"

// 180秒后退出界面
#define INVITE_TIMEOUT 180
// 10秒后显示退出按钮
#define CANCEL_BUTTON_TIMEOUT 10

typedef enum PreLiveStatus {
    PreLiveStatus_None,
    PreLiveStatus_Inviting,
    PreLiveStatus_WaitingEnterRoom,
    PreLiveStatus_EnterRoomAlready,
    PreLiveStatus_Error,
} PreLiveStatus;

@interface PreLiveViewController () <IMLiveRoomManagerDelegate, IMManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
// 当前状态
@property (nonatomic, assign) PreLiveStatus status;
// IM管理器
@property (nonatomic, strong) IMManager *imManager;
// 接口管理器
@property (nonatomic, strong) SessionRequestManager *sessionManager;
// 上次发送返回的邀请
@property (nonatomic, strong) NSString *inviteId;
// 强制发送邀请
@property (nonatomic, assign) BOOL inviteForce;
// 是否已经进入直播间
@property (nonatomic, assign) BOOL enterRoomAlready;

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

#pragma mark - 头像逻辑
@property (atomic, strong) ImageViewLoader *imageViewLoader;
@property (atomic, strong) ImageViewLoader *imageViewLoaderBg;

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

@end

@implementation PreLiveViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PreLiveViewController::initCustomParam()");

    // 初始化管理器
    self.imManager = [IMManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    self.sessionManager = [SessionRequestManager manager];

    self.imageViewLoader = [ImageViewLoader loader];
    self.imageViewLoaderBg = [ImageViewLoader loader];

    // 初始化余额及返点信息管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
}

- (void)dealloc {
    NSLog(@"PreLiveViewController::dealloc()");

    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 重置参数
    [self reset];

    self.ladyNameLabel.text = self.liveRoom.userName;

    // 放大菊花
    //    self.loadingView.transform = CGAffineTransformMakeScale(2.0, 2.0);

    // 禁止导航栏后退手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;

    // 刷新女士头像
    [self.imageViewLoader loadImageWithImageView:self.ladyImageView options:0 imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    [self.imageViewLoaderBg loadImageWithImageView:self.bgImageView options:0 imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Square"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 防止进入时候会闪烁
    self.bgImageView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 防止后退时候会闪烁
    self.bgImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 显示背景
    self.bgImageView.hidden = NO;

    // 开始计时
    [self startHandleTimer];

    // 发起请求
    [self startRequest];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 停止计时
    [self stopAllTimer];
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
    [self.bgImageView addSubview:visualView];

    [visualView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgImageView);
        make.left.equalTo(self.bgImageView);
        make.width.equalTo(self.bgImageView);
        make.height.equalTo(self.bgImageView);
    }];
}

- (void)setupLadyImageView {
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.width / 2;
    self.ladyImageView.layer.masksToBounds = YES;
}

#pragma mark - 数据逻辑
- (void)startRequest {
    BOOL bFlag = NO;

    NSLog(@"PreLiveViewController::startRequest( [开始发起请求], roomType : %d, userId : %@, roomId : %@ )", self.liveRoom.roomType, self.liveRoom.userId, self.liveRoom.roomId);

    if (self.liveRoom.roomId.length > 0) {
        self.statusLabel.text = [NSString stringWithFormat:@"正在进入指定直播间(roomId : %@)...", self.liveRoom.roomId];

        // TODO:发起进入指定直播间
        bFlag = [self.imManager enterRoom:self.liveRoom.roomId
                            finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"PreLiveViewController::startRequest( [进入指定直播间, %@], roomId : %@, waitStart : %@ )", BOOL2SUCCESS(success), self.liveRoom.roomId, BOOL2YES(roomItem.waitStart));

                                    [self handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
                                });
                            }];
    } else {
        if (self.liveRoom.roomType == LiveRoomType_Public || self.liveRoom.roomType == LiveRoomType_Public_VIP) {
            self.statusLabel.text = [NSString stringWithFormat:@"正在进入公开直播间(userId : %@)...", self.liveRoom.userId];

            // TODO:发起进入公开直播间
            bFlag = [self.imManager enterPublicRoom:self.liveRoom.userId
                                      finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSLog(@"PreLiveViewController::startRequest( [进入公开直播间, %@], roomId : %@, waitStart : %@, errMsg : %@ )",
                                                    BOOL2SUCCESS(success), roomItem.roomId, BOOL2YES(roomItem.waitStart), errMsg);

                                              [self handleEnterRoom:success errType:errType errMsg:errMsg roomItem:roomItem];
                                          });
                                      }];

        } else {
            self.status = PreLiveStatus_Inviting;
            self.statusLabel.text = [NSString stringWithFormat:@"正在发起私密邀请..."];
            // TODO:发起私密直播邀请
            bFlag = [self.imManager invitePrivateLive:self.liveRoom.userId
                                                logId:@""
                                                force:self.inviteForce
                                        finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull invitationId, int timeout, NSString *_Nonnull roomId) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                NSLog(@"PreLiveViewController::startRequest( [发起私密邀请, %@], userId : %@, invitationId : %@, roomId : %@, errType : %d, errMsg : %@ )", BOOL2SUCCESS(success), self.liveRoom.userId, invitationId, roomId, errType, errMsg);
                                                if (self.exitLeftSecond > 0) {
                                                    // 未超时
                                                    if (success) {
                                                        // TODO:私密邀请发送成功
                                                        self.statusLabel.text = [NSString stringWithFormat:@"发送私密邀请成功, 等待处理..."];

                                                        if (roomId.length > 0) {
                                                            // 有roomId直接进入
                                                            NSLog(@"PreLiveViewController::startRequest( [私密邀请成功, 有roomId直接进入私密直播间], userId : %@, roomId : %@ )", self.liveRoom.userId, roomId);
                                                            self.liveRoom.roomId = roomId;
                                                            [self startRequest];

                                                        } else if (invitationId.length > 0) {
                                                            // 更新邀请Id
                                                            NSLog(@"PreLiveViewController::startRequest( [私密邀请成功, 更新邀请Id], userId : %@, invitationId : %@ )", self.liveRoom.userId, invitationId);
                                                            self.inviteId = invitationId;
                                                        } else {
                                                            // 没法处理, 弹出错误提示(邀请失败)
                                                            [self handleError:errType errMsg:@"没有inviteId或者roomId"];
                                                        }

                                                    } else {
                                                        if (!self.inviteForce) {
                                                            // 未发送过强制邀请
                                                            if (errType == LCC_ERR_ANCHOR_PLAYING) {
                                                                // 主播正在私密直播中

                                                                // 获取推荐列表
                                                                [self getAdvisementList];

                                                                // 弹出选择对话框
                                                                [self handleError:errType errMsg:@"主播正在直播中"];

                                                            } else {
                                                                // 弹出错误提示(邀请失败)
                                                                [self handleError:errType errMsg:errMsg];
                                                            }

                                                        } else {
                                                            // 弹出错误提示(邀请失败)
                                                            [self handleError:errType errMsg:errMsg];
                                                        }
                                                    }
                                                }

                                            });
                                        }];
        }
    }

    if (!bFlag) {
        NSLog(@"PreLiveViewController::startRequest( [发送请求失败] )");
        self.statusLabel.text = [NSString stringWithFormat:@"发送请求失败"];

        [self stopAllTimer];
        [self showRetry];
    }
}

- (void)getAdvisementList {
    // TODO:获取推荐列表
    GetPromoAnchorListRequest *request = [[GetPromoAnchorListRequest alloc] init];
    request.number = 2;
    request.userId = @"";
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
        if (success) {
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
    self.statusLabel.text = @"出错啦";
    self.status = PreLiveStatus_Error;
    
    switch (errType) {
        case LCC_ERR_INVITE_TIMEOUT: {
            // 邀请超时
            self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_ERR_ENTERROOM_EXPIRE");

            [self stopAllTimer];
            [self showRetry];

        } break;
        case LCC_ERR_NO_CREDIT: {
            // 没钱, 弹出充点
            self.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_ERR_ADD_CREDIT");

            [self stopAllTimer];
            [self showRetry];

            // 显示充点按钮
            self.addCreditButtonHeight.constant = 33;

        } break;
        case LCC_ERR_ANCHOR_PLAYING: {
            // 主播正在私密直播中
            self.tipsLabel.text = [NSString stringWithFormat:@"%@ %@", self.liveRoom.userName, NSLocalizedStringFromSelf(@"PRELIVE_ERR_BOARDCAST_LIVING")];

            // 显示强制邀请按钮
            self.inviteButtonHeight.constant = 33;

        } break;
        default: {
            // 普通错误提示
            self.tipsLabel.text = [NSString stringWithFormat:@"%@", errMsg];

            [self stopAllTimer];
            [self showRetry];

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
    self.liveRoom.roomId = nil;
    // 标记当前状态
    self.status = PreLiveStatus_None;

    // 还原状态提示
    self.tipsLabel.text = NSLocalizedStringFromSelf(@"h2y-1A-AFR.text");
    self.statusLabel.text = @"";
    self.handleCountDownLabel.text = @"";
    self.countDownLabel.text = @"";
    // 显示菊花
    self.loadingView.hidden = NO;
    // 隐藏退出按钮
    self.cancelButton.hidden = YES;

    // 隐藏按钮
    self.retryButtonHeight.constant = 0;
    self.startButtonHeight.constant = 0;
    self.bookButtonHeight.constant = 0;
    self.inviteButtonHeight.constant = 0;
    self.addCreditButtonHeight.constant = 0;
    self.viewProfileButtonHeight.constant = 0;
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
        if (success) {
            // 请求进入成功
            self.liveRoom.imLiveRoom = roomItem;

            if (NO) {
//            if (roomItem.waitStart) {
                // 等待主播进入
                self.statusLabel.text = @"等待主播进入直播间...";
                self.status = PreLiveStatus_WaitingEnterRoom;

            } else {
                self.statusLabel.text = [NSString stringWithFormat:@"进入直播间成功, 准备跳转..."];
                self.status = PreLiveStatus_EnterRoomAlready;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 马上进入直播间
                    [self enterRoom];
                });
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

- (void)enterRoom {
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

- (void)enterPublicRoom {
    // TODO:进入免费公开直播间界面
    PublicViewController *vc = [[PublicViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterPublicVipRoom {
    // TODO:进入付费公开直播间界面
    PublicVipViewController *vc = [[PublicVipViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterPrivateRoom {
    // TODO:进入私密直播间界面
    PrivateViewController *vc = [[PrivateViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterPrivateVipRoom {
    // TODO:进入豪华私密直播间界面
    PrivateVipViewController *vc = [[PrivateVipViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = self.liveRoom;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reloadRecommandView {
    // TODO:刷新推荐列表
    self.recommandViewHeight.constant = (self.recommandItems.count > 0) ? 130 : 0;
    self.recommandViewWidth.constant = [RecommandCollectionViewCell cellWidth] * self.recommandItems.count;
    [self.recommandCollectionView reloadData];

    self.loadingView.hidden = (self.recommandItems.count > 0) ? YES : NO;
}

- (void)showRetry {
    // TODO:显示重试按钮
    self.retryButtonHeight.constant = 33;
    self.startButtonHeight.constant = 0;
    self.bookButtonHeight.constant = 35;
    self.inviteButtonHeight.constant = 0;

    self.loadingView.hidden = YES;
}

#pragma mark - 点击事件
- (IBAction)close:(id)sender {
    // TODO:点击关闭界面
    NSLog(@"PreLiveViewController::close()");

    if (self.liveRoom.roomType == LiveRoomType_Private || self.liveRoom.roomType == LiveRoomType_Private_VIP) {
        // 私密直播, 发出取消请求
        if (self.inviteId.length) {
            if ([self.imManager cancelPrivateLive:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSString *_Nonnull roomId) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 清空邀请
                        self.inviteId = nil;

                        if (success) {
                            // 取消成功
                            self.statusLabel.text = @"取消邀请成功";

                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];

                        } else {
                            // 取消失败, 弹出错误提示
                            [self handleError:LCC_ERR_FAIL errMsg:@"取消邀请失败"];
                        }

                    });
                }]) {
                self.statusLabel.text = @"发送取消邀请中...";

            } else {
                // 取消失败, 弹出错误提示
                [self handleError:LCC_ERR_FAIL errMsg:@"取消邀请失败"];
            }
        } else {
            // 未获得邀请Id, 直接退出
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }

    } else {
        // 公开直播, 直接退出
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)retry:(id)sender {
    // TODO:点击重试

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
    [self reset];
}

- (IBAction)invite:(id)sender {
    // TODO:点击强制邀请

    self.inviteForce = YES;
    [self startRequest];
}

#pragma mark - 直播间IM通知
- (void)onRecvWaitStartOverNotice:(ImStartOverRoomObject *_Nonnull)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PreLiveViewController::onRecvWaitStartOverNotice( [直播间开播通知], roomId : %@, waitStart : %@ )", item.roomId, BOOL2YES(self.liveRoom.imLiveRoom.waitStart));

        if (!self.enterRoomAlready) {
            // 没有进入直播间才处理
            if (self.exitLeftSecond > 0) {
                // 当前直播间通知, 并且是需要等待主播进入的
                if ([item.roomId isEqualToString:self.liveRoom.roomId] && self.liveRoom.imLiveRoom.waitStart) {
                    // 等待进入房间中才处理
                    if (self.status == PreLiveStatus_WaitingEnterRoom) {
                        self.status = PreLiveStatus_EnterRoomAlready;

                        self.statusLabel.text = @"主播已经进入直播间, 开始倒数...";
                        self.tipsLabel.text = [NSString stringWithFormat:@"%@ %@", self.liveRoom.userName, NSLocalizedStringFromSelf(@"PRELIVE_TIPS_BOARDCAST_ENTERING")];

                        // 更新倒数时间
                        self.enterRoomLeftSecond = item.leftSeconds;
                        // 标记过程中不能再进入房间
                        self.enterRoomAlready = YES;

                        // 不能显示退出按钮
                        self.canShowExitButton = NO;
                        self.cancelButton.hidden = YES;

                        if (self.enterRoomLeftSecond > 0) {
                            // 开始倒数
                            [self startEnterRoomTimer];
                        } else {
                            // 马上进入直播间
                            [self enterRoom];
                        }
                    }
                }
            }
        }
    });
}

- (void)onRecvInstantInviteReplyNotice:(NSString *_Nonnull)inviteId replyType:(ReplyType)replyType roomId:(NSString *_Nonnull)roomId roomType:(RoomType)roomType anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PreLiveViewController::onRecvInstantInviteReplyNotice( [立即私密邀请回复通知], roomId : %@, inviteId : %@, replyType : %d )", roomId, inviteId, replyType);

        if (!self.enterRoomAlready) {
            // 没有进入直播间才处理
            if (self.exitLeftSecond > 0) {
                // 当前邀请通知
                if ([inviteId isEqualToString:self.inviteId]) {
                    // 邀请中才处理
                    if (self.status == PreLiveStatus_Inviting) {
                        self.status = PreLiveStatus_WaitingEnterRoom;

                        if (replyType == REPLYTYPE_AGREE) {
                            // 主播同意
                            self.statusLabel.text = @"主播同意私密邀请";

                            // 更新直播间Id, 发起进入直播间请求
                            self.liveRoom.roomId = roomId;
                            [self startRequest];

                        } else if (replyType == REPLYTYPE_REJECT) {
                            // 主播结束拒绝, 弹出提示
                            self.statusLabel.text = @"主播拒绝私密邀请";
                            [self handleError:LCC_ERR_FAIL errMsg:@"主播拒绝私密邀请"];
                        }

                        // 清空邀请
                        self.inviteId = nil;
                    }
                }
            }
        }

    });
}

- (void)onRecvInviteReply:(ImInviteIdItemObject *_Nonnull)item {
    NSLog(@"PreLiveViewController::onRecvInviteReply( [断线重登陆获取到的邀请状态], roomId : %@, inviteId : %@, replyType : %d )", item.roomId, item.invitationId, item.replyType);

    if (!self.enterRoomAlready) {
        // 没有进入直播间才处理
        if (self.exitLeftSecond > 0) {
            // 当前邀请通知
            if ([item.invitationId isEqualToString:self.inviteId]) {
                if (self.status == PreLiveStatus_Inviting) {
                    if (item.replyType == HTTPREPLYTYPE_UNCONFIRM) {
                        // 继续等待
                        
                    } else if (item.replyType == HTTPREPLYTYPE_AGREE) {
                        // 主播同意, 发起进入直播间请求
                        self.status = PreLiveStatus_WaitingEnterRoom;
                        
                        self.statusLabel.text = @"主播同意私密邀请";
                        
                        // 清空邀请
                        self.inviteId = nil;
                        
                        // 重新发送请求
                        [self startRequest];
                        
                    } else if (item.replyType == HTTPREPLYTYPE_REJECT) {
                        // 主播结束拒绝
                        
                        // 清空邀请
                        self.inviteId = nil;
                        
                        // 显示错误提示
                        [self handleError:LCC_ERR_FAIL errMsg:@"主播拒绝了你的邀请"];
                        
                    } else if (item.replyType == HTTPREPLYTYPE_CANCEL) {
                        // 邀请已经取消
                        
                        // 清空邀请
                        self.inviteId = nil;
                        
                        [self handleError:LCC_ERR_FAIL errMsg:@"邀请已经取消"];
                        
                    } else {
                        // 普通错误提示
                        [self handleError:LCC_ERR_FAIL errMsg:@"邀请已经失效"];
                    }
                }
            }
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
    NSLog(@"PreLiveViewController::stopEnterRoomTimer()");

    self.enterRoomQueue = nil;

    @synchronized(self) {
        [self.enterRoomTimer invalidate];
        self.enterRoomTimer = nil;
    }

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
            [self handleError:LCC_ERR_INVITE_TIMEOUT errMsg:@""];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.handleCountDownLabel.text = [NSString stringWithFormat:@"%d s", self.exitLeftSecond];
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

    if (!self.handleQueue) {
        self.handleQueue = dispatch_queue_create("handleQueue", DISPATCH_QUEUE_SERIAL);
    }
    dispatch_async(self.handleQueue, ^{
        self.handleLoop = [NSRunLoop currentRunLoop];
        @synchronized(self) {
            if (!self.handleTimer) {
                self.handleTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                    target:self
                                                                  selector:@selector(handleCountDown)
                                                                  userInfo:nil
                                                                   repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:self.handleTimer forMode:NSDefaultRunLoopMode];
            }
        }
        [[NSRunLoop currentRunLoop] run];
    });
    }

    -(void)stopHandleTimer {
        NSLog(@"PreLiveViewController::stopHandleTimer()");

        self.handleQueue = nil;

        @synchronized(self) {
            [self.handleTimer invalidate];
            self.handleTimer = nil;
        }

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
                                placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    cell.nameLabel.text = item.nickName;
    
    return cell;
}

@end
