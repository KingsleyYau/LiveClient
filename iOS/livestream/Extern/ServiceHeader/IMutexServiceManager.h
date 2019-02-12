//
//  IServiceManager.h
//  dating
//  互斥服务管理器接口类
//  Created by Calvin on 17/9/11.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#ifndef IMutexServiceManager_h
#define IMutexServiceManager_h

#import <Foundation/Foundation.h>
#import "IMutexService.h"

#pragma mark - 消息中心通知
/**
 换站通知Key
 */
#define ASMNotificationReload @"ASMNotificationReload"

/**
 互斥服务管理器接口类
 */
@protocol IMutexServiceManager <NSObject>
/**
 增加互斥服务

 @param service 服务实例
 */
- (void)addService:(id<IMutexService>)service;

/**
 移除互斥服务

 @param service 服务实例
 */
- (void)removeService:(id<IMutexService>)service;

/**
 注册互斥服务

 @param service 服务实例
 */
- (void)startService:(id<IMutexService>)service;

/**
 注销互斥服务
 
 @param service 服务实例
 */
- (void)stopService:(id<IMutexService>)service;

/**
 是否App内部处理的URL
 
 @param url 原始链接
 @return 处理结果[YES:链接可以被内部模块处理/NO:链接不能被内部模块处理]
 */
- (BOOL)canOpenURL:(NSURL *)url;

/**
 解析调用过来的URL
 
 @param url 原始链接
 
 @return 处理结果[YES:成功/NO:失败]
 */
- (BOOL)handleOpenURL:(NSURL *)url;

@end

#endif
