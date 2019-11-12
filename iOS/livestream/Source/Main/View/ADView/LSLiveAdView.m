//
//  LiveAdView.m
//  dating
//
//  Created by test on 2018/3/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSLiveAdView.h"
#import "LSRequestManager.h"
#import "LiveUrlHandler.h"
#import "LSURLQueryParam.h"
#define APP_URLHANDLER_OPEN @"qpidnetwork://app/open?"
#define APP_LINKHANLER @"qpidnetwork://app/"
#define APP_ClOSE @"qpidnetwork://app/closewindow"
@interface LSLiveAdView()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) LSCommonWebView *adWebView;
/** 关闭按钮 */
@property (nonatomic, strong) UIButton *closeBtn;
/**
 跳转url
 */
@property (copy, nonatomic) NSString *baseUrl;
@end

@implementation LSLiveAdView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSLiveAdView" owner:self options:nil].firstObject;
        self.frame = frame;
        self.adWebView = [[LSCommonWebView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width * 0.8, 288)];
        self.adWebView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.adWebView.center = self.center;
        self.adWebView.UIDelegate = self;
        self.adWebView.navigationDelegate = self;
        self.hidden = YES;
        [self addSubview:self.adWebView];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}


// 清空所有webview的Cookice
- (void)clearAllCookies {
    NSHTTPCookie *Cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (Cookie in [storage cookies]) {
        NSLog(@"version:%lu name:%@ value:%@ expiresDate:%@ domain:%@ path:%@",(unsigned long)Cookie.version, Cookie.name, Cookie.value, Cookie.expiresDate, Cookie.domain, Cookie.path);
        [storage deleteCookie:Cookie];
        
    }
}

- (void)loadHTmlStr:(NSString *)string baseUrl:(NSURL *)url {
    [self.adWebView loadHTMLString:string baseURL:url];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
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

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
//    if ([AppShareDelegate().currentViewController isKindOfClass:[LadyWaterfallViewController class]]) {
//
//    }
    self.hidden = NO;
    webView.opaque = NO;
    webView.hidden = NO;
    __block CGFloat webViewHeight;
    // 获取网页的高度,网页的宽度为屏幕宽度的80%
    [self.adWebView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result,NSError * _Nullable error) {
        webViewHeight = [result doubleValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.height) {
                self.height = webViewHeight;
            }

            CGRect orginFrame = self.adWebView.frame;
            if (self.height >= screenSize.height * 0.8) {
                orginFrame.size.height = screenSize.height * 0.8;;
                self.adWebView.scrollView.scrollEnabled = YES;
            } else {
                orginFrame.size.height = self.height;
                self.adWebView.scrollView.scrollEnabled = NO;
            }
            self.adWebView.frame = orginFrame;
            self.adWebView.center = self.center;
            
        });
    }];
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
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
    
    NSURL *url = navigationAction.request.URL;
    NSString *strAbsolute = [url absoluteString];
    BOOL result = YES;
    
    if (strAbsolute != nil) {
        //判断是否为内部链接
        if ([strAbsolute hasPrefix:APP_URLHANDLER_OPEN]) {
            result = NO;
            if ([self.delegate respondsToSelector:@selector(liveAdView:HandlerOpenUrl:)]) {
                [self.delegate liveAdView:self HandlerOpenUrl:url];
            }
            [[LiveUrlHandler shareInstance] handleOpenURL:url];
            
        }else {
            
            if ((strAbsolute != nil) && [strAbsolute hasPrefix:APP_ClOSE]) {
                result = NO;
                if ([self.delegate respondsToSelector:@selector(liveAdViewDidClose:)]) {
                    [self.delegate liveAdViewDidClose:self];
                }
            } else {
                NSString *opentype = [LSURLQueryParam urlParamForKey:@"opentype" url:url];
                if ([opentype intValue] != 0 && ![self.baseUrl isEqualToString:strAbsolute]) {
                    result = NO;
                    //打开方式
                    self.openType = (URLLiveAdOpenType)[opentype intValue];
                    [self qnWebViewOpenURL:url openType:self.openType];
                }
            }
        }
    }
    
    if (result) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
}
//开始获取页面内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    webView.opaque = NO;
    
}

//页面跳转失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
}

- (IBAction)closeAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(liveAdViewDidClose:)]) {
        [self.delegate liveAdViewDidClose:self];
    }
}

- (void)qnWebViewOpenURL:(NSURL *)url openType:(URLLiveAdOpenType)type {
    
    switch (type) {
        case URLLiveAdOpenType_DEFAULT: {
            
        } break;
        case URLLiveAdOpenType_SYSTEMBROWER: {
            [[UIApplication sharedApplication] openURL:url];
        } break;
        case URLLiveAdOpenType_APPBROWER: {
            self.adWebView.hidden = YES;
            if ([self.delegate respondsToSelector:@selector(liveAdViewRedirectURL:)]) {
                [self.delegate liveAdViewRedirectURL:url];
            }
        } break;
        case URLLiveAdOpenType_HIDE: {
            
        } break;
        default:
            break;
    }
}

@end
