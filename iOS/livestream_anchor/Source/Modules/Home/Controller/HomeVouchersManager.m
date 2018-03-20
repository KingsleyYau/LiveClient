//
//  HomeVouchersManager.m
//  livestream
//
//  Created by Calvin on 2018/1/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HomeVouchersManager.h"
#import "LSGetVoucherAvailableInfoRequest.h"
static HomeVouchersManager *homeVouchersManager = nil;

@interface HomeVouchersManager ()

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (nonatomic, strong) LSVoucherAvailableInfoItemObject *item;
@end

@implementation HomeVouchersManager

+ (instancetype)manager {
    if (homeVouchersManager == nil) {
        homeVouchersManager = [[[self class] alloc] init];
    }
    return homeVouchersManager;
}

- (id)init {
    if (self = [super init]) {
        self.sessionManager = [LSSessionRequestManager manager];
    }
    return self;
}

- (void)getVouchersData {
    LSGetVoucherAvailableInfoRequest *request = [[LSGetVoucherAvailableInfoRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSVoucherAvailableInfoItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.item = item;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableViewVouchersData" object:nil];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (BOOL)isShowFreeLive:(NSString *)userId LiveRoomType:(HttpRoomType)type {
    if (!self.item) {
        return NO;
    }

    //免费公开直播间，就显示Free图标
    if (type == HTTPROOMTYPE_FREEPUBLICLIVEROOM) {
        return NO;
    }

    //当前系统时间戳
    NSInteger nowTime = [[NSDate date] timeIntervalSince1970];

    //付费公开直播间
    if (type == HTTPROOMTYPE_CHARGEPUBLICLIVEROOM) {
        if (self.item.onlypublicExpTime > nowTime) {
            return YES;
        }
    }

    //私密直播间
    if (type == HTTPROOMTYPE_COMMONPRIVATELIVEROOM ||
        type == HTTPROOMTYPE_LUXURYPRIVATELIVEROOM ||
        type == HTTPROOMTYPE_NOLIVEROOM) {
        if (self.item.onlyprivateExpTime > nowTime) {
            return YES;
        }
    }

    //绑定主播列表
    NSArray *anchorList = [self.item.bindAnchor copy];
    if (anchorList.count > 0) {
        for (LSBindAnchorItemObject *obj in anchorList) {

            UseRoomType roomType = obj.useRoomType;

            if (obj.useRoomType == USEROOMTYPE_LIMITLESS) {
                if ([obj.anchorId isEqualToString:userId]) {
                    if (obj.expTime > nowTime) {
                        return YES;
                    }
                }
            } else {
                if (type == HTTPROOMTYPE_CHARGEPUBLICLIVEROOM ||
                    type == HTTPROOMTYPE_FREEPUBLICLIVEROOM) {
                    roomType = USEROOMTYPE_PUBLIC;
                }

                if (type == HTTPROOMTYPE_COMMONPRIVATELIVEROOM ||
                    type == HTTPROOMTYPE_LUXURYPRIVATELIVEROOM ||
                    type == HTTPROOMTYPE_NOLIVEROOM) {
                    roomType = USEROOMTYPE_PRIVATE;
                }

                if ([obj.anchorId isEqualToString:userId] && obj.useRoomType == roomType) {
                    if (obj.expTime > nowTime) {
                        return YES;
                    }
                }
            }
        }
    }

    //我看过的主播列表
    NSArray *watchedAnchor = [self.item.watchedAnchor copy];

    BOOL isWatched = [watchedAnchor containsObject:userId];

    //没看过
    if (!isWatched) {
        if (type == HTTPROOMTYPE_CHARGEPUBLICLIVEROOM) {
            if (self.item.onlypublicNewExpTime > nowTime) {
                return YES;
            }
        }
        if (type == HTTPROOMTYPE_COMMONPRIVATELIVEROOM ||
            type == HTTPROOMTYPE_LUXURYPRIVATELIVEROOM ||
            type == HTTPROOMTYPE_NOLIVEROOM) {
            if (self.item.onlyprivateNewExpTime > nowTime) {
                return YES;
            }
        }
    }

    
    return NO;
}
@end
