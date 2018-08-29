//
//  LiveWebViewController.m
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveWebViewController.h"
#import "LSRequestManager.h"
#import "LSConfigManager.h"
#import "IntroduceView.h"
#import "LSLiveWKWebViewManager.h"
#import "LiveModule.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface LiveWebViewController ()<LSLiveWKWebViewManagerDelegate>

@property (weak, nonatomic) IBOutlet IntroduceView *webView;

@property (nonatomic, strong) LSLiveWKWebViewManager *urlManager;

@property (nonatomic, assign) BOOL isResume;
@property (nonatomic, assign) BOOL didFinshNav;
@end

@implementation LiveWebViewController
- (void)dealloc {
    NSLog(@"LiveWebViewController::dealloc()");
    [self.webView stopLoading];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isResume = NO;
    self.didFinshNav = NO;
    
    self.urlManager = [[LSLiveWKWebViewManager alloc] init];
    self.urlManager.isShowTaBar = YES;
    self.urlManager.isFirstProgram = YES;
    self.urlManager.delegate = self;
    
    NSString *intimacyUrl; // 拼接url
//    NSString *appVer = [NSString stringWithFormat:@"appver=%@",[LiveModule module].appVerCode];
    NSString *anchorID = [NSString stringWithFormat:@"&anchorid=%@",self.anchorId];
//    NSString *device; // 设备类型
//    if (IS_IPAD) {
//        device = [NSString stringWithFormat:@"device=32"];
//    } else {
//        device = [NSString stringWithFormat:@"device=31"];
//    }
    
    if (self.isIntimacy) {
        NSString *webSiteUrl = self.urlManager.configManager.item.intimacy;
        if (webSiteUrl.length > 0) {
            if ([webSiteUrl containsString:@"?"]) {
                intimacyUrl = [NSString stringWithFormat:@"%@&%@",webSiteUrl,anchorID];
            } else {
                intimacyUrl = [NSString stringWithFormat:@"%@?%@",webSiteUrl,anchorID];
            }
        }
    } else {
        intimacyUrl = self.url;
        if (!_isUserProtocol) {
            if (![intimacyUrl containsString:@"?"])
                intimacyUrl = [NSString stringWithFormat:@"%@?%@",intimacyUrl,anchorID];
            }

    }
    self.urlManager.baseUrl = intimacyUrl;
}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)setupContainView {
    [super setupContainView];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示导航栏
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
     [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:19]}];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.urlManager.isFirstProgram = YES;
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
