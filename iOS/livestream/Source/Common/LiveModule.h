//
//  LiveModuleManager.h
//  livestream
//
//  Created by randy on 2017/8/3.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SAMSON_TOKEN @"Samson_iy5gL22gsTDJ"
#define MAX_TOKEN @"Max_rklm7BZwcERW"
#define RANDY_TOKEN @"Randy_7D9asnVphU5p"
#define HUNTER_TOKEN @"Hunter_fZUUNpjlEO9o"
#define HARRY_TOKEN @"Harry_HHeEoKeotNFp"
#define ALEX_TOKEN @"Alex_Jd4i0p5A30aH"

@class LiveModule;
@protocol LiveModuleDelegate <NSObject>
@optional
/**
 直播模块注销回调

 @param module 模块实例
 @param kick 是否主动注销(YES:主动/NO:超时)
 */
- (void)module:(LiveModule *)module onLogout:(BOOL)kick;

@end

@interface LiveModule : NSObject
/**
 模块主界面
 */
@property (strong) UIViewController *moduleViewController;

/**
 委托
 */
@property (weak) id<LiveModuleDelegate> delegate;

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

@end
