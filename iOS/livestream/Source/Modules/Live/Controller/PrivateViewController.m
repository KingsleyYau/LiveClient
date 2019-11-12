//
//  PrivateViewController.m
//  livestream
//
//  Created by randy on 2017/8/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PrivateViewController.h"
#import "LiveWebViewController.h"
#import "AnchorPersonalViewController.h"
//#import "StartHangOutTipView.h"
#import "LSAddCreditsViewController.h"

#import "LiveModule.h"

#import "LSRoomUserInfoManager.h"
#import "LSLoginManager.h"
#import "LSConfigManager.h"
#import "LSImManager.h"
#import "LSMinLiveManager.h"

#import "DialogTip.h"
#import "DialogChoose.h"

#import "SetFavoriteRequest.h"

#import "LSImageViewLoader.h"
#import "LSAnchorDetailCardViewController.h"
#import "LSStoreListToLadyViewController.h"

#import "LSGiftInfoView.h"

@interface PrivateViewController () <LSVIPLiveViewControllerDelegate, IMLiveRoomManagerDelegate, InputViewControllerDelegate, IMManagerDelegate,LSAnchorDetailCardViewControllerDelegate>
// IM管理器
@property (nonatomic, strong) LSImManager *imManager;
// 资费提示小时计时器
@property (nonatomic, strong) NSTimer *hidenTimer;
// 是否显示资费提示
@property (nonatomic, assign) BOOL isTipShow;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;

#pragma mark - 头像逻辑
@property (atomic, strong) LSImageViewLoader *ladyImageViewLoader;
@property (atomic, strong) LSImageViewLoader *intimacyLadyImageViewLoader;
@property (atomic, strong) LSImageViewLoader *intimacyManImageViewLoader;
@property (atomic, strong) LSImageViewLoader *manPreviewImageViewLoader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistance;

#pragma mark - 随机礼物控制
@property (strong) LSTimer *randomGiftTimer;
@property (atomic, strong) NSArray<LSGiftManagerItem *> *giftArray;
@property (atomic, assign) NSInteger randomGiftIndex;

// 对话框控件
@property (strong) DialogTip *dialogTipView;
// 是否能推流
@property (assign) BOOL canPublish;

@property (strong) DialogChoose *dialogChoose;
@property (nonatomic, strong) DialogChoose *closeDialogTipView;

#pragma mark - 直播间管理器
// 是否第一次进类型直播间管理器
@property (nonatomic, strong) RoomTypeIsFirstManager *firstManager;

#pragma mark - 用户信息管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

@property (nonatomic, strong) LSGiftInfoView * giftInfoView;
@property (nonatomic, strong) LSAnchorDetailCardViewController *anchorDetailVc;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgShadowTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgShadowHeight;
@end

@implementation PrivateViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    NSLog(@"PrivateViewController::initCustomParam( self : %p )", self);

    // 隐藏导航栏
    self.isShowNavBar = NO;
    // 禁止导航栏后退手势
    self.canPopWithGesture = NO;
    
    srand((unsigned)time(0));

    self.isTipShow = NO;
    self.randomGiftIndex = -1;

    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    self.sessionManager = [LSSessionRequestManager manager];
    self.firstManager = [RoomTypeIsFirstManager manager];
    self.loginManager = [LSLoginManager manager];

    self.roomUserInfoManager = [LSRoomUserInfoManager manager];

    self.ladyImageViewLoader = [LSImageViewLoader loader];
    self.intimacyManImageViewLoader = [LSImageViewLoader loader];
    self.intimacyLadyImageViewLoader = [LSImageViewLoader loader];
    self.manPreviewImageViewLoader = [LSImageViewLoader loader];

    self.dialogTipView = [DialogTip dialogTip];

    self.canPublish = NO;

    // 初始化计时器
    self.randomGiftTimer = [[LSTimer alloc] init];
}

- (void)dealloc {
    NSLog(@"PrivateViewController::dealloc( self : %p )", self);

    if (self.dialogChoose) {
        [self.dialogChoose removeFromSuperview];
    }
    if (self.closeDialogTipView) {
        [self.closeDialogTipView removeFromSuperview];
    }

    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    self.giftInfoView.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.liveRoom.superView = self.view;
    self.liveRoom.superController = self;

    self.giftInfoView = [[LSGiftInfoView alloc]init];
    [self.navigationController.view addSubview:self.giftInfoView];
    self.giftInfoView.hidden = YES;

    // 初始化播放界面
    [self setupPlayController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 刷新头像控件
    [self reloadHeadImageView];

    // 设置状态栏为白色字体
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    // 开启随机礼物定时器
    [self startRandomGiftTimer];

    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 停止随机礼物计时
    [self stopRandomGiftTimer];

    // 设置状态栏为默认字体
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化头部界面
    [self setupHeaderImageView];

    // 通知外部处理
    if ([self.vcDelegate respondsToSelector:@selector(onSetupViewController:)]) {
        [self.vcDelegate onSetupViewController:self];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupPlayController {
    // 输入栏
    self.playVC = [[LSVIPInputViewController alloc] initWithNibName:nil bundle:nil];
    self.playVC.playDelegate = self;
    [self addChildViewController:self.playVC];
    self.playVC.liveRoom = self.liveRoom;
    // 直播间风格
    self.playVC.liveVC.roomStyleItem = [[RoomStyleItem alloc] init];
    // 连击礼物
    self.playVC.liveVC.roomStyleItem.comboViewBgImage = [UIImage imageNamed:@"Live_Private_Bg_Combo"];
    // 座驾背景
    self.playVC.liveVC.roomStyleItem.riderBgColor = Color(255, 109, 0, 0.7);
    self.playVC.liveVC.roomStyleItem.driverStrColor = Color(255, 255, 255, 1);
    // 弹幕
    self.playVC.liveVC.roomStyleItem.barrageBgColor = Color(37, 37, 37, 0.9); //Color(83, 13, 120, 0.9);
    // 消息列表界面
    self.playVC.liveVC.roomStyleItem.myNameColor = COLOR_WITH_16BAND_RGB(0x383838);
    self.playVC.liveVC.roomStyleItem.liverNameColor = COLOR_WITH_16BAND_RGB(0x383838);
    self.playVC.liveVC.roomStyleItem.userNameColor = COLOR_WITH_16BAND_RGB(0x383838);
    
    self.playVC.liveVC.roomStyleItem.chatStrColor = COLOR_WITH_16BAND_RGB(0xffffff);
    self.playVC.liveVC.roomStyleItem.chatBackgroundViewColor = Color(0, 0, 0, 0.5);
    
    self.playVC.liveVC.roomStyleItem.sendStrColor = COLOR_WITH_16BAND_RGB(0xffd205);
    self.playVC.liveVC.roomStyleItem.sendBackgroundViewColor = Color(0, 0, 0, 0.5);
    
    self.playVC.liveVC.roomStyleItem.riderStrColor = COLOR_WITH_16BAND_RGB(0xff9901);
    self.playVC.liveVC.roomStyleItem.riderBackgroundViewColor = Color(0, 0, 0, 0.5);
    
    self.playVC.liveVC.roomStyleItem.followStrColor = COLOR_WITH_16BAND_RGB(0xffffff);
    self.playVC.liveVC.roomStyleItem.announceStrColor = COLOR_WITH_16BAND_RGB(0xffffff);
    self.playVC.liveVC.roomStyleItem.announceBackgroundViewColor = Color(0, 202, 255, 0.5);
    
    self.playVC.liveVC.roomStyleItem.warningStrColor = COLOR_WITH_16BAND_RGB(0xffffff);
    self.playVC.liveVC.roomStyleItem.warningBackgroundViewColor = Color(255, 71, 71, 0.5);

    self.playVC.liveVC.roomStyleItem.firstFreeStrColor = COLOR_WITH_16BAND_RGB(0x383838);
    self.playVC.liveVC.roomStyleItem.firstFreeBackgroundViewColor = COLOR_WITH_16BAND_RGB(0x00cc66);
    
    // 修改高级私密直播间样式
    if ([self.vcDelegate respondsToSelector:@selector(setUpLiveRoomType:)]) {
        [self.vcDelegate setUpLiveRoomType:self];
    }

    [self.view addSubview:self.playVC.view];
    [self.playVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        if (IS_IPHONE_X) {
            make.bottom.equalTo(self.view).offset(-35);
        } else {
            make.bottom.equalTo(self.view);
        }
    }];

    // 置顶礼物播放层次
    [self.view bringSubviewToFront:self.playVC.liveVC.giftView];
    // 置顶在礼物播放之下头部层级
    [self.playVC.liveVC bringSubviewToFrontFromView:self.ladyHeadView];
    
    // 置顶虚拟礼物列表
    [self.view bringSubviewToFront:self.playVC.chooseGiftListView];
    CGRect frame = self.playVC.chooseGiftListView.frame;
    frame.origin.y = SCREEN_HEIGHT;
    self.playVC.chooseGiftListView.frame = frame;

    // 隐藏立即私密邀请控件
    //self.playVC.liveVC.startOneView.backgroundColor = [UIColor clearColor];

    // 随机礼物
//    self.playVC.randomGiftBtnBgWidth.constant = 36;
//    self.playVC.randomGiftBtnWidth.constant = -12;
//    self.playVC.randomGiftBtnTailing.constant = -10;
    // 返点界面
   // self.playVC.liveVC.rewardedBgView.backgroundColor = COLOR_WITH_16BAND_RGB(0X293FA3); //Color(53, 75, 158, 1.0);
    // 视频播放界面
    //    self.playVC.liveVC.videoBgImageView.backgroundColor = self.view.backgroundColor;
    // 视频互动界面
   // [self.playVC.liveVC showPreview];

    // 随机礼物按钮
//    [self.playVC.randomGiftBtn addTarget:self action:@selector(randomGiftAction:) forControlEvents:UIControlEventTouchUpInside];
//    // 输入栏目
//    [self.playVC.chatBtn setImage:[UIImage imageNamed:@"Live_Private_Btn_Chat"]];
//    [self.playVC.giftBtn setImage:[UIImage imageNamed:@"Live_Private_Btn_Gift"] forState:UIControlStateNormal];
    // 发送栏目
//    [self.playVC.liveSendBarView.sendBtn setImage:[UIImage imageNamed:@"Private_Send_Btn"] forState:UIControlStateNormal];
//    self.playVC.liveSendBarView.louderBtnImage = [UIImage imageNamed:@"Private_Pop_Btn"];
//    self.playVC.liveSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB(0xc39eff);
//    self.playVC.liveSendBarView.inputBackGroundImageView.image = [UIImage imageNamed:@"Private_Input_icon"];
//    self.playVC.liveSendBarView.sendBarBgImageView.image = [UIImage imageNamed:@"Live_Private_SendBar_bg"];
//    self.playVC.liveSendBarView.inputTextField.textColor = [UIColor whiteColor];
//    // 显示表情按钮
//    self.playVC.liveSendBarView.emotionBtnWidth.constant = 30;

    // 初始化推流
    [self.playVC.liveVC initPublish];
}

- (void)setupHeaderImageView {
    // 计算StatusBar高度
    if (IS_IPHONE_X) {
        self.topDistance.constant = 44;
        self.bgShadowHeight.constant = 102;
        self.bgShadowTop.constant = -44;
    } else {
        self.topDistance.constant = 0;
        self.bgShadowHeight.constant = 68;
        self.bgShadowTop.constant = 0;
    }
    self.roomTpyeLabel.layer.cornerRadius = self.roomTpyeLabel.frame.size.height * 0.5f;
    self.roomTpyeLabel.layer.masksToBounds = YES;

    // 女士背景
    self.ladyHeadView.layer.cornerRadius = self.ladyImageView.frame.size.height / 2;
    // 女士头像
    self.ladyImageView.layer.cornerRadius = self.ladyImageView.frame.size.width / 2;
    
    self.ladyImageView.layer.borderWidth = 2;
    self.ladyImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.ladyIdLabel.text = self.liveRoom.userId;

    // 直播间类型资费提示(暂时不用)
    //    [self setupRoomTypeImageView];

    WeakObject(self, weakSelf);
    // 女士头像点击
    [self.ladyImageView addTapBlock:^(id obj) {
        [weakSelf pushToAnchorPersonal:nil];
    }];

}

// 直播间类型资费提示(暂时不用)
- (void)setupRoomTypeImageView {

    self.tipView = [[ChardTipView alloc] init];
    self.tipView.gotBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0X5D0E86);
    [self.tipView setTipWithRoomPrice:self.liveRoom.imLiveRoom.roomPrice
                              roomTip:NSLocalizedStringFromSelf(@"PUBLIV_TIP")
                           creditText:NSLocalizedStringFromSelf(@"CREDIT_TIP")];
    self.tipView.hidden = YES;
    [self.view addSubview:self.tipView];
    [self.roomTypeImageView sizeToFit];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roomTypeImageView.mas_bottom).offset(2);
        make.width.equalTo(@(self.roomTypeImageView.frame.size.width * 1.5));
        make.left.equalTo(@0);
    }];

    // 直播间类型点击事件
    WeakObject(self, weakSelf);
    [self.roomTypeImageView addTapBlock:^(id obj) {
        if (!weakSelf.isTipShow) {
            weakSelf.hidenTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                   target:weakSelf
                                                                 selector:@selector(hidenChardTip)
                                                                 userInfo:nil
                                                                  repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:weakSelf.hidenTimer forMode:NSRunLoopCommonModes];
            [weakSelf.view bringSubviewToFront:weakSelf.tipView];
            weakSelf.tipView.hidden = NO;
            weakSelf.isTipShow = YES;
        }
    }];
}

#pragma mark - 点击亲密度
- (void)clickIntimacyImage {
    LiveWebViewController *webViewController = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
    webViewController.isIntimacy = YES;
    webViewController.anchorId = self.liveRoom.userId;
    webViewController.title = @"Intimacy Level";
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - 按钮事件
- (void)hidenChardTip {
    // TODO:点击资费提示
    self.tipView.hidden = YES;
    if (self.hidenTimer) {
        [self.hidenTimer invalidate];
        self.hidenTimer = nil;
    }
    self.isTipShow = NO;
}

- (IBAction)pushToAnchorPersonal:(id)sender {
    // 弹出没点弹层收起键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    self.anchorDetailVc = [[LSAnchorDetailCardViewController alloc] initWithNibName:nil bundle:nil];
    self.anchorDetailVc.item = self.liveRoom;
    self.anchorDetailVc.anchorDetailDelegate = self;
    [self.anchorDetailVc loadAchorDetail:self.navigationController];
}

- (void)lsAnchorDetailCardViewController:(LSAnchorDetailCardViewController *)vc didAddFavorite:(BOOL)favorite {
    self.liveRoom.imLiveRoom.favorite = favorite;
}


- (IBAction)closeAction:(id)sender {
    
     WeakObject(self, weakObj);
   
    NSString *leaveRoomTip = NSLocalizedStringFromSelf(@"EXIT_LIVEROOM_TIP");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:leaveRoomTip preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"NO",nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                           
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"YES",nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
        [LSMinLiveManager manager].privateLiveVC = self;
        [[LSMinLiveManager manager] showMinLive];
                                                          LSNavigationController *nvc = (LSNavigationController *)weakObj.navigationController;
                                                          [nvc forceToDismissAnimated:YES completion:nil];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)hangoutAction:(id)sender {
    // TODO:点击显示Hangout提示框
    if ([self.vcDelegate respondsToSelector:@selector(showHangoutTipView:)]) {
        [self.vcDelegate showHangoutTipView:self];
    }
}

- (IBAction)randomGiftAction:(id)sender {
    // TODO:点击随机礼物
    [[LiveModule module].analyticsManager reportActionEvent:PrivateBroadcastClickRecommendGift eventCategory:EventCategoryBroadcast];
    if (self.randomGiftIndex != -1) {
        LSGiftManagerItem *item = [self.giftArray objectAtIndex:self.randomGiftIndex];
        [self.playVC.giftVC selectItem:item];
    }

    // 打开礼物界面
    //[self.playVC giftAction:sender];
}

#pragma mark - 数据逻辑
- (void)reloadHeadImageView {
    self.laddyNameLabel.text = [NSString stringWithFormat:@"%@", self.liveRoom.userName];

    // TODO:刷新女士头像
    [self.ladyImageViewLoader loadImageFromCache:self.ladyImageView
                                         options:SDWebImageRefreshCached
                                        imageUrl:self.liveRoom.photoUrl
                                placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]
                                   finishHandler:^(UIImage *image){
                                   }];


}

- (void)sendFollowRequest {
    [[LiveModule module].analyticsManager reportActionEvent:BroadcastClickFollow eventCategory:EventCategoryBroadcast];
    SetFavoriteRequest *request = [[SetFavoriteRequest alloc] init];
    request.userId = self.liveRoom.userId;
    request.roomId = self.liveRoom.roomId;
    request.isFav = YES;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                //                [self.playVC.liveVC addAudienceFollowLiverMessage:self.playVC.loginManager.loginItem.nickName];
            } else {
                // 错误提示
                [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:NSLocalizedStringFromSelf(@"FOLLOW_FAIL")];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - 界面显示/隐藏

#pragma mark - LSVIPInputViewControllerDelegate
- (void)pushToAddCredit:(LSVIPInputViewController *)vc {
    LSAddCreditsViewController *addVC = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)didShowGiftListInfo:(LSVIPInputViewController *)vc {
    self.giftInfoView.hidden = NO;
}

- (void)didRemoveGiftListInfo:(LSVIPInputViewController *)vc {
    self.giftInfoView.hidden = YES;
    [self.anchorDetailVc dismissView];
}

- (void)pushStoreVC:(LSVIPInputViewController *)vc {
    LSStoreListToLadyViewController * storeVC = [[LSStoreListToLadyViewController alloc]initWithNibName:nil bundle:nil];
    storeVC.anchorId = self.liveRoom.userId;
    storeVC.anchorName = self.liveRoom.userName;
    storeVC.anchorImageUrl = self.liveRoom.photoUrl;
    [self.navigationController pushViewController:storeVC animated:NO];
}

#pragma mark - 播放界面回调
- (void)onReEnterRoom:(LSVIPInputViewController *)vc {
    NSLog(@"PrivateViewController::onReEnterRoom()");
    
}

#pragma mark - 倒数控制
- (void)randomGiftCountDown {
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
//        // 修改随机礼物
//        UIImage *defaultImage = [UIImage imageNamed:@"Live_Publish_Btn_Gift"];
//        [weakSelf.playVC.randomGiftBtn setImage:defaultImage forState:UIControlStateNormal];

        if (weakSelf.giftArray.count > 0) {
            int randValue = rand();
            weakSelf.randomGiftIndex = randValue % weakSelf.giftArray.count;

            LSGiftManagerItem *gift = [weakSelf.giftArray objectAtIndex:weakSelf.randomGiftIndex];
            NSString *url = gift.infoItem.middleImgUrl;

            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager loadImageWithURL:[NSURL URLWithString:url]
                options:0
                progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

                }
                completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //[weakSelf.playVC.randomGiftBtn setImage:image forState:UIControlStateNormal];
                        });
                    }
                }];
        } else {
            // 没有随机礼物
            NSLog(@"PrivateViewController::randomGiftCountDown( [No random gift] )");
            self.randomGiftIndex = -1;
        }
    });
}

- (void)startRandomGiftTimer {
    NSLog(@"PrivateViewController::startRandomGiftTimer()");
    
    WeakObject(self, weakSelf);
    [self.randomGiftTimer startTimer:nil timeInterval:300.0 * NSEC_PER_SEC starNow:YES action:^{
        [weakSelf randomGiftCountDown];
    }];
}

- (void)stopRandomGiftTimer {
    NSLog(@"PrivateViewController::stopRandomGiftTimer()");
    
    [self.randomGiftTimer stopTimer];
}

@end
