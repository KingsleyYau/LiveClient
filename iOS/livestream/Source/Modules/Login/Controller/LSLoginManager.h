//
//  LSLoginManager.h
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IService.h"

#import "LSLoginItemObject.h"
#import "LSRegisterItemObject.h"

@class LSLoginManager;
@protocol LoginManagerDelegate <NSObject>
@optional

/**
 *  登陆回调
 *
 *  @param manager   登陆状态管理器实例
 *  @param success   是否登陆成功
 *  @param loginItem 登陆成功Item
 *  @param errnum  登陆失败错误码
 *  @param errmsg 登陆失败错误提示
 */
- (void)manager:(LSLoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject * _Nullable)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString * _Nonnull)errmsg;

/**
 *  注销回调
 *
 *  @param manager 登陆状态管理器实例
 *  @param kick  是否主动注销(YES:主动/NO:超时)
 */
- (void)manager:(LSLoginManager * _Nonnull)manager onLogout:(LogoutType)type msg:(NSString * _Nullable)msg;

@end

@interface LSLoginManager : NSObject <ILoginService>
/**
 *  登陆状态
 */
@property (nonatomic, assign, readonly) LoginStatus status;

/**
 身份Id
 */
@property (nonatomic, strong, readonly) NSString* _Nullable manId;

/**
 身份
 */
@property (nonatomic, strong, readonly) NSString* _Nullable token;

/**
 *  用户信息
 */
@property (nonatomic, strong, readonly) LSLoginItemObject* _Nullable loginItem;

/**
 *  用户系统所在国
 */
@property (nonatomic, copy) NSString* _Nullable fullName;

/**
 *  用户所在地区号
 */
@property (nonatomic, copy) NSString* _Nullable zipCode;

/**
 *  用户名
 */
@property (nonatomic, strong, readonly) NSString* _Nullable email;

/**
 *  密码
 */
@property (nonatomic, strong, readonly) NSString* _Nullable password;

/**
 *  上一次输入用户名
 */
@property (nonatomic, strong, readonly) NSString* _Nullable lastInputEmail;

/**
 *  上一次输入密码
 */
@property (nonatomic, strong, readonly) NSString* _Nullable lastInputPassword;

/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

/**
 *  增加监听器
 *
 *  @param delegate 监听器
 */
- (void)addDelegate:(id<LoginManagerDelegate> _Nonnull)delegate;

/**
 *  移除监听器
 *
 *  @param delegate 监听器
 */
- (void)removeDelegate:(id<LoginManagerDelegate> _Nonnull)delegate;

/**
 *  登陆接口
 *
 *  @param manId    QN会员ID
 *  @param userSid  QN系统登录验证返回的标识
 *
 *  @return 是否进入登陆中状态
 */
- (LoginStatus)login:(NSString * _Nonnull)manId userSid:(NSString * _Nonnull)userSid;

/**
 注销
 
 @param type 注销类型
 */
- (void)logout:(LogoutType)type msg:(NSString * _Nullable)msg;

/**
 *  自动登陆
 *
 *  @return 是否进入登陆中状态
 */
- (BOOL)autoLogin;

/*************** 模块接口 ***************/
/**
 模块登录接口

 @param user 用户Id
 @param password 密码
 @param checkcode 验证码
 @return 登录状态
 */
- (LoginStatus)login:(NSString * _Nonnull)user password:(NSString * _Nonnull)password checkcode:(NSString * _Nullable)checkcode;

@end
