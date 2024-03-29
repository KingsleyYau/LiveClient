//
//  LSWebPaymentViewController.m
//  livestream
//
//  Created by test on 2019/10/16.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSWebPaymentViewController.h"
#import "LSMobilePayGotoRequest.h"
#import "LSLiveWKWebViewManager.h"
#import "LSWebViewJSManager.h"
#import "LiveModule.h"
#import "LSAddCreditsViewController.h"
#import "LSNavWebViewController.h"
#import "LiveUrlHandler.h"
#define HideNavigation @"0"
#define ShowNavigation @"1"
#define UnKnow @"UnKnow"

#define demoPaySuccess @"http://demo.qpidnetwork.com/payment/payment_success.php"
#define demoPayError @"http://demo.qpidnetwork.com/payment/payment_error.php"
#define demoPayError2 @"http://demo.qpidnetwork.com/payment/payment_error2.php"
#define demoPayCancel @"http://demo.qpidnetwork.com/payment/payment_cancel.php"
#define demoPayFail @"http://demo.qpidnetwork.com/payment/payment_fail.php"
#define securePaysuccess @"https://secure.qpidnetwork.com/payment/payment_success.php"
#define securePayError @"https://secure.qpidnetwork.com/payment/payment_error.php"
#define securePayError2 @"https://secure.qpidnetwork.com/payment/payment_error2.php"
#define securePayCancel @"https://secure.qpidnetwork.com/payment/payment_cancel.php"
#define securePayFail @"https://secure.qpidnetwork.com/payment/payment_fail.php"

@interface LSWebPaymentViewController () <LSLiveWKWebViewManagerDelegate, LSWebViewJSManagerDelegate, LSListViewControllerDelegate>
@property (nonatomic, strong) LSLiveWKWebViewManager *urlManager;

@property (nonatomic, strong) LSWebViewJSManager *jsManager;
// 是否调用JS方法
@property (nonatomic, assign) BOOL isResume;
// 界面是否viewDidDisappear过
@property (nonatomic, assign) BOOL hasDisappear;

/**
 是否已经加载成功
 */
@property (nonatomic, assign) BOOL isLoadFinish;
@end

@implementation LSWebPaymentViewController

- (void)dealloc {
    NSLog(@"LSWebPaymentViewController::dealloc()");
    [self.webView stopLoading];
    [self.jsManager removeWebViewUserScript:self.webView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.isShowNavBar = YES;
    self.isShowTaBar = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Secure Payment";
    [self setupIsResume:NO];

    self.isLoadFinish = NO;
    self.didFinshNav = NO;
    self.hasDisappear = NO;

    self.urlManager = [[LSLiveWKWebViewManager alloc] init];
    self.urlManager.delegate = self;
    self.urlManager.restrictUrl = @"";
    
    self.jsManager = [[LSWebViewJSManager alloc] init];
    self.jsManager.delegate = self;
    [self.jsManager setWebViewUserScript:self.webView];

    self.webView.translatesAutoresizingMaskIntoConstraints = NO;

    NSURL *url = [NSURL URLWithString:self.requestUrl];
    LSUrlParmItem *item = [[LiveUrlHandler shareInstance] parseUrlParms:url];
    // 回到前台是否调用js
    if ([item.resumecb isEqualToString:@"1"]) {
        self.isResume = YES;
    }
    // 添加接收前后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
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
    self.hasDisappear = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getCheckPayment];
    if( !self.viewDidAppearEver ) {
        if (@available(iOS 11, *)) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
}


- (void)getCheckPayment {
    LSSessionRequestManager *manager = [LSSessionRequestManager manager];
    LSMobilePayGotoRequest *request = [[LSMobilePayGotoRequest alloc] init];
    request.orderNo = self.orderNo;
    request.orderType = LSORDERTYPE_FLOWERGIFT;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *redirtctUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.requestUrl = redirtctUrl;
            [self setupRequestWebview];
        });
    };
    [manager sendRequest:request];
}



- (void)setupIsResume:(BOOL)isResume {
    self.isResume = isResume;
}

- (void)setupRequestWebview {
    self.urlManager.isFirstProgram = self.isFirstProgram;
    self.urlManager.baseUrl = self.requestUrl;
    self.urlManager.liveWKWebView = self.webView;
    self.urlManager.controller = self;
    self.urlManager.isShowTaBar = self.isShowTaBar;
    // 延迟加载网页,防止上一界面没消失,隐藏导航栏导致导航栏位会闪一下看到上一界面
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.urlManager requestWebview];
    });
    
}

- (void)nativeTransferJavaScript {
    if (self.isResume && self.didFinshNav && self.hasDisappear) {
        self.hasDisappear = NO;
        [self.webView webViewTransferResumeHandler:^(id _Nullable response, NSError *_Nullable error){
        }];
    }
}

- (void)showFailView {
    self.urlManager.restrictUrl = @"";
    self.webView.hidden = YES;
    self.failView.hidden = NO;
    self.listDelegate = self;
}

#pragma mark - LSListViewControllerDelegate
- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender {
    self.webView.hidden = NO;
    self.failView.hidden = YES;
//    [self.urlManager requestWebview];
    [self getCheckPayment];
}

#pragma mark - LSWebViewJSManagerDelegate
- (void)jsManagerOnLogin:(BOOL)success {
    [self hideLoading];
    if (success) {
        self.failView.hidden = YES;
        [self.urlManager requestWebview];
    }
}

- (void)jsManagerCallbackCloseWebView {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)jsManagerCallbackWebReload {
    [self.urlManager requestWebview];
}

- (void)jsManagerCallBackAddCredit:(NSString *)error {
    if (error && error.length > 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:error preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add_Credits", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action) {
                                                             LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
                                                             [self.navigationController pushViewController:vc animated:YES];
                                                         }];
        [alertVC addAction:actionOK];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
        [alertVC addAction:actionCancel];
        [self presentViewController:alertVC animated:NO completion:nil];
    } else {
        LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - LSLiveWKWebViewManagerDelegate
- (void)webViewdidCommitNavigation {
    self.isLoadFinish = YES;

    if (!self.isShowTaBar) {
        // 设置风格为半透明导航
        self.isShowNavBar = NO;
        [self hideNavigationBar];
    } else {
        self.isShowNavBar = YES;
        [self showNavigationBar];
    }

    [self hideLoading];
}

- (void)webViewdidFailProvisionalNavigation {
    [self showNavigationBar];
    [self hideLoading];
    [self showFailView];
}

- (void)webViewdidRecvWebContentProcessDidTerminate {
    [self showNavigationBar];
    [self hideLoading];
    [self showFailView];
}

- (void)webViewDidFinishNavigation {
    self.didFinshNav = YES;
    // 禁止网页的长按，选中
    [self.webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    [self.webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];

    if (self.viewDidAppearEver) {
        [self nativeTransferJavaScript];
    }
    [self webViewLoadingFinshCallBack];
}

- (void)webViewLoadingFinshCallBack {
}
- (void)webViewdecidePolicyForNavigationCloseUrl {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)jsManagerCallBackIsShowNavigation:(BOOL)isShow {
    if (isShow) {
        [self showNavigationBar];
    } else {
        [self hideNavigationBar];
    }
}

/**
 切换前台
 */
- (void)becomeActive {
    [self nativeTransferJavaScript];
}

// 切换后台
- (void)enterBackground {
    self.hasDisappear = YES;
}

- (void)webViewdidOpenNewWebView:(NSString *)urlStr title:(NSString *)title screenName:(NSString *)screenName alphaType:(BOOL)alphaType isResume:(BOOL)isResume {
    LSNavWebViewController *vc = [[LSNavWebViewController alloc] initWithNibName:nil bundle:nil];
    vc.url = urlStr;
    vc.navTitle = title;
    // ga跟踪
    if (screenName.length > 0) {
        vc.screenName = screenName;
    }
    vc.alphaType = alphaType;
    vc.isResume = isResume;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)webViewTransferJSIsResume:(BOOL)isResume {
    self.isResume = isResume;
}


- (void)liveWebView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    NSString *urlStr = [url absoluteString];
    //当前界面重新请求 防止web自己打开新网页时丢失cookies
    if (([urlStr hasPrefix:demoPaySuccess]
        || [urlStr hasPrefix:demoPayError]
        || [urlStr hasPrefix:demoPayError2]
        || [urlStr hasPrefix:demoPayCancel]
        || [urlStr hasPrefix:demoPayFail]
        || [urlStr hasPrefix:securePaysuccess]
        || [urlStr hasPrefix:securePayError]
        || [urlStr hasPrefix:securePayError2]
        || [urlStr hasPrefix:securePayCancel]
        || [urlStr hasPrefix:securePayFail])
        && self.urlManager.restrictUrl.length == 0) {
        NSLog(@"urlStr = %@ ---  self.requestUrl = %@",urlStr,self.requestUrl);
          decisionHandler(WKNavigationActionPolicyCancel);
        self.urlManager.restrictUrl = urlStr;
        self.requestUrl = urlStr;
        [self setupRequestWebview];
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end
