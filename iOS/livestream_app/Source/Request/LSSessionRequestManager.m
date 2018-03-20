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

static LSSessionRequestManager* gManager = nil;
@interface LSSessionRequestManager () <LoginManagerDelegate>
@property (nonatomic, strong) LSLoginManager* loginManager;
@property (nonatomic, strong) NSMutableArray* array;
@property (nonatomic, strong) NSMutableArray* requestArray;
@end

@implementation LSSessionRequestManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
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
- (BOOL)sendRequest:(LSSessionRequest* _Nonnull)request {
    BOOL bFlag = NO;
    request.delegate = self;
    request.token = self.loginManager.token?self.loginManager.token:@"";
    
    bFlag = [request sendRequest];
    if( bFlag ) {
        @synchronized(self) {
            [self.requestArray addObject:request];
        }
    }
    
    return bFlag;
}

- (BOOL)request:(LSSessionRequest* _Nonnull)request handleRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    BOOL bFlag = NO;
    if( !success ) {
        // 判断错误码
        if( errnum == HTTP_LCC_ERR_TOKEN_EXPIRE ||
           errnum == HTTP_LCC_ERR_NO_LOGIN) {
            // session超时
            // 插入待处理队列
//            @synchronized(self) {
//                [self.array addObject:request];
//            }
            
            // 主线程登陆
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loginManager logout:YES msg:NSLocalizedString(@"SESSION TIMEOUT", nil)];
            });
            
            bFlag = YES;
            
        }
//        else if ( errnum == LOGIN_BY_OTHER_DEVICE ) {
//            // 主线程被踢(其他设备登录)
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.loginManager logout:YES msg:@""];
//            });
//        }
    }

    return bFlag;
}

- (void)requestFinish:(LSSessionRequest* _Nonnull)request {
    @synchronized(self) {
        [self.requestArray removeObject:request];
    }
}

#pragma mark - 登陆回调处理
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSManBaseInfoItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    
    //session过期直接登出，不用重新发送请求
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
            if( success ) {
                // 重新发送请求
                for(LSSessionRequest* request in self.array) {
                    if( request ) {
                        request.token = manager.token?manager.token:@"";
                        [request sendRequest];
                    }
                }
            } else {
                // 回调失败
                for(LSSessionRequest* request in self.array) {
                    if( request ) {
                        [request callRespond:success errnum:errnum errmsg:errmsg];
                    }
                }
                
            }
            
            // 清空所有请求
            [self.array removeAllObjects];

        }
    });
    */
}

- (void)manager:(LSLoginManager *)manager onLogout:(BOOL)kick msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 清空所有请求
        [self.array removeAllObjects];
    });
}

@end
