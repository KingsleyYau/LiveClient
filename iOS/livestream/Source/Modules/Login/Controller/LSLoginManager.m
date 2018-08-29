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

static LSLoginManager *gManager = nil;

@interface LSLoginManager ()

@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, assign) BOOL isAutoLogin;

@end

@implementation LSLoginManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if (self = [super init]) {
        _status = NONE;

        self.delegates = [NSMutableArray array];
        self.isAutoLogin = NO;

        @synchronized(self) {
            // 加载用户信息
            [self loadLoginParam];

            if (self.manId && self.token) {
                self.isAutoLogin = YES;
            }
        }
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

- (LoginStatus)login:(NSString *_Nonnull)manId userSid:(NSString *_Nonnull)userSid {
    NSLog(@"LSLoginManager::login( [Http登录], manId : %@  userSid : %@ )", manId, userSid);

    LSRequestManager *manager = [LSRequestManager manager];

    switch (self.status) {
        case NONE: {
            // 未登陆

            // 停止所有请求
            [manager stopAllRequest];

            // 用户名和密码
            if (userSid.length > 0) {
                // 进入登陆状态
                @synchronized(self) {
                    _status = LOGINING;
                }

                // 登陆回调
                LoginFinishHandler loginFinishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, LSLoginItemObject *_Nonnull item) {
                    @synchronized(self) {
                        if (success && _status == LOGINING) {
                            // 登陆成功
                            NSLog(@"LSLoginManager::login( [Http登录, 登陆成功], userId : %@, token : %@ )", item.userId, item.token);

                            _status = LOGINED;

                            _manId = manId;
                            _token = userSid;
                            _loginItem = item;

                            // 标记可以自动重登陆
                            self.isAutoLogin = YES;

                            // 保存用户信息
                            [self saveLoginParam];

                        } else {
                            // 登陆失败
                            _status = NONE;

                            //                            if( errnum == LOGIN_BY_OTHER_DEVICE ) {
                            //                                // 账号已经在其他设备登录
                            //                                // 标记不能自动重
                            //                                self.isAutoLogin = NO;
                            //                            }

                            if (errnum == HTTP_LCC_ERR_LOGIN_BY_OTHER_DEVICE) {
                                // 账号已经在其他设备登录
                                // 标记不能自动重
                                self.isAutoLogin = NO;
                            }
                        }
                    }

                    __block BOOL blockSuccess = success;
                    __block HTTP_LCC_ERR_TYPE blockErrnum = errnum;
                    __block NSString *blockErrmsg = errmsg;

                    // 回调
                    [self callbackLoginStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                };

                GetConfigFinishHandler synConfigFinishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, ConfigItemObject *_Nullable item) {
                    if (success) {
                        NSLog(@"LSLoginManager::login( [Http登录, 同步Http服务器地址], url : %@ )", item.httpSvrUrl);

                        LSRequestManager *manager = [LSRequestManager manager];
                        [manager setWebSite:item.httpSvrUrl];

                        NSInteger requestId = [manager login:manId
                                                     userSid:userSid
                                                    deviceid:[manager getDeviceId]
                                                       model:[[UIDevice currentDevice] model]
                                                manufacturer:@"Apple"
                                               finishHandler:loginFinishHandler];

                        if (requestId != [LSRequestManager manager].invalidRequestId) {
                            // TODO:2.开始登陆
                        } else {
                            // 开始登陆失败
                            [self callbackLoginStatus:NO errnum:errnum errmsg:@"Unknow error"];
                        }

                    } else {
                        // 同步配置失败, 导致登陆失败
                        __block BOOL blockSuccess = success;
                        __block HTTP_LCC_ERR_TYPE blockErrnum = errnum;
                        __block NSString *blockErrmsg = errmsg;

                        @synchronized(self) {
                            // 进入未登陆状态
                            _status = NONE;
                        }

                        // 回调
                        [self callbackLoginStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                    }
                };

                // TODO:1.开始同步配置
                // 清空同步配置和服务器
                [[LSConfigManager manager] clean];
                [[LSConfigManager manager] synConfig:synConfigFinishHandler];

            } else {
                // 参数不够
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

- (void)logout:(LogoutType)type {
    return [self logout:type msg:@""];
}

- (void)logout:(LogoutType)type msg:(NSString *)msg {
    NSLog(@"LSLoginManager::logout( [Http注销], type : %d, status : %d )", type, self.status);

    @synchronized(self) {
        if (self.status != NONE) {
            [[LSRequestManager manager] cleanCookies];
            if (type == LogoutTypeActive || type == LogoutTypeKick) {
                // 主动注销(被踢)
                // 标记不能自动重
                self.isAutoLogin = NO;
            }

            // 清除token
            _token = nil;
            _manId = nil;
            // 不能清除, 其他地方在直接用里面的属性
            //            _loginItem = nil;

            // 保存用户信息
            [self saveLoginParam];

            // 标记为已经注销
            _status = NONE;

            for (NSValue *value in self.delegates) {
                id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(manager:onLogout:msg:)]) {
                    [delegate manager:self onLogout:type msg:msg];
                }
            }
        }
    }
}

- (BOOL)autoLogin {
    if (self.isAutoLogin) {
        return [self login:self.manId userSid:self.token];
    } else {
        return NO;
    }
}

- (void)saveLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.manId forKey:@"manId"];
    [userDefaults setObject:self.token forKey:@"token"];
    [userDefaults synchronize];
}

- (void)loadLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _manId = [userDefaults stringForKey:@"manId"];
    _token = [userDefaults stringForKey:@"token"];
}

- (void)loadUserWhere {
    NSString *countryStr = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];

    NSString *profilePlistPath = [[LiveBundle mainBundle] pathForResource:@"Country" ofType:@"plist"];
    NSArray *profileArray = [[NSArray alloc] initWithContentsOfFile:profilePlistPath];
    Country *countryItem = nil;

    for (NSDictionary *dict in profileArray) {
        countryItem = [[Country alloc] initWithDict:dict];
        if ([countryStr isEqualToString:countryItem.shortName]) {
            self.fullName = countryItem.fullName;
            self.zipCode = countryItem.zipCode;
        }
    }
}

- (void)callbackLoginStatus:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    NSLog(@"LSLoginManager::login( [Http登录, %@], manId : %@, token : %@ )", success ? @"成功" : @"失败", self.manId, self.token);

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(manager:onLogin:loginItem:errnum:errmsg:)]) {
                [delegate manager:self onLogin:success loginItem:self.loginItem errnum:errnum errmsg:errmsg];
            }
        }
    }
}

/*************** 模块接口 ***************/
- (LoginStatus)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode {
    NSLog(@"LSLoginManager::login( [Http登录], user : %@  password : %@ )", user, password);

//    LSRequestManager *manager = [LSRequestManager manager];
    _lastInputEmail = user;
    _lastInputPassword = password;
    switch (self.status) {
        case NONE: {

        } break;

        case LOGINING: {
        } break;

        case LOGINED: {
        } break;

        default: {
        } break;
    }

    return self.status;
}

@end
