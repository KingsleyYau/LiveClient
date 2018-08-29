//
//  IntroduceView.h
//  livestream
//
//  Created by test on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class IntroduceView;

typedef void (^JSFinshHandler)(id _Nullable response, NSError * _Nullable error);

@protocol WebViewJSDelegate <NSObject>
@optional
// GA跟踪事件JS接口
- (void)webViewJSCallbackAppGAEvent:(NSString *)event;
// 关闭当前WebView的JS接口
- (void)webViewJSCallbackAppCloseWebView;
// Web通知App页面加载失败
- (void)webViewJSCallbackWebReload:(NSString *)error;
// 账号token过期
- (void)webViewJSCallBackTokenTimeOut:(NSString *)error;
// 账号余额不足
- (void)webViewJSCallBackAddCredit:(NSString *)error;
// 节目GA跟踪事件JS接口
- (void)webViewJSCallbackAppPublicGAEvent:(NSString *)event category:(NSString *)category label:(NSString *)label;

#pragma mark - 加载完成回调

/**
 kvo监听加载完成回调

 @param view 加载网页view
 */
- (void)wkWebViewDidCallbackFinish:(IntroduceView *)view;
@end

@interface IntroduceView : WKWebView

@property (nonatomic, weak) id<WebViewJSDelegate> webViewJSDelegate;

// app调用JS回到前台接口
- (void)webViewTransferResumeHandler:(JSFinshHandler)handler;

@end
