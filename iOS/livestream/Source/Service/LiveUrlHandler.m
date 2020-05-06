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
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didOpenLiveChatLady:anchorName:inviteMsg:)]) {
                [self.parseDelegate liveUrlHandler:self didOpenLiveChatLady:item.anchorId anchorName:item.anchorName inviteMsg:item.inviteMsg];
            }
        }break;
        case LiveUrlTypeSendMail: {
            // TODO:进入发信页面
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didOpenSendMail:anchorName:emfId:)]) {
                [self.parseDelegate liveUrlHandler:self didOpenSendMail:item.anchorId anchorName:item.anchorName emfId:item.emfId];
            }
        }break;
        case LiveUrlTypeHangoutDialog: {
            // TODO:进入多人互动页弹层
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didOpenHangoutDialog:anchorName:)]) {
                [self.parseDelegate liveUrlHandler:self didOpenHangoutDialog:item.anchorId anchorName:item.anchorName];
            }
        }break;
        case LiveUrlTypeHangout: {
            // TODO:进入多人互动
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openHangout:inviteAnchorId:inviteAnchorName:recommendAnchorId:recommendAnchorName:)]) {
                [self.parseDelegate liveUrlHandler:self openHangout:item.roomId inviteAnchorId:item.anchorId inviteAnchorName:item.anchorName recommendAnchorId:item.recommendAnchorId recommendAnchorName:item.recommendAnchorName];
            }
            
        }break;
        case LiveUrlTypeSendSayHi:{
            // TODO:进入发送sayhi
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didSendSayhi:anchorName:)]) {
                [self.parseDelegate liveUrlHandler:self didSendSayhi:item.anchorId anchorName:item.anchorName];
            }
        }break;
        case LiveUrlTypeSayHiList:{
            // TODO:进入sayhi列表
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openSayHiType:)]) {
                [self.parseDelegate liveUrlHandler:self openSayHiType:item.sayHiListType];
            }
        }break;
        case LiveUrlTypeSayHiDetail:{
            // TODO:进入sayhi详情
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didOpenSayHiDetail:)]) {
                [self.parseDelegate liveUrlHandler:self didOpenSayHiDetail:item.sayhiId];
            }
        }break;
        case LiveUrlTypeGreetMailDetail: {
            // TODO:进入意向信详情
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:didOpenGreetingMailDetail:)]) {
                [self.parseDelegate liveUrlHandler:self didOpenGreetingMailDetail:item.loiId];
            }
        }break;
        case LiveUrlTypeGiftFlowerList: {
            // TODO:进入鲜花商城
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openGiftFlowerList:)]) {
                [self.parseDelegate liveUrlHandler:self openGiftFlowerList:item.flowerListType];
            }
        }break;
        case LiveUrlTypeGiftFlowerAnchorStore: {
            // TODO:进入指定主播鲜花商城
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openGiftFlowerAnchorStore:)]) {
                [self.parseDelegate liveUrlHandler:self openGiftFlowerAnchorStore:item.anchorId];
            }
        }break;
        case LiveUrlTypeScheduleList: {
            // TODO:进入预约列表
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openScheduleList:)]) {
                [self.parseDelegate liveUrlHandler:self openScheduleList:item.scheduleListType];
            }
        }break;
        case LiveUrlTypeScheduleDetail: {
            // TODO:进入指定预约详情
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openScheduleDetail:refId:anchorId:)]) {
                [self.parseDelegate liveUrlHandler:self openScheduleDetail:item.inviteId refId:item.refId anchorId:item.anchorId];
            }
        }break;
        case LiveUrlTypeScheduleMailDetail: {
            // TODO:进入指定信件预约详情
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openScheduleMailDetail:anchorName:type:)]) {
                [self.parseDelegate liveUrlHandler:self openScheduleMailDetail:item.loiId anchorName:item.anchorName type:item.mailScheduelDetailType];
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
            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openHangout:inviteAnchorId:inviteAnchorName:recommendAnchorId:recommendAnchorName:)]) {
                [self.parseDelegate liveUrlHandler:self openHangout:item.roomId inviteAnchorId:item.anchorId inviteAnchorName:item.anchorName recommendAnchorId:item.recommendAnchorId recommendAnchorName:item.recommendAnchorName];
            }
        }break;
            
        default:{
            if (item.roomId.length > 0) {
                if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openPrivateLive:anchorName:anchorId:roomType:)]) {
                    [self.parseDelegate liveUrlHandler:self openPrivateLive:item.roomId anchorName:item.anchorName anchorId:item.anchorId roomType:LiveRoomType_Private];
                }
            } else {
                switch (item.roomType) {
                    case LiveUrlRoomTypePublic: {
                        if (item.liveShowId.length > 0) {
                            // 进入节目
                            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openShow:anchorName:anchorId:roomType:)]) {
                                [self.parseDelegate liveUrlHandler:self openShow:item.liveShowId anchorName:item.anchorName anchorId:item.anchorId roomType:LiveRoomType_Public];
                            }
                        } else {
                            // 进入公开直播间
                            if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openPreLive:anchorName:anchorId:roomType:)]) {
                                [self.parseDelegate liveUrlHandler:self openPreLive:item.roomId anchorName:item.anchorName anchorId:item.anchorId roomType:LiveRoomType_Public];
                            }
                        }
                    } break;
                    case LiveUrlRoomTypePrivate:
                    case LiveUrlRoomTypePrivateInvite: {
                        // 主动邀请
                        if ([self.parseDelegate respondsToSelector:@selector(liveUrlHandler:openPreLive:anchorName:anchorId:roomType:)]) {
                            [self.parseDelegate liveUrlHandler:self openPreLive:item.roomId anchorName:item.anchorName anchorId:item.anchorId roomType:LiveRoomType_Private];
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
- (NSURL *)createUrlToHangoutByRoomId:(NSString *)roomId inviteAnchorId:(NSString *)inviteAnchorId inviteAnchorName:(NSString *)inviteAnchorName recommendAnchorId:(NSString *)recommendAnchorId recommendAnchorName:(NSString *)recommendAnchorName {
    int roomTypeInt = 4;
    NSString *codeRoomId = roomId.length > 0 ? roomId : @"";
    NSString *codeInviteAnchorId = inviteAnchorId.length > 0 ? inviteAnchorId : @"";
    NSString *codeInviteAnchorName = inviteAnchorName.length > 0 ? inviteAnchorName : @"";
    NSString *codeRecommendAnchorId = recommendAnchorId.length > 0 ? recommendAnchorId : @"";
    NSString *codeRecommendAnchorName = recommendAnchorName.length > 0 ? recommendAnchorName : @"";
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=hangout&&roomid=%@&anchorid=%@&anchorname=%@&recommendAnchorId=%@&recommendAnchorName=%@&roomtype=%d", codeRoomId, codeInviteAnchorId, [self encodeParameter:codeInviteAnchorName], codeRecommendAnchorId, [self encodeParameter:codeRecommendAnchorName], roomTypeInt];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToInviteByRoomId:(NSString *)roomId anchorName:(NSString *)anchorName anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    int roomTypeInt = 0;
    if (roomType == LiveRoomType_Private) {
        roomTypeInt = 1;
    }

    NSString *codeRoomId = roomId.length > 0 ? roomId : @"";
    NSString *codeAnchorId = anchorId.length > 0 ? anchorId : @"";
    NSString *codeAnchorName = anchorName.length > 0 ? anchorName : @"";
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&roomid=%@&anchorid=%@&anchorname=%@&roomtype=%d", codeRoomId, codeAnchorId,[self encodeParameter:codeAnchorName],roomTypeInt];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToShowRoomId:(NSString *)roomId anchorName:(NSString *)anchorName anchorId:(NSString *)anchorId {
    NSString *codeRoomId = roomId.length > 0 ? roomId : @"";
    NSString *codeAnchorId = anchorId.length > 0 ? anchorId : @"";
    NSString *codeAnchorName = anchorName.length > 0 ? anchorName : @"";
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&liveshowid=%@&anchorname=%@&anchorid=%@&roomtype=0", codeRoomId,[self encodeParameter:codeAnchorName], codeAnchorId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToInviteByInviteId:(NSString *)inviteId anchorId:(NSString *)anchorId anchorName:(NSString *)anchorName {
    NSString *codeInviteId = inviteId.length > 0 ? inviteId : @"";
    NSString *codeAnchorId = anchorId.length > 0 ? anchorId : @"";
    NSString *codeAnchorName = anchorName.length > 0 ? anchorName : @"";
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&invitationid=%@&anchorid=%@&anchorname=%@&roomtype=%d", codeInviteId, codeAnchorId, [self encodeParameter:codeAnchorName], 3];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToAnchorDetail:(NSString *)anchorId {
    NSString *codeAnchorId = anchorId.length > 0 ? anchorId : @"";
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=anchordetail&anchorid=%@", codeAnchorId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createUrlToHomePage:(LiveUrlMainListType)type {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=main&listtype=%d", [LSUrlParmItem mainListIndexWithType:type]];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSString *)encodeParameter:(NSString *)originalPara {
//    CFStringRef encodeParaCf = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)originalPara, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
//    NSString *encodePara = (__bridge NSString *)(encodeParaCf);

//    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"] invertedSet];
//    NSString *encodePara = [originalPara stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    
    // 如果字符串中含有字符集里面的字符将不会被编码,参数需全加密,因此参数加密不需要过滤字符集,
    NSCharacterSet *encodeUrlSet = [[NSCharacterSet alloc] init];
    NSString *encodePara = [originalPara stringByAddingPercentEncodingWithAllowedCharacters:encodeUrlSet];
    
//    CFRelease(encodeParaCf);
    return encodePara;
}

- (NSURL *)createSendmailByanchorId:(NSString *)anchorId anchorName:(NSString *)anchorName emfiId:(NSString *)emfId {
    NSString *codeAnchorId = anchorId.length > 0 ? anchorId : @"";
    NSString *codeAnchorName = anchorName.length > 0 ? anchorName : @"";
    NSString *codeEmfId = emfId.length > 0 ? emfId : @"";
    NSString *encodeName = [self encodeParameter:codeAnchorName];
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=sendmail&anchorid=%@&anchorname=%@&emf_id=%@", codeAnchorId, encodeName,codeEmfId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createLiveChatByanchorId:(NSString *)anchorId anchorName:(NSString *)anchorName {
    NSString *codeAnchorId = anchorId.length > 0 ? anchorId : @"";
    NSString *codeAnchorName = anchorName.length > 0 ? anchorName : @"";
    NSString * urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?site=41&service=live&module=livechat&anchorid=%@&anchorname=%@",codeAnchorId,[self encodeParameter:codeAnchorName]];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createOpenSayHiList:(LiveUrlSayHiListType)type {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=sayhi_list&listtype=%d",type];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createSendSayhiByAnchorId:(NSString *)anchorId anchorName:(NSString *)anchorName {
    NSString *codeAnchorId = anchorId.length > 0 ? anchorId : @"";
    NSString *codeAnchorName = anchorName.length > 0 ? anchorName : @"";
    NSString *encodeName = [self encodeParameter:codeAnchorName];
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=sendsayhi&anchorid=%@&anchorname=%@",codeAnchorId,encodeName];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createSayHiDetailBySayhiId:(NSString *)sayhiId {
    NSString *codeSayhiId = sayhiId.length > 0 ? sayhiId : @"";
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=sayhi_detail&sayhiid=%@",codeSayhiId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createFlowerGightByAnchorId:(NSString *)anchorId {
    NSString *codeAnchorId = anchorId.length > 0 ? anchorId : @"";
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=giftflower_anchor_store&anchorid=%@",codeAnchorId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}


- (NSURL *)createFlowerStore:(LiveUrlGiftFlowerListType)type {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=giftflower_list&listtype=%d",type];;
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createScheduleList:(LiveUrlScheduleListType)type {
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=schedule_list&listtype=%d",type];;
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}


- (NSURL *)createScheduleMailDetail:(NSString *)mailId anchorName:(NSString *)anchorName type:(LiveUrlScheduleMailDetailType)type{
    NSString *codeMailId = mailId.length > 0 ? mailId : @"";
    NSString *codeAnchorName = anchorName.length > 0 ? anchorName : @"";
    NSString *encodeName = [self encodeParameter:codeAnchorName];
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=schedulemaildetail&loi_id=%@&anchorName=%@&listtype=%d",codeMailId,encodeName,type];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)createScheduleDetail:(NSString *)inviteId anchorId:(NSString *)anchorId refId:(NSString *)refId{
    NSString *codeInviteId = inviteId.length > 0 ? inviteId : @"";
    NSString *codeAnchorId = anchorId.length > 0 ? anchorId : @"";
      NSString *codeRefId = refId.length > 0 ? refId : @"";
    NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=scheduledetail&invitationid=%@&anchorid=%@&refid=%@",codeInviteId,codeAnchorId,codeRefId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}


- (NSURL *)createBuyCredit {
    NSString *urlString = @"qpidnetwork://app/open?service=live&module=buycredit";
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}
@end
