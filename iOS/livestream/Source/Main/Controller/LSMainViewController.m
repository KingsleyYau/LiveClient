//
//  LSMainViewController.m
//  livestream
//
//  Created by Max on 2017/5/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSMainViewController.h"

#import "StreamTestViewController.h"
#import "LSHomePageViewController.h"
#import "PreLiveViewController.h"
#import "BookPrivateBroadcastViewController.h"
#import "MeLevelViewController.h"
#import "LiveChannelAdViewController.h"
#import "MeLevelViewController.h"
#import "MyBackpackViewController.h"
#import "LSMyReservationsViewController.h"
#import "AnchorPersonalViewController.h"

// Modify by Max 2018/01/25
#import "HotViewController.h"
#import "FollowingViewController.h"
#import "LSUserInfoListViewController.h"

#import "LSLoginManager.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LiveService.h"

#import "Masonry.h"

#import "LSInvitedToViewController.h"
#import "LSLiveGuideViewController.h"

#import "LSImManager.h"

// Modify by Max 2018/01/26
#import "LSUserUnreadCountManager.h"

@interface LSMainViewController () <LiveUrlHandlerDelegate, LoginManagerDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate, LSLiveGuideViewControllerDelegate, FollowingViewControllerDelegate, LSUserUnreadCountManagerDelegate>
/**
 内容页
 */
@property (strong) NSDictionary<NSNumber *, UIViewController *> *viewControllers;

/**
 底部TabBar发布视频选项
 */
@property (strong) UITabBarItem *tabBarItemPublish;

/**
 底部TabBar当前选项
 */
@property (strong) UITabBarItem *tabBarItemSelected;

/**
 *  Login管理器
 */
@property (nonatomic, strong) LSLoginManager *loginManager;

/** 链接跳转管理器 */
@property (nonatomic, strong) LiveUrlHandler *handler;

// IM管理器
@property (nonatomic, strong) LSImManager *imManager;

// Modify by Max 2018/01/26
@property (nonatomic, strong) LSUserUnreadCountManager *unreadCountManager;
@property (nonatomic, assign) int unreadCount;

@end

@implementation LSMainViewController
#pragma mark - iPhoneX适配Tabbar
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // TODO:刷新Tabbar items
    [self.tabBar invalidateIntrinsicContentSize];

    // TODO:紧贴底部
    //    for (UITabBarItem *item in self.tabBar.items) {
    //        item.imageInsets = UIEdgeInsetsMake(15, 0, -15, 0);
    //        [item setTitlePositionAdjustment:UIOffsetMake(0, 32)];
    //    }
}

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"LSMainViewController::initCustomParam()");

    self.navigationTitle = NSLocalizedStringFromSelf(@"NAVIGATION_ITEM_TITLE");

    // 监听登录事件
    self.loginManager = [LSLoginManager manager];
    [self.loginManager addDelegate:self];

    // 路径跳转
    self.handler = [LiveUrlHandler shareInstance];
    self.handler.delegate = self;

    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    /**
     *  Modify by Max 2018/01/26
     *
     */
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
    // Do any additional setup after loading the view from its nib.

    //    // 主播列表
    //    LSHomePageViewController *vcHome = [[LSHomePageViewController alloc] initWithNibName:nil bundle:nil];
    //    vcHome.tabBarItem.tag = 0;
    //    vcHome.tabBarItem.title = nil;
    //    [self addChildViewController:vcHome];
    //
    //    // 开播选项
    //    self.tabBarItemPublish = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarShow"] tag:1];
    //    self.tabBarItemPublish.imageInsets = UIEdgeInsetsMake(-10, 0, 10, 0);
    //
    //    // 个人中心
    //    StreamTestViewController *vcTest = [[StreamTestViewController alloc] initWithNibName:nil bundle:nil];
    //    vcTest.tabBarItem.tag = 2;
    //    vcTest.tabBarItem.title = nil;
    //    [self addChildViewController:vcTest];

    /**
     *  Modify by Max 2018/01/25
     *
     */
    // 主播Hot列表
    HotViewController *vcHot = [[HotViewController alloc] initWithNibName:nil bundle:nil];
    vcHot.tabBarItem.tag = 0;
    [self addChildViewController:vcHot];

    // 主播Follow列表
    FollowingViewController *vcFollow = [[FollowingViewController alloc] initWithNibName:nil bundle:nil];
    vcFollow.tabBarItem.tag = 1;
    vcFollow.followVCDelegate = self;
    [self addChildViewController:vcFollow];

    LSUserInfoListViewController *vcMe = [[LSUserInfoListViewController alloc] initWithNibName:nil bundle:nil];
    vcMe.tabBarItem.tag = 2;
    [self addChildViewController:vcMe];

    // 初始化内容界面
    self.viewControllers = [NSDictionary dictionaryWithObjectsAndKeys:
                                             vcHot, @(vcHot.tabBarItem.tag),
                                             vcFollow, @(vcFollow.tabBarItem.tag),
                                             vcMe, @(vcMe.tabBarItem.tag),
                                             nil];

    // 初始化底部TabBar
    self.tabBar.items = [NSArray arrayWithObjects:vcHot.tabBarItem, vcFollow.tabBarItem, vcMe.tabBarItem, nil];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectType:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectType:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];

    // 计算Tabbar高度
    if ([LSDevice iPhoneXStyle]) {
        // TODO:底部留空
        self.tabBarHeight.constant = 83;
    } else {
        // TODO:紧贴底部
        self.tabBarHeight.constant = 49;
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
    
    
    if ([LiveModule module].adVc) {
        [[LiveModule module].adVc.view removeFromSuperview];
        [[LiveModule module].adVc removeFromParentViewController];
    }

    // 处理跳转URL
    [[LiveUrlHandler shareInstance] handleOpenURL];
    // 屏蔽新手引导
//    if ([LiveModule module].showListGuide) {
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"] && [LSLoginManager manager].status == LOGINED) {
//            LSLiveGuideViewController *guide = [[LSLiveGuideViewController alloc] initWithNibName:nil bundle:nil];
//            guide.listGuide = YES;
//            guide.guideDelegate = self;
//            [self addChildViewController:guide];
//            [self.view addSubview:guide.view];
//            [guide.view mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.view);
//                make.left.equalTo(self.view);
//                make.width.equalTo(self.view);
//                make.height.equalTo(self.view);
//            }];
//            // 使约束生效
//            [guide.view layoutSubviews];
//
//        } else {
//        }
//    }

    // 刷新未读
    [self reloadUnreadCount];
}

//- (void)lsLiveGuideViewControllerDidFinishGuide:(LSLiveGuideViewController *)guideViewController {
//    // TODO:新手引导结束
//    [guideViewController.view removeFromSuperview];
//    [guideViewController removeFromParentViewController];
//}

- (void)selectType:(UISwipeGestureRecognizer *)gesture {
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:{
            UIViewController *viewController = [self.viewControllers objectForKey:@(self.tabBarItemSelected.tag)];
            if ([viewController isKindOfClass:[HotViewController class]]) {
                UITabBarItem *item = [self.tabBar.items objectAtIndex:1];
                [self showCurrentViewController:item];
            } else if ([viewController isKindOfClass:[FollowingViewController class]]) {
                UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
                [self showCurrentViewController:item];
            } else {

            }
        }break;
        case UISwipeGestureRecognizerDirectionRight:{
            UIViewController *viewController = [self.viewControllers objectForKey:@(self.tabBarItemSelected.tag)];
            if ([viewController isKindOfClass:[HotViewController class]]) {
                
            } else if ([viewController isKindOfClass:[FollowingViewController class]]) {
                UITabBarItem *item = [self.tabBar.items objectAtIndex:0];
                [self showCurrentViewController:item];
            } else {
                UITabBarItem *item = [self.tabBar.items objectAtIndex:1];
                [self showCurrentViewController:item];
            }
        }break;
            
        default:
            break;
    }
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent {
    [super willMoveToParentViewController:parent];

    NSLog(@"LSMainViewController::willMoveToParentViewController( parent : %@ )", parent);

    if (!parent) {
        // 停止互斥服务
        [[LiveService service] closeService];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"END_MODULE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        // 开始互斥服务
        [[LiveService service] startService];
        [[NSUserDefaults standardUserDefaults] setObject:@"live" forKey:@"END_MODULE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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

#pragma mark - 数据逻辑

#pragma mark - LSLoginManager回调
- (void)manager:(LSLoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *_Nullable)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *_Nonnull)errmsg {
}

- (void)manager:(LSLoginManager *_Nonnull)manager onLogout:(BOOL)kick {
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

    // 刷新导航栏
    [self setupNavigationBar];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item == self.tabBarItemPublish) {
        // 点击开播按钮, 弹出预备开播界面
        tabBar.selectedItem = self.tabBarItemSelected;

    } else {
        // 切换内容界面
        for (UIViewController *viewController in self.viewControllers.allValues) {
            [viewController.view removeFromSuperview];
        }
        [self showCurrentViewController:item];
    }
}

- (void)tabBar:(UITabBar *)tabBar willBeginCustomizingItems:(NSArray<UITabBarItem *> *)items {
}

- (void)tabBar:(UITabBar *)tabBar didBeginCustomizingItems:(NSArray<UITabBarItem *> *)items {
}

- (void)tabBar:(UITabBar *)tabBar willEndCustomizingItems:(NSArray<UITabBarItem *> *)items changed:(BOOL)changed {
}

- (void)tabBar:(UITabBar *)tabBar didEndCustomizingItems:(NSArray<UITabBarItem *> *)items changed:(BOOL)changed {
}

#pragma mark - 内容界面通知
- (void)followingVCBrowseToHot {
    // TODO:从Following列表切换到Hot列表

    UITabBarItem *item = [self.tabBar.items objectAtIndex:0];
    [self showCurrentViewController:item];
}

#pragma mark - 获取用户中心未读数
- (void)reloadUnreadCount {
    // TODO:获取未读数量
    self.unreadCount = 0;
    [self.unreadCountManager getResevationsUnredCount];
}

- (void)onGetResevationsUnredCount:(BookingUnreadUnhandleNumItemObject *)item {
    // TODO:获取预约未读返回
    self.unreadCount = item.totalNoReadNum;
    [self.unreadCountManager getBackpackUnreadCount];
}

- (void)onGetBackpackUnreadCount:(GetBackPackUnreadNumItemObject *)item {
    // TODO:获取背包未读返回
    if (self.unreadCount == 0 && item.total > 0) {
        // TODO:显示红点
        LSUITabBarItem *tabBarItem = (LSUITabBarItem *)[self.tabBar.items objectAtIndex:2];
        tabBarItem.isShowNum = NO;
        tabBarItem.badgeValue = @"";
    } else {
        [self reloadUnreadMessage];
    }
}

- (void)reloadUnreadMessage {
    // TODO:刷新界面未读消息
    LSUITabBarItem *tabBarItem = (LSUITabBarItem *)[self.tabBar.items objectAtIndex:2];
    tabBarItem.isShowNum = YES;
    tabBarItem.badgeValue = nil;
    if (self.unreadCount == 0) {
        tabBarItem.badgeValue = nil;
    } else {
        if (self.unreadCount > 99) {
            tabBarItem.badgeValue = @"99+";
        } else {
            tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", self.unreadCount];
        }
    }
}

- (void)onRecvBackpackUpdateNotice:(BackpackInfoObject *)item {
    // TODO:接收背包更新通知
    [self reloadUnreadCount];
}

- (void)onRecvScheduledInviteUserNotice:(NSString *_Nonnull)inviteId anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    // TODO:接收主播预约私密邀请通知
    [self reloadUnreadCount];
}

- (void)onRecvSendBookingReplyNotice:(ImBookingReplyObject *_Nonnull)item {
    // TODO:接收预约私密邀请回复通知
    [self reloadUnreadCount];
}

- (void)onRecvBookingNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg leftSeconds:(int)leftSeconds {
    // TODO:接收预约开始倒数通知
    [self reloadUnreadCount];
}

#pragma mark - LiveUrlHandler通知
- (void)liveUrlHandler:(LiveUrlHandler *)handler openPreLive:(NSString *)roomId userId:(NSString *)userId roomType:(LiveRoomType)roomType {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 主动邀请], roomId : %@, userId : %@, roomType : %u )", roomId, userId, roomType);
    // TODO:主动邀请, 跳转过渡页
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];

    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomId = roomId;
    liveRoom.userId = userId;
    liveRoom.roomType = roomType;
    vc.liveRoom = liveRoom;

    [self navgationControllerPresent:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openInvited:(NSString *_Nullable)userName userId:(NSString *_Nullable)userId inviteId:(NSString *_Nullable)inviteId {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 应邀], userName : %@, userId : %@, inviteId : %@ )", userName, userId, inviteId);
    // TODO:收到通知进入应邀过渡页
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.userId = userId;
    liveRoom.userName = userName;

    LSInvitedToViewController *vc = [[LSInvitedToViewController alloc] init];
    vc.inviteId = inviteId;
    vc.liveRoom = liveRoom;

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
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:NO];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBooking:(NSString *)anchorId {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 新建预约页], anchorId : %@ )", anchorId);
    // TODO:收到通知进入新建预约页
    BookPrivateBroadcastViewController *bookPrivate = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    bookPrivate.userId = anchorId;
    [self.navigationController pushViewController:bookPrivate animated:NO];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBookingList:(int)bookType {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 预约列表页], bookType : %i )", bookType);
    // TODO:收到通知进入预约列表页
    LSMyReservationsViewController *reservation = [[LSMyReservationsViewController alloc] initWithNibName:nil bundle:nil];
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:reservation];
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBackpackList:(int)BackpackType {
    MyBackpackViewController *backPack = [[MyBackpackViewController alloc] initWithNibName:nil bundle:nil];
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:backPack];
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
}

- (void)liveUrlHandlerOpenAddCredit:(LiveUrlHandler *)handler {
    UIViewController *vc = [LiveModule module].addCreditVc;
    if (vc) {
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)liveUrlHandlerOpenMyLevel:(LiveUrlHandler *)handler {
    // TODO:进入我的等级界面
    MeLevelViewController *level = [[MeLevelViewController alloc] initWithNibName:nil bundle:nil];
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:level];
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
}

- (void)navgationControllerPresent:(UIViewController *)controller {
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
    nvc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    nvc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    nvc.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,nil];
    [nvc.navigationBar setTitleTextAttributes:attributes];
    [nvc.navigationItem setHidesBackButton:YES];
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
}

@end
