//
//  LSDomainSessionRequestManager.m
//  dating
//
//  Created by Max on 18/9/29.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//
//  需要处理Session过期的接口调用处理器

#import "LSDomainSessionRequestManager.h"

#import "LSLoginManager.h"
#import "LSDomainSessionRequest.h"
#import "RequestErrorCode.h"
#import "LSGetTokenRequest.h"

// 登录状态类型
typedef enum {
    REQUESTNONE = 0,
    REQUESTING,
    REQUESTED
} DomainRequestStatus;


static LSDomainSessionRequestManager *gManager = nil;
@interface LSDomainSessionRequestManager () <LoginManagerDelegate>
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 域名接口请求状态
@property (nonatomic, assign) DomainRequestStatus requestStatus;
// 域名接口请求中的处理请求
@property (nonatomic, strong) LSDomainSessionRequest* handleRequest;
@property (nonatomic, strong) LSLoginManager *loginManager;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *requestArray;
@end

@implementation LSDomainSessionRequestManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if (self = [super init]) {
        self.array = [NSMutableArray array];
        self.requestArray = [NSMutableArray array];

        self.sessionManager = [LSSessionRequestManager manager];
        self.requestStatus = NONE;
        self.handleRequest = nil;
        
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
        
        
    }
    return self;
}

- (void)dealloc {
    [self.loginManager removeDelegate:self];
}

#pragma mark - 接口回调处理
- (BOOL)sendRequest:(LSDomainSessionRequest *_Nonnull)request {
    BOOL bFlag = NO;
    request.delegate = self;
    request.token = self.loginManager.loginItem.token ? self.loginManager.loginItem.token : @"";

    bFlag = [request sendRequest];
    if (bFlag) {
        @synchronized(self) {
            [self.requestArray addObject:request];
        }
    }

    return bFlag;
}

- (BOOL)request:(LSDomainSessionRequest *_Nonnull)request handleRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *_Nullable)errmsg {
    BOOL bFlag = NO;
    if (!success) {
        // 判断错误码HTTP_LCC_ERR_NO_LOGIN身份失效 （域名接口返回MBCE0003，在LSRequestManager里转换为HTTP_LCC_ERR_NO_LOGIN）
        if (errnum == HTTP_LCC_ERR_NO_LOGIN) {
            // session失效
            // 插入待处理队列
            @synchronized(self) {
                [self.array addObject:request];
            }
            
            // 判断域名接口管理器的状态（1.域名身份请求中状态（有身份才能请求成功的，那些域名接口就等待吧）2.域名身份请求过了状态（现在有失效了）3.没有请求过域名状态（第一次请求域名接口））
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.requestStatus == REQUESTED || self.requestStatus == REQUESTNONE) {
                    NSLog(@"LSDomainSessionRequestManager::handleRespond( [已经登陆状态, 注销], self.array.size : %lu )", (unsigned long)self.array.count);
//                    // 已经登陆状态, 注销
//                    NSLog(@"LSDomainSessionRequestManager::handleRespond( [已经登陆状态, 注销], self.array.size : %lu )", (unsigned long)self.array.count);
                    @synchronized(self) {
                        self.handleRequest = request;
                        [self getAuthToken];
                        self.requestStatus = REQUESTING;
                    }
                    
                } else if (self.requestStatus == REQUESTING) {
                    // 正在域名请求中, 等待
                    NSLog(@"LSDomainSessionRequestManager::handleRespond( [正在域名请求中状态, 等待], self.array.size : %lu )", (unsigned long)self.array.count);
                }
            });

            bFlag = YES;
        }

    }

    return bFlag;
}

- (void)requestFinish:(LSDomainSessionRequest *_Nonnull)request {
    @synchronized(self) {
        [self.requestArray removeObject:request];
    }
}

#pragma mark - 域名接口请求身份请求
- (void)getAuthToken {
    LSGetTokenRequest* request = [[LSGetTokenRequest alloc] init];
    request.siteId = HTTP_OTHER_SITE_LIVE;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull memberId, NSString * _Nonnull sid) {
        NSLog(@"LSDomainSessionRequestManager::getAuthToken( [域名接口请求token], success : %d errnum:%d errmsg:%@)", success,  errnum, errmsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 返回错误就设置域名接口请求状态为none
            // NSLog(@"LSUserUnreadCountManager::setPushConfig()");
            if (success) {
                [self mobileDomainTokenLoginAuth:sid memberId:memberId];
            } else {
                // 失败（错误码除10002外，都认为是源接口调用失败）
                // 当登录失败，设置域名请求状态为NONE，并要调用源接口处理
                [self handleRequestFail:success errnum:errnum errmsg:errmsg];
            }
        });
    };
        [self.sessionManager sendRequest:request];
}

- (void)mobileDomainTokenLoginAuth:(NSString* _Nonnull)token memberId:(NSString*  _Nonnull)memberId {
    LSRequestManager* requestManager = [LSRequestManager manager];
    [[LSRequestManager manager] loginWithTokenAuth:token memberId:memberId deviceid:[requestManager getDeviceId] versionCode:requestManager.versionCode model:[[UIDevice currentDevice] model] manufacturer:@"Apple" finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        @synchronized(self) {
            NSLog(@"LSDomainSessionRequestManager::MobileDomainTokenLoginAuth( [域名接口认证token登录], success : %d errnum:%d errmsg:%@)", success,  errnum, errmsg);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 返回错误就设置域名接口请求状态为none
                // NSLog(@"LSUserUnreadCountManager::setPushConfig()");
                if (success) {
                    self.requestStatus = REQUESTED;
                    // 重新发送请求
                    for (LSDomainSessionRequest *request in self.array) {
                        if (request) {
                            [request sendRequest];
                        }
                    }
                    // 清空所有请求
                    [self.array removeAllObjects];
                } else {
                    // 失败（错误码除10002外，都认为是源接口调用失败）
                    // 当登录失败，设置域名请求状态为NONE，并要调用源接口处理
                    [self handleRequestFail:success errnum:errnum errmsg:errmsg];
                }
            });
        }
    }];
}

// 当登录失败，设置域名请求状态为NONE，并要调用源接口处理
- (void)handleRequestFail:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nonnull)errmsg {
    self.requestStatus = NONE;
    NSLog(@"LSDomainSessionRequestManager::handleRequestFail( [域名接口请求失败回调], success : %d errnum:%d errmsg:%@)", success,  errnum, errmsg);
    if (self.handleRequest) {
        [self.handleRequest callRespond:success errnum:errnum errmsg:errmsg];
        [self.array removeObject:self.handleRequest];
        self.handleRequest = nil;
    }
}

#pragma mark - 登陆回调处理
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
            // 在域名请求中状态才对登录回调处理
            if (self.requestStatus == REQUESTING) {
                if (success) {
                    // 登录成功后在去获取认证token（因为获取认证token为10002身份失效才去做登录流程）
                    [self getAuthToken];
                } else {
                    // 当登录失败，设置域名请求状态为NONE，并要调用源接口处理
                    [self handleRequestFail:success errnum:errnum errmsg:errmsg];
                }
            }
        }
    });
}

- (void)manager:(LSLoginManager * _Nonnull)manager onLogout:(LogoutType)type msg:(NSString * _Nullable)msg {
}

@end
