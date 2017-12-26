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
    self.vc.delegate = self;
    [self addChildViewController:self.vc];
    
    self.talentVC = [[TalentOnDemandViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.talentVC];
}

- (void)dealloc {
    NSLog(@"PrivateVipViewController::dealloc( self : %p )", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.talentVC.liveRoom = self.liveRoom;
    self.talentVC.delegate = self;
    
    self.liveRoom.superView = self.view;
    self.liveRoom.superController = self;
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
    // 弹幕
    self.vc.playVC.liveVC.roomStyleItem.barrageBgColor =  Color(61, 51, 44, 0.9);//Color(83, 13, 120, 0.9);
    // 消息列表界面
    self.vc.playVC.liveVC.roomStyleItem.nameColor = COLOR_WITH_16BAND_RGB(0Xffd205);
    self.vc.playVC.liveVC.roomStyleItem.followStrColor = COLOR_WITH_16BAND_RGB(0XFF5ABB);
    self.vc.playVC.liveVC.roomStyleItem.sendStrColor = COLOR_WITH_16BAND_RGB(0XFFD205);
    self.vc.playVC.liveVC.roomStyleItem.chatStrColor = [UIColor whiteColor];
    self.vc.playVC.liveVC.roomStyleItem.announceStrColor = COLOR_WITH_16BAND_RGB(0x0cd7de);
    self.vc.playVC.liveVC.roomStyleItem.riderStrColor = COLOR_WITH_16BAND_RGB(0xffd205);
    self.vc.playVC.liveVC.roomStyleItem.warningStrColor = COLOR_WITH_16BAND_RGB(0x992926);
}

- (void)onSetupViewController:(PrivateViewController *)vc {
    // 标题背景
    self.vc.bgImageView.image = [UIImage imageNamed:@"Live_Private_Vip_Bg_Bottom"];
    // 房间类型
    self.vc.roomTypeImageView.image = [UIImage imageNamed:@"Live_Private_Vip_Bg_Type"];
    [self.vc.roomTypeImageView sizeToFit];
    // 底部背景
    self.vc.titleBackGroundView.image = [UIImage imageNamed:@"Live_Private_Vip_Bg_Title"];
    // 头像背景
    self.vc.manHeadBgImageView.image = [UIImage imageNamed:@"Live_Private_Vip_Bg_Man_Head"];
    self.vc.ladyHeadBgImageView.image = [UIImage imageNamed:@"Live_Private_Vip_Bg_Lady_Head"];
    // 关注按钮
    [self.vc.followBtn setImage:[UIImage imageNamed:@"Live_Private_Vip_Btn_Follow"] forState:UIControlStateNormal];
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
    // 房间类型提示
    self.vc.tipView.gotBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0X5D0E86);
    [self.vc.tipView setTipWithRoomPrice:self.liveRoom.imLiveRoom.roomPrice
                                 roomTip:NSLocalizedStringFromSelf(@"VIP_PRIVATE_TIP")
                              creditText:NSLocalizedStringFromSelf(@"CREDIT_TIP")];
    [self.vc.tipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.vc.roomTypeImageView.frame.size.width));
    }];
    
    // 聊天输入框
    [self.vc.playVC.liveSendBarView.sendBtn setImage:[UIImage imageNamed:@"Privatevip_Send_Btn"] forState:UIControlStateNormal];
    self.vc.playVC.liveSendBarView.louderBtnImage = [UIImage imageNamed:@"Privatevip_Pop_Btn"];
    self.vc.playVC.liveSendBarView.placeholderColor = COLOR_WITH_16BAND_RGB(0x9b7930);
    self.vc.playVC.liveSendBarView.inputBackGroundImageView.image = [UIImage imageNamed:@"Privatevip_Input_icon"];
    self.vc.playVC.liveSendBarView.sendBarBgImageView.image = [UIImage imageNamed:@"Live_Private_Vip_SendBar_bg"];
    self.vc.playVC.liveSendBarView.inputTextField.textColor = [UIColor whiteColor];
    // 显示表情按钮
    self.vc.playVC.liveSendBarView.emotionBtnWidth.constant = 30;
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
