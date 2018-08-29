//
//  IServiceManager.h
//  dating
//  互斥服务管理器接口类
//  Created by Calvin on 17/9/11.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IMutexService.h"

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
 解析调用过来的URL
 
 @param url 原始链接
 
 @return 处理结果[YES:成功/NO:失败]
 */
- (BOOL)handleOpenURL:(NSURL *)url;

@end

