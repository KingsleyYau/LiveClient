//
//  LiveModuleManager.h
//  livestream
//
//  Created by randy on 2017/8/3.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IService.h"

#pragma mark - QNToken
#define SAMSON_TOKEN @"Samson_iy5gL22gsTDJ"
#define MAX_TOKEN @"Max_rklm7BZwcERW"
#define RANDY_TOKEN @"Randy_7D9asnVphU5p"
#define HUNTER_TOKEN @"Hunter_fZUUNpjlEO9o"
#define HARRY_TOKEN @"Harry_HHeEoKeotNFp"
#define ALEX_TOKEN @"Alex_Jd4i0p5A30aH"
#define IVY_TOKEN @"ivy2_CMTS09553"
#define CALVIN_TOKEN @"Calvin_CMTS09563"
#define LANCE_TOKEN @"Lance_CMTS09562"
#define JAGGER_TOKEN @"Jagger_CMTS09564"

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
 @param type 是否主动注销(YES:主动/NO:超时)
 */
- (void)moduleOnLogout:(LiveModule *)module type:(LogoutType)type msg:(NSString *)msg;

/**
 直播模块需要显示浮窗

 @param module 模块实例
 */
//- (void)moduleOnNotification:(LiveModule *)module;

/**
 直播模块需要消失浮窗

 @param module 模块实例
 */
//- (void)moduleOnNotificationDisappear:(LiveModule *)module;

@end

@interface LiveModule : NSObject
#pragma mark - 界面控制器
/**
 模块主界面(每次调用会创建新实例)
 */
@property (strong, readonly) UIViewController *mainVC;

/**
 模块主界面(内部用, 不会创建新的实例)
 */
@property (strong, readonly) UIViewController *moduleVC;

/**
 通知浮窗控制器
 */
@property (strong, readonly) UIViewController *notificationVC;

/**
 通过外部链接打开测试模式
 */
@property (assign) BOOL test;

/**
 通过外部链接打开Http代理模式
 */
@property (strong, nonatomic) NSString *httpProxy;

/**
 来源界面导航栏颜色
 */
@property (readonly) UIColor *tintColor;
@property (readonly) UIColor *barTintColor;
@property (readonly) NSDictionary *barTitleTextAttributes;

/** 买点界面 */
@property (strong) UIViewController *addCreditVc;

#pragma mark - 基本属性
/**
 委托
 */
@property (weak) id<LiveModuleDelegate> delegate;
/**
 委托
 */
@property (weak) id<LiveModuleDelegate> noticeDelegate;
/**
 直播服务
 */
@property (weak, readonly) id<IMutexService> mutexService;
/**
 登录服务
 */
@property (weak, readonly) id<ILoginService> loginService;
/**
 换站服务
 */
@property (weak, readonly) id<ISiteService> siteService;
/**
 互斥服务器管理器
 */
@property (weak, nonatomic) id<IMutexServiceManager> serviceManager;
/**
 GA跟踪管理器
 */
@property (weak, nonatomic) id<IAnalyticsManager> analyticsManager;

/**
 通知链接处理服务
 */
@property (weak, nonatomic) id<INotificationsServiceService> notificationsServiceService;
/**
 换站管理器
 */
@property (weak) id<ISiteManager> siteManager;

#pragma mark - 公用属性
/**
 是否Debug模式
 */
@property (assign) BOOL debug;
/**
 是否输出日志
 */
@property (assign, nonatomic) BOOL debugLog;
/**
 应用版本号,用于提交网页内部提交
 */
@property (copy) NSString *appVerCode;
/**
 个人中心版本号
 */
@property (copy) NSString *appStringVerCode;
/**
 直播资源目录
 */
@property (strong, nonatomic, readonly) NSBundle *liveBundle;

/**
 鲜花礼品折扣图片
*/
@property (nonatomic, copy) NSString * flowersGift;
#pragma mark - 普通更新
/**
 是否需要普通更新
 */
@property (nonatomic, assign) BOOL isUpdate;
/**
 客户端更新链接
 */
@property (nonatomic, copy) NSString *updateStoreURL;
/**
 客户端更新描述
 */
@property (nonatomic, copy) NSString *updateDesc;

#pragma mark - 外部接口
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
 释放模块主界面
 */
- (void)destroyModuleVC;

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

/**
 清除缓存
 */
- (void)cleanCache;

#pragma mark - Application(通知)
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;

@end
