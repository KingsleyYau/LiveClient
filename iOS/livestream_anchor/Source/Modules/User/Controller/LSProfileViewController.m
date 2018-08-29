//
//  LSProfileViewController.m
//  livestream_anchor
//
//  Created by test on 2018/3/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSProfileViewController.h"

@interface LSProfileViewController ()
@property (nonatomic, strong) LSLiveWKWebViewController *urlController;
@property (nonatomic, strong) NSArray *cookies;
@end

@implementation LSProfileViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)initCustomParam {
    [super initCustomParam];
  
}

- (void)dealloc {
    NSLog(@"LSProfileViewController::dealloc()");
    [self.profileView stopLoading];
    [self hideAndResetLoading];
//    [self.profileView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveAnchorApp"];
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
        self.urlController.controller = self;
        self.urlController.liveWKWebView = self.profileView;
        self.urlController.isShowTaBar = YES;
        self.urlController.isRequestWeb = YES;
        self.urlController.baseUrl = self.profileUrl;
        // 加载webview时显示导航栏，加载完会隐藏的，不要不写，因为如果从这里到其它界面时，再回来会显示导航栏的
        [self.navigationController setNavigationBarHidden:NO];
        self.navigationController.navigationBar.hidden = NO;
        [self.urlController requestWebview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11, *)) {
        self.profileView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
        self.urlController = [[LSLiveWKWebViewController alloc] init];
}


@end
