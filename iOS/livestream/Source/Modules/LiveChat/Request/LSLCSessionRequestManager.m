//
//  LSLCSessionRequestManager.m
//  dating
//
//  Created by Max on 16/3/11.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//
//  需要处理Session过期的接口调用处理器

#import "LSLCSessionRequestManager.h"

#import "LSLoginManager.h"
#import "LSSessionRequest.h"
#import "LiveModule.h"
#import "RequestErrorCode.h"
#import "LSLiveChatManagerListener.h"
#import "LSLiveChatManagerOC.h"

static LSLCSessionRequestManager *sessionRequestManager = nil;
@interface LSLCSessionRequestManager () <LoginManagerDelegate, LSLiveChatManagerListenerDelegate> {
    NSString *_sessionErrorMsg;
}

@property (nonatomic, strong) LSLoginManager *loginManager;
@end

@implementation LSLCSessionRequestManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if (sessionRequestManager == nil) {
        sessionRequestManager = [[[self class] alloc] init];
    }
    return sessionRequestManager;
}

- (id)init {
    if (self = [super init]) {
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
        [[LSLiveChatManagerOC manager] addDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [self.loginManager removeDelegate:self];
    [[LSLiveChatManagerOC manager] removeDelegate:self];
}

#pragma mark - 登陆回调处理

- (void)onTokenOverTimeHandler:(NSString* _Nonnull)errMsg {
    // 判断错误码(这个回调只有没登录和token过期)
    // session超时
    _sessionErrorMsg = errMsg;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loginManager.status == LOGINED) {
            // 已经登陆状态, 注销
            NSLog(@"LSSessionRequestManager::handleRespond( [已经登陆状态, 注销])");
            [self.loginManager logout:LogoutTypeRelogin msg:@""];
            [self.loginManager autoLogin];
        } else if (self.loginManager.status == LOGINING) {
            // 正在登陆, 等待
            NSLog(@"LSSessionRequestManager::handleRespond( [正在登陆状态, 等待])");
        } else if (self.loginManager.status == NONE) {
            // 注销状态, 返回失败
            NSLog(@"LSSessionRequestManager::handleRespond( [注销状态, 返回失败])");
//            @synchronized(self) {
//                [request callRespond:success errnum:HTTP_LCC_ERR_SESSION_REQUEST_WITHOUT_LOGIN errmsg:errmsg];
//                [self.array removeObject:request];
//            }
        }
    });

}

@end

