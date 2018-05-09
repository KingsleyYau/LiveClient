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
@protocol WebViewJSDelegate <NSObject>
@optional
// GA跟踪事件JS接口
- (void)webViewJSCallbackAppGAEvent:(NSString *)event;
// 关闭当前WebView的JS接口
- (void)webViewJSCallbackAppCloseWebView;
// Web通知App页面加载失败
- (void)webViewJSCallbackWebReload:(NSString *)Errno;
- (void)webViewJSCallbackInvite:(NSString *)userid nickName:(NSString *)name photo:(NSString *)photoUrl;
- (void)webViewJSCallbackWebAuthExpired:(NSString *)errmsg;

@end

@interface IntroduceView : WKWebView

@property (nonatomic, weak) id<WebViewJSDelegate> webViewJSDelegate;

@end
