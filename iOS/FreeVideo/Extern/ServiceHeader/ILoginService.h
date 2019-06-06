//
//  ILoginService.h
//  dating
//  登录服务接口类
//  Created by Max on 2018/7/11.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#ifndef ILoginService_h
#define ILoginService_h

#import <Foundation/Foundation.h>

#import "IErrorType.h"

/**
 登录服务接口类
 */
@protocol ILoginService <NSObject>

#pragma mark - 登录接口
// 登录结果回调
typedef void (^AppLoginFinishHandler)(BOOL success, ErrorType errType, NSString *errmsg, NSString *manId);

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
- (LoginStatus)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode userId:(NSString *)userId token:(NSString *)token handler:(AppLoginFinishHandler)handler;

/**
 直接调用登录接口, 检查能否登录
 
 @param user 用户
 @param password 密码
 @param checkcode 验证码
 @return 调用结果
 */
- (BOOL)loginCheck:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode handler:(AppLoginFinishHandler)handler;

#pragma mark - 注销接口
// 注销操作类型
typedef enum {
    LogoutTypeActive = 0, // 主动注销
    LogoutTypeKick,       // 被服务器踢下线
    LogoutTypeRelogin,    // 无感知重新登录(如Session超时)
    LogoutTypeChangeSite, // 无感知重新登录, 注销过程不弹出登录界面, 登录失败才弹出(如换站)
    LogoutTypeUnknow,     // 未知
} LogoutType;

/**
 注销
 
 @param type 注销类型
 */
- (void)logout:(LogoutType)type;

#pragma mark - 获取验证码接口
// 获取验证码结果回调
typedef void (^AppGetCheckCodeFinishHandler)(BOOL success, ErrorType errType, NSString *errmsg, UIImage *image);
- (void)getCheckCodeIsMust:(BOOL)isMust handler:(AppGetCheckCodeFinishHandler)handler;

@end

#endif
