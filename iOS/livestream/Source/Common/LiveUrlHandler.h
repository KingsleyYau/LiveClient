//
//  LiveUrlHandler.h
//  livestream
//
//  Created by test on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSUrlParmItem.h"
#import "LiveRoom.h"

typedef enum {
    LiveUrlTypeNone = 0,
    LiveUrlTypeMain,
    LiveUrlTypeDetail,
    LiveUrlTypeLiveroom,
    LiveUrlTypeInvite,
    LiveUrlTypeInvited,
    LiveUrlTypeBooking,
    LiveUrlTypeBookingList,
    LiveUrlTypeBackpackList,
    LiveUrlTypeBuyCredit,
    LiveUrlTypeMyLevel,
    LiveUrlTypeChatlist,
    LiveUrlTypeChat,
    LiveUrlTypeGreetmaillist,
    LiveUrlTypeMaillist
} LiveUrlType;



typedef enum {
    BookingListUrlTypeWaitUser,
    BookingListUrlTypeWaitAnchor,
    BookingListUrlTypeConfirm,
    BookingListUrlTypeHistory
} BookingListUrlType;

typedef enum {
    BackPackListUrlTypePostStamp,
    BackPackListUrlTypeVoucher,
    BackPackListUrlTypePresent,
    BackPackListUrlTypeDrive
} BackPackListUrlType;

typedef enum {
    MainListTypeHot = 1,
    MainListTypeFollow,
    MainListTypeCalendar
} MainListType;

typedef enum {
    UrlRoomTypePublic = 0,
    UrlRoomTypePrivate,
} UrlRoomType;

@class LiveUrlHandler;
@protocol LiveUrlHandlerDelegate <NSObject>
@optional

/**
 主动邀请处理器

 @param handler 处理器
 @param roomId 直播间Id
 @param userId 主播Id
 @param roomType 直播间类型
 */
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openPreLive:(NSString *_Nullable)roomId userId:(NSString *_Nullable)userId roomType:(LiveRoomType)roomType;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openPublicLive:(NSString *_Nullable)roomId userId:(NSString *_Nullable)userId roomType:(LiveRoomType)roomType;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openShow:(NSString *_Nullable)showId userId:(NSString *_Nullable)userId roomType:(LiveRoomType)roomType;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openInvited:(NSString *_Nullable)userName userId:(NSString *_Nullable)userId inviteId:(NSString *_Nullable)inviteId;
//- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openMainType:(int)index isForTest:(BOOL)forTest;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openMainType:(int)index;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openAnchorDetail:(NSString *_Nullable)anchorId;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openBooking:(NSString *_Nullable)anchorId userName:(NSString * _Nullable)userName;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openBookingList:(int)bookType;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openBackpackList:(int)BackpackType;
- (void)liveUrlHandlerOpenAddCredit:(LiveUrlHandler *_Nonnull)handler;
- (void)liveUrlHandlerOpenMyLevel:(LiveUrlHandler *_Nonnull)handler;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openWithModule:(LiveUrlType)type;
- (void)liveUrlHandlerActive:(LiveUrlHandler *_Nonnull)handler openWithModule:(LiveUrlType)type;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler OpenHangout:(NSString *_Nullable)roomId anchorId:(NSString *_Nullable)anchorId nickName:(NSString *_Nullable)nickName;
- (void)liveUrlHandlerOpenChatlist:(LiveUrlHandler *_Nonnull)handler;
- (void)liveUrlHandlerOpenGreetmaillist:(LiveUrlHandler *_Nonnull)handler;
- (void)liveUrlHandlerOpenMaillist:(LiveUrlHandler *_Nonnull)handler;
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openChatWithAnchor:(NSString *_Nullable)anchorId;
@end

@interface LiveUrlHandler : NSObject
/**
 委托
 */
@property (weak) id<LiveUrlHandlerDelegate> _Nullable delegate;

/**
 当前调用类型
 */
@property (assign, readonly) LiveUrlType type;

/** 主页类型 */
@property (nonatomic, assign) MainListType mainTpye;
/** 预约类型 */
@property (nonatomic, assign) BookingListUrlType bookType;
/** 背包类型 */
@property (nonatomic, assign) BackPackListUrlType backPackType;
/** 房间类型 */
@property (nonatomic, assign) UrlRoomType roomType;

/**
 设置需要处理的链接
 */
@property (strong) NSURL *_Nullable url;

/**
 获取实例

 @return 实例
 */
+ (instancetype _Nonnull)shareInstance;

/**
 解析调用过来的URL
 
 @return 处理结果[YES:成功/NO:失败]
 */
- (BOOL)handleOpenURL;

#pragma mark - 获取模块URL
- (NSURL * _Nonnull)createUrlToHangoutByRoomId:(NSString * _Nullable)roomId anchorId:(NSString * _Nullable)anchorId nickName:(NSString *_Nullable)nickName;

- (NSURL * _Nonnull)createUrlToInviteByRoomId:(NSString * _Nullable)roomId userId:(NSString * _Nullable)userId roomType:(LiveRoomType)roomType;

- (NSURL * _Nonnull)createUrlToShowRoomId:(NSString * _Nonnull)roomId userId:(NSString * _Nullable)userId;

- (NSURL * _Nonnull)createUrlToInviteByInviteId:(NSString * _Nullable)inviteId anchorId:(NSString * _Nullable)anchorId nickName:(NSString * _Nullable)nickName;

- (NSURL * _Nonnull)createUrlToLookLadyAnchorId:(NSString * _Nullable)anchorId;

- (NSURL * _Nonnull)createUrlToHomePage:(int)index;
#pragma mark - 解析URL
- (LSUrlParmItem * _Nullable)parseUrlParms:(NSURL * _Nullable)url ;

@end
