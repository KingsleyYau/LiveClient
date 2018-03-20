//
//  LiveViewController.m
//  livestream
//
//  Created by Max on 2017/5/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveViewController.h"

#import "LiveFinshViewController.h"
#import "LiveWebViewController.h"

#import "LiveModule.h"
#import "LiveUrlHandler.h"

#import "LiveGobalManager.h"
#import "LiveStreamPublisher.h"
#import "LiveStreamPlayer.h"

#import "MsgTableViewCell.h"
#import "MsgItem.h"

#import "LikeView.h"

#import "LSFileCacheManager.h"
#import "LSSessionRequestManager.h"
#import "LiveGiftDownloadManager.h"
#import "UserHeadUrlManager.h"
#import "LSChatEmotionManager.h"
#import "LiveStreamSession.h"
#import "UserInfoManager.h"
#import "LiveRoomCreditRebateManager.h"

#import "AudienceModel.h"
#import "GetNewFansBaseInfoRequest.h"

#import "DialogOK.h"
#import "DialogChoose.h"
#import "DialogTip.h"
#import "Dialog.h"
#import "LSAnalyticsManager.h"

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

#define UnReadMsgCountFontSize 14
#define UnReadMsgCountColor NameColor
#define UnReadMsgCountFont [UIFont boldSystemFontOfSize:UnReadMsgCountFontSize]

#define UnReadMsgTipsFontSize 14
#define UnReadMsgTipsColor MessageTextColor
#define UnReadMsgTipsFont [UIFont boldSystemFontOfSize:UnReadMsgCountFontSize]

#define MessageCount 500

#define MsgTableViewHeight 250

#define TIMECOUNT 30

#pragma mark - 流[播放/推送]逻辑
#define STREAM_PLAYER_RECONNECT_MAX_TIMES 5
#define STREAM_PUBLISH_RECONNECT_MAX_TIMES STREAM_PLAYER_RECONNECT_MAX_TIMES

@interface LiveViewController () <UITextFieldDelegate, LSCheckButtonDelegate, BarrageViewDataSouce, BarrageViewDelegate, GiftComboViewDelegate, IMLiveRoomManagerDelegate, IMManagerDelegate, DriveViewDelegate, MsgTableViewCellDelegate, LiveStreamPlayerDelegate, LiveStreamPublisherDelegate,LiveGobalManagerDelegate>

#pragma mark - 流[播放/推送]管理
// 流播放地址
@property (strong) NSString *playUrl;
// 流播放组件
@property (strong) LiveStreamPlayer *player;
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
@property (nonatomic, strong) UserInfoManager *userInfoManager;

#pragma mark - 礼物连击界面
@property (nonatomic, strong) NSMutableArray<GiftComboView *> *giftComboViews;
@property (nonatomic, strong) NSMutableArray<MASConstraint *> *giftComboViewsLeadings;

#pragma mark - 礼物下载器
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;

#pragma mark - 用户头像管理器
@property (nonatomic, strong) UserHeadUrlManager *photoManager;

#pragma mark - 表情管理器
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;

#pragma mark - 消息管理器
@property (nonatomic, strong) LiveRoomMsgManager *msgManager;

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
@property (nonatomic, strong) LSTimer *timer;
@property (nonatomic, assign) NSInteger timeCount;

#pragma mark - 弹幕
// 显示的弹幕数量 用于判断隐藏弹幕阴影
@property (nonatomic, assign) int showToastNum;

#pragma mark - 对话框
@property (strong) DialogOK *dialogToastAddCredit;
@property (strong) DialogOK *dialogWatchAddCredit;
@property (strong) DialogOK *dialogGiftAddCredit;
@property (strong) DialogTip *dialogProbationTip;
@property (strong) Dialog *dialogWarning;

#pragma mark - 用于显示试用倦提示
@property (nonatomic, assign) BOOL showTip;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;

#pragma mark - 测试
@property (nonatomic, weak) NSTimer *testTimer;
@property (nonatomic, assign) NSInteger giftItemId;
@property (nonatomic, weak) NSTimer *testTimer2;
@property (nonatomic, weak) NSTimer *testTimer3;
@property (nonatomic, weak) NSTimer *testTimer4;
@property (nonatomic, assign) NSInteger msgId;
@property (nonatomic, assign) BOOL isDriveShow;

@end

@implementation LiveViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    NSLog(@"LiveViewController::initCustomParam()");

    // 初始化流组件
    self.playUrl = @"rtmp://172.25.32.133:7474/test_flash/max_mv";
    self.player = [LiveStreamPlayer instance];
    self.player.delegate = self;
    self.playerReconnectTime = 0;

    self.publishUrl = @"rtmp://172.25.32.133:7474/test_flash/max_i";
    self.publisher = [LiveStreamPublisher instance];
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
    self.userInfoManager = [UserInfoManager manager];

    // 初始化礼物管理器
    self.giftDownloadManager = [LiveGiftDownloadManager manager];

    // 初始化表情管理器
    self.emotionManager = [LSChatEmotionManager emotionManager];

    // 初始化头像管理器
    self.photoManager = [UserHeadUrlManager manager];

    // 初始化文字管理器
    self.msgManager = [LiveRoomMsgManager msgManager];

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 注册大礼物结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationWhatIs:) name:@"animationIsAnimaing" object:nil];
    
    // 初始化计时器
    self.videoBtnTimer = [[LSTimer alloc] init];
    
    // 初始化倒数关闭直播间计时器
    self.timer = [[LSTimer alloc] init];

    
    self.dialogProbationTip = [DialogTip dialogTip];
    self.showTip = YES;
}

- (void)dealloc {
    NSLog(@"LiveViewController::dealloc()");

    // 去除大礼物结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"animationIsAnimaing" object:nil];

    [self.giftComboManager removeManager];

    for (GiftComboView *giftView in self.giftComboViews) {
        [giftView stopGiftCombo];
    }

    [self.timer stopTimer];
    
    // 移除直播间后台代理监听
    [[LiveGobalManager manager] removeDelegate:self];
    
    // 移除直播间IM代理监听
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];

    // 赋值到全局变量, 用于前台计时
    [LiveGobalManager manager].liveRoom = nil;
    [LiveGobalManager manager].player = nil;
    [LiveGobalManager manager].publisher = nil;

    // 停止流
    [self stopPlay];
    [self stopPublish];

    // 关闭锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    if (self.liveRoom.roomId.length > 0) {
        // 发送退出直播间
        NSLog(@"LiveViewController::dealloc  [发送退出直播间:%@]",self.liveRoom.roomId);
        [self.imManager leaveRoom:self.liveRoom.roomId];
        // QN判断已退出直播间
        [LiveModule module].roomID = nil;
    }

    if (self.dialogWatchAddCredit) {
        [self.dialogWatchAddCredit removeFromSuperview];
    }
    if (self.dialogToastAddCredit) {
        [self.dialogToastAddCredit removeFromSuperview];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 赋值到全局变量, 用于后台计时操作
    [LiveGobalManager manager].liveRoom = self.liveRoom;
    [LiveGobalManager manager].player = self.player;
    [LiveGobalManager manager].publisher = self.publisher;
    
    // QN判断正在直播间
    [LiveModule module].roomID = self.liveRoom.roomId;
    
    // 禁止锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    // 初始化消息列表
    [self setupTableView];

    // 初始化座驾控件
    [self setupDriveView];

    // 初始化连击控件
    [self setupGiftView];
    
    // 初始化视频界面
    self.player.playView = self.videoView;
    self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;

    // 隐藏返点按钮
    [self.rewardedBtn setHighlighted:NO];
    [self setUpRewardedCredit:self.liveRoom.imLiveRoom.rebateInfo.curCredit];

    // 隐藏倒计时Label
    self.countdownLabel.hidden = YES;

    // 弹幕
    self.barrageView.hidden = YES;

    // 隐藏视频预览界面
    self.previewVideoViewWidth.constant = 0;
    // 隐藏立即私密按钮
    self.cameraBtn.hidden = YES;

    // 隐藏互动直播ActivityView
    self.preActivityView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.barrageView.hidden = YES;

    self.bigGiftArray = nil;
    [self.giftAnimationView removeFromSuperview];
    self.giftAnimationView = nil;
    
    if (self.dialogProbationTip.isShow) {
        [self.dialogProbationTip removeShow];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.liveRoom.imLiveRoom.usedVoucher && self.showTip) {
        self.showTip = NO;
        [self.dialogProbationTip showDialogTip:self.liveRoom.superView tipText:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"LIVE_VOUCHER_APPLIED"),self.liveRoom.imLiveRoom.useCoupon]];
    }
    
    if( !self.viewDidAppearEver ) {
        // 第一次进入
        // 开始播放流
        [self play];
        
        // 自己座驾入场
        [self getDriveInfo:self.loginManager.loginItem.userId];
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

- (void)initialiseSubwidge {
    [super initialiseSubwidge];
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化返点按钮
    [self setupRewardImageView];

    // 初始化弹幕
    [self setupBarrageView];

    // 初始化预览界面
    [self setupPreviewView];
}

- (void)setupRewardImageView {
    // 设置返点按钮
    self.rewardedBgView.layer.cornerRadius = 10;
}

- (void)bringSubviewToFrontFromView:(UIView *)view {

    [self.view bringSubviewToFront:self.giftView];
    [self.view bringSubviewToFront:self.barrageView];
    [self.view bringSubviewToFront:self.cameraBtn];

    [view bringSubviewToFront:self.giftView];
    [view bringSubviewToFront:self.barrageView];
    [view bringSubviewToFront:self.cameraBtn];
}

- (void)showPreview {
    // 显示预览控件
    self.previewVideoViewWidth.constant = 115;
}

#pragma mark - 界面事件
- (IBAction)showAction:(id)sender {
    self.stopVideoBtn.hidden = NO;
    self.muteBtn.hidden = NO;

    @synchronized(self) {
        self.videoBtnLeftSecond = 3;
    }
}

- (IBAction)muteAction:(id)sender {
    self.publisher.mute = !self.publisher.mute;
    self.muteBtn.selected = !self.muteBtn.selected;

    @synchronized(self) {
        self.videoBtnLeftSecond = 3;
    }
}

- (IBAction)cameraAction:(id)sender {
    [[LSAnalyticsManager manager] reportActionEvent:PrivateBroadcastClickVideo eventCategory:EventCategoryBroadcast];
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" userId:self.liveRoom.userId roomType:LiveRoomType_Private];
    [LiveUrlHandler shareInstance].url = url;

    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];
}

- (IBAction)showRewardView:(id)sender {
    
    [[LSAnalyticsManager manager] reportActionEvent:VipBroadcastClickReward eventCategory:EventCategoryBroadcast];
    if ([self.liveDelegate respondsToSelector:@selector(bringRewardViewInTop:)]) {
        [self.liveDelegate bringRewardViewInTop:self];
    }
}

#pragma mark - 流[播放/推送]逻辑
- (void)play {
    self.playUrl = self.liveRoom.playUrl;
    NSLog(@"LiveViewController::play( [开始播放流], playUrl : %@ )", self.playUrl);
    [self debugInfo];
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *dateString = [LSDateFormatter toStringYMDHMSWithUnderLine:[NSDate date]];
    NSString *recordFilePath = [LiveModule module].debug?[NSString stringWithFormat:@"%@/%@_%@_%@.flv", recordDir, self.loginManager.loginItem.userId, self.liveRoom.userId, dateString]:@"";
    NSString *recordH264FilePath = @"";//[NSString stringWithFormat:@"%@/%@", recordDir, @"play.h264"];
    NSString *recordAACFilePath = @"";//[NSString stringWithFormat:@"%@/%@", recordDir, @"play.aac"];
    
    // 开始转菊花
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bFlag = [self.player playUrl:self.playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 停止菊花
            if (bFlag) {
                // 播放成功
                if ([weakSelf.liveDelegate respondsToSelector:@selector(liveViewIsPlay:)]) {
                    [weakSelf.liveDelegate liveViewIsPlay:weakSelf];
                }
                if (self.liveRoom.roomType != LiveRoomType_Public) {
                    weakSelf.rewardedBgView.hidden = NO;
                    weakSelf.rewardedBtn.hidden = NO;
                }
            } else {
                // 播放失败
            }
        });
    });
}

- (void)stopPlay {
    NSLog(@"LiveViewController::stopPlay()");

    [self.player stop];
}

- (void)initPublish {
    NSLog(@"LiveViewController::initPublish( [初始化推送流] )");
    
    // 初始化采集
    [self.publisher initCapture];
    // 初始化预览界面
    self.publisher.publishView = self.previewVideoView;
    self.publisher.publishView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
}

- (void)publish {
    BOOL bFlag = [[LiveStreamSession session] canCapture];
    if (!bFlag) {
        // 无权限
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Open_Permissions_Tip") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action){

                                                         }];
        [alertVC addAction:actionOK];
        [self presentViewController:alertVC animated:NO completion:nil];
    }

    if (bFlag) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.publishUrl = self.liveRoom.publishUrl;
            NSLog(@"LiveViewController::publish( [开始推送流], publishUrl : %@ )", self.publishUrl);
            [self debugInfo];
            
            BOOL bFlag = [self.publisher pushlishUrl:self.publishUrl recordH264FilePath:@"" recordAACFilePath:@""];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 停止菊花
                if (bFlag) {
                    // 成功

                } else {
                    // 失败
                }
            });
        });
    }
}

- (void)stopPublish {
    NSLog(@"LiveViewController::stopPublish()");
    [self.publisher stop];
}

#pragma mark - 流[播放/推送]通知
- (NSString *_Nullable)playerShouldChangeUrl:(LiveStreamPlayer *_Nonnull)player {
    NSString *url = player.url;

    @synchronized(self) {
        if (self.playerReconnectTime++ > STREAM_PLAYER_RECONNECT_MAX_TIMES) {
            // 断线超过指定次数, 切换URL
            url = [self.liveRoom changePlayUrl];
            self.playerReconnectTime = 0;

            NSLog(@"LiveViewController::playerShouldChangeUrl( [切换播放流URL], url : %@)", url);
        }
    }

    return url;
}

- (NSString *_Nullable)publisherShouldChangeUrl:(LiveStreamPublisher *_Nonnull)publisher {
    NSString *url = publisher.url;

    @synchronized(self) {
        if (self.publisherReconnectTime++ > STREAM_PUBLISH_RECONNECT_MAX_TIMES) {
            // 断线超过指定次数, 切换URL
            url = [self.liveRoom changePublishUrl];
            self.publisherReconnectTime = 0;

            NSLog(@"LiveViewController::publisherShouldChangeUrl( [切换推送流URL], url : %@)", url);
        }
    }

    return url;
}

#pragma mark - 初始化座驾控件
- (void)setupDriveView {

    // 初始化座驾播放标志
    self.isDriveShow = NO;

    self.driveView = [[DriveView alloc] init];
    self.driveView.alpha = 0.3;
    self.driveView.delegate = self;
    self.driveView.hidden = YES;
    [self.view addSubview:self.driveView];
    [self.driveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view.mas_right);
        make.width.equalTo(@120);
        make.height.equalTo(@80);
    }];
}

#pragma mark - 座驾（入场信息）
- (void)canPlayDirve:(DriveView *)driveView audienceModel:(AudienceModel *)model ifError:(NSError *)error {
    
    if (error) {
        // 移除错误下载
        [self drivePlayCallback];
    } else {
        // 播放座驾动画
        [self userHaveJoinToRoom];
    }
}

- (void)getDriveInfo:(NSString *)userId {
    NSLog(@"LiveViewController::getDriveInfo( [获取座驾], userId : %@ )", userId);
    [[UserInfoManager manager] getFansBaseInfo:userId finishHandler:^(LSUserInfoModel * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized (self) {
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
                        [self.driveView audienceComeInLiveRoom:self.audienArray[0]];
                    }
                    
                    MsgItem *msgItem = [[MsgItem alloc] init];
                    msgItem.type = MsgType_RiderJoin;
                    msgItem.honorUrl = self.liveRoom.imLiveRoom.honorImg;
                    msgItem.name = item.nickName;
                    msgItem.riderName = item.riderName;
                    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
                    msgItem.attText = attributeString;
                    [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
                    
                } else {
                    // 插入自己入场消息
                    MsgItem *msgItem = [[MsgItem alloc] init];
                    msgItem.type = MsgType_Join;
                    if (![self.liveRoom.imLiveRoom.honorImg isEqualToString:@""]) {
                        msgItem.honorUrl = self.liveRoom.imLiveRoom.honorImg;
                    }
                    msgItem.name = item.nickName;
                    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
                    msgItem.attText = attributeString;
                    [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
                }
            }
        });
    }];
}

#pragma mark - 座驾入场动画
- (void)userHaveJoinToRoom {
    [self.view layoutIfNeeded];

    self.driveView.hidden = NO;
    [self.driveView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@50);
        make.left.equalTo(self.view.mas_right).offset(-130);
    }];

    WeakObject(self, weakSelf);
    [UIView animateWithDuration:2
        animations:^{
            weakSelf.driveView.alpha = 1;
            [weakSelf.view layoutIfNeeded];

        }
        completion:^(BOOL finished) {

            [UIView animateWithDuration:0.5
                delay:1
                options:0
                animations:^{

                    weakSelf.driveView.alpha = 0;
                }
                completion:^(BOOL finished) {

                    [weakSelf.driveView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self.view);
                        make.left.equalTo(self.view.mas_right);
                    }];
                    weakSelf.driveView.hidden = YES;
                    // 播放完回调
                    [weakSelf drivePlayCallback];

                    // 测试
                    // weakSelf.isDriveShow = NO;

                }];
        }];
}

#pragma mark - 座驾动画播放完回调
- (void)drivePlayCallback {

    if (self.audienArray.count) {
        [self.audienArray removeObjectAtIndex:0];
        
        if (self.audienArray.count) {
            [self.driveView audienceComeInLiveRoom:self.audienArray[0]];
        } else {
            self.isDriveShow = NO;
        }
    }
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
    giftComboView.sendLabel.text = giftItem.giftname;

    // 数量
    giftComboView.beginNum = giftItem.multi_click_start;
    giftComboView.endNum = giftItem.multi_click_end;

    NSLog(@"LiveViewController::showCombo( [显示连击礼物], beginNum : %ld, endNum: %ld, clickID : %ld )", (long)giftComboView.beginNum, (long)giftComboView.endNum, (long)giftItem.multi_click_id);

    // 连击礼物
    NSString *imgUrl = [self.giftDownloadManager backBigImgUrlWithGiftID:giftItem.giftid];
    [self.giftImageLoader loadImageWithImageView:giftComboView.giftImageView
                                         options:0
                                        imageUrl:imgUrl
                                placeholderImage:
                                    [UIImage imageNamed:@"Live_Gift_Nomal"]];

    giftComboView.item = giftItem;

    WeakObject(self, weakSelf);
    // 获取用户头像
    [self.userInfoManager getUserInfo:userId
                        finishHandler:^(LSUserInfoModel *_Nonnull item) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // 当前用户
                                [weakSelf.headImageLoader refreshCachedImage:giftComboView.iconImageView options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
                            });
                        }];

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
            NSLog(@"LiveViewController::addCombo( [增加连击礼物, 播放], starNum : %ld, endNum : %ld, clickID : %ld )", (long)giftItem.multi_click_start, (long)giftItem.multi_click_end, (long)giftItem.multi_click_id);
        }

    } else {
        // 没有空闲的界面, 放到缓存
        [self.giftComboManager pushGift:giftItem];
        NSLog(@"LiveViewController::addCombo( [增加连击礼物, 缓存], starNum : %ld, endNum : %ld, clickID : %ld )", (long)giftItem.multi_click_start, (long)giftItem.multi_click_end, (long)giftItem.multi_click_id);
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
    NSString *filePath = [[LiveGiftDownloadManager manager] doCheckLocalGiftWithGiftID:giftID];
    NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:filePath];
    LSYYImage *image = [LSYYImage imageWithData:imageData];

    // 判断本地文件是否损伤 有则播放 无则删除重下播放下一个
    if (image) {
//        UIWindow *window = [UIApplication sharedApplication].delegate.window;
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
        [self.giftDownloadManager deletWebpPath:giftID];
        [self.giftDownloadManager downLoadGiftDetail:giftID];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"animationIsAnimaing" object:self userInfo:nil];
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
        
        if (self.bigGiftArray.count > 0) {
            [self.bigGiftArray removeObjectAtIndex:0];
        }
    }
    if (self.bigGiftArray.count > 0) {
        [self starBigAnimationWithGiftID:self.bigGiftArray[0]];
    }
}

#pragma mark - 弹幕管理
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
    NSLog(@"LiveViewController:: barrageView message:%@",bgItem.message);
    WeakObject(self, weakSelf);
    // 获取用户头像
    [self.userInfoManager getUserInfo:bgItem.userId
                        finishHandler:^(LSUserInfoModel *_Nonnull item) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf.headImageLoader refreshCachedImage:cell.imageViewHeader options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
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

#pragma mark - 消息列表管理
- (void)setupTableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.msgTableView setTableFooterView:footerView];

    self.msgTableView.backgroundView = nil;
    self.msgTableView.backgroundColor = [UIColor clearColor];
    self.msgTableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    [self.msgTableView registerClass:[MsgTableViewCell class] forCellReuseIdentifier:[MsgTableViewCell cellIdentifier]];

    self.msgTipsView.clipsToBounds = YES;
    self.msgTipsView.layer.cornerRadius = 6.0;
    self.msgTipsView.hidden = YES;

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMsgTipsView:)];
    [self.msgTipsView addGestureRecognizer:singleTap];

    [self.view insertSubview:self.barrageView aboveSubview:self.tableSuperView];
}

- (BOOL)sendMsg:(NSString *)text isLounder:(BOOL)isLounder {
    NSLog(@"LiveViewController::sendMsg( [发送文本消息], text : %@, isLounder : %d )", text, isLounder);

    BOOL bFlag = NO;
    BOOL bDebug = NO;
    
    bDebug = [self handleDebugCmd:text];
    NSString *str =  [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 发送IM文本
    if( !bDebug ) {
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

- (void)addTips:(NSAttributedString *)text {
    MsgItem *item = [[MsgItem alloc] init];
    item.text = text.string;
    item.type = MsgType_Announce;
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:item];
    item.attText = attributeString;
    [self addMsg:item replace:NO scrollToEnd:YES animated:YES];
}

#pragma mark - 聊天文本消息管理
// 插入普通聊天消息
- (void)addChatMessageNickName:(NSString *)name userLevel:(NSInteger)level text:(NSString *)text honorUrl:(NSString *)honorUrl {
    NSLog(@"LiveViewController::addChatMessage( [插入文本消息], text : %@ )", text);

    // 发送普通消息
    MsgItem *item = [[MsgItem alloc] init];
    item.level = level;
    item.name = name;
    item.text = text;
    item.honorUrl = honorUrl;
    if ( text.length > 0 && text != nil ) {
        NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:item];
        item.attText = [self.emotionManager parseMessageAttributedTextEmotion:attributeString font:MessageFont];
    }
    // 插入到消息列表
    [self addMsg:item replace:NO scrollToEnd:YES animated:YES];
}

// 插入送礼消息
- (void)addGiftMessageNickName:(NSString *)nickName giftID:(NSString *)giftID giftNum:(int)giftNum honorUrl:(NSString *)honorUrl {
    AllGiftItem *item = [[LiveGiftDownloadManager manager] backGiftItemWithGiftID:giftID];

    MsgItem *msgItem = [[MsgItem alloc] init];
    msgItem.name = nickName;
    msgItem.level = 0;
    msgItem.type = MsgType_Gift;
    msgItem.giftName = item.infoItem.name;
    msgItem.smallImgUrl = [self.giftDownloadManager backSmallImgUrlWithGiftID:giftID];
    msgItem.giftNum = giftNum;
    msgItem.honorUrl = honorUrl;

    // 增加文本消息
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
    msgItem.attText = attributeString;

    [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
}

// 插入关注消息
//- (void)addAudienceFollowLiverMessage:(NSString *)nickName {
//
//    MsgItem *msgItem = [[MsgItem alloc] init];
//    msgItem.name = nickName;
//    msgItem.type = MsgType_Follow;
//
//    // 增加文本消息
//    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
//    msgItem.attText = attributeString;
//
//    [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
//}

- (void)addMsg:(MsgItem *)item replace:(BOOL)replace scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated {
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

    if (lastVisibleRow >= lastRow) {
        // 如果消息列表当前能显示最新的消息

        // 直接刷新
        [self.msgTableView beginUpdates];
        if (deleteOldMsg) {
            if (replace) {
                // 删除一条最新消息
                [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.msgShowArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

            } else {
                // 超出最大消息限制, 删除列表一条旧消息

                [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }

        // 替换显示的消息列表
        self.msgShowArray = [NSMutableArray arrayWithArray:self.msgArray];

        // 增加列表一条新消息
        [self.msgTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.msgShowArray.count - 1 inSection:0]] withRowAnimation:(deleteOldMsg && replace) ? UITableViewRowAnimationNone : UITableViewRowAnimationBottom];

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
}

- (void)scrollToEnd:(BOOL)animated {
    NSInteger count = [self.msgTableView numberOfRowsInSection:0];
    if (count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
        [self.msgTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)showUnReadMsg {
    self.unReadMsgCount++;

    if (!self.tableSuperView.hidden) {
        self.msgTipsView.hidden = NO;
    }
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld ", (long)self.unReadMsgCount]];
    [attString addAttributes:@{
        NSFontAttributeName : UnReadMsgCountFont,
        NSForegroundColorAttributeName : UnReadMsgCountColor
    }
                       range:NSMakeRange(0, attString.length)];

    NSMutableAttributedString *attStringMsg = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"UnRead_Messages")];
    [attStringMsg addAttributes:@{
        NSFontAttributeName : UnReadMsgTipsFont,
        NSForegroundColorAttributeName : UnReadMsgTipsColor
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
    [self scrollToEnd:YES];

    //    [self scrollViewDidScroll:self.msgTableView];
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
    CGFloat height = 0;

    CGFloat width = tableView.frame.size.width;
    // 数据填充
    if (indexPath.row < self.msgShowArray.count) {
        MsgItem *item = [self.msgShowArray objectAtIndex:indexPath.row];

        height = [tableView fd_heightForCellWithIdentifier:[MsgTableViewCell cellIdentifier]
                                          cacheByIndexPath:indexPath
                                             configuration:^(MsgTableViewCell *cell) {

                                                 [cell changeMessageLabelWidth:width];
                                                 [cell updataChatMessage:item];
                                             }];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    // 数据填充
    if (indexPath.row < self.msgShowArray.count) {
        MsgItem *item = [self.msgShowArray objectAtIndex:indexPath.row];

        MsgTableViewCell *msgCell = [tableView dequeueReusableCellWithIdentifier:[MsgTableViewCell cellIdentifier]];
        msgCell.msgDelegate = self;
        [msgCell changeMessageLabelWidth:tableView.frame.size.width];
        [msgCell updataChatMessage:item];
        cell = msgCell;

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger lastVisibleRow = -1;
    if (self.msgTableView.indexPathsForVisibleRows.count > 0) {
        lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
    }
    NSInteger lastRow = self.msgShowArray.count - 1;

    if (self.msgShowArray.count > 0 && lastVisibleRow <= lastRow) {
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

#pragma mark - IM请求
- (void)sendRoomToastRequestFromText:(NSString *)text {
    // 发送弹幕
    [self.imManager sendToast:self.liveRoom.roomId nickName:self.loginManager.loginItem.nickName msg:text];
}

- (void)sendRoomMsgRequestFromText:(NSString *)text {
    // 发送直播间消息
    [self.imManager sendLiveChat:self.liveRoom.roomId nickName:self.loginManager.loginItem.nickName msg:text at:nil];
}

#pragma mark - IM通知
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg item:(ImLoginReturnObject *_Nonnull)item {
    NSLog(@"LiveViewController::onLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    if (errType == LCC_ERR_SUCCESS) {
        // 重新进入直播间
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imManager enterRoom:self.liveRoom.roomId
                        finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImLiveRoomObject *_Nonnull roomItem) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (success) {
                                    NSLog(@"LiveViewController::onLogin( [IM登陆, 成功, 重新进入直播间], roomId : %@ )", self.liveRoom.roomId);
                                    // 更新直播间信息
                                    [self.liveRoom reset];
                                    self.liveRoom.imLiveRoom = roomItem;

                                    // 重新推流
                                    [self stopPlay];
                                    [self play];

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
                                    NSLog(@"LiveViewController::onLogin( [IM登陆, 成功, 但直播间已经关闭], roomId : %@ )", self.liveRoom.roomId);

                                    if (errType != LCC_ERR_CONNECTFAIL) {
                                        // 错误提示
                                        //                                        Dialog *dialog = [Dialog dialog];
                                        //                                        dialog.tipsLabel.text = @"直播间已经关闭";
                                        //                                        [dialog showDialog:self.view
                                        //                                               actionBlock:^{
                                        //                                                   [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                        //                                               }];
                                    }
                                }
                            });
                        }];
        });
    }
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
    NSLog(@"LiveViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@, playerReconnectTime : %lu, publisherReconnectTime : %lu )", errType, errmsg, (unsigned long)self.playerReconnectTime, (unsigned long)self.publisherReconnectTime);

    @synchronized(self) {
        // IM断开, 重置RTMP断开次数
        self.playerReconnectTime = 0;
        self.publisherReconnectTime = 0;
    }
}

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LiveViewController::onSendGift( [发送直播间礼物消息], errmsg : %@, credit : %f, rebateCredit : %f )", errmsg, credit, rebateCredit);
    dispatch_async(dispatch_get_main_queue(), ^{

        if (success) {
            
            if (!(credit < 0)) {
                [self setUpRewardedCredit:rebateCredit];
                // 设置余额及返点信息管理器
                [self.creditRebateManager setCredit:credit];
            }
            [self.creditRebateManager updateRebateCredit:rebateCredit];

        } else if (errType == LCC_ERR_NO_CREDIT) {
            if (self.dialogGiftAddCredit) {
                [self.dialogGiftAddCredit removeFromSuperview];
            }
            WeakObject(self, weakSelf);
            self.dialogGiftAddCredit = [DialogOK dialog];
            self.dialogGiftAddCredit.tipsLabel.text = NSLocalizedStringFromSelf(@"SENDTOSAT_ERR_ADD_CREDIT");
            [self.dialogGiftAddCredit showDialog:self.liveRoom.superView
                                      actionBlock:^{
                                          NSLog(@"没钱了。。");
                                          if ([weakSelf.liveDelegate respondsToSelector:@selector(noCreditPushTo:)]) {
                                              [weakSelf.liveDelegate noCreditPushTo:weakSelf];
                                          }
                                      }];
        }
    });
}

- (void)onRecvSendGiftNotice:(NSString *_Nonnull)roomId fromId:(NSString *_Nonnull)fromId nickName:(NSString *_Nonnull)nickName giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(NSString *_Nonnull)honorUrl {
    NSLog(@"LiveViewController::onRecvRoomGiftNotice( [接收礼物], roomId : %@, fromId : %@, nickName : %@, giftId : %@, giftName : %@, giftNum : %d, honorUrl : %@ )", roomId, fromId, nickName, giftId, giftName, giftNum, honorUrl);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {

            // 判断本地是否有该礼物
            if ([self.giftDownloadManager judgeTheGiftidIsHere:giftId]) {

                // 连击起始数
                NSInteger starNum = multi_click_start - 1;

                // 接收礼物消息item
                GiftItem *giftItem = [GiftItem itemRoomId:roomId fromID:fromId nickName:nickName giftID:giftId giftName:giftName giftNum:giftNum multi_click:multi_click starNum:starNum endNum:multi_click_end clickID:multi_click_id];

                GiftType type = [self.giftDownloadManager backImgTypeWithGiftID:giftId];
                if (type == GIFTTYPE_COMMON) {
                    // 连击礼物
                    [self addCombo:giftItem];

                } else {
                    
                    // 礼物添加到队列
                    if (!self.bigGiftArray && self.viewIsAppear) {
                        self.bigGiftArray = [NSMutableArray array];
                    }
                    for (int i = 0; i < giftNum; i++) {
                        [self.bigGiftArray addObject:giftItem.giftid];
                    }

                    // 防止动画播完view没移除
                    if (!self.giftAnimationView.isAnimating) {
                        [self.giftAnimationView removeFromSuperview];
                        self.giftAnimationView = nil;
                    }

                    if (!self.giftAnimationView) {
                        // 显示大礼物动画
                        if (self.bigGiftArray) {
                            [self starBigAnimationWithGiftID:self.bigGiftArray[0]];
                        }
                    }
                }
                // 插入送礼文本消息
                [self addGiftMessageNickName:nickName giftID:giftId giftNum:giftNum honorUrl:honorUrl];

            } else {
                // 获取礼物详情
                [self.giftDownloadManager requestListnotGiftID:giftId];
            }
        }
    });
}

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LiveViewController::onSendToast( [发送直播间弹幕消息, %@], errmsg : %@, credit : %f, rebateCredit : %f )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errmsg, credit, rebateCredit);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            if (!(credit < 0)) {
                [self setUpRewardedCredit:rebateCredit];

                // 设置余额及返点信息管理器
                [self.creditRebateManager setCredit:credit];
            }
            [self.creditRebateManager updateRebateCredit:rebateCredit];
            
        } else if (errType == LCC_ERR_NO_CREDIT) {
            if (self.dialogToastAddCredit) {
                [self.dialogToastAddCredit removeFromSuperview];
            }
            WeakObject(self, weakSelf);
            self.dialogToastAddCredit = [DialogOK dialog];
            self.dialogToastAddCredit.tipsLabel.text = NSLocalizedStringFromSelf(@"SENDTOSAT_ERR_ADD_CREDIT");
            [self.dialogToastAddCredit showDialog:self.liveRoom.superView
                                      actionBlock:^{
                                          NSLog(@"没钱了。。");
                                          [[LSAnalyticsManager manager] reportActionEvent:@"add_Credit" eventCategory:@"Gobal"];
                                          if ([weakSelf.liveDelegate respondsToSelector:@selector(noCreditPushTo:)]) {
                                              [weakSelf.liveDelegate noCreditPushTo:weakSelf];
                                          }
                                      }];
        }
    });
}

- (void)onRecvSendToastNotice:(NSString *_Nonnull)roomId fromId:(NSString *_Nonnull)fromId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg honorUrl:(NSString *_Nonnull)honorUrl {
    NSLog(@"LiveViewController::onRecvSendToastNotice( [接收直播间弹幕通知], roomId : %@, fromId : %@, nickName : %@, msg : %@ honorUrl:%@)", roomId, fromId, nickName, msg, honorUrl);

    dispatch_async(dispatch_get_main_queue(), ^{
        self.barrageView.hidden = NO;
        // 插入普通文本消息
        [self addChatMessageNickName:nickName userLevel:self.loginManager.loginItem.userlevel text:msg honorUrl:honorUrl];

        // 插入到弹幕
        BarrageModel *bgItem = [BarrageModel barrageModelForName:nickName message:msg urlWihtUserID:fromId];
        NSArray *items = [NSArray arrayWithObjects:bgItem, nil];
        [self.barrageView insertBarrages:items immediatelyShow:YES];

    });
}

- (void)onRecvSendChatNotice:(NSString *_Nonnull)roomId level:(int)level fromId:(NSString *_Nonnull)fromId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg honorUrl:(NSString *_Nonnull)honorUrl {
    NSLog(@"LiveViewController::onRecvSendChatNotice( [接收直播间文本消息通知], roomId : %@, nickName : %@, msg : %@ )", roomId, nickName, msg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.imLiveRoom.roomId]) {
            // 插入聊天消息到列表
            [self addChatMessageNickName:nickName userLevel:level text:msg honorUrl:honorUrl];
        }
    });
}

- (void)onRecvEnterRoomNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl riderId:(NSString *_Nonnull)riderId riderName:(NSString *_Nonnull)riderName riderUrl:(NSString *_Nonnull)riderUrl fansNum:(int)fansNum honorImg:(NSString * _Nonnull)honorImg{

    NSLog(@"LiveViewController::onRecvFansRoomIn( [接收观众进入直播间], roomId : %@, userId : %@, nickName : %@, photoUrl : %@ )", roomId, userId, nickName, photoUrl);
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
                        [self.driveView audienceComeInLiveRoom:self.audienArray[0]];
                    }
                    
                    // 用户座驾入场信息
                    MsgItem *riderItem = [[MsgItem alloc] init];
                    riderItem.type = MsgType_RiderJoin;
                    riderItem.name = nickName;
                    riderItem.riderName = riderName;
                    riderItem.honorUrl = honorImg;
                    NSMutableAttributedString *riderString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:riderItem];
                    riderItem.attText = riderString;
                    [self addMsg:riderItem replace:NO scrollToEnd:YES animated:YES];
                    
                } else { // 如果没座驾
                    // 插入入场消息到列表
                    MsgItem *msgItem = [[MsgItem alloc] init];
                    msgItem.type = MsgType_Join;
                    msgItem.name = nickName;
                    msgItem.honorUrl = honorImg;
                    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
                    msgItem.attText = attributeString;
                    
                    // (插入/替换)到到消息列表
                    BOOL replace = NO;
                    if (self.msgArray.count > 0) {
                        MsgItem *lastItem = [self.msgArray lastObject];
                        if (lastItem.type == msgItem.type) {
                            // 同样是入场消息, 替换最后一条
                            replace = YES;
                        }
                    }
                    [self addMsg:msgItem replace:replace scrollToEnd:YES animated:YES];
                }
            }
        }
    });
}

- (void)onRecvRebateInfoNotice:(NSString *_Nonnull)roomId rebateInfo:(RebateInfoObject *_Nonnull)rebateInfo {
    NSLog(@"LiveViewController::onRecvRebateInfoNotice( [接收返点通知], roomId : %@ )", roomId);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 设置余额及返点信息管理器
        IMRebateItem *imRebateItem = [[IMRebateItem alloc] init];
        imRebateItem.curCredit = rebateInfo.curCredit;
        imRebateItem.curTime = rebateInfo.curTime;
        imRebateItem.preCredit = rebateInfo.preCredit;
        imRebateItem.preTime = rebateInfo.preTime;
        [self.creditRebateManager setReBateItem:imRebateItem];

        // 更新本地返点信息
        self.liveRoom.imLiveRoom.rebateInfo = rebateInfo;
        // 更新返点控件
        [self setUpRewardedCredit:rebateInfo.curCredit];

        // 插入返点更新文本
        NSString *msg = [NSString stringWithFormat:@"%@ %0.0f coins", NSLocalizedStringFromSelf(@"Recv_Rebate"), rebateInfo.preCredit];
        MsgItem *msgItem = [[MsgItem alloc] init];
        msgItem.text = msg;
        msgItem.type = MsgType_Announce;
        NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
        msgItem.attText = attributeString;
        [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
    });
}

- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"LiveViewController::onRecvLevelUpNotice( [接收观众等级升级通知], level : %d )", level);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 插入观众等级升级文本
        NSString *msg = [NSString stringWithFormat:@"%@ %d", NSLocalizedStringFromSelf(@"Recv_Level_Up"), level];
        MsgItem *msgItem = [[MsgItem alloc] init];
        msgItem.text = msg;
        msgItem.type = MsgType_Announce;
        NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
        msgItem.attText = attributeString;
        [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
        
        self.liveRoom.imLiveRoom.manLevel = level;
        self.loginManager.loginItem.userlevel = level;
    });
}

- (void)onRecvLoveLevelUpNotice:(int)loveLevel {
    NSLog(@"LiveViewController::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知], loveLevel : %d )", loveLevel);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 插入观众等级升级文本
        NSString *msg = [NSString stringWithFormat:@"%@ %@ %@ %d", NSLocalizedStringFromSelf(@"Recv_Love_Up"), self.liveRoom.userName, NSLocalizedStringFromSelf(@"Love_Level_Up"), loveLevel];
        MsgItem *msgItem = [[MsgItem alloc] init];
        msgItem.text = msg;
        msgItem.type = MsgType_Announce;
        NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
        msgItem.attText = attributeString;
        [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
        
        self.liveRoom.imLiveRoom.loveLevel = loveLevel;
    });
}

- (void)onRecvRoomKickoffNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *_Nonnull)errmsg credit:(double)credit {
    NSLog(@"LiveViewController::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ credit:%f", roomId, credit);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            // 设置余额及返点信息管理器
            if (!(credit < 0)) {
                [self.creditRebateManager setCredit:credit];
            }
            // 弹出直播间关闭界面
            LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
            finshController.liveRoom = self.liveRoom;
            if (errType == LCC_ERR_NO_CREDIT || errType == LCC_ERR_COUPON_FAIL) {
                finshController.errType = errType;
            } else {
                finshController.errType = LCC_ERR_ROOM_LIVEKICKOFF;
            }
            finshController.errMsg = errmsg;
            
            [self.liveRoom.superController addChildViewController:finshController];
            [self.liveRoom.superView addSubview:finshController.view];
            [finshController.view bringSubviewToFront:self.liveRoom.superView];
            [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.liveRoom.superView);
            }];
            
            // 清空直播间信息
            self.liveRoom = nil;
            
            // 停止流
            [self stopPlay];
            [self stopPublish];
        }
    });
}

- (void)onRecvLackOfCreditNotice:(NSString *_Nonnull)roomId msg:(NSString *_Nonnull)msg credit:(double)credit {
    NSLog(@"LiveViewController::onRecvLackOfCreditNotice( [接收充值通知], roomId : %@ credit:%f", roomId, credit);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 设置余额及返点信息管理器
        if (!(credit < 0)) {
            [self.creditRebateManager setCredit:credit];
        }

        if (self.dialogWatchAddCredit) {
            [self.dialogWatchAddCredit removeFromSuperview];
        }
        WeakObject(self, weakSelf);
        self.dialogWatchAddCredit = [DialogOK dialog];
        self.dialogWatchAddCredit.tipsLabel.text = NSLocalizedStringFromSelf(@"WATCHING_WILL_NO_MONEY");
        [self.dialogWatchAddCredit showDialog:self.liveRoom.superView
                                  actionBlock:^{
                                      NSLog(@"没钱了。。");
                                      if ([weakSelf.liveDelegate respondsToSelector:@selector(noCreditPushTo:)]) {
                                          [weakSelf.liveDelegate noCreditPushTo:weakSelf];
                                      }
                                  }];
    });
}

- (void)onRecvCreditNotice:(NSString *_Nonnull)roomId credit:(double)credit {
    NSLog(@"LiveViewController::onRecvCreditNotice( [接收定时扣费通知], roomId : %@, credit : %f ）", roomId, credit);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 设置余额及返点信息管理器
        if (!(credit < 0)) {
            [self.creditRebateManager setCredit:credit];
        }
    });
}

- (void)onRecvSendTalentNotice:(ImTalentReplyObject *)item {
    NSLog(@"LiveViewController::onRecvSendTalentNotice( [接收直播间才艺点播回复通知] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!(item.credit < 0)) {
            // 更新返点控件
            [self setUpRewardedCredit:item.rebateCredit];
        }
    });
}

- (void)onRecvSendSystemNotice:(NSString *_Nonnull)roomId msg:(NSString *_Nonnull)msg link:(NSString *_Nonnull)link type:(IMSystemType)type{
    NSLog(@"LiveViewController::onRecvSendSystemNotice( [接收直播间公告消息], roomId : %@, msg : %@, link: %@ type:%d)", roomId, msg, link, type);
    dispatch_async(dispatch_get_main_queue(), ^{
        MsgItem *msgItem = [[MsgItem alloc] init];
        if (type == IMSYSTEMTYPE_COMMON) {
            msgItem.text = msg;
            if ([link isEqualToString:@""] || link == nil) {
                msgItem.type = MsgType_Announce;
            } else {
                msgItem.type = MsgType_Link;
                msgItem.linkStr = link;
            }
        } else {
            
            if (self.dialogWarning) {
                [self.dialogWarning removeFromSuperview];
            }
//            WeakObject(self, weakSelf);
            self.dialogWarning = [Dialog dialog];
            self.dialogWarning.tipsLabel.text = msg;
            [self.dialogWarning showDialog:self.liveRoom.superView actionBlock:^{
                
            }];
            
            msgItem.text = msg;
            msgItem.type = MsgType_Warning;
        }
        NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
        msgItem.attText = attributeString;
        [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
    });
}

- (void)onRecvLeavingPublicRoomNotice:(NSString *_Nonnull)roomId leftSeconds:(int)leftSeconds err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg {
    NSLog(@"LiveViewController::onRecvLeavingPublicRoomNotice( [接收关闭直播间倒数通知], roomId : %@ )", roomId);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            // 开启关闭倒计时定时器
            self.cameraBtn.userInteractionEnabled = NO;
            [self.cameraBtn setImage:[UIImage imageNamed:@"Live_willbe_end"] forState:UIControlStateNormal];
            self.countdownLabel.hidden = NO;
            self.cameraBtn.hidden = NO;
            [self.view bringSubviewToFront:self.countdownLabel];

            self.timeCount = leftSeconds;
            WeakObject(self, weakSelf);
            [self.timer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf changeTimeLabel];
                });
            }];
        }
    });
}

- (void)onRecvRoomCloseNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
    NSLog(@"LiveViewController::onRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@ )", roomId, errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {

            [self.timer stopTimer];

            // 弹出直播间关闭界面
            LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
            finshController.liveRoom = self.liveRoom;
            finshController.errType = errType;
            finshController.errMsg = errmsg;
            
            [self.liveRoom.superController addChildViewController:finshController];
            [self.liveRoom.superView addSubview:finshController.view];
            [finshController.view bringSubviewToFront:self.liveRoom.superView];
            [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.liveRoom.superView);
            }];
            
            // 清空直播间信息
            self.liveRoom = nil;

            // 停止流
            [self stopPlay];
            [self stopPublish];
        }
    });
}

- (void)onRecvChangeVideoUrl:(NSString *_Nonnull)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString*> *_Nonnull)playUrl {
    NSLog(@"LiveViewController::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@ )", roomId, playUrl);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新流地址
        [self.liveRoom reset];
        self.liveRoom.playUrlArray = [playUrl copy];
        
        [self stopPlay];
        [self play];
    });

}

#pragma mark - 倒数关闭直播间
- (void)changeTimeLabel {
    self.countdownLabel.text = [NSString stringWithFormat:@"%lds", (long)self.timeCount];
    self.timeCount -= 1;

    if (self.timeCount < 0) {
        [self.timer stopTimer];
        // 关闭之后，重设计数
        self.timeCount = TIMECOUNT;
    }
}

#pragma mark - 倒数控制
- (void)setupPreviewView {
    // 初始化预览界面
    self.stopVideoBtn.hidden = YES;
    self.muteBtn.hidden = YES;

    [self.muteBtn setImage:[UIImage imageNamed:@"Live_Publish_Btn_Mute_Selected"] forState:UIControlStateSelected];
}

- (void)videoBtnCountDown {
    @synchronized(self) {
        self.videoBtnLeftSecond--;
        if (self.videoBtnLeftSecond == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 隐藏视频静音和推送按钮
                self.stopVideoBtn.hidden = YES;
                self.muteBtn.hidden = YES;
            });
        }
    }
}

- (void)startVideoBtnTimer {
    NSLog(@"LiveViewController::startVideoBtnTimer()");

    WeakObject(self, weakSelf);
    [self.videoBtnTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
        [weakSelf videoBtnCountDown];
    }];
}

- (void)stopVideoBtnTimer {
    NSLog(@"LiveViewController::stopVideoBtnTimer()");

    [self.videoBtnTimer stopTimer];
}

- (void)countdownCloseLiveRoom {
    self.cameraBtn.userInteractionEnabled = NO;
    [self.cameraBtn setImage:[UIImage imageNamed:@"Live_willbe_end"] forState:UIControlStateNormal];
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    if( _isBackground == NO ) {
        _isBackground = YES;
        
        [LiveGobalManager manager].enterRoomBackgroundTime = [NSDate date];
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if( _isBackground == YES ) {
        _isBackground = NO;
    }
}

#pragma mark - LiveGobalManagerDelegate
- (void)enterBackgroundTimeOut:(NSDate * _Nullable)time {
    if (self.liveRoom) {
        NSLog(@"LiveViewController::enterBackgroundRoomOut( [接收后台关闭直播间] )");
        // 弹出直播间关闭界面
        LiveFinshViewController *finshController = [[LiveFinshViewController alloc] initWithNibName:nil bundle:nil];
        finshController.liveRoom = self.liveRoom;
        finshController.errType = LCC_ERR_BACKGROUND_TIMEOUT;
        
        [self.liveRoom.superController addChildViewController:finshController];
        [self.liveRoom.superView addSubview:finshController.view];
        [finshController.view bringSubviewToFront:self.liveRoom.superView];
        [finshController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.liveRoom.superView);
        }];
        
        // 清空直播间信息
        self.liveRoom = nil;
    }
}

#pragma mark - 字符串拼接
- (void)setUpRewardedCredit:(double)rebateCredit {

    NSMutableAttributedString *attribuStr = [[NSMutableAttributedString alloc] init];
    [attribuStr appendAttributedString:[self parseMessage:NSLocalizedStringFromSelf(@"Rebate_Tip") font:[UIFont systemFontOfSize:10] color:[UIColor whiteColor]]];
    [attribuStr appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%0.0f", rebateCredit] font:[UIFont systemFontOfSize:12] color:COLOR_WITH_16BAND_RGB(0xffd205)]];
    // 设置标题
    self.rewardedBtn.titleLabel.attributedText = attribuStr;
    [self.rewardedBtn setAttributedTitle:attribuStr forState:UIControlStateNormal];
}


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

#pragma mark - 调试
- (BOOL)handleDebugCmd:(NSString *)text {
    BOOL bFlag = NO;
    
    // 录制命令
    if( [text isEqualToString:RECORD_START] ) {
        NSLog(@"LiveViewController::handleDebugCmd( [record start] ）");
        [LiveModule module].debug = YES;
        [self stopPlay];
        [self play];
        bFlag = YES;
        
    } else if( [text isEqualToString:RECORD_STOP] ) {
        NSLog(@"LiveViewController::handleDebugCmd( [record stop] ）");
        [LiveModule module].debug = NO;
        [self stopPlay];
        [self play];
        bFlag = YES;
    }
    
    // 显示Debug信息命令
    if( [text isEqualToString:DEBUG_START] ) {
        NSLog(@"LiveViewController::handleDebugCmd( [debug show] ）");
        self.debugLabel.hidden = NO;
        bFlag = YES;
        
    } else if( [text isEqualToString:DEBUG_STOP] ) {
        NSLog(@"LiveViewController::handleDebugCmd( [debug hide] ）");
        self.debugLabel.hidden = YES;
        bFlag = YES;
    }
    
    return bFlag;
}

- (void)debugInfo {
    NSString *debugString = [NSString stringWithFormat:@"play: %@\n\npublish: %@\n", self.playUrl, self.publishUrl];
    self.debugLabel.text = debugString;
    [self.debugLabel sizeToFit];
}

#pragma mark - 测试
- (void)test {
    self.giftItemId = 1;
    self.msgId = 1;
    
//    self.testTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(testMethod) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.testTimer forMode:NSRunLoopCommonModes];
//
//    self.testTimer2 = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(testMethod2) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.testTimer2 forMode:NSRunLoopCommonModes];
//
//    self.testTimer3 = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(testMethod3) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.testTimer3 forMode:NSRunLoopCommonModes];
//
//    self.testTimer4 = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(testMethod4) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.testTimer4 forMode:NSRunLoopCommonModes];
}

- (void)stopTest {
    [self.testTimer invalidate];
    self.testTimer = nil;
    
    [self.testTimer2 invalidate];
    self.testTimer2 = nil;
    
    [self.testTimer3 invalidate];
    self.testTimer3 = nil;
    
    [self.testTimer4 invalidate];
    self.testTimer4 = nil;
}

- (void)testMethod {
    GiftItem* item = [[GiftItem alloc] init];
    item.fromid = self.loginManager.loginItem.userId;
    item.nickname = @"Max";
    item.giftid = [NSString stringWithFormat:@"%ld", (long)self.giftItemId++];
    item.multi_click_start = 0;
    item.multi_click_end = 10;
    
    [self addCombo:item];
}

- (void)testMethod2 {
    NSString* msg = [NSString stringWithFormat:@"msg%ld", (long)self.msgId++];
    [self sendMsg:msg isLounder:YES];
}

- (void)testMethod3 {
    NSString* msg = [NSString stringWithFormat:@"msg%ld", (long)self.msgId++];
//    [self sendMsg:msg isLounder:NO];
    
    [self addChatMessageNickName:@"randy" userLevel:6 text:msg honorUrl:nil];
}

- (void)testMethod4 {
    
    if (!self.isDriveShow) {
        [self userHaveJoinToRoom];
    }
}

@end
