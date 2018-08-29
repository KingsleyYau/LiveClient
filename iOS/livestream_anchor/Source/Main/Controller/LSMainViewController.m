//
//  LSMainViewController.m
//  livestream
//
//  Created by Max on 2017/5/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSMainViewController.h"

#import "StreamTestViewController.h"
#import "PreLiveViewController.h"
#import "LSMyReservationsPageViewController.h"
#import "AnchorPersonalViewController.h"
#import "LSLoginManager.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LiveService.h"
#import "LiveStreamSession.h"
#import "LSLiveBroadcasterViewController.h"
#import "PreStartPublicViewController.h"
#import "LSMeViewController.h"
#import "LSAnchorImManager.h"
#import "LSUserUnreadCountManager.h"
#import "CheckPrivacyManager.h"


@interface LSMainViewController () <LiveUrlHandlerDelegate, LoginManagerDelegate, ZBIMManagerDelegate, ZBIMLiveRoomManagerDelegate, LSUserUnreadCountManagerDelegate,LiveModuleDelegate>
/**
 内容页
 */
@property (strong) NSDictionary<NSNumber *, UIViewController *> *viewControllers;

/**
 底部TabBar发布视频选项
 */
@property (strong) UITabBarItem *tabBarItemPublish;

/**
 *  Login管理器
 */
@property (nonatomic, strong) LSLoginManager *loginManager;

@property (nonatomic, strong) CheckPrivacyManager *checkManager;

/** 链接跳转管理器 */
@property (nonatomic, strong) LiveUrlHandler *handler;

// IM管理器
@property (nonatomic, strong) LSAnchorImManager *imManager;

// Modify by Max 2018/01/26
@property (nonatomic, strong) LSUserUnreadCountManager *unreadCountManager;
@property (nonatomic, assign) int unreadCount;

@property (strong, nonatomic) UIWindow *window;
/**
 底部TabBar当前选项
 */
@property (strong) UITabBarItem *tabBarItemSelected;
@end

@implementation LSMainViewController
#pragma mark - iPhoneX适配Tabbar
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // TODO:刷新Tabbar items
    [self.tabBar invalidateIntrinsicContentSize];
}

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    NSLog(@"LSMainViewController::initCustomParam()");
    
    // HTTP登录
    self.loginManager = [LSLoginManager manager];
    [self.loginManager addDelegate:self];
    
    // 权限检测管理器
    self.checkManager = [[CheckPrivacyManager alloc] init];
    
    // 路径跳转
    self.handler = [LiveUrlHandler shareInstance];
    self.handler.delegate = self;
    
    // IM
    self.imManager = [LSAnchorImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    // 未读
    self.unreadCountManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadCountManager addDelegate:self];
    self.unreadCount = 0;
}

- (void)dealloc {
    NSLog(@"LSMainViewController::dealloc()");
    
    // 去掉登录事件
    [self.loginManager removeDelegate:self];
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    [self.unreadCountManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LiveModule module].delegate = self;

    // 主播端首页
    LSLiveBroadcasterViewController *vcBroadcaster = [[LSLiveBroadcasterViewController alloc] initWithNibName:nil bundle:nil];
    vcBroadcaster.tabBarItem.tag = 0;
    [self addChildViewController:vcBroadcaster];
    
    // 开播选项
    self.tabBarItemPublish = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarShow"] tag:1];
    self.tabBarItemPublish.image = [[UIImage imageNamed:@"TabBarShow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItemPublish.imageInsets = UIEdgeInsetsMake(-10, 0, 10, 0);
    
    
    // 个人中心
    LSMeViewController *vcMe = [[LSMeViewController alloc] initWithNibName:nil bundle:nil];
    vcMe.tabBarItem.tag = 2;
    [self addChildViewController:vcMe];
    
    // 初始化主播端首页内容界面
    self.viewControllers = [NSDictionary dictionaryWithObjectsAndKeys:
                            vcBroadcaster, @(vcBroadcaster.tabBarItem.tag),
                            vcMe, @(vcMe.tabBarItem.tag),
                            nil];
    
    // 初始化底部TabBar
    self.tabBar.items = [NSArray arrayWithObjects:vcBroadcaster.tabBarItem, self.tabBarItemPublish, vcMe.tabBarItem, nil];
    
    [self.tabBar setBackgroundImage:[[UIImage alloc] init]];
    
    [self.tabBar setShadowImage:[[UIImage alloc] init]];

    // 计算Tabbar高度
    if ([LSDevice iPhoneXStyle]) {
        // TODO:底部留空
        self.tabBarHeight.constant = 83;
    } else {
        // TODO:紧贴底部
        self.tabBarHeight.constant = 49;
    }
    
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"showUpdateDialog"] boolValue]) {
        //检测更新
        [self checkUpdateAPP];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"LSMainViewController::viewWillAppear( animated : %@ )", BOOL2YES(animated));
    
    // 头部颜色
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // 处理跳转URL
    [[LiveUrlHandler shareInstance] handleOpenURL];
    

}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"LSMainViewController::viewDidAppear( animated : %@, viewDidAppearEver : %@ )", BOOL2YES(animated), BOOL2YES(self.viewDidAppearEver));
    if (!self.viewDidAppearEver) {
        // 选中默认页, 第一次进入
        UITabBarItem *tabBarItemDefault = [self.tabBar.items objectAtIndex:0];
        self.tabBar.selectedItem = tabBarItemDefault;
        [self showCurrentViewController:tabBarItemDefault];
    }
    
    [super viewDidAppear:animated];
    
    // 禁止主界面右滑
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // 处理跳转URL
    [[LiveUrlHandler shareInstance] handleOpenURL];
    
    // 刷新未读
//    [self reloadUnreadCount];
//    [self reloadUnReadShow];
}

#pragma mark 检测更新
- (void)checkUpdateAPP
{
    NSInteger buildID = [[[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleVersion"] integerValue];
    LSConfigManager *config = [LSConfigManager manager];
    if (config.item.newestVer > buildID) {
        UIAlertController * alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UPDATE_TITLE", nil) message:[LSConfigManager manager].item.newestMsg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"UPDATE_NOT_NOW", nil) style:UIAlertActionStyleDefault handler:nil];
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"UPDATE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[LSConfigManager manager].item.downloadAppUrl]];
        }];
        [alertView addAction:cancelAction];
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"showUpdateDialog"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark 界面属性
- (void)willMoveToParentViewController:(nullable UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    
    NSLog(@"LSMainViewController::willMoveToParentViewController( parent : %@ )", parent);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"LSMainViewController::viewWillDisappear( animated : %@ )", BOOL2YES(animated));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 恢复右滑手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    UIViewController *viewController = [self.viewControllers objectForKey:@(self.tabBarItemSelected.tag)];
    self.navigationItem.titleView = viewController.navigationItem.titleView;
    self.navigationItem.leftBarButtonItems = viewController.navigationItem.leftBarButtonItems;
    self.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems;
}

#pragma mark - LSLoginManager回调
- (void)manager:(LSLoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(ZBLSLoginItemObject *_Nullable)loginItem errnum:(ZBHTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *_Nonnull)errmsg {
}

- (void)manager:(LSLoginManager *)manager onLogout:(BOOL)kick msg:(NSString *)msg {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 互踢退出直播间
        UIViewController *moduleVC = [LiveModule module].moduleVC;
        if (moduleVC && moduleVC.navigationController ) {
            UIViewController *vc = moduleVC.navigationController.topViewController;
            [vc dismissViewControllerAnimated:NO completion:nil];
        }
        
        if (msg.length > 0) {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
        [self.navigationController popToRootViewControllerAnimated:NO];
        [LiveModule module].moduleVC = nil;
        [LiveModule module].fromVC = nil;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        LSNavigationController *loginVC = [story instantiateViewControllerWithIdentifier:@"LSNavigationController"];
        
        ZBAppDelegate.window.rootViewController = loginVC;
        
    });
}

#pragma mark - 内容界面切换逻辑
- (void)showCurrentViewController:(UITabBarItem *)item {
    NSLog(@"LSMainViewController::showCurrentViewController( item.tag : %@ )", @(item.tag));
    
    UIViewController *viewController = [self.viewControllers objectForKey:@(item.tag)];
    [self.tabContainView addSubview:viewController.view];
    
    
    [viewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tabContainView);
        make.left.equalTo(self.tabContainView);
        make.width.equalTo(self.tabContainView);
        make.height.equalTo(self.tabContainView);
    }];
    // 使约束生效
    [viewController.view layoutSubviews];
    
    // 刷新底部Tab
    self.tabBarItemSelected = item;
    self.tabBar.selectedItem = item;
    
    if (item.tag == 0) {
        [self reloadUnReadShow];
    }
    // 刷新导航栏
    [self setupNavigationBar];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item == self.tabBarItemPublish) {

        // 点击开播按钮, 弹出预备开播界面
        tabBar.selectedItem = self.tabBarItemSelected;
        
        // 先检测是否开启摄像头/麦克风权限
        [self.checkManager checkPrivacyIsOpen:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    // 点击开播按钮, 弹出预备开播界面
                    tabBar.selectedItem = self.tabBarItemSelected;
                    PreStartPublicViewController *startPublicVc = [[PreStartPublicViewController alloc] initWithNibName:nil bundle:nil];
                    [self navgationControllerPresent:startPublicVc];
                }
            });
        }];
        
    } else {
        // 切换内容界面
        for (UIViewController *viewController in self.viewControllers.allValues) {
            [viewController.view removeFromSuperview];
        }
        [self showCurrentViewController:item];
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - 获取用户中心未读数
- (void)reloadUnreadCount {
    // TODO:获取未读数量
    self.unreadCount = 0;
    [self.unreadCountManager getUnreadSheduledBooking];
}

- (void)reloadUnReadShow {
    [self.unreadCountManager getUnreadShowCalendar];
}


- (void)reloadUnreadMessage {
    // TODO:刷新界面未读消息
    LSUITabBarItem *tabBarItem = (LSUITabBarItem *)[self.tabBar.items objectAtIndex:0];
    tabBarItem.isShowNum = YES;
    tabBarItem.badgeValue = nil;
    if (self.unreadCount == 0) {
        tabBarItem.badgeValue = nil;
    } else {
        if (self.unreadCount > 0) {
            tabBarItem.badgeValue = @"";
        }
    }
}


- (void)onGetUnreadShowCalendar:(int)count {
    if (count > 0) {
        // TODO:获取未读数量
        self.unreadCount = count;
        [self reloadUnreadMessage];
    }else {
        [self reloadUnreadCount];
    }
}

- (void)onZBHandleRecvScheduleAcceptNotice:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl invitationId:(NSString* _Nonnull)invitationId bookTime:(long)bookTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.unreadCount = 1;
        [self reloadUnreadMessage];
        [self reloadUnreadCount];
        
    });
}

- (void)onGetUnreadSheduledBooking:(int)count {
    self.unreadCount = count;
    [self reloadUnreadMessage];
    LSLiveBroadcasterViewController *vcBroadcaster = (LSLiveBroadcasterViewController *)[self.viewControllers objectForKey:@(0)];
    [vcBroadcaster getUnreadSheduledBooking];
    
}

#pragma mark - im通知回调
- (void)onRecvAnchorProgramPlayNotice:(IMAnchorProgramItemObject *_Nonnull)item msg:(NSString * _Nonnull)msg{
    NSLog(@"LSAnchorImManager::onRecvAnchorProgramPlayNotice( [接收节目开播通知])");
    [self.unreadCountManager getUnreadShowCalendar];
}

- (void)onRecvAnchorChangeStatusNotice:(IMAnchorProgramItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::onRecvAnchorChangeStatusNotice( [接收节目状态改变通知])");
    // 不管什么状态都获取,什么状态是未读由服务器控制
    [self.unreadCountManager getUnreadShowCalendar];
}

- (void)onZBLogin:(ZBLCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg item:(ZBImLoginReturnObject* _Nonnull)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.unreadCountManager getUnreadShowCalendar];
    });
}

#pragma mark - LiveUrlHandler通知
- (void)liveUrlHandler:(LiveUrlHandler *)handler openPreLive:(NSString *)roomId userId:(NSString *)userId roomType:(LiveRoomType)roomType {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 预约及切换直播间], roomId : %@, userId : %@, roomType : %u )", roomId, userId, roomType);
    // TODO:主动邀请, 跳转过渡页
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomId = roomId;
    liveRoom.userId = userId;
    liveRoom.roomType = roomType;
    
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = liveRoom;
    vc.status = PreLiveStatus_Enter;;
    
    [self navgationControllerPresent:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openInvited:(NSString *_Nullable)userName userId:(NSString *_Nullable)userId inviteId:(NSString *_Nullable)inviteId {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 直播间外应邀], userName : %@, userId : %@, inviteId : %@ )", userName, userId, inviteId);
    // TODO:收到通知进入应邀过渡页
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.userId = userId;
    liveRoom.userName = userName;
    
    PreLiveViewController *vc = [[PreLiveViewController alloc] init];
    vc.inviteId = inviteId;
    vc.liveRoom = liveRoom;
    vc.status = PreLiveStatus_Accept;
    
    [self navgationControllerPresent:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openMainType:(int)index {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 主页], index : %i )", index);
    // TODO:收到通知进入主页
    [self.navigationController popToViewController:self animated:YES];
    
    if (index < self.tabBar.items.count) {
        UITabBarItem *tabBarItem = [self.tabBar.items objectAtIndex:index];
        [self showCurrentViewController:tabBarItem];
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openAnchorDetail:(NSString *)anchorId {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 主播资料页], anchorId : %@ )", anchorId);
    // TODO:收到通知进入主播资料页
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = anchorId;
    listViewController.showInvite = 1;
    [self.navigationController pushViewController:listViewController animated:NO];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBooking:(NSString *)anchorId {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 新建预约页], anchorId : %@ )", anchorId);
    // TODO:收到通知进入新建预约页
//    BookPrivateBroadcastViewController *bookPrivate = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
//    bookPrivate.userId = anchorId;
//    [self.navigationController pushViewController:bookPrivate animated:NO];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBookingList:(int)bookType {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 预约列表页], bookType : %i )", bookType);
    // TODO:收到通知进入预约列表页
    LSMyReservationsPageViewController *reservation = [[LSMyReservationsPageViewController alloc] initWithNibName:nil bundle:nil];
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:reservation];
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBackpackList:(int)BackpackType {

}

- (void)liveUrlHandlerOpenAddCredit:(LiveUrlHandler *)handler {
    UIViewController *vc = [LiveModule module].addCreditVc;
    if (vc) {
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)liveUrlHandlerOpenMyLevel:(LiveUrlHandler *)handler {
    // TODO:进入我的等级界面
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openShow:(NSString *)showId userId:(NSString *)userId roomType:(LiveRoomType)roomType
{
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 进入节目], roomId : %@, userId : %@, roomType : %u )", showId, userId, roomType);
    // TODO:进入节目过渡页
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.photoUrl = [LSLoginManager manager].loginItem.photoUrl;
    liveRoom.userName = [LSLoginManager manager].loginItem.nickName;
    liveRoom.showId = showId;
    liveRoom.userId = userId;
    liveRoom.roomType = roomType;
    vc.liveShowId = showId;
    vc.status = PreLiveStatus_Show;
    vc.liveRoom = liveRoom;
    
    [self navgationControllerPresent:vc];
}

- (void)navgationControllerPresent:(UIViewController *)controller {
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
    nvc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    nvc.navigationBar.barTintColor = [UIColor whiteColor];
    nvc.navigationBar.backgroundColor = [UIColor whiteColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,nil];
    [nvc.navigationBar setTitleTextAttributes:attributes];
    [nvc.navigationItem setHidesBackButton:YES];
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
}

#pragma mark LiveModuleDelegate
- (void)moduleOnNotification:(LiveModule *)module {
    NSLog(@"LSMainViewController::moduleOnNotification()");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        
        UIViewController *vc = [LiveModule module].notificationVC;
        CGRect frame = CGRectMake(0, 25, self.view.frame.size.width, vc.view.frame.size.height);
        self.window = [[UIWindow alloc] initWithFrame:frame];
        self.window.windowLevel = UIWindowLevelAlert + 1;
        UIWindow *parentView = self.window;
        [self.window addSubview:vc.view];
        [self.window makeKeyAndVisible];
        
        [vc.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(parentView).offset(0);
            make.left.equalTo(parentView).offset(10);
            make.right.equalTo(parentView).offset(-10);
            make.height.equalTo(@(vc.view.frame.size.height));
        }];
        
        // Keep the original keyWindow and avoid some unpredictable problems
        [keyWindow makeKeyWindow];
    });
}

- (void)moduleOnNotificationDisappear:(LiveModule *)module {
    NSLog(@"LSMainViewController::moduleOnNotificationDisappear()");
    self.window = nil;
}

@end
