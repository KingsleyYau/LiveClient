//
//  HangOutUserViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/7.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangOutUserViewController.h"

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
#import "LSGiftManager.h"
#import "GiftComboManager.h"
#import "LSImageViewLoader.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"
#import "LSRoomUserInfoManager.h"

#pragma mark - 流[播放/推送]逻辑
#define STREAM_PLAYER_RECONNECT_MAX_TIMES 5
#define STREAM_PUBLISH_RECONNECT_MAX_TIMES STREAM_PLAYER_RECONNECT_MAX_TIMES

@interface HangOutUserViewController () <LiveStreamPublisherDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate,
                                         LoginManagerDelegate, GiftComboViewDelegate, UIGestureRecognizerDelegate>

// 流推送地址
@property (strong) NSString *publishUrl;
// 流推送组件
@property (strong) LiveStreamPublisher *publisher;
// 流推送重连次数
@property (assign) NSUInteger publisherReconnectTime;

// 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;

// IM管理器
@property (nonatomic, strong) LSImManager *imManager;

// 请求管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

// 图片下载器
@property (nonatomic, strong) LSImageViewLoader *imageLoader;

// 个人信息管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

// 开始视频互动
@property (nonatomic, assign) BOOL startPush;

// 单击收起输入控件手势
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

#pragma mark - 吧台礼物数量记录队列
@property (nonatomic, strong) NSMutableArray *barGiftNumArray;

#pragma mark - 大礼物展现界面 播放队列
@property (nonatomic, strong) BigGiftAnimationView *giftAnimationView;
@property (nonatomic, strong) NSMutableArray<NSString *> *bigGiftArray;

#pragma mark - 连击礼物管理队列
@property (nonatomic, strong) NSMutableArray<GiftComboView *> *giftComboViews;
@property (nonatomic, strong) NSMutableArray<MASConstraint *> *giftComboViewsLeadings;

#pragma mark - 礼物管理器
@property (nonatomic, strong) GiftComboManager *giftComboManager;

#pragma mark - 礼物下载器
@property (nonatomic, strong) LSGiftManager *giftDownloadManager;

// 长按放大控件手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressTap;

// 大礼物控件底部约束
@property (strong) MASConstraint *bigAnimationViewBottom;

@property (nonatomic, strong) LSTimer *showTimer;

// 是否第一次推流
@property (nonatomic, assign) BOOL isFirstPush;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activiView;

@end

@implementation HangOutUserViewController

- (void)dealloc {
    NSLog(@"HangOutUserViewController::dealloc()");

    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];

    // 去除大礼物结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GiftAnimationIsOver" object:nil];

    [self.giftComboManager removeManager];

    for (GiftComboView *giftView in self.giftComboViews) {
        [giftView stopGiftCombo];
    }

    [self stopPublish];
}

- (void)initCustomParam {
    [super initCustomParam];

    self.isShowNavBar = NO;
    
    self.publishUrl = @"rtmp://172.25.32.133:7474/test_flash/max_i";
    self.publisher = [LiveStreamPublisher instance:LiveStreamType_Audience_Mutiple];
    self.publisher.delegate = self;
    self.publisherReconnectTime = 0;

    // 注册大礼物结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationWhatIs:) name:@"GiftAnimationIsOver" object:nil];

    // 初始化吧台礼物统计数组
    self.barGiftNumArray = [[NSMutableArray alloc] init];

    // 初始请求管理器
    self.sessionManager = [LSSessionRequestManager manager];

    // 初始化IM管理器
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    // 初始登录
    self.loginManager = [LSLoginManager manager];

    // 连击礼物管理器
    self.giftComboManager = [[GiftComboManager alloc] init];

    // 初始化礼物管理器
    self.giftDownloadManager = [LSGiftManager manager];

    // 图片下载器
    self.imageLoader = [LSImageViewLoader loader];

    // 初始化个人信息管理器
    self.roomUserInfoManager = [LSRoomUserInfoManager manager];

    // 初始化是否方法界面标识位
    self.isBoostView = NO;

    // 初始化显示计时器
    self.showTimer = [[LSTimer alloc] init];

    // 是否第一次推流
    self.isFirstPush = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 默认隐藏loading
    [self activiViewIsShow:NO];

    // 加载推流器
    [self initPublish];

    // 加载观众头像
    [self.imageLoader loadImageWithImageView:self.headImageView
                                     options:SDWebImageRefreshCached
                                    imageUrl:self.loginManager.loginItem.photoUrl
                            placeholderImage:[UIImage imageNamed:@"Default_Img_Noman_HangOut"]
                               finishHandler:nil];

    // 初始化连击礼物
    [self setupGiftView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewIsAppear) {
        self.startPush = YES;
    }
    [super viewDidAppear:animated];

    // 添加单击事件
    [self addSingleTap];
    [self addLongPressTap];

    [self.view bringSubviewToFront:self.startCloseBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self removeLongPressTap];
    [self removeSingleTap];
}

- (void)initPublish {
    NSLog(@"LiveViewController::initPublish( [初始化推送流] )");

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

    // 初始化视频界面
    self.publisher.publishView = self.videoView;
    self.publisher.publishView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
}

- (void)publish {
    self.publishUrl = self.liveRoom.publishUrl;
    NSLog(@"HangOutUserViewController::publish( [开始推送流], publishUrl : %@ )", self.publishUrl);
    [self.publisher pushlishUrl:self.publishUrl recordH264FilePath:@"" recordAACFilePath:@""];
}

- (void)stopPublish {
    NSLog(@"HangOutUserViewController::stopPublish()");
    [self.publisher stop];
}

- (void)resetPublish {
    NSLog(@"HangOutUserViewController::resetPublish()");
    [self stopPublish];
    self.publisher = nil;
}

- (void)setThePublishMute:(BOOL)isMute {
    self.publisher.mute = isMute;
}

- (NSString *_Nullable)publisherShouldChangeUrl:(LiveStreamPublisher *_Nonnull)publisher {
    NSString *url = publisher.url;

    @synchronized(self) {
        if (self.publisherReconnectTime++ > STREAM_PUBLISH_RECONNECT_MAX_TIMES) {
            // 断线超过指定次数, 切换URL
            url = [self.liveRoom changePublishUrl];
            self.publisherReconnectTime = 0;

            NSLog(@"HangOutUserViewController::publisherShouldChangeUrl( [切换推送流URL], url : %@)", url);
        }
    }

    return url;
}

- (void)publisherOnConnect:(LiveStreamPublisher *)publisher {
    //   NSLog(@"HangOutUserViewController::publisherOnConnect( [推流连接] )");
}

- (void)publisherOnDisconnect:(LiveStreamPublisher *)publisher {
    //    NSLog(@"HangOutUserViewController::publisherOnDisconnect( [推流断开] )");
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

        // 吧台礼物延迟移除
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

#pragma mark - 界面显示/隐藏
- (void)activiViewIsShow:(BOOL)isShow {
    if (isShow) {
        [self.activiView startAnimating];
        self.activiView.hidden = NO;
        self.view.userInteractionEnabled = NO;
    } else {
        [self.activiView stopAnimating];
        self.activiView.hidden = YES;
        self.view.userInteractionEnabled = YES;
    }
}

- (void)showNopushView {
    self.headImageView.hidden = NO;
    self.backgroundView.hidden = NO;
    self.closeBackgroundBtn.hidden = NO;
    self.startCloseBtn.hidden = NO;
    [self.view bringSubviewToFront:self.startCloseBtn];

    if (self.isBoostView) {
        self.isBoostView = !self.isBoostView;

        if ([self.userDelegate respondsToSelector:@selector(userLongPressTapBoost:)]) {
            [self.userDelegate userLongPressTapBoost:self.isBoostView];
        }
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

- (void)reloadVideoStatus {
    if (self.liveRoom.publishUrl.length > 0) {
        [self sendRequestManPush:YES];
    } else {
        [self sendRequestManPush:NO];
    }
}

- (void)hiddenBackgroundView {
    if (!self.startPush) {
        self.backgroundView.hidden = YES;
        self.closeBackgroundBtn.hidden = YES;
        self.startCloseBtn.hidden = YES;

        if (self.showTimer) {
            [self.showTimer stopTimer];
        }
    }
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
    self.backgroundView.hidden = NO;
    self.closeBackgroundBtn.hidden = NO;
    self.startCloseBtn.hidden = NO;
    [self.view bringSubviewToFront:self.closeBackgroundBtn];
    [self.view bringSubviewToFront:self.startCloseBtn];

    if (!self.showTimer) {
        self.showTimer = [[LSTimer alloc] init];
    }
    WeakObject(self, weakSelf);
    [self.showTimer startTimer:dispatch_get_main_queue()
                  timeInterval:3.0 * NSEC_PER_SEC
                       starNow:NO
                        action:^{
                            [weakSelf hiddenBackgroundView];
                        }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint pt = [touch locationInView:self.view];
    if (CGRectContainsPoint([self.videoView frame], pt)) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 手势事件 (长按屏幕)
- (void)addLongPressTap {
    if (self.longPressTap == nil) {
        self.longPressTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        self.longPressTap.minimumPressDuration = 1.0;
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
        if (self.liveRoom) {
            self.isBoostView = !self.isBoostView;

            if ([self.userDelegate respondsToSelector:@selector(userLongPressTapBoost:)]) {
                [self.userDelegate userLongPressTapBoost:self.isBoostView];
            }
        }
    }
}

#pragma mark - 界面事件
- (IBAction)closeBackgroundAction:(id)sender {
    [self hiddenBackgroundView];
}

- (IBAction)startAndCloseAction:(id)sender {
    if (self.isFirstPush) {
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromSelf(@"OPEN_VIDEO_TIP") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *okAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.isFirstPush = NO;
            
            self.backgroundView.hidden = YES;
            self.headImageView.hidden = YES;
            self.closeBackgroundBtn.hidden = YES;
            self.startCloseBtn.hidden = YES;
            
            if (self.startPush) {
                [[LiveModule module].analyticsManager reportActionEvent:ClickTwoWay eventCategory:EventCategoryBroadcast];
            }
            // 第一次进入
            [self sendRequestManPush:self.startPush];
        }];
        [alertVC addAction:cancelAC];
        [alertVC addAction:okAC];
        [self presentViewController:alertVC animated:YES completion:nil];

    } else {
        self.backgroundView.hidden = YES;
        self.headImageView.hidden = YES;
        self.closeBackgroundBtn.hidden = YES;
        self.startCloseBtn.hidden = YES;

        if (self.startPush) {
            [[LiveModule module].analyticsManager reportActionEvent:ClickTwoWay eventCategory:EventCategoryBroadcast];
        }
        // 第一次进入
        [self sendRequestManPush:self.startPush];
    }
}

#pragma mark - IM请求
// 观众开始结束视频互动
- (void)sendRequestManPush:(BOOL)isStart {
    [self activiViewIsShow:YES];
    IMControlType type = isStart ? IMCONTROLTYPE_START : IMCONTROLTYPE_CLOSE;

    BOOL bflag = [self.imManager controlManPushHangout:self.liveRoom.roomId
                                               control:type
                                         finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSArray<NSString *> *_Nonnull manPushUrl) {
                                             NSLog(@"HangOutUserViewController::sendRequestManPush( [观众开始/结束视频互动] success : %@, errType : %d, errMsg : %@, manPushUrl : %@ )", success == YES ? @"成功" : @"失败", errType, errMsg, manPushUrl);
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self activiViewIsShow:NO];
                                                 if (success) {
                                                     if (isStart) {
                                                         self.liveRoom.publishUrlArray = manPushUrl;
                                                         [self publish];

                                                         self.startPush = NO;
                                                         [self.startCloseBtn setImage:[UIImage imageNamed:@"Live_Turn_Off_Camera"] forState:UIControlStateNormal];
                                                     } else {
                                                         [self stopPublish];

                                                         self.startPush = YES;
                                                         [self.startCloseBtn setImage:[UIImage imageNamed:@"Live_Open_Camera"] forState:UIControlStateNormal];
                                                         [self showNopushView];
                                                     }

                                                 } else {
                                                     [self stopPublish];

                                                     self.startPush = YES;
                                                     [self.startCloseBtn setImage:[UIImage imageNamed:@"Live_Open_Camera"] forState:UIControlStateNormal];
                                                     [self showNopushView];

                                                     if ([self.userDelegate respondsToSelector:@selector(showManPushError:errNum:)]) {
                                                         [self.userDelegate showManPushError:errMsg errNum:errType];
                                                     }
                                                 }
                                             });
                                         }];
    if (!bflag) {
        [self stopPublish];

        self.startPush = YES;
        [self.startCloseBtn setImage:[UIImage imageNamed:@"Live_Open_Camera"] forState:UIControlStateNormal];
        [self showNopushView];
    }
}

#pragma mark - IM通知
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"HangOutUserViewController::onLogin( [IM登录成功] )");
    dispatch_async(dispatch_get_main_queue(), ^{

                   });
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"HangOutUserViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@, publisherReconnectTime : %lu )", errType, errmsg, (unsigned long)self.publisherReconnectTime);
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
            // IM断开, 重置RTMP断开次数
            self.publisherReconnectTime = 0;
        }
    });
}

- (void)onRecvHangoutGiftNotice:(IMRecvHangoutGiftItemObject *)item {
    BOOL isEqualUserId = [item.toUid isEqualToString:self.loginManager.loginItem.userId];
    BOOL isEqualRoomId = [item.roomId isEqualToString:self.liveRoom.roomId];

    if (isEqualUserId && isEqualRoomId) {
        NSLog(@"HangOutUserViewController::onRecvHangoutGiftNotice( [接收多人互动直播间礼物通知] roomId : %@, fromId : %@, toUid : %@,"
               "giftId : %@, userId : %@ )",
              item.roomId, item.fromId, item.toUid, item.giftId, item.toUid);
        dispatch_async(dispatch_get_main_queue(), ^{

            // 初始化连击起始数
            int starNum = item.multiClickStart - 1;

            // 接收礼物消息item
            GiftItem *model = [GiftItem itemRoomId:item.roomId
                                            fromID:item.fromId
                                          nickName:item.nickName
                                          photoUrl:@""
                                            giftID:item.giftId
                                          giftName:item.giftName
                                           giftNum:item.giftNum
                                       multi_click:item.isMultiClick
                                           starNum:starNum
                                            endNum:item.multiClickEnd
                                           clickID:item.multiClickId];
            // 礼物类型
            GiftType giftType = model.giftItem.infoItem.type;

            switch (giftType) {
                case GIFTTYPE_CELEBRATE: {
                    // 庆祝礼物
                } break;

                case GIFTTYPE_COMMON: {
                    // 连击礼物
                    [self addCombo:model];
                } break;

                default: {
                    // 吧台礼物列表展示
                    [self disPlayBarGiftList:giftType giftItem:model];

                    // 礼物添加到队列
                    if (!self.bigGiftArray && self.viewIsAppear) {
                        self.bigGiftArray = [NSMutableArray array];
                    }
                    for (int i = 0; i < item.giftNum; i++) {
                        [self.bigGiftArray addObject:model.giftid];
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
                } break;
            }
        });
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

- (void)onRecvEnterHangoutRoomNotice:(IMRecvEnterRoomItemObject *)item {

    BOOL isAnchor = item.isAnchor;
    BOOL isEqualUserId = [self.loginManager.loginItem.userId isEqualToString:item.userId];
    BOOL isEqualRoomId = [item.roomId isEqualToString:self.liveRoom.roomId];

    if (!isAnchor && isEqualUserId && isEqualRoomId) {
        NSLog(@"HangOutUserViewController::onRecvEnterHangoutRoomNotice( [接收观众/主播进入多人互动直播间] roomId : %@, userId : %@,"
               "nickName : %@ )",
              item.roomId, item.userId, item.nickName);
        dispatch_async(dispatch_get_main_queue(), ^{

            self.liveRoom.roomId = item.roomId;
            self.liveRoom.userId = item.userId;
            self.liveRoom.userName = item.nickName;
            self.liveRoom.photoUrl = item.photoUrl;
            self.liveRoom.publishUrlArray = item.pullUrl;

            // 刷新吧台礼物统计视图
            [self.barGiftNumArray removeAllObjects];
            if (item.bugForList.count > 0) {
                // 如果吧台礼物列表有用户数据 则更新列表
                [self.barGiftNumArray addObjectsFromArray:item.bugForList];
                [self showGiftCount:self.barGiftNumArray];
            }

            // 存储观众信息到本地
            LSUserInfoModel *model = [[LSUserInfoModel alloc] init];
            model.userId = item.userId;
            model.nickName = item.nickName;
            model.photoUrl = item.photoUrl;
            model.riderName = item.userInfo.riderName;
            model.riderId = item.userInfo.riderId;
            model.riderUrl = item.userInfo.riderUrl;
            model.isAnchor = item.isAnchor;
            [self.roomUserInfoManager setAudienceInfoDicL:model];
        });
    }
}

- (void)onRecvLackOfCreditNotice:(NSString *)roomId msg:(NSString *)msg credit:(double)credit errType:(LCC_ERR_TYPE)errType {
    NSLog(@"HangOutUserViewController::onRecvLackOfCreditNotice( [接收充值通知], roomId : %@ credit:%f errType:%d", roomId, credit, errType);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.liveRoom.roomId isEqualToString:roomId]) {
            if ([self.userDelegate respondsToSelector:@selector(showManPushError:errNum:)]) {
                [self.userDelegate showManPushError:msg errNum:errType];
            }
            [self sendRequestManPush:NO];
        }
    });
}

- (void)onRecvLeaveHangoutRoomNotice:(IMRecvLeaveRoomItemObject *)item {
//    NSLog(@"HangOutUserViewController::onRecvLeaveHangoutRoomNotice( [接收观众/主播退出多人互动直播间] roomId : %@, userId : %@,"
//          "nickName : %@, errNo : %d, errMsg : %@ )", item.roomId, item.userId, item.nickName, item.errNo, item.errMsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

@end
