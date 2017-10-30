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

#import "LSLoginManager.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LiveService.h"

#import "Masonry.h"

#import "LSInvitedToViewController.h"

#import "LSImManager.h"


@interface LSMainViewController () <LiveUrlHandlerDelegate, LoginManagerDelegate,IMManagerDelegate,IMLiveRoomManagerDelegate>
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

@property (nonatomic, strong) LSImManager *imManager;

@end

@implementation LSMainViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"LSMainViewController::initCustomParam()");

    // 监听登录事件
    self.loginManager = [LSLoginManager manager];
    [self.loginManager addDelegate:self];

    // 路径跳转
    self.handler = [LiveUrlHandler shareInstance];
    self.handler.delegate = self;
    
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
}

- (void)dealloc {
    NSLog(@"LSMainViewController::dealloc()");

    // 去掉登录事件
    [self.loginManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 主播列表
    LSHomePageViewController *vcHome = [[LSHomePageViewController alloc] initWithNibName:nil bundle:nil];
    vcHome.tabBarItem.tag = 0;
    vcHome.tabBarItem.title = nil;
    [self addChildViewController:vcHome];

    // 开播选项
    self.tabBarItemPublish = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarShow"] tag:1];
    self.tabBarItemPublish.imageInsets = UIEdgeInsetsMake(-10, 0, 10, 0);

    // 个人中心
    StreamTestViewController *vcTest = [[StreamTestViewController alloc] initWithNibName:nil bundle:nil];
    vcTest.tabBarItem.tag = 2;
    vcTest.tabBarItem.title = nil;
    [self addChildViewController:vcTest];

    // 初始化内容界面
    self.viewControllers = [NSDictionary dictionaryWithObjectsAndKeys:
                                             vcHome, @(vcHome.tabBarItem.tag),
                                             vcTest, @(vcTest.tabBarItem.tag),
                                             nil];

    // 初始化底部TabBar
    self.tabBar.items = [NSArray arrayWithObjects:vcHome.tabBarItem, self.tabBarItemPublish, vcTest.tabBarItem, nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 头部颜色
    self.navigationController.navigationBar.barTintColor = COLOR_WITH_16BAND_RGB(0x5D0E86);

    if (!self.viewDidAppearEver) {
        //        // 第一次进入, 判断是否已经登录
        //        [self checkLogin:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 选中默认页
    UITabBarItem *tabBarItemDefault = [self.tabBar.items objectAtIndex:0];
    self.tabBar.selectedItem = tabBarItemDefault;
    [self showCurrentViewController:tabBarItemDefault];
    
    // 处理跳转URL
    [[LiveUrlHandler shareInstance] handleOpenURL];
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent {
    [super willMoveToParentViewController:parent];

    NSLog(@"LSMainViewController::willMoveToParentViewController( parent : %@ )", parent);
    
    if (!parent) {
        // 还原导航栏颜色
        self.navigationController.navigationBar.tintColor = [LiveModule module].tintColor;
        self.navigationController.navigationBar.barTintColor = [LiveModule module].barTintColor;
        [self.navigationController.navigationBar setTitleTextAttributes:[LiveModule module].barTitleTextAttributes];
        
        // 停止互斥服务
        [[LiveService service] closeService];
    } else {
        // 开始互斥服务
        [[LiveService service] startService];
    }
}

- (void)setupNavigationBar {
    [super setupNavigationBar];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:19]}];

    UIViewController *viewController = [self.viewControllers objectForKey:@(self.tabBarItemSelected.tag)];
    self.navigationItem.titleView = viewController.navigationItem.titleView;
    self.navigationItem.leftBarButtonItems = viewController.navigationItem.leftBarButtonItems;
    self.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems;
}

#pragma mark - 数据逻辑
- (void)checkLogin:(BOOL)animated {
    //    // 如果曾经登录成功
    //    if( [self.loginManager everLoginSuccess] ) {
    //        // 跳进广告界面
    //        WelcomeViewController* vc = [[WelcomeViewController alloc] initWithNibName:nil bundle:nil];
    //        LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:vc];
    //        self.welcomeVC = vc;
    //
    //        [nvc.navigationBar setTranslucent:self.navigationController.navigationBar.translucent];
    //        [nvc.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
    //        [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
    //
    //        [self presentViewController:nvc animated:animated completion:nil];
    //
    //    } else {
    //        // 从来没登录, 跳进登录界面
    //        LoginViewController *vc = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    //        LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:vc];
    //        self.loginVC = vc;
    //
    //        [nvc.navigationBar setTranslucent:self.navigationController.navigationBar.translucent];
    //        [nvc.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
    //        [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
    //
    //        [self presentViewController:nvc animated:animated completion:nil];
    //
    //    }
}

#pragma mark - LSLoginManager回调
- (void)manager:(LSLoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *_Nullable)loginItem errnum:(NSInteger)errnum errmsg:(NSString *_Nonnull)errmsg {
}

- (void)manager:(LSLoginManager *_Nonnull)manager onLogout:(BOOL)kick {
}

#pragma mark - 内容界面切换逻辑
- (void)showCurrentViewController:(UITabBarItem *)item {
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

    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openInvited:(NSString *_Nullable)userName userId:(NSString *_Nullable)userId inviteId:(NSString *_Nullable)inviteId {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 应邀], userName : %@, userId : %@, inviteId : %@ )", userName, userId, inviteId);
    
}

- (void)onRecvInstantInviteUserNotice:(NSString *_Nonnull)inviteId anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    
    NSLog(@"LiveModule::onRecvInstantInviteUserNotice( [接收主播立即私密邀请通知], inviteId : %@, userId : %@, userName : %@, msg : %@ )",inviteId, anchorId, nickName, msg);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        LiveRoom *liveRoom = [[LiveRoom alloc] init];
        liveRoom.userId = anchorId;
        liveRoom.userName = nickName;
        
        // 测试用 收到通知进入应邀过渡页
        LSInvitedToViewController *controller = [[LSInvitedToViewController alloc] init];
        controller.inviteId = inviteId;
        controller.avatarUrl = avatarImg;
        controller.liveRoom = liveRoom;
        [self navgationControllerPresent:controller];
    });
}


- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openMainType:(int)index {
    UITabBarItem *tabBarItemDefault = [self.tabBar.items objectAtIndex:0];
    self.tabBar.selectedItem = tabBarItemDefault;
    [self showCurrentViewController:tabBarItemDefault];
    LSHomePageViewController *viewController = (LSHomePageViewController *)[self.viewControllers objectForKey:@(tabBarItemDefault.tag)];
    [viewController.pagingScrollView displayPagingViewAtIndex:index animated:YES];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openAnchorDetail:(NSString *)anchorId {
    LiveChannelAdViewController *adVc = [[LiveChannelAdViewController alloc] initWithNibName:nil bundle:nil];
    //  设置透明底
    adVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:adVc animated:YES completion:nil];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBooking:(NSString *)anchorId {
    BookPrivateBroadcastViewController *bookPrivate = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    bookPrivate.userId = anchorId;
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:bookPrivate];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBookingList:(int)bookType {
    //TODO:进入预约列表界面
    LSMyReservationsViewController *reservation = [[LSMyReservationsViewController alloc] initWithNibName:nil bundle:nil];
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:reservation];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBackpackList:(int)BackpackType {
    MyBackpackViewController *backPack = [[MyBackpackViewController alloc] initWithNibName:nil bundle:nil];
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:backPack];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)liveUrlHandlerOpenAddCredit:(LiveUrlHandler *)handler {
    
}


- (void)liveUrlHandlerOpenMyLevel:(LiveUrlHandler *)handler {
    //TODO:进入我的等级界面
    MeLevelViewController *level = [[MeLevelViewController alloc] initWithNibName:nil bundle:nil];
    LSNavigationController* nvc = [[LSNavigationController alloc] initWithRootViewController:level];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)navgationControllerPresent:(UIViewController *)controller {
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
    nvc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    nvc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    nvc.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

@end
