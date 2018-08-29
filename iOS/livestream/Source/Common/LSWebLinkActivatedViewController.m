//
//  LSWebLinkActivatedViewController.m
//  livestream
//
//  Created by test on 2018/5/17.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSWebLinkActivatedViewController.h"

@interface LSWebLinkActivatedViewController ()
@property (nonatomic, strong) LSLiveWKWebViewManager *urlManager;
@property (nonatomic, strong) NSArray *cookies;
@end

@implementation LSWebLinkActivatedViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)initCustomParam {
    [super initCustomParam];
    
}

- (void)dealloc {
    NSLog(@"LSWebLinkActivatedViewController::dealloc()");
    [self.commonWeb stopLoading];
    [self hideAndResetLoading];
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
    if (!self.viewDidAppearEver) {
        self.urlManager.controller = self;
        self.urlManager.liveWKWebView = self.commonWeb;
        self.urlManager.isShowTaBar = YES;
        self.urlManager.isRequestWeb = YES;
        self.urlManager.baseUrl = self.linkActivatedUrl;
        // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
        [self.navigationController setNavigationBarHidden:NO];
        self.navigationController.navigationBar.hidden = NO;
        [self.urlManager requestWebview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11, *)) {
        self.commonWeb.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.urlManager = [[LSLiveWKWebViewManager alloc] init];
}


@end
