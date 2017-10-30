//
//  LiveModuleManager.h
//  livestream
//
//  Created by randy on 2017/8/3.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - QN
#import "IServiceManager.h"
#import "IQNService.h"
#import "IAnalyticsManager.h"

#define SAMSON_TOKEN @"Samson_iy5gL22gsTDJ"
#define MAX_TOKEN @"Max_rklm7BZwcERW"
#define RANDY_TOKEN @"Randy_7D9asnVphU5p"
#define HUNTER_TOKEN @"Hunter_fZUUNpjlEO9o"
#define HARRY_TOKEN @"Harry_HHeEoKeotNFp"
#define ALEX_TOKEN @"Alex_Jd4i0p5A30aH"
#define LVY_TOKEN @"ivy2_CMTS09553"

@class LiveModule;
@protocol LiveModuleDelegate <NSObject>
@optional

/**
 直播模块登陆成功

 */
- (void)moduleOnLogin:(LiveModule *)module;

/**
 直播模块注销回调

 @param module 模块实例
 @param kick 是否主动注销(YES:主动/NO:超时)
 */
- (void)moduleOnLogout:(LiveModule *)module kick:(BOOL)kick msg:(NSString *)msg;

///**
//  直播模块需要显示广告
//
// @param module 模块实例
// @param adView 广告界面
// */
- (void)moduleOnAdViewController:(LiveModule *)module;

/**
 直播模块需要显示浮窗

 @param module 模块实例
 */
- (void)moduleOnNotification:(LiveModule *)module;

@end

@interface LiveModule : NSObject
#pragma mark - 界面控制器
/**
 模块主界面
 */
@property (strong) UIViewController *moduleVC;

/**
 来源界面
 */
@property (strong, nonatomic) UIViewController *fromVC;

/**
 通知浮窗控制器
 */
@property (strong, readonly) UIViewController *notificationVC;

/**
 广告控制器
 */
@property (strong, readonly) UIViewController *adVc;


/**
 来源界面导航栏颜色
 */
@property (copy, readonly) UIColor *tintColor;
@property (copy, readonly) UIColor *barTintColor;
@property (copy, readonly) NSDictionary *barTitleTextAttributes;

/** 买点界面 */
@property (nonatomic, strong) UIViewController* addCreditVc;

#pragma mark - 基本属性
/**
 委托
 */
@property (weak) id<LiveModuleDelegate> delegate;

/**
 互斥服务器管理器
 */
@property (weak, nonatomic) id<IServiceManager> serviceManager;

/**
 直播服务
 */
@property (weak, nonatomic, readonly) id<IQNService> service;

/**
 GA跟踪管理器
 */
@property (weak) id<IAnalyticsManager> analyticsManager;

/**
 获取实例

 @return 实例
 */
+ (instancetype)module;


/**
 设置同步配置服务器地址

 @param url 同步配置服务器地址
 */
- (void)setConfigUrl:(NSString *)url;

/**
 开启模块
 @param manId 男士ID
 @param token 身份标记
 @return YES:开启成功/NO:开启失败
 */
- (BOOL)start:(NSString *)manId token:(NSString *)token;

/**
 停止模块
 */
- (void)stop;

@end
