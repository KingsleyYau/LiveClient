//
//  PostStampViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/8/21.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PostStampViewController.h"
#import "LSRequestManager.h"
#import "LSConfigManager.h"
#import "IntroduceView.h"
#import "LSLiveWKWebViewManager.h"
#import "LiveModule.h"

@interface PostStampViewController ()<LSLiveWKWebViewManagerDelegate>

@property (weak, nonatomic) IBOutlet IntroduceView *webView;

@property (strong, nonatomic) LSLiveWKWebViewManager *urlManager;

@property (nonatomic, assign) BOOL isResume;
@property (nonatomic, assign) BOOL didFinshNav;
@end

@implementation PostStampViewController

- (void)dealloc {
    NSLog(@"PostStampViewController::dealloc()");
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
    self.urlManager.baseUrl = [LSConfigManager manager].item.postStampUrl;
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
