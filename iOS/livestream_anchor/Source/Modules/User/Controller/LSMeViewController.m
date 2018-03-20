//
//  LSMeViewController.m
//  livestream_anchor
//
//  Created by test on 2018/3/6.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMeViewController.h"
#import "LSLiveWKWebViewController.h"
#import "LSLoginManager.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface LSMeViewController ()
@property (nonatomic, strong) LSLiveWKWebViewController *urlController;
@property (nonatomic, strong) LSLoginManager *loginManager;
@end

@implementation LSMeViewController



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)initCustomParam {
    [super initCustomParam];
    
    // Items for tab
    LSUITabBarItem *tabBarItem = [[LSUITabBarItem alloc] init];
    self.tabBarItem = tabBarItem;
    //    self.tabBarItem.title = @"Me";
    self.tabBarItem.image = [[UIImage imageNamed:@"TabBarMe"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBarMe-Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSDictionary *normalColor = [NSDictionary dictionaryWithObject:Color(51, 51, 51, 1) forKey:NSForegroundColorAttributeName];
    NSDictionary *selectedColor = [NSDictionary dictionaryWithObject:Color(52, 120, 247, 1) forKey:NSForegroundColorAttributeName];
    [self.tabBarItem setTitleTextAttributes:normalColor forState:UIControlStateNormal];
    [self.tabBarItem setTitleTextAttributes:selectedColor forState:UIControlStateSelected];

    UIBarButtonItem * btnItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromSelf(@"Logout") style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    btnItem.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = btnItem;
}


- (void)dealloc {
    NSLog(@"AnchorPersonalViewController::dealloc()");
    [self.meView stopLoading];
    [self hideAndResetLoading];
    [self.meView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self hideAndResetLoading];
}


- (void)setupNavigationBar {
    [super setupNavigationBar];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.urlController.liveWKWebView = self.meView;
    self.urlController.controller = self;
    self.urlController.isShowTaBar = YES;
    self.urlController.isRequestWeb = YES;
    // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
    [self.urlController requestWebview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginManager = [LSLoginManager manager];
    if (@available(iOS 11, *)) {
        self.meView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.urlController = [[LSLiveWKWebViewController alloc] init];
    self.urlController.isRequestWeb = YES;
    
    NSString *anchorPage = self.urlController.configManager.item.mePageUrl;
    NSString *device; // 设备类型
    if (anchorPage.length > 0) {
        if (IS_IPAD) {
            device = [NSString stringWithFormat:@"device=32"];
        } else {
            device = [NSString stringWithFormat:@"device=31"];
        }

    }
    self.urlController.baseUrl = anchorPage;
}


- (void)logout {
    UIAlertController * alertView = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Logout_msg") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.loginManager logout:YES msg:@""];
    }];
    [alertView addAction:cancelAction];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
}

@end
