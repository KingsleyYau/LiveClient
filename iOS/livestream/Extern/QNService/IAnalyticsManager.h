//
//  IAnalyticsManager.h
//  livestream
//
//  Created by Calvin on 17/10/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAnalyticsManager <NSObject>
@optional;
/**
 *  跟踪屏幕创建
 *
 *  @param viewController 界面控制器实例
 */
- (void)reportAllocScreen:(UIViewController *_Nonnull)viewController;

/**
 *  跟踪屏幕销毁
 *
 *  @param viewController 界面控制器实例
 */
- (void)reportDeallocScreen:(UIViewController *_Nonnull)viewController;

/**
 *  跟踪屏幕显示
 *
 *  @param viewController 界面控制器实例
 */
- (void)reportShowScreen:(UIViewController *_Nonnull)viewController;

/**
 *  跟踪屏幕消失
 *
 *  @param viewController 界面控制器实例
 */
- (void)reportDismissScreen:(UIViewController *_Nonnull)viewController;

/**
 *  跟踪屏幕显示页
 *
 *  @param viewController   界面控制器实例
 *  @param pageIndex        页面号
 */
- (void)reportDidShowPage:(UIViewController* _Nonnull)viewController pageIndex:(NSUInteger)pageIndex;


/**
 跟踪用户点击事件

 @param action 事件操作
 @param category 类型
 */
- (void)reportActionEvent:(NSString * _Nonnull)action eventCategory:(NSString * _Nonnull)category;
/**
 *  跟踪App被打开
 *
 *  @param url 被打开的URL
 */
- (void)openURL:(NSURL * _Nonnull)url;

@end
