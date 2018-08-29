//
//  PublicViewController.m
//  livestream
//
//  Created by randy on 2017/8/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PublicViewController.h"
#import "LSMainViewController.h"
#import "AnchorPersonalViewController.h"

#import "LiveUrlHandler.h"

#import "AudienceCell.h"
#import "LSAnchorImManager.h"
#import "LiveModule.h"
#import "AudienModel.h"
#import "RoomTypeIsFirstManager.h"
#import "UserInfoManager.h"
#import "DialogTip.h"

#define PageSize 10

@interface PublicViewController () <ZBIMManagerDelegate, ZBIMLiveRoomManagerDelegate,PlayViewControllerDelegate>

// 观众数组
@property (nonatomic, strong) NSMutableArray *audienceArray;

// IM管理器
@property (nonatomic, strong) LSAnchorImManager *imManager;

@property (nonatomic, strong) NSTimer *hidenTimer;

@property (nonatomic, assign) BOOL isTipShow;

@property (nonatomic, assign) BOOL isClickGot;

// 是否第一次进类型直播间管理器
@property (nonatomic, strong) RoomTypeIsFirstManager *firstManager;

#pragma mark - toast控件
@property (nonatomic, strong) DialogTip *dialogTipView;

@end

@implementation PublicViewController

- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PublicViewController::initCustomParam( self : %p )", self);
    self.isTipShow = NO;

    self.firstManager = [RoomTypeIsFirstManager manager];

    self.audienceArray = [[NSMutableArray alloc] init];

    self.imManager = [LSAnchorImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    self.dialogTipView = [DialogTip dialogTip];
}

- (void)dealloc {
    NSLog(@"PublicViewController::dealloc( self : %p )", self);

    [[DialogTip dialogTip] stopTimer];
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.liveRoom.superView = self.view;
    self.liveRoom.superController = self;
    // 初始化播放界面
    [self setupPlayController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

- (void)setupContainView {
    [super setupContainView];

    // 初始化头部界面
    [self setupHeaderImageView];
}

- (void)setupHeaderImageView {
    // 计算StatusBar高度
    if ([LSDevice iPhoneXStyle]) {
        self.titleBgImageTop.constant = 44;
    } else {
        self.titleBgImageTop.constant = 20;
    }
    
    // 初始化收藏 观众人数
    self.numShaowView.layer.cornerRadius = 10;
    self.followAndHomepageView.layer.cornerRadius = 13;
//    self.followBtnWidth.constant = 0;
    
    // 直播间类型资费提示
    self.tipView = [[ChardTipView alloc] init];
    self.tipView.gotBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x5d0e86);

    [self.tipView setTipWithRoomPrice:0 roomTip:NSLocalizedStringFromSelf(@"Public_Tip") creditText:nil];
    [self.view addSubview:self.tipView];
    [self.roomTypeImageView sizeToFit];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roomTypeImageView.mas_bottom).offset(2);
        make.width.equalTo(@(self.roomTypeImageView.frame.size.width * 1.5));
        make.left.equalTo(@0);
    }];

    // 图片点击事件
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

    // 是否第一次进入该类型直播间 显示资费提示
    BOOL haveCome = [self.firstManager getThisTypeHaveCome:@"Public_Join"];
    if (haveCome) {
        [self.tipView hiddenChardTip];
    } else {
        [self.firstManager comeinLiveRoomWithType:@"Public_Join" HaveComein:YES];
    }

    // 更新头部直播间数据
    [self setupHeadViewInfo];
}

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
    self.playVC.liveVC.roomStyleItem.userNameColor = Color(255, 135, 0, 1);
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
        make.top.equalTo(self.titleBackGroundView.mas_bottom);
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
    
    //    self.playVC.chooseGiftListView.frame.origin = CGPointMake(self.playVC.chooseGiftListView.frame.origin.x, SCREEN_HEIGHT);
    // 立即私密按钮
//    self.playVC.liveVC.cameraBtn.hidden = NO;
    //    [self.playVC.liveVC.cameraBtn addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
    // 邀请按钮
//    [self.playVC.liveVC.cameraBtn setImage:[UIImage imageNamed:@"Live_Public_Btn_Camera_Invite"] forState:UIControlStateNormal];

    // 视频播放界面
    //    self.playVC.liveVC.videoBgImageView.backgroundColor = self.view.backgroundColor;

    // 聊天输入框
    self.playVC.liveSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB(0xb296df);
    self.playVC.liveSendBarView.inputTextField.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
    // 隐藏表情按钮
    self.playVC.liveSendBarView.emotionBtnWidth.constant = 0;
}

- (void)hidenChardTip {
    self.tipView.hidden = YES;
    if (self.hidenTimer) {
        [self.hidenTimer invalidate];
        self.hidenTimer = nil;
    }
    self.isTipShow = NO;
}

#pragma mark - 按钮事件
//- (IBAction)cameraAction:(id)sender {
//    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" userId:self.liveRoom.userId roomType:LiveRoomType_Private];
//    [LiveUrlHandler shareInstance].url = url;
//
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//}

- (IBAction)pushLiveHomePage:(id)sender {
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] init];
    listViewController.anchorId = self.liveRoom.userId;
    listViewController.showInvite = 0;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (IBAction)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 请求数据逻辑
// 更新头部直播间数据
- (void)setupHeadViewInfo {
    [self.homePageBtn setTitle:self.liveRoom.userName forState:UIControlStateNormal];
    [self.peopleNumBtn setTitle:[NSString stringWithFormat:@" %d", self.liveRoom.imLiveRoom.maxFansiNum] forState:UIControlStateNormal];
}

#pragma mark - IM回调
- (void)onZBRecvEnterRoomNotice:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl riderId:(NSString *)riderId riderName:(NSString *)riderName riderUrl:(NSString *)riderUrl fansNum:(int)fansNum isHasTicket:(BOOL)isHasTicket{
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
    if (self.liveRoom.roomId.length > 0) {
        // 发送退出直播间
        NSLog(@"PublicViewController::onCloseLiveRoom( [发送退出直播间:%@] )",self.liveRoom.roomId);
        [self.imManager leaveRoom:self.liveRoom.roomId];
        // QN判断已退出直播间
        [LiveModule module].roomID = nil;
    }
}

- (void)text {

    UIImage *image1 = [UIImage imageNamed:@"freeLive_nomal_background"];
    UIImage *image2 = [UIImage imageNamed:@"Live_Public_Btn_Camera_Invite"];
    UIImage *image3 = [UIImage imageNamed:@"Login_Main_Logo"];
    UIImage *image4 = [UIImage imageNamed:@"freeLive_nomal_background"];
    UIImage *image5 = [UIImage imageNamed:@"Live_Public_Btn_Camera_Invite"];
    UIImage *image6 = [UIImage imageNamed:@"Login_Main_Logo"];
    UIImage *image7 = [UIImage imageNamed:@"Live_Public_Btn_Camera_Invite"];
    UIImage *image8 = [UIImage imageNamed:@"Login_Main_Logo"];
    UIImage *image9 = [UIImage imageNamed:@"freeLive_nomal_background"];
    UIImage *image10 = [UIImage imageNamed:@"Login_Main_Logo"];
    UIImage *image11 = [UIImage imageNamed:@"Live_Public_Btn_Camera_Invite"];
    UIImage *image12 = [UIImage imageNamed:@"freeLive_nomal_background"];
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:image1,image2,image3,image4,image5,image6,image7,image8,image9,image10,image11,image12, nil];
    self.audienceArray = array;
    self.audienceView.audienceArray = self.audienceArray;
}


@end
