//
//  UserInfoManager.h
//  livestream
//
//  Created by Max on 2017/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AudienModel.h"
@interface UserInfoManager : NSObject

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

#pragma mark - 获取用户详情
typedef void (^GetUserInfoHandler)(AudienModel * _Nonnull item);

/**
 3.12获取指定观众信息
 
 @param userId 用户id
 @param finishHandler 获取成功回调
 */
- (void)getFansBaseInfo:(NSString * _Nonnull)userId finishHandler:(GetUserInfoHandler _Nullable)finishHandler;


/**
 缓存用户信息

 @param item 用户资料
 */
- (void)setAudienceInfoDicL:(AudienModel * _Nonnull)item;

/**
 移除所有信息
 */
- (void)removeAllInfo;

@end

