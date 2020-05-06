//
//  LSUserInfoManager.m
//  livestream
//
//  Created by test on 2019/3/6.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSUserInfoManager.h"
#import "LSGetUserInfoRequest.h"

static LSUserInfoManager *gManager = nil;
@interface LSUserInfoManager ()
#pragma mark - 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 缓存数据
@property (nonatomic, strong) NSMutableDictionary *userDictionary;

@end

@implementation LSUserInfoManager
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

        // 初始请求管理器
        self.sessionManager = [LSSessionRequestManager manager];
    }
    return self;
}

- (LSUserInfoModel *)getUserInfoLocal:(NSString *)userId {
    LSUserInfoModel *userInfo = [self.userDictionary valueForKey:userId];
    return userInfo;
}

- (void)getUserInfo:(NSString *)userId finishHandler:(GetUserInfoHandler)finishHandler {
    LSUserInfoModel *userInfo = [self.userDictionary valueForKey:userId];
    if (userInfo) {
        // 回调
        if (finishHandler) {
            finishHandler(userInfo);
        }
    } else {
        [self getUserInfoWithRequest:userId finishHandler:finishHandler];
    }
}

- (void)getUserInfoWithRequest:(NSString *)userId finishHandler:(GetUserInfoHandler)finishHandler {
    LSGetUserInfoRequest *request = [[LSGetUserInfoRequest alloc] init];
    request.userId = userId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSUserInfoItemObject *userInfoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
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

                [self.userDictionary setObject:info forKey:userId];

                NSLog(@"LSUserDetailInfoManage::getUserInfoWithRequest( userId : %@, nickName : %@, photoUrl : %@ )", userInfoItem.userId, userInfoItem.nickName, userInfoItem.photoUrl);

                // 回调
                if (finishHandler) {
                    finishHandler(info);
                }
            } else {
                finishHandler(nil);
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)removeAllUserInfo {
    [self.userDictionary removeAllObjects];
}
@end
