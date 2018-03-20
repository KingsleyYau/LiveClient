//
//  AnalyticsManager.h
//  dating
//
//  Created by  Samson on 6/28/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  跟踪管理器

#import <Foundation/Foundation.h>
#import <Google/Analytics.h>
#import "LSLoginManager.h"
#import "ScreenManager.h"
#import "AppDelegate.h"
#import "ScreenItem.h"

@interface LSAnalyticsManager : NSObject

/**
 *  获取跟踪单件跟踪管理器
 *
 *  @return 跟踪管理器
 */
+ (LSAnalyticsManager* _Nonnull)manager;

/**
 *  初始化Google跟踪
 *  @param isReal   是否真实环境(运营的站点环境)
 */
- (void)initGoogleAnalytics:(BOOL)isReal;

/**
 *  跟踪屏幕创建
 *
 *  @param viewController ViewController
 */
- (void)reportAllocScreen:(UIViewController* _Nonnull)viewController;

/**
 *  跟踪屏幕销毁
 *
 *  @param viewController ViewController
 */
- (void)reportDeallocScreen:(UIViewController* _Nonnull)viewController;

/**
 *  跟踪屏幕显示
 *
 *  @param viewController ViewController
 */
- (void)reportShowScreen:(UIViewController* _Nonnull)viewController;

/**
 *  跟踪屏幕消失
 *
 *  @param viewController ViewController
 */
- (void)reportDismissScreen:(UIViewController* _Nonnull)viewController;

/**
 *  跟踪屏幕显示页
 *
 *  @param viewController   ViewController
 *  @param pageIndex            页面号
 */
- (void)reportDidShowPage:(UIViewController* _Nonnull)viewController pageIndex:(NSUInteger)pageIndex;

/**
 *  跟踪App被打开
 *
 *  @param url 被打开的URL
 */
- (void)openURL:(NSURL * _Nonnull)url;

/**
 跟踪app点击事件

 @param action 操作事件
 @param category 操作分类
 */
- (void)reportActionEvent:(NSString * _Nonnull)action eventCategory:(NSString * _Nonnull)category;


/**
 跟踪app点击事件类型

 @param action 操作事件
 @param category 操作分类
 @param label 操作标签
 */
- (void)reportActionEvent:(NSString * _Nonnull)action eventCategory:(NSString * _Nonnull)category label:(NSString * _Nonnull)label;
@end
