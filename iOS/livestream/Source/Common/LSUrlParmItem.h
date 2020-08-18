//
//  LSUrlParmItem.h
//  livestream
//
//  Created by randy on 2017/11/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveRoom.h"

typedef enum {
    LiveUrlTypeMain,
    LiveUrlTypeDetail,
    LiveUrlTypeLiveRoom,
    LiveUrlTypeBooking,
    LiveUrlTypeBookingList,
    LiveUrlTypeBackpackList,
    LiveUrlTypeBuyCredit,
    LiveUrlTypeMyLevel,
    LiveUrlTypeChatList,
    LiveUrlTypeChat,
    LiveUrlTypeGreetMailList,
    LiveUrlTypeMailList,
    LiveUrlTypeDialog,
    LiveUrlTypeLiveChat,
    LiveUrlTypeLiveChatList,
    LiveUrlTypeSendMail,
    LiveUrlTypeHangoutDialog,
    LiveUrlTypeHangout,
    LiveUrlTypeSayHiList,
    LiveUrlTypeSayHiDetail,
    LiveUrlTypeSendSayHi,
    LiveUrlTypeGreetMailDetail,
    LiveUrlTypeGiftFlowerList,
    LiveUrlTypeGiftFlowerAnchorStore,
    LiveUrlTypeScheduleList,
    LiveUrlTypeScheduleMailDetail,
    LiveUrlTypeScheduleDetail,
    LiveUrlTypeSendScheduleMail,
    LiveUrlTypePremiumVideoList,
    LiveUrlTypePremiumVideoDetail,
    LiveUrlTypeUnknow,
} LiveUrlType;

typedef enum {
    LiveUrlMainListTypeHot = 1,
    LiveUrlMainListUrlTypeFollow = 2,
    LiveUrlMainListUrlTypeCalendar = 3,
    LiveUrlMainListUrlTypeHangout = 4,
    LiveUrlMainListTypeUnknow,
} LiveUrlMainListType;

typedef enum {
    LiveUrlRoomTypePublic = 0,
    LiveUrlRoomTypePrivate = 1,
    LiveUrlRoomTypePrivateInvite = 2,
    LiveUrlRoomTypePrivateAccept = 3,
    LiveUrlRoomTypeHangOut = 4,
    LiveUrlRoomTypeUnknow,
} LiveUrlRoomType;

typedef enum {
    LiveUrlBookingListTypeWaitUser = 1,
    LiveUrlBookingListTypeWaitAnchor,
    LiveUrlBookingListTypeConfirm,
    LiveUrlBookingListTypeHistory,
    LiveUrlBookingListTypeUnknow,
} LiveUrlBookingListType;

typedef enum {
    LiveUrlBackPackListTypePresent = 1,
    LiveUrlBackPackListTypeVoucher,
    LiveUrlBackPackListTypeDrive,
    LiveUrlBackPackListTypePostStamp,
    LiveUrlBackPackListTypeUnknow,
} LiveUrlBackpackListType;

typedef enum {
    LiveUrlSayHiListTypeAll = 1,
    LiveUrlSayHiListTypeResponse,
    LiveUrlSayHiListTypeUnknown,
} LiveUrlSayHiListType;

typedef enum {
    LiveUrlGiftFlowerListTypeStore = 1,
    LiveUrlGiftFlowerListTypeDelivery,
    LiveUrlGiftFlowerListTypeUnknow,
} LiveUrlGiftFlowerListType;

typedef enum {
    LiveUrlScheduleListTypePending = 1,
    LiveUrlScheduleListTypeConfirm,
    LiveUrlScheduleListTypeDeceline,
    LiveUrlScheduleListTypeExpired,
    LiveUrlScheduleListTypeUnknow,
} LiveUrlScheduleListType;


typedef enum {
    LiveUrlScheduleMailDetailTypeInbox = 1,
    LiveUrlScheduleMailDetailTypeOutBox,
    LiveUrlScheduleMailDetailTypeUnknow,
} LiveUrlScheduleMailDetailType;
@interface LSUrlParmItem : NSObject
/**
 根据URL生成实例

 @param url 原始URL
 @return 实例
 */
+ (instancetype)urlItemWithUrl:(NSURL *)url;

#pragma mark - 模块参数
/**
 模块类型
 */
@property (assign, readonly) LiveUrlType type;

#pragma mark - 公共参数
/**
 主播Id
 */
@property (strong, readonly) NSString *anchorId;
/**
 主播名称
 */
@property (strong, readonly) NSString *anchorName;
/**
多人互动邀请 推荐主播Id
*/
@property (strong, readonly) NSString *recommendAnchorId;
/**
多人互动邀请 推荐主播名称
*/
@property (strong, readonly) NSString *recommendAnchorName;

#pragma mark - 主界面参数
/**
 主界面列表类型
 */
@property (assign, readonly) LiveUrlMainListType mainListType;

#pragma mark - 直播间参数
/**
 直播间Id
 */
@property (strong, readonly) NSString *roomId;
/**
 直播间类型
 */
@property (assign, readonly) LiveUrlRoomType roomType;
/**
 邀请Id
 */
@property (strong, readonly) NSString *inviteId;

#pragma mark - 预约列表参数
/**
 预约列表类型
 */
@property (assign, readonly) LiveUrlBookingListType bookingListType;
/**
 预约详情类型
 */
@property (assign, readonly) LiveUrlScheduleMailDetailType mailScheduelDetailType;

#pragma mark - 背包列表参数
/**
 背包列表类型
 */
@property (assign, readonly) LiveUrlBackpackListType backpackListType;

#pragma mark - 背包列表参数
/**
 sayhi列表类型
 */
@property (assign, readonly) LiveUrlSayHiListType sayHiListType;
#pragma mark - 节目参数
/**
 节目Id
 */
@property (strong, readonly) NSString *liveShowId;
#pragma mark - sayhi参数
/**
 sayId
 */
@property (strong, readonly) NSString *sayhiId;
#pragma mark - 鲜花礼品参数
/**
  鲜花礼品类型
 */
@property (assign, readonly) LiveUrlGiftFlowerListType flowerListType;
#pragma mark - 意向信参数
/**
 意向信id   Or  信件id Or 预约详情id
 */
@property (strong, readonly) NSString *loiId;
@property (strong, readonly) NSString *refId;
@property (strong, readonly) NSString *emfId;
#pragma mark - 对话框参数
@property (strong, readonly) NSString *title;
@property (strong, readonly) NSString *msg;
@property (strong, readonly) NSString *yesTitle;
@property (strong, readonly) NSString *noTitle;
@property (strong, readonly) NSString *yesUrl;

#pragma mark - 链接参数
@property (strong, readonly) NSString *opentype;
@property (strong, readonly) NSString *apptitle;
@property (strong, readonly) NSString *gascreen;
@property (strong, readonly) NSString *styletype;
@property (strong, readonly) NSString *resumecb;

#pragma mark - 链接参数
@property (strong, readonly) NSString *inviteMsg;
@property (copy, readonly) NSString *sourceSite;

#pragma mark - 预约列表参数
/**
  预约列表类型
 */
@property (assign, readonly) LiveUrlScheduleListType scheduleListType;

#pragma mark - 付费视频参数
@property (copy, readonly) NSString *videoId;
#pragma mark - 协议解析
+ (int)mainListIndexWithType:(LiveUrlMainListType)type;

@end
