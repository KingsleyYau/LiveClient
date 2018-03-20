//
//  UserInfoManager.h
//  livestream
//
//  Created by Max on 2017/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSUserInfoModel.h"
#import "LSSessionRequestManager.h"
#import "LSGetManBaseInfoRequest.h"
#import "LSSetManBaseInfoRequest.h"
@interface UserInfoManager : NSObject

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

#pragma mark - 获取用户详情
typedef void (^GetUserInfoHandler)(LSUserInfoModel * _Nonnull item);

/**
 获取用户详情

 @param userId 用户Id
 @param finishHandler 获取成功回调
 */
- (void)getUserInfo:(NSString * _Nonnull)userId finishHandler:(GetUserInfoHandler _Nullable)finishHandler;


/**
 3.12获取指定观众信息

 @param userId 用户id
 @param finishHandler 获取成功回调
 */
- (void)getFansBaseInfo:(NSString * _Nonnull)userId finishHandler:(GetUserInfoHandler _Nullable)finishHandler;


/**
 6.10获取主播/观众信息

 @param userId 用户id
 @param finishHandler 获取成功回调
 */
- (void)getLiverInfo:(NSString * _Nonnull)userId finishHandler:(GetUserInfoHandler _Nullable)finishHandler;

/**
 获取用户详情 独立专用
 @param finishHandler 获取成功回调
 */
- (void)getMyProfileInfoFinishHandler:(GetManBaseInfoFinishHandler _Nullable)finishHandler;

/**
 设置用户详情 独立专用
 @param finishHandler 获取成功回调
 */
- (void)setUserInfo:(NSString *_Nonnull)name FinishHandler:(SetManBaseInfoFinishHandler _Nullable)finishHandler;
@end
