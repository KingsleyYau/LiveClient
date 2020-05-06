//
//  HangOutLiverViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/4/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangOutLiverViewController.h"

#import "LiveModule.h"
#import "LiveUrlHandler.h"

#import "LiveGobalManager.h"
#import "LiveStreamPublisher.h"
#import "LiveStreamPlayer.h"
#import "LiveStreamSession.h"

#import "LSTimer.h"

#import "GiftComboView.h"
#import "BigGiftAnimationView.h"

#import "LSImManager.h"
#import "GiftComboManager.h"
#import "LSImageViewLoader.h"
#import "LSRoomUserInfoManager.h"
#import "SendGiftTheQueueManager.h"
#import "LSLoginManager.h"
#import "LSGiftManager.h"

#import "LSSendinvitationHangoutRequest.h"
#import "LSCancelInviteHangoutRequest.h"

#pragma mark - 流[播放/推送]逻辑
#define STREAM_PLAYER_RECONNECT_MAX_TIMES 5
#define STREAM_PUBLISH_RECONNECT_MAX_TIMES STREAM_PLAYER_RECONNECT_MAX_TIMES
#define ISIphoneFive [UIScreen mainScreen].bounds.size.height < 600 ? YES : NO
#define TIPMESSAGEVIEWTOP 16
#define TIPMESSAGEVIEWBOTTOM 15

@interface HangOutLiverViewController () <GiftComboViewDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate,
                                          LiveStreamPublisherDelegate, LiveStreamPlayerDelegate>

#pragma mark - 推播流组件
// 流播放地址
@property (strong) NSString *playUrl;
// 流播放组件
@property (strong) LiveStreamPlayer *player;
// 流播放重连次数
@property (assign) NSUInteger playerReconnectTime;

// 请求管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

#pragma mark - 送礼管理器
@property (nonatomic, strong) SendGiftTheQueueManager *sendGiftManager;

#pragma mark - 礼物下载器
@property (nonatomic, strong) LSGiftManager *giftDownloadManager;

#pragma mark - 大礼物展现界面 播放队列
@property (nonatomic, strong) BigGiftAnimationView *giftAnimationView;
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

#pragma mark - 连击礼物管理队列
@property (nonatomic, strong) NSMutableArray<GiftComboView *> *giftComboViews;
@property (nonatomic, strong) NSMutableArray<MASConstraint *> *giftComboViewsLeadings;

#pragma mark - 连击礼物播放管理器
@property (nonatomic, strong) GiftComboManager *giftComboManager;

#pragma mark - 主播正在进入计时器
@property (strong) LSTimer *enterTimer;
@property (nonatomic, assign) NSInteger timeOut;

// 个人信息管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

/** 首次连击 **/
@property (nonatomic, assign) int clickId;

/** 当前送礼数、送礼总数、开始数、结束数 */
@property (nonatomic, assign) int giftNum;
@property (nonatomic, assign) int totalGiftNum;
@property (nonatomic, assign) int starNum;
@property (nonatomic, assign) int endNum;

// 长按放大控件手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressTap;

@property (nonatomic, assign) LIVETYPE liveType;

// 大礼物控件底部约束
@property (strong) MASConstraint *bigAnimationViewBottom;

@property (nonatomic, copy) NSString *inviteId;
@property (nonatomic, copy) NSString *recommendId;

// 是否开始倒计时
@property (nonatomic, assign) BOOL timeStart;

@end

@implementation HangOutLiverViewController

- (void)dealloc {
    NSLog(@"HangOutLiverViewController::dealloc()");

    // 发送礼物管理器移除代理
    [self.sendGiftManager unInit];

    [[LSImManager manager] removeDelegate:self];
    [[LSImManager manager].client removeDelegate:self];

    // 去除大礼物结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftAnimationIsOver" object:nil];

    [self.giftComboManager removeManager];

    for (GiftComboView *giftView in self.giftComboViews) {
        [giftView stopGiftCombo];
    }

    [self stopPlay];
    self.player = nil;
}

- (void)initCustomParam {
    [super initCustomParam];

    self.isShowNavBar = NO;
    
    // 初始化流组件
    self.playUrl = @"rtmp://172.25.32.133:7474/test_flash/max_mv";
    self.player = [LiveStreamPlayer instance];
    self.player.delegate = self;
    self.playerReconnectTime = 0;

    [[LSImManager manager] addDelegate:self];
    [[LSImManager manager].client addDelegate:self];

    // 注册大礼物结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationWhatIs:) name:@"GiftAnimationIsOver" object:nil];

    // 初始化请求管理器
    self.sessionManager = [LSSessionRequestManager manager];

    // 初始化送礼管理器
    self.sendGiftManager = [SendGiftTheQueueManager manager];

    // 初始化礼物下载器
    self.giftDownloadManager = [LSGiftManager manager];

    // 初始化主播进入计时器
    self.timeOut = 0;
    self.enterTimer = [[LSTimer alloc] init];

    // 初始化连击礼物队列
    self.giftComboViews = [[NSMutableArray alloc] init];
    self.giftComboViewsLeadings = [[NSMutableArray alloc] init];

    // 初始化连击礼物管理器
    self.giftComboManager = [[GiftComboManager alloc] init];

    // 初始化吧台礼物数量记录队列
    self.barGiftNumArray = [[NSMutableArray alloc] init];

    // 初始化个人信息管理器
    self.roomUserInfoManager = [LSRoomUserInfoManager manager];

    // 重置连击数量
    _starNum = 1;
    _endNum = 1;
    _giftNum = 1;
    _totalGiftNum = 1;

    // 重置连击ID
    self.clickId = 0;

    // 初始化是否方法界面标识位
    self.isBoostView = NO;

    // 初始化直播间在线状态
    self.liveType = LIVETYPE_OUTLIEROOM;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化视频界面
//    self.player.playView = self.videoView;
//    self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.player addPlayView:self.videoView];
    
    // 取消按钮切圆角
    self.cancelButton.layer.cornerRadius = self.cancelButton.frame.size.height / 2;

    // 重置界面
    [self resetView:NO];

    // 初始化连击礼物
    [self setupGiftView];

    if (ISIphoneFive) {
        self.headImageViewWidth.constant = DESGIN_TRANSFORM_3X(self.headImageViewWidth.constant);
    }
    // 头像切圆角
    self.headImageView.layer.cornerRadius = self.headImageViewWidth.constant / 2;
    self.headImageView.layer.masksToBounds = YES;
}

- (LIVETYPE)getTheLiveType {
    return self.liveType;
}

- (void)resetView:(BOOL)isClean {
    self.liveType = LIVETYPE_OUTLIEROOM;

    [self.bigGiftArray removeAllObjects];
    [self.view sendSubviewToBack:self.giftAnimationView];

    // 重置控件初始状态
    [self stopPlay];

    if (isClean) {
        self.liveRoom = nil;
        self.inviteId = nil;
        self.sendGiftManager.toUid = nil;
    }

    // 重置连击数量
    _starNum = 1;
    _endNum = 1;
    _giftNum = 1;
    _totalGiftNum = 1;

    // 重置连击ID
    self.clickId = 0;

    self.videoLoadingView.hidden = YES;
    self.nameShadowView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.headImageView.hidden = YES;
    self.cancelButton.hidden = YES;
    self.giftCountView.hidden = YES;

    self.inviteButton.hidden = NO;
    self.maskView.hidden = NO;
    self.tipMessageView.hidden = NO;

    if (ISIphoneFive) {
        self.tipMessageViewTop.constant = -24;
    } else {
        self.tipMessageViewTop.constant = -34;
    }
    self.tipIconViewWidth.constant = 0;

    self.tipMessageLabel.text = NSLocalizedStringFromSelf(@"zBx-hC-ddw.text");

    // 重置界面时 如果放大则缩小
    if (self.isBoostView) {
        self.isBoostView = !self.isBoostView;

        if ([self.inviteDelegate respondsToSelector:@selector(liverLongPressTap:isBoost:)]) {
            [self.inviteDelegate liverLongPressTap:self isBoost:self.isBoostView];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self addLongPressTap];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self removeLongPressTap];
}

#pragma mark - 流[播放/推送]逻辑
- (void)play {
    self.playUrl = self.liveRoom.playUrl;
    NSLog(@"HangOutLiverViewController::play( [开始播放流], playUrl : %@ )", self.playUrl);
    //    [self debugInfo];

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
    NSLog(@"HangOutLiverViewController::stopPlay()");
    [self.player stop];
}

- (void)setThePlayMute:(BOOL)isMute {
    self.player.mute = isMute;
}

#pragma mark - 流[播放]通知
- (NSString *_Nullable)playerShouldChangeUrl:(LiveStreamPlayer *_Nonnull)player {
    NSString *url = player.url;

    @synchronized(self) {
        if (self.playerReconnectTime++ > STREAM_PLAYER_RECONNECT_MAX_TIMES) {
            // 断线超过指定次数, 切换URL
            url = [self.liveRoom changePlayUrl];
            self.playerReconnectTime = 0;

            NSLog(@"HangOutLiverViewController::playerShouldChangeUrl( [切换播放流URL], url : %@)", url);
        }
    }
    return url;
}

- (void)playerOnConnect:(LiveStreamPlayer *)player {

    //    NSLog(@"HangOutLiverViewController::playerOnConnect( [播流连接] )");
}

- (void)playerOnDisconnect:(LiveStreamPlayer *)player {
    //    NSLog(@"HangOutLiverViewController::playerOnDisconnect( [播流断开] )");
}

#pragma mark - 初始化连击控件
- (void)setupGiftView {
    [self.comboGiftView removeAllSubviews];

    self.giftComboViews = [NSMutableArray array];
    self.giftComboViewsLeadings = [NSMutableArray array];

    GiftComboView *preGiftComboView = nil;

    for (int i = 0; i < 1; i++) {
        GiftComboView *giftComboView = [GiftComboView giftComboView:self];
        [self.comboGiftView addSubview:giftComboView];
        [self.giftComboViews addObject:giftComboView];

        giftComboView.tag = i;
        giftComboView.delegate = self;
        giftComboView.hidden = YES;

//        UIImage *image = [UIImage imageNamed:@"Live_Public_Bg_Combo"];
        giftComboView.numberView.numImageName = @"white_";

        NSNumber *height = [NSNumber numberWithInteger:giftComboView.frame.size.height];
        CGFloat width = [UIScreen mainScreen].bounds.size.width / 2 - 5;

        if (!preGiftComboView) {
            [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.comboGiftView);
                make.width.equalTo(@(width));
                make.height.equalTo(height);
                MASConstraint *leading = make.left.equalTo(self.comboGiftView.mas_left).offset(-width);
                [self.giftComboViewsLeadings addObject:leading];
            }];

        } else {
            [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(preGiftComboView.mas_top).offset(-5);
                make.width.equalTo(@(width));
                make.height.equalTo(height);
                MASConstraint *leading = make.left.equalTo(self.comboGiftView.mas_left).offset(-width);
                [self.giftComboViewsLeadings addObject:leading];
            }];
        }
        preGiftComboView = giftComboView;
    }
}

#pragma mark - 连击礼物管理
- (BOOL)showCombo:(GiftItem *)giftItem giftComboView:(GiftComboView *)giftComboView withUserID:(NSString *)userId {
    BOOL bFlag = YES;

    giftComboView.hidden = NO;

    // 数量
    giftComboView.beginNum = giftItem.multi_click_start;
    giftComboView.endNum = giftItem.multi_click_end;

    NSLog(@"HangOutLiverViewController::showCombo( [显示连击礼物], beginNum : %ld, endNum: %ld, clickID : %ld )", (long)giftComboView.beginNum, (long)giftComboView.endNum, (long)giftItem.multi_click_id);

    // 连击礼物
    LSGiftManagerItem *item = [self.giftDownloadManager getGiftItemWithId:giftItem.giftid];
    NSString *imgUrl = item.infoItem.bigImgUrl;
    [[LSImageViewLoader loader] loadImageWithImageView:giftComboView.giftImageView
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
        MASConstraint *newGiftComboViewLeading = make.left.equalTo(self.comboGiftView.mas_left).offset(5);
        [self.giftComboViewsLeadings replaceObjectAtIndex:index withObject:newGiftComboViewLeading];
    }];

    [giftComboView reset];
    [giftComboView start];

    NSTimeInterval duration = 0.3;
    [UIView animateWithDuration:duration
        animations:^{
            [self.comboGiftView layoutIfNeeded];
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
        }

    } else {
        // 没有空闲的界面, 放到缓存
        [self.giftComboManager pushGift:giftItem];
    }
}

#pragma mark - 连击结束回调 (GiftComboViewDelegate)
- (void)playComboFinish:(GiftComboView *)giftComboView {
    // 收回界面
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 2 - 5;
    NSInteger index = giftComboView.tag;
    MASConstraint *giftComboViewsLeading = [self.giftComboViewsLeadings objectAtIndex:index];
    [giftComboViewsLeading uninstall];
    [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
        MASConstraint *newGiftComboViewLeading = make.left.equalTo(self.comboGiftView.mas_left).offset(-width);
        [self.giftComboViewsLeadings replaceObjectAtIndex:index withObject:newGiftComboViewLeading];
    }];
    giftComboView.hidden = YES;
    [self.comboGiftView layoutIfNeeded];

    // 显示下一个
    GiftItem *giftItem = [self.giftComboManager popGift:nil];
    if (giftItem) {
        // 开始播放新的礼物连击
        [self showCombo:giftItem giftComboView:giftComboView withUserID:giftItem.fromid];
    }
}

#pragma mark - 初始化大礼物播放控件 大礼物播放逻辑
- (void)starBigAnimationWithGiftID:(NSString *)giftID {
    self.giftAnimationView = [BigGiftAnimationView sharedObject];
    self.giftAnimationView.userInteractionEnabled = NO;

    // webp路径
    LSGiftManagerItem *item = [self.giftDownloadManager getGiftItemWithId:giftID];
    LSYYImage *image = nil;

    if (item.infoItem.type == GIFTTYPE_BAR) {
        image = (LSYYImage *)[item barGiftImage];
    } else {
        image = [item bigGiftImage];
    }

    // 判断本地文件是否损伤 有则播放 无则删除重下播放下一个
    if (image) {
        if (item.infoItem.type != GIFTTYPE_BAR) {
            self.giftAnimationView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            self.giftAnimationView.contentMode = UIViewContentModeScaleToFill;
        }
        self.giftAnimationView.image = image;
        [self.view addSubview:self.giftAnimationView];
        [self.view bringSubviewToFront:self.giftAnimationView];
        [self.giftAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (item.infoItem.type != GIFTTYPE_BAR) {
                make.left.top.equalTo(self.view);
                make.width.height.equalTo(self.view);
            } else {
                make.height.width.equalTo(@(self.view.frame.size.width / 2));
                self.bigAnimationViewBottom = make.centerY.equalTo(self.view);
                make.centerX.equalTo(self.view);
            }

        }];
        [self bringLiveRoomSubView];

        //  吧台礼物延迟移除
        if (item.infoItem.type == GIFTTYPE_BAR) {
            double sec = item.infoItem.playTime * 0.001;
            [self performSelector:@selector(barGiftHiddenAnimation) withObject:nil afterDelay:sec];
        }

    } else {
        // 重新下载
        [item download];
        // 结束动画
        [self bigGiftAnimationEnd];
    }
}

// 遍历最外层控制器视图 将dialog放到最上层
- (void)bringLiveRoomSubView {
    for (UIView *view in self.view.subviews) {
        if (IsDialog(view)) {
            [self.liveRoom.superView bringSubviewToFront:view];
        }
    }
}

// 发送大礼物播放结束通知
- (void)bigGiftAnimationEnd {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GiftAnimationIsOver" object:self userInfo:nil];
}

// 吧台礼物移除界面动画
- (void)barGiftHiddenAnimation {
    [self.bigAnimationViewBottom uninstall];
    [self.giftAnimationView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@(30));
        make.bottom.equalTo(self.giftCountView.mas_top);
    }];
    [UIView animateWithDuration:0.2
        animations:^{
            [self.view layoutIfNeeded];
        }
        completion:^(BOOL finished) {
            [self bigGiftAnimationEnd];
        }];
}

#pragma mark - 大礼物播放结束 Notification
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

#pragma mark - 邀请过渡界面提示显示
// 邀请成功 等待主播回复
- (void)showInvitingAnchorTip {
    self.liveType = LIVETYPE_INVITING;

    if (ISIphoneFive) {
        self.tipMessageViewTop.constant = 9;
        self.tipMessageViewBottom.constant = 8;
    }

    self.tipMessageLabel.numberOfLines = 1;
    self.tipMessageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.headImageView.hidden = NO;
    self.tipMessageView.hidden = NO;
    self.cancelButton.hidden = NO;
    self.maskView.hidden = NO;

    self.videoLoadingView.hidden = YES;
    self.nameShadowView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.inviteButton.hidden = YES;

    [self playTipIconAnimation];
    self.tipMessageLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITING_ANCHOR"), self.liveRoom.userName];

    if (!self.liveRoom.photoUrl.length) {
        [self.roomUserInfoManager getLiverInfo:self.anchorItem.anchorId
                            finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                self.liveRoom.photoUrl = item.photoUrl;
                                [[LSImageViewLoader loader] loadImageFromCache:self.headImageView
                                                                       options:SDWebImageRefreshCached
                                                                      imageUrl:self.liveRoom.photoUrl
                                                              placeholderImage:LADYDEFAULTIMG
                                                                 finishHandler:^(UIImage *image){

                                                                 }];
                            }];
    } else {
        [[LSImageViewLoader loader] loadImageFromCache:self.headImageView
                                               options:SDWebImageRefreshCached
                                              imageUrl:self.liveRoom.photoUrl
                                      placeholderImage:LADYDEFAULTIMG
                                         finishHandler:^(UIImage *image){

                                         }];
    }
}

// 开门请求成功 等待服务器返回
- (void)showAnchorComingTip {
    self.liveType = LIVETYPE_OPENINGDOOR;

    if (ISIphoneFive) {
        self.tipMessageViewTop.constant = 9;
        self.tipMessageViewBottom.constant = 8;
    }

    self.tipMessageLabel.numberOfLines = 1;
    self.tipMessageLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.tipMessageView.hidden = NO;
    self.headImageView.hidden = NO;
    self.maskView.hidden = NO;

    self.cancelButton.hidden = YES;
    self.videoLoadingView.hidden = YES;
    self.nameShadowView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.inviteButton.hidden = YES;

    [self playTipIconAnimation];
    self.tipMessageLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ANCHOR_IS_COMING"), self.liveRoom.userName];

    if (!self.liveRoom.photoUrl.length) {
        [self.roomUserInfoManager getLiverInfo:self.anchorItem.anchorId
                            finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                self.liveRoom.photoUrl = item.photoUrl;
                                [[LSImageViewLoader loader] loadImageFromCache:self.headImageView
                                                                       options:SDWebImageRefreshCached
                                                                      imageUrl:self.liveRoom.photoUrl
                                                              placeholderImage:LADYDEFAULTIMG
                                                                 finishHandler:^(UIImage *image){

                                                                 }];
                            }];
    } else {
        [[LSImageViewLoader loader] loadImageFromCache:self.headImageView
                                               options:SDWebImageRefreshCached
                                              imageUrl:self.liveRoom.photoUrl
                                      placeholderImage:LADYDEFAULTIMG
                                         finishHandler:^(UIImage *image){

                                         }];
    }
}

// 主播正在从其他直播间进入
- (void)showAnchorEnterCountdown:(NSInteger)sec {
    self.liveType = LIVETYPE_COUNTDOWN;

    self.tipMessageLabel.numberOfLines = 2;
    self.tipMessageLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

    self.tipMessageView.hidden = NO;
    self.headImageView.hidden = NO;
    self.maskView.hidden = NO;

    self.cancelButton.hidden = YES;
    self.videoLoadingView.hidden = YES;
    self.nameShadowView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.inviteButton.hidden = YES;
    self.tipIconViewWidth.constant = 0;
    [self.tipIconView stopAnimating];

    if (!self.liveRoom.photoUrl.length) {
        [self.roomUserInfoManager getLiverInfo:self.anchorItem.anchorId
                            finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                self.liveRoom.photoUrl = item.photoUrl;
                                [[LSImageViewLoader loader] loadImageFromCache:self.headImageView
                                                                       options:SDWebImageRefreshCached
                                                                      imageUrl:self.liveRoom.photoUrl
                                                              placeholderImage:LADYDEFAULTIMG
                                                                 finishHandler:^(UIImage *image){
                                                                 }];
                            }];
    } else {
        [[LSImageViewLoader loader] loadImageFromCache:self.headImageView
                                               options:SDWebImageRefreshCached
                                              imageUrl:self.liveRoom.photoUrl
                                      placeholderImage:LADYDEFAULTIMG
                                         finishHandler:^(UIImage *image){
                                         }];
    }

    self.timeStart = YES;
    self.timeOut = sec;
    WeakObject(self, weakSelf);
    [self.enterTimer startTimer:dispatch_get_main_queue()
                   timeInterval:1.0 * NSEC_PER_SEC
                        starNow:YES
                         action:^{
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [weakSelf willEnterCountdownTip];
                             });
                         }];
}

// 主播正在加载视频
- (void)showAnchorLoading {
    self.liveType = LIVETYPE_ONLIVRROOM;

    self.tipMessageLabel.numberOfLines = 1;
    self.sendGiftManager.toUid = self.liveRoom.userId;

    self.nameShadowView.hidden = NO;
    self.nameLabel.hidden = NO;
    self.giftCountView.hidden = NO;
    self.nameLabel.text = self.liveRoom.userName;

    self.videoLoadingView.hidden = YES;
    self.tipMessageView.hidden = YES;
    self.headImageView.hidden = YES;
    self.cancelButton.hidden = YES;
    self.inviteButton.hidden = YES;
    self.maskView.hidden = YES;
}

// 进入直播间状态界面
- (void)showEnterRoomType {
    self.inviteId = self.anchorItem.inviteId;
    self.liveRoom.userId = self.anchorItem.anchorId;
    self.liveRoom.userName = self.anchorItem.nickName;
    self.liveRoom.photoUrl = self.anchorItem.photoUrl;
    self.liveRoom.playUrlArray = self.anchorItem.videoUrl;

    switch (self.anchorItem.anchorStatus) {
        case LIVEANCHORSTATUS_INVITECONFIRM:
        case LIVEANCHORSTATUS_INVITATION: {
            self.liveType = LIVETYPE_INVITING;
            // 邀请中 、邀请已确认
            [self showInvitingAnchorTip];
        } break;

        case LIVEANCHORSTATUS_KNOCKCONFIRM: {
            self.liveType = LIVETYPE_OPENINGDOOR;
            // 敲门已确认
            [self showAnchorComingTip];
        } break;

        case LIVEANCHORSTATUS_RECIPROCALENTER: {
            // 倒数进入中
            [self showAnchorEnterCountdown:self.anchorItem.leftSeconds];
        } break;

        case LIVEANCHORSTATUS_ONLINE: {
            // 在线
            [self showAnchorLoading];
            // 播流
            [self play];
        } break;

        case LIVEANCHORSTATUS_UNKNOW: {
            // 在线
            [self showAnchorLoading];
        } break;

        default: {
        } break;
    }
}

- (void)showGiftCount:(NSMutableArray *)bugforList {
    self.barGiftNumArray = bugforList;
    self.giftCountView.giftCountArray = self.barGiftNumArray;

    CGFloat length = [UIScreen mainScreen].bounds.size.width / 2;
    CGFloat giftCountViewWidth = self.barGiftNumArray.count * 38;
    if (giftCountViewWidth > length) {
        self.giftCountViewWidth.constant = length;
    } else {
        self.giftCountViewWidth.constant = giftCountViewWidth;
    }
}

- (void)reloadGiftCountView {
    [self.giftCountView reloadGiftCount];
}

// 播放邀请动画
- (void)playTipIconAnimation {
    self.tipMessageViewTop.constant = TIPMESSAGEVIEWTOP;
    self.tipIconViewWidth.constant = 14;
    NSMutableArray *iconArray = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 3; i++) {
        NSString *imageName = [NSString stringWithFormat:@"Live_Liver_Invite_To_%d", i];
        UIImage *image = [UIImage imageNamed:imageName];
        [iconArray addObject:image];
    }
    self.tipIconView.animationImages = iconArray;
    self.tipIconView.animationRepeatCount = 0;
    self.tipIconView.animationDuration = 0.6;
    [self.tipIconView startAnimating];
}

// 进入直播间倒计时
- (void)willEnterCountdownTip {
    self.tipMessageLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ANCHOR_WILL_ENTER"), self.liveRoom.userName, self.timeOut];
    self.timeOut -= 1;
    if (self.timeOut < 0) {
        // 关闭定时器 重新计数
        [self.enterTimer stopTimer];
        self.timeOut = 0;
        // 显示正在加载视频
        [self showAnchorLoading];
        // 播流
        [self play];
    }
    if (self.timeStart) {
        self.timeStart = NO;
        self.tipMessageViewTop.constant = TIPMESSAGEVIEWTOP;
        CGFloat labelHeight = [self.tipMessageLabel sizeThatFits:CGSizeMake(self.tipMessageLabel.tx_width, MAXFLOAT)].height;
        if (labelHeight > 20) {
            if (ISIphoneFive) {
                self.tipMessageViewBottom.constant = -10;
            } else {
                self.tipMessageViewBottom.constant = 0;
            }
        }
    }
}

#pragma mark - 播放礼物
- (void)onSendGiftNoticePlay:(IMRecvHangoutGiftItemObject *)model {

    // 初始化连击起始数
    int starNum = model.multiClickStart - 1;

    // 接收礼物消息item
    GiftItem *item = [GiftItem itemRoomId:model.roomId
                                   fromID:model.fromId
                                 nickName:model.nickName
                                 photoUrl:@""
                                   giftID:model.giftId
                                 giftName:model.giftName
                                  giftNum:model.giftNum
                              multi_click:model.isMultiClick
                                  starNum:starNum
                                   endNum:model.multiClickEnd
                                  clickID:model.multiClickId];

    GiftType giftType = item.giftItem.infoItem.type;

    switch (giftType) {
        case GIFTTYPE_CELEBRATE: {
            // 庆祝礼物
        } break;

        case GIFTTYPE_COMMON: {
            // 连击礼物
            [self addCombo:item];
        } break;

        default: {
            // 吧台礼物列表展示
            [self disPlayBarGiftList:giftType giftItem:item];

            LSGiftManagerItem *giftItem = [[LSGiftManager manager] getGiftItemWithId:item.giftid];
            if (giftItem.infoItem) { // 是否有详情播放
                // 礼物添加到队列
                if (!self.bigGiftArray && self.viewIsAppear) {
                    self.bigGiftArray = [NSMutableArray array];
                }
                for (int i = 0; i < model.giftNum; i++) {
                    [self.bigGiftArray addObject:model.giftId];
                }

                // 防止动画播完view没移除
                if (!self.giftAnimationView.isAnimating && giftType != GIFTTYPE_BAR) {
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
        } break;
    }
}

- (void)disPlayBarGiftList:(GiftType)type giftItem:(GiftItem *)item {
    if (type == GIFTTYPE_BAR) {
        // 吧台礼物列表对象
        IMGiftNumItemObject *obj = [[IMGiftNumItemObject alloc] init];
        obj.giftId = item.giftid;
        obj.giftNum = item.giftnum;

        if (self.barGiftNumArray.count > 0) {
            // 吧台数量礼物列表如果有值 则遍历是否有相同元素 有则本地加减 无则添加
            NSMutableArray *bars = [[NSMutableArray alloc] init];
            BOOL bHave = NO;
            for (IMGiftNumItemObject *numItem in self.barGiftNumArray) {
                if ([numItem.giftId isEqualToString:obj.giftId]) {
                    numItem.giftNum = numItem.giftNum + obj.giftNum;
                    bHave = YES;
                }
                [bars addObject:numItem];
            }

            if (bHave) {
                self.barGiftNumArray = bars;
            } else {
                [self.barGiftNumArray addObject:obj];
            }

        } else {
            // 吧台数量礼物列表如果为空则直接添加
            [self.barGiftNumArray addObject:obj];
        }

        // 刷新显示统计控件
        [self showGiftCount:self.barGiftNumArray];
    }
}

#pragma mark - 界面事件

- (IBAction)inviteAction:(id)sender {
    if ([self.inviteDelegate respondsToSelector:@selector(inviteAnchorJoinHangOut:)]) {
        [self.inviteDelegate inviteAnchorJoinHangOut:self];
    }
}

- (IBAction)cancelInviteAction:(id)sender {
    if (self.liveType != LIVETYPE_CANCELLING) {
        [self sendCancelInviteHangOut];
    }
}

#pragma mark - 手势事件 (长按屏幕)
- (void)addLongPressTap {
    if (self.longPressTap == nil) {
        self.longPressTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [self.view addGestureRecognizer:self.longPressTap];
    }
}

- (void)removeLongPressTap {
    if (self.longPressTap) {
        [self.view removeGestureRecognizer:self.longPressTap];
        self.longPressTap = nil;
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //添加该判断可以防止长按后触发多次事件
        if (self.liveRoom) {
            self.view.userInteractionEnabled = NO;
            self.isBoostView = !self.isBoostView;

            if ([self.inviteDelegate respondsToSelector:@selector(liverLongPressTap:isBoost:)]) {
                [self.inviteDelegate liverLongPressTap:self isBoost:self.isBoostView];
            }
        }
    }
}

#pragma mark - HTTP请求
- (void)sendHangoutInvite:(LSHangoutAnchorItemObject *)anchorItem {
    if (self.liveType == LIVETYPE_OUTLIEROOM) {
        if (!self.liveRoom.photoUrl.length) {
            [self.roomUserInfoManager getLiverInfo:anchorItem.anchorId
                                finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                    self.liveRoom.photoUrl = item.photoUrl;
                                    [[LSImageViewLoader loader] loadImageFromCache:self.headImageView
                                                                           options:SDWebImageRefreshCached
                                                                          imageUrl:self.liveRoom.photoUrl
                                                                  placeholderImage:LADYDEFAULTIMG
                                                                     finishHandler:^(UIImage *image){
                                                                     }];
                                }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 显示邀请中状态
            [self showInvitingAnchorTip];
        });
        LSSendinvitationHangoutRequest *request = [[LSSendinvitationHangoutRequest alloc] init];
        request.roomId = self.liveRoom.roomId;
        request.anchorId = anchorItem.anchorId;
        request.recommendId = self.recommendId;
        request.isCreateOnly = NO;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSString *_Nonnull roomId, NSString *_Nonnull inviteId, int expire) {
            NSLog(@"HangOutLiverViewController::sendHangoutInvite( [发起多人互动邀请 %@] errnum : %d, errmsg : %@,"
                   "roomId : %@, inviteId : %@, erpire : %d )",
                  success == YES ? @"成功" : @"失败", errnum, errmsg, roomId, inviteId, expire);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 代理通知hangout邀请回调
                if ([self.inviteDelegate respondsToSelector:@selector(invitationHangoutRequest:errMsg:anchorId:liverVC:)]) {
                    [self.inviteDelegate invitationHangoutRequest:errnum errMsg:errmsg anchorId:anchorItem.anchorId liverVC:self];
                }
                if (success) {
                    self.inviteId = inviteId;
                    
                    if (roomId.length > 0) {
                        // 主播加载视频中
                        [self showAnchorLoading];
                    }
                    
                } else {
                    // 重置状态 释放绑定的控制器
                    [self resetView:YES];
                }
            });
        };
        [self.sessionManager sendRequest:request];
    }
}

- (void)sendCancelInviteHangOut {
    if (self.inviteId.length > 0) {
        self.liveType = LIVETYPE_CANCELLING;

        LSCancelInviteHangoutRequest *request = [[LSCancelInviteHangoutRequest alloc] init];
        request.inviteId = self.inviteId;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
            NSLog(@"HangOutLiverViewController::LSCancelInviteHangoutRequest( [取消多人互动邀请 %@] errnum : %d,"
                   "errmsg : %@ )",
                  success == YES ? @"成功" : @"失败", errnum, errmsg);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 代理通知取消hangout回调
                if ([self.inviteDelegate respondsToSelector:@selector(cancelInviteHangoutRequest:errMsg:anchorId:liverVC:)]) {
                    [self.inviteDelegate cancelInviteHangoutRequest:success errMsg:errmsg anchorId:self.liveRoom.userId liverVC:self];
                }
                if (self.inviteId.length > 0) {
                    if (success) {
                        // 重置状态 释放绑定的控制器
                        [self resetView:YES];
                    } else {
                        self.liveType = LIVETYPE_INVITING;
                    }
                }
            });
        };
        [self.sessionManager sendRequest:request];
    }
}

#pragma mark - IM请求
// 发送连击礼物

- (void)sendHangoutComboGift:(LSGiftManagerItem *)item clickId:(int)clickId isPrivate:(NSInteger)isPrivate {
    if (self.clickId != clickId) {
        self.clickId = clickId;
        _starNum = 1;
        _endNum = 1;
        _giftNum = 1;
        _totalGiftNum = 1;
    } else {
        _starNum = _totalGiftNum + 1;
        _endNum = _totalGiftNum + 1;
        _giftNum = 1;
        _totalGiftNum = _totalGiftNum + 1;
    }
    GiftItem *sendItem = [GiftItem hangoutRoomId:self.liveRoom.roomId
                                        nickName:[LSLoginManager manager].loginItem.nickName
                                     is_Backpack:NO
                                       isPrivate:isPrivate
                                         giftNum:_giftNum
                                         starNum:_starNum
                                          endNum:_endNum
                                         clickID:self.clickId
                                        giftItem:item];

    // 发送礼物
    [self.sendGiftManager sendHangoutGiftrRequestWithGiftItem:sendItem];
}

// 发送其他礼物 (吧台 大礼物)

- (void)sendHangoutGift:(LSGiftManagerItem *)item clickId:(int)clickId isPrivate:(NSInteger)isPrivate {
    GiftItem *sendItem = [GiftItem hangoutRoomId:self.liveRoom.roomId
                                        nickName:[LSLoginManager manager].loginItem.nickName
                                     is_Backpack:NO
                                       isPrivate:isPrivate
                                         giftNum:1
                                         starNum:1
                                          endNum:1
                                         clickID:self.clickId
                                        giftItem:item];
    // 发送礼物
    [self.sendGiftManager sendHangoutGiftrRequestWithGiftItem:sendItem];
}

#pragma mark - IM回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"HangOutLiverViewController::onLogin( [IM登录成功] )");
    dispatch_async(dispatch_get_main_queue(), ^{

                   });
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"HangOutLiverViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@, playerReconnectTime : %lu )", errType, errmsg, (unsigned long)self.playerReconnectTime);
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
            // IM断开, 重置RTMP断开次数
            self.playerReconnectTime = 0;
        }
    });
}

- (void)onRecvDealInviteHangoutNotice:(IMRecvDealInviteItemObject *)item {
    BOOL isEqualUserId = [item.anchorId isEqualToString:self.liveRoom.userId];
    BOOL isEqualRoomId = [item.roomId isEqualToString:self.liveRoom.roomId];

    if (isEqualUserId && isEqualRoomId) {
        NSLog(@"HangOutLiverViewController::onRecvDealInviteHangoutNotice( [接收主播回复观众多人互动邀请通知] invteId : %@, roomId : %@,"
               "anchorId : %@, type : %d, anchorId : %@ )",
              item.inviteId, item.roomId, item.anchorId, item.type, item.anchorId);
        dispatch_async(dispatch_get_main_queue(), ^{

            if ([self.inviteId isEqualToString:item.inviteId]) {
                // 主播同意 切换状态
                if (item.type != IMREPLYINVITETYPE_AGREE && self.liveType != LIVETYPE_ONLIVRROOM) {
                    // 代理通知hangout邀请回复回调
                    if ([self.inviteDelegate respondsToSelector:@selector(inviteHangoutNotAgreeNotice:liverVC:)]) {
                        [self.inviteDelegate inviteHangoutNotAgreeNotice:item liverVC:self];
                    }
                    // 重置状态
                    [self resetView:YES];
                }
            }
        });
    }
}

- (void)onRecvAnchorCountDownEnterHangoutRoomNotice:(NSString *)roomId anchorId:(NSString *)anchorId leftSecond:(int)leftSecond {
    BOOL isEqualUserId = [anchorId isEqualToString:self.liveRoom.userId];
    BOOL isEqualRoomId = [roomId isEqualToString:self.liveRoom.roomId];

    if (isEqualUserId && isEqualRoomId) {
        NSLog(@"HangOutLiverViewController::onRecvAnchorCountDownEnterHangoutRoomNotice( [接收进入多人互动直播间倒数] roomId : %@, anchorId : %@ leftSecond : %d )", roomId, anchorId, leftSecond);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 是否显示倒数
            if (leftSecond > 0 && self.liveType != LIVETYPE_ONLIVRROOM) {
                [self showAnchorEnterCountdown:leftSecond];
            } else {
                //                [self showAnchorComingTip];
            }
        });
    }
}

- (void)onRecvEnterHangoutRoomNotice:(IMRecvEnterRoomItemObject *)item {
    BOOL isAnchor = item.isAnchor;
    BOOL isEqualUserId = [item.userId isEqualToString:self.liveRoom.userId];
    BOOL isEqualRoomId = [item.roomId isEqualToString:self.liveRoom.roomId];

    if (isAnchor && isEqualUserId && isEqualRoomId) {
        NSLog(@"HangOutLiverViewController::onRecvEnterHangoutRoomNotice( [接收观众/主播进入多人互动直播间] roomId : %@, userId : %@,"
               "nickName : %@, anchorId : %@ )",
              item.roomId, item.userId, item.nickName, item.userId);
        dispatch_async(dispatch_get_main_queue(), ^{

            self.liveRoom.roomId = item.roomId;
            self.liveRoom.userId = item.userId;
            self.liveRoom.userName = item.nickName;
            self.liveRoom.photoUrl = item.photoUrl;
            self.liveRoom.playUrlArray = item.pullUrl;
            self.liveRoom.roomType = LiveRoomType_Hang_Out;

            // 刷新吧台礼物统计视图
            [self.barGiftNumArray removeAllObjects];
            [self.barGiftNumArray addObjectsFromArray:item.bugForList];
            [self showGiftCount:self.barGiftNumArray];

            // 存储主播信息到本地
            LSUserInfoModel *model = [[LSUserInfoModel alloc] init];
            model.userId = item.userId;
            model.nickName = item.nickName;
            model.photoUrl = item.photoUrl;
            model.isAnchor = item.isAnchor;
            [self.roomUserInfoManager setLiverInfoDic:model];
            
            // 主播加载视频中
            [self showAnchorLoading];
            // 播流
            [self play];
        });
    }
}

- (void)onRecvLeaveHangoutRoomNotice:(IMRecvLeaveRoomItemObject *)item {
    BOOL isAnchor = item.isAnchor;
    BOOL isEqualUserId = [item.userId isEqualToString:self.liveRoom.userId];
    BOOL isEqualRoomId = [item.roomId isEqualToString:self.liveRoom.roomId];
    
    if (isAnchor && isEqualUserId && isEqualRoomId) {
        NSLog(@"HangOutLiverViewController::onRecvLeaveHangoutRoomNotice( [接收观众/主播退出多人互动直播间] roomId : %@, userId : %@,"
              "nickName : %@, errNo : %d, errMsg : %@, anchorId : %@ )", item.roomId, item.userId, item.nickName, item.errNo, item.errMsg, item.userId);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 代理通知离开hangout直播间回调
            if ([self.inviteDelegate respondsToSelector:@selector(leaveHangoutRoomNotice:)]) {
                [self.inviteDelegate leaveHangoutRoomNotice:self];
            }
            // 重置状态
            [self resetView:YES];
        });
    }
}

- (void)onRecvChangeVideoUrl:(NSString *)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString *> *)playUrl userId:(NSString *)userId {
    BOOL isEqualUserId = [userId isEqualToString:self.liveRoom.userId];
    BOOL isEqualRoomId = [roomId isEqualToString:self.liveRoom.roomId];
    
    if (isAnchor && isEqualUserId && isEqualRoomId) {
        NSLog(@"HangOutLiverViewController::onRecvChangeVideoUrl( [接收主播切换视频流通知], roomId : %@, playUrl : %@, userId : %@, anchorId : %@ )", roomId, playUrl, userId, self.liveRoom.userId);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新流地址
            [self.liveRoom reset];
            self.liveRoom.playUrlArray = [playUrl copy];
            
            [self stopPlay];
            [self play];
        });
    }
}

@end
