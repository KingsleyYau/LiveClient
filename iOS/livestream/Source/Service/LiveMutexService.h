//
//  LiveMutexService.h
//  livestream
//
//  Created by Max on 2017/10/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - QN
#import "IService.h"

@interface LiveMutexService : NSObject <IMutexService>
#pragma mark - 模块内部调用
/**
 获取实例

 @return 实例
 */
+ (instancetype)service;

/**
 跳转指定链接

 @param url 链接
 */
- (void)openUrlByLive:(NSURL *)url;

/**
 内部开启服务
 */
- (void)startService;

/**
 内部停止服务
 */
- (void)closeService;

@end
