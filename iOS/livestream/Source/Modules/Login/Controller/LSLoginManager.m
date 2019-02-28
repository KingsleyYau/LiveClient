//
//  LSLoginManager.m
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSLoginManager.h"
#import "LSRequestManager.h"
#import "LSConfigManager.h"
#import "LiveBundle.h"
#import "Country.h"
#import "LSPrivateMessageManager.h"
#import "LSAddTokenRequest.h"
#import "LSDestroyTokenRequest.h"
#import "LSImManager.h"
#import "LSLiveChatManagerOC.h"
#import "LSFileCacheManager.h"
#import "LSPhoneInfoRequest.h"
#define PHONE_INFO_FILE @"LSPhoneInfo.plist"

static LSLoginManager *loginManager = nil;
@interface LSLoginManager ()

@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, assign) BOOL isAutoLogin;
@property (nonatomic, copy) AppLoginFinishHandler loginBlock;
/**
 *  私密消息管理器
 */
@property (nonatomic, strong) LSPrivateMessageManager *messageManager;

@end

@implementation LSLoginManager
#pragma mark - 获取实例
+ (instancetype)manager {
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
          if (!loginManager) {
               loginManager = [[[self class] alloc] init];
          }
     });
     return loginManager;
}

- (id)init {
    if (self = [super init]) {
        _status = NONE;

        self.delegates = [NSMutableArray array];
        self.isAutoLogin = NO;
    }
    return self;
}

- (void)addDelegate:(id<LoginManagerDelegate>)delegate {
    @synchronized(self) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<LoginManagerDelegate>)delegate {
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LoginManagerDelegate> item = (id<LoginManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}

#pragma mark - 登录服务接口
- (void)getCheckCodeIsMust:(BOOL)isMust handler:(AppGetCheckCodeFinishHandler)handler {
    NSLog(@"LSLoginManager::getCheckCode( [获取验证码] )");
     
     [[LSRequestManager manager] getValidateCode:isMust?LSVALIDATECODETYPE_FINDPW:LSVALIDATECODETYPE_LOGIN
                                  finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, const char *_Nullable data, int len) {
                                      NSLog(@"LSLoginManager::getCheckCode( [获取验证码, %@], errnum : %d, errmsg : %@ )", BOOL2YES(success), errnum, errmsg);

                                      UIImage *image = nil;
                                      if (success) {
                                          if (data && len > 0) {
                                              image = [UIImage imageWithData:[NSData dataWithBytes:data length:len]];
                                          }
                                      }

                                      if (handler) {
                                          ErrorType errType = success ? ErrorType_Success : ErrorType_UnknowError;
                                          handler(success, errType, errmsg, image);
                                      }

                                  }];
}

- (BOOL)loginCheck:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode handler:(AppLoginFinishHandler)handler {
    NSLog(@"LSLoginManager::loginCheck( [Http登录检查], user : %@, password : %@, checkcode : %@ )", user, password, checkcode);

    if (handler) {
        handler(NO, ErrorType_UnknowError, @"", nil);
    }

    return YES;
}

- (LoginStatus)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode userId:(NSString *)userId token:(NSString *)token handler:(AppLoginFinishHandler)handler {
    NSLog(@"LSLoginManager::login( [Http登录], user : %@, password : %@, checkcode : %@, userId : %@, token : %@ )", user, password, checkcode, userId, token);

    // 保存用户信息
    _userId = user;
    _password = password;

    self.loginBlock = handler;
    return [self login:user password:password checkcode:checkcode userId:userId token:token];
}

- (void)logout:(LogoutType)type {
    return [self logout:type msg:@""];
}

#pragma mark - 模块内登录注销接口
- (LoginStatus)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode userId:(NSString *)userId token:(NSString *)token {
    NSLog(@"LSLoginManager::login( [Http登录(内部)], user : %@, password : %@, checkcode : %@, userId : %@, token : %@ )", user, password, checkcode, userId, token);

     _userId = user;
     _password = password;
     
    LSRequestManager *manager = [LSRequestManager manager];
    switch (self.status) {
        case NONE: {
            // 未登陆

            // 停止所有请求
            [manager stopAllRequest];

            // 用户名和密码
            if (user.length > 0 && password.length > 0) {
                // 进入登陆状态
                @synchronized(self) {
                    _status = LOGINING;
                }

                // 登陆回调
                LoginFinishHandler loginFinishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSLoginItemObject *item) {
                    NSLog(@"LSLoginManager::login( [Http登录(内部), Sid登录, %@] )", BOOL2SUCCESS(success));

                    @synchronized(self) {
                        if (success && _status == LOGINING) {
                            // 登陆成功
                            _manId = item.userId;
                            _token = item.token;
                            _loginItem = item;

                            // 标记可以自动重登陆
                            self.isAutoLogin = YES;

                        } else {
                            if (errnum == HTTP_LCC_ERR_LOGIN_BY_OTHER_DEVICE) {
                                // 账号已经在其他设备登录
                                // 标记不能自动重
                                self.isAutoLogin = NO;
                            }
                        }
                    }

                    // 回调
                    [self loginResultHandler:success errnum:errnum errmsg:errmsg];
                };

                // Http登录(Token)回调
                LoginWithTokenFinishHandler loginWithTokenFinishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *memberId, NSString *sid) {
                    NSLog(@"LSLoginManager::login( [Http登录(内部), Token登录, %@], memberId : %@, sid : %@ )", BOOL2SUCCESS(success), memberId, sid);
                    if (success) {
                        // TODO:3.Token登录成功, 开始SID登录
                        LSRequestManager *manager = [LSRequestManager manager];
                        NSInteger requestId = [manager login:memberId
                                                     userSid:sid
                                                    deviceid:[manager getDeviceId]
                                                       model:[[UIDevice currentDevice] model]
                                                manufacturer:@"Apple"
                                               finishHandler:loginFinishHandler];

                        if (requestId != [LSRequestManager manager].invalidRequestId) {
                        } else {
                            // 开始登陆失败
                            [self loginResultHandler:NO errnum:errnum errmsg:@"Unknow error"];
                        }
                    } else {
                        // 回调
                        [self loginResultHandler:success errnum:errnum errmsg:errmsg];
                    }
                };

                // Http登录(账号密码)回调
                LoginWithPasswordFinishHandler loginWithPasswordFinishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *memberId, NSString *sid) {
                    NSLog(@"LSLoginManager::login( [Http登录(内部), 账号密码登录, %@], memberId : %@, sid : %@ )", BOOL2SUCCESS(success), memberId, sid);
                    if (success) {
                        // TODO:3.账号密码登录成功, 开始SID登录
                        LSRequestManager *manager = [LSRequestManager manager];
                        NSInteger requestId = [manager login:memberId
                                                     userSid:sid
                                                    deviceid:[manager getDeviceId]
                                                       model:[[UIDevice currentDevice] model]
                                                manufacturer:@"Apple"
                                               finishHandler:loginFinishHandler];

                        if (requestId != [LSRequestManager manager].invalidRequestId) {
                        } else {
                            // 开始登陆失败
                            [self loginResultHandler:NO errnum:errnum errmsg:@"Unknow error"];
                        }
                    } else {
                        // 回调
                        [self loginResultHandler:success errnum:errnum errmsg:errmsg];
                    }
                };

                GetConfigFinishHandler synConfigFinishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, ConfigItemObject *_Nullable item) {
                    NSLog(@"LSLoginManager::login( [Http登录(内部), 同步配置, %@], webSiteUrl : %@ )", BOOL2SUCCESS(success), item.httpSvrUrl);
                    if (success) {
                         _configItem = item;
                        // 设置服务器域名
                        LSRequestManager *manager = [LSRequestManager manager];
                        [manager setWebSite:item.httpSvrUrl];
                        // 设置通用服务器域名
                        [manager setDomainWebSite:item.httpSvrMobileUrl];
//                        [LSRequestManager setProxy:@"http://172.25.32.80:8888"];

                        if (userId.length > 0 && token.length > 0) {
                            NSLog(@"LSLoginManager::login( [Http登录(内部), 开始Token登录], user : %@, password : %@, checkcode : %@, userId : %@, token : %@ )", user, password, checkcode, userId, token);
                            // TODO:2.开始Token登录
                            NSInteger requestId = [manager loginWithToken:userId otherToken:token finishHandler:loginWithTokenFinishHandler];
                            if (requestId != [LSRequestManager manager].invalidRequestId) {

                            } else {
                                [self loginResultHandler:NO errnum:errnum errmsg:@"Get Config Error"];
                            }
                        } else {
                            NSLog(@"LSLoginManager::login( [Http登录(内部), 开始账号密码登录], user : %@, password : %@, checkcode : %@, userId : %@, token : %@ )", user, password, checkcode, userId, token);
                            // TODO:2.开始账号密码登录
                            NSInteger requestId = [manager loginWithPassword:user password:password authCode:checkcode finishHandler:loginWithPasswordFinishHandler];
                            if (requestId != [LSRequestManager manager].invalidRequestId) {

                            } else {
                                [self loginResultHandler:NO errnum:errnum errmsg:@"Get Config Error"];
                            }
                        }

                    } else {
                        // 同步配置失败
                        [self loginResultHandler:success errnum:errnum errmsg:errmsg];
                    }
                };

                // TODO:1.开始同步配置
                // 清空同步配置和服务器
                [[LSConfigManager manager] clean];
                [[LSConfigManager manager] synConfig:synConfigFinishHandler];

            } else {
                // 参数不够
                NSLog(@"LSLoginManager::login( [Http登录(内部), 参数不够, %@] )", BOOL2SUCCESS(NO));
                 [self loginResultHandler:NO errnum:HTTP_LCC_ERR_FAIL errmsg:NSLocalizedString(@"LOCAL_ERROR_CODE_TIMEOUT", nil)];
                 
            }
        } break;
        case LOGINING: {
            // 登陆中

        } break;
        case LOGINED: {
            // 已经登陆
        } break;
        default:
            break;
    }

    return self.status;
}

- (void)loginResultHandler:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    NSLog(@"LSLoginManager::loginResultHandler( [Http登录, %@], manId : %@, token : %@, errnum : %d, errmsg : %@ )", BOOL2SUCCESS(success), self.manId, self.token, errnum, errmsg);
     dispatch_async(dispatch_get_main_queue(), ^{
          
               if (success) {
                    [self summitDeviceToken];
                    
                    // 收集手机硬件信息
                    [self updatePhoneInfo];
                    
                    _status = LOGINED;
                    
                    if (self.loginBlock) {
                         self.loginBlock(success, ErrorType_Success, errmsg, self.manId);
                    }
                    
               } else {
                    _status = NONE;
                    
                    if (self.loginBlock) {
                         ErrorType errType = success ? ErrorType_Success : ErrorType_UnknowError;
                         if (!success) {
                              if (errnum == HTTP_LCC_ERR_CONNECTFAIL) {
                                   // TODO:网络错误
                                   errType = ErrorType_NetworkError;
                              } else if (errnum == HTTP_LCC_ERR_PLOGIN_ENTER_VERIFICATION || errnum == HTTP_LCC_ERR_PLOGIN_VERIFICATION_WRONG) {
                                   // TODO:验证码错误
                                   errType = ErrorType_CheckCodeError;
                              } else if (errnum == HTTP_LCC_ERR_PLOGIN_PASSWORD_INCORRECT) {
                                   // TODO:密码错误
                                   errType = ErrorType_PasswordError;
                              } else {
                                   // TODO:其他错误
                                   errType = ErrorType_UnknowError;
                              }
                         }
                         self.loginBlock(success, errType, errmsg, self.manId);
                    }
               }
          
          for (NSValue *value in self.delegates) {
               id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
               if ([delegate respondsToSelector:@selector(manager:onLogin:loginItem:errnum:errmsg:)]) {
                    [delegate manager:self onLogin:success loginItem:self.loginItem errnum:errnum errmsg:errmsg];
               }
          }
     });
}

- (void)logout:(LogoutType)type msg:(NSString *)msg {
    NSLog(@"LSLoginManager::logout( [Http注销], type : %d, status : %d )", type, self.status);

    // TODO:注销
    @synchronized(self) {
        if (type == LogoutTypeActive || type == LogoutTypeKick) {
            // 主动注销(被踢)
            // 标记不能自动重
            self.isAutoLogin = NO;
            _password = nil;

            [self closePushToken];
        }
       
        // 清除token
        _token = nil;
        _manId = nil;

        // 标记为已经注销
        _status = NONE;
         
         self.messageManager = nil;

        for (NSValue *value in self.delegates) {
            id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(manager:onLogout:msg:)]) {
                [delegate manager:self onLogout:type msg:msg];
            }
        }
    }
}


- (BOOL)autoLogin {
    // TODO:自动登录
    NSLog(@"LSLoginManager::autoLogin( [Http自动登录] )");
    if (self.isAutoLogin) {
        return [self login:self.userId password:self.password checkcode:nil userId:nil token:nil];
    } else {
        return NO;
    }
}

- (LoginStatus)loginWithSession:(NSString *)sessionId {
    // TODO:测试登录

    NSLog(@"LSLoginManager::loginWithSession( [Http登录(测试), Sid登录], sessionId : %@ )", sessionId);
    LSRequestManager *manager = [LSRequestManager manager];
    switch (self.status) {
        case NONE: {
            // 未登陆

            // 停止所有请求
            [manager stopAllRequest];

            // 用户名和密码
            if (sessionId.length > 0) {
                // 进入登陆状态
                @synchronized(self) {
                    _status = LOGINING;
                }

                // 登陆回调
                LoginFinishHandler loginFinishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSLoginItemObject *item) {
                    NSLog(@"LSLoginManager::loginWithSession( [Http登录(测试), Sid登录, %@] )", BOOL2SUCCESS(success));

                    @synchronized(self) {
                        if (success && _status == LOGINING) {
                            // 登陆成功
                            _manId = item.userId;
                            _token = item.token;
                            _loginItem = item;

                            // 标记可以自动重登陆
                            self.isAutoLogin = YES;

                        } else {
                            if (errnum == HTTP_LCC_ERR_LOGIN_BY_OTHER_DEVICE) {
                                // 账号已经在其他设备登录
                                // 标记不能自动重
                                self.isAutoLogin = NO;
                            }
                        }
                    }

                    // 回调
                    [self loginResultHandler:success errnum:errnum errmsg:errmsg];
                };

                GetConfigFinishHandler synConfigFinishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, ConfigItemObject *_Nullable item) {
                    NSLog(@"LSLoginManager::login( [Http登录(内部), 同步配置, %@], webSiteUrl : %@ )", BOOL2SUCCESS(success), item.httpSvrUrl);
                    if (success) {
                         _configItem = item;
                        // 设置服务器域名
                        LSRequestManager *manager = [LSRequestManager manager];
                        [manager setWebSite:item.httpSvrUrl];


                        // TODO:2.开始SID登录
                        NSInteger requestId = [manager login:@""
                                                     userSid:sessionId
                                                    deviceid:[manager getDeviceId]
                                                       model:[[UIDevice currentDevice] model]
                                                manufacturer:@"Apple"
                                               finishHandler:loginFinishHandler];

                        if (requestId != [LSRequestManager manager].invalidRequestId) {
                        } else {
                            // 开始登陆失败
                            [self loginResultHandler:NO errnum:HTTP_LCC_ERR_FAIL errmsg:@"Unknow error"];
                        }

                    } else {
                        // 同步配置失败
                        [self loginResultHandler:success errnum:errnum errmsg:errmsg];
                    }
                };

                // TODO:1.开始同步配置
                // 清空同步配置和服务器
                [[LSConfigManager manager] clean];
                [[LSConfigManager manager] synConfig:synConfigFinishHandler];
            }
        }
        case LOGINING: {
            // 登陆中

        } break;
        case LOGINED: {
            // 已经登陆
        } break;
        default:
            break;
    }

    return self.status;
}

// 提交设备的token
- (void)summitDeviceToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenId = [userDefaults objectForKey:@"deviceTokenString"];
    
    NSLog(@"LSLoginManager::summitAppTokenDeviced( tokenId : %@ )", tokenId);
    if (tokenId != nil) {
         //提交设备tokenId的请求
        LSAddTokenRequest * request = [[LSAddTokenRequest alloc]init];
        request.appId = [[NSBundle mainBundle] bundleIdentifier];
        request.tokenId = tokenId;
        [[LSDomainSessionRequestManager manager] sendRequest:request];
    }
}

// 清除设备token
- (void)closePushToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenId = [userDefaults objectForKey:@"deviceTokenString"];
    NSLog(@"LSLoginManager::unbindAppToken( tokenId : %@ )", tokenId);
    if (tokenId != nil) {
        LSDestroyTokenRequest * request = [[LSDestroyTokenRequest alloc]init];
         [[LSDomainSessionRequestManager manager] sendRequest:request];
    }
}

// 更新手机的信息
- (void)updatePhoneInfo {
     //获取完整路径
     NSString *path = [[LSFileCacheManager manager] phoneInfoWithFileName:PHONE_INFO_FILE];
     if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
          NSMutableDictionary *dictplist = [[NSMutableDictionary alloc] init];
          //写入文件
          [dictplist writeToFile:path atomically:YES];
     }
     NSMutableDictionary *applist = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] mutableCopy];
     
     NSArray *array = [applist allValues];
    bool isPhoneInfo = NO;
    int index = 0;
     //新安装
     if (array.count == 0) {
         isPhoneInfo = YES;
         index = 0;
     } else { //新用户
          if (![array containsObject:self.loginItem.userId]) {
              isPhoneInfo = YES;
              index = 1;
          }
     }
    
    if (isPhoneInfo) {
        LSPhoneInfoRequest * request = [[LSPhoneInfoRequest alloc]init];
        request.phoneInfo = [[LSPhoneInfoObject alloc] initWithAction:index];
         NSLog(@"%@: 请求phoneInfo(" , index == 0 ? @"新安装" : @"新用户");
         request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
              dispatch_async(dispatch_get_main_queue(), ^{
                   NSLog(@"phoneInfo( success : %d )" ,success);
                   if (success) {
                        [self savePhoneInfoMsg:self.loginItem.userId];
                   }
              });
         };
        [[LSDomainSessionRequestManager manager] sendRequest:request];
    }

    
}

// 保存手机信息信息
- (void)savePhoneInfoMsg:(NSString *)manId
{
     //获取完整路径
     NSString *path = [[LSFileCacheManager manager] phoneInfoWithFileName:PHONE_INFO_FILE];
     NSMutableDictionary *applist = [[[NSMutableDictionary alloc]initWithContentsOfFile:path]mutableCopy];
     [applist setObject:manId forKey:@"manId"];
     [applist writeToFile:path atomically:YES];
}
@end
