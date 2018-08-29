//
//  IMutexService.h
//  dating
//  互斥服务接口类
//  Created by Max on 2018/7/11.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 停止互斥服务
 */
- (void)stopService;

/**
 是否需要停止互斥服务
 
 @param url 将要打开的URL
 @return 是否
 */
- (BOOL)isStopService:(NSURL *)url;

/**
 解析调用过来的URL
 
 @param url 原始链接
 
 @return 处理结果[YES:成功/NO:失败]
 */
- (BOOL)handleOpenURL:(NSURL *)url fromVC:(UIViewController *)fromVC;

@end
