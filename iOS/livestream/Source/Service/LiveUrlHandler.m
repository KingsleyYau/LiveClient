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

#define Qpid @"qpidnetwork://app/open?"

static LiveUrlHandler *gInstance = nil;
@interface LiveUrlHandler ()
// 需要处理的URL
@property (strong) NSURL *url;
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
    }
    return self;
}

- (BOOL)handleOpenURL:(NSURL *)url {
    NSLog(@"LiveUrlHandler::handleOpenURL( url : %@ )", url);
    //    NSLog(@"LiveUrlHandler::handleOpenURL( url.host : %@ )", url.host);
    //    NSLog(@"LiveUrlHandler::handleOpenURL( url.path : %@ )", url.path);
    //    NSLog(@"LiveUrlHandler::handleOpenURL( url.query : %@ )", url.query);

    self.url = url;

    if ([self.delegate respondsToSelector:@selector(handlerUpdateUrl:)]) {
        [self.delegate handlerUpdateUrl:self];
    }

    return YES;
}

- (void)openURL {
    NSLog(@"LiveUrlHandler::openURL( url : %@ )", self.url);
    if (self.url) {
        LSUrlParmItem *item = [LSUrlParmItem urlItemWithUrl:self.url];
        [self openURLWithItem:item];
        self.url = nil;
    }
}

- (BOOL)openURLWithItem:(LSUrlParmItem *)item {
    NSLog(@"LiveUrlHandler::openURLWithItem( url : %@, type : %d )", self.url, item.type);

    BOOL bFlag = YES;

    switch (item.type) {
        case LiveUrlTypeMain: {
            // TODO:进入主界面
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openMainType:)]) {
                [self.parseDelegate liveUrlHandler:self openMainType:item.mainListType];
            }

        } break;
        case LiveUrlTypeDetail: {
            // TODO:进入主播详情
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openAnchorDetail:)]) {
                [self.parseDelegate liveUrlHandler:self openAnchorDetail:item.anchorId];
            }

        } break;
        case LiveUrlTypeLiveRoom: {
            // TODO:进入[直播间/主动邀请/应邀/多人互动/节目]
            [self invitationRoomIn:item];
        } break;
        case LiveUrlTypeBooking: {
            // TODO:进入新建预约
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openBooking:anchorName:)]) {
                [self.parseDelegate liveUrlHandler:self openBooking:item.anchorId anchorName:item.anchorName];
            }

        } break;
        case LiveUrlTypeBookingList: {
            // TODO:进入预约列表
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openBookingList:)]) {
                [self.parseDelegate liveUrlHandler:self openBookingList:item.bookingListType];
            }

        } break;
        case LiveUrlTypeBackpackList: {
            // TODO:进入背包列表
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openBackpackList:)]) {
                [self.parseDelegate liveUrlHandler:self openBackpackList:item.backpackListType];
            }
        } break;
        case LiveUrlTypeBuyCredit: {
            // TODO:进入充值
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandlerOpenAddCredit:)]) {
                [self.parseDelegate liveUrlHandlerOpenAddCredit:self];
            }
        } break;
        case LiveUrlTypeMyLevel: {
            // TODO:进入我的等级
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandlerOpenMyLevel:)]) {
                [self.parseDelegate liveUrlHandlerOpenMyLevel:self];
            }
        } break;
        case LiveUrlTypeChatList: {
            // TODO:进入私信列表列表
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandlerOpenChatList:)]) {
                [self.parseDelegate liveUrlHandlerOpenChatList:self];
            }
        } break;
        case LiveUrlTypeChat: {
            // TODO:进入私信详情界面
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openChatWithAnchor:anchorName:)]) {
                [self.parseDelegate liveUrlHandler:self openChatWithAnchor:item.anchorId anchorName:item.anchorName];
            }
        } break;
        case LiveUrlTypeGreetMailList: {
            // TODO:进入意向信列表
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandlerOpenGreetMailList:)]) {
                [self.parseDelegate liveUrlHandlerOpenGreetMailList:self];
            }
        } break;
        case LiveUrlTypeMailList: {
            // TODO:进入信件列表
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandlerOpenMailList:)]) {
                [self.parseDelegate liveUrlHandlerOpenMailList:self];
            }
        } break;
        case LiveUrlTypeDialog: {
            // TODO:弹出对话框
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didOpenYesNoDialogTitle:msg:yesTitle:noTitle:yesUrl:)]) {
                [self.parseDelegate liveUrlHandler:self didOpenYesNoDialogTitle:item.title msg:item.msg yesTitle:item.yesTitle noTitle:item.noTitle yesUrl:item.yesUrl];
            }
        } break;
        case LiveUrlTypeLiveChatList: {
            // TODO:进入livechat联系人列表
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandlerOpenLiveChatList:)]) {
                [self.parseDelegate liveUrlHandlerOpenLiveChatList:self];
            }
        }break;
        case LiveUrlTypeLiveChat: {
            // TODO:进入livechat联系人
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didOpenLiveChatLady:anchorName:)]) {
                [self.parseDelegate liveUrlHandler:self didOpenLiveChatLady:item.anchorId anchorName:item.anchorName];
            }
        }break;
        case LiveUrlTypeSendMail: {
            // TODO:进入发信页面
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didOpenSendMail:anchorName:)]) {
                [self.parseDelegate liveUrlHandler:self didOpenSendMail:item.anchorId anchorName:item.anchorName];
            }
        }break;
        case LiveUrlTypeHangoutDialog: {
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didOpenHangoutDialog:anchorName:)]) {
                [self.parseDelegate liveUrlHandler:self didOpenHangoutDialog:item.anchorId anchorName:item.anchorName];
            }
        }break;
        case LiveUrlTypeHangout: {
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didOpenHangoutRoom:anchorName:)]) {
                [self.parseDelegate liveUrlHandler:self didOpenHangoutRoom:item.anchorId anchorName:item.anchorName];
            }
        }break;
        default: {
            // 进入主界面
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openMainType:)]) {
                [self.parseDelegate liveUrlHandler:self openMainType:0];
            }
        } break;
    }

    return bFlag;
}

- (LSUrlParmItem *)parseUrlParms:(NSURL *)url {
    // TODO:解析URL为结构体
    LSUrlParmItem *item = [LSUrlParmItem urlItemWithUrl:url];
    return item;
}

- (void)invitationRoomIn:(LSUrlParmItem *)item {
    
    switch (item.roomType) {
        case LiveUrlRoomTypeHangOut:{
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openHangout:anchorId:anchorName:hangoutAnchorId:hangoutAnchorName:)]) {
                [self.parseDelegate liveUrlHandler:self openHangout:item.roomId anchorId:item.anchorId anchorName:item.anchorName hangoutAnchorId:item.hangoutAnchorId hangoutAnchorName:item.hangoutAnchorName];
            }
        }break;
            
        default:{
            if (item.roomId.length > 0) {
                if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openPublicLive:anchorId:roomType:)]) {
                    [self.parseDelegate liveUrlHandler:self openPublicLive:item.roomId anchorId:item.anchorId roomType:LiveRoomType_Private_VIP];
                }
            } else {
                switch (item.roomType) {
                    case LiveUrlRoomTypePublic: {
                        if (item.liveShowId.length > 0) {
                            // 进入节目
                            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openShow:anchorId:roomType:)]) {
                                [self.parseDelegate liveUrlHandler:self openShow:item.liveShowId anchorId:item.anchorId roomType:LiveRoomType_Public];
                            }
                        } else {
                            // 进入公开直播间
                            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openPublicLive:anchorId:roomType:)]) {
                                [self.parseDelegate liveUrlHandler:self openPublicLive:item.roomId anchorId:item.anchorId roomType:LiveRoomType_Public];
                            }
                        }
                    } break;
                    case LiveUrlRoomTypePrivate:
                    case LiveUrlRoomTypePrivateInvite: {
                        // 主动邀请
                        if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openPreLive:anchorId:roomType:)]) {
                            [self.parseDelegate liveUrlHandler:self openPreLive:item.roomId anchorId:item.anchorId roomType:LiveRoomType_Private];
                        }
                    } break;
                    case LiveUrlRoomTypePrivateAccept: {
                        // 应邀
                        if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openInvited:anchorId:inviteId:)]) {
                            [self.parseDelegate liveUrlHandler:self openInvited:item.anchorName anchorId:item.anchorId inviteId:item.inviteId];
                        }
                    } break;
                    default:
                        break;
                }
            }
        }break;
    }
}

#pragma mark - 获取模块URL
- (NSURL *)createUrlToHangoutByRoomId:(NSString *)roomId anchorId:(NSString *)anchorId anchorName:(NSString *)anchorName hangoutAnchorId:(NSString *)hangoutAnchorId hangoutAnchorName:(NSString *)hangoutAnchorName {
    int roomTypeInt = 4;
    NSString *codeName = nil;
    if (anchorName.length > 0) {
        codeName = [self encodeParameter:anchorName];
    }
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&&roomid=%@&anchorid=%@&anchorname=%@&hangoutAnchorId=%@&hangoutAnchorName=%@&roomtype=%d", roomId, anchorId, codeName, hangoutAnchorId, hangoutAnchorName, roomTypeInt];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToInviteByRoomId:(NSString *)roomId anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    int roomTypeInt = 0;
    if (roomType == LiveRoomType_Private || roomType == LiveRoomType_Private_VIP) {
        roomTypeInt = 1;
    }

    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&roomid=%@&anchorid=%@&roomtype=%d", roomId, anchorId, roomTypeInt];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToShowRoomId:(NSString *)roomId anchorId:(NSString *)anchorId {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&liveshowid=%@&anchorid=%@&roomtype=0", roomId, anchorId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToInviteByInviteId:(NSString *)inviteId anchorId:(NSString *)anchorId anchorName:(NSString *)anchorName {
    NSString *codeName = [self encodeParameter:anchorName];
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&invitationid=%@&anchorid=%@&anchorname=%@&roomtype=%d", inviteId, anchorId, codeName, 3];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToAnchorDetail:(NSString *)anchorId {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=anchordetail&anchorid=%@", anchorId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToHomePage:(LiveUrlMainListType)type {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=main&listtype=%d", [LSUrlParmItem mainListIndexWithType:type]];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSString *)encodeParameter:(NSString *)originalPara {
    CFStringRef encodeParaCf = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)originalPara, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
    NSString *encodePara = (__bridge NSString *)(encodeParaCf);
    CFRelease(encodeParaCf);
    return encodePara;
}

- (NSURL *)createSendmailByanchorId:(NSString *)anchorId anchorName:(NSString *)anchorName {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=sendmail&anchorid=%@&anchorname=%@", anchorId, anchorName];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createLiveChatByanchorId:(NSString *)anchorId anchorName:(NSString *)anchorName {
    NSString * urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?site=41&service=live&module=livechat&anchorid=%@&anchorname=%@",anchorId,[anchorName UrlEncode]];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

@end
