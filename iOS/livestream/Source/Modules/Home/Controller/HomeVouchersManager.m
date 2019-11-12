//
//  HomeVouchersManager.m
//  livestream
//
//  Created by Calvin on 2018/1/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HomeVouchersManager.h"

static HomeVouchersManager* homeVouchersManager = nil;

@interface HomeVouchersManager ()

@property (nonatomic, strong) LSSessionRequestManager* sessionManager;

@end

@implementation HomeVouchersManager

+ (instancetype)manager {
    if( homeVouchersManager == nil ) {
        homeVouchersManager = [[[self class] alloc] init];
    }
    return homeVouchersManager;
}

- (id)init {
    if( self = [super init] ) {
        self.sessionManager = [LSSessionRequestManager manager];
    }
    return self;
}

- (void)getVouchersData:(GetVoucherAvailableInfoFinishHandler)finishHandler
{
    LSGetVoucherAvailableInfoRequest * request = [[LSGetVoucherAvailableInfoRequest alloc]init];
    request.finishHandler = finishHandler;
    [self.sessionManager sendRequest:request];
}

- (BOOL)isShowWatchNowFree:(NSString *)userId {
    if (!self.item) {
        return NO;
    }
    //当前系统时间戳
    NSInteger nowTime = [[NSDate date] timeIntervalSince1970];
    
    //绑定主播列表
    NSArray * anchorList = [self.item.bindAnchor copy];
    if (anchorList.count > 0) {
        for (LSBindAnchorItemObject * obj in anchorList) {
            if ([obj.anchorId isEqualToString:userId] && obj.useRoomType != USEROOMTYPE_PRIVATE) {
                if (obj.expTime > nowTime) {
                    return YES;
                }
            }
        }
    }
    
    //我看过的主播列表
    NSArray * watchedAnchor = [self.item.watchedAnchor copy];
    if (watchedAnchor.count > 0) {
        BOOL isWatched = [watchedAnchor containsObject:userId];
        //没看过
        if (!isWatched) {
            if (self.item.onlypublicNewExpTime > nowTime) {
                return YES;
            }
        }
    }
    
    //公开直播间
    if (self.item.onlypublicExpTime > nowTime) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isShowInviteFree:(NSString *)userId {
    if (!self.item) {
        return NO;
    }
    //当前系统时间戳
    NSInteger nowTime = [[NSDate date] timeIntervalSince1970];
    
    //绑定主播列表
    NSArray * anchorList = [self.item.bindAnchor copy];
    if (anchorList.count > 0) {
        for (LSBindAnchorItemObject * obj in anchorList) {
            if ([obj.anchorId isEqualToString:userId] && obj.useRoomType != USEROOMTYPE_PUBLIC) {
                if (obj.expTime > nowTime) {
                    return YES;
                }
            }
        }
    }

    //我看过的主播列表
    NSArray * watchedAnchor = [self.item.watchedAnchor copy];
    if (watchedAnchor.count > 0) {
        BOOL isWatched = [watchedAnchor containsObject:userId];
        //没看过
        if (!isWatched) {
            if (self.item.onlyprivateNewExpTime > nowTime) {
                return YES;
            }
        }
    }
    
    //私密直播间
    if (self.item.onlyprivateExpTime > nowTime) {
        return YES;
    }
    
    return NO;
}

@end
