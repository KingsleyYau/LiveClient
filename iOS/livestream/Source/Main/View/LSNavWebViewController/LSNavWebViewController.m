//
//  LSNavWebViewController.m
//  livestream
//
//  Created by test on 2018/6/11.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSNavWebViewController.h"
#import "LiveModule.h"
#import "LSLiveWKWebViewManager.h"
#define NavNormalHeight 64
#define NavIphoneXHeight 88

@interface LSNavWebViewController ()<UIScrollViewDelegate,LSLiveWKWebViewManagerDelegate>
@property (nonatomic, strong) LSLiveWKWebViewManager *urlManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewTopDistance;
/** 顶部标题 */
@property (nonatomic, strong) UILabel *navTitleLabel;

@property (nonatomic, assign) BOOL didFinshNav;
@end

@implementation LSNavWebViewController

- (void)dealloc {
    NSLog(@"LSNavWebViewController::dealloc()");
    [self.webView stopLoading];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"LiveApp"];
    // 在9.0上需清空代理,会导致crash
    self.webView.scrollView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.didFinshNav = NO;
    
    if (@available(iOS 11, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.urlManager = [[LSLiveWKWebViewManager alloc] init];
    self.urlManager.delegate = self;
    self.webView.scrollView.delegate = self;
    // 设置可以点击进入节目界面（防止多次点击）
//    self.urlManager.isFirstProgram = YES;
//    [self setNeedsNavigationBackground:0];
    self.navTitleLabel = [[UILabel alloc] init];

    
    if (self.alphaType) {
          if ([LSDevice iPhoneXStyle]) {
              self.webViewTopDistance.constant = -NavIphoneXHeight;
          }else {
              self.webViewTopDistance.constant = -NavNormalHeight;
          }
        self.navTitleLabel.alpha = 0;
    }else {
        self.webViewTopDistance.constant = 0;
        self.navTitleLabel.alpha = 1;
    }
    self.urlManager.baseUrl = self.url;
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
    // 跟踪显示屏幕
    //[[LiveModule module].analyticsManager reportShowWebScreen:self];
    [self hideNavgationBarBottomLine:YES];
    
    if (!self.viewDidAppearEver) {
        self.urlManager.liveWKWebView = self.webView;
        self.urlManager.controller = self;
        self.urlManager.isShowTaBar = YES;
        self.urlManager.isFirstProgram = YES;
        [self.urlManager requestWebview];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navTitleLabel.text = self.navTitle;
    [self.navTitleLabel sizeToFit];
    self.navigationItem.titleView = self.navTitleLabel;
    
    // 每次进来判断是否需要显示导航栏的透明的状态,防止跳转下一页返回透明状态不准确的问题
    if (self.alphaType) {
        [self setupAlphaStatus:self.webView.scrollView];
    }else {
        [self setNeedsNavigationBackground:1];
    }
    
    [self.urlManager resetFirstProgram];
    
    [self nativeTransferJavaScript];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 跟踪屏幕消失
//    [[LiveModule module].analyticsManager reportDismissWebScreen:self];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self hideAndResetLoading];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)nativeTransferJavaScript {
    if (self.isResume && self.didFinshNav) {
        [self.webView webViewTransferResumeHandler:^(id  _Nullable response, NSError * _Nullable error) {
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.alphaType) {
        [self setupAlphaStatus:scrollView];
    }
}

// 设置透明状态
- (void)setupAlphaStatus:(UIScrollView *)scrollView {
    CGFloat navHeight = NavNormalHeight;
    
    if ([LSDevice iPhoneXStyle]) {
        navHeight = NavIphoneXHeight;
    }
    
    CGFloat per = scrollView.contentOffset.y /navHeight;
    if (scrollView.contentOffset.y >= navHeight) {
        [self setNeedsNavigationBackground:1];
    }else {
        [self setNeedsNavigationBackground:per];
    }
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    // 导航栏背景透明度设置
    UIView *barBackgroundView = [[self.navigationController.navigationBar subviews] objectAtIndex:0];
    UIImageView *backgroundImageView = [[barBackgroundView subviews] objectAtIndex:0];
    BOOL result = self.navigationController.navigationBar.isTranslucent;
    if (result) {
        if (backgroundImageView != nil && backgroundImageView.image != nil) {
            barBackgroundView.alpha = alpha;
        } else {
            UIView *backgroundEffectView = [[barBackgroundView subviews] objectAtIndex:1];
            if (backgroundEffectView != nil) {
                backgroundEffectView.alpha = alpha;
            }
        }
    } else {
        barBackgroundView.alpha = alpha;
    }
    self.navTitleLabel.alpha = alpha;
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
