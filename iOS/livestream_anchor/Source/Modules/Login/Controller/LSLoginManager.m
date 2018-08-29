//
//  LSLoginManager.m
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSLoginManager.h"
#import "LSAnchorRequestManager.h"
#import "LSConfigManager.h"
#import "LiveBundle.h"

static LSLoginManager* gManager = nil;

@interface LSLoginManager ()

@property (nonatomic, strong) NSMutableArray* delegates;
@property (nonatomic, assign) BOOL isAutoLogin;

@end

@implementation LSLoginManager
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
        for(NSValue* value in self.delegates) {
            id<LoginManagerDelegate> item = (id<LoginManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}

- (LoginStatus)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode  {
    NSLog(@"LSLoginManager::login( [Http登录], user : %@  password : %@ )", user, password);
    
    LSAnchorRequestManager* manager = [LSAnchorRequestManager manager];

    switch (self.status) {
        case NONE:{
            // 未登陆
            
            // 停止所有请求
            [manager stopAllRequest];
            
            // 用户名和密码
            if(user && user.length > 0 && password && password.length > 0 ) {
                // 进入登陆状态
                @synchronized(self) {
                    _status = LOGINING;
                }
                
                // 登陆回调
                ZBLoginFinishHandler loginFinishHandler = ^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBLSLoginItemObject * _Nonnull item) {
                    @synchronized(self) {
                        if( success && _status == LOGINING ) {
                            // 登陆成功
                            NSLog(@"LSLoginManager::login( [Http登录, 登陆成功], userId : %@, token : %@ )", item.userId, item.token);
                            
                            _status = LOGINED;
                            
                            _email = user;
                            _password = password;
                            _loginItem = item;
                            
                            // 标记可以自动重登陆
                            self.isAutoLogin = YES;
                            
                            // 保存用户信息
                            [self saveLoginParam];
                            
                        } else {
                            // 登陆失败
                            _status = NONE;

                            if( errnum == ZBHTTP_LCC_ERR_LOGIN_BY_OTHER_DEVICE ) {
                                // 账号已经在其他设备登录
                                // 标记不能自动重
                                self.isAutoLogin = NO;
                            }
                        }
                    }
                    
                    __block BOOL blockSuccess = success;
                    __block ZBHTTP_LCC_ERR_TYPE blockErrnum = errnum;
                    __block NSString* blockErrmsg = errmsg;
                    
                    // 回调
                    [self callbackLoginStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                };
                
                ZBGetConfigFinishHandler synConfigFinishHandler = ^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBConfigItemObject *_Nullable item) {
                    if( success ) {
                        NSLog(@"LSLoginManager::login( [Http登录, 同步Http服务器地址], url : %@ )", item.httpSvrUrl);

                        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
                        [manager setWebSite:item.httpSvrUrl];
                        
                        [[LiveModule module] setConfigUrl:item.httpSvrUrl];
                        
                        NSInteger buildID = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue];
                        //判断是否有强制更新
                        if (item.minAavilableVer > buildID) {
                            // 返回登录失败
                            __block BOOL blockSuccess = NO;
                            __block ZBHTTP_LCC_ERR_TYPE blockErrnum = ZBHTTP_LCC_ERR_FORCED_TO_UPDATE;
                            __block NSString* blockErrmsg = @"Forced to update";
                            @synchronized(self) {
                                // 进入未登陆状态
                                _status = NONE;
                            }
                            // 回调
                            [self callbackLoginStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                        }
                        else
                        {
                            NSInteger requestId = [manager anchorLogin:user password:password code:checkcode deviceid:[manager getDeviceId] model:[[UIDevice currentDevice] model] manufacturer:@"Apple" finishHandler:loginFinishHandler];
                            
                            if( requestId != [LSAnchorRequestManager manager].invalidRequestId ) {
                                // TODO:2.开始登陆
                            } else {
                                // 开始登陆失败
                                [self callbackLoginStatus:NO errnum:errnum errmsg:@"Unknow error"];
                            }
                        }
                    } else {
                        // 同步配置失败, 导致登陆失败
                        __block BOOL blockSuccess = success;
                        __block ZBHTTP_LCC_ERR_TYPE blockErrnum = errnum;
                        __block NSString* blockErrmsg = errmsg;
                        
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

- (void)logout:(BOOL)kick msg:(NSString *)msg {
    @synchronized(self) {
        NSLog(@"LSLoginManager::logout( [Http注销], kick : %@, msg : %@, status : %d )", kick ? @"YES":@"NO", msg, self.status);
        
        if (self.status != NONE) {
            [[LSAnchorRequestManager manager] cleanCookies];
            if( kick ) {
                // 主动注销(被踢)
                // 标记不能自动重
                self.isAutoLogin = NO;
            }
            // 清除token
            _email = nil;
            _password = nil;
            
            [self removePassword];
            
            // 标记为已经注销
            _status = NONE;
            
            for(NSValue* value in self.delegates) {
                id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
                if( [delegate respondsToSelector:@selector(manager:onLogout:msg:)] ) {
                    [delegate manager:self onLogout:kick msg:msg];
                }
            }
        }
    }

}

- (BOOL)autoLogin {
    if (self.email && self.email.length > 0 && self.password && self.password.length > 0) {
        return [self login:self.email password:self.password checkcode:nil];
    } else {
        return NO;
    }
}

/**
 *  保存用户信息(文件)
 *
 */
- (void)saveLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:self.email forKey:@"email"];
    [userDefaults setObject:self.password forKey:@"password"];
    
    [userDefaults synchronize];
}

// 清空密码
- (void)removePassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"" forKey:@"password"];
    [userDefaults synchronize];
}

/**
 *  加载用户信息(文件)
 *
 */
- (void)loadLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _email = [userDefaults stringForKey:@"email"];
    _password = [userDefaults stringForKey:@"password"];
}

//- (void)loadUserWhere {
//    NSString *countryStr = [[NSLocale currentLocale]objectForKey:NSLocaleCountryCode];
//    
//    NSString *profilePlistPath = [[LiveBundle mainBundle] pathForResource:@"Country" ofType:@"plist"];
//    NSArray *profileArray = [[NSArray alloc] initWithContentsOfFile:profilePlistPath];
//    Country  *countryItem = nil;
//    
//    for (NSDictionary *dict in profileArray) {
//        countryItem = [[Country alloc] initWithDict:dict];
//        if ([countryStr isEqualToString:countryItem.shortName]) {
//            self.fullName = countryItem.fullName;
//            self.zipCode = countryItem.zipCode;
//        }
//    }
//}

- (void)callbackLoginStatus:(BOOL)success errnum:(ZBHTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    NSLog(@"LSLoginManager::login( [Http登录, %@], user : %@ )", success ? @"成功" : @"失败", self.email);
    
    @synchronized(self) {
        for(NSValue* value in self.delegates) {
            id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(manager:onLogin:loginItem:errnum:errmsg:)] ) {
                [delegate manager:self onLogin:success loginItem:self.loginItem errnum:errnum errmsg:errmsg];
            }
        }
    }
}

@end
