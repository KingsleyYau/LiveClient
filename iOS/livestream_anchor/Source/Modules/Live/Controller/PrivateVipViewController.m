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
#import "LiveModule.h"
#import "RoomTypeIsFirstManager.h"

@interface PrivateVipViewController () <PrivateViewControllerDelegate, TalentOnDemandVCDelegate>
@property (strong) PrivateViewController *vc;
@property (strong) TalentOnDemandViewController *talentVC;
@property (nonatomic, strong) UIButton *backBtn;
#pragma mark - 直播间管理器
// 是否第一次进类型直播间管理器
@property (nonatomic, strong) RoomTypeIsFirstManager *firstManager;

@property (nonatomic, assign) BOOL haveCome;
@end

@implementation PrivateVipViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"PrivateVipViewController::initCustomParam( self : %p )", self);
    
    self.firstManager = [RoomTypeIsFirstManager manager];
    
    self.vc = [[PrivateViewController alloc] initWithNibName:nil bundle:nil];
    self.vc.privateDelegate = self;
    [self addChildViewController:self.vc];
    
    self.talentVC = [[TalentOnDemandViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.talentVC];
}

- (void)dealloc {
    NSLog(@"PrivateVipViewController::dealloc( self : %p )", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.talentVC getTalentList:self.liveRoom.roomId];
    
    self.haveCome = [self.firstManager getThisTypeHaveCome:@"Private_VIP_Join"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.liveRoom.superView = self.view;
    self.liveRoom.superController = self;
    
    self.talentVC.liveRoom = self.liveRoom;
    self.talentVC.delegate = self;
}

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
    
    [self.view addSubview:self.talentVC.view];
    [self.talentVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(220));
    }];
}

- (void)setUpLiveRoomType:(PrivateViewController *)vc {
    // 连击礼物
    self.vc.playVC.liveVC.roomStyleItem.comboViewBgImage = [UIImage imageNamed:@"Live_Private_Vip_Bg_Combo"];
    // 座驾背景
    self.vc.playVC.liveVC.roomStyleItem.riderBgColor = Color(255, 109, 0, 0.7);
    self.vc.playVC.liveVC.roomStyleItem.driverStrColor = Color(255, 255, 255, 1);
    // 弹幕
    self.vc.playVC.liveVC.roomStyleItem.barrageBgColor =  Color(37, 37, 37, 0.9);
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
 
    // 礼物按钮
    [self.vc.playVC.giftBtn setImage:[UIImage imageNamed:@"Live_Private_Vip_Btn_Gift"] forState:UIControlStateNormal];
    
    // 隐藏立即私密邀请控件
    self.vc.playVC.liveVC.startOneView.backgroundColor = [UIColor clearColor];
    
    // 聊天输入框
    self.vc.playVC.liveSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB(0x9b7930);
    self.vc.playVC.liveSendBarView.inputTextField.textColor = [UIColor whiteColor];
}

#pragma mark - 按钮事件
- (IBAction)talentAction:(id)sender {
    
    [[LiveModule module].analyticsManager reportActionEvent:PrivateBroadcastClickTalent eventCategory:EventCategoryBroadcast];
    // 隐藏底部输入框
    [self.vc.playVC hiddenBottomView];
    
    [self.view layoutIfNeeded];
    [self.talentVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-220);
    }];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.backBtn.hidden = NO;
                     }];
    

}

#pragma mark - TalentOnDemandVCDelegate
- (void)talentOnDemandVCCancelButtonDid {
    [self.vc.playVC showBottomView];
    
    [self.view layoutIfNeeded];
    [self.talentVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
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
    UIViewController *vc = [LiveModule module].addCreditVc;
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
