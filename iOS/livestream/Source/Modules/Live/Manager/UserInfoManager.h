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
 缓存主播信息

 @param item 主播资料
 */
- (void)setLiverInfoDic:(LSUserInfoModel * _Nonnull)item;

/**
 缓存用户信息

 @param item 用户资料
 */
- (void)setAudienceInfoDicL:(LSUserInfoModel * _Nonnull)item;

/**
 移除所有信息
 */
- (void)removeAllInfo;

@end

