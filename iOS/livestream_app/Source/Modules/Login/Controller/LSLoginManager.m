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
#import "LSGetManBaseInfoRequest.h"

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

- (ILoginHandler *)newLoginHandlerWithType:(NSString *)type
{
    ILoginHandler * handler = nil;
    if ([type isEqualToString:@"Email"]) {
        handler = [[MailLoginHandler alloc]init];
    }
    else if ([type isEqualToString:@"Facebook"])
    {
       handler = [[FacebookLoginHandler alloc]initWithPresentVC:[self.delegates firstObject]];
    }
    else
    {
        
    }
    return handler;
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

- (LoginStatus)login:(ILoginHandler *)loginHandler
{
    self.loginHandler = loginHandler;
    LSRequestManager* manager = [LSRequestManager manager];
    switch (self.status) {
        case NONE:{
            // 未登陆
            
            // 停止所有请求
            [manager stopAllRequest];
            
            // 用户名和密码
            if( loginHandler != nil ) {
                // 进入登陆状态
                @synchronized(self) {
                    _status = LOGINING;
                }
                
                // 登陆回调
                LoginHandler loginFinishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull sessionId){
                    @synchronized(self) {
                        if( success && _status == LOGINING ) {
                            // 登陆成功
                            _status = LOGINED;
                            
                            //_manId = sessionId;
                            _token = sessionId;
//                            _loginItem = item;
                            
                            // 标记可以自动重登陆
                            self.isAutoLogin = YES;
            
                        } else {
                            // 登陆失败
                            _status = NONE;
                            
//                            if( errnum == LOGIN_BY_OTHER_DEVICE ) {
//                                // 账号已经在其他设备登录
//                                // 标记不能自动重
//                                self.isAutoLogin = NO;
//                            }
                        }
                    }
                    
                    __block BOOL blockSuccess = success;
                    __block HTTP_LCC_ERR_TYPE blockErrnum = errnum;
                    __block NSString* blockErrmsg = errmsg;
                    
                    // 回调
                    [self callbackLoginStatus:blockSuccess errnum:blockErrnum errmsg:blockErrmsg];
                };

                GetConfigFinishHandler synConfigFinishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ConfigItemObject *_Nullable item) {
                    if( success ) {
                        NSLog(@"LSLoginManager::login( [Http登录, 同步Http服务器地址], url : %@ )", item.httpSvrUrl);
                       
                        LSConfigManager *config = [LSConfigManager manager];
                        config.item = item;
                       
                        [[LSRequestManager manager] setWebSite:item.httpSvrUrl];
                        
                        NSInteger buildID = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue];
                        //判断是否有强制更新
                        if (item.minAavilableVer > buildID) {
                            // 返回登录失败
                            __block BOOL blockSuccess = NO;
                            __block HTTP_LCC_ERR_TYPE blockErrnum = HTTP_LCC_ERR_FORCED_TO_UPDATE;
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
                            // Handler内部判断是否自动登录
                            [loginHandler login:loginFinishHandler];
                        }

                    } else {
                        // 同步配置失败, 导致登陆失败
                        __block BOOL blockSuccess = success;
                        __block HTTP_LCC_ERR_TYPE blockErrnum = errnum;
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
                NSLog(@"[[LSConfigManager manager] clean];1 start");
                [[LSConfigManager manager] clean];
                [[LSConfigManager manager] synConfig:synConfigFinishHandler];
                NSLog(@"[[LSConfigManager manager] clean];1 end");
                
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
            [[LSRequestManager manager] cleanCookies];
            if( kick ) {
                // 主动注销(被踢)
                // 标记不能自动重
                self.isAutoLogin = NO;
            }
            
            [self.loginHandler logout:nil];
            
            // 清除token
            _token = nil;
  
            // 不能清除, 其他地方在直接用里面的属性
//            _loginItem = nil;
            
            // 标记为已经注销
            _status = NONE;
            
            @synchronized(self) {
                for(NSValue* value in self.delegates) {
                    
                     id<LoginManagerDelegate> delegate = (id<LoginManagerDelegate>)value.nonretainedObjectValue;
                    if( [delegate respondsToSelector:@selector(manager:onLogout:msg:)] ) {
                        [delegate manager:self onLogout:kick msg:msg];
                    }
                }
            }
        }
    }
}


- (BOOL)autoLogin {
    if( self.isAutoLogin ) {
        
        NSDictionary * loginDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginInfo"];
        if (loginDic.allKeys > 0)
        {
            ILoginHandler * handler = [self newLoginHandlerWithType:[loginDic objectForKey:@"Type"]];
            [self login:handler];
        
        }
    
        return YES;
    } else {
        return NO;
    }
}

- (void)loadLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * loginDic = [userDefaults dictionaryForKey:@"LoginInfo"];
    
    if (loginDic.allKeys.count > 0) {
        if ([[loginDic objectForKey:@"Type"] isEqualToString:@"Email"]) {
            self.isAutoLogin = YES;
        }
        else if ([[loginDic objectForKey:@"Type"] isEqualToString:@"Facebook"])
        {
            self.isAutoLogin = YES;
        }
        else
        {
            
        }
    }
    else
    {
      self.isAutoLogin = NO;
    }
}

- (void)loadUserWhere {
    NSString *countryStr = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    NSString *profilePlistPath = [[LiveBundle mainBundle] pathForResource:@"Country" ofType:@"plist"];
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

- (void)callbackLoginStatus:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            HTTP_LCC_ERR_TYPE loginErrnum = errnum;
            NSString * loginErrmsg = errmsg;
            
            LSGetManBaseInfoRequest *request = [[LSGetManBaseInfoRequest alloc] init];
            request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSManBaseInfoItemObject * _Nonnull infoItem) {
                
                NSLog(@"LSLoginManager::login( [Http登录, %@], manId : %@, token : %@ )", success?@"成功":@"失败", infoItem.userId, self.token);
                if (success) {
                    self.loginItem = infoItem;
                }
                
                @synchronized(self) {
                    for(NSValue* value in self.delegates) {
                        id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
                        if( [delegate respondsToSelector:@selector(manager:onLogin:loginItem:errnum:errmsg:)] ) {
                            [delegate manager:self onLogin:success loginItem:self.loginItem errnum:loginErrnum errmsg:loginErrmsg];
                        }
                    }
                }
            };
            [[LSSessionRequestManager manager] sendRequest:request];
        });

    }else
    {
        NSLog(@"登录失败");
        @synchronized(self) {
            for(NSValue* value in self.delegates) {
                id<LoginManagerDelegate> delegate = value.nonretainedObjectValue;
                if( [delegate respondsToSelector:@selector(manager:onLogin:loginItem:errnum:errmsg:)] ) {
                    [delegate manager:self onLogin:success loginItem:self.loginItem errnum:errnum errmsg:errmsg];
                }
            }
        }
    }
}

@end
