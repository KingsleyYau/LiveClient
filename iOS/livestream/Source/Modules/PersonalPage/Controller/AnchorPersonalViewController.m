//
//  AnchorPersonalViewController.m
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AnchorPersonalViewController.h"
#import "AnchorPersonalView.h"
#import "PreLiveViewController.h"
#import "MeLevelViewController.h"
#import "LSHomePageViewController.h"
#import "BookPrivateBroadcastViewController.h"
#import "LiveChannelAdViewController.h"
#import "LSMyReservationsViewController.h"

@interface AnchorPersonalViewController () <WKUIDelegate, WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet AnchorPersonalView *anchorPersonalView;
@end

@implementation AnchorPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.anchorPersonalView.UIDelegate = self;
    self.anchorPersonalView.navigationDelegate = self;
    [self requestWebview];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCustomParam {
    [super initCustomParam];
}


- (void)setupContainView{
    [super setupContainView];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
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
    NSString *webSiteUrl = @"";
    // webSiteUrl = @"https://tympanus.net/Development/AnimatedBooks/index.html";
    webSiteUrl = @"http://demo-mobile.charmdate.com/member/lady_profile/womanid/P580502/devicetype/31/versioncode/110/showButton/1";
    // webview请求url
    NSURL *url = [NSURL URLWithString:webSiteUrl];
    // url请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSLog(@"[loadURL:%@",url);
    [self showLoading];
    [self.anchorPersonalView loadRequest:request];
    
}

#pragma mark - WKNavigationDelegate (导航的代理：提供了追踪主窗口网页加载过程和判断主窗口和子窗口是否进行页面加载新页面的相关方法)
// webview的权限处理的代理
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
    NSLog(@"%s",__func__);
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

/** 页面跳转的代理方法： 可以用来追踪加载过程（页面开始加载、加载完成、加载失败） **/

// 当main frame的导航开始请求时，会调用此方法
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s",__func__);
}


//开始获取页面内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
    NSLog(@"%s",__func__);
}

// 加载完webview (当main frame导航完成时，会回调)
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s",__func__);
    [self hideLoading];
}

//页面跳转失败 (当main frame开始加载数据失败时，会回调)
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self hideLoading];
    NSLog(@"%s---=====%@",__func__,error);
    
    [self showFailView];
    
}

// 当main frame最后下载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
     NSLog(@"%s---=====%@",__func__,error);
}




/** 用来追踪加载过程的方法 页面跳转的代理方法有三种，分为（收到跳转与决定是否跳转两种）**/
// 当main frame接收到服务重定向时，会回调此方法(接收到服务器跳转请求之后调用)
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s",__func__);
}

// 决定是否接收响应
// 这个是决定是否接收response
// 要获取response，通过WKNavigationResponse对象获取
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%s",__func__);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
////1.
// * 在发送请求之前，决定是否跳转
// *
// * @param webView 实现该代理的webview
// * @param navigationAction 当前navigation
// * @param decisionHandler 是否调转block
/*
 WKNavigationTypeLinkActivated,//链接的href属性被用户激活。
 WKNavigationTypeFormSubmitted,//一个表单提交。
 WKNavigationTypeBackForward,//回到前面的条目列表请求。
 WKNavigationTypeReload,//网页加载。
 WKNavigationTypeFormResubmitted,//一个表单提交(例如通过前进,后退,或重新加载)。
 WKNavigationTypeOther = -1,//导航是发生一些其他原因。

 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"%s",__func__);
    

    // url
    NSString *hostName = [navigationAction.request.URL absoluteString];
    // 跳转模块
    NSString *commonJump = @"qpidnetwork://app/open?";
    // 是跳转请求， URL的url不是空 而且 是 qpidnetwork://app/open?module=
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated && (hostName != nil) && [hostName hasPrefix:commonJump]) {
//        // 跳转模块的值
//        NSString *strModule = [self parameterForKey:hostName param:@"module"];
//        // main模块
//        if ([strModule hasPrefix:@"main"]) {
//            
//        }
//        else if ([strModule hasPrefix:@"anchordetail"]) {
//        
//        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

#pragma mark - WKUIDelegate（提供用原生控件显示网页的方法回调）

// 创建新的webview
// 可以指定配置对象、导航动作对象、window特性
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
     NSLog(@"%s---%@ %ld", __func__, [navigationAction.request.URL absoluteString], (long)navigationAction.navigationType);
    
    if (!navigationAction.targetFrame.isMainFrame) {
        // [webView loadRequest:navigationAction.request];
        //[[LiveUrlHandler shareInstance] handleOpenURL:navigationAction.request.URL];
        //NSString *hostName = @"qpidnetwork://app/open?service=live&module=bookinglist&listtype=1";
        //NSString *hostName = [NSString stringWithFormat:@"qpidnetwork://app/open?site:4&service=live&module=liveroom&anchorid=%@", self.liveRoomInfo.userId];
        // 跳转模块
        NSString *commonJump = @"qpidnetwork://app/open?";
        NSString *hostName = [navigationAction.request.URL absoluteString];
        // test 
        //NSString *hostName = [NSString stringWithFormat:@"qpidnetwork://app/open?site:4&service=live&module=liveroom&anchorid=%@&roomtype=1", self.liveRoomInfo.userId];
        //NSString *hostName = @"qpidnetwork://app/open?service=live&module=bookinglist&listtype=1";
        //NSString *hostName = [NSString stringWithFormat:@"qpidnetwork://app/open?site:4&service=live&module=liveroom&anchorid=%@", self.liveRoomInfo.userId];
        if ((hostName != nil) && [hostName hasPrefix:commonJump]) {
//            NSURL *url = [NSURL URLWithString:hostName];
            //[LiveUrlHandler shareInstance].url = navigationAction.request.URL;
//            [LiveUrlHandler shareInstance].url = url;
//            [[LiveUrlHandler shareInstance] handleOpenURL];
        }

    }
    return nil;
}

// 调用JS的alert()方法
//alert 警告框
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"%s---",__func__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WARNING", @"WARNING") message:NSLocalizedString(@"CALL_ALERT_BOX", @"CALL_ALERT_BOX") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    NSLog(@"alert message:%@",message);
}

// 调用JS的confirm()方法
//confirm 确认框
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    NSLog(@"%s---",__func__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIR_BOX", @"CONFIR_BOX") message:NSLocalizedString(@"CALL_CONFIRM_BOX", @"CALL_CONFIRM_BOX") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SURE", @"SURE") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", @"CANCEL") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"confirm message:%@", message);
    
}


// 调用JS的prompt()方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"%s---",__func__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"INPUT_BOX", @"INPUT_BOX") message:NSLocalizedString(@"CALL_INPUT_BOX", @"CALL_INPUT_BOX") preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SURE", @"SURE") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}


#pragma mark - url的字段
- (NSString *)parameterForKey:(NSString *)url param:(NSString *)param {
    NSDictionary *parameters = [self parameters:url];
    if(parameters == nil) {
        return nil;
    }
    return parameters[param];
}

-(NSDictionary  *)parameters:(NSString *)url {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *query = url;
    NSArray *values = [query componentsSeparatedByString:@"&"];
    
    if( values == nil || values.count == 0 )
        return nil;
    
    for(NSString *value in values) {
        NSArray *param = [value componentsSeparatedByString:@"="];
        if( param == nil || param.count == 2 ) {
            [parameters setObject:param[1] forKey:param[0]];
        }
    }
    
    return parameters;
}

#pragma mark - 加载失败
- (void)showFailView {
    self.failView.hidden = NO;
    self.failTipsText = NSLocalizedString(@"List_FailTips", @"List_FailTips");
    self.failBtnText = NSLocalizedString(@"List_Reload", @"List_Reload");
    self.delegateSelect = @selector(retryToload:);
    [self reloadFailViewContent];
    
}

- (void)retryToload:(UIButton *)btn {
    self.failView.hidden = YES;
    [self requestWebview];
}

@end
