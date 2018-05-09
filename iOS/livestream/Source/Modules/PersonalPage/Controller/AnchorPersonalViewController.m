//
//  AnchorPersonalViewController.m
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AnchorPersonalViewController.h"

#import "PreLiveViewController.h"

#import "MeLevelViewController.h"
#import "LSLiveWKWebViewController.h"
#import "LSLiveGuideViewController.h"
#import "LiveModule.h"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface AnchorPersonalViewController ()<LSLiveGuideViewControllerDelegate>

@property (nonatomic, strong) LSLiveWKWebViewController *urlController;

@end

@implementation AnchorPersonalViewController

- (void)dealloc {
    NSLog(@"AnchorPersonalViewController::dealloc()");
    [self.personalView stopLoading];
    [self.personalView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11, *)) {
        self.personalView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tabType = 0;
    
    self.urlController = [[LSLiveWKWebViewController alloc] init];
    self.urlController.isShowTaBar = NO;
    self.urlController.isRequestWeb = YES;
    
    NSString *anchorPage = self.urlController.configManager.item.anchorPage;
    NSString *device; // 设备类型
    NSString *anchorid = [NSString stringWithFormat:@"anchorid=%@",self.anchorId]; // 主播id;
    NSString *enterroom = [NSString stringWithFormat:@"&enterroom=%d",self.enterRoom];
    if (anchorPage.length > 0) {
        if (IS_IPAD) {
            device = [NSString stringWithFormat:@"device=32"];
        } else {
            device = [NSString stringWithFormat:@"device=31"];
        }
        NSString *appVer = [NSString stringWithFormat:@"appver=%@",[LiveModule module].appVerCode];
        if ([anchorPage containsString:@"?"]) {
            anchorPage = [NSString stringWithFormat:@"%@&%@&%@&%@%@",anchorPage,device,appVer,anchorid,enterroom];
        } else {
            anchorPage = [NSString stringWithFormat:@"%@?%@%@&%@%@",anchorPage,device,appVer,anchorid,enterroom];
        }
    }
    
    anchorPage = [NSString stringWithFormat:@"%@&tabtype=%ld",anchorPage,self.tabType];
    
    self.urlController.baseUrl = anchorPage;
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)setupContainView{
    [super setupContainView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    if (!self.viewDidAppearEver) {
//        self.navigationController.navigationBar.hidden = NO;
//        [self.navigationController setNavigationBarHidden:NO];
//        self.navigationController.navigationBar.translucent = NO;
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
//
//    if (!self.navigationController.navigationBar.hidden) {
//        self.navigationController.navigationBar.hidden = YES;
//        [self.navigationController setNavigationBarHidden:YES];
//    }
    //    else {
    //
    //    }
    //    [self.navigationController setNavigationBarHidden:NO];
    //    self.urlController.liveWKWebView = self.personalView;
    //    self.urlController.controller = self;
    //    [self.urlController requestWebview];
}

- (void)viewDidAppear:(BOOL)animated {
    
    // 出现新手引导不加载webview,防止进入新手引导页会出现加载loading的状态
    // 屏蔽新手引导功能
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
//        LSLiveGuideViewController *guide =  [[LSLiveGuideViewController alloc] initWithNibName:nil bundle:nil];
//        guide.listGuide = NO;
//        guide.guideDelegate = self;
//        [self addChildViewController:guide];
//        [self.view addSubview:guide.view];
//        [guide.view mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.view);
//            make.left.equalTo(self.view);
//            make.width.equalTo(self.view);
//            make.height.equalTo(self.view);
//        }];
//        // 使约束生效
//        [guide.view layoutSubviews];
//        [self hideAndResetLoading];
//    }else{
        if (!self.viewDidAppearEver) {
            self.urlController.liveWKWebView = self.personalView;
            self.urlController.controller = self;
            self.urlController.isShowTaBar = NO;
            self.urlController.isRequestWeb = YES;
            // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
            [self.navigationController setNavigationBarHidden:NO];
            self.navigationController.navigationBar.hidden = NO;
            [self.urlController requestWebview];
        } else {
            // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
            [self.navigationController setNavigationBarHidden:YES];
            self.navigationController.navigationBar.hidden = YES;
        }
//    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideAndResetLoading];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}


- (void)lsLiveGuideViewControllerDidFinishGuide:(LSLiveGuideViewController *)guideViewController {
    //TODO:新手引导页退出导航栏操作
    //    self.navigationController.navigationBar.hidden = YES;
    if (@available(iOS 11, *)) {
        self.personalView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [guideViewController.view removeFromSuperview];
    
    self.urlController.liveWKWebView = self.personalView;
    self.urlController.controller = self;
    self.urlController.isShowTaBar = NO;
    self.urlController.isRequestWeb = YES;
    [self.urlController requestWebview];
}
@end
