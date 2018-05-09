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
#import "YMAudienceView.h"

#import "LSImManager.h"
#import "LiveGiftDownloadManager.h"
#import "GiftComboManager.h"
#import "LSImageViewLoader.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"

#pragma mark - 流[播放/推送]逻辑
#define STREAM_PLAYER_RECONNECT_MAX_TIMES 5
#define STREAM_PUBLISH_RECONNECT_MAX_TIMES STREAM_PLAYER_RECONNECT_MAX_TIMES

@interface HangOutUserViewController ()<LiveStreamPublisherDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate,
                                        LoginManagerDelegate, GiftComboViewDelegate>

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
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;

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
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.publishUrl = @"rtmp://172.25.32.133:7474/test_flash/max_i";
    self.publisher = [LiveStreamPublisher instance];
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
    self.giftDownloadManager = [LiveGiftDownloadManager manager];
    
    // 图片下载器
    self.imageLoader = [LSImageViewLoader loader];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化视频界面
    self.publisher.publishView = self.videoView;
    self.publisher.publishView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    // 隐藏阴影
    self.backgroundView.hidden = YES;
    
    // 隐藏头像
    self.headImageView.hidden = YES;
    
    // 初始化连击礼物
    [self setupGiftView];
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
            NSLog(@"HangOutUserViewController::publish( [开始推送流], publishUrl : %@ )", self.publishUrl);
            BOOL bFlag = [self.publisher pushlishUrl:self.publishUrl recordH264FilePath:@"" recordAACFilePath:@""];
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self debugInfo];
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
    NSLog(@"HangOutUserViewController::stopPublish()");
    [self.publisher stop];
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
   NSLog(@"HangOutUserViewController::publisherOnConnect( [推流连接] )");
}

- (void)publisherOnDisconnect:(LiveStreamPublisher *)publisher {
    NSLog(@"HangOutUserViewController::publisherOnDisconnect( [推流断开] )");
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

#pragma mark - 界面事件
- (IBAction)closeBackgroundAction:(id)sender {
    self.backgroundView.hidden = YES;
}

- (IBAction)closeCameraAction:(id)sender {
    
}

#pragma mark - IM通知
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"HangOutUserViewController::onLogin( [IM登录成功] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"HangOutUserViewController::onLogout( [IM注销通知], errType : %d, errmsg : %@, publisherReconnectTime : %lu )"
          , errType, errmsg,(unsigned long)self.publisherReconnectTime);
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
            // IM断开, 重置RTMP断开次数
            self.publisherReconnectTime = 0;
        }
    });
}

- (void)onRecvHangoutGiftNotice:(IMRecvHangoutGiftItemObject *)item {
    NSLog(@"HangOutUserViewController::onRecvHangoutGiftNotice( [接收多人互动直播间礼物通知] roomId : %@, fromId : %@, toUid : %@,"
          "giftId : %@ )",item.roomId, item.fromId, item.toUid, item.giftId);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([item.roomId isEqualToString:self.liveRoom.roomId]) {
            if ([item.toUid isEqualToString:self.loginManager.loginItem.userId]) {
                // 初始化连击起始数
                int starNum = item.multiClickStart - 1;
                
                // 接收礼物消息item
                GiftItem *model = [GiftItem itemRoomId:item.roomId fromID:item.fromId nickName:item.nickName
                                               giftID:item.giftId giftName:item.giftName giftNum:item.giftNum
                                          multi_click:item.isMultiClick starNum:starNum endNum:item.multiClickEnd clickID:item.multiClickId];
                
                GiftType giftType = model.giftItem.infoItem.type;
                
                if (giftType == GIFTTYPE_COMMON) {
                    // 连击礼物
                    [self addCombo:model];
                    
                } else {
                    
                    // 吧台礼物本地计数
                    if (giftType == GIFTTYPE_BAR) {
                        // 吧台礼物列表对象
                        IMGiftNumItemObject *obj = [[IMGiftNumItemObject alloc] init];
                        obj.giftId = model.giftid;
                        obj.giftNum = model.giftnum;
                        
                        // 如果数组有元素遍历添加 无元素则直接添加
                        if (self.barGiftNumArray.count) {
                            NSMutableArray *bars = [[NSMutableArray alloc] init];
                            BOOL bHave = NO;
                            for (IMGiftNumItemObject *numItem in self.barGiftNumArray) {
                                if ([numItem.giftId isEqualToString:model.giftid]) {
                                    numItem.giftNum = numItem.giftNum + model.giftnum;
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
                    for (int i = 0; i < item.giftNum; i++) {
                        [self.bigGiftArray addObject:model.giftid];
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
        }
    });
}

- (void)onRecvEnterHangoutRoomNotice:(IMRecvEnterRoomItemObject *)item {
    NSLog(@"HangOutUserViewController::onRecvEnterHangoutRoomNotice( [接收观众/主播进入多人互动直播间] roomId : %@, userId : %@,"
          "nickName : %@ )",item.roomId, item.userId, item.nickName);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!item.isAnchor && [self.loginManager.loginItem.userId isEqualToString:item.userId]) {
            self.liveRoom.roomId = item.roomId;
            self.liveRoom.userId = item.userId;
            self.liveRoom.userName = item.nickName;
            self.liveRoom.photoUrl = item.photoUrl;
            self.liveRoom.publishUrlArray = item.pullUrl;
            [self.barGiftNumArray addObjectsFromArray:item.bugForList];
            // 加载用户头像
            [self.imageLoader loadImageWithImageView:self.headImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
            
            // 开始推流
            [self publish];
        }
    });
}

- (void)onRecvLeaveHangoutRoomNotice:(IMRecvLeaveRoomItemObject *)item {
    NSLog(@"HangOutUserViewController::onRecvLeaveHangoutRoomNotice( [接收观众/主播退出多人互动直播间] roomId : %@, userId : %@,"
          "nickName : %@, errNo : %d, errMsg : %@ )", item.roomId, item.userId, item.nickName, item.errNo, item.errMsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}



@end
