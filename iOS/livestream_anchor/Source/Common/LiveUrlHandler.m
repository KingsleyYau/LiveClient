//
//  LiveUrlHandler.m
//  livestream
//
//  Created by test on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveUrlHandler.h"
#import "LSLoginManager.h"

static LiveUrlHandler *gInstance = nil;
@interface LiveUrlHandler () <LoginManagerDelegate>
/**
 *  是否已经被URL打开
 */
@property (assign, atomic) BOOL openByUrl;

/**
 *  是否有待处理URL
 */
@property (assign, atomic) BOOL hasHandle;

/** 代理数组 */
@property (nonatomic, strong) NSMutableArray *delegates;

@end

@implementation LiveUrlHandler
+ (instancetype)shareInstance {
    if (gInstance == nil) {
        gInstance = [[[self class] alloc] init];
    }
    return gInstance;
}

- (id)init {
    if (self = [super init]) {
        _type = LiveUrlTypeNone;
    }
    return self;
}

- (BOOL)handleOpenURL {
    BOOL bFlag = NO;

    NSURL *url = self.url;
    if (url) {
        NSLog(@"LiveUrlHandler::handleOpenURL( url : %@ )", url);

        // 跳转模块
        NSString *serviceKey = [LSURLQueryParam urlParamForKey:@"service" url:url];
        if ([serviceKey isEqualToString:@"live"]) {
            // 跳转模块
            NSString *moduleKey = [LSURLQueryParam urlParamForKey:@"module" url:url];
            [self getURL:url moduleType:moduleKey];
        }
    }

    self.url = nil;

    return bFlag;
}

- (void)getURL:(NSURL *)url moduleType:(NSString *)moduleString {
    if ([moduleString isEqualToString:@"main"]) {
        // 跳转主页
        _type = LiveUrlTypeMain;
        [self parseLive:url Type:_type];
    } else if ([moduleString isEqualToString:@"anchordetail"]) {
        _type = LiveUrlTypeDetail;
        [self parseLive:url Type:_type];
    } else if ([moduleString isEqualToString:@"liveroom"]) {
        _type = LiveUrlTypeInvite;
        LSUrlParmItem *item = [self parseUrlParms:url];
        [self invitationRoomIn:item andUrl:url];
    } else if ([moduleString isEqualToString:@"newbooking"]) {
        _type = LiveUrlTypeBooking;
        [self parseLive:url Type:_type];
    } else if ([moduleString isEqualToString:@"bookinglist"]) {
        _type = LiveUrlTypeBookingList;

        [self parseLive:url Type:_type];
    } else if ([moduleString isEqualToString:@"backpacklist"]) {
        _type = LiveUrlTypeBackpackList;
        [self parseLive:url Type:_type];
    } else if ([moduleString isEqualToString:@"buycredit"]) {
        _type = LiveUrlTypeBuyCredit;
        [self parseLive:url Type:_type];
    } else if ([moduleString isEqualToString:@"mylevel"]) {
        _type = LiveUrlTypeMyLevel;
        [self parseLive:url Type:_type];
    }
}

- (BOOL)parseLive:(NSURL *)url Type:(LiveUrlType)type {
    BOOL bFlag = YES;
    switch (type) {
        case LiveUrlTypeMain: {
            NSString *listType = [LSURLQueryParam urlParamForKey:@"listtype" url:url];
            _mainTpye = [listType intValue];
            int index = 0;
            if (_mainTpye == MainListTypeFollow) {
                index = 1;
            }
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openMainType:)]) {
                [self.delegate liveUrlHandler:self openMainType:index];
            }

        } break;
        case LiveUrlTypeDetail: {
            // TODO:弹出广告页面,个人详情
            NSString *anchorId = [LSURLQueryParam urlParamForKey:@"anchorid" url:url];
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openAnchorDetail:)]) {
                [self.delegate liveUrlHandler:self openAnchorDetail:anchorId];
            }

        } break;
        case LiveUrlTypeLiveroom: {

        } break;
        case LiveUrlTypeBooking: {
            // TODO:进入新建预约界面
            NSString *anchorId = [LSURLQueryParam urlParamForKey:@"anchorid" url:url];
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openBooking:)]) {
                [self.delegate liveUrlHandler:self openBooking:anchorId];
            }

        } break;
        case LiveUrlTypeBookingList: {
            // TODO:进入预约列表界面
            NSString *listType = [LSURLQueryParam urlParamForKey:@"listtype" url:url];
            _bookType = [listType intValue];
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openBookingList:)]) {
                [self.delegate liveUrlHandler:self openBookingList:_bookType];
            }

        } break;
        case LiveUrlTypeBackpackList: {
            // TODO:进入背包列表界面
            NSString *listType = [LSURLQueryParam urlParamForKey:@"listtype" url:url];
            _backPackType = [listType intValue];
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openBackpackList:)]) {
                [self.delegate liveUrlHandler:self openBackpackList:_backPackType];
            }
        } break;
        case LiveUrlTypeBuyCredit: {
            // TODO:进入充值界面
            if ([self.delegate respondsToSelector:@selector(liveUrlHandlerOpenAddCredit:)]) {
                [self.delegate liveUrlHandlerOpenAddCredit:self];
            }

        } break;
        case LiveUrlTypeMyLevel: {
            // TODO:进入我的等级界面
            if ([self.delegate respondsToSelector:@selector(liveUrlHandlerOpenMyLevel:)]) {
                [self.delegate liveUrlHandlerOpenMyLevel:self];
            }

        } break;
        default:
            break;
    }

    return bFlag;
}

- (LSUrlParmItem *)parseUrlParms:(NSURL *)url {
    LSUrlParmItem *item = [[LSUrlParmItem alloc] init];

    item.roomId = [LSURLQueryParam urlParamForKey:@"roomid" url:url];
    item.userId = [LSURLQueryParam urlParamForKey:@"anchorid" url:url];
    item.roomType = LiveRoomType_Public;
    item.roomTypeString = [LSURLQueryParam urlParamForKey:@"roomtype" url:url];
    item.userName = [LSURLQueryParam urlParamForKey:@"anchorname" url:url];
    item.opentype = [LSURLQueryParam urlParamForKey:@"opentype" url:url];
    item.apptitle = [LSURLQueryParam urlParamForKey:@"apptitle" url:url];
    item.showId = [LSURLQueryParam urlParamForKey:@"liveshowid" url:url];
    return item;
}

- (void)invitationRoomIn:(LSUrlParmItem *)item andUrl:(NSURL *)url {

    if ([item.roomTypeString isEqualToString:@"3"]) {
        // 应邀
        item.roomType = LiveRoomType_Private;

        NSString *inviteId = [LSURLQueryParam urlParamForKey:@"invitationid" url:url];
        if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openInvited:userId:inviteId:)]) {
            [self.delegate liveUrlHandler:self openInvited:item.userName userId:item.userId inviteId:inviteId];
        }

    } else if ([item.roomTypeString isEqualToString:@"1"]) {
        // 主动邀请
        item.roomType = LiveRoomType_Private;
        if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openPreLive:userId:roomType:)]) {
            [self.delegate liveUrlHandler:self openPreLive:item.roomId userId:item.userId roomType:item.roomType];
        }
    }
    else
    {
        if (item.showId.length > 0) {
            NSLog(@"进入节目直播间");
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openShow:userId:roomType:)]) {
                [self.delegate liveUrlHandler:self openShow:item.showId userId:item.userId roomType:item.roomType];
            }
        }
    }
}

#pragma mark - 获取模块URL
- (NSURL *)createUrlToInviteByRoomId:(NSString *)roomId userId:(NSString *)userId roomType:(LiveRoomType)roomType {
    int roomTypeInt = 0;
    if (roomType == LiveRoomType_Private || roomType == LiveRoomType_Private_VIP) {
        roomTypeInt = 1;
    }

    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?site:4&service=live&module=liveroom&roomid=%@&anchorid=%@&roomtype=%d", roomId, userId, roomTypeInt];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToShowRoomId:(NSString *)roomId userId:(NSString *)userId  {
    
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?site:4&service=live&module=liveroom&liveshowid=%@&anchorid=%@&roomtype=0", roomId, userId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToInviteByInviteId:(NSString *)inviteId anchorId:(NSString *)anchorId nickName:(NSString *)nickName {
    NSString *codeName = [self encodeParameter:nickName];
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?site:4&service=live&module=liveroom&invitationid=%@&anchorid=%@&anchorname=%@&roomtype=%d", inviteId, anchorId, codeName, 3];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToLookLadyAnchorId:(NSString *)anchorId {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?site:4&service=live&module=anchordetail&anchorid=%@",anchorId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToHomePage:(int)index {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?site:4&service=live&module=main&listtype=%d",index];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSString *)encodeParameter:(NSString *)originalPara {
    CFStringRef encodeParaCf = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)originalPara, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
    NSString *encodePara = (__bridge NSString *)(encodeParaCf);
    CFRelease(encodeParaCf);
    return encodePara;
}

@end
