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
#import "LSMinLiveManager.h"
#import "LSOutBoxViewController.h"
#import "LSMailScheduleDetailViewController.h"
#import "LSScheduleListRootViewController.h"
#import "LSScheduleDetailsViewController.h"

@interface LSMainOpenURLManager () <LiveUrlHandlerDelegate, LiveUrlHandlerParseDelegate>
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
    NSLog(@"LSMainOpenURLManager::handlerUpdateUrl( [URL更新], self : %p, viewDidAppearEver : %@ )", self, BOOL2YES(self.mainVC.viewDidAppearEver));

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

    [self showMinLiveView];
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

- (void)liveUrlHandler:(LiveUrlHandler *)handler openPrivateLive:(NSString *)roomId anchorName:(NSString *)anchorName anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    // TODO:点击进入指定的直播间
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 进入指定直播间], roomId : %@, anchorId : %@, roomType : %u )", roomId, anchorId, roomType);

    [[LiveModule module].analyticsManager reportActionEvent:EnterVipBroadcast eventCategory:EventCategoryenterBroadcast];
    [LiveGobalManager manager].liveRoom.canShowMinLiveView = [LiveGobalManager manager].isInMainView;
    if ([[LSMinLiveManager manager].userId isEqualToString:anchorId] && ![LSMinLiveManager manager].minView.hidden) {
        [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:[LSMinLiveManager manager].liveVC];
        [[LSMinLiveManager manager] hidenMinLive];
    } else {
        if ([[LSMinLiveManager manager].userId isEqualToString:anchorId] && [LiveGobalManager manager].liveRoom.roomType == roomType) {
            [LiveGobalManager manager].liveRoom.canShowMinLiveView = [LiveGobalManager manager].isInMainView;
            [[LiveGobalManager manager] pushAndPopVCWithNVCFromVC:self.mainVC toVC:(LSViewController *)[LSMinLiveManager manager].liveVC];
            [[LSMinLiveManager manager] hidenMinLive];
        } else {
            [[LiveGobalManager manager] dismissLiveRoomVC];
            [[LSMinLiveManager manager] removeVC];

            PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
            LiveRoom *liveRoom = [[LiveRoom alloc] init];
            liveRoom.userName = anchorName;
            liveRoom.roomId = roomId;
            liveRoom.userId = anchorId;
            liveRoom.roomType = roomType;
            liveRoom.canShowMinLiveView = [LiveGobalManager manager].isInMainView;
            vc.liveRoom = liveRoom;
            [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
        }
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openPreLive:(NSString *)roomId anchorName:(NSString *)anchorName anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    // TODO:主动邀请, 跳转过渡页
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 主动邀请], roomId : %@, anchorId : %@, roomType : %u )", roomId, anchorId, roomType);
    [LiveGobalManager manager].liveRoom.canShowMinLiveView = [LiveGobalManager manager].isInMainView;
    if ([[LSMinLiveManager manager].userId isEqualToString:anchorId] && ![LSMinLiveManager manager].minView.hidden) {
        [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:[LSMinLiveManager manager].liveVC];
        [[LSMinLiveManager manager] hidenMinLive];
    } else {

        if ([[LSMinLiveManager manager].userId isEqualToString:anchorId] && [LiveGobalManager manager].liveRoom.roomType == roomType) {
            [LiveGobalManager manager].liveRoom.canShowMinLiveView = [LiveGobalManager manager].isInMainView;
            [[LiveGobalManager manager] pushAndPopVCWithNVCFromVC:self.mainVC toVC:(LSViewController *)[LSMinLiveManager manager].liveVC];
            [[LSMinLiveManager manager] hidenMinLive];
        } else {
            [[LiveGobalManager manager] dismissLiveRoomVC];
            [[LSMinLiveManager manager] hidenMinLive];

            PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
            LiveRoom *liveRoom = [[LiveRoom alloc] init];
            liveRoom.userName = anchorName;
            liveRoom.userId = anchorId;
            liveRoom.roomType = roomType;
            liveRoom.canShowMinLiveView = [LiveGobalManager manager].isInMainView;
            vc.liveRoom = liveRoom;
            [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
        }
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openShow:(NSString *)showId anchorName:(NSString *)anchorName anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    // TODO:进入节目过渡页
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 进入节目], roomId : %@, anchorId : %@, roomType : %u )", showId, anchorId, roomType);
    [LiveGobalManager manager].liveRoom.canShowMinLiveView = [LiveGobalManager manager].isInMainView;
    if ([[LSMinLiveManager manager].userId isEqualToString:anchorId] && ![LSMinLiveManager manager].minView.hidden) {
        [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:[LSMinLiveManager manager].liveVC];
        [[LSMinLiveManager manager] hidenMinLive];
    } else {
        if ([[LSMinLiveManager manager].userId isEqualToString:anchorId] && [LiveGobalManager manager].liveRoom.roomType == roomType) {
            [[LiveGobalManager manager] pushAndPopVCWithNVCFromVC:self.mainVC toVC:(LSViewController *)[LSMinLiveManager manager].liveVC];
            [[LSMinLiveManager manager] hidenMinLive];
        } else {
            [[LiveGobalManager manager] dismissLiveRoomVC];
            [[LSMinLiveManager manager] hidenMinLive];

            InterimShowViewController *vc = [[InterimShowViewController alloc] initWithNibName:nil bundle:nil];
            LiveRoom *liveRoom = [[LiveRoom alloc] init];
            liveRoom.userName = anchorName;
            liveRoom.showId = showId;
            liveRoom.userId = anchorId;
            liveRoom.roomType = roomType;
            liveRoom.canShowMinLiveView = [LiveGobalManager manager].isInMainView;
            vc.liveRoom = liveRoom;
            [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
        }
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openInvited:(NSString *)anchorName anchorId:(NSString *)anchorId inviteId:(NSString *)inviteId {
    // TODO:收到通知进入应邀过渡页
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 应邀], anchorName : %@, anchorId : %@, inviteId : %@ )", anchorName, anchorId, inviteId);
    [LiveGobalManager manager].liveRoom.canShowMinLiveView = [LiveGobalManager manager].isInMainView;
    if ([[LSMinLiveManager manager].userId isEqualToString:anchorId] && ![LSMinLiveManager manager].minView.hidden) {
        [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:[LSMinLiveManager manager].liveVC];
        [[LSMinLiveManager manager] hidenMinLive];
    } else {
        [[LiveGobalManager manager] dismissLiveRoomVC];
        [[LSMinLiveManager manager] hidenMinLive];

        LSInvitedToViewController *vc = [[LSInvitedToViewController alloc] init];
        LiveRoom *liveRoom = [[LiveRoom alloc] init];
        liveRoom.userId = anchorId;
        liveRoom.userName = anchorName;
        liveRoom.canShowMinLiveView = [LiveGobalManager manager].isInMainView;
        vc.inviteId = inviteId;
        vc.liveRoom = liveRoom;
        [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openHangout:(NSString *)roomId inviteAnchorId:(NSString *)inviteAnchorId inviteAnchorName:(NSString *)inviteAnchorName recommendAnchorId:(NSString *)recommendAnchorId recommendAnchorName:(NSString *)recommendAnchorName {
    // TODO:收到通知进入多人互动直播间
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 进入多人互动直播间], roomId : %@, inviteAnchorId : %@, inviteAnchorName : %@, recommendAnchorId : %@, recommendAnchorName : %@ )", roomId, inviteAnchorId, inviteAnchorName, recommendAnchorId, recommendAnchorName);
    // 跳转多人互动默认关闭最小化窗口
    [[LSMinLiveManager manager] minLiveViewDidCloseBtn];
    [[LiveGobalManager manager] dismissLiveRoomVC];
    [[LSMinLiveManager manager] hidenMinLive];
    HangOutPreViewController *vc = [[HangOutPreViewController alloc] initWithNibName:nil bundle:nil];
    vc.roomId = roomId;
    vc.inviteAnchorId = inviteAnchorId;
    vc.inviteAnchorName = inviteAnchorName;
    vc.recommendAnchorId = recommendAnchorId;
    vc.recommendAnchorName = recommendAnchorName;

    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBooking:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:收到通知进入新建预约页
    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 新建预约页], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
    //关闭预约

    //    [self reportScreenForce];
    //
    //    BookPrivateBroadcastViewController *vc = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    //    vc.userId = anchorId;
    //    vc.userName = anchorName;
    //
    //    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBookingList:(LiveUrlBookingListType)bookListType {
    // TODO:收到通知进入预约列表页
    // 关闭预约
    //    int index = 0;
    //    switch (bookListType) {
    //        case LiveUrlBookingListTypeWaitUser: {
    //            index = 0;
    //        } break;
    //        case LiveUrlBookingListTypeWaitAnchor: {
    //            index = 1;
    //        } break;
    //        case LiveUrlBookingListTypeConfirm: {
    //            index = 2;
    //        } break;
    //        case LiveUrlBookingListTypeHistory: {
    //            index = 3;
    //        } break;
    //        default:
    //            break;
    //    }
    //
    //    NSLog(@"LSMainOpenURLManager:liveUrlHandler( [URL跳转, 预约列表页], bookType : %d, index : %d )", bookListType, index);
    //    [self showMinLiveView];
    //    [[LiveGobalManager manager] popToRootVC];
    //    [self reportScreenForce];
    //
    //    LSMyReservationsViewController *vc = [[LSMyReservationsViewController alloc] initWithNibName:nil bundle:nil];
    //    vc.curIndex = index;
    //
    //    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
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
    [self showMinLiveView];
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
    [self showMinLiveView];
    [[LiveGobalManager manager] popToRootVC];
    [self reportScreenForce];

    MeLevelViewController *vc = [[MeLevelViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandlerOpenChatList:(LiveUrlHandler *)handler {
    // TODO:收到通知进入私信列表
    NSLog(@"LSMainOpenURLManager:liveUrlHandlerOpenChatList( [URL跳转, 聊天列表] )");
    [self showMinLiveView];
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
    [self showMinLiveView];
    [[LiveGobalManager manager] popToRootVC];
    LSGreetingsViewController *vc = [[LSGreetingsViewController alloc] initWithNibName:nil bundle:nil];

    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenGreetingMailDetail:(NSString *)loiId {
    NSLog(@"LSMainOpenURLManager::didOpenGreetingMailDetail( [URL跳转, 意向信详情] ) loiId %@", loiId);
    // TODO:进入意向信详情
    [self showMinLiveView];
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
    [self showMinLiveView];
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

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenLiveChatLady:(NSString *)anchorId anchorName:(NSString *)anchorName inviteMsg:(NSString *)msg {
    // TODO::进入聊天界面
    NSLog(@"LSMainOpenURLManager::didOpenLiveChatLady ( [URL跳转,进入聊天界面] )");
    QNChatViewController *vc = [[QNChatViewController alloc] initWithNibName:nil bundle:nil];
    vc.womanId = anchorId;
    vc.firstName = anchorName;
    vc.ladyInviteMsg = msg;
    [[LiveGobalManager manager] pushAndPopVCWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandlerOpenLiveChatList:(LiveUrlHandler *)handler {
    // TODO::进入聊天界面
    NSLog(@"LSMainOpenURLManager:liveUrlHandlerOpenLiveChatList ( [URL跳转,进入聊天列表] )");
    if (![[QNRiskControlManager manager] isRiskControlType:RiskType_livechat withController:self.mainVC]) {
        [[LSMinLiveManager manager] showMinLive];
        [[LiveGobalManager manager] dismissLiveRoomVC];
        [[LiveGobalManager manager] popToRootVC];
        QNChatAndInvitationViewController *vc = [[QNChatAndInvitationViewController alloc] initWithNibName:nil bundle:nil];
        [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenSendMail:(NSString *)anchorId anchorName:(NSString *)anchorName emfId:(NSString *)emfId {
    // TODO:进入发送信件界面
    NSLog(@"LSMainOpenURLManager::didOpenSendMail( [URL跳转, 发送EMF], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
    LSSendMailViewController *vc = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    vc.anchorName = anchorName;
    vc.emfId = emfId;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenHangoutRoom:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:进入多人互动直播过渡页
    NSLog(@"LSMainOpenURLManager::didOpenHangoutRoom( [URL跳转, 跳转多人互动过渡页], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
    HangOutPreViewController *vc = [[HangOutPreViewController alloc] initWithNibName:nil bundle:nil];
    vc.inviteAnchorId = anchorId;
    vc.inviteAnchorName = anchorName;

    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenHangoutDialog:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:进入多人互动弹层
    NSLog(@"LSMainOpenURLManager::didOpenHangoutDialog( [URL跳转, 跳转多人互动弹层页], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
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
    [self showMinLiveView];
    [[LiveGobalManager manager] popToRootVC];
    LSSayHiListViewController *vc = [[LSSayHiListViewController alloc] initWithNibName:nil bundle:nil];
    vc.curIndex = index;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenSayHiDetail:(NSString *)sayhiId {
    // TODO:进入sayhi详情
    NSLog(@"LSMainOpenURLManager:didOpenSayHiDetail( [URL跳转, sayhi详情], sayhiId : %@ )", sayhiId);
    LSSayHiDetailViewController *vc = [[LSSayHiDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.sayHiID = sayhiId;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didSendSayhi:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:进入发送sayhi页
    NSLog(@"LSMainOpenURLManager::didSendSayhi( [URL跳转, 跳转发送sayhi页], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
    LSSendSayHiViewController *vc = [[LSSendSayHiViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    vc.anchorName = anchorName;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openGiftFlowerList:(LiveUrlGiftFlowerListType)type {
    // TODO:进入鲜花礼品列表
    NSLog(@"LSMainOpenURLManager::openGiftFlowerList( [URL跳转, 跳转鲜花礼品商城], type : %d )", type);
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

    [self showMinLiveView];
    [[LiveGobalManager manager] popToRootVC];
    LSStoreMainViewController *vc = [[LSStoreMainViewController alloc] initWithNibName:nil bundle:nil];
    vc.curIndex = index;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openGiftFlowerAnchorStore:(NSString *)anchorId {
    // TODO:跳转指定女士的鲜花商城
    NSLog(@"LSMainOpenURLManager::openGiftFlowerAnchorStore( [URL跳转, 跳转指定女士鲜花礼品删除], anchorId : %@ )", anchorId);
    LSStoreListToLadyViewController *vc = [[LSStoreListToLadyViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openScheduleList:(LiveUrlScheduleListType)type {
    // TODO:跳转预约私密列表
    int index = 0;

    switch (type) {
        case LiveUrlScheduleListTypePending: {
            index = 0;
        } break;
        case LiveUrlScheduleListTypeConfirm: {
            index = 1;
        } break;
        case LiveUrlScheduleListTypeDeceline: {
            index = 2;
        } break;
        case LiveUrlScheduleListTypeExpired: {
            index = 3;
        } break;
        default:
            break;
    }
    NSLog(@"LSMainOpenURLManager::openScheduleList( [URL跳转,跳转预约列表], type : %d, index : %d )", type, index);
    [self showMinLiveView];
    [[LiveGobalManager manager] popToRootVC];
    [self reportScreenForce];

    LSScheduleListRootViewController *vc = [[LSScheduleListRootViewController alloc] initWithNibName:nil bundle:nil];
    vc.curIndex = index;

    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openScheduleDetail:(NSString *)inviteId refId:(NSString *)refId anchorId:(NSString *)anchorId {
    // TODO:跳转指定预约详情
    NSLog(@"LSMainOpenURLManager::openScheduleDetail( [URL跳转, 跳转指定预约详情], inviteId : %@ refId : %@ anchorId : %@)", inviteId, refId, anchorId);
    LSScheduleDetailsViewController *vc = [[LSScheduleDetailsViewController alloc] initWithNibName:nil bundle:nil];
    vc.inviteId = inviteId;
    vc.refId = refId;
    vc.anchorId = anchorId;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openScheduleMailDetail:(NSString *)loid anchorName:(NSString *)anchorName type:(LiveUrlScheduleMailDetailType)type {
    // TODO:跳转信件预约详情
    NSLog(@"LSMainOpenURLManager::openScheduleMailDetail( [URL跳转, 跳转指定信件详情], type : %d loid : %@ anchorName : %@)", type, loid, anchorName);
    BOOL isInbox = YES;
    if (type == LiveUrlScheduleMailDetailTypeOutBox) {
        isInbox = NO;
    }
    LSMailScheduleDetailViewController *vc = [[LSMailScheduleDetailViewController alloc] initWithNibName:nil bundle:nil];
    LSHttpLetterListItemObject *letterItem = [[LSHttpLetterListItemObject alloc] init];
    letterItem.anchorNickName = anchorName;
    letterItem.letterId = loid;
    vc.letterItem = letterItem;
    vc.isInBoxSheduleDetail = isInbox;
    [[LiveGobalManager manager] pushWithNVCFromVC:self.mainVC toVC:vc];
}

- (void)showMinLiveView {
    NSLog(@"LSMainOpenURLManager::showMinLiveView( [URL跳转, 显示最小化直播间] )");
    if ( [LiveGobalManager manager].liveRoom) {
        [[LSMinLiveManager manager] showMinLive];
        [[LiveGobalManager manager] dismissLiveRoomVC];
    }
}

@end
