//
//  IMutexService.h
//  dating
//  互斥服务接口类
//  Created by Max on 2018/7/11.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#ifndef IMutexService_h
#define IMutexService_h

#import <Foundation/Foundation.h>

/**
 互斥服务接口类
 */
@protocol IMutexService <NSObject>
/**
 服务名称

 @return 服务名称
 */
- (NSString *)serviceName;

/**
 服务冲突时候提示

 @return 服务冲突时候提示
 */
- (NSString *)serviceConflictTips;

/**
 站点Id
 
 @param siteId 站点Id
 */
- (void)setSiteId:(NSString *)siteId;

/**
 停止互斥服务
 */
- (void)stopService;

/**
 是否需要停止互斥服务
 
 @param url 将要打开的URL
 @param siteId 站点Id
 @return 是否
 */
- (BOOL)isStopService:(NSURL *)url siteId:(NSString *)siteId;

/**
 解析调用过来的URL
 
 @param url 原始链接
 
 @return 处理结果[YES:成功/NO:失败]
 */
- (BOOL)handleOpenURL:(NSURL *)url fromVC:(UIViewController *)fromVC;

@end

#endif
