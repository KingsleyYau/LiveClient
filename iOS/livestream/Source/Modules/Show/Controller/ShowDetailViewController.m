//
//  ShowDetailViewController.m
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ShowDetailViewController.h"
#import "LSLiveWKWebViewManager.h"
#import "LiveModule.h"
#import "ShowAddCreditsView.h"
#import "AnchorPersonalViewController.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
@interface ShowDetailViewController ()<WKUIDelegate,WKNavigationDelegate,WebViewJSDelegate,LSLiveWKWebViewManagerDelegate>
// 内嵌web
@property (weak, nonatomic) IBOutlet IntroduceView *webView;

@property (nonatomic, strong) LSLiveWKWebViewManager *urlManager;

@property (nonatomic, assign) BOOL isResume;
@property (nonatomic, assign) BOOL didFinshNav;
@end

@implementation ShowDetailViewController

- (void)dealloc {
    NSLog(@"ShowDetailViewController::dealloc()");
    [self.webView stopLoading];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Show";
    
    self.isResume = NO;
    self.didFinshNav = NO;
    
    if (@available(iOS 11, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.webView.webViewJSDelegate = self;
    self.urlManager = [[LSLiveWKWebViewManager alloc] init];
    self.urlManager.isShowTaBar = YES;
    self.urlManager.delegate = self;
    NSString *webSiteUrl = self.urlManager.configManager.item.showDetailPage;
   
    if ([webSiteUrl containsString:@"?"]) {
       webSiteUrl = [NSString stringWithFormat:@"%@&live_show_id=%@",webSiteUrl,self.item.showLiveId];
    } else {
      webSiteUrl = [NSString stringWithFormat:@"%@?live_show_id=%@",webSiteUrl,self.item.showLiveId];
    }
    
    self.urlManager.baseUrl = webSiteUrl;
}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
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

- (void)getTicket {
    UIViewController *vc = [LiveModule module].addCreditVc;
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)WatchNow {
    
}

- (void)pushLadyDetail {
    AnchorPersonalViewController * vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = self.item.anchorId;
    [self.navigationController pushViewController:vc animated:YES];
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
