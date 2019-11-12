//
//  LSMainOpenURLManager.m
//  livestream
//
//  Created by Calvin on 2019/8/9.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMainOpenURLManager.h"
#import "LSLoginManager.h"
#import "LiveGobalManager.h"
#import "LiveModule.h"
#import "QNRiskControlManager.h"
#import "LiveUrlHandler.h"

#import "AnchorPersonalViewController.h"
#import "PreLiveViewController.h"
#import "InterimShowViewController.h"
#import "InterimShowViewController.h"
#import "LSInvitedToViewController.h"
#import "HangOutPreViewController.h"
#import "BookPrivateBroadcastViewController.h"
#import "LSMyReservationsViewController.h"
#import "MyBackpackViewController.h"
#import "MeLevelViewController.h"
#import "LSMessageViewController.h"
#import "LSChatViewController.h"
#import "LSGreetingsViewController.h"
#import "LSGreetingDetailViewController.h"
#import "LSMailViewController.h"
#import "QNChatViewController.h"
#import "QNChatAndInvitationViewController.h"
#import "LSSendMailViewController.h"
#import "LSSayHiListViewController.h"
#import "LSSayHiDetailViewController.h"
#import "LSSendSayHiViewController.h"
#import "LSAddCreditsViewController.h"
#import "LiveWebViewController.h"
#import "LSStoreMainViewController.h"
#import "LSStoreListToLadyViewController.h"



@interface LSMainOpenURLManager ()<LiveUrlHandlerDelegate, LiveUrlHandlerParseDelegate>
/** 链接跳转管理器 */
@property (nonatomic, strong) LiveUrlHandler *handler;

@end

@implementation LSMainOpenURLManager

- (instancetype)init {
    self = [super init];
    if (self) {
        // 路径跳转
        self.handler = [LiveUrlHandler shareInstance];
        self.handler.delegate = self;
        self.handler.parseDelegate = self;
    }
    return self;
}

- (void)removeMainVC {
    [self.mainVC.view removeFromSuperview];
    [self.mainVC removeFromParentViewController];
    self.mainVC = nil;
}

- (void)reportScreenForce {
    [self.mainVC reportScreenForce];
}


#pragma mark - 链接打开内部模块处理
- (void)handlerUpdateUrl:(LiveUrlHandler *)handler {
    NSLog(@"LSMainViewController::handlerUpdateUrl( [URL更新], self : %p, viewDidAppearEver : %@ )", self, BOOL2YES(self.mainVC.viewDidAppearEver));
    
    // TODO:如果界面已经展现, 收到URL打开模块通知, 直接处理
    if (self.mainVC.viewDidAppearEver) {
        [self.mainVC.settingVC removeHomeSettingVC];
        [handler openURL];
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openMainType:(LiveUrlMainListType)type {
    // TODO:收到通知进入主页
    int index = 0;
    switch (type) {
        case LiveUrlMainListTypeHot: {
            index = 0;
        } break;
        case LiveUrlMainListUrlTypeHangout: {
            // 如果没有多人互动的权限则跳转到首页
            if (![LSLoginManager manager].loginItem.userPriv.hangoutPriv.isHangoutPriv) {
                index = 0;
            } else {
                index = 1;
            }
            
        } break;
        case LiveUrlMainListUrlTypeFollow: {
            if (![LSLoginManager manager].loginItem.userPriv.hangoutPriv.isHangoutPriv) {
                index = 1;
            } else {
                index = 2;
            }
            
        } break;
        case LiveUrlMainListUrlTypeCalendar: {
            if (![LSLoginManager manager].loginItem.userPriv.hangoutPriv.isHangoutPriv) {
                index = 2;
            } else {
                index = 3;
            }
            
        } break;
        default:
            break;
    }
    
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 主页], type : %d, index : %d )", type, index);
    
    [self.mainVC.navigationController popToViewController:self.mainVC animated:NO];
    [self reportScreenForce];
    
    self.mainVC.curIndex = index;
    
    // 界面显示再切换标题页
    if (self.mainVC.viewDidAppearEver) {
        [self.mainVC.pagingScrollView layoutIfNeeded];
        [self.mainVC.pagingScrollView displayPagingViewAtIndex:self.mainVC.curIndex animated:NO];
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openAnchorDetail:(NSString *)anchorId {
    // TODO:收到通知进入主播资料页
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 主播资料页], anchorId : %@ )", anchorId);
    
    AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    vc.enterRoom = 1;
    
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openPublicLive:(NSString *)roomId anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    // TODO:点击立即免费公开
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 进入公开直播间], roomId : %@, anchorId : %@, roomType : %u )", roomId, anchorId, roomType);
    
    [[LiveModule module].analyticsManager reportActionEvent:EnterPublicBroadcast eventCategory:EventCategoryenterBroadcast];
    
    [[LiveGobalManager manager] dismissLiveRoomVC];
    
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomId = roomId;
    liveRoom.userId = anchorId;
    liveRoom.roomType = roomType;
    vc.liveRoom = liveRoom;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openPreLive:(NSString *)roomId anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    // TODO:主动邀请, 跳转过渡页
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 主动邀请], roomId : %@, anchorId : %@, roomType : %u )", roomId, anchorId, roomType);
    
    [[LiveGobalManager manager] dismissLiveRoomVC];
    
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomId = roomId;
    liveRoom.userId = anchorId;
    liveRoom.roomType = roomType;
    vc.liveRoom = liveRoom;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openShow:(NSString *)showId anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    // TODO:进入节目过渡页
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 进入节目], roomId : %@, anchorId : %@, roomType : %u )", showId, anchorId, roomType);
    
    [[LiveGobalManager manager] dismissLiveRoomVC];
    
    InterimShowViewController *vc = [[InterimShowViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.showId = showId;
    liveRoom.userId = anchorId;
    liveRoom.roomType = roomType;
    vc.liveRoom = liveRoom;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openInvited:(NSString *)anchorName anchorId:(NSString *)anchorId inviteId:(NSString *)inviteId {
    // TODO:收到通知进入应邀过渡页
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 应邀], anchorName : %@, anchorId : %@, inviteId : %@ )", anchorName, anchorId, inviteId);
    
    [[LiveGobalManager manager] dismissLiveRoomVC];
    
    LSInvitedToViewController *vc = [[LSInvitedToViewController alloc] init];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.userId = anchorId;
    liveRoom.userName = anchorName;
    vc.inviteId = inviteId;
    vc.liveRoom = liveRoom;
    
     [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openHangout:(NSString *)roomId anchorId:(NSString *)anchorId anchorName:(NSString *)anchorName hangoutAnchorId:(NSString *)hangoutAnchorId hangoutAnchorName:(NSString *)hangoutAnchorName {
    // TODO:收到通知进入多人互动直播间
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 进入多人互动直播间], roomId : %@, anchorId : %@, anchorName : %@, hangoutAnchorId : %@, hangoutAnchorName : %@ )", roomId, anchorId, anchorName, hangoutAnchorId, hangoutAnchorName);
    
    [[LiveGobalManager manager] dismissLiveRoomVC];
    
    HangOutPreViewController *vc = [[HangOutPreViewController alloc] initWithNibName:nil bundle:nil];
    vc.roomId = roomId;
    vc.inviteAnchorId = anchorId;
    vc.inviteAnchorName = anchorName;
    vc.hangoutAnchorId = hangoutAnchorId;
    vc.hangoutAnchorName = hangoutAnchorName;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBooking:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:收到通知进入新建预约页
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 新建预约页], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
    [self reportScreenForce];
    
    BookPrivateBroadcastViewController *vc = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    vc.userId = anchorId;
    vc.userName = anchorName;
    
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBookingList:(LiveUrlBookingListType)bookListType {
    // TODO:收到通知进入预约列表页
    int index = 0;
    switch (bookListType) {
        case LiveUrlBookingListTypeWaitUser: {
            index = 0;
        } break;
        case LiveUrlBookingListTypeWaitAnchor: {
            index = 1;
        } break;
        case LiveUrlBookingListTypeConfirm: {
            index = 2;
        } break;
        case LiveUrlBookingListTypeHistory: {
            index = 3;
        } break;
        default:
            break;
    }
    
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 预约列表页], bookType : %d, index : %d )", bookListType, index);
    [[LiveGobalManager manager] popToRootVC];
    [self reportScreenForce];
    
    LSMyReservationsViewController *vc = [[LSMyReservationsViewController alloc] initWithNibName:nil bundle:nil];
    vc.curIndex = index;
    
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBackpackList:(LiveUrlBackpackListType)backpackType {
    // TODO:收到通知进入背包列表页
    int index = 0;
    switch (backpackType) {
        case LiveUrlBackPackListTypePresent: {
            index = 2;
        } break;
        case LiveUrlBackPackListTypeVoucher: {
            index = 1;
        } break;
        case LiveUrlBackPackListTypeDrive: {
            index = 3;
        } break;
        case LiveUrlBackPackListTypePostStamp: {
            index = 0;
        } break;
        default:
            break;
    }
    
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 背包列表页], backpackType : %d, index : %d )", backpackType, index);
    [[LiveGobalManager manager] popToRootVC];
    [self reportScreenForce];
    
    MyBackpackViewController *vc = [[MyBackpackViewController alloc] initWithNibName:nil bundle:nil];
    vc.curIndex = index;
    
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandlerOpenAddCredit:(LiveUrlHandler *)handler {
    NSLog(@"LSMainOpenURLManager:liveUrlHandlerOpenMyLevel( [URL跳转, 买点] )");
    // TODO:收到通知进入买点
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandlerOpenMyLevel:(LiveUrlHandler *)handler {
    // TODO:收到通知进入我的等级
    NSLog(@"LSMainOpenURLManager:liveUrlHandlerOpenMyLevel( [URL跳转, 我的等级] )");
    [[LiveGobalManager manager] popToRootVC];
    [self reportScreenForce];
    
    MeLevelViewController *vc = [[MeLevelViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandlerOpenChatList:(LiveUrlHandler *)handler {
    // TODO:收到通知进入私信列表
    NSLog(@"LSMainOpenURLManager:liveUrlHandlerOpenChatList( [URL跳转, 聊天列表] )");
    [[LiveGobalManager manager] popToRootVC];
    [self reportScreenForce];
    
    LSMessageViewController *vc = [[LSMessageViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openChatWithAnchor:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:进入私信界面
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 聊天界面] )");
    LSChatViewController *vc = [LSChatViewController initChatVCWithAnchorId:anchorId];
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandlerOpenGreetMailList:(LiveUrlHandler *)handler {
    // TODO:进入意向信列表
    NSLog(@"LSMainOpenURLManager:liveUrlHandlerOpenGreetMailList( [URL跳转, 意向信列表] )");
    [[LiveGobalManager manager] popToRootVC];
    LSGreetingsViewController *vc = [[LSGreetingsViewController alloc] initWithNibName:nil bundle:nil];
    
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenGreetingMailDetail:(NSString *)loiId {
    NSLog(@"LSMainViewController::didOpenGreetingMailDetail( [URL跳转, 意向信详情] ) loiId %@",loiId);
    // TODO:进入意向信详情
    [[LiveGobalManager manager] popToRootVC];
    LSGreetingDetailViewController *vc = [[LSGreetingDetailViewController alloc] initWithNibName:nil bundle:nil];
    LSHttpLetterListItemObject *letterItem = [[LSHttpLetterListItemObject alloc] init];
    letterItem.letterId = loiId;
    vc.letterItem = letterItem;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandlerOpenMailList:(LiveUrlHandler *)handler {
    // TODO:进入信件列表
    NSLog(@"LSMainOpenURLManager:liveUrlHandlerOpenMailList( [URL跳转, 信件列表] )");
    [[LiveGobalManager manager] popToRootVC];
    LSMailViewController *vc = [[LSMailViewController alloc] initWithNibName:nil bundle:nil];
    
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenYesNoDialogTitle:(NSString *)title msg:(NSString *)msg yesTitle:(NSString *)yesTitle noTitle:(NSString *)noTitle yesUrl:(NSString *)yesUrl {
    // TODO:弹出对话框
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 弹出对话框] )");
    
    UIAlertController *yesNoAlertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    // 如果没有No的标题则不显示
    if (noTitle.length > 0) {
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:noTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             
                                                         }];
        [yesNoAlertView addAction:noAction];
    }
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesTitle
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          if (yesUrl.length > 0) {
                                                              BOOL bFlag = [[LiveModule module].serviceManager canOpenURL:[NSURL URLWithString:yesUrl]];
                                                              if (bFlag) {
                                                                  // 可以处理的内部模块链接
                                                                  [[LiveModule module].serviceManager handleOpenURL:[NSURL URLWithString:yesUrl]];
                                                              } else {
                                                                  // 通过WebView打开的Http链接
                                                                  LiveWebViewController *vc = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
                                                                  vc.url = yesUrl;
                                                                  [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
                                                              }
                                                          }
                                                      }];
    [yesNoAlertView addAction:yesAction];
    
    [self.mainVC presentViewController:yesNoAlertView animated:NO completion:nil];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenLiveChatLady:(NSString *)anchorId anchorName:(NSString *)anchorName inviteMsg:(NSString *)msg{
    // TODO::进入聊天界面
    NSLog(@"LSMainViewController::didOpenLiveChatLady ( [URL跳转,进入聊天界面] )");
    QNChatViewController *vc = [[QNChatViewController alloc] initWithNibName:nil bundle:nil];
    vc.womanId = anchorId;
    vc.firstName = anchorName;
    vc.ladyInviteMsg = msg;
    [[LiveGobalManager manager] pushAndPopVCWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandlerOpenLiveChatList:(LiveUrlHandler *)handler {
    // TODO::进入聊天界面
    NSLog(@"LSMainOpenURLManager:liveUrlHandlerOpenLiveChatList ( [URL跳转,进入聊天列表] )");
    if (![[QNRiskControlManager manager]isRiskControlType:RiskType_livechat withController:self.mainVC]) {
        [[LiveGobalManager manager] popToRootVC];
        QNChatAndInvitationViewController *vc = [[QNChatAndInvitationViewController alloc] initWithNibName:nil bundle:nil];
        [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenSendMail:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:进入发送信件界面
    NSLog(@"LSMainViewController::didOpenSendMail( [URL跳转, 发送EMF], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
    LSSendMailViewController *vc = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    vc.anchorName = anchorName;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenHangoutRoom:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:进入多人互动直播过渡页
    NSLog(@"LSMainViewController::didOpenHangoutRoom( [URL跳转, 跳转多人互动过渡页], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
    HangOutPreViewController *vc = [[HangOutPreViewController alloc] initWithNibName:nil bundle:nil];
    vc.inviteAnchorId = anchorId;
    vc.inviteAnchorName = anchorName;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenHangoutDialog:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:进入多人互动弹层
    NSLog(@"LSMainViewController::didOpenHangoutDialog( [URL跳转, 跳转多人互动弹层页], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
    HangoutDialogViewController *vc = [[LiveGobalManager manager] addDialogVc];
    vc.anchorId = anchorId;
    vc.anchorName = anchorName;
    [vc showhangoutView];
}


- (void)liveUrlHandler:(LiveUrlHandler *)handler openSayHiType:(LiveUrlSayHiListType)type {
    // TODO:进入sayhi列表
    int index = 0;
    switch (type) {
        case LiveUrlSayHiListTypeAll: {
            index = 0;
        } break;
        case LiveUrlSayHiListTypeResponse: {
            index = 1;
        } break;
        default:
            break;
    }
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, sayhi列表页], openSayHiType : %d, index : %d )", type, index);
    [[LiveGobalManager manager] popToRootVC];
    LSSayHiListViewController *vc = [[LSSayHiListViewController alloc] initWithNibName:nil bundle:nil];
    vc.curIndex = index;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenSayHiDetail:(NSString *)sayhiId {
    // TODO:进入sayhi详情
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, sayhi详情], didOpenSayHiDetail : %@,)", sayhiId);
    LSSayHiDetailViewController * vc = [[LSSayHiDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.sayHiID = sayhiId;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didSendSayhi:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:进入发送sayhi页
    NSLog(@"LSMainViewController::didOpenHangoutDialog( [URL跳转, 跳转发送sayhi页], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
    LSSendSayHiViewController *vc = [[LSSendSayHiViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    vc.anchorName = anchorName;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler OpenGiftFlowerList:(LiveUrlGiftFlowerListType)type {
    // TODO:进入鲜花礼品列表
    int index = 0;
    switch (type) {
        case LiveUrlGiftFlowerListTypeStore: {
            index = 0;
        } break;
        case LiveUrlGiftFlowerListTypeDelivery: {
            index = 1;
        } break;
        default:
            break;
    }
    NSLog(@"LSMainViewController::OpenGiftFlowerList( [URL跳转, 跳转鲜花礼品商城])");
    [[LiveGobalManager manager] popToRootVC];
    LSStoreMainViewController * vc = [[LSStoreMainViewController alloc]initWithNibName:nil bundle:nil];
    vc.curIndex = index;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openGiftFlowerAnchorStore:(NSString *)anchorId {
    // TODO:跳转指定女士的鲜花商城
    NSLog(@"LSMainViewController::openGiftFlowerAnchorStore( [URL跳转, 跳转指定女士鲜花礼品删除], anchorId : %@)", anchorId);
    LSStoreListToLadyViewController *vc = [[LSStoreListToLadyViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}
@end
