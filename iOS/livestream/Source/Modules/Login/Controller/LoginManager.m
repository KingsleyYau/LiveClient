//
//  LoginManager.m
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoginManager.h"
#import "RequestManager.h"
#import "Country.h"

static LoginManager* gManager = nil;

@interface LoginManager ()

@property (nonatomic, strong) NSMutableArray* delegates;
@property (nonatomic, assign) BOOL isAutoLogin;

@end

@implementation LoginManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        _status = NONE;

        self.delegates = [NSMutableArray array];
        self.isAutoLogin = NO;
        
        @synchronized(self) {
            // 加载用户信息
            [self loadLoginParam];
            
            [self loadUserWhere];
            
            if( self.email && self.email.length > 0 && self.password && self.password.length > 0 && self.areano.length > 0 ) {
                self.isAutoLogin = YES;
            }
        }
        
    }
    return self;
}

- (void)addDelegate:(id<LoginManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<LoginManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<LoginManagerDelegate> item = (id<LoginManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}

- (LoginStatus)login:(NSString *)user password:(NSString *)password areano:(NSString *)areano {
    RequestManager* manager = [RequestManager manager];
    _lastInputEmail = user;
    _lastInputPassword = password;
    
    switch (self.status) {
        case NONE:{
            // 未登陆
            
            // 停止所有请求
            [manager stopAllRequest];
            
            // 用户名和密码
            if( user.length > 0 && password.length > 0 && areano.length > 0 ) {
                // 进入登陆状态
                @synchronized(self) {
                    _status = LOGINING;
                }
                
                // 登陆回调
                LoginFinishHandler loginFinishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, LoginItemObject * _Nonnull item) {
                    @synchronized(self) {
                        if( success ) {
                            // 登陆成功
                            _status = LOGINED;
                            
                            _email = user;
                            _password = password;
                            _areano = areano;
                            _loginItem = item;
                            
                            // 标记可以自动重登陆
                            self.isAutoLogin = YES;
                            
                            // 保存用户信息
                            [self saveLoginParam];
                            
                        } else {
                            // 登陆失败
                            _status = NONE;
                            
                            if( errnum == LOGIN_BY_OTHER_DEVICE ) {
                                // 账号已经在其他设备登录
                                // 标记不能自动重
                                self.isAutoLogin = NO;
                            }
                        }
                        
                    }
                    
                    __block BOOL blockSuccess = success;
                    __block NSInteger blockErrnum = errnum;
                    __block NSString* blockErrmsg = errmsg;
                    
                    // 回调
                    [self callbackLoginStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                    
                };
                
                [manager login:LoginType_Phone
                       phoneno:user
                         areno:areano
                      password:password
                      deviceid:[manager getDeviceId]
                         model:[[UIDevice currentDevice] model]
                  manufacturer:@"Apple"
                     autoLogin:self.isAutoLogin
                 finishHandler:loginFinishHandler];
                
            } else {
                // 参数不够
            }
        }break;
        case LOGINING:{
            // 登陆中
            
        }break;
        case LOGINED:{
            // 已经登陆
            
        }break;
        default:
            break;
    }
    
    return self.status;
}

- (void)logout:(BOOL)kick {
    if( kick ) {
        // 主动注销(被踢)
        [[RequestManager manager] cleanCookies];

        // 清除用户帐号密码
        @synchronized(self) {
            // 标记不能自动重
            self.isAutoLogin = NO;
            
            _password = nil;
            _loginItem = nil;
            
            // 保存用户信息
            [self saveLoginParam];
        }
    }

    // 标记为已经注销
    @synchronized(self) {
        _status = NONE;
    }
    
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(manager:onLogout:)] ) {
                [delegate manager:self onLogout:kick];
            }

        }
    }

}

- (BOOL)autoLogin {
    if( self.isAutoLogin ) {
        return [self login:self.email password:self.password areano:self.areano];
        
    } else {
        return NO;
        
    }
}

- (BOOL)everLoginSuccess {
    BOOL bFlag = NO;
    
    if( self.email.length > 0 && self.password.length > 0 && self.areano.length > 0 ) {
        bFlag = YES;
    }
    
    return bFlag;
}

- (void)saveLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:self.email forKey:@"email"];
    [userDefaults setObject:self.password forKey:@"password"];
    [userDefaults setObject:self.areano forKey:@"areano"];
    
    [userDefaults synchronize];
}

- (void)loadLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _email = [userDefaults stringForKey:@"email"];
    _password = [userDefaults stringForKey:@"password"];
    _areano = [userDefaults stringForKey:@"areano"];
}

- (void)loadUserWhere {
    
    NSString *countryStr = [[NSLocale currentLocale]objectForKey:NSLocaleCountryCode];
    
    NSString *profilePlistPath = [[NSBundle mainBundle] pathForResource:@"Country" ofType:@"plist"];
    NSArray *profileArray = [[NSArray alloc] initWithContentsOfFile:profilePlistPath];
    Country  *countryItem = nil;
    
    for (NSDictionary *dict in profileArray) {
        countryItem = [[Country alloc] initWithDict:dict];
        if ([countryStr isEqualToString:countryItem.shortName]) {
            self.fullName = countryItem.fullName;
            self.zipCode = countryItem.zipCode;
        }
    }
}

- (void)callbackLoginStatus:(BOOL)success errnum:(NSInteger)errnum errmsg:(NSString *)errmsg {
    // 主线程回调
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(manager:onLogin:loginItem:errnum:errmsg:)] ) {
                [delegate manager:self onLogin:success loginItem:self.loginItem errnum:errnum errmsg:errmsg];
            }
        }
    }

}

@end
