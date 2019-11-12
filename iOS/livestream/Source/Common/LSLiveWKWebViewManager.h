//
//  LSLiveWKWebViewManager.h
//  livestream
//
//  Created by randy on 2017/11/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroduceView.h"
#import "LSConfigManager.h"
#import "LiveUrlHandler.h"
#import "IntroduceViewController.h"

@protocol LSLiveWKWebViewManagerDelegate<NSObject>
@optional

/**
 开始获取界面内容是返回
 */
- (void)webViewdidCommitNavigation;

/**
 界面加载完成
 */
- (void)webViewDidFinishNavigation;

/**
 界面跳转失败
 */
- (void)webViewdidFailProvisionalNavigation;


/**
 缓存过载
 */
- (void)webViewdidRecvWebContentProcessDidTerminate;

/**
 url重定向 解析需要关闭当前webview
 */
- (void)webViewdecidePolicyForNavigationCloseUrl;

- (void)liveWebView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
/**
 url重定向 打开新的webview界面

 @param urlStr 请求url
 @param title 标题
 @param screenName ga跟踪
 @param alphaType 是否显示导航栏
 @param isResume 是否需要显示界面请求js接口
 */
- (void)webViewdidOpenNewWebView:(NSString *)urlStr title:(NSString *)title screenName:(NSString *)screenName alphaType:(BOOL)alphaType isResume:(BOOL)isResume;

/**
 url重定向 是否需要显示界面请求js接口

 @param isResume 标志位
 */
- (void)webViewTransferJSIsResume:(BOOL)isResume;
@end

@interface LSLiveWKWebViewManager : NSObject

@property (nonatomic,weak) id<LSLiveWKWebViewManagerDelegate> delegate;
/**
 加载视图
 */
@property (nonatomic, weak) IntroduceView *liveWKWebView;
/**
 视图控制器
 */
@property (nonatomic, weak) LSListViewController *controller;
/**
 跳转url
 */
@property (copy, nonatomic) NSString *baseUrl;
/**
 同步管理器
 */
@property (nonatomic, strong) LSConfigManager *configManager;
/**
 是否显示导航栏
 */
@property (nonatomic, assign) BOOL isShowTaBar;

/**
 *  这个只有主播详情使用，从主播详情进入节目标志位， 因为根据url判断从详情进节目就导航栏过去, 设置isFirstProgram为false防止多次点击，等到了主播详情出现节目，再设置为true；
 */
@property (nonatomic, assign) BOOL isFirstProgram;
/** 重定向url */
@property (nonatomic, copy) NSString *restrictUrl;

// 清理所有cookies
- (void)clearAllCookies;

// 发送请求
- (void)requestWebview;

// 重置第一次请求标志位
- (void)resetFirstProgram;

@end
