//
//  UserInfoManager.h
//  livestream
//
//  Created by Max on 2017/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserInfo.h"
#import "SessionRequestManager.h"

@interface UserInfoManager : NSObject

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

#pragma mark - 获取用户详情
typedef void (^GetUserInfoHandler)(UserInfo * _Nonnull item);
/**
 获取用户详情

 @param userId 用户Id
 @param finishHandler 获取成功回调
 */
- (void)getUserInfo:(NSString * _Nonnull)userId finishHandler:(GetUserInfoHandler _Nullable)finishHandler;

@end
