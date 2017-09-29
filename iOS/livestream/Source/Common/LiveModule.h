//
//  LiveModuleManager.h
//  livestream
//
//  Created by randy on 2017/8/3.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IServiceManager.h"

#define SAMSON_TOKEN @"Samson_iy5gL22gsTDJ"
#define MAX_TOKEN @"Max_rklm7BZwcERW"
#define RANDY_TOKEN @"Randy_7D9asnVphU5p"
#define HUNTER_TOKEN @"Hunter_fZUUNpjlEO9o"
#define HARRY_TOKEN @"Harry_HHeEoKeotNFp"
#define ALEX_TOKEN @"Alex_Jd4i0p5A30aH"
#define LVY_TOKEN @"ivy_CMTS09548"

@class LiveModule;
@class LiveChannelAdView;
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
- (void)module:(LiveModule *)module onLogout:(BOOL)kick msg:(NSString *)msg;

/**
  直播模块广告回调

 @param module 模块实例
 @param adView 广告界面
 */
- (void)module:(LiveModule *)module onGetAdView:(LiveChannelAdView *)adView;

@end

@interface LiveModule : NSObject
/**
 模块主界面
 */
@property (strong) UIViewController *moduleViewController;

/**
 来源界面
 */
@property (strong) UIViewController *fromVC;

/**
 委托
 */
@property (weak) id<LiveModuleDelegate> delegate;

/**
 互斥服务器管理器
 */
@property (nonatomic, strong) IServiceManager *serviceManager;

/**
 获取实例

 @return 实例
 */
+ (instancetype)module;

/**
 开启模块
 @param token 身份标记
 @return YES:开启成功/NO:开启失败
 */
- (BOOL)start:(NSString *)token;

/**
 停止模块
 */
- (void)stop;


/**
 获取广告view
 */
- (void)getAdView;

@end
