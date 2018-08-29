//
//  ILoginService.h
//  dating
//  登录服务接口类
//  Created by Max on 2018/7/11.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ILoginService <NSObject>

#pragma mark - 登录接口
// 登录结果回调
typedef void (^AppLoginFinishHandler)(BOOL success, NSString * errnum, NSString * errmsg, NSString * manId);

// 登录状态类型
typedef enum {
    NONE = 0,
    LOGINING,
    LOGINED
} LoginStatus;

/**
 登录
 
 @param user 用户
 @param password 密码
 @param checkcode 验证码
 @return 登录状态
 */
- (LoginStatus)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode handler:(AppLoginFinishHandler)handler;
- (LoginStatus)loginWithToken:(NSString *)token userid:(NSString *)userid handler:(AppLoginFinishHandler)handler;

#pragma mark - 注销接口
// 注销操作类型
typedef enum {
    LogoutTypeActive = 0, // 主动注销
    LogoutTypeKick,       // 被服务器踢下线
    LogoutTypeRelogin,    // 需要无感知重新登录(如Session超时)
} LogoutType;

/**
 注销

 @param type 注销类型
 */
- (void)logout:(LogoutType)type;

@end
