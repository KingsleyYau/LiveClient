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
#import "ConfigItemObject.h"

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
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg;

/**
 *  注销回调
 *
 *  @param manager 登陆状态管理器实例
 *  @param type  注销类型
 */
- (void)manager:(LSLoginManager *)manager onLogout:(LogoutType)type msg:(NSString *)msg;

@end

@interface LSLoginManager : NSObject <ILoginService>
/**
 *  登陆状态
 */
@property (nonatomic, assign, readonly) LoginStatus status;

/**
 身份Id
 */
@property (nonatomic, strong, readonly) NSString* manId;

/**
 身份
 */
@property (nonatomic, strong, readonly) NSString* token;

/**
 *  用户信息
 */
@property (nonatomic, strong, readonly) LSLoginItemObject* loginItem;

/**
 *  用户系统所在国
 */
@property (nonatomic, copy) NSString* fullName;

/**
 *  用户所在地区号
 */
@property (nonatomic, copy) NSString* zipCode;

/**
 *  用户名
 */
@property (nonatomic, strong, readonly) NSString* userId;

/**
 *  密码
 */
@property (nonatomic, strong, readonly) NSString* password;

/**
 *  同步配置的信息，暂用于livechat
 */
@property (nonatomic, strong) ConfigItemObject* configItem;


/**
    livechat登录
 */
@property (nonatomic, assign) BOOL isLivechatLogin;
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype)manager;

/**
 *  增加监听器
 *
 *  @param delegate 监听器
 */
- (void)addDelegate:(id<LoginManagerDelegate>)delegate;

/**
 *  移除监听器
 *
 *  @param delegate 监听器
 */
- (void)removeDelegate:(id<LoginManagerDelegate> )delegate;

///**
// *  登陆接口
// *
// *  @param manId    QN会员ID
// *  @param userSid  QN系统登录验证返回的标识
// *
// *  @return 是否进入登陆中状态
// */
//- (LoginStatus)login:(NSString * _Nonnull)manId userSid:(NSString * _Nonnull)userSid;

- (LoginStatus)loginWithSession:(NSString *)sessionId;

/**
 注销
 
 @param type 注销类型
 */
- (void)logout:(LogoutType)type msg:(NSString *)msg;

/**
 *  自动登陆
 *
 *  @return 是否进入登陆中状态
 */
- (BOOL)autoLogin;

- (LoginStatus)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode userId:(NSString *)userId token:(NSString *)token;

@end
