//
//  LiveUrlHandler.m
//  livestream
//
//  Created by test on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveUrlHandler.h"
#import "LSLoginManager.h"
#import "LiveModule.h"

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
    }else if ([moduleString isEqualToString:@"chatlist"]) {
        _type = LiveUrlTypeChatlist;
        [self parseLive:url Type:_type];
    }else if ([moduleString isEqualToString:@"chat"]) {
        _type = LiveUrlTypeChat;
        [self parseLive:url Type:_type];
    }else if ([moduleString isEqualToString:@"greetmaillist"]) {
        _type = LiveUrlTypeGreetmaillist;
        [self parseLive:url Type:_type];
    }else if ([moduleString isEqualToString:@"maillist"]) {
        _type = LiveUrlTypeMaillist;
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
            } else if (_mainTpye == MainListTypeCalendar) {
                index = 2;
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
            NSString *userName = [LSURLQueryParam urlParamForKey:@"anchorname" url:url];
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openBooking:userName:)]) {
                [self.delegate liveUrlHandler:self openBooking:anchorId userName:userName];
            }

        } break;
        case LiveUrlTypeBookingList: {
            // TODO:进入预约列表界面
            NSString *listType = [LSURLQueryParam urlParamForKey:@"listtype" url:url];
            if ([listType isEqualToString:@"4"]) {
                _bookType = BookingListUrlTypeHistory;
            }else if ([listType isEqualToString:@"3"]) {
                _bookType = BookingListUrlTypeConfirm;
            }else if ([listType isEqualToString:@"2"]) {
                _bookType = BookingListUrlTypeWaitAnchor;
            }else {
                _bookType = BookingListUrlTypeWaitUser;
            }

            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openBookingList:)]) {
                [self.delegate liveUrlHandler:self openBookingList:_bookType];
            }

        } break;
        case LiveUrlTypeBackpackList: {
            // TODO:进入背包列表界面
            NSString *listType = [LSURLQueryParam urlParamForKey:@"listtype" url:url];
            if ([listType isEqualToString:@"4"]) {
                _backPackType = BackPackListUrlTypePostStamp;
            }else if ([listType isEqualToString:@"3"]) {
                _backPackType = BackPackListUrlTypeDrive;
            }else if ([listType isEqualToString:@"2"]) {
                _backPackType = BackPackListUrlTypeVoucher;
            }else {
                _backPackType = BackPackListUrlTypePresent;
            }

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
        case LiveUrlTypeChatlist: {
            // TODO:进入聊天列表
            if ([self.delegate respondsToSelector:@selector(liveUrlHandlerOpenChatlist:)]) {
                [self.delegate liveUrlHandlerOpenChatlist:self];
            }
            
        } break;
        case LiveUrlTypeChat: {
            // TODO:进入聊天界面
            NSString *anchorId = [LSURLQueryParam urlParamForKey:@"anchorid" url:url];
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openChatWithAnchor:)]) {
                [self.delegate liveUrlHandler:self openChatWithAnchor:anchorId];
            }

            
        } break;
        case LiveUrlTypeGreetmaillist: {
            // TODO:进入意向信
            if ([self.delegate respondsToSelector:@selector(liveUrlHandlerOpenGreetmaillist:)]) {
                [self.delegate liveUrlHandlerOpenGreetmaillist:self];
            }

            
        } break;
        case LiveUrlTypeMaillist: {
            // TODO:进入信件列表
            if ([self.delegate respondsToSelector:@selector(liveUrlHandlerOpenMaillist:)]) {
                [self.delegate liveUrlHandlerOpenMaillist:self];
            }
            
        } break;
        default:{
            // 无则认为跳转到首页main
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openMainType:)]) {
                [self.delegate liveUrlHandler:self openMainType:0];
            }
        }break;
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
    item.showId = [LSURLQueryParam urlParamForKey:@"liveshowid" url:url];
    item.opentype = [LSURLQueryParam urlParamForKey:@"opentype" url:url];
    item.apptitle = [LSURLQueryParam urlParamForKey:@"apptitle" url:url];
    item.anchorid = [LSURLQueryParam urlParamForKey:@"anchorid" url:url];
    item.gascreen = [LSURLQueryParam urlParamForKey:@"gascreen" url:url];
    item.styletype = [LSURLQueryParam urlParamForKey:@"styletype" url:url];
    item.resumecb = [LSURLQueryParam urlParamForKey:@"resumecb" url:url];
    return item;
}

- (void)invitationRoomIn:(LSUrlParmItem *)item andUrl:(NSURL *)url {

    if ([item.roomTypeString isEqualToString:@"1"]) {
        // 主动邀请
        item.roomType = LiveRoomType_Private;
        if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openPreLive:userId:roomType:)]) {
            [self.delegate liveUrlHandler:self openPreLive:item.roomId userId:item.userId roomType:item.roomType];
        }
    } else if ([item.roomTypeString isEqualToString:@"2"]) {

        // 发送立即私密邀请
        item.roomType = LiveRoomType_Private;
        if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openPreLive:userId:roomType:)]) {
            [self.delegate liveUrlHandler:self openPreLive:item.roomId userId:item.userId roomType:item.roomType];
        }

    } else if ([item.roomTypeString isEqualToString:@"3"]) {
        // 应邀
        item.roomType = LiveRoomType_Private;

        NSString *inviteId = [LSURLQueryParam urlParamForKey:@"invitationid" url:url];
        if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openInvited:userId:inviteId:)]) {
            [self.delegate liveUrlHandler:self openInvited:item.userName userId:item.userId inviteId:inviteId];
        }

    } else if ([item.roomTypeString isEqualToString:@"5"]) {
        // 新建多人互动直播间
        item.roomType = LiveRoomType_Hang_Out;
        if ([self.delegate respondsToSelector:@selector(liveUrlHandler:OpenHangout:anchorId:nickName:)]) {
            [self.delegate liveUrlHandler:self OpenHangout:item.roomId anchorId:item.userId nickName:item.userName];
        }

    } else {
        if (item.showId.length > 0) {
            NSLog(@"进入节目直播间");
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openShow:userId:roomType:)]) {
                [self.delegate liveUrlHandler:self openShow:item.showId userId:item.userId roomType:item.roomType];
            }
        } else {
            // 默认进入公开直播间
            item.roomType = LiveRoomType_Public;
            NSLog(@"进入公开直播间");
            if ([self.delegate respondsToSelector:@selector(liveUrlHandler:openPublicLive:userId:roomType:)]) {
                [self.delegate liveUrlHandler:self openPublicLive:item.roomId userId:item.userId roomType:item.roomType];
            }
        }
    }
}

#pragma mark - 获取模块URL
- (NSURL *)createUrlToHangoutByRoomId:(NSString *_Nullable)roomId anchorId:(NSString *_Nullable)anchorId nickName:(NSString *)nickName {

    int roomTypeInt = 5;
    NSString *codeName = nil;
    if (nickName.length > 0) {
        codeName = [self encodeParameter:nickName];
    }
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&&roomid=%@&anchorid=%@&anchorname=%@&roomtype=%d", roomId, anchorId, codeName, roomTypeInt];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToInviteByRoomId:(NSString *)roomId userId:(NSString *)userId roomType:(LiveRoomType)roomType {
    int roomTypeInt = 0;
    if (roomType == LiveRoomType_Private || roomType == LiveRoomType_Private_VIP) {
        roomTypeInt = 1;
    }

    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&roomid=%@&anchorid=%@&roomtype=%d", roomId, userId, roomTypeInt];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToShowRoomId:(NSString *)roomId userId:(NSString *)userId {

    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&liveshowid=%@&anchorid=%@&roomtype=0", roomId, userId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToInviteByInviteId:(NSString *)inviteId anchorId:(NSString *)anchorId nickName:(NSString *)nickName {
    NSString *codeName = [self encodeParameter:nickName];
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&invitationid=%@&anchorid=%@&anchorname=%@&roomtype=%d", inviteId, anchorId, codeName, 3];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToLookLadyAnchorId:(NSString *)anchorId {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=anchordetail&anchorid=%@", anchorId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToHomePage:(int)index {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=main&listtype=%d", index];
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
