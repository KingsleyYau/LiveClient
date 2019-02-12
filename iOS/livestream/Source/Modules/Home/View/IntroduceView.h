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
- (void)webViewJSCallbackAppGAEvent:(NSString * _Nonnull)event;
// 关闭当前WebView的JS接口
- (void)webViewJSCallbackAppCloseWebView;
// Web通知App页面加载失败
- (void)webViewJSCallbackWebReload:(NSString * _Nonnull)error;
// 账号token过期
- (void)webViewJSCallBackTokenTimeOut:(NSString *_Nonnull)error;
// 账号余额不足
- (void)webViewJSCallBackAddCredit:(NSString * _Nonnull)error;
// 节目GA跟踪事件JS接口
- (void)webViewJSCallbackAppPublicGAEvent:(NSString * _Nonnull)event category:(NSString * _Nonnull)category label:(NSString * _Nonnull)label;
@end

@interface IntroduceView : WKWebView

@property (nonatomic, weak) id<WebViewJSDelegate> _Nullable webViewJSDelegate;

// app调用JS回到前台接口
- (void)webViewTransferResumeHandler:(JSFinshHandler _Nonnull)handler;
- (void)webViewNotifyLiveAppUnreadCount:(NSString * _Nonnull)unreadCount Handler:(JSFinshHandler _Nonnull)handler;
@end
