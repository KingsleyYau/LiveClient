//
//  IntroduceViewController.m
//  livestream
//
//  Created by test on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "IntroduceViewController.h"
#import "LSLiveWKWebViewController.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface IntroduceViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) LSLiveWKWebViewController *urlController;

@end

@implementation IntroduceViewController

- (void)dealloc {
    NSLog(@"IntroduceViewController::dealloc()");
    [self.introduceView stopLoading];
    [self.introduceView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 11, *)) {
     self.introduceView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.urlController = [[LSLiveWKWebViewController alloc] init];
    self.urlController.isShowTaBar = YES;
    self.urlController.isRequestWeb = YES;

    // webview请求url
    NSString *webSiteUrl = self.bannerUrl;
    NSString *device; // 设备类型
    if (webSiteUrl.length > 0) {
        if (IS_IPAD) {
            device = [NSString stringWithFormat:@"device=32"];
        } else {
            device = [NSString stringWithFormat:@"device=31"];
        }
        if ([webSiteUrl containsString:@"?"]) {
            webSiteUrl = [NSString stringWithFormat:@"%@&%@",webSiteUrl,device];
        } else {
            webSiteUrl = [NSString stringWithFormat:@"%@?%@",webSiteUrl,device];
        }
    }
    self.urlController.baseUrl = webSiteUrl;
    
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
//    [self.navigationController setNavigationBarHidden:NO];
        self.navigationController.navigationBar.hidden = NO;
    if (!self.viewDidAppearEver) {
        self.urlController.liveWKWebView = self.introduceView;
        self.urlController.controller = self;
        self.urlController.isShowTaBar = YES;
        self.urlController.isRequestWeb = YES;
        [self.urlController requestWebview];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideAndResetLoading];
//    [self.navigationController setNavigationBarHidden:NO];
    
        self.navigationController.navigationBar.hidden = NO;
}



@end
