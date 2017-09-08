//
//  MainViewController.m
//  livestream
//
//  Created by Max on 2017/5/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MainViewController.h"

#import "TestViewController.h"
#import "HomePageViewController.h"

#import "LoginManager.h"

#import "Masonry.h"

@interface MainViewController () <LoginManagerDelegate>

/**
 内容页
 */
@property (strong) NSDictionary<NSNumber*, UIViewController*>* viewControllers;

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
@property (nonatomic, strong) LoginManager *loginManager;

@end

@implementation MainViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
 
    // 监听登录事件
    self.loginManager = [LoginManager manager];
    [self.loginManager addDelegate:self];
}

- (void)dealloc {
    // 去掉登录事件
    [self.loginManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 主播列表
    HomePageViewController* vcHome = [[HomePageViewController alloc] initWithNibName:nil bundle:nil];
    vcHome.tabBarItem.tag = 0;
    vcHome.tabBarItem.title = nil;
    [self addChildViewController:vcHome];
    
    // 开播选项
    self.tabBarItemPublish = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarShow"] tag:1];
    self.tabBarItemPublish.imageInsets = UIEdgeInsetsMake(-10, 0, 10, 0);
    
    // 个人中心
    TestViewController* vcTest = [[TestViewController alloc] initWithNibName:nil bundle:nil];
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
    
    // 选中默认页
    UITabBarItem* tabBarItemDefault = [self.tabBar.items objectAtIndex:0];
    self.tabBar.selectedItem = tabBarItemDefault;
    [self showCurrentViewController:tabBarItemDefault];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if( !self.viewDidAppearEver ) {
//        // 第一次进入, 判断是否已经登录
//        [self checkLogin:NO];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    UIViewController* viewController = [self.viewControllers objectForKey:@(self.tabBarItemSelected.tag)];
    self.navigationItem.titleView = viewController.navigationItem.titleView;
    self.navigationItem.leftBarButtonItems = viewController.navigationItem.leftBarButtonItems;
    self.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 数据逻辑
- (void)checkLogin:(BOOL)animated {
//    // 如果曾经登录成功
//    if( [self.loginManager everLoginSuccess] ) {
//        // 跳进广告界面
//        WelcomeViewController* vc = [[WelcomeViewController alloc] initWithNibName:nil bundle:nil];
//        KKNavigationController *nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
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
//        KKNavigationController *nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
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

- (void)showAlert4Relogin:(NSString *)errmsg {
//    // 收起欢迎界面
//    [self.welcomeVC dismissViewControllerAnimated:NO completion:nil];
////    // 收起发布界面
////    [self.prePublishVC dismissViewControllerAnimated:NO completion:nil];
//    
//    // 弹出错误提示
//    UIAlertController* alertView = [UIAlertController alertControllerWithTitle:nil
//                                                                       message:errmsg
//                                                                preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction *action = nil;
//    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        // 跳进登录界面
//        [self.navigationController popToRootViewControllerAnimated:NO];
//        
//        LoginViewController *vc = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
//        KKNavigationController *nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
//        self.loginVC = vc;
//        
//        [nvc.navigationBar setTranslucent:self.navigationController.navigationBar.translucent];
//        [nvc.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
//        [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
//        
//        [self presentViewController:nvc animated:YES completion:nil];
//    }];
//    [alertView addAction:action];
//
//    // 弹出到主界面
//    [self.navigationController popToRootViewControllerAnimated:NO];
//    
//    // 弹出提示
//    [self presentViewController:alertView animated:YES completion:nil];
}

#pragma mark - LoginManager回调
- (void)manager:(LoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject * _Nullable)loginItem errnum:(NSInteger)errnum errmsg:(NSString * _Nonnull)errmsg {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"MainViewController::onLogin( [%@], errnum : %ld )", success?@"Success":@"Fail", (long)errnum);
//        if( !success ) {
//            if( errnum == LOGIN_BY_OTHER_DEVICE ) {
//                // 账号已经在其他设备登录
//                
//                [self showAlert4Relogin:errmsg];
//            }
//        }
//    });
}

- (void)manager:(LoginManager * _Nonnull)manager onLogout:(BOOL)kick {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"MainViewController::onLogout( [%@] )", kick?@"手动注销/被踢":@"Session超时");
//        if( kick ) {
//            // 被踢
//        
//            [self showAlert4Relogin:@"You have been kick"];
//        }
//    });
}

#pragma mark - 内容界面切换逻辑
- (void)showCurrentViewController:(UITabBarItem *)item {
    UIViewController* viewController = [self.viewControllers objectForKey:@(item.tag)];
    [self.tabContainView addSubview:viewController.view];
    
    [viewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tabContainView);
        make.left.equalTo(self.tabContainView);
        make.width.equalTo(self.tabContainView);
        make.height.equalTo(self.tabContainView);
    }];
    
    // 刷新底部Tab
    self.tabBarItemSelected = item;
    
    // 刷新导航栏
    [self setupNavigationBar];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if( item == self.tabBarItemPublish ) {
        // 点击开播按钮, 弹出预备开播界面
        tabBar.selectedItem = self.tabBarItemSelected;
        
    } else {
        // 切换内容界面
        for(UIViewController* viewController in self.viewControllers.allValues) {
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

@end
