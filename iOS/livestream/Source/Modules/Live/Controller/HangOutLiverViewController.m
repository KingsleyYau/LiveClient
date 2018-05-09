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
#import "YMAudienceView.h"

#import "LSImManager.h"
#import "LiveGiftDownloadManager.h"
#import "GiftComboManager.h"
#import "LSImageViewLoader.h"

#import "LSSendinvitationHangoutRequest.h"
#import "LSCancelInviteHangoutRequest.h"

#pragma mark - 流[播放/推送]逻辑
#define STREAM_PLAYER_RECONNECT_MAX_TIMES 5
#define STREAM_PUBLISH_RECONNECT_MAX_TIMES STREAM_PLAYER_RECONNECT_MAX_TIMES

@interface HangOutLiverViewController ()<GiftComboViewDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate,
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

#pragma mark - 礼物下载器
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;

#pragma mark - 大礼物展现界面 播放队列
@property (nonatomic, strong) BigGiftAnimationView *giftAnimationView;
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

#pragma mark - 连击礼物管理队列
@property (nonatomic, strong) NSMutableArray<GiftComboView *> *giftComboViews;
@property (nonatomic, strong) NSMutableArray<MASConstraint *> *giftComboViewsLeadings;

#pragma mark - 连击礼物播放管理器
@property (nonatomic, strong) GiftComboManager *giftComboManager;

#pragma mark - 吧台礼物数量记录队列
@property (nonatomic, strong) NSMutableArray *barGiftNumArray;

#pragma mark - 主播正在进入计时器
@property (strong) LSTimer *enterTimer;
@property (nonatomic, assign) NSInteger timeOut;

#pragma mark - 加载视频计时器
@property (strong) LSTimer *loadingTimer;

@end

@implementation HangOutLiverViewController

- (void)dealloc {
    NSLog(@"HangOutLiverViewController::dealloc()");
    
    [[LSImManager manager] removeDelegate:self];
    [[LSImManager manager].client removeDelegate:self];
    
    // 去除大礼物结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftAnimationIsOver" object:nil];
    
    [self.giftComboManager removeManager];
    
    for (GiftComboView *giftView in self.giftComboViews) {
        [giftView stopGiftCombo];
    }
}

- (void)initCustomParam {
    [super initCustomParam];
    
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
    
    // 初始化礼物下载器
    self.giftDownloadManager = [LiveGiftDownloadManager manager];
    
    // 初始化主播进入计时器
    self.timeOut = 0;
    self.enterTimer = [[LSTimer alloc] init];
    
    // 初始化加载视频计时器
    self.loadingTimer = [[LSTimer alloc] init];
    
    // 初始化连击礼物队列
    self.giftComboViews = [[NSMutableArray alloc] init];
    self.giftComboViewsLeadings = [[NSMutableArray alloc] init];
    
    // 初始化连击礼物管理器
    self.giftComboManager = [[GiftComboManager alloc] init];
    
    // 初始化吧台礼物数量记录队列
    self.barGiftNumArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化视频界面
    self.player.playView = self.videoView;
    self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    // 重置界面
    [self resetView:NO];
    
    // 初始化连击礼物
    [self setupGiftView];
}

- (void)resetView:(BOOL)isClean {
    // 重置控件初始状态
    [self stopPlay];
    
    if (isClean) {
        self.liveRoom = nil;
        self.inviteId = nil;
    }
    
    self.videoLoadingView.hidden = YES;
    self.nameShadowView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.headImageView.hidden = YES;
    self.cancelButton.hidden = YES;
    
    self.inviteButton.hidden = NO;
    self.tipMessageView.hidden = NO;
    self.tipMessageViewTop.constant = -16;
    self.tipIconViewWidth.constant = 0;
    
    self.tipMessageLabel.text = NSLocalizedStringFromSelf(@"zBx-hC-ddw.text");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
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
    NSString *recordFilePath = [LiveModule module].debug?[NSString stringWithFormat:@"%@/%@_%@.flv", recordDir, self.liveRoom.userId, dateString]:@"";
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
                [weakSelf startPlay];
                [weakSelf.loadingTimer stopTimer];
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
    NSLog(@"HangOutLiverViewController::playerOnConnect( [播流连接] )");
}

- (void)playerOnDisconnect:(LiveStreamPlayer *)player {
    NSLog(@"HangOutLiverViewController::playerOnDisconnect( [播流断开] )");
}

#pragma mark - 初始化连击控件
- (void)setupGiftView {
    [self.comboGiftView removeAllSubviews];
    
    GiftComboView *preGiftComboView = nil;
    
    for (int i = 0; i < 1; i++) {
        GiftComboView *giftComboView = [GiftComboView giftComboView:self];
        [self.comboGiftView addSubview:giftComboView];
        [self.giftComboViews addObject:giftComboView];
        
        giftComboView.tag = i;
        giftComboView.delegate = self;
        giftComboView.hidden = YES;
        
        UIImage *image = [UIImage imageNamed:@"Live_Public_Bg_Combo"];
        [giftComboView.backImageView setImage:image];
        
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
    NSString *imgUrl = [self.giftDownloadManager backBigImgUrlWithGiftID:giftItem.giftid];
    [[LSImageViewLoader loader] loadImageWithImageView:giftComboView.giftImageView
                                         options:0
                                        imageUrl:imgUrl
                                placeholderImage:
     [UIImage imageNamed:@"Live_Gift_Nomal"]];
    
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
//            NSLog(@"HangOutLiverViewController::addCombo( [增加连击礼物, 播放], starNum : %ld, endNum : %ld, clickID : %ld )", (long)giftItem.multi_click_start, (long)giftItem.multi_click_end, (long)giftItem.multi_click_id);
        }
        
    } else {
        // 没有空闲的界面, 放到缓存
        [self.giftComboManager pushGift:giftItem];
//        NSLog(@"HangOutLiverViewController::addCombo( [增加连击礼物, 缓存], starNum : %ld, endNum : %ld, clickID : %ld )", (long)giftItem.multi_click_start, (long)giftItem.multi_click_end, (long)giftItem.multi_click_id);
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
    AllGiftItem *item = [self.giftDownloadManager backGiftItemWithGiftID:giftID];
    self.giftAnimationView = [BigGiftAnimationView sharedObject];
    self.giftAnimationView.userInteractionEnabled = NO;
    
    // webp路径
    NSString *filePath = [[LiveGiftDownloadManager manager] doCheckLocalGiftWithGiftID:giftID];
    NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:filePath];
    LSYYImage *image = [LSYYImage imageWithData:imageData];
    
    // 判断本地文件是否损伤 有则播放 无则删除重下播放下一个
    if (image) {
        //        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        self.giftAnimationView.contentMode = UIViewContentModeScaleAspectFit;
        self.giftAnimationView.image = image;
        [self.view addSubview:self.giftAnimationView];
        [self.view bringSubviewToFront:self.giftAnimationView];
        [self.giftAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.view);
            make.width.height.equalTo(self.view);
        }];
        [self bringLiveRoomSubView];
        
        // 吧台礼物延迟移除
        if (item.infoItem.type == GIFTTYPE_BAR) {
            long sec = item.infoItem.playTime / 1000;
            [self performSelector:@selector(bigGiftAnimationEnd) withObject:nil afterDelay:sec];
        }
        
    } else {
        [self.giftDownloadManager deletWebpPath:giftID];
        [self.giftDownloadManager downLoadGiftDetail:giftID];
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
    self.headImageView.hidden = NO;
    self.tipMessageView.hidden = NO;
    self.cancelButton.hidden = NO;
    
    self.videoLoadingView.hidden = YES;
    self.nameShadowView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.inviteButton.hidden = YES;
    
    if (!self.tipIconView.isAnimating) {
        [self playTipIconAnimation];
    }
    self.tipMessageLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"INVITING_ANCHOR"),self.liveRoom.userName];
}

// 开门请求成功 等待服务器返回
- (void)showAnchorComingTip {
    self.tipMessageView.hidden = NO;
    self.headImageView.hidden = NO;
    
    self.cancelButton.hidden = YES;
    self.videoLoadingView.hidden = YES;
    self.nameShadowView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.inviteButton.hidden = YES;
    
    if (!self.tipIconView.isAnimating) {
        [self playTipIconAnimation];
    }
    self.tipMessageLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ANCHOR_IS_COMING"),self.liveRoom.userName];
}

// 主播正在从其他直播间进入
- (void)showAnchorEnterCountdown:(NSInteger)sec {
    self.tipMessageView.hidden = NO;
    self.headImageView.hidden = NO;
    
    self.cancelButton.hidden = YES;
    self.videoLoadingView.hidden = YES;
    self.nameShadowView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.inviteButton.hidden = YES;
    self.tipIconViewWidth.constant = 0;
    [self.tipIconView stopAnimating];
    
    self.timeOut = sec;
    WeakObject(self, weakSelf);
    [self.enterTimer startTimer:nil timeInterval:1.0 * NSEC_PER_SEC starNow:YES action:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf willEnterCountdownTip];
        });
    }];
}

// 主播正在加载视频
- (void)showAnchorLoading {
    self.videoLoadingView.hidden = NO;
    self.nameShadowView.hidden = NO;
    self.nameLabel.hidden = NO;
    self.nameLabel.text = self.liveRoom.userName;
    
    self.tipMessageView.hidden = YES;
    self.headImageView.hidden = YES;
    self.cancelButton.hidden = YES;
    self.inviteButton.hidden = YES;
    
    // 播流
    [self play];
    
    // 加载视频计时器
    WeakObject(self, weakSelf);
    [self.loadingTimer startTimer:nil timeInterval:60.0 * NSEC_PER_SEC starNow:NO action:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // 重置状态
            [weakSelf resetView:YES];
            if ([weakSelf.inviteDelegate respondsToSelector:@selector(loadVideoOvertime:)]) {
                [weakSelf.inviteDelegate loadVideoOvertime:weakSelf];
            }
        });
    }];
}

// 播放视频 隐藏所有控件
- (void)startPlay {
    self.videoLoadingView.hidden = YES;
    self.nameShadowView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.tipMessageView.hidden = YES;
    self.headImageView.hidden = YES;
    self.cancelButton.hidden = YES;
    self.inviteButton.hidden = YES;
}

// 播放邀请动画
- (void)playTipIconAnimation {
    self.tipMessageViewTop.constant = 16;
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
    self.tipMessageLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ANCHOR_WILL_ENTER"),self.liveRoom.userName ,self.timeOut];
    self.timeOut -= 1;
    if (self.timeOut < 0) {
        // 关闭定时器 重新计数
        [self.enterTimer stopTimer];
        self.timeOut = 0;
    }
}

// 播放礼物逻辑
- (void)onSendGiftNoticePlay:(IMRecvHangoutGiftItemObject *)model {
    
    // 初始化连击起始数
    int starNum = model.multiClickStart - 1;
    
    // 接收礼物消息item
    GiftItem *item = [GiftItem itemRoomId:model.roomId fromID:model.fromId nickName:model.nickName
                                   giftID:model.giftId giftName:model.giftName giftNum:model.giftNum multi_click:model.isMultiClick
                          starNum:starNum endNum:model.multiClickEnd clickID:model.multiClickId];
    
    GiftType giftType = item.giftItem.infoItem.type;
    
    if (giftType == GIFTTYPE_COMMON) {
        // 连击礼物
        [self addCombo:item];
        
    } else {
        
        // 吧台礼物本地计数
        if (giftType == GIFTTYPE_BAR) {
            // 吧台礼物列表对象
            IMGiftNumItemObject *obj = [[IMGiftNumItemObject alloc] init];
            obj.giftId = item.giftid;
            obj.giftNum = item.giftnum;
            
            // 如果数组有元素遍历添加 无元素则直接添加
            if (self.barGiftNumArray.count) {
                NSMutableArray *bars = [[NSMutableArray alloc] init];
                BOOL bHave = NO;
                for (IMGiftNumItemObject *numItem in self.barGiftNumArray) {
                    if ([numItem.giftId isEqualToString:item.giftid]) {
                        numItem.giftNum = numItem.giftNum + item.giftnum;
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
                [self.barGiftNumArray addObject:obj];
            }
        }
        
        // 礼物添加到队列
        if (!self.bigGiftArray && self.viewIsAppear) {
            self.bigGiftArray = [NSMutableArray array];
        }
        for (int i = 0; i < model.giftNum; i++) {
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
}

#pragma mark - 界面事件

- (IBAction)inviteAction:(id)sender {
    if ([self.inviteDelegate respondsToSelector:@selector(inviteAnchorJoinHangOut:)]) {
        [self.inviteDelegate inviteAnchorJoinHangOut:self];
    }
}

- (IBAction)cancelInviteAction:(id)sender {
    [self sendCancelInviteHangOut];
}

#pragma mark - HTTP请求
- (void)sendHangoutInvite:(LSHangoutAnchorItemObject *)item {
    LSSendinvitationHangoutRequest *request = [[LSSendinvitationHangoutRequest alloc] init];
    request.anchorId = item.anchorId;
    request.recommendId = @"";
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, NSString * _Nonnull inviteId, int expire) {
        NSLog(@"HangOutLiverViewController::sendHangoutInvite( [发起多人互动邀请] success : %@, errnum : %d, errmsg : %@,"
              "roomId : %@, inviteId : %@, erpire : %d )",success == YES ? @"成功":@"失败", errnum, errmsg, roomId, inviteId, expire);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.inviteId = inviteId;
                self.liveRoom.userId = item.anchorId;
                self.liveRoom.userName = item.nickName;
                // 显示邀请中状态
                [self showInvitingAnchorTip];
                
            } else {
                // 重置状态 释放绑定的控制器
                [self resetView:YES];
            }
            // 代理通知hangout邀请回调
            if ([self.inviteDelegate respondsToSelector:@selector(invitationHangoutRequest:errMsg:liverVC:)]) {
                [self.inviteDelegate invitationHangoutRequest:success errMsg:errmsg liverVC:self];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)sendCancelInviteHangOut {
    LSCancelInviteHangoutRequest *request = [[LSCancelInviteHangoutRequest alloc] init];
    request.inviteId = self.inviteId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        NSLog(@"HangOutLiverViewController::LSCancelInviteHangoutRequest( [取消多人互动邀请] success ； %@, errnum : %d,"
              "errmsg : %@ )",success == YES ? @"成功":@"失败", errnum, errmsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                // 重置状态 释放绑定的控制器
                [self resetView:YES];
            }
            // 代理通知取消hangout回调
            if ([self.inviteDelegate respondsToSelector:@selector(cancelInviteHangoutRequest:errMsg:liverVC:)]) {
                [self.inviteDelegate cancelInviteHangoutRequest:success errMsg:errmsg liverVC:self];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - IM请求

#pragma mark - IM回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"HangOutLiverViewController::onLogin( [IM登录成功] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"HangOutLiverViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@, playerReconnectTime : %lu )"
          , errType, errmsg, (unsigned long)self.playerReconnectTime);
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
            // IM断开, 重置RTMP断开次数
            self.playerReconnectTime = 0;
        }
    });
}

- (void)onRecvDealInviteHangoutNotice:(IMRecvDealInviteItemObject *)item {
    NSLog(@"HangOutLiverViewController::onRecvDealInviteHangoutNotice( [接收主播回复观众多人互动邀请通知] invteId : %@, roomId : %@,"
          "anchorId : %@, type : %d )", item.inviteId, item.roomId, item.anchorId, item.type);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([item.anchorId isEqualToString:self.liveRoom.userId]) {
            // 主播同意 切换状态
            if (item.type == IMREPLYINVITETYPE_AGREE) {
                // 是否显示倒数
                if (item.expires > 0) {
                    [self showAnchorEnterCountdown:item.expires];
                } else {
                    [self showAnchorComingTip];
                }
            } else {
                // 重置状态
                [self resetView:YES];
                // 代理通知hangout邀请回复回调
                if ([self.inviteDelegate respondsToSelector:@selector(inviteHangoutNotAgreeNotice:)]) {
                    [self.inviteDelegate inviteHangoutNotAgreeNotice:self];
                }
            }
        }
    });
}

- (void)onRecvEnterHangoutRoomNotice:(IMRecvEnterRoomItemObject *)item {
    NSLog(@"HangOutLiverViewController::onRecvEnterHangoutRoomNotice( [接收观众/主播进入多人互动直播间] roomId : %@, userId : %@,"
          "nickName : %@ )",item.roomId, item.userId, item.nickName);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (item.isAnchor && [item.userId isEqualToString:self.liveRoom.userId]) {
            self.liveRoom.roomId = item.roomId;
            self.liveRoom.userId = item.userId;
            self.liveRoom.userName = item.nickName;
            self.liveRoom.photoUrl = item.photoUrl;
            self.liveRoom.playUrlArray = item.pullUrl;
            self.liveRoom.roomType = LiveRoomType_Hang_Out;
            [self.barGiftNumArray addObjectsFromArray:item.bugForList];
            // 主播加载视频中
            [self showAnchorLoading];
        }
    });
}

- (void)onRecvLeaveHangoutRoomNotice:(IMRecvLeaveRoomItemObject *)item {
    NSLog(@"HangOutLiverViewController::onRecvLeaveHangoutRoomNotice( [接收观众/主播退出多人互动直播间] roomId : %@, userId : %@,"
          "nickName : %@, errNo : %d, errMsg : %@ )", item.roomId, item.userId, item.nickName, item.errNo, item.errMsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (item.isAnchor && [item.userId isEqualToString:self.liveRoom.userId]) {
            // 重置状态
            [self resetView:YES];
            // 代理通知离开hangout直播间回调
            if ([self.inviteDelegate respondsToSelector:@selector(leaveHangoutRoomNotice:)]) {
                [self.inviteDelegate leaveHangoutRoomNotice:self];
            }
        }
    });
}



@end
