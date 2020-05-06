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

@interface LSLiveWKWebViewManager () <WKUIDelegate, WKNavigationDelegate, WebViewJSDelegate, LoginManagerDelegate, LSListViewControllerDelegate>
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

/**
 当前webview处理的URL
 */
@property (nonatomic, copy) NSString *requestUrl;


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

    NSString *appVerCode = [NSString stringWithFormat:@"appver=%@", [LiveModule module].appVerCode];
    if ([baseUrl containsString:@"?"]) {
        _baseUrl = [NSString stringWithFormat:@"%@&%@&%@", baseUrl, device, appVerCode];
    } else {
        _baseUrl = [NSString stringWithFormat:@"%@?%@&%@", baseUrl, device, appVerCode];
    }
    self.requestUrl = _baseUrl;
}

#pragma mark - WKwebview 处理
// 清空所有webview的Cookice
- (void)clearAllCookies {
    NSHTTPCookie *Cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (Cookie in [storage cookies]) {
        NSLog(@"LSLiveWKWebViewManager::clearAllCookies( version:%lu name:%@ value:%@ expiresDate:%@ domain:%@ path:%@ )", (unsigned long)Cookie.version, Cookie.name, Cookie.value, Cookie.expiresDate, Cookie.domain, Cookie.path);
        [storage deleteCookie:Cookie];
    }
}

// 请求webview
- (void)requestWebview {
    // 清cookies和http缓存
    [self clearAllCookies];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    NSString *webSiteUrl = self.requestUrl;
    // webview请求url
    NSURL *url = [NSURL URLWithString:webSiteUrl];
    // url请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    // 请求添加cookie
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [request setHTTPShouldHandleCookies:YES];
    NSArray *cookies = [self.requestManager getCookies];
    for (NSHTTPCookie *cookie in cookies) {
        // 拼接cookies(一定要带domain path) 存入WKWebView中 避免webView调用AJAX请求身份验证失败
        NSString *documentCookie = [[NSString alloc] initWithString:[NSString stringWithFormat:@"document.cookie='%@=%@;domain=%@;path=%@';", cookie.name, cookie.value, cookie.domain, cookie.path]];
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:documentCookie injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];

        [self.liveWKWebView.configuration.userContentController addUserScript:cookieScript];

        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];

    }
    NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
    [request setAllHTTPHeaderFields:cookieHeaders];


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
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler {

    NSLog(@"LSLiveWKWebViewManager::didReceiveAuthenticationChallenge %s", __func__);
    //AFNetworking中的处理方式
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
        //NSLog(@"alextest willSendRequestForAuthenticationChallenge [challenge previousFailureCount] == 0");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"test"
                                                                    password:@"5179"
                                                                 persistence:NSURLCredentialPersistenceForSession];
        completionHandler(NSURLSessionAuthChallengeUseCredential, newCredential);
    } else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
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
    } else {
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
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"LSLiveWKWebViewManager::didCommitNavigation()");

    if ([self.delegate respondsToSelector:@selector(webViewdidCommitNavigation)]) {
        [self.delegate webViewdidCommitNavigation];
    }
}

// 加载完webview (当main frame导航完成时，会回调)
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"LSLiveWKWebViewManager::didFinishNavigation()");
//    页面加载完成之后调用需要重新给WKWebView设置Cookie防止因为a标签跳转，导致下一次跳转的时候Cookie丢失。
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=({FNXX==XXFN}*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";

    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    NSLog(@"JSCookieString %@",JSCookieString);
    //执行js
    [webView evaluateJavaScript:JSCookieString completionHandler:^(id obj, NSError * _Nullable error) {
        NSLog(@"JSCookieString error %@",error);
    }];
    
    
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishNavigation)]) {
        [self.delegate webViewDidFinishNavigation];
    }
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    if (@available(iOS 13.0, *)) {
           UIView *statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame] ;
            statusBar.backgroundColor = color;
            [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
        } else {
            UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
            if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
                statusBar.backgroundColor = color;
            }
        }
}

//页面跳转失败 (当main frame开始加载数据失败时，会回调)
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"LSLiveWKWebViewManager::didFailProvisionalNavigation() error:%@", error);
    if ([self.delegate respondsToSelector:@selector(webViewdidFailProvisionalNavigation)]) {
        [self.delegate webViewdidFailProvisionalNavigation];
    }
}

// 当main frame最后下载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"LSLiveWKWebViewManager::didFailNavigation() error:%@", error);
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
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
//    NSArray *cookies = [self.requestManager getCookies];
//    for (NSHTTPCookie *cookie in cookies) {
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//    }
    

    decisionHandler(WKNavigationResponsePolicyAllow);

    

}

// 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    BOOL result = YES;
    // 拦截H5返回按钮事件
    NSString *closeUrl = QpidClose;
    NSString *qpidJump = Qpid;
    NSString *qpidLiveJump = QpidLive;
    NSURL *url = navigationAction.request.URL;
    NSString *urlStr = [url absoluteString];
 
    if ([self.delegate respondsToSelector:@selector(liveWebView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.delegate liveWebView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        return;
    }
    
//    NSMutableURLRequest *request = (NSMutableURLRequest *)navigationAction.request;
//    NSDictionary *cookieHeaders = request.allHTTPHeaderFields;
//    NSString *cookie =  request.allHTTPHeaderFields[@"Cookie"];
//    NSLog(@"url = %@  %@",urlStr,cookie);
//    if (cookie == nil) {
//        decisionHandler(WKNavigationActionPolicyCancel);
//        self.requestUrl = urlStr;
//        [self requestWebview];
//        return;
//    }
    
//    if (![self.requestUrl isEqualToString:urlStr]) {
//         self.requestUrl = urlStr;
//         [self requestWebview];
//         decisionHandler(WKNavigationActionPolicyCancel);
//     }else {
//         decisionHandler(WKNavigationActionPolicyAllow);
//     }
//    NSArray *cookies = [self.requestManager getCookies];
//    for (NSHTTPCookie *cookie in cookies) {
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//    }
//    NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
//    [request setAllHTTPHeaderFields:cookieHeaders];

//    if ([urlStr isEqualToString:@"http://demo.qpidnetwork.com/payment/payment_success.php"]) {
//        if (!self.test) {
//                  self.test = YES;
//              decisionHandler(WKNavigationActionPolicyCancel);
//              self.requestUrl = urlStr;
//              [self requestWebview];
//
//        }else {
//            decisionHandler(WKNavigationActionPolicyAllow);
//        }
//
//        return;
//    }
    NSLog(@"LSLiveWKWebViewManager::decidePolicyForNavigationAction( [url : %@] )", urlStr);

    if ([urlStr isEqualToString:closeUrl]) {
        if ([self.delegate respondsToSelector:@selector(webViewdecidePolicyForNavigationCloseUrl)]) {
            [self.delegate webViewdecidePolicyForNavigationCloseUrl];
        }
        result = NO;
    }
    
    if ([urlStr containsString:@"video"]&&[urlStr containsString:@".mp4"]) {
        NSLog(@"LSLiveWKWebViewManager::Play Video");
        if ([self.delegate respondsToSelector:@selector(webViewOpenVideo)]) {
            [self.delegate webViewOpenVideo];
        }
    }

    // 如果链接含有打开指定页的跳转则执行链接跳转
    if ([urlStr containsString:qpidJump] || [urlStr containsString:qpidLiveJump]) {
        NSLog(@"LSLiveWKWebViewManager::didOpenJumpUrl( url : %@ )", url);
        LSUrlParmItem *item = [self.urlHandler parseUrlParms:url];
        // 服务冲突判断
        if (item.type == LiveUrlTypeHangoutDialog) {
            [[LiveUrlHandler shareInstance] handleOpenURL:url];
        }else {
            [[LiveModule module].serviceManager handleOpenURL:url];
        }
        result = NO;
        // 如果是含有打开类型则执行对应操作
    } else if ([urlStr containsString:@"opentype"]) {
        LSUrlParmItem *item = [self.urlHandler parseUrlParms:url];

        if ([item.opentype isEqualToString:openTpyeNewWeb]) { // 打开新的webview
            if (![self.requestUrl isEqualToString:urlStr] && self.isFirstProgram) {
                BOOL alphaType = NO;
                BOOL isResume = NO;
                // 导航栏显示样式
                if ([item.styletype isEqualToString:styletypeNormal]) {
                    alphaType = YES;
                }
                // 回到前台是否调用js
                if ([item.resumecb isEqualToString:resumecbNormal]) {
                    isResume = YES;
                }
                if ([self.delegate respondsToSelector:@selector(webViewdidOpenNewWebView:title:screenName:alphaType:isResume:)]) {
                    [self.delegate webViewdidOpenNewWebView:urlStr title:item.apptitle screenName:item.gascreen alphaType:alphaType isResume:isResume];
                }
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
        if (![self.requestUrl isEqualToString:urlStr]) {
            self.requestUrl = urlStr;
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
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          completionHandler();
                                                      }]];
    [self.controller presentViewController:alertController animated:YES completion:nil];
}

// 调用JS的confirm()方法
//confirm 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          completionHandler(NO);
                                                      }]];
    [self.controller presentViewController:alertController animated:YES completion:nil];
}

// 调用JS的prompt()方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *__nullable result))completionHandler {

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
    if ([self.delegate respondsToSelector:@selector(webViewdidRecvWebContentProcessDidTerminate)]) {
        [self.delegate webViewdidRecvWebContentProcessDidTerminate];
    }
}

#pragma mark - 懒加载
- (void)setLiveWKWebView:(IntroduceView *)liveWKWebView {
    
    _liveWKWebView = liveWKWebView;
    if (_liveWKWebView) {
        _liveWKWebView.UIDelegate = self;
        _liveWKWebView.navigationDelegate = self;
    }
}

@end
