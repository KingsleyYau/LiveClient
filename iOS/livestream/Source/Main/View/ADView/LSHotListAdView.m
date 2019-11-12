//
//  RandomListAdView.m
//  dating
//
//  Created by test on 2019/9/27.
//  Copyright © 2019 qpidnetwork. All rights reserved.
//

#import "LSHotListAdView.h"
#import "LiveModule.h"
#define APP_MODULE_NAME @"qpidnetwork://app/open?"
#define QpidLive @"qpidnetwork-live://app/open?"
@implementation LSHotListAdView
- (instancetype)initWithCoder:(NSCoder *)coder{
    
    CGRect frame = CGRectMake(0, 0, screenSize.width * 0.8, 288);
    
    WKWebViewConfiguration *myConfiguration = [[WKWebViewConfiguration alloc] init];
    myConfiguration.preferences.javaScriptEnabled = YES;
    myConfiguration.allowsInlineMediaPlayback = YES;
    
    self.backgroundColor = [UIColor clearColor];
    
    self = [super initWithFrame:frame configuration:myConfiguration];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.UIDelegate = self;
    self.navigationDelegate = self;
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initDelegate];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDelegate];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initDelegate];
    }
    return self;
}

- (void)initDelegate {
    self.UIDelegate = self;
    self.navigationDelegate = self;
}

- (void)loadURL:(NSString *)webSiteUrl {
    self.loadedURL = webSiteUrl;
    // 清除cookie
    [self clearAllCookies];

    
    NSURL *url = [NSURL URLWithString:webSiteUrl];
    // url请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    
    [request setHTTPShouldHandleCookies:YES];
    [request setAllHTTPHeaderFields:headers];
    
    [request setTimeoutInterval:60];
    
    [self loadRequest:request];
}

- (void)loadUrlRequest:(NSMutableURLRequest *)request {

    // 清除cookie
    [self clearAllCookies];
    
    [request setHTTPShouldHandleCookies:YES];
    
    [request setTimeoutInterval:60];
    
    [self loadRequest:request];
}

// 设置头部cookie
- (NSMutableURLRequest *)setupCookie:(NSURLRequest *)request {
    // 清除cookie
    [self clearAllCookies];
    // 增加cookie

    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    NSMutableURLRequest *mutalbleRequest = (NSMutableURLRequest *)request;
    [mutalbleRequest setHTTPShouldHandleCookies:YES];
    [mutalbleRequest setAllHTTPHeaderFields:headers];
    
    [mutalbleRequest setTimeoutInterval:60];
    return mutalbleRequest;
}

// 清空所有webview的Cookice
- (void)clearAllCookies {
    NSHTTPCookie *Cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (Cookie in [storage cookies]) {
        [storage deleteCookie:Cookie];
    }
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
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURL *url = navigationAction.request.URL;
    NSString *strAbsolute = [url absoluteString];
    //APP TitleLSURLQueryParam urlParamForKey:@"opentype" url:url
    self.apptitle = [LSURLQueryParam urlParamForKey:@"apptitle" url:url];
    BOOL result = YES;
    
    if (strAbsolute != nil) {
        //判断是否为内部链接
        if ([strAbsolute hasPrefix:APP_MODULE_NAME]|| [strAbsolute containsString:QpidLive]) {
            result = NO;
            [[LiveModule module].serviceManager handleOpenURL:url];
        } else {
            if ((strAbsolute != nil) && [strAbsolute hasPrefix:@"qpidnetwork://app/closewindow"]) {
                result = NO;
                if ([self.webDelegate respondsToSelector:@selector(lsWebViewDidClose)]) {
                    [self.webDelegate lsWebViewDidClose];
                }
            } else {
                
                NSString *opentype = [LSURLQueryParam urlParamForKey:@"opentype" url:url];
                if ([opentype intValue] != 0 && ![self.loadedURL isEqualToString:strAbsolute]) {
                    result = NO;
                    //打开方式
                    self.openType = (URLOpenType)[opentype intValue];
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

- (void)qnWebViewOpenURL:(NSURL *)url openType:(URLOpenType)ytpe {
    
    switch (ytpe) {
        case URLOpenType_DEFAULT: {
            
        } break;
        case URLOpenType_SYSTEMBROWER: {
            [[UIApplication sharedApplication] openURL:url];
        } break;
        case URLOpenType_APPBROWER: {
            if ([self.webDelegate respondsToSelector:@selector(lsLiveWebViewRedirectURL:)]) {
                [self.webDelegate lsLiveWebViewRedirectURL:url];
            }
        } break;
        case URLOpenType_HIDE: {
            
        } break;
        default:
            break;
    }
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if ([self.webDelegate respondsToSelector:@selector(lsLiveWebViewDidFinishLoad:)]) {
        [self.webDelegate lsLiveWebViewDidFinishLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"webView didFailLoadWithError");
    if ([self.webDelegate respondsToSelector:@selector(lsLiveWebView:didFailLoadWithError:)]) {
        [self.webDelegate lsLiveWebView:self didFailLoadWithError:error];
    }
}
@end
