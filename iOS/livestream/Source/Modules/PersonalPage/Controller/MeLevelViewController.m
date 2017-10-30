//
//  MeLevelViewController.m  我的等级界面
//  livestream
//
//  Created by alex shum on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MeLevelViewController.h"
#import "MeLevelView.h"

@interface MeLevelViewController () <WKUIDelegate,WKNavigationDelegate>
// 内嵌web
@property (weak, nonatomic) IBOutlet MeLevelView *meLevelView;

@end

@implementation MeLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"My Level";
    
    self.meLevelView.UIDelegate = self;
    self.meLevelView.navigationDelegate = self;
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
     webSiteUrl = @"http://baidu.com";
    // webSiteUrl = @"http://www.google.com";
    // webview请求url
    
    NSURL *url = [NSURL URLWithString:webSiteUrl];
    // url请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSLog(@"[loadURL:%@",url);
    [self showLoading];
    [self.meLevelView loadRequest:request];
    
}

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

// 加载完webview
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s",__func__);
    [self hideLoading];
}

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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"%s %@ %@ target:%d", __func__, [navigationAction.sourceFrame.request.URL absoluteString], [navigationAction.targetFrame.request.URL absoluteString], navigationAction.targetFrame.mainFrame);
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
//开始获取页面内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
    NSLog(@"%s",__func__);
}
//页面跳转失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self hideLoading];
    NSLog(@"%s---=====%@",__func__,error);
    
   [self showFailView]; 
}


// 创建新的webview
// 可以指定配置对象、导航动作对象、window特性
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"%s---%@ %ld", __func__, [navigationAction.request.URL absoluteString], (long)navigationAction.navigationType);
//    
//    if (!navigationAction.targetFrame.isMainFrame) {
//        [webView loadRequest:navigationAction.request];
//    }
    return nil;
}

#pragma mark - 加载失败
- (void)showFailView {
    self.failView.hidden = NO;
    self.failTipsText = NSLocalizedString(@"List_FailTips",@"List_FailTips");
    self.failBtnText = NSLocalizedString(@"List_Reload",@"List_Reload");
    self.delegateSelect = @selector(retryToload:);
    [self reloadFailViewContent];
    
}

- (void)retryToload:(UIButton *)btn {
    self.failView.hidden = YES;
    [self requestWebview];
}

@end
