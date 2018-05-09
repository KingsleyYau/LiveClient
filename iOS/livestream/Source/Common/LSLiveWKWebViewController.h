//
//  LSLiveWKWebViewController.h
//  livestream
//
//  Created by randy on 2017/11/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroduceView.h"
#import "LSRequestManager.h"
#import "LSConfigManager.h"
#import "LiveUrlHandler.h"
#import "IntroduceViewController.h"

@protocol LSLiveWKWebViewControllerDelegate<NSObject>
@optional

@end

@interface LSLiveWKWebViewController : NSObject

@property (nonatomic,weak) id<LSLiveWKWebViewControllerDelegate> delegate;
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
 是否普通请求
 */
@property (nonatomic, assign) BOOL isRequestWeb;

// 清理所有cookies
- (void)clearAllCookies;

// 发送请求
- (void)requestWebview;

@end
