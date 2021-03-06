//
//  LSSessionRequestManager.m
//  dating
//
//  Created by Max on 16/3/11.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//
//  需要处理Session过期的接口调用处理器

#import "LSSessionRequestManager.h"

#import "LSLoginManager.h"
#import "LSSessionRequest.h"
#import "RequestErrorCode.h"

static LSSessionRequestManager *sessionRequestManager = nil;
@interface LSSessionRequestManager () <LoginManagerDelegate> {
    NSString *_sessionErrorMsg;
}

@property (nonatomic, strong) LSLoginManager *loginManager;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *requestArray;
@end

@implementation LSSessionRequestManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if (sessionRequestManager == nil) {
        sessionRequestManager = [[[self class] alloc] init];
    }
    return sessionRequestManager;
}

- (id)init {
    if (self = [super init]) {
        self.array = [NSMutableArray array];
        self.requestArray = [NSMutableArray array];

        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [self.loginManager removeDelegate:self];
}

#pragma mark - 接口回调处理
- (BOOL)sendRequest:(LSSessionRequest *)request {
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

- (BOOL)request:(LSSessionRequest *)request handleRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    BOOL bFlag = NO;
    if (!success) {
        // 判断错误码
        if (errnum == HTTP_LCC_ERR_TOKEN_EXPIRE ||
            errnum == HTTP_LCC_ERR_NO_LOGIN) {
            // session超时
            _sessionErrorMsg = errmsg;

            // 插入待处理队列
            @synchronized(self) {
                [self.array addObject:request];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.loginManager.status == LOGINED) {
                    // 已经登陆状态, 注销
                    NSLog(@"LSSessionRequestManager::handleRespond( [已经登陆状态, 注销], self.array.size : %lu )", (unsigned long)self.array.count);
                    [self.loginManager logout:LogoutTypeRelogin msg:@""];
                    [self.loginManager autoLogin];
                } else if (self.loginManager.status == LOGINING) {
                    // 正在登陆, 等待
                    NSLog(@"LSSessionRequestManager::handleRespond( [正在登陆状态, 等待], self.array.size : %lu )", (unsigned long)self.array.count);
                } else if (self.loginManager.status == NONE) {
                    // 注销状态, 返回失败
                    NSLog(@"LSSessionRequestManager::handleRespond( [注销状态, 返回失败], self.array.size : %lu )", (unsigned long)self.array.count);
                    @synchronized(self) {
                        [request callRespond:success errnum:HTTP_LCC_ERR_SESSION_REQUEST_WITHOUT_LOGIN errmsg:errmsg];
                        [self.array removeObject:request];
                    }
                }
            });

            bFlag = YES;
        }
    }

    return bFlag;
}

- (void)requestFinish:(LSSessionRequest *)request {
    @synchronized(self) {
        [self.requestArray removeObject:request];
    }
}

#pragma mark - 登陆回调处理
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
            if (success) {
                // 重新发送请求
                for (LSSessionRequest *request in self.array) {
                    if (request) {
                        request.token = manager.loginItem.token ? manager.loginItem.token : @"";
                        [request sendRequest];
                    }
                }

            } else {
                // 回调失败
                for (LSSessionRequest *request in self.array) {
                    if (request) {
                        [request callRespond:success errnum:errnum errmsg:errmsg];
                    }
                }
            }

            // 清空所有请求
            [self.array removeAllObjects];

        }
    });
}

- (void)manager:(LSLoginManager *)manager onLogout:(LogoutType)type msg:(NSString *)msg {
}

@end
