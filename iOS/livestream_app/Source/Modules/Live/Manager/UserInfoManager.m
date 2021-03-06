//
//  UserInfoManager.m
//  livestream
//
//  Created by Max on 2017/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "UserInfoManager.h"
#import "LSGetUserInfoRequest.h"
#import "GetNewFansBaseInfoRequest.h"
#import "LSLoginManager.h"

static UserInfoManager *gManager = nil;
@interface UserInfoManager ()
#pragma mark - 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 缓存数据
@property (nonatomic, strong) NSMutableDictionary *userDictionary;
@property (nonatomic, strong) NSMutableDictionary *liverDictionary;
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
        self.userDictionary = [NSMutableDictionary dictionary];
        self.liverDictionary = [NSMutableDictionary dictionary];
        
        // 初始请求管理器
        self.sessionManager = [LSSessionRequestManager manager];
    }
    return self;
}

- (void)getUserInfo:(NSString *)userId finishHandler:(GetUserInfoHandler)finishHandler {
    if( userId ) {
        @synchronized (self) {
            // 获取用户属性
            LSUserInfoModel *userInfo = [self.userDictionary valueForKey:userId];
            LSUserInfoModel *liverInfo = [self.liverDictionary valueForKey:userId];
            if (liverInfo) {
                // 回调
                if( finishHandler ) {
                    finishHandler(liverInfo);
                }
            } else if (userInfo) {
                // 回调
                if( finishHandler ) {
                    finishHandler(userInfo);
                }
            } else {
                // 请求观众信息
                GetNewFansBaseInfoRequest *request = [[GetNewFansBaseInfoRequest alloc] init];
                request.userId = userId;
                request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, GetNewFansBaseInfoItemObject * _Nonnull item) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(success) {
                            LSUserInfoModel *info = [[LSUserInfoModel alloc] init];
                            info.nickName = item.nickName;
                            info.photoUrl = item.photoUrl;
                            info.riderId = item.riderId;
                            info.riderName = item.riderName;
                            info.riderUrl = item.riderUrl;
                            @synchronized (self) {
                                [self.userDictionary setObject:info forKey:userId];
                            }
                            NSLog(@"UserInfoManager:: getUserInfo: FansBaseInfo( userId : %@, photoUrl : %@ )", userId, item.photoUrl);
                            // 回调
                            if( finishHandler ) {
                                finishHandler(info);
                            }
                        } else {
                            // 请求失败请求主播信息
                            [self getLiverInfo:userId finishHandler:finishHandler];
                        }
                    });
                };
                [self.sessionManager sendRequest:request];
            }
        }
    }
}

- (void)getLiverInfo:(NSString * _Nonnull)userId finishHandler:(GetUserInfoHandler _Nullable)finishHandler {
    LSGetUserInfoRequest *request = [[LSGetUserInfoRequest alloc] init];
    request.userId = userId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSUserInfoItemObject * _Nullable userInfoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(success) {
                if ([[LSLoginManager manager].loginItem.userId isEqualToString:userInfoItem.userId]) {
                    [LSLoginManager manager].loginItem.userlevel = userInfoItem.userLevel;
                }
                LSUserInfoModel *info = [[LSUserInfoModel alloc] init];
                info.userId = userInfoItem.userId;
                info.nickName = userInfoItem.nickName;
                info.photoUrl = userInfoItem.photoUrl;
                info.age = userInfoItem.age;
                info.country = userInfoItem.country;
                info.isOnline = userInfoItem.isOnline;
                info.isAnchor = userInfoItem.isAnchor;
                info.leftCredit = userInfoItem.leftCredit;
                info.userLevel = userInfoItem.userLevel;
                info.anchorInfo = userInfoItem.anchorInfo;
                @synchronized (self) {
                    [self.liverDictionary setObject:info forKey:userId];
                }
                NSLog(@"UserInfoManager::getLiverInfo( userId : %@, photoUrl : %@ )", userInfoItem.userId, userInfoItem.photoUrl);
                // 回调
                if( finishHandler ) {
                    finishHandler(info);
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)getFansBaseInfo:(NSString *)userId finishHandler:(GetUserInfoHandler)finishHandler {
    
    GetNewFansBaseInfoRequest *request = [[GetNewFansBaseInfoRequest alloc] init];
    request.userId = userId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, GetNewFansBaseInfoItemObject * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(success) {
                
                LSUserInfoModel *info = [[LSUserInfoModel alloc] init];
                info.nickName = item.nickName;
                info.photoUrl = item.photoUrl;
                info.riderId = item.riderId;
                info.riderName = item.riderName;
                info.riderUrl = item.riderUrl;
                @synchronized (self) {
                    [self.userDictionary setObject:info forKey:userId];
                }
                NSLog(@"UserInfoManager::getFansBaseInfo( userId : %@, photoUrl : %@ )", userId, item.photoUrl);
                // 回调
                if( finishHandler ) {
                    finishHandler(info);
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)getMyProfileInfoFinishHandler:(GetManBaseInfoFinishHandler)finishHandler
{
    LSGetManBaseInfoRequest *request = [[LSGetManBaseInfoRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSManBaseInfoItemObject * _Nonnull infoItem) {
        if( finishHandler ) {
            finishHandler(success,errnum,errmsg,infoItem);
        }
        if (success) {
            if ([[LSLoginManager manager].loginItem.userId isEqualToString:infoItem.userId]) {
                [LSLoginManager manager].loginItem.userlevel = infoItem.userlevel;
            }
        }
    };
     [self.sessionManager sendRequest:request];
}


- (void)setUserInfo:(NSString *)name FinishHandler:(SetManBaseInfoFinishHandler)finishHandler
{
    LSSetManBaseInfoRequest * request = [[LSSetManBaseInfoRequest alloc]init];
    request.nickName = name;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        
        if (finishHandler) {
            finishHandler(success,errnum,errmsg);
        }
    };
    [self.sessionManager sendRequest:request];
}
@end
