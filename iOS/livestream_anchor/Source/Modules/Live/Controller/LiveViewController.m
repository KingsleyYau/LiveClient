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
#import "LiveService.h"
#import "LiveGobalManager.h"

#import "MsgTableViewCell.h"
#import "MsgItem.h"

#import "LiveGiftDownloadManager.h"
#import "LSChatEmotionManager.h"
#import "UserInfoManager.h"

#import "AudienModel.h"

#import "DialogOK.h"
#import "DialogChoose.h"
#import "DialogTip.h"
#import "DialogWarning.h"

#import "LSAnchorRequestManager.h"
#import "LSAnchorImManager.h"

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

#define TIMECOUNT 0

#pragma mark - 流[播放/推送]逻辑
#define STREAM_PLAYER_RECONNECT_MAX_TIMES 5
#define STREAM_PUBLISH_RECONNECT_MAX_TIMES STREAM_PLAYER_RECONNECT_MAX_TIMES

typedef enum RoomTipType {
    ROOMTIP_NONE,
    ROOMTIP_INVITING,
    ROOMTIP_AGREE,
    ROOMTIP_REJECT,
    ROOMTIP_FINSH
} RoomTipType;

@interface LiveViewController () <UITextFieldDelegate, LSCheckButtonDelegate, BarrageViewDataSouce, BarrageViewDelegate, GiftComboViewDelegate, ZBIMLiveRoomManagerDelegate, ZBIMManagerDelegate, DriverViewDelegate, MsgTableViewCellDelegate, LiveStreamPlayerDelegate, LiveStreamPublisherDelegate,LiveGobalManagerDelegate,LiveHeadViewDelegate,VIPAudienceViewDelegate, UIGestureRecognizerDelegate>

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
// 视频加载loadingview
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *videoLoadView;

#pragma mark - 观众管理
// 座驾数组
@property (strong) NSMutableArray *driverArray;

// 观众列表数组
@property (nonatomic, strong) NSMutableArray *audienceArray;

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

#pragma mark - 礼物管理器
@property (nonatomic, strong) GiftComboManager *giftComboManager;

#pragma mark - 用户信息管理器
@property (nonatomic, strong) UserInfoManager *userInfoManager;

#pragma mark - 礼物连击界面
@property (nonatomic, strong) NSMutableArray<GiftComboView *> *giftComboViews;
@property (nonatomic, strong) NSMutableArray<MASConstraint *> *giftComboViewsLeadings;

#pragma mark - 礼物下载器
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;

#pragma mark - 表情管理器
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;

#pragma mark - 消息管理器
@property (nonatomic, strong) LiveRoomMsgManager *msgManager;

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

#pragma mark - 主播立即私密邀请过期计时
@property (strong) LSTimer *inviteTimer;

#pragma mark - 弹幕
// 显示的弹幕数量 用于判断隐藏弹幕阴影
@property (nonatomic, assign) int showToastNum;

#pragma mark - 对话框
@property (strong) DialogTip *dialogProbationTip;
@property (nonatomic, strong) DialogWarning *dialogWarning;
/** 单击收起输入控件手势 **/
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

#pragma mark - 测试
@property (nonatomic, weak) NSTimer *testTimer;
@property (nonatomic, assign) NSInteger giftItemId;
@property (nonatomic, weak) NSTimer *testTimer2;
@property (nonatomic, weak) NSTimer *testTimer3;
@property (nonatomic, weak) NSTimer *testTimer4;
@property (nonatomic, assign) NSInteger msgId;
@property (nonatomic, assign) BOOL isDriveShow;

#pragma mark - IM管理器
@property (nonatomic, strong) LSAnchorImManager *imManager;

/** 聊天对象数组 **/
@property (nonatomic, strong) NSMutableArray *useridArray;

#pragma mark - 立即私密邀请(状态、url)
@property (strong) NSURL *pushUrl;
@property (nonatomic, assign) BOOL isInviting;
@property (nonatomic, copy) NSString *invitionId;

// 收到结束直播通知
@property (nonatomic, assign) BOOL isRecvRoomClose;

@property (nonatomic, assign) RoomTipType tipType;

@property (nonatomic, assign) BOOL reloadAudience;

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

    self.liveStreamType = LiveStreamType_ShowHost_Public;
    self.publisherReconnectTime = 0;

    // 初始化消息
    self.msgArray = [NSMutableArray array];
    self.msgShowArray = [NSMutableArray array];
    self.needToReload = NO;

    // 初始化IM管理器
    self.imManager = [LSAnchorImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    // 初始登录
    self.loginManager = [LSLoginManager manager];
    self.giftComboManager = [[GiftComboManager alloc] init];

    // 初始化用户信息管理器
    self.userInfoManager = [UserInfoManager manager];

    // 初始化礼物管理器
    self.giftDownloadManager = [LiveGiftDownloadManager manager];

    // 初始化表情管理器
    self.emotionManager = [LSChatEmotionManager emotionManager];

    // 初始化文字管理器
    self.msgManager = [LiveRoomMsgManager msgManager];

    // 初始化大礼物播放队列
    self.bigGiftArray = [NSMutableArray array];

    // 初始化座驾队列
    self.driverArray = [[NSMutableArray alloc] init];
    
    // 初始化观众列表队列
    self.audienceArray = [[NSMutableArray alloc] init];
    
    // 初始化真实观众队列
    self.chatAudienceArray = [[NSMutableArray alloc] init];
    
    // 初始化聊天对象数组
    self.useridArray = [[NSMutableArray alloc] init];

    // 初始化手势是否可操作
    self.isCanTouch = YES;
    
    // 初始化私密邀请状态
    self.isInviting = NO;
    
    // 刷新状态
    self.reloadAudience = YES;
    
    // 初始化是否收到关闭直播间通知
    self.isRecvRoomClose = NO;
    
    // 显示的弹幕数量
    self.showToastNum = 0;

    // 初始化视频控制按钮消失计时器
    self.videoBtnLeftSecond = 3;
    
    // 初始化倒计时关闭直播间计时器
    self.timeCount = 0;

    // 图片下载器
    self.headImageLoader = [LSImageViewLoader loader];
    self.giftImageLoader = [LSImageViewLoader loader];
    self.cellHeadImageLoader = [LSImageViewLoader loader];
    
    // 注册大礼物结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationWhatIs:) name:@"animationIsAnimaing" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invitationCountdown:) name:@"LivePushInviteNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookingCountdown:) name:@"LivePushBookingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCountdown:) name:@"LiveShowNotification" object:nil];
    // 初始化计时器
    self.videoBtnTimer = [[LSTimer alloc] init];
    
    // 初始化倒数关闭直播间计时器
    self.timer = [[LSTimer alloc] init];
    
    // 立即私密邀请过期计时器
    self.inviteTimer = [[LSTimer alloc] init];
    
    self.dialogProbationTip = [DialogTip dialogTip];
}

- (void)dealloc {
    NSLog(@"LiveViewController::dealloc()");
    
    // 移除直播间用户信息
    [[UserInfoManager manager] removeAllInfo];
    
    // 去除大礼物结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"animationIsAnimaing" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LivePushInviteNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LivePushBookingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LiveShowNotification" object:nil];
    [self.giftComboManager removeManager];

    for (GiftComboView *giftView in self.giftComboViews) {
        [giftView stopGiftCombo];
    }
    
    [[DialogTip dialogTip] stopTimer];
    
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
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 赋值到全局变量, 用于后台计时操作
    [LiveGobalManager manager].liveRoom = self.liveRoom;
    [LiveGobalManager manager].player = self.player;
    [LiveGobalManager manager].publisher = self.publisher;
    
    // QN判断正在直播间
    [LiveModule module].roomID = self.liveRoom.roomId;
    
    // 观众席添加代理
    self.audienceView.delegate = self;
    
    self.roomTipView.hidden = YES;
    
    // 禁止锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    // 初始化头部控件
    [self setupLiveHeadView];
    
    // 初始化消息列表
    [self setupTableView];

    // 初始化座驾控件
    [self setupDriverView];

    // 请求观众席列表
    [self setupAudienView];
    
    // 初始化连击控件
    [self setupGiftView];
    
    // 显示视频加载动画
    [self showVideoLoadView];
    
    // 初始化视频界面
    self.player.playView = self.videoView;
    self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;

    // 弹幕
    self.barrageView.hidden = YES;

    // 隐藏视频预览界面
    self.previewVideoViewWidth.constant = 0;

    // 隐藏互动直播ActivityView
    self.preActivityView.hidden = YES;
    
    // 默认隐藏邀请私密控件
    self.startOneViewHeigh.constant = 0;
    self.startOneView.layer.shadowColor = Color(0, 0, 0, 0.7).CGColor;
    self.startOneView.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.startOneView.layer.shadowOpacity = 0.5;
    self.startOneView.layer.shadowRadius = 1.0f;
    
    // 观众席人数控件
    self.viewersNumView.layer.cornerRadius = 5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    // 直播间倒数剩余秒数大于0，则倒数关闭
    if (self.liveRoom.imLiveRoom.leftSeconds > 0 && self.liveRoom.imLiveRoom.status == ZBLIVESTATUS_RECIPROCALEND) {
        self.isRecvRoomClose = YES;
        // 显示房间关闭倒计时
        [self setupTipRoomWithType:ROOMTIP_FINSH userName:nil];
        self.timeCount = self.liveRoom.imLiveRoom.leftSeconds;
        WeakObject(self, weakSelf);
        [self.timer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf changeTimeLabel];
            });
        }];
    }
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
    if( !self.viewDidAppearEver ) {
        // 第一次进入
        [self initPublish];
        [self publish];
    }
    // 开始计时器
    [self startVideoBtnTimer];
    
    [super viewDidAppear:animated];
    
     // 添加手势
    [self addSingleTap];

//    [self test];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 停止计时器
    [self stopVideoBtnTimer];
    
    // 去除手势
    [self removeSingleTap];
    
//    [self stopTest];
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化弹幕
    [self setupBarrageView];

    // 初始化预览界面
    [self setupPreviewView];
}

#pragma mark - Setter/Getter
- (void)setChatUserId:(NSString *)chatUserId {
    _chatUserId = chatUserId;
    [self.useridArray removeAllObjects];
    if (_chatUserId.length) {
        [self.useridArray addObject:_chatUserId];
    }
}

#pragma mark - 接收确认私密邀请通知 (LivePushInviteNotification)
- (void)invitationCountdown:(NSNotification *)notification {
    NSLog(@"LiveViewController::LivePushInviteNotification( %@ ) ",notification.object);
    NSURL *url = notification.object;
    LSUrlParmItem *item = [[LiveUrlHandler shareInstance] parseUrlParms:url];
    if (item.roomId.length) {
        [self sendSetRoomCountDown:item.roomId pushUrl:url];
    }
}

#pragma mark - 接收确认预约通知 (LivePushBookingNotification)
- (void)bookingCountdown:(NSNotification *)notification {
    
    NSLog(@"LiveViewController::LivePushBookingNotification( %@ ) ",notification.object);
    NSURL *url = notification.object;
    LSUrlParmItem *item = [[LiveUrlHandler shareInstance] parseUrlParms:url];
    if (item.roomId.length) {
        [self sendSetRoomCountDown:item.roomId pushUrl:url];
    }
}

#pragma mark - 接收确认预约通知 (LiveShowNotification)
- (void)showCountdown:(NSNotification *)notification  {
    NSLog(@"LiveViewController::LiveShowNotification( %@ ) ",notification.object);
    NSDictionary * dic = notification.object;
    [self sendSetRoomCountDown:[dic objectForKey:@"roomId"] pushUrl:[dic objectForKey:@"rul"]];
}

#pragma mark - 控件层次
- (void)bringSubviewToFrontFromView:(UIView *)view {

    [self.view bringSubviewToFront:self.giftView];
    [self.view bringSubviewToFront:self.barrageView];

    [view bringSubviewToFront:self.giftView];
    [view bringSubviewToFront:self.barrageView];
}

- (void)showPreview {
    // 显示预览控件
    self.previewVideoViewWidth.constant = 115;
}

- (void)showVideoLoadView {
    self.videoLoadView.hidden = NO;
    [self.videoLoadView startAnimating];
}

- (void)hiddenVideoLoadView {
    self.videoLoadView.hidden = YES;
    [self.videoLoadView stopAnimating];
}

- (void)showPreviewLoadView {
    self.preActivityView.hidden = NO;
    [self.preActivityView startAnimating];
}

- (void)hiddenPreviewLoadView {
    self.preActivityView.hidden = YES;
    [self.preActivityView stopAnimating];
}

#pragma mark - 手势事件 (单击屏幕)
- (void)addSingleTap {
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        self.singleTap.delegate = self;
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
        self.singleTap.delegate = nil;
    }
}

- (void)singleTapAction {
    if (self.liveHeadView.hidden) {
        self.liveHeadView.hidden = NO;
    } else {
        self.liveHeadView.hidden = YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (self.isCanTouch) {
        
        CGPoint pt = [touch locationInView:self.view];
        if (CGRectContainsPoint([self.videoView frame], pt)) {
            return YES;
        } else {
            return NO;
        }
        
    } else {
        return NO;
    }
}

#pragma mark - 流[播放/推送]逻辑
- (void)initPlayer {
    self.player.playView = self.previewVideoView;
    self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
}

- (void)play {
    self.playUrl = self.liveRoom.playUrl;
    NSLog(@"LiveViewController::play( [开始播放流], playUrl : %@ )", self.playUrl);
    [self debugInfo];
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *recordDir = [NSString stringWithFormat:@"%@/record", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *dateString = [LSDateFormatter toStringYMDHMSWithUnderLine:[NSDate date]];
    NSString *recordFilePath = [LiveModule module].debug?[NSString stringWithFormat:@"%@/%@_%@.flv", recordDir, self.liveRoom.userId, dateString]:@"";
    NSString *recordH264FilePath = @"";//[NSString stringWithFormat:@"%@/%@", recordDir, @"play.h264"];
    NSString *recordAACFilePath = @"";//[NSString stringWithFormat:@"%@/%@", recordDir, @"play.aac"];
    
    // 开始转菊花
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bFlag = [self.player playUrl:self.playUrl recordFilePath:recordFilePath recordH264FilePath:recordH264FilePath recordAACFilePath:recordAACFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bFlag) {
                // 播放成功
                if ([weakSelf.liveDelegate respondsToSelector:@selector(liveViewIsPlay:)]) {
                    [weakSelf.liveDelegate liveViewIsPlay:weakSelf];
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
    
    if( self.publisher == nil ) {
        self.publisher = [LiveStreamPublisher instance:self.liveStreamType];
        self.publisher.delegate = self;
    }
    
    // 初始化采集
    [self.publisher initCapture];
    
    // 初始化预览界面
    self.publisher.publishView = self.videoView;
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
            BOOL bFlag = [self.publisher pushlishUrl:self.publishUrl recordH264FilePath:@"" recordAACFilePath:@""];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self debugInfo];
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

- (void)playerOnConnect:(LiveStreamPlayer *)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 停止菊花
        [self hiddenPreviewLoadView];
    });
}

- (void)playerOnDisconnect:(LiveStreamPlayer *)player {
    
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

- (void)publisherOnConnect:(LiveStreamPublisher *)publisher {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hiddenVideoLoadView];
    });
}

- (void)publisherOnDisconnect:(LiveStreamPublisher *)publisher {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.videoLoadView.isAnimating && self.videoLoadView.hidden && self.liveRoom && !self.isRecvRoomClose) {
            [self showVideoLoadView];
            [[DialogTip dialogTip] showDialogTip:self.liveRoom.superView tipText:NSLocalizedStringFromSelf(@"VIDEO_IS_JUMPY")];
        }
    });
}

#pragma mark - 刷新状态栏
- (void)setupTipRoomWithType:(RoomTipType)type userName:(NSString *)userName {
    
    self.tipType = type;
    
    NSString *name = userName;
//    if (userName.length > 10) {
//        name = [NSString stringWithFormat:@"%@...",[userName substringToIndex:10]];
//    }
    self.roomTipView.hidden = NO;
    [self.tipIconImageView stopAnimating];
    self.tipIconImageView.animationImages = nil;
    
    switch (type) {
        case ROOMTIP_FINSH:{
            self.tipIconImageWidth.constant = 0;
            self.tipMessageLabel.text = NSLocalizedStringFromSelf(@"LIVE_WILL_END");
            
        }break;
        
        case ROOMTIP_REJECT:{
            self.tipIconImageWidth.constant = 14;
            self.tipIconImageView.image = [UIImage imageNamed:@"Live_Tip_Warning_Icon"];
            self.tipMessageLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"LIVE_INVITE_FAIL"), name];
            // 三秒消失
            LSTimer *timer = [[LSTimer alloc] init];
            [timer startTimer:nil timeInterval:3.0 * NSEC_PER_SEC starNow:NO action:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.roomTipView.hidden = YES;
                    [timer stopTimer];
                });
            }];
            
        }break;
            
        case ROOMTIP_AGREE:{
            self.tipIconImageWidth.constant = 14;
            self.tipIconImageView.image = [UIImage imageNamed:@"Live_Tip_Accepted_Icon"];
            self.tipMessageLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"LIVE_INVITE_HAS_ACCEPT"),name];
            
        }break;
            
        case ROOMTIP_INVITING:{
            self.tipIconImageWidth.constant = 14;
            NSMutableArray *iconArray = [[NSMutableArray alloc] init];
            for (int i = 1; i <= 3; i++) {
                NSString *imageName = [NSString stringWithFormat:@"Live_Liver_Invite_To_%d", i];
                UIImage *image = [UIImage imageNamed:imageName];
                [iconArray addObject:image];
            }
            self.tipIconImageView.animationImages = iconArray;
            self.tipIconImageView.animationRepeatCount = 0;
            self.tipIconImageView.animationDuration = 0.6;
            [self.tipIconImageView startAnimating];
            self.tipMessageLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"LIVE_INVITE_ING"),name];
            
        }break;
            
        default:{
            
        }break;
    }
}

#pragma mark - 初始化头部控件
- (void)setupLiveHeadView {
    self.liveHeadView.delegate = self;
    
    self.liveHeadView.closeBtn.hidden = self.liveRoom.showId.length > 0?YES:NO;
    
    self.viewersTotalNumLabel.text = [NSString stringWithFormat:@" / %d",self.liveRoom.imLiveRoom.maxFansiNum];
}

#pragma mark - 初始化座驾控件
- (void)setupDriverView {

    // 初始化座驾播放标志
    self.isDriveShow = NO;

    self.driverView = [[DriverView alloc] init];
    [self.driverView setupViewColor:self.roomStyleItem];
    self.driverView.alpha = 0.3;
    self.driverView.delegate = self;
    self.driverView.hidden = YES;
    [self.view addSubview:self.driverView];
}

#pragma mark - 获取观众列表
- (void)setupAudienView {
    [[LSAnchorRequestManager manager] anchorLiveFansList:self.liveRoom.roomId start:0 step:0 finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<ZBViewerFansItemObject *> * _Nullable array) {
        NSLog(@"LiveViewController::AnchorLiveFansList( [请求观众列表], success : %d, errnum : %ld, errmsg : %@, array : %u )", success, (long)errnum, errmsg, (unsigned int)array.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                
                [self.audienceArray removeAllObjects];
                [self.chatAudienceArray removeAllObjects];
                for (ZBViewerFansItemObject *item in array) {
                    AudienModel *model = [[AudienModel alloc] init];
                    model.userId = item.userId;
                    model.nickName = item.nickName;
                    model.photoUrl = item.photoUrl;
                    model.mountId = item.mountId;
                    model.mountname = item.mountName;
                    model.mountUrl = item.mountUrl;
                    model.level = item.level;
                    model.image = [UIImage imageNamed:@"Default_Img_Man_Circyle"];
                    model.isHasTicket = item.isHasTicket;
                    [self.audienceArray addObject:model];
                    [self.chatAudienceArray addObject:model];
                    
                    // 更新并缓存本地观众数据
                    [[UserInfoManager manager] setAudienceInfoDicL:model];
                }
                
                // 观众人数显示
                self.viewersNumLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)self.audienceArray.count];
                
                // 默认六个头像
                if (self.audienceArray.count < self.liveRoom.imLiveRoom.maxFansiNum) {
                    NSUInteger count = self.liveRoom.imLiveRoom.maxFansiNum - self.audienceArray.count;
                    for (NSUInteger num = 0; num < count; num++) {
                        AudienModel *model = [[AudienModel alloc] init];
                        model.image = [UIImage imageNamed:@"Default_Img_Noman_Circyle"];
                        [self.audienceArray addObject:model];
                    }
                }
                if (self.reloadAudience) {
                    self.reloadAudience = NO;
                    self.audienceView.audienceArray = self.audienceArray;
                    [self.audienceView updateUserInfo];
                }
            }
        });
    }];
}

#pragma mark - VIPAudienceViewDelegate
- (void)vipLiveAudidenveViewDidSelectItem:(AudienModel *)model {
    if ([self.liveDelegate respondsToSelector:@selector(audidenveViewDidSelectItem:)]) {
        [self.liveDelegate audidenveViewDidSelectItem:model];
    }
}

#pragma mark - 座驾（入场信息）
- (void)canPlayDirve:(DriverView *)driverView driverModel:(AudienModel *)model offset:(int)offset ifError:(NSError *)error {
    
    if (error) {
        // 移除错误下载
        [self drivePlayCallback];
    } else {
        [self.driverView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@70);
            make.right.equalTo(self.view.mas_right).offset(offset);
            make.width.equalTo(@(offset));
        }];
        // 播放座驾动画
        [self driveAnimationOffset:offset];
    }
}

#pragma mark - 座驾入场动画
- (void)driveAnimationOffset:(int)offset {
    [self.view layoutIfNeeded];

    self.driverView.hidden = NO;
    [self.driverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-13);
    }];

    WeakObject(self, weakSelf);
    [UIView animateWithDuration:2
        animations:^{
            weakSelf.driverView.alpha = 1;
            [weakSelf.view layoutIfNeeded];

        }
        completion:^(BOOL finished) {

            [UIView animateWithDuration:0.5
                delay:1
                options:0
                animations:^{

                    weakSelf.driverView.alpha = 0;
                }
                completion:^(BOOL finished) {

//                    [weakSelf.driverView mas_updateConstraints:^(MASConstraintMaker *make) {
//                        make.right.equalTo(self.view.mas_right).offset(offset);
//                    }];
                    weakSelf.driverView.hidden = YES;
                    // 播放完回调
                    [weakSelf drivePlayCallback];

                    // 测试
                    // weakSelf.isDriveShow = NO;

                }];
        }];
}

#pragma mark - 座驾动画播放完回调
- (void)drivePlayCallback {

    if (self.driverArray.count) {
        [self.driverArray removeObjectAtIndex:0];
        
        if (self.driverArray.count) {
            self.isDriveShow = YES;
            [self.driverView audienceComeInLiveRoom:self.driverArray[0]];
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
    [self.userInfoManager getFansBaseInfo:userId
                        finishHandler:^(AudienModel *_Nonnull item) {
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
    [self.userInfoManager getFansBaseInfo:bgItem.userId
                        finishHandler:^(AudienModel *_Nonnull item) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf.headImageLoader refreshCachedImage:cell.imageViewHeader options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
                            });
                        }];
    NSString *name = bgItem.name;
    if (bgItem.name.length > 20) {
        name = [NSString stringWithFormat:@"%@...",[bgItem.name substringToIndex:15]];
    }
    NSString *message = [NSString stringWithFormat:@"%@：%@",name ,bgItem.message];
    cell.labelMessage.attributedText = [self.emotionManager parseMessageTextEmotion:message font:[UIFont boldSystemFontOfSize:15]];

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

    self.msgTableView.clipsToBounds = YES;
    self.msgTableView.backgroundView = nil;
    self.msgTableView.backgroundColor = [UIColor clearColor];
//    self.msgTableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    [self.msgTableView registerClass:[MsgTableViewCell class] forCellReuseIdentifier:[MsgTableViewCell cellIdentifier]];

    self.msgTipsView.hidden = YES;

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMsgTipsView:)];
    [self.msgTipsView addGestureRecognizer:singleTap];

    [self.view insertSubview:self.barrageView aboveSubview:self.tableSuperView];
}

- (BOOL)sendMsg:(NSString *)text {
    NSLog(@"LiveViewController::sendMsg( [发送文本消息], text : %@ )", text);

    BOOL bFlag = NO;
    BOOL bDebug = NO;
    
    bDebug = [self handleDebugCmd:text];
    NSString *str =  [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 发送IM文本
    if( !bDebug ) {
        if (str.length > 0) {
            bFlag = YES;
            // 调用IM命令(发送直播间消息)
            [self sendRoomMsgRequestFromText:text];
        }
    }
    
    return bFlag;
}

- (void)addTips:(NSString *)text {
    MsgItem *item = [[MsgItem alloc] init];
    item.text = text;
    item.msgType = MsgType_Announce;
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:item];
    item.attText = attributeString;
    [self addMsg:item replace:NO scrollToEnd:YES animated:YES];
}

#pragma mark - 聊天文本消息管理
// 插入普通聊天消息
- (void)addChatMessageNickName:(NSString *)name userLevel:(NSInteger)level text:(NSString *)text honorUrl:(NSString *)honorUrl
                        fromId:(NSString *)fromId
                   isHasTicket:(BOOL)isHasTicket {
    NSLog(@"LiveViewController::addChatMessage( [插入文本消息], text : %@ )", text);

    // 发送普通消息
    MsgItem *item = [[MsgItem alloc] init];
    
    // 判断是谁发送
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        item.usersType = UsersType_Liver;
        
    } else {
         item.usersType = UsersType_Audience;
    }
    item.level = level;
    item.name = name;
    item.text = text;
    item.honorUrl = honorUrl;
    item.isHasTicket = isHasTicket;
    if ( text.length > 0 && text != nil ) {
        NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:item];
        item.attText = [self.emotionManager parseMessageAttributedTextEmotion:attributeString font:MessageFont];
    }
    // 插入到消息列表
    [self addMsg:item replace:NO scrollToEnd:YES animated:YES];
}

// 插入送礼消息
- (void)addGiftMessageNickName:(NSString *)nickName giftID:(NSString *)giftID giftNum:(int)giftNum honorUrl:(NSString *)honorUrl
                        fromId:(NSString *)fromId
                   isHasTicket:(BOOL)isHasTicket{
    AllGiftItem *item = [[LiveGiftDownloadManager manager] backGiftItemWithGiftID:giftID];

    MsgItem *msgItem = [[MsgItem alloc] init];
    // 判断是谁发送
    if ([fromId isEqualToString:self.loginManager.loginItem.userId]) {
        msgItem.usersType = UsersType_Liver;
    } else {
        msgItem.usersType = UsersType_Audience;
    }
    msgItem.name = nickName;
    msgItem.level = 0;
    msgItem.msgType = MsgType_Gift;
    msgItem.giftName = item.infoItem.name;
    msgItem.smallImgUrl = [self.giftDownloadManager backSmallImgUrlWithGiftID:giftID];
    msgItem.giftNum = giftNum;
    msgItem.honorUrl = honorUrl;
    msgItem.isHasTicket = isHasTicket;
    // 增加文本消息
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
    msgItem.attText = attributeString;
    [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
}

- (MsgItem *)addJoinMessageNickName:(NSString *)nickName honorUrl:(NSString *)honorUrl fromId:(NSString *)fromId isHasTicket:(BOOL)isHasTicket{
    MsgItem *msgItem = [[MsgItem alloc] init];
    msgItem.usersType = UsersType_Audience;
    msgItem.msgType = MsgType_Join;
    msgItem.name = nickName;
    msgItem.honorUrl = honorUrl;
    msgItem.isHasTicket = isHasTicket;
    NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
    msgItem.attText = attributeString;
    return msgItem;
}

- (void)addRiderJoinMessageNickName:(NSString *)nickName riderName:(NSString *)riderName riderUrl:(NSString *)riderUrl honorUrl:(NSString *)honorUrl fromId:(NSString *)fromId isHasTicket:(BOOL)isHasTicket{
    // 用户座驾入场信息
    MsgItem *riderItem = [[MsgItem alloc] init];
    riderItem.usersType = UsersType_Audience;
    riderItem.msgType = MsgType_RiderJoin;
    riderItem.name = nickName;
    riderItem.riderName = riderName;
    riderItem.riderUrl = riderUrl;
    riderItem.honorUrl = honorUrl;
    riderItem.isHasTicket = isHasTicket;
    NSMutableAttributedString *riderString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:riderItem];
    riderItem.attText = riderString;
    [self addMsg:riderItem replace:NO scrollToEnd:YES animated:YES];
    
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
    // 计算文本高度
    item.containerHeight = [self computeContainerHeight:item];
    
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

- (CGFloat)computeContainerHeight:(MsgItem *)item {
    CGFloat height = 0;
    CGFloat width = self.tableSuperView.frame.size.width;
    YYTextContainer *container = [[YYTextContainer alloc] init];
    if (item.msgType == MsgType_Gift) {
        width = width - 3;
    }
    container.size = CGSizeMake(width, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:item.attText];
    height = layout.textBoundingSize.height + 1;
    if (height < 22) {
        height = 22;
    }
    item.layout = layout;
    item.labelFrame = CGRectMake(0, 0, layout.textBoundingSize.width, height);
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
    return item.containerHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    // 数据填充
    if (indexPath.row < self.msgShowArray.count) {
        MsgItem *item = [self.msgShowArray objectAtIndex:indexPath.row];

        MsgTableViewCell *msgCell = [tableView dequeueReusableCellWithIdentifier:[MsgTableViewCell cellIdentifier]];
        msgCell.clipsToBounds = YES;
        msgCell.msgDelegate = self;
        [msgCell setTextBackgroundViewColor:self.roomStyleItem];
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

#pragma mark - MsgTableViewCellDelegate
- (void)msgCellRequestHttp:(NSString *)linkUrl {
    LiveWebViewController *webViewController = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
    webViewController.url = linkUrl;
    webViewController.isIntimacy = NO;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - LiveHeadViewDelegate (发送退出直播间、切换摄像头)
- (void)liveHeadCloseAction:(LiveHeadView *)liveHeadView {
    if ([self.liveDelegate respondsToSelector:@selector(liveRoomIsClose:)]) {
        if (self.timeCount == 0) {
            [self.liveDelegate liveRoomIsClose:self];
        }
    }
}

- (void)liveHeadChangeCameraAction:(LiveHeadView *)liveHeadView {
    // 旋转摄像头
    [self.publisher rotateCamera];
}

#pragma mark - 发送请求 (请求发送直播间消息、请求发送立即私密邀请、请求设置准备进入直播间)
- (void)sendRoomMsgRequestFromText:(NSString *)text {
    BOOL inRoom = NO;
    AudienModel *item = [[AudienModel alloc] init];
    for (AudienModel *model in self.chatAudienceArray) {
        if ([model.userId isEqualToString:self.chatUserId]) {
            item = model;
            inRoom = YES;
        }
    }
    NSString *chatMsg = text;
    if (item.nickName) {
        chatMsg = [NSString stringWithFormat:@"@%@ %@",item.nickName ,text];
    }
    // 如果@用户不在直播间则弹提示
    if (!inRoom && self.useridArray.count) {
        [[DialogTip dialogTip] showDialogTip:self.liveRoom.superView tipText:NSLocalizedStringFromSelf(@"CONTACT_NOT_HAVE")];
    } else {
        // 发送直播间消息
        [self.imManager sendLiveChat:self.liveRoom.roomId nickName:self.loginManager.loginItem.nickName msg:chatMsg at:self.useridArray];
    }
}

- (void)sendInstantInviteUser:(NSString *)userid userName:(NSString *)userName {
    
    // 主播发送立即私密邀请
    [self.imManager anchorSendImmediatePrivateInvite:userid finishHandler:^(BOOL success, ZBLCC_ERR_TYPE errType, NSString * _Nonnull errMsg, NSString * _Nonnull invitation, int timeOut, NSString * _Nonnull roomId) {
        NSLog(@"LiveViewController::anchorSendImmediatePrivateInvite( [主播发送立即私密邀请] success : %@, errType : %d, errMsg : %@, invitation : %@, timeOut : %d, roomId : %@ )",(success == YES) ? @"成功" : @"失败", errType, errMsg, invitation, timeOut, roomId);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                // 如果有roomid直接进入直播间
                if (roomId.length) {
                    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:roomId userId:userid roomType:LiveRoomType_Private];
                    [self sendSetRoomCountDown:roomId pushUrl:url];
                    
                } else {
                    // 如果正在倒计时关闭直播间，则停止计时器
                    if (self.timer) {
                        [self.timer stopTimer];
                    }
                    // 邀请中...
                    [self setupTipRoomWithType:ROOMTIP_INVITING userName:userName];
                    self.invitionId = invitation;
                    if (timeOut) {
                        // 邀请超时显示失败
                        [self.inviteTimer startTimer:nil timeInterval:timeOut * NSEC_PER_SEC starNow:NO action:^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self setupTipRoomWithType:ROOMTIP_REJECT userName:userName];
                                [self.inviteTimer stopTimer];
                            });
                        }];
                    }
                }
            } else {
                // 错误提示
                [self showDialogTipView:errMsg];
            }
        });
    }];
}

- (void)sendSetRoomCountDown:(NSString *)roomid pushUrl:(NSURL *)pushUrl {
    // 设置准备进入直播间 请求失败则3秒重试
    LSTimer *timer = [[LSTimer alloc] init];
    [timer startTimer:dispatch_get_main_queue() timeInterval:3.0 * NSEC_PER_SEC starNow:YES action:^{
        [[LSAnchorRequestManager manager] anchorSetRoomCountDowne:roomid
                finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
                    NSLog(@"LiveViewController::anchorSetRoomCountDowne( [设置准备进入直播间] success : %@, errnum : %d, errmsg : %@ roomId : %@)", (success == YES) ? @"成功":@"失败", errnum, errmsg , roomid);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (errnum != ZBHTTP_LCC_ERR_CONNECTFAIL) {
                            [timer stopTimer];
                        }
                        if (success) {
                            self.isInviting = YES;
                            self.pushUrl = pushUrl;
                        }
                    });
                }];
    }];
}

#pragma mark - IM通知
- (void)onZBLogin:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ZBImLoginReturnObject *)item {
    NSLog(@"LiveViewController::onZBLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    if (errType == ZBLCC_ERR_SUCCESS) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.liveRoom.roomId) {
                [self.imManager enterRoom:self.liveRoom.roomId finishHandler:^(BOOL success, ZBLCC_ERR_TYPE errType, NSString * _Nonnull errMsg, ZBImLiveRoomObject * _Nonnull roomItem) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            NSLog(@"LiveViewController::onZBLogin( [IM登陆, 成功, 重新进入直播间], roomId : %@ )", self.liveRoom.roomId);
                            // 更新直播间信息
                            [self.liveRoom reset];
                            self.liveRoom.imLiveRoom = roomItem;

                            // 重新推流
                            [self stopPublish];
                            [self publish];

                            if ([self.liveDelegate respondsToSelector:@selector(onReEnterRoom:)]) {
                                [self.liveDelegate onReEnterRoom:self];
                            }

                        } else {
                            NSLog(@"LiveViewController::onLogin( [IM登陆, 成功, 但直播间已经关闭], roomId : %@ )", self.liveRoom.roomId);

                            if (errType != ZBLCC_ERR_CONNECTFAIL) {
                                // 停止推拉流、结束直播
                                [self stopLiveWithErrtype:ZBLCC_ERR_NOT_FOUND_ROOM errMsg:NSLocalizedStringFromSelf(@"LIVE_NOT_ROOM")];
                            }
                        }
                    });
                }];
                
            } else {
                // 停止推拉流、结束直播
                [self stopLiveWithErrtype:ZBLCC_ERR_NOT_FOUND_ROOM errMsg:NSLocalizedStringFromSelf(@"LIVE_NOT_ROOM")];
            }
            
        });
    }
}

- (void)onZBLogout:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LiveViewController::onZBLogout( [IM注销通知], errType : %d, errmsg : %@, playerReconnectTime : %lu, publisherReconnectTime : %lu )", errType, errmsg, (unsigned long)self.playerReconnectTime, (unsigned long)self.publisherReconnectTime);

    @synchronized(self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // IM断开, 重置RTMP断开次数
            if (self.liveRoom) {
                [[DialogTip dialogTip] showDialogTip:self.liveRoom.superView tipText:NSLocalizedStringFromSelf(@"VIDEO_IS_JUMPY")];
            }
            self.playerReconnectTime = 0;
            self.publisherReconnectTime = 0;
        });
    }
}

- (void)onZBRecvSendGiftNotice:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName giftId:(NSString *)giftId giftName:(NSString *)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(NSString *)honorUrl totalCredit:(int)totalCredit {
    NSLog(@"LiveViewController::onZBRecvSendGiftNotice( [接收礼物], roomId : %@, fromId : %@, nickName : %@, giftId : %@, giftName : %@, giftNum : %d, honorUrl : %@ )", roomId, fromId, nickName, giftId, giftName, giftNum, honorUrl);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {

            // 判断本地是否有该礼物
            if ([self.giftDownloadManager judgeTheGiftidIsHere:giftId]) {

                // 连击起始数
                NSInteger starNum = multi_click_start - 1;

                // 接收礼物消息item
                GiftItem *giftItem = [GiftItem itemRoomId:roomId fromID:fromId nickName:nickName giftID:giftId giftName:giftName giftNum:giftNum multi_click:multi_click starNum:starNum endNum:multi_click_end clickID:multi_click_id];

                ZBGiftType type = [self.giftDownloadManager backImgTypeWithGiftID:giftId];
                if (type == ZBGIFTTYPE_COMMON) {
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

                [self.userInfoManager getFansBaseInfo:fromId finishHandler:^(AudienModel * _Nonnull item) {
                    // 插入送礼文本消息
                    [self addGiftMessageNickName:nickName giftID:giftId giftNum:giftNum honorUrl:honorUrl fromId:fromId isHasTicket:item.isHasTicket];
                }];

            } else {
                // 获取礼物详情
                [self.giftDownloadManager requestListnotGiftID:giftId];
            }
        }
    });
}

- (void)onZBRecvSendToastNotice:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName msg:(NSString *)msg honorUrl:(NSString *)honorUrl {
    NSLog(@"LiveViewController::onZBRecvSendToastNotice( [接收直播间弹幕通知], roomId : %@, fromId : %@, nickName : %@, msg : %@ honorUrl:%@)", roomId, fromId, nickName, msg, honorUrl);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.barrageView.hidden = NO;

            [self.userInfoManager getFansBaseInfo:fromId finishHandler:^(AudienModel * _Nonnull item) {
                // 插入普通文本消息
                [self addChatMessageNickName:nickName userLevel:false text:msg honorUrl:honorUrl fromId:fromId isHasTicket:item.isHasTicket];
            }];

            // 插入到弹幕
            BarrageModel *bgItem = [BarrageModel barrageModelForName:nickName message:msg urlWihtUserID:fromId];
            NSArray *items = [NSArray arrayWithObjects:bgItem, nil];
            [self.barrageView insertBarrages:items immediatelyShow:YES];
        }
    });
}

- (void)onZBRecvSendChatNotice:(NSString *)roomId level:(int)level fromId:(NSString *)fromId nickName:(NSString *)nickName msg:(NSString *)msg honorUrl:(NSString *)honorUrl {
    NSLog(@"LiveViewController::onZBRecvSendChatNotice( [接收直播间文本消息通知], roomId : %@, nickName : %@, msg : %@ )", roomId, nickName, msg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            
            [self.userInfoManager getFansBaseInfo:fromId finishHandler:^(AudienModel * _Nonnull item) {
                // 插入聊天消息到列表
                [self addChatMessageNickName:nickName userLevel:level text:msg honorUrl:honorUrl fromId:fromId isHasTicket:item.isHasTicket];
            }];
        }
    });
}

- (void)onZBRecvSendSystemNotice:(NSString *)roomId msg:(NSString *)msg link:(NSString *)link type:(ZBIMSystemType)type {
    NSLog(@"LiveViewController::onZBRecvSendSystemNotice( [接收直播间公告消息], roomId : %@, msg : %@, link: %@ type:%d)", roomId, msg, link, type);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            MsgItem *msgItem = [[MsgItem alloc] init];
            if (type == ZBIMSYSTEMTYPE_COMMON) {
                msgItem.text = msg;
                if ([link isEqualToString:@""] || link == nil) {
                    msgItem.msgType = MsgType_Announce;
                } else {
                    msgItem.msgType = MsgType_Link;
                    msgItem.linkStr = link;
                }
            } else {
                
                if (self.dialogWarning) {
                    [self.dialogWarning hidenDialog];
                }
                //            WeakObject(self, weakSelf);
                self.dialogWarning = [DialogWarning dialog];
                self.dialogWarning.tipsLabel.text = msg;
                [self.dialogWarning showDialog:self.liveRoom.superView actionBlock:^{
                    
                }];
                
                msgItem.text = msg;
                msgItem.msgType = MsgType_Warning;
            }
            NSMutableAttributedString *attributeString = [self.msgManager presentTheRoomStyleItem:self.roomStyleItem msgItem:msgItem];
            msgItem.attText = attributeString;
            [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];
        }
    });
}

- (void)onZBRecvEnterRoomNotice:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl riderId:(NSString *)riderId riderName:(NSString *)riderName riderUrl:(NSString *)riderUrl fansNum:(int)fansNum isHasTicket:(BOOL)isHasTicket {
    NSLog(@"LiveViewController::onZBRecvEnterRoomNotice( [接收观众进入直播间], roomId : %@, userId : %@, nickName : %@, photoUrl : %@ )", roomId, userId, nickName, photoUrl);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.reloadAudience = YES;
            // 刷观众列表
            [self setupAudienView];

            // 如果有座驾
            if (riderId.length) {
                // 坐骑队列
                AudienModel *model = [[AudienModel alloc] init];
                model.userId = userId;
                model.nickName = nickName;
                model.photoUrl = photoUrl;
                model.mountId = riderId;
                model.mountname = riderName;
                model.mountUrl = riderUrl;
                [self.driverArray addObject:model];
                if (!self.isDriveShow) {
                    self.isDriveShow = YES;
                    [self.driverView audienceComeInLiveRoom:self.driverArray[0]];
                }

                // 用户座驾入场信息
                [self addRiderJoinMessageNickName:nickName riderName:riderName riderUrl:riderUrl honorUrl:nil fromId:userId isHasTicket:isHasTicket];

            } else { // 如果没座驾
                // 插入入场消息到列表
                MsgItem *msgItem = [self addJoinMessageNickName:nickName honorUrl:nil fromId:userId isHasTicket:isHasTicket];

                // (插入/替换)到到消息列表
                BOOL replace = NO;
                if (self.msgArray.count > 0) {
                    MsgItem *lastItem = [self.msgArray lastObject];
                    if (lastItem.msgType == msgItem.msgType) {
                        // 同样是入场消息, 替换最后一条
                        replace = NO;
                    }
                }
                [self addMsg:msgItem replace:replace scrollToEnd:YES animated:YES];
            }
        }
    });
}

- (void)onZBRecvLeaveRoomNotice:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl fansNum:(int)fansNum {
    NSLog(@"LiveViewController::onZBRecvLeaveRoomNotice( [接收观众退出直播间通知] ) roomId : %@, userId : %@, nickName : %@, photoUrl : %@, fansNum : %d", roomId, userId, nickName, photoUrl, fansNum);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.reloadAudience = YES;
            [self setupAudienView];
        }
    });
}

- (void)onZBRecvInstantInviteReplyNotice:(NSString *)inviteId replyType:(ZBReplyType)replyType roomId:(NSString *)roomId roomType:(ZBRoomType)roomType userId:(NSString *)userId nickName:(NSString *)nickName avatarImg:(NSString *)avatarImg {
    NSLog(@"LiveViewController::onZBRecvInstantInviteReplyNotice( [接收立即私密邀请回复通知]  inviteId : %@, replyType : %d, roomId : %@, roomType : %d, userId : %@, nickName : %@ )", inviteId, replyType, roomId, roomType, userId, nickName);
    // 停止邀请过期计时器
    [self.inviteTimer stopTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 判断是否同一个邀请
        if ([self.invitionId isEqualToString:inviteId]) {
            if (replyType == ZBREPLYTYPE_AGREE) {
                // 更新提示栏
//                [self setupTipRoomWithType:ROOMTIP_AGREE userName:nickName];
                self.tipType = ROOMTIP_AGREE;
                
                // 设置准备进入直播间
                NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:roomId userId:userId roomType:LiveRoomType_Private];
                [self sendSetRoomCountDown:roomId pushUrl:url];
                
                // 插入文本提示
                [self addTips:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"LIVE_INVITE_HAS_ACCEPT"),nickName]];
                
            } else {
                [self setupTipRoomWithType:ROOMTIP_REJECT userName:nickName];
            }
        }
    });
}

- (void)onZBRecvRoomKickoffNotice:(NSString *)roomId errType:(ZBLCC_ERR_TYPE)errType errmsg:(NSString *)errmsg {
    NSLog(@"LiveViewController::onZBRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@", roomId);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            // 停止推拉流、显示结束直播间界面
            [self stopLiveWithErrtype:errType errMsg:errmsg];
        }
    });
}

- (void)onZBRecvLeavingPublicRoomNotice:(NSString *)roomId leftSeconds:(int)leftSeconds err:(ZBLCC_ERR_TYPE)err errMsg:(NSString *)errMsg {
    NSLog(@"LiveViewController::onZBRecvLeavingPublicRoomNotice( [接收关闭直播间倒数通知], roomId : %@ )", roomId);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            self.isRecvRoomClose = YES;
            // 显示房间关闭倒计时
            [self setupTipRoomWithType:ROOMTIP_FINSH userName:nil];
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

- (void)onRecvAnchorLeaveRoomNotice:(NSString *)roomId anchorId:(NSString *)anchorId {
    NSLog(@"LiveViewController::onRecvAnchorLeaveRoomNotice( [接收主播退出直播间通知], roomId : %@ , anchorId : %@ )", roomId, anchorId);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.liveRoom.roomId isEqualToString:roomId] && [self.loginManager.loginItem.userId isEqualToString:anchorId]) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

- (void)onZBRecvRoomCloseNotice:(NSString *)roomId errType:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LiveViewController::onZBRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@ )", roomId, errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            
            // 接收关闭直播间通知
            self.isRecvRoomClose = YES;
            
            if (self.isInviting) {
                // 停止流
                [self stopPlay];
                [self stopPublish];
                // 跳转过渡页
                [[LiveService service] openUrlByLive:self.pushUrl];
                
            } else {
                // 停止流、显示结束直播页
                [self stopLiveWithErrtype:errType errMsg:errmsg];
            }
        }
    });
}

//- (void)onRecvChangeVideoUrl:(NSString *_Nonnull)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString*> *_Nonnull)playUrl {
//    NSLog(@"LiveViewController::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@ )", roomId, playUrl);
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        // 更新流地址
//        [self.liveRoom reset];
//        self.liveRoom.playUrlArray = [playUrl copy];
//
//        [self stopPlay];
//        [self play];
//    });
//
//}

#pragma mark - 倒数关闭直播间
- (void)changeTimeLabel {
    NSString *str = [NSString stringWithFormat:@"%lds", (long)self.timeCount];
    NSAttributedString *countStr = [self parseMessage:str font:[UIFont systemFontOfSize:18] color:[UIColor whiteColor]];
    NSMutableAttributedString *timeStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"LIVE_WILL_END")];
    [timeStr appendAttributedString:countStr];
    self.tipMessageLabel.attributedText = timeStr;
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

}

- (void)videoBtnCountDown {
    @synchronized(self) {
        self.videoBtnLeftSecond--;
        if (self.videoBtnLeftSecond == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
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
//    self.startOneBtn.userInteractionEnabled = NO;
//    [self.cameraBtn setImage:[UIImage imageNamed:@"Live_willbe_end"] forState:UIControlStateNormal];
}

// 显示直播结束界面
- (void)showLiveFinshViewWithErrtype:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    if (self.liveRoom) {
        if ([self.liveDelegate respondsToSelector:@selector(liveFinshViewIsShow:)]) {
            [self.liveDelegate liveFinshViewIsShow:self];
        }
        
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
        
        // 清空直播间信息
        self.liveRoom = nil;
    }
}

// 直播结束停止推拉流并显示结束页
- (void)stopLiveWithErrtype:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    // 如果正在私密邀请则取消
    if (self.invitionId.length) {
        [[LSAnchorRequestManager manager] anchorCancelInstantInvite:self.invitionId finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
            NSLog(@"LiveViewController::anchorCancelInstantInvite( [主播取消立即私密邀请:%@] )",(success == YES) ? @"成功" : @"失败");
        }];
    }
    
    // 停止流
    [self stopPlay];
    [self stopPublish];
    
    // 弹出直播间关闭界面
    [self showLiveFinshViewWithErrtype:errType errMsg:errMsg];
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

#pragma mark - 3秒dailog
- (void)showDialogTipView:(NSString *)tipText {
    [self.dialogProbationTip showDialogTip:self.liveRoom.superView tipText:tipText];
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
    self.testTimer3 = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(testMethod3) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.testTimer3 forMode:NSRunLoopCommonModes];
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
    [self sendMsg:msg];
}

- (void)testMethod3 {
    NSString* msg = [NSString stringWithFormat:@"msg%ld", (long)self.msgId++];
//    [self sendMsg:msg isLounder:NO];
    
    [self addChatMessageNickName:@"randy" userLevel:6 text:msg honorUrl:nil fromId:nil isHasTicket:YES];
}

- (void)testMethod4 {
    
    if (!self.isDriveShow) {
    }
}

@end
