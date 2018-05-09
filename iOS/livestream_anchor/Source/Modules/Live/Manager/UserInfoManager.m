//
//  UserInfoManager.m
//  livestream
//
//  Created by Max on 2017/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "UserInfoManager.h"
#import "LSAnchorRequestManager.h"
#import "LSLoginManager.h"

static UserInfoManager *gManager = nil;
@interface UserInfoManager ()
#pragma mark - 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 缓存数据
@property (nonatomic, strong) NSMutableDictionary *userDictionary;
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
        
        // 初始请求管理器
        self.sessionManager = [LSSessionRequestManager manager];
    }
    return self;
}

- (void)getFansBaseInfo:(NSString *)userId finishHandler:(GetUserInfoHandler)finishHandler {
    if( userId.length ) {
        @synchronized (self) {
            // 获取用户属性
            AudienModel *userInfo = [self.userDictionary valueForKey:userId];
            if (userInfo) {
                // 回调
                if( finishHandler ) {
                    finishHandler(userInfo);
                }
            } else {
                [[LSAnchorRequestManager manager] anchorGetNewFansBaseInfo:userId finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBGetNewFansBaseInfoItemObject * _Nonnull item) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(success) {
                            AudienModel *model = [[AudienModel alloc] init];
                            model.userId = userId;
                            model.nickName = item.nickName;
                            model.photoUrl = item.photoUrl;
                            model.mountId = item.riderId;
                            model.mountname = item.riderName;
                            model.mountUrl = item.riderUrl;
                            model.level = item.level;
                            @synchronized (self) {
                                [self.userDictionary setObject:model forKey:userId];
                            }
                            NSLog(@"UserInfoManager:: getUserInfo: FansBaseInfo( userId : %@, photoUrl : %@ )", userId, item.photoUrl);
                            // 回调
                            if( finishHandler ) {
                                finishHandler(model);
                            }
                        }
                    });
                }];
            }
        }
    }
}


- (void)setAudienceInfoDicL:(AudienModel *)item {
    if (item.userId) {
        @synchronized (self) {
            [self.userDictionary setObject:item forKey:item.userId];
        }
    }
}

- (void)removeAllInfo {
    @synchronized (self) {
        [self.userDictionary removeAllObjects];
    }
}

@end
