//
//  PublicViewController.m
//  livestream
//
//  Created by randy on 2017/8/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PublicViewController.h"

#import "MainViewController.h"

#import "AudienceCell.h"
#import "IMManager.h"
#import "LiveModule.h"
#import "RemberLiveRoomModel.h"
#import "SetFavoriteRequest.h"
#import "LiveFansListRequest.h"
#import "AudienModel.h"
#import "RoomTypeIsFirstManager.h"
#import "LiveRoomCreditRebateManager.h"

#define PageSize 10

@interface PublicViewController ()<IMManagerDelegate,IMLiveRoomManagerDelegate>

// 观众数组
@property(nonatomic, strong) NSMutableArray *audienceArray;

// IM管理器
@property (nonatomic, strong) IMManager *imManager;

@property (nonatomic ,strong) NSTimer * hidenTimer;

@property (nonatomic, assign) BOOL isTipShow;

@property (nonatomic, assign) BOOL isClickGot;

@property (nonatomic, strong) RemberLiveRoomModel *liveRoomModel;

/** 接口管理器 **/
@property (nonatomic, strong) SessionRequestManager *sessionManager;

// 是否第一次进类型直播间管理器
@property (nonatomic, strong) RoomTypeIsFirstManager *firstManager;


@end

@implementation PublicViewController

- (void)initCustomParam {
    self.isTipShow = NO;
    
    self.liveRoomModel = [RemberLiveRoomModel liveRoomModel];
    self.sessionManager = [SessionRequestManager manager];
    self.firstManager = [RoomTypeIsFirstManager manager];
    
    self.audienceArray = [[NSMutableArray alloc] init];
    
    self.imManager = [IMManager manager];
    [self.imManager addDelegate:self];
     [self.imManager.client addDelegate:self];
}

- (void)dealloc {
    NSLog(@"PublicViewController::dealloc()");
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent= NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

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
    
    // 初始化播放界面
    [self setupPlayController];
    // 初始化头部界面
    [self setupHeaderImageView];
    
    // 请求观众席列表
    [self setupAudienView];
}

- (void)setupHeaderImageView {
    // 初始化收藏 观众人数
    self.numShaowView.layer.cornerRadius = 9;
    self.followAndHomepageView.layer.cornerRadius = 10;
    
    if (self.liveRoom.imLiveRoom.favorite) {
        self.followBtnWidth.constant = 0;
    }
    
    // 直播间类型资费提示
    self.tipView = [[ChardTipView alloc] init];
    self.tipView.gotBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x5d0e86);
    
    [self.tipView setTipWithRoomPrice:0 roomTip:NSLocalizedStringFromSelf(@"Public_Tip") creditText:nil];
    [self.view addSubview:self.tipView];
    [self.roomTypeImageView sizeToFit];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roomTypeImageView.mas_bottom).offset(2);
        make.width.equalTo(@(self.roomTypeImageView.width));
        make.left.equalTo(@13);
    }];
    
    // 图片点击事件
    WeakObject(self, weakSelf);
    [self.roomTypeImageView addTapBlock:^(id obj) {
        
        if (!weakSelf.isTipShow) {
            weakSelf.hidenTimer =  [NSTimer scheduledTimerWithTimeInterval:3.0 target:weakSelf selector:@selector(hidenChardTip)
                                                                  userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:weakSelf.hidenTimer forMode:NSRunLoopCommonModes];
            [weakSelf.view bringSubviewToFront:weakSelf.tipView];
            weakSelf.tipView.hidden = NO;
            weakSelf.isTipShow = YES;
        }
    }];
    
    // 是否第一次进入该类型直播间 显示资费提示
    BOOL haveCome = [self.firstManager getThisTypeHaveCome:self.liveRoom.roomType];
    if (haveCome) {
        [self.tipView hiddenChardTip];
        
    } else {
        [self.firstManager comeinLiveRoomWithType:self.liveRoom.roomType HaveComein:YES];
    }
    
    // 更新头部直播间数据
    [self setupHeadViewInfo];
}

- (void)setupPlayController {
    // 输入栏
    self.playVC = [[PlayViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.playVC];
    self.playVC.liveRoom = self.liveRoom;
    
    [self.view addSubview:self.playVC.view];
    [self.playVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleBackGroundView.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.playVC.liveVC bringSubviewToFrontFromView:self.view];
    [self.view bringSubviewToFront:self.playVC.chooseGiftListView];
    self.playVC.chooseGiftListView.top = SCREEN_HEIGHT;

    // 立即私密按钮
    self.playVC.liveVC.cameraBtn.hidden = NO;
    [self.playVC.liveVC.cameraBtn addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 直播间风格
    self.playVC.liveVC.roomStyleItem = [[RoomStyleItem alloc] init];
    
    // 连击礼物
    self.playVC.liveVC.roomStyleItem.comboViewBgImage = [UIImage imageNamed:@"Live_Public_Bg_Combo"];
    
    // 弹幕
    self.playVC.liveVC.roomStyleItem.barrageBgColor = Color(255, 255, 255, 0.9);
    
    // 聊天列表
    self.playVC.liveVC.roomStyleItem.nameColor = COLOR_WITH_16BAND_RGB(0XEC0212);
    self.playVC.liveVC.roomStyleItem.followStrColor = COLOR_WITH_16BAND_RGB(0X0CD7DE);
    self.playVC.liveVC.roomStyleItem.sendStrColor = COLOR_WITH_16BAND_RGB(0XDF3CE9);
    self.playVC.liveVC.roomStyleItem.chatStrColor = [UIColor blackColor];
    self.playVC.liveVC.roomStyleItem.announceStrColor = COLOR_WITH_16BAND_RGB(0x0cd7de);
    self.playVC.liveVC.roomStyleItem.riderStrColor = COLOR_WITH_16BAND_RGB(0xffd205);
    
    // 邀请按钮
    [self.playVC.liveVC.cameraBtn setImage:[UIImage imageNamed:@"Live_Public_Btn_Camera_Invite"] forState:UIControlStateNormal];
    
    // 返点界面
    self.playVC.liveVC.rewardedBgView.backgroundColor = COLOR_WITH_16BAND_RGB(0x5D0E86);
    
    // 视频播放界面
//    self.playVC.liveVC.videoBgImageView.backgroundColor = self.view.backgroundColor;
    
    // 聊天输入框
    [self.playVC.liveSendBarView.sendBtn setImage:[UIImage imageNamed:@"Public_Send_Btn"] forState:UIControlStateNormal];
    self.playVC.liveSendBarView.louderBtnImage = [UIImage imageNamed:@"Pubilc_Pop_Btn"];
    self.playVC.liveSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB(0xb296df);
    self.playVC.liveSendBarView.inputBackGroundImageView.image = [UIImage imageNamed:@"Public_Input_icon"];
    self.playVC.liveSendBarView.sendBarBgImageView.image = [UIImage imageNamed:@"Live_Public_SendBar_bg"];
    
    // 隐藏表情按钮
    self.playVC.liveSendBarView.emotionBtnWidth.constant = 0;
}

// 获取观众列表
- (void)setupAudienView {
    
    LiveFansListRequest *request = [[LiveFansListRequest alloc] init];
    request.roomId = self.liveRoom.roomId;
    request.start = 0;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg,
                              NSArray<ViewerFansItemObject *> * _Nullable array) {
        
        NSLog(@"PublicViewController::LiveFansListRequest [请求观众列表] success : %d, errnum : %d, errmsg : %@, array : %@",success, errnum, errmsg, array);
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
                        [self.peopleNumBtn setTitle:[NSString stringWithFormat:@" %d",array.count] forState:UIControlStateNormal];
                    }
                }
                
            }
        });
    };
    [self.sessionManager sendRequest:request];
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
- (IBAction)cameraAction:(id)sender {
    MainViewController *vc = (MainViewController *)[[LiveModule module] moduleViewController];
    vc.liveRoom = self.liveRoom;
    vc.liveRoom.roomType = LiveRoomType_Private;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pushLiveHomePage:(id)sender {
    
}

- (IBAction)followLiverAction:(id)sender {
    SetFavoriteRequest *request = [[SetFavoriteRequest alloc] init];
    request.userId = self.liveRoom.userId;
    request.roomId = self.liveRoom.roomId;
    request.isFav = YES;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.followBtnWidth.constant = 0;
                [self.playVC.liveVC addAudienceFollowLiverMessage:self.playVC.loginManager.loginItem.nickName];
            }
            NSLog(@"PublicViewController::followLiverAction success:%d errnum:%ld errmsg:%@",success,(long)errnum,errmsg);
        });
    };
    [self.sessionManager sendRequest:request];
}

- (IBAction)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 请求数据逻辑
- (void)sendExitRequest {
    
}

// 更新头部直播间数据
- (void)setupHeadViewInfo {
    [self.homePageBtn setTitle:self.liveRoom.httpLiveRoom.nickName forState:UIControlStateNormal];
    [self.peopleNumBtn setTitle:[NSString stringWithFormat:@" %d",self.liveRoom.imLiveRoom.fansNum] forState:UIControlStateNormal];
}

#pragma mark - IM回调
- (void)onRecvEnterRoomNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl riderId:(NSString *_Nonnull)riderId riderName:(NSString *_Nonnull)riderName riderUrl:(NSString *_Nonnull)riderUrl fansNum:(int)fansNum {
    NSLog(@"PublicViewController::onRecvEnterRoomNotice( [接收观众进入直播间通知] ) roomId : %@, userId : %@, nickName : %@, photoUrl : %@, riderId : %@, riderName : %@, riderUrl : %@, fansNum : %d",roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum );
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

- (void)onRecvLeavingPublicRoomNotice:(NSString *_Nonnull)roomId err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg {
    NSLog(@"PublicViewController::onRecvLeavingPublicRoomNotice( [接收关闭直播间倒数通知], roomId : %@ )", roomId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 开启关闭倒计时定时器
        
    });
}

- (void)text{
    
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
