//
//  LSVIPLiveViewController.m
//  livestream
//
//  Created by Calvin on 2019/8/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSVIPLiveViewController.h"

#import "LiveFinshViewController.h"
#import "LiveWebViewController.h"
#import "LSAddCreditsViewController.h"

#import "LiveModule.h"
#import "LiveUrlHandler.h"

#import "LiveGobalManager.h"
#import "LiveStreamPublisher.h"


#import "MsgTableViewCell.h"
#import "TalentMsgCell.h"
#import "HangOutOpenDoorCell.h"
#import "LSInviteHangoutMsgCell.h"
#import "MsgItem.h"

#import "LikeView.h"
#import "DialogChoose.h"

#import "LSFileCacheManager.h"
#import "LSSessionRequestManager.h"
#import "LSGiftManager.h"
#import "LSChatEmotionManager.h"
#import "LiveStreamSession.h"
#import "LSRoomUserInfoManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "PraviteLiveMsgManager.h"
#import "LSConfigManager.h"

#import "AudienceModel.h"
#import "GetNewFansBaseInfoRequest.h"
#import "LSSendinvitationHangoutRequest.h"
#import "LSGetHangoutInvitStatusRequest.h"

#import "DialogChoose.h"
#import "DialogTip.h"
#import "DialogWarning.h"
#import "LSShadowView.h"
#import "LSCreditView.h"
#import "PrivateDriveView.h"

#import "LSCancelInviteHangoutRequest.h"
#import "LSUserInfoManager.h"

#define RECORD_START @"!record=1!"
#define RECORD_STOP @"!record=0!"

#define DEBUG_START @"!debug=1!"
#define DEBUG_STOP @"!debug=0!"

#define INPUTMESSAGEVIEW_MAX_HEIGHT 44.0 * 2

#define LevelFontSize 14
#define LevelFont [UIFont systemFontOfSize:LevelFontSize]
#define LevelGrayColor [LSColor colorWithIntRGB:56 green:135 blue:213 alpha:255]

#define MessageFontSize 16
#define MessageFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:MessageFontSize]

#define NameFontSize 14
#define NameFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:NameFontSize]

#define NameColor [LSColor colorWithIntRGB:255 green:210 blue:5 alpha:255]
#define MessageTextColor [UIColor whiteColor]

#define MessageCount 500

#define TIMECOUNT 30

#define OpenDoorHeight 71

#pragma mark - 流[播放/推送]逻辑
#define STREAM_PLAYER_RECONNECT_MAX_TIMES 5
#define STREAM_PUBLISH_RECONNECT_MAX_TIMES STREAM_PLAYER_RECONNECT_MAX_TIMES

@interface LSVIPLiveViewController ()<UITextFieldDelegate, LSCheckButtonDelegate, GiftComboViewDelegate, IMLiveRoomManagerDelegate, IMManagerDelegate, DriveViewDelegate, MsgTableViewCellDelegate, LiveStreamPlayerDelegate, LiveStreamPublisherDelegate, LiveGobalManagerDelegate, TalentMsgCellDelegate, LSInviteHangoutMsgCellDelegate,LSCreditViewDelegate>
#pragma mark - 流[播放/推送]管理
// 流播放地址
@property (nonatomic, copy) NSString *playUrl;

// 流播放重连次数
@property (assign) NSUInteger playerReconnectTime;
// 流推送地址
@property (strong) NSString *publishUrl;
// 流推送组件
@property (strong) LiveStreamPublisher *publisher;
// 流推送重连次数
@property (assign) NSUInteger publisherReconnectTime;

#pragma mark - 观众管理
// 观众数组
@property (strong) NSMutableArray *audienArray;

#pragma mark - 消息列表
/**
 用于显示的消息列表
 @description 注意在主线程操作
 */
@property (strong) NSMutableArray<MsgItem *> *msgShowArray;
/**
 用于保存真实的消息列表
 @description 注意在主线程操作
 */
@property (strong) NSMutableArray<MsgItem *> *msgArray;
/**
 是否需要刷新消息列表
 @description 注意在主线程操作
 */
@property (assign) BOOL needToReload;

#pragma mark - 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

#pragma mark - 礼物管理器
@property (nonatomic, strong) GiftComboManager *giftComboManager;

#pragma mark - 用户信息管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

#pragma mark - 礼物连击界面
@property (nonatomic, strong) NSMutableArray<GiftComboView *> *giftComboViews;
@property (nonatomic, strong) NSMutableArray<MASConstraint *> *giftComboViewsLeadings;

#pragma mark - 礼物下载器
@property (nonatomic, strong) LSGiftManager *giftDownloadManager;

#pragma mark - 表情管理器
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;

#pragma mark - 消息管理器
@property (nonatomic, strong) PraviteLiveMsgManager *msgManager;

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

#pragma mark - 倒数控制
// 视频按钮倒数
@property (strong) LSTimer *videoBtnTimer;
// 视频按钮消失倒数
@property (nonatomic, assign) int videoBtnLeftSecond;

#pragma mark - 图片下载器
@property (nonatomic, strong) LSImageViewLoader *headImageLoader;
@property (nonatomic, strong) LSImageViewLoader *giftImageLoader;
@property (nonatomic, strong) LSImageViewLoader *cellHeadImageLoader;

#pragma mark - 倒计时关闭直播间
@property (strong) LSTimer *timer;
@property (nonatomic, assign) NSInteger timeCount;

#pragma mark - 弹幕
// 显示的弹幕数量 用于判断隐藏弹幕阴影
@property (nonatomic, assign) int showToastNum;

#pragma mark - 对话框
@property (strong) DialogTip *dialogProbationTip;
@property (strong) DialogWarning *dialogView;
@property (strong) DialogChoose *dialogChoose;

#pragma mark - 用于显示试用倦提示
@property (nonatomic, assign) BOOL showTip;

#pragma mark - 后台处理
@property (nonatomic, assign) BOOL isBackground;

// 是否已退入后台超时
@property (nonatomic, assign) BOOL isTimeOut;

// 是否是推荐邀请Hangout
@property (nonatomic, assign) BOOL isRecommend;
// 是否邀请Hangout成功
@property (nonatomic, assign) BOOL isInviteHangout;
// 是否正在Hangout邀请
@property (nonatomic, assign) BOOL isInvitingHangout;
// HangOut邀请ID
@property (nonatomic, copy) NSString *hangoutInviteId;
// Hangout邀请主播名称 ID
@property (nonatomic, copy) NSString *hangoutAnchorName;
@property (nonatomic, copy) NSString *hangoutAnchorId;
// push跳转Url
@property (nonatomic, strong) NSURL *pushUrl;

@property (nonatomic, assign) BOOL isDriveShow;

@property (nonatomic, strong) LSCreditView * creditView;

@property (nonatomic, strong) PrivateDriveView *privateDriveView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *liveHeadDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoTopDIstance;

// 记录收起前的消息行数
@property (nonatomic, assign) NSInteger msgPushDownLastRow;

@end

@implementation LSVIPLiveViewController

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    NSLog(@"LSVIPLiveViewController::initCustomParam()");
    
    self.isShowNavBar = NO;
    
    // 初始化流组件
    self.playUrl = @"rtmp://172.25.32.133:7474/test_flash/max_mv";
    self.player = [LiveStreamPlayer instance];
    self.player.delegate = self;
    self.playerReconnectTime = 0;
    
    self.publishUrl = @"rtmp://172.25.32.133:7474/test_flash/max_i";
    self.publisher = [LiveStreamPublisher instance:LiveStreamType_Audience_Private];
    self.publisher.delegate = self;
    self.publisherReconnectTime = 0;
    
    // 初始化消息
    self.msgArray = [NSMutableArray array];
    self.msgShowArray = [NSMutableArray array];
    self.needToReload = NO;
    
    // 初始请求管理器
    self.sessionManager = [LSSessionRequestManager manager];
    
    // 初始化IM管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    // 初始化后台管理器
    [[LiveGobalManager manager] addDelegate:self];
    
    // 初始登录
    self.loginManager = [LSLoginManager manager];
    self.giftComboManager = [[GiftComboManager alloc] init];
    
    // 初始化用户信息管理器
    self.roomUserInfoManager = [LSRoomUserInfoManager manager];
    
    // 初始化礼物管理器
    self.giftDownloadManager = [LSGiftManager manager];
    
    // 初始化表情管理器
    self.emotionManager = [LSChatEmotionManager emotionManager];
    
    // 初始化文字管理器
    self.msgManager = [[PraviteLiveMsgManager alloc] init];
    
    // 初始化余额及返点信息管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
    
    // 初始化大礼物播放队列
    self.bigGiftArray = [NSMutableArray array];
    
    // 初始化观众队列
    self.audienArray = [[NSMutableArray alloc] init];
    
    // 显示的弹幕数量
    self.showToastNum = 0;
    
    // 初始化视频控制按钮消失计时器
    self.videoBtnLeftSecond = 3;
    
    // 图片下载器
    self.headImageLoader = [LSImageViewLoader loader];
    self.giftImageLoader = [LSImageViewLoader loader];
    self.cellHeadImageLoader = [LSImageViewLoader loader];
    
    // 注册前后台切换通知
    _isBackground = NO;
    self.isTimeOut = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 注册大礼物结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationWhatIs:) name:@"GiftAnimationIsOver" object:nil];
    
    // 初始化计时器
    self.videoBtnTimer = [[LSTimer alloc] init];
    
    // 初始化倒数关闭直播间计时器
    self.timer = [[LSTimer alloc] init];
    
    self.dialogProbationTip = [DialogTip dialogTip];
    self.showTip = YES;
    
    // 初始化是否推荐邀请hangout
    self.isRecommend = NO;
    // 初始化是否邀请多人互动成功
    self.isInviteHangout = NO;
    // 初始化是否正在多人互动邀请
    self.isInvitingHangout = NO;
    // 聊天列表顶部间隔
    self.topInterval = 0;
    self.isMsgPushDown = NO;
    // 初始化上一条消息位置
    self.msgPushDownLastRow = -2;
}

- (void)dealloc {
    NSLog(@"LSVIPLiveViewController::dealloc()");
    
    if (self.dialogChoose) {
        [self.dialogChoose removeFromSuperview];
    }
    
    // 去除大礼物结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftAnimationIsOver" object:nil];
    
    [self.giftComboManager removeManager];
    
    for (GiftComboView *giftView in self.giftComboViews) {
        [giftView stopGiftCombo];
    }
    
    [self.timer stopTimer];
    
    // 移除直播间后台代理监听
    [[LiveGobalManager manager] removeDelegate:self];
    [[LiveGobalManager manager] setupLiveVC:nil orHangOutVC:nil];
    
    // 移除直播间IM代理监听
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    // 停止流
    [self stopPlay];
    [self stopPublish];
    
    //取消hangout邀请
    if (self.isInvitingHangout) {
        [self sendCancelHangoutInvit];
    }
    
    self.creditView.hidden = YES;
    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (self.liveRoom.roomId.length > 0) {
        // 发送退出直播间
        NSLog(@"LSVIPLiveViewController::dealloc( [发送退出直播间], roomId : %@ )", self.liveRoom.roomId);
        [self.imManager leaveRoom:self.liveRoom];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 赋值到全局变量, 用于后台计时操作
    [LiveGobalManager manager].liveRoom = self.liveRoom;
    // 赋值到全局变量 用于观看信件或chat视频关闭直播声音
    [[LiveGobalManager manager] setupVIPLiveVC:self orHangOutVC:nil];
    
    // 禁止锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    // 初始化消息列表
    [self setupTableView];
    
    // 初始化连击控件
    [self setupGiftView];
    
    // 初始化视频界面
    self.player.playView = self.videoView;
    self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    //鲜花礼品按钮判断
    if ([LSLoginManager manager].loginItem.userPriv.isGiftFlowerPriv && [LSLoginManager manager].loginItem.isGiftFlowerSwitch) {
        self.camBtnBottom.constant = 192;
        self.stroeBtn.hidden = NO;
    }else {
        self.camBtnBottom.constant = 143;
        self.stroeBtn.hidden = YES;
    }
    
    // 弹幕
    //self.barrageView.hidden = YES;
    
    // 隐藏互动直播ActivityView
    self.preActivityView.hidden = YES;
    
    // 隐藏startOneView
    //[self hiddenStartOneView];
    
    self.creditView = [[LSCreditView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.creditView.delegate = self;
    [self.navigationController.view addSubview:self.creditView];
    self.creditView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self hideNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    //self.barrageView.hidden = YES;
    
    self.bigGiftArray = nil;
    [self.giftAnimationView removeFromSuperview];
    self.giftAnimationView = nil;
    
    if (self.dialogProbationTip.isShow) {
        [self.dialogProbationTip removeShow];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        // 刷新双向视频状态
        [self reloadVideoStatus];
        
        // 第一次进入,未播流显示蒙层
        self.bgView.hidden = NO;
        // 获取用户头像
        
        if (self.liveRoom.roomPhotoUrl.length > 0) {
            // 当前用户
            [self.headImageLoader loadImageFromCache:self.bgImageView
                                             options:SDWebImageRefreshCached
                                            imageUrl:self.liveRoom.roomPhotoUrl
                                    placeholderImage:nil
                                       finishHandler:^(UIImage *image){
                                       }];
        }else {
            
            [[LSUserInfoManager manager] getUserInfo:self.liveRoom.userId finishHandler:^(LSUserInfoModel *item) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 当前用户
                    [self.headImageLoader loadImageFromCache:self.bgImageView
                                                     options:SDWebImageRefreshCached
                                                    imageUrl:item.anchorInfo.roomPhotoUrl
                                            placeholderImage:nil
                                               finishHandler:^(UIImage *image){
                                               }];
                });
            }];
        
        }
        
        


        // 开始播放流
        [self play];
        
        // 自己座驾入场
        [self getDriveInfo:self.loginManager.loginItem.userId];
        
        // 插入是否具有试聊卷
        [self useVoucher];
    }
    
    // 开始计时器
    [self startVideoBtnTimer];
    
    [super viewDidAppear:animated];
    
    //    [self test];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 停止计时器
    [self stopVideoBtnTimer];
    
    //    [self stopTest];
}

- (void)setupContainView {
    [super setupContainView];
    
    // 初始化返点按钮
    [self setupRewardImageView];
    
    // 初始化弹幕
    //[self setupBarrageView];
    
    // 初始化预览界面
    [self setupPreviewView];
}

- (void)setupRewardImageView {
    // 设置返点按钮
    //self.rewardedBgView.layer.cornerRadius = 10;
}

- (void)bringSubviewToFrontFromView:(UIView *)view {
    
    [self.view bringSubviewToFront:self.giftView];
    //[self.view bringSubviewToFront:self.barrageView];
    //    [self.view bringSubviewToFront:self.cameraBtn];
    [self.view insertSubview:view belowSubview:self.giftView];
//    [view bringSubviewToFront:self.giftView];
    
}

- (void)showRoomTipView:(NSString *)tip {
    NSAttributedString * str = [[NSAttributedString alloc]initWithString:tip];
    [self addTips:str];
}

/** 显示买点弹框 **/
- (void)showAddCreditsView:(NSString *)tip {
    
    if (self.viewIsAppear) {
        // 弹出没点弹层收起键盘
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        // 设置没点弹层的层级
        [self.navigationController.view bringSubviewToFront:self.creditView];
        self.creditView.tipLabel.text = tip;
        self.creditView.hidden = NO;
    }
}

- (void)creditViewDidAddCredit {
    if ([self.liveDelegate respondsToSelector:@selector(noCreditPushTo:)]) {
        [self.liveDelegate noCreditPushTo:self];
    }
}

- (void)showManPushErrorView:(NSString *)msg retey:(BOOL)retey {
    // 显示开启/关闭双向视频错误弹框
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *closeAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (retey) {
            [self showManPushView:!retey];
        }
    }];
    
    UIAlertAction *retryAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.liveRoom) {
            [self sendVideoControl:retey];
        }
    }];
    [alertVC addAction:closeAC];
    [alertVC addAction:retryAC];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)showManPushView:(BOOL)start {
    // 显示双向视频界面
    self.camBtn.hidden = start;
    self.previewView.hidden = !start;
    self.shadowImageView.hidden = NO;
    if (start) {
        [self.view bringSubviewToFront:self.previewView];
    } else {
        [self stopPublish];
    }
}

#pragma mark - 界面事件

- (IBAction)pushDownChatList:(id)sender {
    if (!self.isMsgPushDown) {
        if (self.msgTableView.indexPathsForVisibleRows.count > 0) {
            self.msgPushDownLastRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
        }
        // 旋转180度
        self.pushDownBtn.transform = CGAffineTransformMakeRotation(M_PI);
        self.msgTableViewTop.constant = self.msgSuperViewH.constant;
        self.isMsgPushDown = YES;
    } else {
        // 按钮还原
        self.pushDownBtn.transform = CGAffineTransformIdentity;
        if (self.topInterval < self.msgSuperViewH.constant) {
            self.msgTableViewTop.constant = self.msgSuperViewH.constant - self.topInterval;
        } else {
            self.msgTableViewTop.constant = 0;
        }
        self.isMsgPushDown = NO;
        // 如果之前在最新消息则展开滑动到最底
        NSInteger lastRow = self.msgShowArray.count - 1;
        if (self.msgPushDownLastRow >= lastRow) {
            [self scrollToEnd:NO];
        }
    }
}
 
- (IBAction)showBtnDid:(UIButton *)sender {
    self.stopVideoBtn.hidden = NO;
    //    self.muteBtn.hidden = NO;
    self.showBtn.hidden = YES;
    @synchronized(self) {
        self.videoBtnLeftSecond = 3;
    }
}

- (IBAction)startManPush:(id)sender {
    // TODO:点击开始视频互动

    // 关闭所有输入
    if ([self.liveDelegate respondsToSelector:@selector(closeAllInputView:)]) {
        [self.liveDelegate closeAllInputView:self];
    }
    
    [[LiveModule module].analyticsManager reportActionEvent:PrivateBroadcastClickVideo eventCategory:EventCategoryBroadcast];
    
    // 开始视频互动
    if (![LSConfigManager manager].dontShow2WayVideoDialog) {
        if (self.dialogChoose) {
            [self.dialogChoose removeFromSuperview];
        }
        self.dialogChoose = [DialogChoose dialog];
        NSString *price = [NSString stringWithFormat:@"%.2f", self.liveRoom.imLiveRoom.manPushPrice];
        NSString *tips = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"PUSH_TIPS"), price];
        self.dialogChoose.tipsLabel.text = tips;
        WeakObject(self, weakSelf);
        [self.dialogChoose showDialog:self.liveRoom.superView
                          cancelBlock:^{
                              // 保存参数
                              [LSConfigManager manager].dontShow2WayVideoDialog = weakSelf.dialogChoose.checkBox.on;
                              [[LSConfigManager manager] saveConfigParam];
                          }
                          actionBlock:^{
                              // 保存参数
                              [LSConfigManager manager].dontShow2WayVideoDialog = weakSelf.dialogChoose.checkBox.on;
                              [[LSConfigManager manager] saveConfigParam];
                              
                              // 开始视频互动
                              if (weakSelf.creditRebateManager.mCredit) {
                                  [weakSelf showManPushView:YES];
                                  [weakSelf sendVideoControl:YES];
                              } else {
                                  [weakSelf showAddCreditsView:NSLocalizedStringFromSelf(@"CAM_NO_CREDITS")];
                              }
                          }];
    } else {
        // 开始视频互动
        if (self.creditRebateManager.mCredit) {
            [self showManPushView:YES];
            [self sendVideoControl:YES];
        } else {
            [self showAddCreditsView:NSLocalizedStringFromSelf(@"CAM_NO_CREDITS")];
        }
    }
}

- (IBAction)stopVideoAction:(id)sender {
    // TODO:点击关闭视频互动
    
    // 关闭所有输入
    if ([self.liveDelegate respondsToSelector:@selector(closeAllInputView:)]) {
        [self.liveDelegate closeAllInputView:self];
    }
    
    // 关闭视频互动
    [self sendVideoControl:NO];
}

- (void)reloadVideoStatus {
    NSLog(@"LSVIPLiveViewController::reloadVideoStatus( publishUrl : %@ )", self.liveRoom.publishUrl);
    if (self.liveRoom.publishUrl.length > 0) {
        // 已经有推流地址, 发送命令
        [self showManPushView:YES];
        [self sendVideoControl:YES];
    } else {
        // 停止推流
        [self stopPublish];
    }
}

- (IBAction)muteAction:(id)sender {
    self.publisher.mute = !self.publisher.mute;
    //self.muteBtn.selected = !self.muteBtn.selected;
    
    @synchronized(self) {
        self.videoBtnLeftSecond = 3;
    }
}

- (IBAction)startOneOnOneAction:(id)sender {
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:NO completion:nil];
    [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];
    
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" anchorId:self.liveRoom.userId roomType:LiveRoomType_Private];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}


- (IBAction)startHangoutBtnDid:(UIButton *)sender {
    if ([self.liveDelegate respondsToSelector:@selector(showHangoutTipView:)]) {
        [self.liveDelegate showHangoutTipView:self];
    }
}

- (IBAction)storeBtnDid:(id)sender {
    if ([self.liveDelegate respondsToSelector:@selector(pushStoreVC:)]) {
        [self.liveDelegate pushStoreVC:self];
    }
}
#pragma mark - 流[播放/推送]逻辑
- (void)play {
    self.playUrl = self.liveRoom.playUrl;
    NSLog(@"LSVIPLiveViewController::play( [开始播放流], playUrl : %@ )", self.playUrl);
   
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *dateString = [LSDateFormatter toStringYMDHMSWithUnderLine:[NSDate date]];
    NSString *recordFilePath = [LiveModule module].debug ? [NSString stringWithFormat:@"%@/%@_%@.flv", recordDir, self.liveRoom.userId, dateString] : @"";
    NSString *recordH264FilePath = @""; //[NSString stringWithFormat:@"%@/%@", recordDir, @"play.h264"];
    NSString *recordAACFilePath = @"";  //[NSString stringWithFormat:@"%@/%@", recordDir, @"play.aac"];
    
    // 开始转菊花
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bFlag = [self.player playUrl:self.playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 停止菊花
            if (bFlag) {
                // 播放成功
              
            } else {
                // 播放失败
            }
        });
    });
}

- (void)stopPlay {
    NSLog(@"LSVIPLiveViewController::stopPlay()");
    
    [self.player stop];
}

- (void)initPublish {
    NSLog(@"LSVIPLiveViewController::initPublish( [初始化推送流] )");
    // 初始化采集
    [[LiveStreamSession session] checkAudio:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Open_Permissions_Tip") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *_Nonnull action){
                                                                     
                                                                 }];
                [alertVC addAction:actionOK];
                [self presentViewController:alertVC animated:NO completion:nil];
            }
        });
    }];
    
    [[LiveStreamSession session] checkVideo:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Open_Permissions_Tip") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *_Nonnull action){
                                                                     
                                                                 }];
                [alertVC addAction:actionOK];
                [self presentViewController:alertVC animated:NO completion:nil];
            }
        });
    }];
    
    // 初始化预览界面
    self.publisher.publishView = self.previewVideoView;
    self.publisher.publishView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
}

- (void)publish {
    self.publishUrl = self.liveRoom.publishUrl;
    NSLog(@"LSVIPLiveViewController::publish( [开始推送流], publishUrl : %@ )", self.publishUrl);
   
    [self.publisher pushlishUrl:self.publishUrl recordH264FilePath:@"" recordAACFilePath:@""];
}

- (void)stopPublish {
    NSLog(@"LSVIPLiveViewController::stopPublish()");
    [self.publisher stop];
}


#pragma mark - 流[播放/推送]通知
- (NSString *)playerShouldChangeUrl:(LiveStreamPlayer *)player {
    NSString *url = player.url;
    
    @synchronized(self) {
        if (self.playerReconnectTime++ > STREAM_PLAYER_RECONNECT_MAX_TIMES) {
            // 断线超过指定次数, 切换URL
            url = [self.liveRoom changePlayUrl];
            self.playerReconnectTime = 0;
            
            NSLog(@"LSVIPLiveViewController::playerShouldChangeUrl( [切换播放流URL], url : %@)", url);
        }
    }
    
    return url;
}

- (NSString *)publisherShouldChangeUrl:(LiveStreamPublisher *)publisher {
    NSString *url = publisher.url;
    
    @synchronized(self) {
        if (self.publisherReconnectTime++ > STREAM_PUBLISH_RECONNECT_MAX_TIMES) {
            // 断线超过指定次数, 切换URL
            url = [self.liveRoom changePublishUrl];
            self.publisherReconnectTime = 0;
            
            NSLog(@"LSVIPLiveViewController::publisherShouldChangeUrl( [切换推送流URL], url : %@)", url);
        }
    }
    
    return url;
}


- (void)playerOnConnect:(LiveStreamPlayer * _Nonnull)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bgView.hidden = YES;
    });

}

- (void)playerOnDisconnect:(LiveStreamPlayer * _Nonnull)player {
    dispatch_async(dispatch_get_main_queue(), ^{

    });
//    self.bgView.hidden = NO;
}

- (void)publisherOnConnect:(LiveStreamPublisher * _Nonnull)publisher {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.shadowImageView.hidden = YES;
    });
    NSString *url = publisher.url;
    NSLog(@"LSVIPLiveViewController::publisherOnConnect( [推送流URL], url : %@)", url);
}

#pragma mark - 关闭/开启直播间声音(LiveChat使用)
- (void)openOrCloseSuond:(BOOL)isClose {
    self.publisher.mute = isClose;
    self.player.mute = isClose;
}


#pragma mark - 试聊卷
- (void)useVoucher {
    if (self.liveRoom.imLiveRoom.usedVoucher) {
        NSString *msg = [NSString stringWithFormat:@"%d",(int)self.liveRoom.imLiveRoom.useCoupon];
        NSAttributedString *atrStr = [[NSAttributedString alloc] initWithString:msg];
        [self addVouchTips:atrStr];
    }
}


#pragma mark - 初始化座驾控件

- (PrivateDriveView *)privateDriveView {
    if (!_privateDriveView) {
        _privateDriveView = [[PrivateDriveView alloc] init];
    }
    return _privateDriveView;
}

#pragma mark - 座驾（入场信息）
- (void)showDriveView:(AudienceModel *)model {
    self.privateDriveView.model = model;
    [self.view addSubview:self.privateDriveView];
    self.privateDriveView.alpha = 0;
    [self.privateDriveView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.offset(68);
        make.right.offset(-17);
        make.width.offset(83);
        make.height.offset(83);
    }];
   
    // 座驾动画
    [UIView animateWithDuration:1 animations:^{
        self.privateDriveView.alpha = 1;
    } completion:^(BOOL finished) {
        // 平移动画
        [self.privateDriveView showCarAnimation:CGPointMake(60, 211)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1 animations:^{
                self.privateDriveView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.privateDriveView removeFromSuperview];
                self.privateDriveView = nil;
            }];
        });
        
    }];
}

- (void)getDriveInfo:(NSString *)userId {
    
    NSLog(@"LSVIPLiveViewController::getDriveInfo( [获取座驾], userId : %@ )", userId);
    [self.roomUserInfoManager getFansBaseInfo:userId
                                finishHandler:^(LSUserInfoModel * item) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        @synchronized(self) {
                                            if (item.riderId.length > 0) {
                                                AudienceModel *model = [[AudienceModel alloc] init];
                                                model.userid = userId;
                                                model.nickname = item.nickName;
                                                model.photourl = item.photoUrl;
                                                model.riderid = item.riderId;
                                                model.riderurl = item.riderUrl;
                                                model.ridername = item.riderName;
                                                [self.audienArray addObject:model];
                                                
                                                
                                                if (!self.isDriveShow) {
                                                    self.isDriveShow = YES;
                                                    [self showDriveView:model];
                                                }
                                
                                                
                                                // 插入自己座驾入场消息
                                                [self addRiderJoinMessageNickName:item.nickName riderName:item.riderName honorUrl:self.liveRoom.imLiveRoom.honorImg fromId:self.loginManager.loginItem.userId isHasTicket:self.liveRoom.httpLiveRoom.showInfo.ticketStatus == PROGRAMTICKETSTATUS_BUYED ? YES : NO];
                                                
                                            } else {
                                                // 插入自己入场消息
                                                MsgItem *msgItem = [self addJoinMessageNickName:item.nickName honorUrl:self.liveRoom.imLiveRoom.honorImg fromId:self.loginManager.loginItem.userId isHasTicket:self.liveRoom.httpLiveRoom.showInfo.ticketStatus == PROGRAMTICKETSTATUS_BUYED ? YES : NO];
                                                [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
                                            }
                                        }
                                    });
                                }];
}


#pragma mark - 连击管理
- (void)setupGiftView {
    [self.giftView removeAllSubviews];
    
    self.giftComboViews = [NSMutableArray array];
    self.giftComboViewsLeadings = [NSMutableArray array];
    
    GiftComboView *preGiftComboView = nil;
    
    for (int i = 0; i < 2; i++) {
        GiftComboView *giftComboView = [GiftComboView giftComboView:self];
        [self.giftView addSubview:giftComboView];
        [self.giftComboViews addObject:giftComboView];
        
        giftComboView.tag = i;
        giftComboView.delegate = self;
        giftComboView.hidden = YES;
        
        UIImage *image = self.roomStyleItem.comboViewBgImage; // [UIImage imageNamed:@"Live_Public_Bg_Combo"]
        [giftComboView.backImageView setImage:image];
        
        NSNumber *height = [NSNumber numberWithInteger:giftComboView.frame.size.height];
        
        if (!preGiftComboView) {
            [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.giftView);
                make.width.equalTo(@220);
                make.height.equalTo(height);
                MASConstraint *leading = make.left.equalTo(self.giftView.mas_left).offset(-220);
                [self.giftComboViewsLeadings addObject:leading];
            }];
            
        } else {
            [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(preGiftComboView.mas_top).offset(-5);
                make.width.equalTo(@220);
                make.height.equalTo(height);
                MASConstraint *leading = make.left.equalTo(self.giftView.mas_left).offset(-220);
                [self.giftComboViewsLeadings addObject:leading];
            }];
        }
        
        preGiftComboView = giftComboView;
    }
}

- (BOOL)showCombo:(GiftItem *)giftItem giftComboView:(GiftComboView *)giftComboView withUserID:(NSString *)userId {
    BOOL bFlag = YES;
    
    giftComboView.hidden = NO;
    
    // 发送人名 礼物名
    giftComboView.nameLabel.text = giftItem.nickname;
    giftComboView.sendLabel.text = [NSString stringWithFormat:@"sent a gift \"%@\"",giftItem.giftname];
    
    
    // 数量
    giftComboView.beginNum = giftItem.multi_click_start;
    giftComboView.endNum = giftItem.multi_click_end;
    
    NSLog(@"LSVIPLiveViewController::showCombo( [显示连击礼物], beginNum : %ld, endNum: %ld, clickID : %ld )", (long)giftComboView.beginNum, (long)giftComboView.endNum, (long)giftItem.multi_click_id);
    
    // 连击礼物
    LSGiftManagerItem *item = [self.giftDownloadManager getGiftItemWithId:giftItem.giftid];
    NSString *imgUrl = item.infoItem.bigImgUrl;
    [self.giftImageLoader loadImageWithImageView:giftComboView.iconImageView
                                         options:0
                                        imageUrl:imgUrl
                                placeholderImage:
     [UIImage imageNamed:@"Live_Gift_Nomal"]
                                   finishHandler:nil];
    
    giftComboView.item = giftItem;
    
    
    // 从左到右
    NSInteger index = giftComboView.tag;
    MASConstraint *giftComboViewsLeading = [self.giftComboViewsLeadings objectAtIndex:index];
    [giftComboViewsLeading uninstall];
    [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
        MASConstraint *newGiftComboViewLeading = make.left.equalTo(self.giftView.mas_left).offset(10);
        [self.giftComboViewsLeadings replaceObjectAtIndex:index withObject:newGiftComboViewLeading];
    }];
    
    [giftComboView reset];
    [giftComboView start];
    
    NSTimeInterval duration = 0.3;
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.giftView layoutIfNeeded];
                         
                     }
                     completion:^(BOOL finished) {
                         // 开始连击
                         [giftComboView playGiftCombo];
                     }];
    
    return bFlag;
}

- (void)addCombo:(GiftItem *)giftItem {
    // 寻找可用界面
    GiftComboView *giftComboView = nil;
    
    for (GiftComboView *view in self.giftComboViews) {
        if (!view.playing) {
            // 寻找空闲的界面
            giftComboView = view;
            
        } else {
            
            if ([view.item.itemId isEqualToString:giftItem.itemId]) {
                
                // 寻找正在播放同一个连击礼物的界面
                giftComboView = view;
                // 更新最后连击数字
                giftComboView.endNum = giftItem.multi_click_end;
                break;
            }
        }
    }
    
    if (giftComboView) {
        // 有空闲的界面
        if (!giftComboView.playing) {
            // 开始播放新的礼物连击
            [self showCombo:giftItem giftComboView:giftComboView withUserID:giftItem.fromid];
            NSLog(@"LSVIPLiveViewController::addCombo( [增加连击礼物, 播放], starNum : %ld, endNum : %ld, clickID : %ld )", (long)giftItem.multi_click_start, (long)giftItem.multi_click_end, (long)giftItem.multi_click_id);
        }
        
    } else {
        // 没有空闲的界面, 放到缓存
        [self.giftComboManager pushGift:giftItem];
        NSLog(@"LSVIPLiveViewController::addCombo( [增加连击礼物, 缓存], starNum : %ld, endNum : %ld, clickID : %ld )", (long)giftItem.multi_click_start, (long)giftItem.multi_click_end, (long)giftItem.multi_click_id);
    }
}

#pragma mark - 连击回调(GiftComboViewDelegate)
- (void)playComboFinish:(GiftComboView *)giftComboView {
    // 收回界面
    NSInteger index = giftComboView.tag;
    MASConstraint *giftComboViewsLeading = [self.giftComboViewsLeadings objectAtIndex:index];
    [giftComboViewsLeading uninstall];
    [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
        MASConstraint *newGiftComboViewLeading = make.left.equalTo(self.giftView.mas_left).offset(-220);
        [self.giftComboViewsLeadings replaceObjectAtIndex:index withObject:newGiftComboViewLeading];
    }];
    giftComboView.hidden = YES;
    [self.giftView layoutIfNeeded];
    
    // 显示下一个
    GiftItem *giftItem = [self.giftComboManager popGift:nil];
    if (giftItem) {
        // 开始播放新的礼物连击
        [self showCombo:giftItem giftComboView:giftComboView withUserID:giftItem.fromid];
    }
}

#pragma mark - 播放大礼物
- (void)starBigAnimationWithGiftID:(NSString *)giftID {
    self.giftAnimationView = [BigGiftAnimationView sharedObject];
    self.giftAnimationView.userInteractionEnabled = NO;
    
    LSGiftManagerItem *item = [self.giftDownloadManager getGiftItemWithId:giftID];
    LSYYImage *image = item.bigGiftImage;
    
    // 判断本地文件是否损伤 有则播放 无则删除重下播放下一个
    if (image) {
        self.giftAnimationView.contentMode = UIViewContentModeScaleAspectFit;
        self.giftAnimationView.image = image;
        [self.liveRoom.superView addSubview:self.giftAnimationView];
        [self.liveRoom.superView bringSubviewToFront:self.giftAnimationView];
        [self.giftAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.liveRoom.superView);
            make.width.height.equalTo(self.liveRoom.superView);
        }];
        [self bringLiveRoomSubView];
        
    } else {
        // 重新下载
        [item download];
        // 结束动画
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GiftAnimationIsOver" object:self userInfo:nil];
    }
}

// 遍历最外层控制器视图 将dialog放到最上层
- (void)bringLiveRoomSubView {
    for (UIView *view in self.liveRoom.superView.subviews) {
        if (IsDialog(view)) {
            [self.liveRoom.superView bringSubviewToFront:view];
        }
    }
}

#pragma mark - 通知大动画结束
- (void)animationWhatIs:(NSNotification *)notification {
    if (self.giftAnimationView) {
        [self.giftAnimationView removeFromSuperview];
        self.giftAnimationView = nil;
        
        if (self.bigGiftArray.count) {
            [self.bigGiftArray removeObjectAtIndex:0];
        }
    }
    if (self.bigGiftArray.count) {
        [self starBigAnimationWithGiftID:self.bigGiftArray[0]];
    }
}

#pragma mark - 弹幕管理
/*
- (void)setupBarrageView {
    self.barrageView.delegate = self;
    self.barrageView.dataSouce = self;
}

#pragma mark - 弹幕回调(BarrageView)
- (NSUInteger)numberOfRowsInTableView:(BarrageView *)barrageView {
    return 1;
}

- (BarrageViewCell *)barrageView:(BarrageView *)barrageView cellForModel:(id<BarrageModelAble>)model {
    BarrageModelCell *cell = [BarrageModelCell cellWithBarrageView:barrageView];
    BarrageModel *bgItem = (BarrageModel *)model;
    cell.model = bgItem;
    NSLog(@"LiveViewController:: barrageView message:%@", bgItem.message);
    // 获取用户头像
    [self.roomUserInfoManager getUserInfo:bgItem.userId
                            finishHandler:^(LSUserInfoModel * item) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.headImageLoader loadImageFromCache:cell.imageViewHeader
                                                                     options:SDWebImageRefreshCached
                                                                    imageUrl:item.photoUrl
                                                            placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]
                                                               finishHandler:^(UIImage *image){
                                                               }];
                                });
                            }];
    
    cell.labelName.text = bgItem.name;
    cell.labelMessage.attributedText = [self.emotionManager parseMessageTextEmotion:bgItem.message font:[UIFont boldSystemFontOfSize:15]];
    
    return cell;
}

- (void)barrageView:(BarrageView *)barrageView didSelectedCell:(BarrageViewCell *)cell {
}

- (void)barrageView:(BarrageView *)barrageView willDisplayCell:(BarrageViewCell *)cell {
    self.showToastNum += 1;
    self.barrageView.hidden = NO;
}

- (void)barrageView:(BarrageView *)barrageView didEndDisplayingCell:(BarrageViewCell *)cell {
    self.showToastNum -= 1;
    
    if (self.showToastNum == 0) {
        self.barrageView.hidden = YES;
    }
}
*/

#pragma mark - 消息列表管理
- (void)setupTableView {
 
    // 防止更改tableview高度cell跳动
    self.msgTableView.estimatedRowHeight = 0;
    self.msgTableView.estimatedSectionFooterHeight = 0;
    self.msgTableView.estimatedSectionHeaderHeight = 0;
    
    [self.msgTableView setTableFooterView:[UIView new]];
    
    self.msgTableView.clipsToBounds = YES;
    self.msgTableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    
    self.msgTipsView.clipsToBounds = YES;
    self.msgTipsView.hidden = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMsgTipsView:)];
    [self.msgTipsView addGestureRecognizer:singleTap];
    
   // [self.view insertSubview:self.barrageView aboveSubview:self.tableSuperView];
}

- (BOOL)sendMsg:(NSString *)text isLounder:(BOOL)isLounder {
    BOOL bFlag = NO;
    BOOL bDebug = NO;
    
   
    NSString *str = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 发送IM文本
    if (!bDebug) {
        if (str.length > 0) {
            bFlag = YES;
            if (isLounder) {
                // 调用IM命令(发送弹幕)
                [self sendRoomToastRequestFromText:text];
                
            } else {
                // 调用IM命令(发送直播间消息)
                [self sendRoomMsgRequestFromText:text];
            }
        }
    }
    
    return bFlag;
}

- (void)addVouchTips:(NSAttributedString *)text {
    MsgItem *item = [[MsgItem alloc] init];
    item.text = text.string;
    item.msgType = MsgType_FirstFree;
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:item];
    item.attText = attributeString;
    [self addMsg:item replace:NO scrollToEnd:YES animated:YES];
}

- (void)addTips:(NSAttributedString *)text {
    MsgItem *item = [[MsgItem alloc] init];
    item.text = text.string;
    item.msgType = MsgType_Announce;
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:item];
    item.attText = attributeString;
    [self addMsg:item replace:NO scrollToEnd:YES animated:YES];
}

#pragma mark - 聊天文本消息管理
// 插入普通聊天消息
- (void)addChatMessageNickName:(NSString *)name text:(NSString *)text honorUrl:(NSString *)honorUrl fromId:(NSString *)fromId
                   isHasTicket:(BOOL)isHasTicket {
    // 发送普通消息
    MsgItem *item = [[MsgItem alloc] init];
    
    // 判断是谁发送
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        item.usersType = UsersType_Me;
        
    } else if ([fromId isEqualToString:self.liveRoom.userId]) {
        item.usersType = UsersType_Liver;
        
    } else {
        item.usersType = UsersType_Audience;
    }
    item.msgType = MsgType_Chat;
    item.sendName = name;
    item.text = text;
    item.honorUrl = honorUrl;
    item.isHasTicket = isHasTicket;
    
    if (text.length > 0) {
        NSMutableAttributedString *attributeString = [self.msgManager setupChatMessageStyle:self.roomStyleItem msgItem:item];
        item.attText = [self.emotionManager parseMessageAttributedTextEmotion:attributeString font:MessageFont];
    }
    // 插入到消息列表
    [self addMsg:item replace:NO scrollToEnd:YES animated:YES];
}

// 插入送礼消息
- (void)addGiftMessageNickName:(NSString *)nickName giftID:(NSString *)giftID giftNum:(int)giftNum honorUrl:(NSString *)honorUrl
                        fromId:(NSString *)fromId
                   isHasTicket:(BOOL)isHasTicket {
    
    LSGiftManagerItem *item = [[LSGiftManager manager] getGiftItemWithId:giftID];
    
    MsgItem *msgItem = [[MsgItem alloc] init];
    // 判断是谁发送
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.usersType = UsersType_Me;
        
    } else if ([fromId isEqualToString:self.liveRoom.userId]) {
        msgItem.usersType = UsersType_Liver;
        
    } else {
        msgItem.usersType = UsersType_Audience;
    }
    msgItem.msgType = MsgType_Gift;
    msgItem.giftType = item.infoItem.type;
    msgItem.sendName = nickName;
    msgItem.giftName = item.infoItem.name;
    
    LSGiftManagerItem *giftItem = [[LSGiftManager manager] getGiftItemWithId:giftID];
    msgItem.smallImgUrl = giftItem.infoItem.smallImgUrl;
    
    msgItem.giftNum = giftNum;
    msgItem.honorUrl = honorUrl;
    msgItem.isHasTicket = isHasTicket;
    // 增加文本消息
    NSMutableAttributedString *attributeString = [self.msgManager setupGiftMessageStyle:self.roomStyleItem msgItem:msgItem];
    msgItem.attText = attributeString;
    
    [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
}

- (MsgItem *)addJoinMessageNickName:(NSString *)nickName honorUrl:(NSString *)honorUrl fromId:(NSString *)fromId isHasTicket:(BOOL)isHasTicket {
    MsgItem *msgItem = [[MsgItem alloc] init];
    // 判断是谁
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.usersType = UsersType_Me;
        
    } else if ([fromId isEqualToString:self.liveRoom.userId]) {
        msgItem.usersType = UsersType_Liver;
        
    } else {
        msgItem.usersType = UsersType_Audience;
    }
    msgItem.msgType = MsgType_Join;
    msgItem.sendName = nickName;
    msgItem.honorUrl = honorUrl;
    msgItem.isHasTicket = isHasTicket;
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
    msgItem.attText = attributeString;
    return msgItem;
}

- (void)addRiderJoinMessageNickName:(NSString *)nickName riderName:(NSString *)riderName honorUrl:(NSString *)honorUrl fromId:(NSString *)fromId isHasTicket:(BOOL)isHasTicket {
    // 用户座驾入场信息
    MsgItem *riderItem = [[MsgItem alloc] init];
    // 判断是谁
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        riderItem.usersType = UsersType_Me;
        
    } else if ([fromId isEqualToString:self.liveRoom.userId]) {
        riderItem.usersType = UsersType_Liver;
        
    } else {
        riderItem.usersType = UsersType_Audience;
    }
    riderItem.msgType = MsgType_RiderJoin;
    riderItem.sendName = nickName;
    riderItem.riderName = riderName;
    riderItem.honorUrl = honorUrl;
    riderItem.isHasTicket = isHasTicket;
    NSMutableAttributedString *riderString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:riderItem];
    riderItem.attText = riderString;
    [self addMsg:riderItem replace:NO scrollToEnd:YES animated:YES];
}

- (void)addMsg:(MsgItem *)item replace:(BOOL)replace scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated {
    // 计算文本高度
    if (item.msgType == MsgType_Knock || item.msgType == MsgType_Recommend) {
        item.containerHeight = [self getInviteCellHeight:item];
    } else {
        item.containerHeight = [self computeContainerHeight:item];
    }
    
    // 计算当前显示的位置
    NSInteger lastVisibleRow = -1;
    if (self.msgTableView.indexPathsForVisibleRows.count > 0) {
        lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
    }
    NSInteger lastRow = self.msgShowArray.count - 1;
    
    // 计算消息数量
    BOOL deleteOldMsg = NO;
    if (self.msgArray.count > 0) {
        if (replace) {
            deleteOldMsg = YES;
            // 删除一条最新消息
            [self.msgArray removeObjectAtIndex:self.msgArray.count - 1];
            
        } else {
            deleteOldMsg = (self.msgArray.count >= MessageCount);
            if (deleteOldMsg) {
                // 超出最大消息限制, 删除一条最旧消息
                [self.msgArray removeObjectAtIndex:0];
            }
        }
    }
    // 增加新消息
    [self.msgArray addObject:item];
    
    // 改变tableview高度
    CGFloat time = 0;
    self.topInterval += item.containerHeight;
    if (!self.isMsgPushDown) {
        if (self.topInterval < self.msgSuperViewH.constant) {
            self.msgTableViewTop.constant = self.msgSuperViewH.constant - self.topInterval;
            time = 0.1;
        } else {
            self.msgTableViewTop.constant = 0;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (lastVisibleRow >= lastRow && !self.isMsgPushDown) {
            // 如果消息列表当前能显示最新的消息
            NSInteger count = self.msgArray.count - self.msgShowArray.count;
            
            // 直接刷新
            [self.msgTableView beginUpdates];
            if (deleteOldMsg) {
                if (replace) {
                    // 删除一条最新消息
                    [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.msgShowArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    for (int index = 0; index < count; index++) {
                        // 超出最大消息限制, 删除列表一条旧消息
                        [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }
            }
            
            // 替换显示的消息列表
            self.msgShowArray = [NSMutableArray arrayWithArray:self.msgArray];
            for (int index = 1; index < count+1; index++) {
                // 增加列表一条新消息
                [self.msgTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:lastVisibleRow + index inSection:0]] withRowAnimation:(deleteOldMsg && replace) ? UITableViewRowAnimationNone : UITableViewRowAnimationBottom];
            }
            [self.msgTableView endUpdates];
            
            // 拉到最底
            if (scrollToEnd) {
                [self scrollToEnd:animated];
            }
        } else {
            // 标记为需要刷新数据
            self.needToReload = YES;
            
            // 显示提示信息
            [self showUnReadMsg];
        }
    });
}

- (void)scrollToEnd:(BOOL)animated {
    NSInteger count = [self.msgTableView numberOfRowsInSection:0];
    if (count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
        [self.msgTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
//        CGPoint offset = CGPointMake(0, self.msgTableView.contentSize.height - self.msgSuperViewH.constant);
//        [self.msgTableView setContentOffset:offset animated:animated];
    }
}

- (void)chatListScrollToEnd {
    // 计算当前显示的位置
    NSInteger lastVisibleRow = -1;
    if (self.msgTableView.indexPathsForVisibleRows.count > 0) {
        lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
    }
    NSInteger lastRow = self.msgShowArray.count - 1;
    if (lastVisibleRow <= lastRow) {
        [self scrollToEnd:NO];
    }
}

- (void)showUnReadMsg {
    self.unReadMsgCount++;
    
    if (!self.msgSuperView.hidden) {
        self.msgTipsView.hidden = NO;
    }
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld ", (long)self.unReadMsgCount]];
    [attString addAttributes:@{
                               NSFontAttributeName : [UIFont systemFontOfSize:12],
                               NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838)
                               }
                       range:NSMakeRange(0, attString.length)];
    
    NSMutableAttributedString *attStringMsg = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"UnRead_Messages")];
    [attStringMsg addAttributes:@{
                                  NSFontAttributeName : [UIFont systemFontOfSize:12],
                                  NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838)
                                  }
                          range:NSMakeRange(0, attStringMsg.length)];
    [attString appendAttributedString:attStringMsg];
    self.msgTipsLabel.attributedText = attString;
}

- (void)hideUnReadMsg {
    self.unReadMsgCount = 0;
    self.msgTipsView.hidden = YES;
}

- (void)tapMsgTipsView:(id)sender {
    if (self.msgTableViewTop.constant) {
        if (self.topInterval < self.msgSuperViewH.constant) {
            self.msgTableViewTop.constant = self.msgSuperViewH.constant - self.topInterval;
        } else {
            self.msgTableViewTop.constant = 0;
        }
        self.pushDownBtn.transform = CGAffineTransformIdentity;
        self.isMsgPushDown = NO;
    }
   
    if (self.msgShowArray.count > 0 && self.needToReload) {
        // 同步位置
        [self scrollToEnd:NO];
    }
}

// 可能有用
/**
 聊天图片富文本
 
 @param image 图片
 @param font 字体
 @return 富文本
 */
- (NSAttributedString *)parseImageMessage:(UIImage *)image font:(UIFont *)font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    
    LSChatTextAttachment *attachment = nil;
    
    // 增加表情文本
    attachment = [[LSChatTextAttachment alloc] init];
    //    attachment.bounds = CGRectMake(0, 0, font.lineHeight, font.lineHeight);
    attachment.image = image;
    
    // 生成表情富文本
    NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:attachment];
    [attributeString appendAttributedString:imageString];
    
    return attributeString;
}

- (CGFloat)computeContainerHeight:(MsgItem *)item {
    CGFloat height = 0;
    CGFloat width = 0;
    // 减去label对于背景左右边距
    if (item.msgType == MsgType_Gift || item.msgType == MsgType_Chat) {
        width = self.msgSuperView.frame.size.width - 11;
    } else {
        width = self.msgSuperView.frame.size.width - 18;
    }
    YYTextContainer *container = [[YYTextContainer alloc] init];
    container.size = CGSizeMake(width, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:item.attText];
    // label高度+对于背景上下边距+背景对于父view上下边距
    height = layout.textBoundingSize.height + 6 + 6;
    if (height < 25) {
        height = 25;
    }
    item.layout = layout;
    CGFloat y = (height - layout.textBoundingSize.height - 4) / 2;
    item.labelFrame = CGRectMake(0, y, layout.textBoundingSize.width, layout.textBoundingSize.height);
    return height;
}

- (CGFloat)getInviteCellHeight:(MsgItem *)item {
    CGFloat height = 0;
    CGFloat width = self.msgSuperView.frame.size.width;
    YYTextContainer *container = [[YYTextContainer alloc] init];
    container.size = CGSizeMake(width, CGFLOAT_MAX);
    if (!item.attText.string.length) {
        item.attText = [[NSMutableAttributedString alloc] initWithString:item.text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    }
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:item.attText];
    height = layout.textBoundingSize.height + 10 + 75;
    item.layout = layout;
    return height;
}

#pragma mark - 消息列表列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = self.msgArray ? self.msgArray.count : 0;
    
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgItem *item = [self.msgShowArray objectAtIndex:indexPath.row];
    if (item.msgType == MsgType_Talent) {
        return [TalentMsgCell cellHeight];
    }
    return item.containerHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // 数据填充
    if (indexPath.row < self.msgShowArray.count) {
        MsgItem *item = [self.msgShowArray objectAtIndex:indexPath.row];
        
        switch (item.msgType) {
            case MsgType_Talent: {
                TalentMsgCell *msgCell = [TalentMsgCell getUITableViewCell:tableView];
                [msgCell updateMsg:item];
                msgCell.talentCellDelegate = self;
                cell = msgCell;
            } break;
                
            case MsgType_Knock:
            case MsgType_Recommend: {
                LSInviteHangoutMsgCell *msgCell = [LSInviteHangoutMsgCell getUITableViewCell:tableView];
                msgCell.delagate = self;
                [msgCell upDataInviteMessage:item];
                
//                HangOutOpenDoorCell *msgCell = [tableView dequeueReusableCellWithIdentifier:[HangOutOpenDoorCell cellIdentifier]];
//                msgCell.delagate = self;
//                [msgCell updataChatMessage:item];
                cell = msgCell;
            } break;
                
            default: {
                MsgTableViewCell *msgCell = [tableView dequeueReusableCellWithIdentifier:[MsgTableViewCell cellIdentifier]];
                if (!msgCell) {
                    msgCell = [[MsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MsgTableViewCell cellIdentifier]];
                }
                msgCell.clipsToBounds = YES;
                msgCell.msgDelegate = self;
                [msgCell setupChatMessage:item styleItem:self.roomStyleItem];
                cell = msgCell;
            } break;
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@""];
        if (!cell) {
            cell = [[UITableViewCell alloc] init];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)talentMsgCellDid {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showTalentList" object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger lastVisibleRow = -1;
    if (self.msgTableView.indexPathsForVisibleRows.count > 0) {
        lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
    }
    NSInteger lastRow = self.msgShowArray.count - 1;

    if (self.msgShowArray.count > 0 && lastVisibleRow >= lastRow) {
        // 已经拖动到最底, 刷新界面
        if (self.needToReload) {
            self.needToReload = NO;

            // 收起提示信息
            [self hideUnReadMsg];

            // 刷新消息列表
            self.msgShowArray = [NSMutableArray arrayWithArray:self.msgArray];
            [self.msgTableView reloadData];

            // 同步位置
            [self scrollToEnd:NO];
        }
    }
}

#pragma mark - MsgTableViewCellDelegate
- (void)msgCellRequestHttp:(NSString *)linkUrl {
    LiveWebViewController *webViewController = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
    webViewController.url = linkUrl;
    webViewController.isIntimacy = NO;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - LSInviteHangoutMsgCellDelegate
- (void)inviteHangoutAnchor:(MsgItem *)item {
    [[LiveModule module].analyticsManager reportActionEvent:ClickHangOutNow eventCategory:EventCategoryBroadcast];
    // 处理主播推荐好友请求
    [self inviteAnchorWithHangout:item.recommendItem.recommendId anchorId:item.recommendItem.friendId anchorName:item.recommendItem.friendNickName];
}

#pragma mark - HTTP请求
// TODO:直播间发送Hangout邀请
- (void)inviteAnchorWithHangout:(NSString *)recommendId anchorId:(NSString *)anchorId anchorName:(NSString *)anchorName {
    if (!self.isInvitingHangout) {
        self.isInvitingHangout = YES;
        
        
        LSSendinvitationHangoutRequest *request = [[LSSendinvitationHangoutRequest alloc] init];
        request.roomId = self.liveRoom.roomId;
        request.anchorId = self.liveRoom.userId;
        request.recommendId = recommendId;
        request.isCreateOnly = YES;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * errmsg, NSString * roomId, NSString * inviteId, int expire) {
            NSLog(@"LSVIPLiveViewController::sendHangoutInvite( [发起多人互动邀请], success : %@, errnum : %d, errmsg : %@, roomId : %@, inviteId : %@, expire : %d )",
                  BOOL2SUCCESS(success), errnum, errmsg, roomId, inviteId, expire);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (errnum == HTTP_LCC_ERR_SUCCESS) {
                    // 显示提示控件
                    [self showRoomTipView:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITING_HANG_OUT"), self.liveRoom.userName]];
                    
                    if (recommendId.length > 0) {
                        self.isRecommend = YES;
                    }
                    self.hangoutInviteId = inviteId;
                    self.hangoutAnchorName = anchorName;
                    self.hangoutAnchorId = anchorId;
                } else {
                    self.isInvitingHangout = NO;
                    
                    self.isRecommend = NO;
                    self.isInviteHangout = NO;
                    self.hangoutInviteId = nil;
                    
                    // 如果没钱
                    if (errnum == HTTP_LCC_ERR_NO_CREDIT) {
                        [self showAddCreditsView:NSLocalizedStringFromSelf(@"SEND_INVITE_NO_CREDIT")];
                    }else {
                        // 发送邀请失败提示
                        [self.dialogProbationTip showDialogTip:self.liveRoom.superView tipText:errmsg];
                    }
                }
            });
        };
        [self.sessionManager sendRequest:request];
    }
}

// TODO:查询Hangout邀请状态
- (void)getHangoutInviteStatu {
    
    if (self.hangoutInviteId.length > 0) {
        LSGetHangoutInvitStatusRequest *request = [[LSGetHangoutInvitStatusRequest alloc] init];
        request.inviteId = self.hangoutInviteId;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * errmsg, HangoutInviteStatus status, NSString * roomId, int expire) {
            NSLog(@"LSVIPLiveViewController::getHangoutInviteStatu( [查询多人互动邀请状态] success : %@, errnum : %d, errmsg : %@,"
                  "status : %d, roomId : %@, expire : %d )",
                  BOOL2SUCCESS(success), errnum, errmsg, status, roomId, expire);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    switch (status) {
                        case IMREPLYINVITETYPE_AGREE: {
                            self.isInvitingHangout = YES;
                            self.isInviteHangout = YES;
                            [self showRoomTipView:NSLocalizedStringFromSelf(@"INVITE_SUCCESS_HANGOUT")];
                            if (roomId.length > 0) {
                                // 拼接push跳转多人互动url
                                if (self.isRecommend) {
                                    self.pushUrl = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:roomId anchorId:self.hangoutAnchorId anchorName:self.hangoutAnchorName hangoutAnchorId:self.liveRoom.userId hangoutAnchorName:self.liveRoom.userName];
                                } else {
                                    self.pushUrl = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:roomId anchorId:self.hangoutAnchorId anchorName:self.hangoutAnchorName hangoutAnchorId:@"" hangoutAnchorName:@""];
                                }
                            }
                        } break;
                            
                        case IMREPLYINVITETYPE_NOCREDIT: {
                            self.isInvitingHangout = NO;
                            [self showAddCreditsView:NSLocalizedString(@"INVITE_HANGOUT_ADDCREDIT", nil)];
                        } break;
                            
                        default: {
                            self.isInvitingHangout = NO;
                            self.isRecommend = NO;
                            self.isInviteHangout = NO;
                            self.hangoutInviteId = nil;
                            
                            NSString * name = self.liveRoom.userName;
                            if (name.length > 8) {
                                name = [NSString stringWithFormat:@"%@...",[name substringWithRange:NSMakeRange(0, 3)]];
                            }
                            NSString *tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_REJECT_HANGOUT"), name];
                            [self showRoomTipView:tip];
                        } break;
                    }
                }
            });
        };
        [self.sessionManager sendRequest:request];
    }
}

#pragma mark - IM请求
- (void)sendVideoControl:(BOOL)start {
    
    self.preActivityView.hidden = NO;
    [self.preActivityView startAnimating];
    
    IMControlType type = start ? IMCONTROLTYPE_START : IMCONTROLTYPE_CLOSE;
    BOOL bFlag = [self.imManager controlManPush:self.liveRoom.roomId
                                        control:type
                                  finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSArray<NSString *> *_Nonnull manPushUrl) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          // 隐藏菊花
                                          self.preActivityView.hidden = YES;
                                          
                                          if (success) {
                                              BOOL bChange = YES;
                                              BOOL bSuccess = NO;
                                              
                                              if (start) {
                                                  // 开启视频互动成功
                                                  if (manPushUrl.count > 0) {
                                                      bChange = YES;
                                                      bSuccess = YES;
                                                      // 开始推流
                                                      self.liveRoom.publishUrlArray = manPushUrl;
                                                  } else {
                                                      bChange = NO;
                                                      // 发送关闭命令
                                                      [self.imManager controlManPush:self.liveRoom.roomId control:IMCONTROLTYPE_CLOSE finishHandler:nil];
                                                      // 显示错误弹框
                                                      [self showManPushErrorView:NSLocalizedStringFromSelf(@"OPEN_MAN_PUSH_ERROR") retey:YES];
                                                  }
                                              } else {
                                                // 关闭视频互动成功
                                              }
                                              
                                              // 改变界面状态
                                              if (bSuccess) {
                                                  // 开始推流
                                                  [self publish];
                                              } else {
                                                  // 停止推流
                                                  [self stopPublish];
                                                  // 还原双向视频界面
                                                  [self showManPushView:NO];
                                              }
                                              
                                          } else {
                                              NSString *errStr = start ? @"开启视频互动失败" : @"关闭视频互动失败";
                                              NSLog(@"LSVIPLiveViewController::sendVideoControl( %@, errType : %d )", errStr, errType);
                                              if (start) {
                                                  NSString *tip = errMsg.length > 0 ? errMsg : NSLocalizedStringFromSelf(@"OPEN_MAN_PUSH_ERROR");
                                                  if (errType == LCC_ERR_NO_CREDIT || errType == LCC_ERR_NO_CREDIT_DOUBLE_VIDEO) {
                                                      // 没钱, 弹出充值
                                                      [self showAddCreditsView:NSLocalizedStringFromSelf(@"CAM_NO_CREDITS")];
                                                      [self showManPushView:NO];
                                                  } else {
                                                      // 开启失败错误提示
                                                      [self showManPushErrorView:tip retey:YES];
                                                  }
                                              } else {
                                                  NSString *tip = errMsg.length > 0 ? errMsg : NSLocalizedStringFromSelf(@"CLOSE_MAN_PUSH_ERROR");
                                                  // 关闭失败错误提示
                                                  [self showManPushErrorView:tip retey:NO];
                                              }
                                          }
                                      });
                                  }];
    if (!bFlag) {
        NSString *msg = start ? NSLocalizedStringFromSelf(@"OPEN_MAN_PUSH_ERROR") : NSLocalizedStringFromSelf(@"CLOSE_MAN_PUSH_ERROR");
        [self showManPushErrorView:msg retey:start];
    }
}

- (void)sendRoomToastRequestFromText:(NSString *)text {
    // 发送弹幕
    [self.imManager sendToast:self.liveRoom.roomId nickName:self.loginManager.loginItem.nickName msg:text];
}

- (void)sendRoomMsgRequestFromText:(NSString *)text {
    // 发送直播间消息
    [self.imManager sendLiveChat:self.liveRoom.roomId nickName:self.loginManager.loginItem.nickName msg:text at:nil];
}

#pragma mark - IM通知
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"LSVIPLiveViewController::onLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    
    if (errType == LCC_ERR_SUCCESS) {
        // 重新进入直播间
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.liveRoom.roomId.length) {
                // 获取Hangout邀请回复状态
                [self getHangoutInviteStatu];
                
                [self.imManager enterRoom:self.liveRoom.roomId
                            finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString * errMsg, ImLiveRoomObject * roomItem, ImAuthorityItemObject * priv) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.liveRoom.priv = priv;
                                    if (success) {
                                        NSLog(@"LSVIPLiveViewController::onLogin( [IM登陆, 成功, 重新进入直播间], roomId : %@ isHasOneOnOneAuth :%d, isHasBookingAuth : %d)", self.liveRoom.roomId, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
                                        // 更新直播间信息
                                        [self.liveRoom reset];
                                        self.liveRoom.imLiveRoom = roomItem;
                                        
                                        // 重新推流
                                        [self stopPlay];
                                        [self play];
                                        
                                        // 刷新双向视频状态
                                        [self reloadVideoStatus];
                                        
                                        if ([self.liveDelegate respondsToSelector:@selector(onReEnterRoom:)]) {
                                            [self.liveDelegate onReEnterRoom:self];
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
                                        NSLog(@"LSVIPLiveViewController::onLogin( [IM登陆, 成功, 但直播间已经关闭], roomId : %@ )", self.liveRoom.roomId);
                                        
                                        // 如果是正在邀请Hangout状态 跳转Hangout直播间
                                        if (self.isInviteHangout) {
                                            [self stopPlay];
                                            [self stopPublish];
                                            
                                            LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
                                            [nvc forceToDismissAnimated:NO completion:nil];
                                            [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];
                                            
                                            [[LiveUrlHandler shareInstance] handleOpenURL:self.pushUrl];
                                        } else {
                                            if (errType != LCC_ERR_CONNECTFAIL) {
                                                // 停止推拉流、结束直播
                                                [self stopLiveWithErrtype:LCC_ERR_NOT_FOUND_ROOM errMsg:NSLocalizedStringFromSelf(@"LIVE_NOT_ROOM")];
                                            }
                                        }
                                    }
                                });
                            }];
            } else {
                // 停止推拉流、结束直播
                [self stopLiveWithErrtype:LCC_ERR_NOT_FOUND_ROOM errMsg:NSLocalizedStringFromSelf(@"LIVE_NOT_ROOM")];
            }
        });
    }
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LSVIPLiveViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@, playerReconnectTime : %lu, publisherReconnectTime : %lu )", errType, errmsg, (unsigned long)self.playerReconnectTime, (unsigned long)self.publisherReconnectTime);
    
    @synchronized(self) {
        // IM断开, 重置RTMP断开次数
        self.playerReconnectTime = 0;
        self.publisherReconnectTime = 0;
    }
}

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LSVIPLiveViewController::onSendGift( [发送直播间礼物消息], errmsg : %@, credit : %f, rebateCredit : %f )", errmsg, credit, rebateCredit);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            if (credit >= 0) {
                
                // 设置余额及返点信息管理器
                [self.creditRebateManager setCredit:credit];
            }
            [self.creditRebateManager updateRebateCredit:rebateCredit];
            
        } else if (errType == LCC_ERR_NO_CREDIT) {
            [self showAddCreditsView:NSLocalizedStringFromSelf(@"SENDTOSAT_ERR_ADD_CREDIT")];
        }
    });
}

- (void)onRecvSendGiftNotice:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName giftId:(NSString *)giftId giftName:(NSString *)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(NSString *)honorUrl {
    NSLog(@"LSVIPLiveViewController::onRecvRoomGiftNotice( [接收礼物], roomId : %@, fromId : %@, nickName : %@, giftId : %@, giftName : %@, giftNum : %d, honorUrl : %@ )", roomId, fromId, nickName, giftId, giftName, giftNum, honorUrl);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            // 判断本地是否有该礼物
            BOOL bHave = ([self.giftDownloadManager getGiftItemWithId:giftId] != nil);
            if (bHave) {
                // 连击起始数
                int starNum = multi_click_start - 1;
                
                // 接收礼物消息item
                GiftItem *item = [GiftItem itemRoomId:roomId
                                               fromID:fromId
                                             nickName:nickName
                                               giftID:giftId
                                             giftName:giftName
                                              giftNum:giftNum
                                          multi_click:multi_click
                                              starNum:starNum
                                               endNum:multi_click_end
                                              clickID:multi_click_id];
                
                if (item.giftItem.infoItem.type == GIFTTYPE_COMMON) {
                    // 连击礼物
                    [self addCombo:item];
                    
                } else {
                    // 礼物添加到队列
                    if (!self.bigGiftArray && self.viewIsAppear) {
                        self.bigGiftArray = [NSMutableArray array];
                    }
                    for (int i = 0; i < giftNum; i++) {
                        [self.bigGiftArray addObject:item.giftid];
                    }
                    
                    // 防止动画播完view没移除
                    if (!self.giftAnimationView.isAnimating) {
                        [self.giftAnimationView removeFromSuperview];
                        self.giftAnimationView = nil;
                    }
                    
                    if (!self.giftAnimationView) {
                        // 显示大礼物动画
                        if (self.bigGiftArray.count) {
                            [self starBigAnimationWithGiftID:self.bigGiftArray[0]];
                        }
                    }
                }
                
                if ([fromId isEqualToString:[LSLoginManager manager].loginItem.userId]) {
                    // 插入送礼文本消息
                    [self addGiftMessageNickName:nickName giftID:giftId giftNum:giftNum honorUrl:honorUrl fromId:fromId isHasTicket:self.liveRoom.httpLiveRoom.showInfo.ticketStatus == PROGRAMTICKETSTATUS_BUYED ? YES : NO];
                } else {
                    [self.roomUserInfoManager getUserInfo:fromId
                                            finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    // 插入送礼文本消息
                                                    [self addGiftMessageNickName:nickName giftID:giftId giftNum:giftNum honorUrl:honorUrl fromId:fromId isHasTicket:item.isHasTicket];
                                                });
                                            }];
                }
            } else {
                // 获取礼物详情
                // [self.giftDownloadManager requestListnotGiftID:giftId];
            }
        }
    });
}

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LSVIPLiveViewController::onSendToast( [发送直播间弹幕消息, %@], errmsg : %@, credit : %f, rebateCredit : %f )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errmsg, credit, rebateCredit);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            if (credit >= 0) {
                // 设置余额及返点信息管理器
                [self.creditRebateManager setCredit:credit];
            }
            [self.creditRebateManager updateRebateCredit:rebateCredit];
            
        } else if (errType == LCC_ERR_NO_CREDIT) {
            [self showAddCreditsView:NSLocalizedStringFromSelf(@"SENDTOSAT_ERR_ADD_CREDIT")];
        }
    });
}

- (void)onRecvSendToastNotice:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName msg:(NSString *)msg honorUrl:(NSString *)honorUrl {
    NSLog(@"LSVIPLiveViewController::onRecvSendToastNotice( [接收直播间弹幕通知], roomId : %@, fromId : %@, nickName : %@, msg : %@ honorUrl:%@)", roomId, fromId, nickName, msg, honorUrl);
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.barrageView.hidden = NO;
            
            if ([fromId isEqualToString:[LSLoginManager manager].loginItem.userId]) {
                // 插入普通文本消息
                [self addChatMessageNickName:nickName text:msg honorUrl:honorUrl fromId:fromId isHasTicket:self.liveRoom.httpLiveRoom.showInfo.ticketStatus == PROGRAMTICKETSTATUS_BUYED ? YES : NO];
            } else {
                [self.roomUserInfoManager getUserInfo:fromId
                                        finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                // 插入普通文本消息
                                                [self addChatMessageNickName:nickName text:msg honorUrl:honorUrl fromId:fromId isHasTicket:item.isHasTicket];
                                            });
                                        }];
            }
            // 插入到弹幕
            BarrageModel *bgItem = [BarrageModel barrageModelForName:nickName message:msg urlWihtUserID:fromId];
            NSArray *items = [NSArray arrayWithObjects:bgItem, nil];
            [self.barrageView insertBarrages:items immediatelyShow:YES];
        }
    });
     */
}

- (void)onRecvSendChatNotice:(NSString *)roomId level:(int)level fromId:(NSString *)fromId nickName:(NSString *)nickName msg:(NSString *)msg honorUrl:(NSString *)honorUrl {
    NSLog(@"LSVIPLiveViewController::onRecvSendChatNotice( [接收直播间文本消息通知], roomId : %@, nickName : %@, msg : %@ )", roomId, nickName, msg);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.imLiveRoom.roomId]) {
            
            if ([fromId isEqualToString:[LSLoginManager manager].loginItem.userId]) {
                // 插入聊天消息到列表
                [self addChatMessageNickName:nickName text:msg honorUrl:honorUrl fromId:fromId isHasTicket:self.liveRoom.httpLiveRoom.showInfo.ticketStatus == PROGRAMTICKETSTATUS_BUYED ? YES : NO];
            } else {
                [self.roomUserInfoManager getUserInfo:fromId
                                        finishHandler:^(LSUserInfoModel * item) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                // 插入聊天消息到列表
                                                [self addChatMessageNickName:nickName text:msg honorUrl:honorUrl fromId:fromId isHasTicket:item.isHasTicket];
                                            });
                                        }];
            }
        }
    });
}

- (void)onRecvEnterRoomNotice:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl riderId:(NSString *)riderId riderName:(NSString *)riderName riderUrl:(NSString *)riderUrl fansNum:(int)fansNum honorImg:(NSString *)honorImg isHasTicket:(BOOL)isHasTicket {
    
    NSLog(@"LSVIPLiveViewController::onRecvFansRoomIn( [接收观众进入直播间], roomId : %@, userId : %@, nickName : %@, photoUrl : %@ )", roomId, userId, nickName, photoUrl);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([roomId isEqualToString:self.liveRoom.imLiveRoom.roomId]) {
            if (![userId isEqualToString:self.loginManager.loginItem.userId]) {
                // 如果有座驾
                if (riderId.length) {
                    // 坐骑队列
                    AudienceModel *model = [[AudienceModel alloc] init];
                    model.userid = userId;
                    model.nickname = nickName;
                    model.photourl = photoUrl;
                    model.riderid = riderId;
                    model.ridername = riderName;
                    model.riderurl = riderUrl;
                    [self.audienArray addObject:model];
                    if (!self.isDriveShow) {
                        self.isDriveShow = YES;
                        [self showDriveView:model];
//                        [self.driveView audienceComeInLiveRoom:self.audienArray[0]];
                    }
                    
                    // 用户座驾入场信息
                    [self addRiderJoinMessageNickName:nickName riderName:riderName honorUrl:honorImg fromId:userId isHasTicket:isHasTicket];
                    
                } else { // 如果没座驾
                    // 插入入场消息到列表
                    MsgItem *msgItem = [self addJoinMessageNickName:nickName honorUrl:honorImg fromId:userId isHasTicket:isHasTicket];
                    [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
                }
            }
        }
    });
}

- (void)onRecvRebateInfoNotice:(NSString *)roomId rebateInfo:(RebateInfoObject *)rebateInfo {
    NSLog(@"LSVIPLiveViewController::onRecvRebateInfoNotice( [接收返点通知], roomId : %@ )", roomId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            // 设置余额及返点信息管理器
            IMRebateItem *imRebateItem = [[IMRebateItem alloc] init];
            imRebateItem.curCredit = rebateInfo.curCredit;
            imRebateItem.curTime = rebateInfo.curTime;
            imRebateItem.preCredit = rebateInfo.preCredit;
            imRebateItem.preTime = rebateInfo.preTime;
            [self.creditRebateManager setReBateItem:imRebateItem];
            
            // 更新本地返点信息
            self.liveRoom.imLiveRoom.rebateInfo = rebateInfo;
            
            
            // 插入返点更新文本
            NSString *msg = [NSString stringWithFormat:@"%@ %.2f credits", NSLocalizedStringFromSelf(@"Recv_Rebate"), rebateInfo.preCredit];
            NSAttributedString *atrStr = [[NSAttributedString alloc] initWithString:msg];
            [self addTips:atrStr];
        }
    });
}

- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"LSVIPLiveViewController::onRecvLevelUpNotice( [接收观众等级升级通知], level : %d )", level);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 插入观众等级升级文本
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Recv_Level_Up", @"Recv_Level_Up"), level];
        NSAttributedString *atrStr = [[NSAttributedString alloc] initWithString:msg];
        [self addTips:atrStr];
        
        self.liveRoom.imLiveRoom.manLevel = level;
    });
}

- (void)onRecvLoveLevelUpNotice:(IMLoveLevelItemObject *)loveLevelItem {
    NSLog(@"LSVIPLiveViewController::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知], loveLevel : %d, anchorId: %@, anchorName: %@  )", loveLevelItem.loveLevel, loveLevelItem.anchorId, loveLevelItem.anchorName);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 插入观众等级升级文本
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Recv_Love_Up", @"Recv_Love_Up"), self.liveRoom.userName, loveLevelItem.loveLevel];
        NSAttributedString *atrStr = [[NSAttributedString alloc] initWithString:msg];
        [self addTips:atrStr];
        
        self.liveRoom.imLiveRoom.loveLevel = loveLevelItem.loveLevel;
    });
}

- (void)onRecvRoomKickoffNotice:(NSString *)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *)errmsg credit:(double)credit priv:(ImAuthorityItemObject *)priv {
    NSLog(@"LSVIPLiveViewController::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ credit:%f, isHasOneOnOneAuth :%d, isHasBookingAuth : %d", roomId, credit, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.liveRoom.priv = priv;
            // 发送退出直播间
            [self.imManager leaveRoom:self.liveRoom];
            
            // 设置余额及返点信息管理器
            if (credit >= 0) {
                [self.creditRebateManager setCredit:credit];
            }
            
            LCC_ERR_TYPE type;
            if (errType == LCC_ERR_NO_CREDIT || errType == LCC_ERR_COUPON_FAIL) {
                type = errType;
            } else {
                type = LCC_ERR_ROOM_LIVEKICKOFF;
            }
            // 停止推拉流、显示结束直播间界面
            [self stopLiveWithErrtype:type errMsg:errmsg];
        }
    });
}

- (void)onRecvLackOfCreditNotice:(NSString *)roomId msg:(NSString *)msg credit:(double)credit errType:(LCC_ERR_TYPE)errType {
    NSLog(@"LSVIPLiveViewController::onRecvLackOfCreditNotice( [接收充值通知], roomId : %@ credit:%f errType:%d", roomId, credit, errType);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 设置余额及返点信息管理器
        if (credit >= 0) {
            [self.creditRebateManager setCredit:credit];
        }
        
        [self showAddCreditsView:NSLocalizedStringFromSelf(@"WATCHING_WILL_NO_MONEY")];
        
        if (errType == LCC_ERR_NO_CREDIT_DOUBLE_VIDEO_NOTICE) {
            [self sendVideoControl:NO];
        }
    });
}

- (void)onRecvCreditNotice:(NSString *)roomId credit:(double)credit {
    NSLog(@"LSVIPLiveViewController::onRecvCreditNotice( [接收定时扣费通知], roomId : %@, credit : %f ）", roomId, credit);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 设置余额及返点信息管理器
        if (credit >= 0) {
            [self.creditRebateManager setCredit:credit];
        }
    });
}

- (void)onRecvSendTalentNotice:(ImTalentReplyObject *)item {
    NSLog(@"LSVIPLiveViewController::onRecvSendTalentNotice( [接收直播间才艺点播回复通知] )");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (item.status == TALENTSTATUS_AGREE && item.credit >= 0) {
           
            [self starBigAnimationWithGiftID:item.giftId];
        }
    });
}

- (void)onRecvTalentPromptNotice:(NSString *)roomId introduction:(NSString *)introduction {
    NSLog(@"LSVIPLiveViewController::onRecvTalentPromptNotice( [接收直播间才艺点播提示公告通知] :%@)", introduction);
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        if ([self.liveRoom.roomId isEqualToString:roomId]) {
    //            MsgItem *msgItem = [[MsgItem alloc] init];
    //            msgItem.msgType = MsgType_Talent;
    //            msgItem.honorUrl = self.liveRoom.photoUrl;
    //            msgItem.toName = self.liveRoom.userName;
    //            msgItem.text = introduction;
    //            [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
    //        }
    //    });
}

- (void)onRecvSendSystemNotice:(NSString *)roomId msg:(NSString *)msg link:(NSString *)link type:(IMSystemType)type {
    NSLog(@"LSVIPLiveViewController::onRecvSendSystemNotice( [接收直播间公告消息], roomId : %@, msg : %@, link: %@ type:%d)", roomId, msg, link, type);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            MsgItem *msgItem = [[MsgItem alloc] init];
            if (type == IMSYSTEMTYPE_COMMON) {
                msgItem.text = msg;
                if ([link isEqualToString:@""] || link == nil) {
                    msgItem.msgType = MsgType_Announce;
                } else {
                    msgItem.msgType = MsgType_Link;
                    msgItem.linkStr = link;
                }
                
            } else {
                if (self.dialogView) {
                    [self.dialogView removeFromSuperview];
                }
                self.dialogView = [DialogWarning dialogWarning];
                self.dialogView.tipsLabel.text = msg;
                
                if (self.viewIsAppear) {
                    [self.dialogView showDialogWarning:self.navigationController.view actionBlock:nil];
                }
                
                msgItem.text = msg;
                msgItem.msgType = MsgType_Warning;
            }
            NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
            msgItem.attText = attributeString;
            [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
        }
    });
}

- (void)onRecvLeavingPublicRoomNotice:(NSString *)roomId leftSeconds:(int)leftSeconds err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg priv:(ImAuthorityItemObject *)priv {
    NSLog(@"LSVIPLiveViewController::onRecvLeavingPublicRoomNotice( [接收关闭直播间倒数通知], roomId : %@ , leftSeconds : %d ,isHasOneOnOneAuth : %d ,isHasOneOnOneAuth : %d)", roomId, leftSeconds, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.liveRoom.priv = priv;
            
            self.timeCount = leftSeconds;
            [self.timer startTimer:nil
                      timeInterval:1.0 * NSEC_PER_SEC
                           starNow:YES
                            action:^{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self changeTimeLabel];
                                });
                            }];
        }
    });
}

- (void)onRecvRoomCloseNotice:(NSString *)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg priv:(ImAuthorityItemObject *)priv {
    NSLog(@"LSVIPLiveViewController::onRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@, isHasOneOnOneAuth : %d, isHasOneOnOneAuth: %d )", roomId, errType, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    
    NSLog(@"[NSThread currentThread]---%@", [NSThread currentThread]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.liveRoom.roomId) {
            if ([self.liveRoom.roomId isEqualToString:roomId]) {
                self.liveRoom.priv = priv;
                // 是否邀请Hangout
                if (self.isInviteHangout) {
                    [self stopPlay];
                    [self stopPublish];
                    
                    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
                    [nvc forceToDismissAnimated:NO completion:nil];
                    [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];
                    
                    [[LiveUrlHandler shareInstance] handleOpenURL:self.pushUrl];
                    
                } else {
                    // 停止流、显示结束直播页
                    [self stopLiveWithErrtype:errType errMsg:errmsg];
                }
            }
        }
    });
}

- (void)onRecvChangeVideoUrl:(NSString *)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString *> *)playUrl userId:(NSString *)userId {
    NSLog(@"LSVIPLiveViewController::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@ userId : %@ )", roomId, playUrl, userId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            // 更新流地址
            [self.liveRoom reset];
            self.liveRoom.playUrlArray = [playUrl copy];
            
            [self stopPlay];
            [self play];
        }
    });
}

- (void)onRecvRecommendHangoutNotice:(IMRecommendHangoutItemObject *)item {
    NSLog(@"LSVIPLiveViewController::onRecvRecommendHangoutNotice( [接收主播推荐好友通知] roomId : %@, anchorID : %@,"
          "nickName : %@, recommendId : %@, photourl : %@ )",
          item.roomId, item.anchorId, item.nickName, item.recommendId, item.photoUrl);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([item.roomId isEqualToString:self.liveRoom.roomId]) {
            
//            NSAttributedString *atrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"WOULD_LIKE_TO_HANGOUT"), item.nickName, item.friendNickName]];
//            [self addTips:atrStr];
            
            MsgItem *msgItem = [[MsgItem alloc] init];
            msgItem.msgType = MsgType_Recommend;
            msgItem.sendName = item.nickName;
            msgItem.recommendItem = item;
            msgItem.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"WOULD_LIKE_TO_HANGOUT"),item.nickName,item.friendNickName];
            [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
        }
    });
}

- (void)onRecvDealInviteHangoutNotice:(IMRecvDealInviteItemObject *)item {
    NSLog(@"LSVIPLiveViewController::onRecvDealInviteHangoutNotice( [接收主播回复观众多人互动邀请通知] invteId : %@, roomId : %@,"
          "anchorId : %@, type : %d, anchorId : %@ )",
          item.inviteId, item.roomId, item.anchorId, item.type, item.anchorId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (item.type) {
            case IMREPLYINVITETYPE_AGREE: {
                self.isInvitingHangout = YES;
                self.isInviteHangout = YES;
                [self showRoomTipView:NSLocalizedStringFromSelf(@"INVITE_SUCCESS_HANGOUT")];
                // 拼接push跳转多人互动url
                // 是否是推荐邀请
                if (self.isRecommend) {
                    self.pushUrl = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:item.roomId anchorId:self.hangoutAnchorId anchorName:self.hangoutAnchorName hangoutAnchorId:self.liveRoom.userId hangoutAnchorName:self.liveRoom.userName];
                } else {
                    self.pushUrl = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:item.roomId anchorId:self.hangoutAnchorId anchorName:self.hangoutAnchorName hangoutAnchorId:@"" hangoutAnchorName:@""];
                }
                
            } break;
                
            case IMREPLYINVITETYPE_NOCREDIT: {
                self.isInvitingHangout = NO;
                [self showAddCreditsView:NSLocalizedString(@"INVITE_HANGOUT_ADDCREDIT", nil)];
            } break;
                
            default: {
                self.isInvitingHangout = NO;
                self.isRecommend = NO;
                self.isInviteHangout = NO;
                self.hangoutInviteId = nil;
                
                NSString * name = item.nickName;
                if (name.length > 8) {
                    name = [NSString stringWithFormat:@"%@...",[name substringWithRange:NSMakeRange(0, 3)]];
                }
                NSString *tip = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITE_REJECT_HANGOUT"), name];
                [self showRoomTipView:tip];
            } break;
        }
    });
}


#pragma mark - 倒数关闭直播间
- (void)changeTimeLabel {
  
    self.timeCount -= 1;
    
    if (self.timeCount < 0) {
        // 关闭
        [self.timer stopTimer];
        // 关闭之后，重设计数
        self.timeCount = TIMECOUNT;
    }
}

#pragma mark - 倒数控制
- (void)setupPreviewView {
    // 计算StatusBar高度
    if (IS_IPHONE_X) {
        self.liveHeadDistance.constant = 44;
//        self.videoTopDIstance.constant = 44;
    } else {
        self.liveHeadDistance.constant = 0;
//        self.videoTopDIstance.constant = 0;
    }
    // 初始化预览界面
    self.previewView.hidden = YES;
}

- (void)videoBtnCountDown {
    @synchronized(self) {
        self.videoBtnLeftSecond--;
        if (self.videoBtnLeftSecond == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 隐藏视频静音和推送按钮
               self.stopVideoBtn.hidden = YES;
//                self.muteBtn.hidden = YES;
                self.showBtn.hidden = NO;
            });
        }
    }
}

- (void)startVideoBtnTimer {
    NSLog(@"LSVIPLiveViewController::startVideoBtnTimer()");
    WeakObject(self, weakSelf);
    [self.videoBtnTimer startTimer:nil
                      timeInterval:1.0 * NSEC_PER_SEC
                           starNow:YES
                            action:^{
                                [weakSelf videoBtnCountDown];
                            }];
}

- (void)stopVideoBtnTimer {
    NSLog(@"LSVIPLiveViewController::stopVideoBtnTimer()");
    
    [self.videoBtnTimer stopTimer];
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    if (_isBackground == NO) {
        _isBackground = YES;
        
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (_isBackground == YES) {
        _isBackground = NO;
        
        if (self.isTimeOut) {
            if (self.liveRoom) {
                NSLog(@"LSVIPLiveViewController::willEnterForeground ( [接收后台关闭直播间]  IsTimeOut : %@ )", (self.isTimeOut == YES) ? @"Yes" : @"No");
                // 弹出直播间关闭界面
                [self showLiveFinshViewWithErrtype:LCC_ERR_BACKGROUND_TIMEOUT errMsg:NSLocalizedStringFromErrorCode(@"LIVE_ROOM_BACKGROUND_TIMEOUT")];
            }
        }
    }
}

#pragma mark - LiveGobalManagerDelegate
- (void)enterBackgroundTimeOut:(NSDate *)time {
    self.isTimeOut = YES;
    
    if (self.liveRoom.roomId.length > 0) {
        // 发送IM退出直播间命令
        [[LSImManager manager] leaveRoom:self.liveRoom];
    }
    
    if (self.player) {
        // 停止播放器
        [self.player stop];
    }
    if (self.publisher) {
        // 停止推流器
        [self.publisher stop];
    }
}

// 显示直播结束界面
- (void)showLiveFinshViewWithErrtype:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    if ([self.liveDelegate respondsToSelector:@selector(closeAllInputView:)]) {
        [self.liveDelegate closeAllInputView:self];
    }
    
    if (self.liveRoom.superView) {
        LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
        finshController.liveRoom = self.liveRoom;
        finshController.errType = errType;
        finshController.errMsg = errMsg;
        
        [self.liveRoom.superController addChildViewController:finshController];
        [self.liveRoom.superView addSubview:finshController.view];
        [finshController.view bringSubviewToFront:self.liveRoom.superView];
        [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.liveRoom.superView);
        }];
    }
    
    if (self.liveRoom.roomId.length > 0) {
        // 发送退出直播间
        NSLog(@"LSVIPLiveViewController::showLiveFinshView( [发送退出直播间], roomId : %@ )", self.liveRoom.roomId);
        [self.imManager leaveRoom:self.liveRoom];
    }
    // 清空直播间信息
    self.liveRoom = nil;
    // 移除礼物通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftAnimationIsOver" object:nil];
}

// 直播结束停止推拉流并显示结束页
- (void)stopLiveWithErrtype:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    if (self.liveRoom) {
        // 直接结束关闭直播间内的弹层
        [self closeAllPresentView];
        
        [self.timer stopTimer];
        // 停止流
        [self stopPlay];
        [self stopPublish];
        
        // 弹出直播间关闭界面
        [self showLiveFinshViewWithErrtype:errType errMsg:errMsg];
    }
}


- (void)closeAllPresentView {
    self.creditView.hidden = YES;
    if (self.dialogView) {
        // 移除警告dialog
        [self.dialogView hidenDialog];
    }
}

#pragma mark - 字符串拼接
- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
    return attributeString;
}

- (void)sendCancelHangoutInvit {
    // TODO:取消多人互动邀请
    LSCancelInviteHangoutRequest *request = [[LSCancelInviteHangoutRequest alloc] init];
    request.inviteId = self.hangoutInviteId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        NSLog(@"LSVIPLiveViewController::LSCancelInviteHangoutRequest( [取消多人互动邀请 %@] errnum : %d,"
              "errmsg : %@ )",success == YES ? @"成功":@"失败", errnum, errmsg);
    };
    [self.sessionManager sendRequest:request];
}
@end
