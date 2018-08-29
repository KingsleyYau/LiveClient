//
//  IntroduceViewController.m
//  livestream
//
//  Created by test on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "IntroduceViewController.h"
#import "LSLiveWKWebViewManager.h"
#import "LiveModule.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface IntroduceViewController ()<WKUIDelegate,WKNavigationDelegate,LSLiveWKWebViewManagerDelegate>

@property (nonatomic, strong) LSLiveWKWebViewManager *urlManager;

@property (nonatomic, assign) BOOL isResume;
@property (nonatomic, assign) BOOL didFinshNav;
@end

@implementation IntroduceViewController

- (void)dealloc {
    NSLog(@"webViewController::dealloc()");
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

    self.urlManager = [[LSLiveWKWebViewManager alloc] init];
    self.urlManager.isShowTaBar = YES;
    self.urlManager.delegate = self;
    
    // webview请求url
    NSString *webSiteUrl = self.bannerUrl;
    self.urlManager.baseUrl = webSiteUrl;
    
    self.title = self.titleStr;
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
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
    if (!self.viewDidAppearEver) {
        self.urlManager.liveWKWebView = self.webView;
        self.urlManager.controller = self;
        self.urlManager.isShowTaBar = YES;
        [self.urlManager requestWebview];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self nativeTransferJavaScript];
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
