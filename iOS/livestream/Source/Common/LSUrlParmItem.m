//
//  LSUrlParmItem.m
//  livestream
//
//  Created by randy on 2017/11/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSUrlParmItem.h"

@implementation LSUrlParmItem
+ (instancetype)urlItemWithUrl:(NSURL *)url {
    LSUrlParmItem *item = [[LSUrlParmItem alloc] initWithUrl:url];
    return item;
}

- (id)initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        // 重置参数
        [self reset];
        
        // 模块类型
        _type = [self getTypeFromUrl:url];

        // 公共参数
        _anchorId = [LSURLQueryParam urlParamForKey:@"anchorid" url:url];
        _anchorName = [LSURLQueryParam urlParamForKey:@"anchorname" url:url];
        _hangoutAnchorId = [LSURLQueryParam urlParamForKey:@"hangoutAnchorId" url:url];
        _hangoutAnchorName = [LSURLQueryParam urlParamForKey:@"hangoutAnchorName" url:url];
        
        // Webview属性参数
        _opentype = [LSURLQueryParam urlParamForKey:@"opentype" url:url];
        _apptitle = [LSURLQueryParam urlParamForKey:@"apptitle" url:url];
        _gascreen = [LSURLQueryParam urlParamForKey:@"gascreen" url:url];
        _styletype = [LSURLQueryParam urlParamForKey:@"styletype" url:url];
        _resumecb = [LSURLQueryParam urlParamForKey:@"resumecb" url:url];
        _liveShowId = [LSURLQueryParam urlParamForKey:@"liveshowid" url:url];
        switch (_type) {
            case LiveUrlTypeMain: {
                // TODO:主界面
                NSString *listTypeString = [LSURLQueryParam urlParamForKey:@"listtype" url:url];
                if( [listTypeString intValue] >= LiveUrlMainListTypeHot && [listTypeString intValue] < LiveUrlMainListTypeUnknow ) {
                    _mainListType = [listTypeString intValue];
                }

            } break;
            case LiveUrlTypeDetail: {
                // TODO:个人详情
            } break;
            case LiveUrlTypeLiveRoom: {
                // TODO:直播间
                _roomId = [LSURLQueryParam urlParamForKey:@"roomid" url:url];
                
                NSString *roomTypeString = [LSURLQueryParam urlParamForKey:@"roomtype" url:url];
                if( [roomTypeString intValue] >= LiveUrlRoomTypePublic && [roomTypeString intValue] < LiveUrlRoomTypeUnknow ) {
                    _roomType = [roomTypeString intValue];
                }
                
                _inviteId = [LSURLQueryParam urlParamForKey:@"invitationid" url:url];
                
            } break;
            case LiveUrlTypeBooking: {
                // TODO:新建预约
            } break;
            case LiveUrlTypeBookingList: {
                // TODO:预约列表
                NSString *listTypeString = [LSURLQueryParam urlParamForKey:@"listtype" url:url];
                if( [listTypeString intValue] >= LiveUrlBookingListTypeWaitUser && [listTypeString intValue] < LiveUrlBookingListTypeUnknow ) {
                    _bookingListType = [listTypeString intValue];
                }
                
            } break;
            case LiveUrlTypeBackpackList: {
                // TODO:背包列表
                NSString *listTypeString = [LSURLQueryParam urlParamForKey:@"listtype" url:url];
                if( [listTypeString intValue] >= LiveUrlBackPackListTypePresent && [listTypeString intValue] < LiveUrlBackPackListTypeUnknow ) {
                    _backpackListType = [listTypeString intValue];
                }
            } break;
            case LiveUrlTypeBuyCredit: {
                // TODO:充值
            } break;
            case LiveUrlTypeMyLevel: {
                // TODO:我的等级
            } break;
            case LiveUrlTypeChatList: {
                // TODO:聊天列表
            } break;
            case LiveUrlTypeChat: {
                // TODO:聊天界面
            } break;
            case LiveUrlTypeGreetMailList: {
                // TODO:意向信列表
            } break;
            case LiveUrlTypeMailList: {
                // TODO:信件列表
            } break;
            case LiveUrlTypeDialog: {
                // TODO:弹出对话框
                _title = [LSURLQueryParam urlParamForKey:@"title" url:url];
                _msg = [LSURLQueryParam urlParamForKey:@"msg" url:url];
                _yesTitle = [LSURLQueryParam urlParamForKey:@"yes_title" url:url];
                _noTitle = [LSURLQueryParam urlParamForKey:@"no_title" url:url];
                _yesUrl = [LSURLQueryParam urlParamForKey:@"yes_url" url:url];
            } break;
            case LiveUrlTypeLiveChat:{
                // TODO:联系人
            }break;
            case LiveUrlTypeLiveChatList: {
                // TODO:联系人列表
                
            }break;
            case LiveUrlTypeSendMail:{
                // TODO:发送意向信
            }break;
            case LiveUrlTypeHangoutDialog: {
                // TODO:多人直播间弹窗
            }break;
            case LiveUrlTypeHangout: {
                // TODO:多人直播间
            }break;
            case LiveUrlTypeSendSayHi: {
                // TODO:进入发送SayHi界面
            }break;
            case LiveUrlTypeSayHiList:{
                // TODO:进入SayHi的列表
                NSString *listTypeString = [LSURLQueryParam urlParamForKey:@"listtype" url:url];
                if( [listTypeString intValue] >= LiveUrlSayHiListTypeAll && [listTypeString intValue] < LiveUrlSayHiListTypeUnknown ) {
                    _sayHiListType = [listTypeString intValue];
                }
            }break;
            case LiveUrlTypeSayHiDetail:{
                // TODO:进入SayHi详情界面
                  _sayhiId = [LSURLQueryParam urlParamForKey:@"sayhiid" url:url];
            }break;
            default: {
            } break;
        }
    }
    return self;
}

#pragma mark - 协议解析
+ (int)mainListIndexWithType:(LiveUrlMainListType)type {
    int index = 0;
    switch (type) {
        case LiveUrlMainListTypeHot:{
            index = 1;
        }break;
        case LiveUrlMainListUrlTypeFollow:{
            index = 2;
        }break;
        case LiveUrlMainListUrlTypeCalendar:{
            index = 3;
        }break;
        case LiveUrlMainListUrlTypeHangout: {
            index = 4;
        }break;
        default:
            break;
    }
    return index;
}

#pragma mark - 私有方法
- (void)reset {
    _type = LiveUrlTypeUnknow;
    _mainListType = LiveUrlMainListTypeUnknow;
    _roomType = LiveUrlRoomTypeUnknow;
    _bookingListType = LiveUrlBookingListTypeUnknow;
    _backpackListType = LiveUrlBackPackListTypeUnknow;
    
    _anchorId = @"";
    _anchorName = @"";
    
}

- (LiveUrlType)getTypeFromUrl:(NSURL *)url {
    NSString *moduleString = [LSURLQueryParam urlParamForKey:@"module" url:url];

    LiveUrlType type = LiveUrlTypeMain;
    if ([moduleString isEqualToString:@"main"]) {
        type = LiveUrlTypeMain;
    } else if ([moduleString isEqualToString:@"anchordetail"]) {
        type = LiveUrlTypeDetail;
    } else if ([moduleString isEqualToString:@"liveroom"]) {
        type = LiveUrlTypeLiveRoom;
    } else if ([moduleString isEqualToString:@"newbooking"]) {
        type = LiveUrlTypeBooking;
    } else if ([moduleString isEqualToString:@"bookinglist"]) {
        type = LiveUrlTypeBookingList;
    } else if ([moduleString isEqualToString:@"backpacklist"]) {
        type = LiveUrlTypeBackpackList;
    } else if ([moduleString isEqualToString:@"buycredit"]) {
        type = LiveUrlTypeBuyCredit;
    } else if ([moduleString isEqualToString:@"mylevel"]) {
        type = LiveUrlTypeMyLevel;
    } else if ([moduleString isEqualToString:@"chatlist"]) {
        type = LiveUrlTypeChatList;
    } else if ([moduleString isEqualToString:@"chat"]) {
        type = LiveUrlTypeChat;
    } else if ([moduleString isEqualToString:@"greetmaillist"]) {
        type = LiveUrlTypeGreetMailList;
    } else if ([moduleString isEqualToString:@"maillist"]) {
        type = LiveUrlTypeMailList;
    } else if ([moduleString isEqualToString:@"popyesnodialog"]) {
        type = LiveUrlTypeDialog;
    } else if ([moduleString isEqualToString:@"livechat"]) {
        type = LiveUrlTypeLiveChat;
    } else if ([moduleString isEqualToString:@"livechatlist"]) {
        type = LiveUrlTypeLiveChatList;
    }else if([moduleString isEqualToString:@"sendmail"]) {
        type = LiveUrlTypeSendMail;
    }else if ([moduleString isEqualToString:@"hangout_dialog"]) {
        type = LiveUrlTypeHangoutDialog;
    }else if ([moduleString isEqualToString:@"hangout"]) {
        type = LiveUrlTypeHangout;
    }else if ([moduleString isEqualToString:@"sayhi_list"]) {
        type = LiveUrlTypeSayHiList;
    }else if ([moduleString isEqualToString:@"sendsayhi"]) {
        type = LiveUrlTypeSendSayHi;
    }else if ([moduleString isEqualToString:@"sayhi_detail"]) {
        type = LiveUrlTypeSayHiDetail;
    }
    
    return type;
}

@end
