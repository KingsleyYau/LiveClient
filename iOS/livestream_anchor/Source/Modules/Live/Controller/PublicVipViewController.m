//
//  PublicVipViewController.m
//  livestream
//
//  Created by randy on 2017/9/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PublicVipViewController.h"
#import "LSMainViewController.h"

#import "LSLoginManager.h"
#import "LiveModule.h"
#import "AudienModel.h"
#import "RoomTypeIsFirstManager.h"
#import "UserInfoManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "AnchorPersonalViewController.h"
#import "DialogTip.h"
#import "DialogChoose.h"
#import "LSImageViewLoader.h"
#import "ZBLSImManager.h"

@interface PublicVipViewController () <ZBIMManagerDelegate, ZBIMLiveRoomManagerDelegate,PlayViewControllerDelegate>

// 观众数组
@property (nonatomic, strong) NSMutableArray *audienceArray;

@property (nonatomic, strong) NSTimer *hidenTimer;

@property (nonatomic, assign) BOOL isTipShow;

@property (nonatomic, assign) BOOL isClickGot;

// 管理器
@property (nonatomic, strong) ZBLSImManager *imManager;

@property (nonatomic, strong) LSLoginManager *loginManager;

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

// 是否第一次进类型直播间管理器
@property (nonatomic, strong) RoomTypeIsFirstManager *firstManager;

#pragma mark - toast控件
@property (nonatomic, strong) DialogTip *dialogTipView;
@property (nonatomic, strong) DialogChoose *closeDialogTipView;

@property (nonatomic, strong) LSImageViewLoader *ladyImageLoader;

@end

@implementation PublicVipViewController
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PublicVipViewController::initCustomParam( self : %p )", self);

    self.sessionManager = [LSSessionRequestManager manager];
    self.firstManager = [RoomTypeIsFirstManager manager];
    self.imManager = [ZBLSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    self.dialogTipView = [DialogTip dialogTip];
    self.audienceArray = [[NSMutableArray alloc] init];
    
    self.ladyImageLoader = [LSImageViewLoader loader];
}

- (void)setupContainView {
    [super setupContainView];
}

- (void)dealloc {
    NSLog(@"PublicVipViewController::dealloc( self : %p )", self);

    if (self.closeDialogTipView) {
        [self.closeDialogTipView removeFromSuperview];
    }
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.liveRoom.superView = self.view;
    self.liveRoom.superController = self;
    
    // 初始化播放界面
    [self setupPlayController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
     [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - 界面风格初始化
- (void)setupPlayController {
    // 输入栏
    self.playVC = [[PlayViewController alloc] initWithNibName:nil bundle:nil];
    self.playVC.playDelegate = self;
    [self addChildViewController:self.playVC];
    self.playVC.liveRoom = self.liveRoom;
    // 直播间风格
    self.playVC.liveVC.roomStyleItem = [[RoomStyleItem alloc] init];
    // 连击礼物
    self.playVC.liveVC.roomStyleItem.comboViewBgImage = [UIImage imageNamed:@"Live_Public_Bg_Combo"];
    // 座驾背景
    self.playVC.liveVC.roomStyleItem.riderBgColor = Color(8, 68, 158, 0.58);
    self.playVC.liveVC.roomStyleItem.driverStrColor = Color(255, 210, 5, 1);
    // 弹幕
    self.playVC.liveVC.roomStyleItem.barrageBgColor = Color(255, 255, 255, 0.9);
    // 聊天列表
    self.playVC.liveVC.roomStyleItem.myNameColor = Color(41, 122, 243, 1);
    self.playVC.liveVC.roomStyleItem.liverNameColor = Color(0, 153, 39, 1);
    self.playVC.liveVC.roomStyleItem.userNameColor = Color(41, 122, 243, 1);
    self.playVC.liveVC.roomStyleItem.liverTypeImage = [UIImage imageNamed:@"Live_Public_Vip_Broadcaster"];
    self.playVC.liveVC.roomStyleItem.followStrColor = Color(255, 135, 0, 1);
    self.playVC.liveVC.roomStyleItem.sendStrColor = Color(41, 122, 243, 1);
    self.playVC.liveVC.roomStyleItem.chatStrColor = Color(0, 0, 0, 1);
    self.playVC.liveVC.roomStyleItem.announceStrColor = Color(41, 122, 243, 1);
    self.playVC.liveVC.roomStyleItem.riderStrColor = Color(255, 135, 0, 1);
    self.playVC.liveVC.roomStyleItem.warningStrColor = Color(255, 77, 77, 1);
    self.playVC.liveVC.roomStyleItem.textBackgroundViewColor = Color(181, 181, 181, 0.49);
    
    [self.view addSubview:self.playVC.view];
    [self.playVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    [self.playVC.liveVC bringSubviewToFrontFromView:self.view];
    [self.view bringSubviewToFront:self.playVC.chooseGiftListView];
    CGRect frame = self.playVC.chooseGiftListView.frame;
    frame.origin.y = SCREEN_HEIGHT;
    self.playVC.chooseGiftListView.frame = frame;

    // 设置邀请私密按钮
    self.playVC.liveVC.startOneViewHeigh.constant = 50;
    self.playVC.liveVC.startOneView.clipsToBounds = NO;
    
    // 立即私密按钮
//    self.playVC.liveVC.cameraBtn.hidden = NO;
//    [self.playVC.liveVC.cameraBtn setImage:[UIImage imageNamed:@"Live_Public_Vip_Invite_Btn"] forState:UIControlStateNormal];
    //    [self.playVC.liveVC.cameraBtn addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];

    // 礼物按钮
    [self.playVC.giftBtn setImage:[UIImage imageNamed:@"Live_Public_Vip_Gift_Btn"] forState:UIControlStateNormal];
    // 输入栏目
   
    // 视频播放界面
    //        self.playVC.liveVC.videoBgImageView.backgroundColor = self.view.backgroundColor;

    // 聊天输入框
    self.playVC.liveSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB(0xbaac3f);
    self.playVC.liveSendBarView.inputTextField.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
    // 隐藏表情按钮
    self.playVC.liveSendBarView.emotionBtnWidth.constant = 0;
}

#pragma mark - IM回调
- (void)onZBRecvEnterRoomNotice:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl riderId:(NSString *)riderId riderName:(NSString *)riderName riderUrl:(NSString *)riderUrl fansNum:(int)fansNum {
    NSLog(@"PublicViewController::onZBRecvEnterRoomNotice( [接收观众进入直播间通知] ) roomId : %@, userId : %@, nickName : %@, photoUrl : %@, riderId : %@, riderName : %@, riderUrl : %@, fansNum : %d", roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum);
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

- (void)onZBRecvLeaveRoomNotice:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl fansNum:(int)fansNum {
    NSLog(@"PublicViewController::onZBRecvLeaveRoomNotice( [接收观众退出直播间通知] ) roomId : %@, userId : %@, nickName : %@, photoUrl : %@, fansNum : %d", roomId, userId, nickName, photoUrl, fansNum);
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

#pragma mark - PlayViewControllerDelegate
- (void)onCloseLiveRoom:(PlayViewController *)vc {
    if (self.closeDialogTipView) {
        [self.closeDialogTipView removeFromSuperview];
    }
    self.closeDialogTipView = [DialogChoose dialog];
    [self.closeDialogTipView hiddenCheckView];
    self.closeDialogTipView.tipsLabel.text = NSLocalizedStringFromSelf(@"EXIT_LIVEROOM_TIP");
    WeakObject(self, weakObj);
    [self.closeDialogTipView showDialog:self.view cancelBlock:^{
        
    } actionBlock:^{
        if (weakObj.liveRoom.roomId.length > 0) {
            // 发送退出直播间
            NSLog(@"PublicViewController::liveHeadCloseAction [发送退出直播间:%@]",self.liveRoom.roomId);
            [weakObj.imManager leaveRoom:self.liveRoom.roomId];
            // QN判断已退出直播间
            [LiveModule module].roomID = nil;
        }
    }];
}

@end
