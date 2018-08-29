//
//  LSLiveWKWebViewController.m
//  livestream
//
//  Created by randy on 2017/11/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSLiveWKWebViewController.h"
#import "PreLiveViewController.h"
#import "LSLoginManager.h"
#import "LiveModule.h"
#import "LSAnchorRequestManager.h"
#import "DialogTip.h"
#import "LSProfileViewController.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
@interface LSLiveWKWebViewController ()<WKUIDelegate,WKNavigationDelegate, WebViewJSDelegate, LoginManagerDelegate,LSListViewControllerDelegate>
/**
 网络请求管理器
 */
@property (nonatomic, strong) LSAnchorRequestManager *requestManager;

/**
 解析url
 */
@property (nonatomic, strong) LiveUrlHandler *urlHandler;

/**
 重登陆管理器
 */
@property (nonatomic, strong) LSLoginManager *loginManager;


/** 错误信息 */
@property (nonatomic, strong) NSString* errmsg;

@end

@implementation LSLiveWKWebViewController

- (void)dealloc {
    NSLog(@"LSLiveWKWebViewController::dealloc()");
    [self.loginManager removeDelegate:self];
    
    [[DialogTip dialogTip] stopTimer];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 设置失败显示代理
        self.requestManager = [LSAnchorRequestManager manager];
        self.configManager = [LSConfigManager manager];
        self.urlHandler = [LiveUrlHandler shareInstance];
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
    }
    return self;
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

- (NSString *)setupCommonConfig:(NSString *)baseUrl {
    NSString *url;
    NSString *device; // 设备类型
    NSString *appVer = [NSString stringWithFormat:@"appver=%@",[LSAnchorRequestManager manager].versionCode]; // 设备类型
    if (IS_IPAD) {
        device = [NSString stringWithFormat:@"device=32"];
    } else {
        device = [NSString stringWithFormat:@"device=31"];
    }
    if ([baseUrl containsString:@"?"]) {
        url = [NSString stringWithFormat:@"%@&%@%@",baseUrl,device,appVer];
    }else {
        url = [NSString stringWithFormat:@"%@?%@&%@",baseUrl,device,appVer];
    }
    return url;
}

// 请求webview
- (void)requestWebview
{
    self.liveWKWebView.hidden = NO;
    self.controller.failView.hidden = YES;
    
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
    if (self.isRequestWeb) {
        if (self.liveWKWebView.webViewJSDelegate != nil) {
            self.liveWKWebView.webViewJSDelegate = nil;
        }
        self.liveWKWebView.webViewJSDelegate = self;
        self.liveWKWebView.configuration.allowsInlineMediaPlayback = YES;
    }
    [self.controller showLoading];
    [self.liveWKWebView loadRequest:request];
}

#pragma mark - WKNavigationDelegate (导航的代理：提供了追踪主窗口网页加载过程和判断主窗口和子窗口是否进行页面加载新页面的相关方法)
// webview的权限处理的代理
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
    NSLog(@"LSLiveWKWebViewController::didReceiveAuthenticationChallenge %s",__func__);
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
    NSLog(@"LSLiveWKWebViewController::didStartProvisionalNavigation()");
}

//开始获取页面内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"LSLiveWKWebViewController::didCommitNavigation()");
}

// 加载完webview (当main frame导航完成时，会回调)
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"LSLiveWKWebViewController::didFinishNavigation()");
    
    if (!self.isShowTaBar) {
        // 隐藏导航栏
//        [self.controller.navigationController setNavigationBarHidden:YES];
        self.controller.navigationController.navigationBar.hidden = YES;
        [self.controller.navigationController setNavigationBarHidden:YES];
        self.controller.navigationController.navigationBar.translucent = YES;
        self.controller.edgesForExtendedLayout = UIRectEdgeNone;
        //self.controller.navigationController.navigationBar.barTintColor = [UIColor greenColor];
//        UIView *statusBarView = [[UIView alloc]   initWithFrame:CGRectMake(0, 0, self.controller.view.bounds.size.width, [[UIApplication sharedApplication] statusBarFrame].size.height)];
//        statusBarView.backgroundColor = self.controller.navigationController.navigationBar.barTintColor;//COLOR_WITH_16BAND_RGB(0x5D0E86);//[UIColor greenColor];
//        [self.controller.view addSubview:statusBarView];
    }
    
    // 禁止网页的长按，选中
    [self.liveWKWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    [self.liveWKWebView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';"completionHandler:nil];
    
    [self.controller hideLoading];
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

//页面跳转失败 (当main frame开始加载数据失败时，会回调)
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"LSLiveWKWebViewController::didFailProvisionalNavigation() error:%@",error);
    [self.controller hideLoading];
    self.controller.navigationController.navigationBar.hidden = NO;
    [self.controller.navigationController setNavigationBarHidden:NO];
    self.controller.navigationController.navigationBar.translucent = NO;
    self.controller.edgesForExtendedLayout = UIRectEdgeNone;
    [self showFailView];
}

// 当main frame最后下载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"LSLiveWKWebViewController::didFailNavigation() error:%@",error);
}

/** 用来追踪加载过程的方法 页面跳转的代理方法有三种，分为（收到跳转与决定是否跳转两种）**/
// 当main frame接收到服务重定向时，会回调此方法(接收到服务器跳转请求之后调用)
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"LSLiveWKWebViewController::didReceiveServerRedirectForProvisionalNavigation()");
}

// 决定是否接收响应
// 这个是决定是否接收response
// 要获取response，通过WKNavigationResponse对象获取
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"LSLiveWKWebViewController::decidePolicyForNavigationResponse()");
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"LSLiveWKWebViewController::decidePolicyForNavigationAction()");
    
    BOOL result = YES;
    // 拦截H5返回按钮事件
    NSString *closeUrl = @"qpidnetwork://app/closewindow";
    NSString *commonJump = @"qpidnetwork://app/open?";
    NSURL *url = navigationAction.request.URL;
    NSString *urlStr = [url absoluteString];
    
    if ( [urlStr isEqualToString:closeUrl] ) {
        
        if (self.controller.navigationController) {
            [self.controller.navigationController popViewControllerAnimated:YES];
        } else {
            [self.controller dismissViewControllerAnimated:YES completion:nil];
        }
        result = NO;
    }
    
    if ( [urlStr containsString:commonJump] ) {
        
        LSUrlParmItem *item = [self.urlHandler parseUrlParms:url];
        
        if ([urlStr containsString:@"liveroom"]) {
            
            PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
            LiveRoom *liveRoom = [[LiveRoom alloc] init];
            if (item.roomId.length > 0) {
                liveRoom.roomId = item.roomId;
            }
            if (item.userId.length > 0) {
                liveRoom.userId = item.userId;
            }
            if (item.userName.length > 0) {
                liveRoom.userName = item.userName;
            }
            if ([item.roomTypeString isEqualToString:@"0"]) {
                liveRoom.roomType = LiveRoomType_Public;
            } else {
                liveRoom.roomType = LiveRoomType_Private;
            }
            vc.liveRoom = liveRoom;
            [self navgationControllerPresent:vc];
            
        }
        
        result = NO;
    }
    else if ([urlStr containsString:@"opentype"]) {
        LSUrlParmItem *item = [self.urlHandler parseUrlParms:url];
        if ([item.opentype isEqualToString:@"2"]) {
            LSProfileViewController *vc = [[LSProfileViewController alloc] initWithNibName:nil bundle:nil];
            vc.title = item.apptitle;
            vc.profileUrl = urlStr;
            if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
                [self.controller.navigationController pushViewController:vc animated:YES];
                result = NO;
            }
          
        }else if ([item.opentype isEqualToString:@"1"]) {
            NSURL *webUrl = [NSURL URLWithString:urlStr];
            [[UIApplication sharedApplication] openURL:webUrl];
            result = NO;
        }
 
    }  else if ([urlStr containsString:@"liveshowid"]) {
        LSUrlParmItem *item = [self.urlHandler parseUrlParms:url];
        // 进入节目直播间
        PreLiveViewController *preLive = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
        
        LiveRoom *liveRoom = [[LiveRoom alloc] init];
        liveRoom.roomId = item.roomId;
        liveRoom.userId = [LSLoginManager manager].loginItem.userId;
        liveRoom.userName = [LSLoginManager manager].loginItem.nickName;
        liveRoom.photoUrl = [LSLoginManager manager].loginItem.photoUrl;
        preLive.liveRoom = liveRoom;
        preLive.liveShowId = item.showId;
        preLive.status = PreLiveStatus_Show;
        [self navgationControllerPresent:preLive];
        result = NO;
    }
    
    if (result) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

#pragma mark - WKUIDelegate（提供用原生控件显示网页的方法回调）

// 创建新的webview（捕捉事件，主要是界面转换事件）
// 可以指定配置对象、导航动作对象、window特性
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"LSLiveWKWebViewController::createWebViewWithConfiguration url:%@ navigationType:%ld", [navigationAction.request.URL absoluteString], (long)navigationAction.navigationType);
    
    return nil;
}

// 调用JS的alert()方法
//alert 警告框
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    //    NSLog(@"%s---",__func__);
    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WARNING", @"WARNING") message:NSLocalizedString(@"CALL_ALERT_BOX", @"CALL_ALERT_BOX") preferredStyle:UIAlertControllerStyleAlert];
    //    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        completionHandler();
    //    }]];
    //    [self presentViewController:alert animated:YES completion:nil];
    //    NSLog(@"alert message:%@",message);
}

// 调用JS的confirm()方法
//confirm 确认框
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    NSLog(@"%s---",__func__);
    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIR_BOX", @"CONFIR_BOX") message:NSLocalizedString(@"CALL_CONFIRM_BOX", @"CALL_CONFIRM_BOX") preferredStyle:UIAlertControllerStyleAlert];
    //    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SURE", @"SURE") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        completionHandler(YES);
    //    }]];
    //    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", @"CANCEL") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    //        completionHandler(NO);
    //    }]];
    //    [self presentViewController:alert animated:YES completion:NULL];
    //
    //    NSLog(@"confirm message:%@", message);
}


// 调用JS的prompt()方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    //    NSLog(@"%s---",__func__);
    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"INPUT_BOX", @"INPUT_BOX") message:NSLocalizedString(@"CALL_INPUT_BOX", @"CALL_INPUT_BOX") preferredStyle:UIAlertControllerStyleAlert];
    //    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    //        textField.textColor = [UIColor blackColor];
    //    }];
    //
    //    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SURE", @"SURE") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        completionHandler([[alert.textFields lastObject] text]);
    //    }]];
    //
    //    [self presentViewController:alert animated:YES completion:NULL];
}


#pragma mark - 添加导航栏
- (void)navgationControllerPresent:(UIViewController *)controller {
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
    nvc.navigationBar.tintColor = self.controller.navigationController.navigationBar.tintColor;
    nvc.navigationBar.barTintColor = self.controller.navigationController.navigationBar.barTintColor;
    nvc.navigationBar.backgroundColor = self.controller.navigationController.navigationBar.backgroundColor;
    [self.controller.navigationController presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - 加载失败
- (void)showFailView {
    self.liveWKWebView.hidden = YES;
    self.controller.failView.hidden = NO;
    self.controller.failTipsText = NSLocalizedString(@"List_FailTips", @"List_FailTips");
    self.controller.failBtnText = NSLocalizedString(@"List_Reload", @"List_Reload");
//    self.controller.delegateSelect = @selector(retryToload:);
    self.controller.delegate = self;
    [self.controller reloadFailViewContent];
}

- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender {
    [self retryToload:sender];
}

- (void)retryToload:(UIButton *)btn {

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
- (void)webViewJSCallbackWebReload:(NSString *)Errno {
    NSLog(@"WebViewJSCallbackWebReload Errno:%@", Errno);
    BOOL isReLoad = YES;
    if (Errno != nil &&Errno.length > 0) {
        int value = [Errno intValue];
        // 判断是否token过期，重新登录
        if (value == ZBLCC_ERR_TOKEN_EXPIRE) {
            isReLoad = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controller showLoading];
               // [self getAnchorListRequest];
            });
        }
    }
    if (isReLoad) {
        [self reloadWebview];
    }
    
}

// Web通知App跳转私密直播过渡页
- (void)webViewJSCallbackInvite:(NSString *)userid nickName:(NSString *)name photo:(NSString *)photoUrl {
    NSLog(@"webViewJSCallbackInvite userid:%@ nickName :%@", userid,name);
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.userId = userid;
    liveRoom.userName = name;
    liveRoom.photoUrl = photoUrl;
    
    // TODO:主动邀请, 跳转私密直播过渡页
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveRoom = liveRoom;
    vc.status = PreLiveStatus_Inviting;
    [self navgationControllerPresent:vc];
}


// Web通知App身份失效
- (void)webViewJSCallbackWebAuthExpired:(NSString *)errmsg {
    NSLog(@"webViewJScallbackWebAuthExpired ");
     [self.loginManager logout:YES msg:@""];
    self.errmsg = errmsg;
}

//// 为了重登录（由Web通知App页面加载失败，token过期，调用hot列表接口因为token过期应该返回错误的就会重登录）
//- (BOOL)getAnchorListRequest {
//    BOOL bFlag = NO;
//    GetAnchorListRequest *request = [[GetAnchorListRequesFt alloc] init];
//    request.start = 0;
//    request.step = 10;
//    request.hasWatch = NO;
//    // 调用接口
//    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.controller hideLoading];
//            if (success) {
//                [self reloadWebview];
//            }
//        });
//    };
//    bFlag = [self.sessionManager sendRequest:request];
//    return bFlag;
//}

// 登录回调
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(ZBLSLoginItemObject *)loginItem errnum:(ZBHTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.controller hideLoading];
        if (success) {
            // 登录成功就加载
            [self reloadWebview];
        }
    });
}

- (void)manager:(LSLoginManager *)manager onLogout:(BOOL)kick msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.errmsg.length > 0) {
            [[DialogTip dialogTip] showDialogTip:ZBAppDelegate.window tipText:self.errmsg];
        }
    });
}

- (void)reloadWebview {
    //登录成功就重新加载
    self.controller.failView.hidden = YES;
    [self requestWebview];
}

@end
