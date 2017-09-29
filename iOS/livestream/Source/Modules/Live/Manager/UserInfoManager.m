//
//  UserInfoManager.m
//  livestream
//
//  Created by Max on 2017/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "UserInfoManager.h"
#import "GetNewFansBaseInfoRequest.h"

static UserInfoManager *gManager = nil;
@interface UserInfoManager ()
#pragma mark - 接口管理器
@property (nonatomic, strong) SessionRequestManager *sessionManager;
// 缓存数据
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@end

@implementation UserInfoManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if (self = [super init]) {
        // 初始化缓存
        self.dictionary = [NSMutableDictionary dictionary];
        // 初始请求管理器
        self.sessionManager = [SessionRequestManager manager];
    }
    return self;
}

- (void)getUserInfo:(NSString *)userId finishHandler:(GetUserInfoHandler)finishHandler {
    @synchronized (self) {
        // 获取用户属性
        UserInfo *userInfo = [self.dictionary valueForKey:userId];
        if( userInfo ) {
            // 回调
            if( finishHandler ) {
                finishHandler(userInfo);
            }
            
        } else {
            // 发起请求
            GetNewFansBaseInfoRequest *request = [[GetNewFansBaseInfoRequest alloc] init];
            request.userId = userId;
            request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, GetNewFansBaseInfoItemObject * _Nonnull item) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized (self) {
                        if( success) {
                            // 更新缓存
                            UserInfo *userInfo = [[UserInfo alloc] init];
                            userInfo.userId = userId;
                            userInfo.item = item;
                            [self.dictionary setObject:userInfo forKey:userId];
                            
                            // 回调
                            if( finishHandler ) {
                                finishHandler(userInfo);
                            }
                        }
                    }
                });
            };
            [self.sessionManager sendRequest:request];
        }
    }
}

@end
