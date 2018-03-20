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
#import "HotViewController.h"
#import "LSMyCoinViewController.h"
#import "LSLoginManager.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LiveService.h"

#import "Masonry.h"

#import "LSInvitedToViewController.h"
#import "LSLiveGuideViewController.h"
#import "LSImManager.h"
#import "LSLoginViewController.h"
#import "IServiceManager.h"
@interface LSMainViewController () <LiveUrlHandlerDelegate, LoginManagerDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate,LSLiveGuideViewControllerDelegate,LiveModuleDelegate>
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

@property (strong, nonatomic) UIWindow *window;
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
    
    
    [LiveModule module].delegate = self;
//    if (![LiveModule module].moduleVC) {
//        // 设置模块主界面
//        [LiveModule module].fromVC = self;
//    }
}

- (void)dealloc {
    NSLog(@"LSMainViewController::dealloc()");
    
    // 去掉登录事件
    [self.loginManager removeDelegate:self];
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
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
    
    NSLog(@"LSMainViewController::viewWillAppear( animated : %@ )", BOOL2YES(animated));
    
    // 头部颜色
    self.navigationController.navigationBar.barTintColor = COLOR_WITH_16BAND_RGB(0x5D0E86);
    // 处理跳转URL
    [[LiveUrlHandler shareInstance] handleOpenURL];
    if (!self.viewDidAppearEver) {
        //        // 第一次进入, 判断是否已经登录
        //        [self checkLogin:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"LSMainViewController::viewDidAppear( animated : %@ )", BOOL2YES(animated));
    
    // 选中默认页
    UITabBarItem *tabBarItemDefault = [self.tabBar.items objectAtIndex:0];
    self.tabBar.selectedItem = tabBarItemDefault;
    [self showCurrentViewController:tabBarItemDefault];
    
    // 处理跳转URL
    [[LiveUrlHandler shareInstance] handleOpenURL];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        LSLiveGuideViewController *guide =  [[LSLiveGuideViewController alloc] initWithNibName:nil bundle:nil];
        guide.listGuide = YES;
        guide.guideDelegate = self;
        [self addChildViewController:guide];
        [self.view addSubview:guide.view];
        [guide.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(self.view);
        }];
        // 使约束生效
        [guide.view layoutSubviews];
        
    }else{

    }

    
}


/**
 新手引导结束
 
 @param guideViewController 新手引导控制器
 */
- (void)lsLiveGuideViewControllerDidFinishGuide:(LSLiveGuideViewController *)guideViewController {
    
    [guideViewController.view removeFromSuperview];
    [guideViewController removeFromParentViewController];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showNavigationBar" object:nil];
    
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    
    NSLog(@"LSMainViewController::willMoveToParentViewController( parent : %@ )", parent);
    
    if (!parent) {
        // 停止互斥服务
        [[LiveService service] closeService];
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"END_MODULE"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } else {
        // 开始互斥服务
        [[LiveService service] startService];
        [[NSUserDefaults standardUserDefaults]setObject:@"live" forKey:@"END_MODULE"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"LSMainViewController::viewWillDisappear( animated : %@ )", BOOL2YES(animated));
    
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:19]}];
    
    UIViewController *viewController = [self.viewControllers objectForKey:@(self.tabBarItemSelected.tag)];
    self.navigationItem.titleView = viewController.navigationItem.titleView;
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems;
}

#pragma mark - LiveModuleDelegate
- (void)moduleOnNotification:(LiveModule *)module {
    NSLog(@"LSMainViewController::moduleOnNotification()");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        
        UIViewController *vc = [LiveModule module].notificationVC;
        CGRect frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20 + 5, self.view.frame.size.width, vc.view.frame.size.height);
        self.window = [[UIWindow alloc] initWithFrame:frame];
        self.window.windowLevel = UIWindowLevelAlert + 1;
        UIWindow *parentView = self.window;
        [self.window addSubview:vc.view];
        [self.window makeKeyAndVisible];
        
        [vc.view mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(@0);
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
- (void)manager:(LSLoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(LSManBaseInfoItemObject *_Nullable)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *_Nonnull)errmsg {

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
        
        AppDelegate().window.rootViewController = loginVC;

    });
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
    
    [self navgationControllerPresent:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openInvited:(NSString *_Nullable)userName userId:(NSString *_Nullable)userId inviteId:(NSString *_Nullable)inviteId {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 应邀], userName : %@, userId : %@, inviteId : %@ )", userName, userId, inviteId);
    
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.userId = userId;
    liveRoom.userName = userName;
    
    // 收到通知进入应邀过渡页
    LSInvitedToViewController *vc = [[LSInvitedToViewController alloc] init];
    vc.inviteId = inviteId;
    vc.liveRoom = liveRoom;
    
    [self navgationControllerPresent:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openMainType:(int)index {
    
    [self.navigationController popToViewController:self animated:YES];
    UITabBarItem *tabBarItemDefault = [self.tabBar.items objectAtIndex:0];
    self.tabBar.selectedItem = tabBarItemDefault;
    [self showCurrentViewController:tabBarItemDefault];
    LSHomePageViewController *viewController = (LSHomePageViewController *)[self.viewControllers objectForKey:@(tabBarItemDefault.tag)];
    [viewController.pagingScrollView displayPagingViewAtIndex:index animated:NO];
}

//- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openMainType:(int)index isForTest:(BOOL)forTest{
//
//    [self.navigationController popToViewController:self animated:YES];
//    UITabBarItem *tabBarItemDefault = [self.tabBar.items objectAtIndex:0];
//    self.tabBar.selectedItem = tabBarItemDefault;
//    [self showCurrentViewController:tabBarItemDefault];
//    LSHomePageViewController *viewController = (LSHomePageViewController *)[self.viewControllers objectForKey:@(tabBarItemDefault.tag)];
//    [viewController.pagingScrollView displayPagingViewAtIndex:index animated:YES];
//
//
//}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openAnchorDetail:(NSString *)anchorId {
    
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:NO];
    
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBooking:(NSString *)anchorId {
    BookPrivateBroadcastViewController *bookPrivate = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    bookPrivate.userId = anchorId;
    [self.navigationController pushViewController:bookPrivate animated:NO];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBookingList:(int)bookType {
    // TODO:进入预约列表界面
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
    LSMyCoinViewController *myCoin = [[LSMyCoinViewController alloc] initWithNibName:nil bundle:nil];
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:myCoin];
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
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
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
    [nvc.navigationBar setTitleTextAttributes:attributes];
    [nvc.navigationItem setHidesBackButton:YES];
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
}

@end
