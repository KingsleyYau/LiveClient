//
//  LSLoginManager.h
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSAnchorRequestManager.h"
#import "LSLoginItemObject.h"
#import "LSRegisterItemObject.h"
#import "LiveModule.h"
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
- (void)manager:(LSLoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(ZBLSLoginItemObject * _Nullable)loginItem errnum:(ZBHTTP_LCC_ERR_TYPE)errnum errmsg:(NSString * _Nonnull)errmsg;

/**
 *  注销回调
 *
 *  @param manager 登陆状态管理器实例
 *  @param kick  是否主动注销(YES:主动/NO:超时)
 */
- (void)manager:(LSLoginManager * _Nonnull)manager onLogout:(BOOL)kick msg:(NSString * _Nullable)msg;

@end

typedef enum {
    NONE = 0,
    LOGINING,
    LOGINED
} LoginStatus;

@interface LSLoginManager : NSObject
/**
 *  登陆状态
 */
@property (nonatomic, assign, readonly) LoginStatus status;

/**
 *  用户名
 */
@property (nonatomic, strong, readonly) NSString* _Nullable email;

/**
 *  密码
 */
@property (nonatomic, strong, readonly) NSString* _Nullable password;
/**
 *  用户信息
 */
@property (nonatomic, strong, readonly) ZBLSLoginItemObject* _Nullable loginItem;

/**
 *  用户系统所在国
 */
@property (nonatomic, copy) NSString* _Nullable fullName;

/**
 *  用户所在地区号
 */
@property (nonatomic, copy) NSString* _Nullable zipCode;

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
 *  @param user          用户
 *  @param password      密码
 *  @param checkcode     验证码
 *
 *  @return 是否进入登陆中状态
 */
- (LoginStatus)login:(NSString * _Nullable)user password:(NSString * _Nullable)password checkcode:(NSString * _Nullable)checkcode;
/**
 *  注销接口
 *
 *  @param kick 是否主动注销(或者被踢)
 *
 */
- (void)logout:(BOOL)kick msg:(NSString * _Nullable)msg;

/**
 *  自动登陆
 *
 *  @return 是否进入登陆中状态
 */
- (BOOL)autoLogin;

@end
