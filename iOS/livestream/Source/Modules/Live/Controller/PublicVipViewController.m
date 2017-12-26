//
//  PublicVipViewController.m
//  livestream
//
//  Created by randy on 2017/9/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PublicVipViewController.h"
#import "LSMainViewController.h"

#import "SetFavoriteRequest.h"
#import "LiveFansListRequest.h"

#import "LSLoginManager.h"
#import "LiveModule.h"
#import "AudienModel.h"
#import "RoomTypeIsFirstManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "AnchorPersonalViewController.h"
#import "DialogTip.h"

@interface PublicVipViewController () <IMManagerDelegate, IMLiveRoomManagerDelegate,PlayViewControllerDelegate>

// 观众数组
@property (nonatomic, strong) NSMutableArray *audienceArray;

@property (nonatomic, strong) NSTimer *hidenTimer;

@property (nonatomic, assign) BOOL isTipShow;

@property (nonatomic, assign) BOOL isClickGot;

// 管理器
@property (nonatomic, strong) LSImManager *imManager;

@property (nonatomic, strong) LSLoginManager *loginManager;

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

// 是否第一次进类型直播间管理器
@property (nonatomic, strong) RoomTypeIsFirstManager *firstManager;

#pragma mark - toast控件
@property (nonatomic, strong) DialogTip *dialogTipView;

@end

@implementation PublicVipViewController
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PublicVipViewController::initCustomParam( self : %p )", self);

    self.sessionManager = [LSSessionRequestManager manager];
    self.firstManager = [RoomTypeIsFirstManager manager];
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    self.dialogTipView = [DialogTip dialogTip];
    self.audienceArray = [[NSMutableArray alloc] init];
}

- (void)setupContainView {
    [super setupContainView];

    // 初始化头部界面
    [self setupHeaderImageView];

    // 请求观众席列表
    [self setupAudienView];
}

- (void)dealloc {
    NSLog(@"PublicVipViewController::dealloc( self : %p )", self);

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

#pragma mark - 界面风格初始化
- (void)setupPlayController {
    // 输入栏
    self.playVC = [[PlayViewController alloc] initWithNibName:nil bundle:nil];
    self.playVC.delegate = self;
    [self addChildViewController:self.playVC];
    self.playVC.liveRoom = self.liveRoom;
    // 直播间风格
    self.playVC.liveVC.roomStyleItem = [[RoomStyleItem alloc] init];
    // 连击礼物
    self.playVC.liveVC.roomStyleItem.comboViewBgImage = [UIImage imageNamed:@"Live_Public_Bg_Combo"];
    // 弹幕
    self.playVC.liveVC.roomStyleItem.barrageBgColor = Color(93, 14, 134, 0.9);
    // 聊天列表
    self.playVC.liveVC.roomStyleItem.nameColor = COLOR_WITH_16BAND_RGB(0Xffd205);
    self.playVC.liveVC.roomStyleItem.followStrColor = COLOR_WITH_16BAND_RGB(0X9b8aff);
    self.playVC.liveVC.roomStyleItem.sendStrColor = COLOR_WITH_16BAND_RGB(0X0cedf5);
    self.playVC.liveVC.roomStyleItem.chatStrColor = [UIColor whiteColor];
    self.playVC.liveVC.roomStyleItem.announceStrColor = COLOR_WITH_16BAND_RGB(0x0cd7de);
    self.playVC.liveVC.roomStyleItem.riderStrColor = COLOR_WITH_16BAND_RGB(0xffd205);
    self.playVC.liveVC.roomStyleItem.warningStrColor = COLOR_WITH_16BAND_RGB(0x992926);
    
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

    // 立即私密按钮
    self.playVC.liveVC.cameraBtn.hidden = NO;
    [self.playVC.liveVC.cameraBtn setImage:[UIImage imageNamed:@"Live_Public_Vip_Invite_Btn"] forState:UIControlStateNormal];
    //    [self.playVC.liveVC.cameraBtn addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];

    // 礼物按钮
    [self.playVC.giftBtn setImage:[UIImage imageNamed:@"Live_Public_Vip_gift_btn"] forState:UIControlStateNormal];
    // 输入栏目
    [self.playVC.chatBtn setImage:[UIImage imageNamed:@"Live_Public_Vip_Btn_Chat"]];
    // 返点界面
    self.playVC.liveVC.rewardedBgView.backgroundColor = COLOR_WITH_16BAND_RGB(0x5D0E86);
    // 视频播放界面
    //        self.playVC.liveVC.videoBgImageView.backgroundColor = self.view.backgroundColor;

    // 聊天输入框
    [self.playVC.liveSendBarView.sendBtn setImage:[UIImage imageNamed:@"Live_Public_Vip_Send_Btn"] forState:UIControlStateNormal];
    self.playVC.liveSendBarView.louderBtnImage = [UIImage imageNamed:@"Live_Public_Vip_Pop_Btn"];
    self.playVC.liveSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB(0xbaac3f);
    self.playVC.liveSendBarView.inputBackGroundImageView.image = [UIImage imageNamed:@"Public_Input_icon"];
    self.playVC.liveSendBarView.sendBarBgImageView.image = [UIImage imageNamed:@"Live_Public_Vip_SendBar_bg"];
    self.playVC.liveSendBarView.inputTextField.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
    // 隐藏表情按钮
    self.playVC.liveSendBarView.emotionBtnWidth.constant = 0;
}

- (void)setupHeaderImageView {
    // 初始化收藏 观众人数
    self.followAndHomepageView.layer.cornerRadius = 13;

    // 初始化观众席
    self.audienceSuperView.layer.cornerRadius = 5;
    self.audienceSuperView.layer.borderWidth = 1;
    self.audienceSuperView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xf5df9b).CGColor;
    self.audienceNumView.layer.borderWidth = 1;
    self.audienceNumView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xf5df9b).CGColor;

    // 初始化观众按钮
    if (self.liveRoom.imLiveRoom.favorite) {
        self.followBtnWidth.constant = 0;
    }

    // 直播间类型资费提示
    self.tipView = [[ChardTipView alloc] init];
    self.tipView.gotBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x5d0e86);

    [self.tipView setTipWithRoomPrice:self.liveRoom.imLiveRoom.roomPrice
                              roomTip:NSLocalizedStringFromSelf(@"VIP_PUBLIC_TIP")
                           creditText:NSLocalizedStringFromSelf(@"CREDIT_TIP")];
    [self.view addSubview:self.tipView];
    [self.roomTypeImageView sizeToFit];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roomTypeImageView.mas_bottom).offset(2);
        make.width.equalTo(@(self.roomTypeImageView.frame.size.width));
        make.left.equalTo(@13);
    }];

    // 图片点击事件
    WeakObject(self, weakSelf);
    [self.roomTypeImageView addTapBlock:^(id obj) {

        if (!weakSelf.isTipShow) {
            weakSelf.hidenTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                   target:weakSelf
                                                                 selector:@selector(hidenChardTip:)
                                                                 userInfo:nil
                                                                  repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:weakSelf.hidenTimer forMode:NSRunLoopCommonModes];
            [weakSelf.view bringSubviewToFront:weakSelf.tipView];
            weakSelf.tipView.hidden = NO;
            weakSelf.isTipShow = YES;
        }
    }];

    // 是否第一次进入该类型直播间 显示资费提示
    BOOL haveCome = [self.firstManager getThisTypeHaveCome:@"Public_VIP_Join"];
    if (haveCome) {
        [self.tipView hiddenChardTip];
    } else {
        [self.firstManager comeinLiveRoomWithType:@"Public_VIP_Join" HaveComein:YES];
    }

    // 更新头部直播间数据
    [self setupHeadViewInfo];
}

// 更新头部直播间数据
- (void)setupHeadViewInfo {
    if (self.liveRoom.userName.length > 0) {
        [self.homePageBtn setTitle:self.liveRoom.userName forState:UIControlStateNormal];
    } else {
        [self.homePageBtn setTitle:self.liveRoom.httpLiveRoom.nickName forState:UIControlStateNormal];
    }
    NSString *audienceNum = [NSString stringWithFormat:@"(%d/%d)", self.liveRoom.imLiveRoom.fansNum, self.liveRoom.imLiveRoom.maxFansiNum];
    self.audienNumLabel.text = audienceNum;
}

#pragma mark - 网络请求

// 获取观众列表
- (void)setupAudienView {

    LiveFansListRequest *request = [[LiveFansListRequest alloc] init];
    request.roomId = self.liveRoom.roomId;
    request.start = 0;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg,
                              NSArray<ViewerFansItemObject *> *_Nullable array) {

        NSLog(@"PublicViewController::LiveFansListRequest( [请求观众列表], success : %d, errnum : %ld, errmsg : %@, array : %u )", success, (long)errnum, errmsg, (unsigned int)array.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {

                [self.audienceArray removeAllObjects];
                for (ViewerFansItemObject *item in array) {
                    AudienModel *model = [[AudienModel alloc] init];
                    model.userId = item.userId;
                    model.nickName = item.nickName;
                    model.photoUrl = item.photoUrl;
                    model.mountId = item.mountId;
                    model.mountUrl = item.mountUrl;
                    model.level = item.level;
                    [self.audienceArray addObject:model];

                    if (array.count == self.audienceArray.count) {
                        self.audienceView.audienceArray = self.audienceArray;
                        NSString *audienceNum = [NSString stringWithFormat:@"(%u/%d)", (unsigned int)array.count, self.liveRoom.imLiveRoom.maxFansiNum];
                        self.audienNumLabel.text = audienceNum;
                    }
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - PlayViewControllerDelegate
- (void)pushToAddCredit:(PlayViewController *)vc {
    [self.navigationController pushViewController:[LiveModule module].addCreditVc animated:YES];
}

#pragma mark - IM回调

- (void)onRecvEnterRoomNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl riderId:(NSString *_Nonnull)riderId riderName:(NSString *_Nonnull)riderName riderUrl:(NSString *_Nonnull)riderUrl fansNum:(int)fansNum honorImg:(NSString *_Nonnull)honorImg {
    NSLog(@"PublicViewController::onRecvEnterRoomNotice( [接收观众进入直播间通知] ) roomId : %@, userId : %@, nickName : %@, photoUrl : %@, riderId : %@, riderName : %@, riderUrl : %@, fansNum : %d", roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 刷观众列表
        [self setupAudienView];
    });
}

- (void)onRecvLeaveRoomNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl fansNum:(int)fansNum {
    NSLog(@"PublicViewController::onRecvLeaveRoomNotice( [接收观众退出直播间通知] ) roomId : %@, userId : %@, nickName : %@, photoUrl : %@, fansNum : %d", roomId, userId, nickName, photoUrl, fansNum);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupAudienView];
    });
}

#pragma mark - 按钮事件
- (IBAction)hidenChardTip:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:BroadcastClickBroadcastInfo eventCategory:EventCategoryBroadcast];
    self.tipView.hidden = YES;
    if (self.hidenTimer) {
        [self.hidenTimer invalidate];
        self.hidenTimer = nil;
    }
    self.isTipShow = NO;
}

- (IBAction)pushLiveHomePage:(id)sender {
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] init];
    listViewController.anchorId = self.liveRoom.userId;
    listViewController.enterRoom = 0;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (IBAction)followLiverAction:(id)sender {
     [[LiveModule module].analyticsManager reportActionEvent:BroadcastClickFollow eventCategory:EventCategoryBroadcast];
    SetFavoriteRequest *request = [[SetFavoriteRequest alloc] init];
    request.userId = self.liveRoom.userId;
    request.roomId = self.liveRoom.roomId;
    request.isFav = YES;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.followBtnWidth.constant = 0;
                //                [self.playVC.liveVC addAudienceFollowLiverMessage:self.playVC.loginManager.loginItem.nickName];
            } else {
                [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:NSLocalizedStringFromSelf(@"FOLLOW_FAIL")];
            }
            NSLog(@"PublicViewController::followLiverAction( success : %d, errnum : %ld, errmsg : %@ )", success, (long)errnum, errmsg);
        });
    };
    [self.sessionManager sendRequest:request];
}

- (IBAction)showAudienceDetail:(id)sender {
    
}

- (IBAction)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
