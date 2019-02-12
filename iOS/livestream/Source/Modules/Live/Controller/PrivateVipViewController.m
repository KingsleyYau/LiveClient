//
//  PrivateVipViewController.m
//  livestream
//
//  Created by Max on 2017/9/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PrivateVipViewController.h"

#import "PrivateViewController.h"
#import "TalentOnDemandViewController.h"
#import "StartHangOutTipView.h"
#import "LiveModule.h"
#import "RoomTypeIsFirstManager.h"
#import "LSAddCreditsViewController.h"

@interface PrivateVipViewController () <PrivateViewControllerDelegate, TalentOnDemandVCDelegate, StartHangOutTipViewDelegate>
@property (strong) PrivateViewController *vc;
@property (strong) UINavigationController *navVC;
@property (strong) TalentOnDemandViewController *talentVC;
@property (nonatomic, strong) UIButton *backBtn;
#pragma mark - 直播间管理器
// 是否第一次进类型直播间管理器
@property (nonatomic, strong) RoomTypeIsFirstManager *firstManager;

@property (nonatomic, assign) BOOL haveCome;

@property (nonatomic, strong) UIImageView * talentIcon;

// Hangout提示框
@property (nonatomic, strong) StartHangOutTipView *hangoutTipView;
@property (nonatomic, strong) UIButton *closeHangoutTipBtn;
@end

@implementation PrivateVipViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PrivateVipViewController::initCustomParam( self : %p )", self);
    
    self.firstManager = [RoomTypeIsFirstManager manager];
    
    self.vc = [[PrivateViewController alloc] initWithNibName:nil bundle:nil];
    self.vc.vcDelegate = self;
    [self addChildViewController:self.vc];
    
    self.talentVC = [[TalentOnDemandViewController alloc] initWithNibName:nil bundle:nil];
    self.talentVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 300);
    self.navVC = [[UINavigationController alloc] initWithRootViewController:self.talentVC];
     self.navVC.navigationBar.barTintColor = [UIColor blackColor];
     self.navVC.view.frame = CGRectMake(0, SCREEN_HEIGHT - self.talentVC.view.frame.size.height, SCREEN_WIDTH, self.talentVC.view.frame.size.height);
}

- (void)dealloc {
    NSLog(@"PrivateVipViewController::dealloc( self : %p )", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHangOutTipView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.talentVC getTalentList:self.liveRoom.roomId];
    
    self.haveCome = [self.firstManager getThisTypeHaveCome:@"Private_VIP_Join"];
    if (self.haveCome) {
        [self.vc.tipView hiddenChardTip];
    } else {
        self.vc.tipView.hidden = NO;
        [self.firstManager comeinLiveRoomWithType:@"Private_VIP_Join" HaveComein:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.liveRoom.superView = self.view;
    self.liveRoom.superController = self;
    
    self.talentVC.liveRoom = self.liveRoom;
    self.talentVC.delegate = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showTalentList) name:@"showTalentList" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"showTalentList" object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    CGFloat y = 150;
//    CGFloat x = ([UIScreen mainScreen].bounds.size.width - 310) / 2;
//    self.hangoutTipView.frame = CGRectMake(x, y, 310, 228);
}

#pragma mark 接收showTalentList 通知
- (void)showTalentList {
    [self talentAction:nil];
}

#pragma mark 设置界面
- (void)setupContainView {
    [super setupContainView];

    self.vc.liveRoom = self.liveRoom;
    [self.view addSubview:self.vc.view];
    [self.vc.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.backBtn = [[UIButton alloc] init];
    self.backBtn.hidden = YES;
    [self.view addSubview:self.backBtn];
    [self.backBtn addTarget:self action:@selector(hiddenTalentView) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.navVC.view];
    [self addChildViewController: self.navVC];
    [self.navVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(self.navVC.view.frame.size.height));
    }];
}

#pragma mark - PrivateViewControllerDelegate
- (void)setUpLiveRoomType:(PrivateViewController *)vc {
    // 连击礼物
    self.vc.playVC.liveVC.roomStyleItem.comboViewBgImage = [UIImage imageNamed:@"Live_Private_Vip_Bg_Combo"];
    // 座驾背景
    self.vc.playVC.liveVC.roomStyleItem.riderBgColor = Color(255, 109, 0, 0.7);
    self.vc.playVC.liveVC.roomStyleItem.driverStrColor = Color(255, 255, 255, 1);
    // 弹幕
    self.vc.playVC.liveVC.roomStyleItem.barrageBgColor =  Color(37, 37, 37, 0.9);//Color(83, 13, 120, 0.9);
    // 消息列表界面
    self.vc.playVC.liveVC.roomStyleItem.myNameColor = Color(255, 109, 0, 1);
    self.vc.playVC.liveVC.roomStyleItem.liverNameColor = Color(92, 222, 126, 1);
    self.vc.playVC.liveVC.roomStyleItem.liverTypeImage = [UIImage imageNamed:@"Live_Private_Vip_Broadcaster"];
    self.vc.playVC.liveVC.roomStyleItem.followStrColor = Color(249, 231, 132, 1);
    self.vc.playVC.liveVC.roomStyleItem.sendStrColor = Color(255, 210, 5, 1);
    self.vc.playVC.liveVC.roomStyleItem.chatStrColor = Color(255, 255, 255, 1);
    self.vc.playVC.liveVC.roomStyleItem.announceStrColor = Color(255, 109, 0, 1);
    self.vc.playVC.liveVC.roomStyleItem.riderStrColor = Color(255, 109, 0, 1);
    self.vc.playVC.liveVC.roomStyleItem.warningStrColor = Color(255, 77, 77, 1);
    self.vc.playVC.liveVC.roomStyleItem.textBackgroundViewColor = Color(191, 191, 191, 0.17);
}

- (void)onSetupViewController:(PrivateViewController *)vc {
    // 返点界面
    self.vc.playVC.liveVC.rewardedBgView.backgroundColor = COLOR_WITH_16BAND_RGB(0X644C3B);//Color(61, 51, 44, 1.0);
    // 才艺点播
    self.vc.playVC.talentBtnWidth.constant = 36;
    self.vc.playVC.talentBtnTailing.constant = -10;
    [self.vc.playVC.talentBtn addTarget:self action:@selector(talentAction:) forControlEvents:UIControlEventTouchUpInside];
    // 礼物按钮
    [self.vc.playVC.giftBtn setImage:[UIImage imageNamed:@"Live_Private_Vip_Btn_Gift"] forState:UIControlStateNormal];
    // 输入栏目
    [self.vc.playVC.chatBtn setImage:[UIImage imageNamed:@"Live_Private_Vip_Btn_Chat"]];
    
    
    self.talentIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 36, 36)];
    self.talentIcon.userInteractionEnabled = YES;
    [self.talentIcon addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(talentAction:)]];
    [self.vc.playVC.talentBtn addSubview:self.talentIcon];

    NSMutableArray * array = [NSMutableArray array];
    for (int i = 1; i <= 12; i++) {
        [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"TalentIcon%d",i]]];
    }
    for (int i = 1; i <= 6; i++) {
        [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"TalentIcon%d",12]]];
    }
    
    self.talentIcon.animationImages = array;
    self.talentIcon.animationDuration = 0.9;
    self.talentIcon.animationRepeatCount = 5;
    [self.talentIcon startAnimating];
    [self performSelector:@selector(hidenTalentIcon) withObject:self afterDelay:4.5];
    
    // 房间类型提示
//    self.vc.tipView.gotBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0X5D0E86);
//    [self.vc.tipView setTipWithRoomPrice:self.liveRoom.imLiveRoom.roomPrice
//                                 roomTip:NSLocalizedStringFromSelf(@"VIP_PRIVATE_TIP")
//                              creditText:NSLocalizedStringFromSelf(@"CREDIT_TIP")];
//    [self.vc.tipView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@(self.vc.roomTypeImageView.frame.size.width * 1.5));
//    }];
    
    // 隐藏立即私密邀请控件
    self.vc.playVC.liveVC.startOneView.backgroundColor = [UIColor clearColor];
    
    // 聊天输入框
    [self.vc.playVC.liveSendBarView.sendBtn setImage:[UIImage imageNamed:@"Privatevip_Send_Btn"] forState:UIControlStateNormal];
    self.vc.playVC.liveSendBarView.louderBtnImage = [UIImage imageNamed:@"Privatevip_Pop_Btn"];
    self.vc.playVC.liveSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB(0x9b7930);
    self.vc.playVC.liveSendBarView.inputBackGroundImageView.image = [UIImage imageNamed:@"Privatevip_Input_icon"];
    self.vc.playVC.liveSendBarView.sendBarBgImageView.image = [UIImage imageNamed:@"Live_Private_Vip_SendBar_bg"];
    self.vc.playVC.liveSendBarView.inputTextField.textColor = [UIColor whiteColor];
    // 显示表情按钮
    self.vc.playVC.liveSendBarView.emotionBtnWidth.constant = 30;
    
    // 消息列表顶部间隔
    self.vc.playVC.msgSuperTabelTop = 6;
    self.vc.playVC.liveVC.barrageViewTop.constant = -6;
}

- (void)showHangoutTipView:(PrivateViewController *)vc {
    [self showHangoutTipView];
}

- (void)hidenTalentIcon {
    self.talentIcon.hidden = YES;
}

- (void)setupHangOutTipView {
    self.hangoutTipView = [[StartHangOutTipView alloc] init];
    self.hangoutTipView.hidden = YES;
    self.hangoutTipView.delegate = self;
//    self.hangoutTipView.layer.shadowColor = Color(0, 0, 0, 1).CGColor;
//    self.hangoutTipView.layer.shadowOffset = CGSizeMake(0, 0);
//    self.hangoutTipView.layer.shadowRadius = 1;
//    self.hangoutTipView.layer.shadowOpacity = 0.1;
//    [self.view addSubview:self.hangoutTipView];
    
    self.closeHangoutTipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeHangoutTipBtn.hidden = YES;
    [self.closeHangoutTipBtn addTarget:self action:@selector(removeHangoutTip:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeHangoutTipBtn];
    [self.closeHangoutTipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)showHangoutTipView {
    self.closeHangoutTipBtn.hidden = NO;
    self.hangoutTipView.hidden = NO;
    [self.hangoutTipView showMainHangoutTip:self.navigationController.view];
}

- (void)removeHangoutTip:(id)sender {
    self.closeHangoutTipBtn.hidden = YES;
    self.hangoutTipView.hidden = YES;
}

#pragma mark - 按钮事件
- (IBAction)talentAction:(id)sender {
    
    [[LiveModule module].analyticsManager reportActionEvent:PrivateBroadcastClickTalent eventCategory:EventCategoryBroadcast];
    // 隐藏底部输入框
    [self.vc.playVC hiddenBottomView];
    [self.talentVC getTalentList:self.liveRoom.roomId];
    [self.view layoutIfNeeded];
    [self.navVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-self.navVC.view.frame.size.height);
    }];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.backBtn.hidden = NO;
                     }];
    

}

#pragma mark - StartHangOutTipViewDelegate
- (void)requestHangout:(StartHangOutTipView *)view {
    [[LiveModule module].analyticsManager reportActionEvent:InviteHangOut eventCategory:EventCategoryBroadcast];
    // TODO:邀请当前主播hangout
    [self.vc.playVC.liveVC inviteAnchorWithHangout:nil anchorId:self.liveRoom.userId anchorName:self.liveRoom.userName];
    [self removeHangoutTip:nil];
}

- (void)closeHangoutTip:(StartHangOutTipView *)view {
    [self removeHangoutTip:nil];
}

#pragma mark - TalentOnDemandVCDelegate
- (void)talentOnDemandVCCancelButtonDid {
    [self.vc.playVC showBottomView];
    
    [self.view layoutIfNeeded];
    [self.navVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom);
    }];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                        [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.backBtn.hidden = YES;
                     }];
    
}

- (void)hiddenTalentView {
    [self talentOnDemandVCCancelButtonDid];
}

- (void)onSendtalentOnDemandMessage:(NSAttributedString *)message {
    [self.vc.playVC.liveVC addTips:message];
}

- (void)pushToRechargeCredit {
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
