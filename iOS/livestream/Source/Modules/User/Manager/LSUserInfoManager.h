//
//  LSUserInfoManager.h
//  livestream
//  用户信息缓存管理器
//  Created by test on 2019/3/6.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSUserInfoModel.h"

@interface LSUserInfoManager : NSObject
typedef void (^GetUserInfoHandler)(LSUserInfoModel * item);

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype)manager;

/**
 获取用户信息(仅缓存)

 @param userId 用户Id
 @return 本地缓存
 */
- (LSUserInfoModel *)getUserInfoLocal:(NSString *)userId;

/**
 获取用户信息(缓存->接口)

 @param userId 用户Id
 @param finishHandler 回调
 */
- (void)getUserInfo:(NSString *)userId finishHandler:(GetUserInfoHandler)finishHandler;
/**
获取用户信息(缓存)
直接获取接口
@param userId 用户Id
@param finishHandler 回调
*/
- (void)getUserInfoWithRequest:(NSString *)userId finishHandler:(GetUserInfoHandler)finishHandler;

/// 清除用户信息缓存
- (void)removeAllUserInfo;
@end
