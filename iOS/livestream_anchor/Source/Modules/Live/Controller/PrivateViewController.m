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

#import "LSImageViewLoader.h"

#import "LSLoginManager.h"
#import "LiveModule.h"
#import "LSConfigManager.h"
#import "LSAnchorImManager.h"

#import "DialogTip.h"
#import "DialogOK.h"
#import "DialogChoose.h"
#import "TalentDialog.h"

#import "SetFavoriteRequest.h"

#import "RandomGiftModel.h"
#import "UserInfoManager.h"


@interface PrivateViewController () <LiveViewControllerDelegate, PlayViewControllerDelegate, ZBIMManagerDelegate,
                                        ZBIMLiveRoomManagerDelegate, UIAlertViewDelegate>
// IM管理器
@property (nonatomic, strong) LSAnchorImManager *imManager;
// 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;
// 对话框控件
@property (strong) DialogTip *dialogTipView;
// 是否能推流
@property (assign) BOOL canPublish;

@property (nonatomic, strong) DialogChoose *closeDialogTipView;
// 才艺点播提示框
@property (nonatomic, strong) TalentDialog * talentDialog;

@end

@implementation PrivateViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    NSLog(@"PrivateViewController::initCustomParam( self : %p )", self);
    
    self.imManager = [LSAnchorImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    self.loginManager = [LSLoginManager manager];

    self.dialogTipView = [DialogTip dialogTip];
    
    self.talentDialog = [TalentDialog dialog];
    
    self.canPublish = NO;
}

- (void)dealloc {
    NSLog(@"PrivateViewController::dealloc( self : %p )", self);

    if (self.closeDialogTipView) {
        [self.closeDialogTipView removeFromSuperview];
    }
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = Color(255, 255, 255, 0.11);
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
    // 设置状态栏为默认字体
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
  
    // 第一次进入才发送
    if (!self.viewDidAppearEver) {
        // 刷新双向视频状态
        [self setupVideoPreview:NO];
    }
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupContainView {
    [super setupContainView];

    // 视频互动界面
    [self.playVC.liveVC showPreview];
    [self.playVC.liveVC initPlayer];
    
    // 隐藏立即私密邀请控件
    self.playVC.liveVC.startOneView.backgroundColor = [UIColor clearColor];
    
    // 隐藏聊天选人控件
    [self.playVC hiddenchatAudienceView];
    
    // 发送栏目
    self.playVC.inputMessageView.backgroundColor = Color(255, 255, 255, 0.11);
    self.playVC.liveSendBarView.placeholderColor = Color(255, 255, 255, 0.62);
    self.playVC.liveSendBarView.inputTextField.textColor = [UIColor whiteColor];
    self.playVC.liveSendBarView.emotionBtnWidth.constant = 0;
    
    // 礼物按钮
    [self.playVC.giftBtn setImage:[UIImage imageNamed:@"Live_Private_Vip_Btn_Gift"] forState:UIControlStateNormal];
    
    // 通知外部处理
    if ([self.privateDelegate respondsToSelector:@selector(onSetupViewController:)]) {
        [self.privateDelegate onSetupViewController:self];
    }
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
    self.playVC.liveVC.roomStyleItem.comboViewBgImage = [UIImage imageNamed:@"Live_Private_Vip_Bg_Combo"];
    // 座驾背景
    self.playVC.liveVC.roomStyleItem.riderBgColor = Color(255, 109, 0, 0.7);
    self.playVC.liveVC.roomStyleItem.driverStrColor = Color(255, 255, 255, 1);
    // 弹幕
    self.playVC.liveVC.roomStyleItem.barrageBgColor = Color(37, 37, 37, 0.9);
    // 消息列表界面
    self.playVC.liveVC.roomStyleItem.myNameColor = Color(255, 109, 0, 1);
    self.playVC.liveVC.roomStyleItem.userNameColor = Color(255, 109, 0, 1);
    self.playVC.liveVC.roomStyleItem.liverNameColor = Color(92, 222, 126, 1);
    self.playVC.liveVC.roomStyleItem.liverTypeImage = [UIImage imageNamed:@"Live_Private_Vip_Broadcaster"];
    self.playVC.liveVC.roomStyleItem.followStrColor = Color(249, 231, 132, 1);
    self.playVC.liveVC.roomStyleItem.sendStrColor = Color(255, 210, 5, 1);
    self.playVC.liveVC.roomStyleItem.chatStrColor = Color(255, 255, 255, 1);
    self.playVC.liveVC.roomStyleItem.announceStrColor = Color(255, 109, 0, 1);
    self.playVC.liveVC.roomStyleItem.riderStrColor = Color(255, 109, 0, 1);
    self.playVC.liveVC.roomStyleItem.warningStrColor = Color(255, 77, 77, 1);
    self.playVC.liveVC.roomStyleItem.textBackgroundViewColor = Color(191, 191, 191, 0.17);
    
    // 双向视频默认图
    [self.playVC.liveVC.previewImageView setImage:[UIImage imageNamed:@"Interact_Video_Icon"]];

    // 修改高级私密直播间样式
    if ([self.privateDelegate respondsToSelector:@selector(setUpLiveRoomType:)]) {
        [self.privateDelegate setUpLiveRoomType:self];
    }

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

    // 初始化推流
    [self.playVC.liveVC initPublish];
}

#pragma mark - PlayViewControllerDelegate
- (void)onCloseLiveRoom:(PlayViewController *)vc {
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedStringFromSelf(@"EXIT_LIVEROOM_TIP") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"SURE", nil), nil];
    [alertView show];
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (self.liveRoom.roomId.length) {
            // 发送退出直播间
            NSLog(@"PrivateViewController::liveHeadCloseAction [发送退出直播间:%@]",self.liveRoom.roomId);
            [self.imManager leaveRoom:self.liveRoom.roomId];
            // QN判断已退出直播间
            [LiveModule module].roomID = nil;
        }
    }
}

#pragma mark - IM通知
- (void)onZBLogin:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ZBImLoginReturnObject *)item {
    
}

- (void)onZBRecvTalentRequestNotice:(ZBImTalentRequestObject *)talentRequestItem {
    NSLog(@"PrivateViewController::onZBRecvTalentRequestNotice( [接收直播间才艺点播通知], nickName : %@, TalentName : %@ )", talentRequestItem.nickName, talentRequestItem.name);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playVC closeAllInputView];
        [self.talentDialog setTalentName:talentRequestItem.nickName andRequestName:talentRequestItem.name];
        [self.talentDialog showDialog:self.view declineBlock:^{
            [self getAnchorDealTalentRequestIsAccept:NO andTalentInviteItem:talentRequestItem];
        } acceptBlock:^{
            [self getAnchorDealTalentRequestIsAccept:YES andTalentInviteItem:talentRequestItem];
        }];
    });
}

- (void)onZBRecvControlManPushNotice:(ZBImControlPushItemObject *)item {
    NSLog(@"PrivateViewController::onZBRecvControlManPushNotice( [接收观众%@视频互动] userid : %@ , videoUrl : %@ )", (item.control == 1) ? @"启动" : @"关闭" , item.userId, item.manVideoUrl);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.liveRoom.roomId isEqualToString:item.roomId]) {
            
            NSString * message = (item.control == 1)?NSLocalizedStringFromSelf(@"AUDIENCE_OPEND_CAMERA"):NSLocalizedStringFromSelf(@"AUDIENCE_CLOSE_CAMERA");
            message = [NSString stringWithFormat:message,item.nickName];
            
            if (item.control == 1) {
                [self.playVC.liveVC showPreviewLoadView];
                [self.playVC.liveVC addTips:message];
                
                self.liveRoom.playUrlArray = item.manVideoUrl;
                [self setupVideoPreview:YES];
                [self.playVC.liveVC play];
            } else {
                [self.playVC.liveVC hiddenPreviewLoadView];
                [self.playVC.liveVC addTips:message];
                
                self.liveRoom.playUrlArray = nil;
                [self.playVC.liveVC stopPlay];
                [self setupVideoPreview:NO];
            }
        }
    });
}

#pragma mark - 主播同意or拒绝才艺点播
- (void)getAnchorDealTalentRequestIsAccept:(BOOL)isAccept andTalentInviteItem:(ZBImTalentRequestObject *)item
{
    if (isAccept) {
        [self showLoading];
    }
    [[LSAnchorRequestManager manager] anchorDealTalentRequest:item.talentInviteId status:isAccept?ZBTALENTREPLYTYPE_AGREE:ZBTALENTREPLYTYPE_REJECT finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            [self.talentDialog hidenDialog];
            NSString * message = isAccept?NSLocalizedStringFromSelf(@"Accepted_msg"):NSLocalizedStringFromSelf(@"Declined_msg");
            message = [NSString stringWithFormat:message,item.nickName,item.name];
            if (success && isAccept) {
                [self.playVC.liveVC addTips:message];
            }
            if (!isAccept) {
                [self.playVC.liveVC addTips:message];
            }
            if (!success && isAccept) {
                if (errnum == ZBHTTP_LCC_ERR_FAIL || errnum == ZBHTTP_LCC_ERR_CONNECTFAIL) {
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"CONNECTION_SERVER_FAILED")];
                } else {
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                }
            }
        });
    }];
}

#pragma mark - 播放界面回调
- (void)onReEnterRoom:(PlayViewController *)vc {
    NSLog(@"PrivateViewController::onReEnterRoom()");
    // 刷新界面
    [self setupVideoPreview:NO];
}

- (void)setupVideoPreview:(BOOL)start {
    self.playVC.liveVC.previewImageView.hidden = start;
}



@end
