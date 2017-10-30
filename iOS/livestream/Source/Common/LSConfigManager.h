//
//  LSConfigManager.h
//  dating
//
//  Created by Max on 16/2/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSRequestManager.h"
#import "GetConfigRequest.h"

@interface LSConfigManager : NSObject
@property (assign) BOOL dontShow2WayVideoDialog;
@property (nonatomic, strong) ConfigItemObject* _Nullable item;

#pragma mark - 获取实例
+ (instancetype _Nonnull)manager;

/**
 *  获取同步配置
 *
 *  @param finishHandler 完成回调
 *
 *  @return 是否进入同步中状态
 */
- (BOOL)synConfig:(GetConfigFinishHandler _Nullable)finishHandler;

/**
 *  清除
 */
- (void)clean;

/**
 保存配置
 */
- (void)saveConfigParam;

@end
