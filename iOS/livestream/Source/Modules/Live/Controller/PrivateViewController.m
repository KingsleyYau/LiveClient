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
#import "LiveUrlHandler.h"

@interface PrivateViewController () <LSVIPLiveViewControllerDelegate, IMLiveRoomManagerDelegate, InputViewControllerDelegate, IMManagerDelegate,LSAnchorDetailCardViewControllerDelegate, LSGiftInfoViewDelegate>
// IM管理器
@property (nonatomic, strong) LSImManager *imManager;
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
    
    [self.giftInfoView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.liveRoom.superView = self.view;
    self.liveRoom.superController = self;
    
    self.giftInfoView = [[LSGiftInfoView alloc] init];
    [self.giftInfoView.infoHeadBgImageView setImage:[UIImage imageNamed:@"VIPLive_PurpleBG"]];
    self.giftInfoView.delegate = self;
    
    // 初始化播放界面
    [self setupPlayController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [LSMinLiveManager manager].liveVC = self;
    [LSMinLiveManager manager].userId = self.liveRoom.userId;
    
    // 刷新头像控件
    [self reloadHeadImageView];
    
    // 设置状态栏为白色字体
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    UIImage *backImage = [UIImage imageNamed:@"Live_Public_ShrankRoom"];
//    if ([LiveGobalManager manager].liveRoom.canShowMinLiveView) {
//        backImage = [UIImage imageNamed:@"Live_Public_ShrankRoom"];
//    }else {
//        backImage = [UIImage imageNamed:@"VIPLive_Close"];
//    }
    
    [self.closeBtn setImage:backImage forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 设置状态栏为默认字体
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
}


- (BOOL)prefersStatusBarHidden {
    return YES;
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

- (void)setupPlayController {
    // 输入栏
    self.playVC = [[LSVIPInputViewController alloc] initWithNibName:nil bundle:nil];
    self.playVC.playDelegate = self;
    [self addChildViewController:self.playVC];
    self.playVC.liveRoom = self.liveRoom;
    // 直播间风格
    self.playVC.roomStyleItem = [[RoomStyleItem alloc] init];
    // 连击礼物
    self.playVC.roomStyleItem.comboViewBgImage = [UIImage imageNamed:@"Live_Private_Bg_Combo"];
    self.playVC.roomStyleItem.comboNumImageName = @"yellow_";
    // 座驾背景
    self.playVC.roomStyleItem.riderBgColor = Color(255, 109, 0, 0.7);
    self.playVC.roomStyleItem.driverStrColor = Color(255, 255, 255, 1);
    // 弹幕
    self.playVC.roomStyleItem.barrageBgColor = Color(37, 37, 37, 0.9); //Color(83, 13, 120, 0.9);
    // 消息列表界面
    self.playVC.roomStyleItem.myNameColor = COLOR_WITH_16BAND_RGB(0x383838);
    self.playVC.roomStyleItem.liverNameColor = COLOR_WITH_16BAND_RGB(0x383838);
    self.playVC.roomStyleItem.userNameColor = COLOR_WITH_16BAND_RGB(0x383838);
    self.playVC.roomStyleItem.chatStrColor = COLOR_WITH_16BAND_RGB(0xffffff);
    self.playVC.roomStyleItem.chatBackgroundViewColor = Color(0, 0, 0, 0.5);
    self.playVC.roomStyleItem.sendStrColor = COLOR_WITH_16BAND_RGB(0xffd205);
    self.playVC.roomStyleItem.sendBackgroundViewColor = Color(0, 0, 0, 0.5);
    self.playVC.roomStyleItem.riderStrColor = COLOR_WITH_16BAND_RGB(0xff9901);
    self.playVC.roomStyleItem.riderBackgroundViewColor = Color(0, 0, 0, 0.5);
    self.playVC.roomStyleItem.followStrColor = COLOR_WITH_16BAND_RGB(0xffffff);
    self.playVC.roomStyleItem.announceStrColor = COLOR_WITH_16BAND_RGB(0xffffff);
    self.playVC.roomStyleItem.announceBackgroundViewColor = Color(0, 202, 255, 0.5);
    self.playVC.roomStyleItem.warningStrColor = COLOR_WITH_16BAND_RGB(0xffffff);
    self.playVC.roomStyleItem.warningBackgroundViewColor = Color(255, 71, 71, 0.5);
    self.playVC.roomStyleItem.firstFreeStrColor = COLOR_WITH_16BAND_RGB(0x383838);
    self.playVC.roomStyleItem.firstFreeBackgroundViewColor = COLOR_WITH_16BAND_RGB(0x00cc66);
    // 推荐礼物界面
    self.playVC.roomStyleItem.chooseTopGiftViewBgColor = COLOR_WITH_16BAND_RGB(0x330435);
    self.playVC.roomStyleItem.topGiftViewBtnImage = [UIImage imageNamed:@"VIPLive_GiftView_Upicon"];
    // 输入框
    self.playVC.roomStyleItem.emotionImage = [UIImage imageNamed:@"VIPLive_Input_Emoji"];
    self.playVC.roomStyleItem.emotionSelectImage = [UIImage imageNamed:@"VIPLive_Input_Keyboard"];
    // 礼物列表
    self.playVC.roomStyleItem.giftPageHeadBgImage = [UIImage imageNamed:@"VIPLive_PurpleBG"];
    self.playVC.roomStyleItem.giftPageTipBtnImage = [UIImage imageNamed:@"VIPLive_Info"];
    self.playVC.roomStyleItem.giftPageDownBtnImage = [UIImage imageNamed:@"VIPLive_GiftView_Downicon"];
    self.playVC.roomStyleItem.giftPageBgColor = COLOR_WITH_16BAND_RGB(0x330435);
    self.playVC.roomStyleItem.giftSegmentTitleColor = COLOR_WITH_16BAND_RGB(0x330435);
    self.playVC.roomStyleItem.giftSegmentTitleSelectColor = COLOR_WITH_16BAND_RGB(0xed85e8);
    
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
    
    WeakObject(self, weakSelf);
    // 女士头像点击
    [self.ladyImageView addTapBlock:^(id obj) {
        [weakSelf pushToAnchorPersonal:nil];
    }];
}

#pragma mark - 按钮事件
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
    
    if (![LSConfigManager manager].dontShow2WayVideoDialog) {
        [self.playVC.liveVC stopCamVideo];
    }
    
//    if ( [LiveGobalManager manager].liveRoom.canShowMinLiveView) {
        [[LSMinLiveManager manager] showMinLive];
        LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
        [nvc forceToDismissAnimated:YES completion:nil];
//    }else {
//        
//        WeakObject(self, weakObj);
//        
//        NSString *leaveRoomTip = NSLocalizedStringFromSelf(@"EXIT_LIVEROOM_TIP");
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:leaveRoomTip preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"NO",nil)
//                                                            style:UIAlertActionStyleCancel
//                                                          handler:^(UIAlertAction *_Nonnull action) {
//            
//        }]];
//        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"YES",nil)
//                                                            style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction *_Nonnull action) {
//            [[LSMinLiveManager manager] hidenMinLive];
//            LSNavigationController *nvc = (LSNavigationController *)weakObj.navigationController;
//            [nvc forceToDismissAnimated:YES completion:nil];
//        }]];
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
}

- (void)dismissVC {
    
}

#pragma mark - 数据逻辑
- (void)reloadHeadImageView {
    self.laddyNameLabel.text = [NSString stringWithFormat:@"%@", self.liveRoom.userName];
    
    // TODO:刷新女士头像
    [self.ladyImageViewLoader loadImageFromCache:self.ladyImageView
                                         options:SDWebImageRefreshCached
                                        imageUrl:self.liveRoom.photoUrl
                                placeholderImage:LADYDEFAULTIMG
                                   finishHandler:^(UIImage *image){
    }];
    
    
}

#pragma mark - LSVIPInputViewControllerDelegate
- (void)pushToAddCredit:(LSVIPInputViewController *)vc {
    NSURL *url = [[LiveUrlHandler shareInstance] createBuyCredit];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (void)didShowGiftListInfo:(LSVIPInputViewController *)vc {
    [self.navigationController.view addSubview:self.giftInfoView];
}

- (void)didRemoveGiftListInfo:(LSVIPInputViewController *)vc {
    [self.giftInfoView removeFromSuperview];
    [self.anchorDetailVc dismissView];
}

- (void)pushStoreVC:(LSVIPInputViewController *)vc {
    LSStoreListToLadyViewController * storeVC = [[LSStoreListToLadyViewController alloc]initWithNibName:nil bundle:nil];
    storeVC.anchorId = self.liveRoom.userId;
    storeVC.anchorName = self.liveRoom.userName;
    storeVC.anchorImageUrl = self.liveRoom.photoUrl;
    [self.navigationController pushViewController:storeVC animated:NO];
}

#pragma mark - LSGiftInfoViewDelegate
- (void)didCloseGiftInfoView:(LSGiftInfoView *)infoView {
    [self.giftInfoView removeFromSuperview];
}

#pragma mark - 播放界面回调
- (void)onReEnterRoom:(LSVIPInputViewController *)vc {
    NSLog(@"PrivateViewController::onReEnterRoom()");
}

@end
