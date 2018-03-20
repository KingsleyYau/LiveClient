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
    request.token = self.loginManager.loginItem.token?self.loginManager.loginItem.token:@"";
    
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
            @synchronized(self) {
                [self.array addObject:request];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if( self.loginManager.status == LOGINED ) {
                    // 已经登陆状态, 注销
                    NSLog(@"LSSessionRequestManager::handleRespond( [已经登陆状态, 注销], self.array.size : %lu )", (unsigned long)self.array.count);
                    [self.loginManager logout:NO msg:@""];
                } else if ( self.loginManager.status == LOGINING ) {
                    // 正在登陆, 等待
                    NSLog(@"LSSessionRequestManager::handleRespond( [正在登陆状态, 等待], self.array.size : %lu )", (unsigned long)self.array.count);
                } else if( self.loginManager.status == NONE ) {
                    // 注销状态, 返回失败
                    NSLog(@"LSSessionRequestManager::handleRespond( [注销状态, 返回失败], self.array.size : %lu )", (unsigned long)self.array.count);
                    @synchronized (self) {
                        // 回调失败   注释掉回调所有请求，改为回调当前的请求就可以了
//                        for(LSSessionRequest* request in self.array) {
//                            if( request ) {
                               // [request callRespond:success errnum:(NSInteger)SESSION_REQUEST_WITHOUT_LOGIN errmsg:@"Send session request without login"];
                                [request callRespond:success errnum:HTTP_LCC_ERR_SESSION_REQUEST_WITHOUT_LOGIN errmsg:@"Send session request without login"];
//                            }
//                        }
                        [self.array removeObject:request];
                    }
                }
            });
            
            bFlag = YES;
            
        }
//        else if ( errnum == HTTP_LCC_ERR_LOGIN_BY_OTHER_DEVICE ) {
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
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(ZBLSLoginItemObject *)loginItem errnum:(ZBHTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
            if( success ) {
                // 重新发送请求
                for(LSSessionRequest* request in self.array) {
                    if( request ) {
                        request.token = manager.loginItem.token?manager.loginItem.token:@"";
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
    
}

- (void)manager:(LSLoginManager * _Nonnull)manager onLogout:(BOOL)timeout {
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

@end
