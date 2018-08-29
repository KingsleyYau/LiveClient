//
//  LSLiveWKWebViewManager.m
//  livestream
//
//  Created by randy on 2017/11/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSLiveWKWebViewManager.h"
#import "LSRequestManager.h"
#import "PreLiveViewController.h"
#import "BookPrivateBroadcastViewController.h"
#import "LSLoginManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "GetAnchorListRequest.h"
#import "LiveModule.h"
#import "LSNavWebViewController.h"
#define QpidLive @"qpidnetwork-live://app/open?"
#define Qpid @"qpidnetwork://app/open?"
#define QpidClose @"qpidnetwork://app/closewindow"
#define openTpyeNewWeb @"2"
#define openTpyeSystemBrowser @"1"
#define styletypeNormal @"1"
#define resumecbNormal @"1"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

@interface LSLiveWKWebViewManager ()<WKUIDelegate,WKNavigationDelegate, WebViewJSDelegate, LoginManagerDelegate,LSListViewControllerDelegate>
/**
 网络请求管理器
 */
@property (nonatomic, strong) LSRequestManager *requestManager;

/**
 解析url
 */
@property (nonatomic, strong) LiveUrlHandler *urlHandler;

/**
 重登陆管理器
 */
@property (nonatomic, strong) LSLoginManager *loginManager;

/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@end

@implementation LSLiveWKWebViewManager

- (void)dealloc {
    NSLog(@"LSLiveWKWebViewManager::dealloc()");
    [self.loginManager removeDelegate:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 设置失败显示代理
        self.requestManager = [LSRequestManager manager];
        self.configManager = [LSConfigManager manager];
        self.urlHandler = [LiveUrlHandler shareInstance];
        self.sessionManager = [LSSessionRequestManager manager];
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
    }
    return self;
}

- (void)setBaseUrl:(NSString *)baseUrl {
    NSString *device; // 设备类型
    if (IS_IPAD) {
        device = [NSString stringWithFormat:@"device=32"];
    } else {
        device = [NSString stringWithFormat:@"device=31"];
    }
    
    NSString *appVerCode = [NSString stringWithFormat:@"appver=%@",[LiveModule module].appVerCode];
    if ([baseUrl containsString:@"?"]) {
        _baseUrl = [NSString stringWithFormat:@"%@&%@&%@",baseUrl,device,appVerCode];
    } else {
        _baseUrl = [NSString stringWithFormat:@"%@?%@&%@",baseUrl,device,appVerCode];
    }
}

#pragma mark - WKwebview 处理
// 清空所有webview的Cookice
- (void)clearAllCookies
{
    NSHTTPCookie *Cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (Cookie in [storage cookies]) {
        NSLog(@"version:%lu name:%@ value:%@ expiresDate:%@ domain:%@ path:%@",(unsigned long)Cookie.version, Cookie.name, Cookie.value, Cookie.expiresDate, Cookie.domain, Cookie.path);
        [storage deleteCookie:Cookie];
    }
}

// 请求webview
- (void)requestWebview
{
    // 清cookies和http缓存
    [self clearAllCookies];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSString *webSiteUrl = self.baseUrl;
    // webview请求url
    NSURL *url = [NSURL URLWithString:webSiteUrl];
    // url请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 请求添加cookie
    NSArray *cookies = [self.requestManager getCookies];
    for (NSHTTPCookie *cookie in  cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [request setHTTPShouldHandleCookies:YES];
    [request setAllHTTPHeaderFields:cookieHeaders];
    [request setTimeoutInterval:60];
    if (self.liveWKWebView.webViewJSDelegate != nil) {
        self.liveWKWebView.webViewJSDelegate = nil;
    }
    self.liveWKWebView.webViewJSDelegate = self;
    self.liveWKWebView.configuration.allowsInlineMediaPlayback = YES;

    [self.controller showLoading];
    [self.liveWKWebView loadRequest:request];
}

- (void)resetFirstProgram {
    self.isFirstProgram = YES;
}

#pragma mark - WKNavigationDelegate (导航的代理：提供了追踪主窗口网页加载过程和判断主窗口和子窗口是否进行页面加载新页面的相关方法)
// webview的权限处理的代理
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
    NSLog(@"LSLiveWKWebViewManager::didReceiveAuthenticationChallenge %s",__func__);
    //AFNetworking中的处理方式
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
        //NSLog(@"alextest willSendRequestForAuthenticationChallenge [challenge previousFailureCount] == 0");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"test"
                                                                    password:@"5179"
                                                                 persistence:NSURLCredentialPersistenceForSession];
        completionHandler(NSURLSessionAuthChallengeUseCredential, newCredential);
    }
    else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        /*disposition：如何处理证书
         NSURLSessionAuthChallengePerformDefaultHandling:默认方式处理
         NSURLSessionAuthChallengeUseCredential：使用指定的证书    NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消请求
         */
        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
        completionHandler(disposition, credential);
    }
    else {
        //NSLog(@"alextest willSendRequestForAuthenticationChallenge [challenge previousFailureCount] != 0");
        // Inform the user that the user name and password are incorrect
        //completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

// 当main frame的导航开始请求时，会调用此方法
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"LSLiveWKWebViewManager::didStartProvisionalNavigation()");
}

//开始获取页面内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"LSLiveWKWebViewManager::didCommitNavigation()");
    if (!self.isShowTaBar) {
        // 隐藏导航栏
        self.controller.navigationController.navigationBar.hidden = YES;
        [self.controller.navigationController setNavigationBarHidden:YES];
        self.controller.navigationController.navigationBar.translucent = YES;
        self.controller.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    
    // 禁止网页的长按，选中
    [self.liveWKWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    [self.liveWKWebView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';"completionHandler:nil];
    
    [self.controller hideLoading];
}

// 加载完webview (当main frame导航完成时，会回调)
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"LSLiveWKWebViewManager::didFinishNavigation()");
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishNavigation)]) {
        [self.delegate webViewDidFinishNavigation];
    }
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

//页面跳转失败 (当main frame开始加载数据失败时，会回调)
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"LSLiveWKWebViewManager::didFailProvisionalNavigation() error:%@",error);
    [self.controller hideLoading];
    self.controller.navigationController.navigationBar.hidden = NO;
    [self.controller.navigationController setNavigationBarHidden:NO];
    self.controller.navigationController.navigationBar.translucent = NO;
    self.controller.edgesForExtendedLayout = UIRectEdgeNone;
    [self showFailView];
}

// 当main frame最后下载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"LSLiveWKWebViewManager::didFailNavigation() error:%@",error);
}

/** 用来追踪加载过程的方法 页面跳转的代理方法有三种，分为（收到跳转与决定是否跳转两种）**/
// 当main frame接收到服务重定向时，会回调此方法(接收到服务器跳转请求之后调用)
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"LSLiveWKWebViewManager::didReceiveServerRedirectForProvisionalNavigation()");
}

// 决定是否接收响应
// 这个是决定是否接收response
// 要获取response，通过WKNavigationResponse对象获取
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"LSLiveWKWebViewManager::decidePolicyForNavigationResponse()");
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{

    BOOL result = YES;
    // 拦截H5返回按钮事件
    NSString *closeUrl = QpidClose;
    NSString *qpidJump = Qpid;
    NSString *qpidLiveJump = QpidLive;
    NSURL *url = navigationAction.request.URL;
    NSString *urlStr = [url absoluteString];

    NSLog(@"LSLiveWKWebViewManager::decidePolicyForNavigationAction( [url : %@] )",urlStr);
    
    if ( [urlStr isEqualToString:closeUrl] ) {
        
        if (self.controller.navigationController) {
            [self.controller.navigationController popViewControllerAnimated:YES];
        } else {
            [self.controller dismissViewControllerAnimated:YES completion:nil];
        }
        result = NO;
    }
    
    // 如果链接含有打开指定页的跳转则执行链接跳转
    if ( [urlStr containsString:qpidJump] || [urlStr containsString:qpidLiveJump] ) {
        NSLog(@"LSLiveWKWebViewManager::didOpenJumpUrl: %@",url);
        [LiveUrlHandler shareInstance].url = url;
        [[LiveUrlHandler shareInstance] handleOpenURL];
        result = NO;
    // 如果是含有打开类型则执行对应操作
    } else if ([urlStr containsString:@"opentype"]) {
        LSUrlParmItem *item = [self.urlHandler parseUrlParms:url];
        
        if ([item.opentype isEqualToString:openTpyeNewWeb]) { // 打开新的webview
            if (![self.baseUrl isEqualToString:urlStr] && self.isFirstProgram) {
                LSNavWebViewController *vc = [[LSNavWebViewController alloc] initWithNibName:nil bundle:nil];
                vc.url = urlStr;
                vc.navTitle = item.apptitle;
                // ga跟踪
                if (item.gascreen.length > 0) {
                    vc.gaScreenName = item.gascreen;
                }
                // 导航栏显示样式
                if ([item.styletype isEqualToString:styletypeNormal]) {
                    vc.alphaType = YES;
                } else {
                    vc.alphaType = NO;
                    vc.title = item.apptitle;
                }
                // 回到前台是否调用js
                if ([item.resumecb isEqualToString:resumecbNormal]) {
                    vc.isResume = YES;
                } else {
                    vc.isResume = NO;
                }
                [self.controller.navigationController pushViewController:vc animated:YES];
                NSLog(@"LSLiveWKWebViewManager::decidePolicyForNavigationAction() self:%p", self);
                self.isFirstProgram = NO;
                result = NO;
            }
            
        } else if ([item.opentype isEqualToString:openTpyeSystemBrowser]) {
            NSURL *webUrl = [NSURL URLWithString:urlStr];
            [[UIApplication sharedApplication] openURL:webUrl];
            result = NO;
        }
    }
    
    if (result) {
        self.baseUrl = urlStr;
        LSUrlParmItem *item = [self.urlHandler parseUrlParms:url];
        if (item.resumecb) {
            BOOL isResume = NO;
            if ([item.resumecb isEqualToString:resumecbNormal]) {
                isResume = YES;
            }
            if ([self.delegate respondsToSelector:@selector(webViewTransferJSIsResume:)]) {
                [self.delegate webViewTransferJSIsResume:isResume];
            }
        }
        
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

#pragma mark - WKUIDelegate（提供用原生控件显示网页的方法回调）

// 创建新的webview（捕捉事件，主要是界面转换事件）
// 可以指定配置对象、导航动作对象、window特性
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"LSLiveWKWebViewManager::createWebViewWithConfiguration url:%@ navigationType:%ld", [navigationAction.request.URL absoluteString], (long)navigationAction.navigationType);
    
    return nil;
}

// 调用JS的alert()方法
//alert 警告框
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self.controller presentViewController:alertController animated:YES completion:nil];
}

// 调用JS的confirm()方法
//confirm 确认框
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self.controller presentViewController:alertController animated:YES completion:nil];
}


// 调用JS的prompt()方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields.lastObject.text);
    }]];
    [self.controller presentViewController:alertController animated:YES completion:nil];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"LSLiveWKWebViewManager:webViewWebContentProcessDidTerminate");
}

#pragma mark - 加载失败
- (void)showFailView {
    self.liveWKWebView.hidden = YES;
    self.controller.failView.hidden = NO;
    self.controller.failTipsText = NSLocalizedString(@"List_FailTips", @"List_FailTips");
    self.controller.failBtnText = NSLocalizedString(@"List_Reload", @"List_Reload");
    self.controller.listDelegate = self;
    [self.controller reloadFailViewContent];
}

- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender {
    [self retryToload:sender];
}

- (void)retryToload:(UIButton *)btn {
    self.liveWKWebView.hidden = NO;
    self.controller.failView.hidden = YES;
    [self requestWebview];
}

#pragma mark - 懒加载
- (void)setLiveWKWebView:(IntroduceView *)liveWKWebView {
    
    _liveWKWebView = liveWKWebView;
    if (_liveWKWebView) {
        _liveWKWebView.UIDelegate = self;
        _liveWKWebView.navigationDelegate = self;
    }
}

#pragma mark - WebViewJSDelegate
// GA跟踪事件JS接口
- (void)webViewJSCallbackAppGAEvent:(NSString *)event {
    NSLog(@"WebViewJSCallbackAppGAEvent event:%@", event);
    [[LiveModule module].analyticsManager reportActionEvent:event eventCategory:EventCategoryBroadcast];
}
// 关闭当前WebView的JS接口
- (void)webViewJSCallbackAppCloseWebView {
    NSLog(@"WebViewJSCallbackAppCloseWebView");
    if (self.controller.navigationController) {
        [self.controller.navigationController popViewControllerAnimated:YES];
    } else {
        [self.controller dismissViewControllerAnimated:YES completion:nil];
    }
}
// Web通知App页面加载失败
- (void)webViewJSCallbackWebReload:(NSString *)error {
    NSLog(@"WebViewJSCallbackWebReload error:%@", error);
    BOOL isReLoad = YES;
    if (error != nil &&error.length > 0) {
        int value = [error intValue];
        // 判断是否token过期，重新登录
        if (value == LCC_ERR_TOKEN_EXPIRE) {
            isReLoad = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loginManager logout:LogoutTypeKick msg:error];
            });
        }
    }
    if (isReLoad) {
        [self reloadWebview];
    }
}

//token过期
- (void)webViewJSCallBackTokenTimeOut:(NSString *)error
{
    NSLog(@"webViewJSCallBackTokenTimeOut error:%@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginManager logout:LogoutTypeKick msg:error];
    });
}

//账号余额不足
- (void)webViewJSCallBackAddCredit:(NSString *)error
{
    NSLog(@"webViewJSCallBackAddCredit error:%@", error);
    
    if (error && error.length > 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:error preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add_Credits", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action){
                                                             [self.controller.navigationController pushViewController:[LiveModule module].addCreditVc animated:YES];
                                                         }];
        [alertVC addAction:actionOK];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
        [alertVC addAction:actionCancel];
        [self.controller presentViewController:alertVC animated:NO completion:nil];
    }else {
        [self.controller.navigationController pushViewController:[LiveModule module].addCreditVc animated:YES];
    }

}

- (void)webViewJSCallbackAppPublicGAEvent:(NSString *)event category:(NSString *)category label:(NSString *)label {
    NSLog(@"webViewJSCallbackAppPublicGAEvent event:%@ category:%@ label:%@", event,category,label);
    [[LiveModule module].analyticsManager reportActionEvent:event eventCategory:category label:label value:nil];
}

- (void)wkWebViewDidCallbackFinish:(IntroduceView *)view {
    if (!self.isShowTaBar) {
        // 隐藏导航栏
        self.controller.navigationController.navigationBar.hidden = YES;
        [self.controller.navigationController setNavigationBarHidden:YES];
        self.controller.navigationController.navigationBar.translucent = YES;
        self.controller.edgesForExtendedLayout = UIRectEdgeNone;

    }
    
    // 禁止网页的长按，选中
    [self.liveWKWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    [self.liveWKWebView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';"completionHandler:nil];
    
    [self.controller hideLoading];
}

// 登录回调
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.controller hideLoading];
        if (success) {
            // 登录成功就加载
            [self reloadWebview];
        }
    });
}

- (void)reloadWebview {
    //登录成功就重新加载
    self.controller.failView.hidden = YES;
    [self requestWebview];
}

@end
