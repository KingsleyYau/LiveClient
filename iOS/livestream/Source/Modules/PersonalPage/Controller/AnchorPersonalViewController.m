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
#import "LSLiveWKWebViewManager.h"
#import "LSLiveGuideViewController.h"
#import "LiveModule.h"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface AnchorPersonalViewController ()<LSLiveWKWebViewManagerDelegate>

@property (nonatomic, strong) LSLiveWKWebViewManager *urlManager;

@property (nonatomic, assign) BOOL isResume;
@property (nonatomic, assign) BOOL didFinshNav;
@end

@implementation AnchorPersonalViewController

- (void)dealloc {
    NSLog(@"AnchorPersonalViewController::dealloc()");
    [self.webView stopLoading];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isResume = NO;
    self.didFinshNav = NO;
    
    if (@available(iOS 11, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tabType = 0;
    
    self.urlManager = [[LSLiveWKWebViewManager alloc] init];
    self.urlManager.isShowTaBar = NO;
    // 设置可以点击进入节目界面（防止多次点击）
    self.urlManager.isFirstProgram = YES;
    self.urlManager.delegate = self;
    
    NSString *anchorPage = self.urlManager.configManager.item.anchorPage;
    NSString *anchorid = [NSString stringWithFormat:@"anchorid=%@",self.anchorId]; // 主播id;
    NSString *enterroom = [NSString stringWithFormat:@"enterroom=%d",self.enterRoom];
    NSString *tabType = [NSString stringWithFormat:@"tabtype=%d",(int)self.tabType];
    
    if ([anchorPage containsString:@"?"]) {
        anchorPage = [NSString stringWithFormat:@"%@&%@&%@&%@",anchorPage,anchorid,enterroom,tabType];
    } else {
        anchorPage = [NSString stringWithFormat:@"%@?%@%@&%@",anchorPage,anchorid,enterroom,tabType];
    }
    
    self.urlManager.baseUrl = anchorPage;
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
    NSLog(@"AnchorPersonalViewController::viewWillAppear( animated : %@ )", BOOL2YES(animated));
    if (self.urlManager != nil) {
        self.urlManager.isFirstProgram = YES;
    }
    if (!self.viewDidAppearEver) {
        self.urlManager.liveWKWebView = self.webView;
        self.urlManager.controller = self;
        self.urlManager.isShowTaBar = NO;
        // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
        [self.navigationController setNavigationBarHidden:NO];
        self.navigationController.navigationBar.hidden = NO;
        [self.urlManager requestWebview];
    } else {
        // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
        [self.navigationController setNavigationBarHidden:YES];
        self.navigationController.navigationBar.hidden = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self nativeTransferJavaScript];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"AnchorPersonalViewController::viewWillDisappear( animated : %@ )", BOOL2YES(animated));
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
    [self hideAndResetLoading];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"AnchorPersonalViewController::viewDidDisappear( animated : %@ )", BOOL2YES(animated));

}

- (void)nativeTransferJavaScript {
    if (self.isResume && self.didFinshNav) {
        [self.webView webViewTransferResumeHandler:^(id  _Nullable response, NSError * _Nullable error) {
        }];
    }
}

#pragma mark - LSLiveWKWebViewManagerDelegate
- (void)webViewTransferJSIsResume:(BOOL)isResume {
    self.isResume = isResume;
}

- (void)webViewDidFinishNavigation {
    self.didFinshNav = YES;
    if (self.viewDidAppearEver) {
        [self nativeTransferJavaScript];
    }
}

@end
