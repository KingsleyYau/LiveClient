//
//  RandomListAdView.h
//  dating
//
//  Created by test on 2019/9/27.
//  Copyright © 2019 qpidnetwork. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN
// 广告URL打开方式
typedef enum {
    URLOpenType_DEFAULT = 0,            // 当前WebView打开
    URLOpenType_SYSTEMBROWER = 1,    // 系统浏览器打开
    URLOpenType_APPBROWER = 2,       // APP内嵌浏览器打开
    URLOpenType_HIDE = 3           // 隐藏WebView打开
} URLOpenType;

@class LSHotListAdView;
@protocol LSHotListAdViewDelegate<NSObject>
@optional
//打开重定向URL
- (void)lsLiveWebViewRedirectURL:(NSURL *)url;
//关闭webView回调
- (void)lsWebViewDidClose;

- (void)lsLiveWebViewDidFinishLoad:(LSHotListAdView *)webView;

- (void)lsLiveWebView:(LSHotListAdView *)webView didFailLoadWithError:(NSError *)error;
@end

@interface LSHotListAdView : WKWebView<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic, weak) id<LSHotListAdViewDelegate> webDelegate;
@property (nonatomic, assign) URLOpenType openType;
@property (nonatomic, copy) NSString * apptitle;
@property (nonatomic, copy) NSString * loadedURL;
@property (nonatomic, assign) UIWebViewNavigationType navType;

- (void)loadURL:(NSString *)webSiteUrl;
- (void)loadUrlRequest:(NSMutableURLRequest *)request;
- (void)clearAllCookies;
@end

NS_ASSUME_NONNULL_END
