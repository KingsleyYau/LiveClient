//
//  PublicVipViewController.m
//  livestream
//
//  Created by randy on 2017/9/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PublicVipViewController.h"
#import "LSMainViewController.h"
#import "LSAddCreditsViewController.h"
#import "AnchorPersonalViewController.h"
#import "HangoutDialogViewController.h"

#import "SetFavoriteRequest.h"
#import "LiveFansListRequest.h"

#import "LiveUrlHandler.h"
#import "LSImageViewLoader.h"
#import "LiveModule.h"
#import "AudienModel.h"

#import "LSLoginManager.h"
#import "RoomTypeIsFirstManager.h"
#import "LSRoomUserInfoManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "LiveGobalManager.h"
#import "LSMinLiveManager.h"

#import "DialogTip.h"
#import "DialogChoose.h"
#import "LSGiftInfoView.h"
#import "StartHangOutTipView.h"

#import "LSPrivateInviteView.h"
#import "LSAnchorDetailCardViewController.h"

@interface PublicVipViewController () <IMManagerDelegate, IMLiveRoomManagerDelegate, InputViewControllerDelegate, HangoutDialogViewControllerDelegate,LSAnchorDetailCardViewControllerDelegate, LSGiftInfoViewDelegate>


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
@property (nonatomic, strong) DialogChoose *closeDialogTipView;

@property (nonatomic, strong) LSImageViewLoader *ladyImageLoader;

// Hangout提示框
@property (nonatomic, strong) StartHangOutTipView *hangoutTipView;
@property (nonatomic, strong) UIButton *closeHangoutTipBtn;

#pragma mark - 用户信息管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;
@property (nonatomic, strong) LSGiftInfoView * giftInfoView;

#pragma mark - 倒计时关闭直播间
@property (strong) LSTimer *timer;
@property (nonatomic, assign) NSInteger timeCount;

@property (weak, nonatomic) IBOutlet UIView *endTimeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) LSAnchorDetailCardViewController *anchorDetailVc;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgShadowTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgShadowHeight;
@property (weak, nonatomic) IBOutlet UIView *roomHeaderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audienceWidth;
@property (weak, nonatomic) IBOutlet UILabel *anchorId;



@end

@implementation PublicVipViewController

- (void)dealloc {
    NSLog(@"PublicVipViewController::dealloc( self : %p )", self);
    
    if (self.closeDialogTipView) {
        [self.closeDialogTipView removeFromSuperview];
    }
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    [self.giftInfoView removeFromSuperview];
    
    [self.timer stopTimer];
}

- (void)initCustomParam {
    [super initCustomParam];
    
    NSLog(@"PublicVipViewController::initCustomParam( self : %p )", self);
    
    // 隐藏导航栏
    self.isShowNavBar = NO;
    // 禁止导航栏后退手势
    self.canPopWithGesture = NO;
    
    self.sessionManager = [LSSessionRequestManager manager];
    self.firstManager = [RoomTypeIsFirstManager manager];
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    self.dialogTipView = [DialogTip dialogTip];
    self.audienceArray = [[NSMutableArray alloc] init];
    
    self.ladyImageLoader = [LSImageViewLoader loader];
    
    self.roomUserInfoManager = [LSRoomUserInfoManager manager];
    
    // 初始化倒数关闭直播间计时器
    self.timer = [[LSTimer alloc] init];
}

- (void)setupContainView {
    [super setupContainView];
    
    // 更新头部直播间数据
    [self setupHeadViewInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.laddyHeadImageView.layer.cornerRadius = self.laddyHeadImageView.frame.size.height / 2;
    self.laddyHeadImageView.layer.borderWidth = 2.0f;
    self.laddyHeadImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.laddyHeadImageView.layer.masksToBounds = YES;
    
    self.liveRoom.superView = self.view;
    self.liveRoom.superController = self;
    
    self.endTimeView.layer.cornerRadius = self.endTimeView.tx_height / 2;
    self.endTimeView.layer.masksToBounds = YES;
    self.endTimeView.hidden = YES;
    
    self.giftInfoView = [[LSGiftInfoView alloc] init];
    [self.giftInfoView.infoHeadBgImageView setImage:[UIImage imageNamed:@"Live_Public_Gift_HeadBg"]];
    self.giftInfoView.delegate = self;
    
    // 初始化播放界面
    [self setupPlayController];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [LSMinLiveManager manager].liveVC = self;
    [LSMinLiveManager manager].userId = self.liveRoom.userId;
    
    // 设置状态栏为白色字体
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    [UIApplication sharedApplication].statusBarHidden = YES;
    // 请求同步观众席列表
    [self setupAudienView];
    UIImage *backImage = [UIImage imageNamed:@"Live_Public_ShrankRoom"];
//    if ([LiveGobalManager manager].liveRoom.canShowMinLiveView) {
//        backImage = [UIImage imageNamed:@"Live_Public_ShrankRoom"];
//    }else {
//        backImage = [UIImage imageNamed:@"VIPLive_Close"];
//    }
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
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
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)showHangoutTipView {
    HangoutDialogViewController *vc = [[LiveGobalManager manager] addDialogVc];
    vc.anchorId = self.liveRoom.userId;
    vc.anchorName = self.liveRoom.userName;
    [vc showhangoutView];
}

#pragma mark - 界面风格初始化
- (void)setupPlayController {
    // 输入栏
    self.playVC = [[LSVIPInputViewController alloc] initWithNibName:nil bundle:nil];
    self.playVC.playDelegate = self;
    [self addChildViewController:self.playVC];
    self.playVC.liveRoom = self.liveRoom;
    // 直播间风格
    self.playVC.roomStyleItem = [[RoomStyleItem alloc] init];
    // 连击礼物
    self.playVC.roomStyleItem.comboViewBgImage = [UIImage imageNamed:@"Live_Public_Bg_Combo"];
    self.playVC.roomStyleItem.comboNumImageName = @"white_";
    // 座驾背景
    self.playVC.roomStyleItem.riderBgColor = Color(255, 109, 0, 0.7);
    self.playVC.roomStyleItem.driverStrColor = Color(255, 255, 255, 1);
    // 弹幕
    self.playVC.roomStyleItem.barrageBgColor = Color(37, 37, 37, 0.9);
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
    self.playVC.roomStyleItem.chooseTopGiftViewBgColor = COLOR_WITH_16BAND_RGB(0xE0000000);
    self.playVC.roomStyleItem.topGiftViewBtnImage = [UIImage imageNamed:@"Live_Public_Gift_Show"];
    // 输入框
    self.playVC.roomStyleItem.popBtnImage = [UIImage imageNamed:@"Send_Pop_Close"];
    self.playVC.roomStyleItem.popBtnSelectImage = [UIImage imageNamed:@"Live_Public_Vip_Pop_Btn"];
    // 礼物列表
    self.playVC.roomStyleItem.giftPageHeadBgImage = [UIImage imageNamed:@"Live_Public_Gift_HeadBg"];
    self.playVC.roomStyleItem.giftPageTipBtnImage = [UIImage imageNamed:@"Live_Public_Gift_InfoBtn"];
    self.playVC.roomStyleItem.giftPageDownBtnImage = [UIImage imageNamed:@"Live_Public_Gift_Down"];
    self.playVC.roomStyleItem.giftPageBgColor = COLOR_WITH_16BAND_RGB(0xE0000000);
    self.playVC.roomStyleItem.giftSegmentTitleColor = COLOR_WITH_16BAND_RGB(0x2a0809);
    self.playVC.roomStyleItem.giftSegmentTitleSelectColor = COLOR_WITH_16BAND_RGB(0xff8685);
    
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
    [self.playVC.liveVC bringSubviewToFrontFromView:self.roomHeaderView];
    
    [self.view bringSubviewToFront:self.playVC.chooseGiftListView];
    CGRect frame = self.playVC.chooseGiftListView.frame;
    frame.origin.y = SCREEN_HEIGHT;
    self.playVC.chooseGiftListView.frame = frame;
}

// 更新头部直播间数据
- (void)setupHeadViewInfo {
    // 计算StatusBar高度
    if (IS_IPHONE_X) {
        self.bgShadowTop.constant = 44;
    } else {
        self.bgShadowTop.constant = 0;
    }
    if (self.liveRoom.userName.length > 0) {
        self.laddyNameLabel.text = self.liveRoom.userName;
    } else {
        self.laddyNameLabel.text = self.liveRoom.httpLiveRoom.nickName;
    }
    [self.ladyImageLoader loadImageFromCache:self.laddyHeadImageView
                                     options:SDWebImageRefreshCached
                                    imageUrl:self.liveRoom.photoUrl
                            placeholderImage:LADYDEFAULTIMG
                               finishHandler:^(UIImage *image){
    }];
    self.anchorId.text = self.liveRoom.userId;
    
    //    NSString *audienceNum = [NSString stringWithFormat:@"(%d/%d)", self.liveRoom.imLiveRoom.fansNum, self.liveRoom.imLiveRoom.maxFansiNum];
}

#pragma mark - 倒数关闭直播间
- (void)changeTimeLabel {
    self.timeLabel.text = [NSString stringWithFormat:@"%lds", (long)self.timeCount];
    self.timeCount -= 1;
    
    if (self.timeCount < 0) {
        // 关闭
        [self.timer stopTimer];
        // 关闭之后，重设计数
        self.timeCount = 0;
    }
}

#pragma mark - 网络请求
// 获取观众列表
- (void)setupAudienView {
    LiveFansListRequest *request = [[LiveFansListRequest alloc] init];
    request.roomId = self.liveRoom.roomId;
    request.start = 0;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg,
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
                    model.image = [UIImage imageNamed:@"Default_Img_Man_Circyle"];
                    model.isHasTicket = item.isHasTicket;
                    [self.audienceArray addObject:model];
                    
                    // 更新并缓存本地观众数据
                    LSUserInfoModel *infoItem = [[LSUserInfoModel alloc] init];
                    infoItem.userId = item.userId;
                    infoItem.nickName = item.nickName;
                    infoItem.photoUrl = item.photoUrl;
                    infoItem.riderId = item.mountId;
                    infoItem.riderName = item.mountUrl;
                    infoItem.userLevel = item.level;
                    infoItem.isAnchor = 0;
                    infoItem.isHasTicket = item.isHasTicket;
                    [self.roomUserInfoManager setAudienceInfoDicL:infoItem];
                }
                // 显示观众列表数列
                self.audienceView.audienceArray = self.audienceArray;
                if (self.audienceArray.count >= 5) {
                    CGFloat audienceWidth = 31 * 6 + 4 * 6;
                    CGFloat maxWidth = screenSize.width - self.headBackgroundView.frame.size.width - 20 - 40 - 10;
                    if (audienceWidth > maxWidth) {
                        self.audienceWidth.constant = maxWidth;
                    }else {
                        self.audienceWidth.constant = audienceWidth;
                    }
                } else {
                    CGFloat audienceWidth = 31 * self.audienceArray.count + (self.audienceArray.count - 1) * 6;
                    CGFloat maxWidth = screenSize.width - self.headBackgroundView.frame.size.width - 20 - 40 - 10;
                    if (audienceWidth > maxWidth) {
                        self.audienceWidth.constant = maxWidth;
                    }else {
                        self.audienceWidth.constant = audienceWidth;
                        
                    }
                    
                }
                
                [self.audienceView.collectionView reloadData];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - PlayViewControllerDelegate
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

- (void)showPubilcHangoutTipView:(LSVIPInputViewController *)vc {
    // 显示hangout提示框
    [self showHangoutTipView];
}

#pragma mark - LSGiftInfoViewDelegate
- (void)didCloseGiftInfoView:(LSGiftInfoView *)infoView {
    [self.giftInfoView removeFromSuperview];
}

#pragma mark - IM回调

- (void)onRecvEnterRoomNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl riderId:(NSString *_Nonnull)riderId riderName:(NSString *_Nonnull)riderName riderUrl:(NSString *_Nonnull)riderUrl fansNum:(int)fansNum honorImg:(NSString *_Nonnull)honorImg isHasTicket:(BOOL)isHasTicket {
    NSLog(@"PublicViewController::onRecvEnterRoomNotice( [接收观众进入直播间通知] ) roomId : %@, userId : %@, nickName : %@, photoUrl : %@, riderId : %@, riderName : %@, riderUrl : %@, fansNum : %d", roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 最小化不处理进出动画
        if (self.viewIsAppear) {
            // 更新并缓存本地观众数据
            LSUserInfoModel *infoItem = [[LSUserInfoModel alloc] init];
            infoItem.userId = userId;
            infoItem.nickName = nickName;
            infoItem.photoUrl = photoUrl;
            infoItem.riderId = riderId;
            infoItem.riderName = riderName;
            infoItem.riderUrl = riderUrl;
            infoItem.isAnchor = 0;
            [self.roomUserInfoManager setAudienceInfoDicL:infoItem];
            
            
            
            AudienModel *model = [[AudienModel alloc] init];
            model.userId = userId;
            model.nickName = nickName;
            model.photoUrl = photoUrl;
            model.mountId = riderId;
            model.mountUrl = riderUrl;
            //        model.level = level;
            model.isHasTicket = isHasTicket;
            
            // 刷观众列表
            self.audienceView.isRoomIn = YES;
            [self addItemIfNotExist:model];
            
            // 显示观众列表数列
            self.audienceView.audienceArray = self.audienceArray;
            [self audienceViewMemberChangeWithAnimation];
            [self.audienceView.collectionView reloadData];
        }
        //        [self setupAudienView];
    });
}


- (void)addItemIfNotExist:(AudienModel *_Nonnull)itemNew {
    bool bFlag = NO;
    
    for (AudienModel *item in self.audienceArray) {
        if ([item.userId isEqualToString:itemNew.userId]) {
            // 已经存在
            bFlag = YES;
            break;
        }
    }
    
    if (!bFlag) {
        // 不存在
        [self.audienceArray addObject:itemNew];
    }
}

- (void)onRecvLeaveRoomNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl fansNum:(int)fansNum {
    NSLog(@"PublicViewController::onRecvLeaveRoomNotice( [接收观众退出直播间通知] ) roomId : %@, userId : %@, nickName : %@, photoUrl : %@, fansNum : %d", roomId, userId, nickName, photoUrl, fansNum);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 最小化不处理进出动画
        if (self.viewIsAppear) {
            int index = -1;
            for (int i = 0; i < self.audienceArray.count; i++) {
                AudienModel *model = self.audienceArray[i];
                if ([model.userId isEqualToString:userId]) {
                    index = i;
                    break;
                }
            }
            self.audienceView.isRoomIn = NO;
            if (index >= 0) {
                // 防止数组越界
                if (index < self.audienceArray.count) {
                    [self.audienceArray removeObjectAtIndex:index];
                    // 显示观众列表数列
                    self.audienceView.audienceArray = self.audienceArray;
                    
                    [self.audienceView audienceLeave:index action:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self audienceViewMemberChangeWithAnimation];
                            
                        });
                    }];
                }
            }
        }
        
    });
}

// 观众进出场动画
- (void)audienceViewMemberChangeWithAnimation {
    if (self.audienceArray.count >= 5) {
        CGFloat audienceWidth = 31 * 6 + 4 * 6;
        CGFloat maxWidth = screenSize.width - self.headBackgroundView.frame.size.width - 20 - 40 - 10;
        [UIView animateWithDuration:0.5 animations:^{
            if (audienceWidth > maxWidth) {
                self.audienceWidth.constant = maxWidth;
            }else {
                self.audienceWidth.constant = audienceWidth;
            }
            [self.audienceView layoutIfNeeded];
        }];
        
        
    } else {
        CGFloat audienceWidth = 31 * self.audienceArray.count + (self.audienceArray.count - 1) * 6;
        CGFloat maxWidth = screenSize.width - self.headBackgroundView.frame.size.width - 20 - 40 - 10;
        [UIView animateWithDuration:0.5 animations:^{
            if (audienceWidth > maxWidth) {
                self.audienceWidth.constant = maxWidth;
            }else {
                self.audienceWidth.constant = audienceWidth;
            }
            [self.audienceView layoutIfNeeded];
        }];
        
    }
}


- (void)onRecvInstantInviteUserNotice:(NSString *_Nonnull)inviteId anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    // TODO:接收主播立即私密邀请通知
    NSLog(@"PublicVipViewController::onRecvInstantInviteUserNotice( [接收主播立即私密邀请通知], inviteId : %@, userId : %@, userName : %@, msg : %@ )", inviteId, anchorId, nickName, msg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[LiveGobalManager manager] canShowInvite:anchorId] ) {
            LSPrivateInviteView *inviteView = [LSPrivateInviteView initPrivateInviteView];
            PrivateInviteItem *item = [[PrivateInviteItem alloc] init];
            item.anchorId = anchorId;
            item.anchorName = nickName;
            item.anchorPhotoUrl = avatarImg;
            inviteView.item = item;
            [inviteView showPrivateViewInView:self.navigationController.view];
        }
        
        
    });
}

- (void)onRecvLeavingPublicRoomNotice:(NSString *)roomId leftSeconds:(int)leftSeconds err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg priv:(ImAuthorityItemObject *)priv {
    NSLog(@"PublicVipViewController::onRecvLeavingPublicRoomNotice( [接收关闭直播间倒数通知], roomId : %@ , leftSeconds : %d ,isHasOneOnOneAuth : %d ,isHasOneOnOneAuth : %d)", roomId, leftSeconds, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([roomId isEqualToString:self.liveRoom.roomId]) {
            
            self.endTimeView.hidden = NO;
            [self.view bringSubviewToFront:self.endTimeView];
            
            self.liveRoom.priv = priv;
            
            self.timeCount = leftSeconds;
            [self.timer startTimer:nil
                      timeInterval:1.0 * NSEC_PER_SEC
                           starNow:YES
                            action:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self changeTimeLabel];
                });
            }];
        }
    });
    
}

#pragma mark - 按钮事件
- (IBAction)pushLiveHomePage:(id)sender {
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
    if (self.closeDialogTipView) {
        [self.closeDialogTipView removeFromSuperview];
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

@end
