//
//  LSWebViewJSManager.h
//  livestream
//
//  Created by Randy_Fan on 2018/9/7.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSListViewController.h"
#import "IntroduceView.h"

@protocol LSWebViewJSManagerDelegate<NSObject>
@optional
- (void)jsManagerOnLogin:(BOOL)success;
- (void)jsManagerCallbackCloseWebView;
- (void)jsManagerCallbackWebReload;
- (void)jsManagerCallBackAddCredit:(NSString *)error;
- (void)jsManagerCallBackIsShowNavigation:(NSString *)isShow;
@end

@interface LSWebViewJSManager : NSObject

@property (nonatomic,weak) id<LSWebViewJSManagerDelegate> delegate;

/**
 注册webview用户手册

 @param webView 网页
 */
- (void)setWebViewUserScript:(IntroduceView *)webView;

/**
 移除webview用户手册侧

 @param webView 网页
 */
- (void)removeWebViewUserScript:(IntroduceView *)webView;

@end
