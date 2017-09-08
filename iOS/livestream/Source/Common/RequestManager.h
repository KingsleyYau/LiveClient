//
//  RequestManager.h
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LoginItemObject.h"
#import "ViewerFansItemObject.h"
#import "LiveRoomInfoItemObject.h"
#import "LiveRoomPersonalInfoItemObject.h"
#import "CoverPhotoItemObject.h"
#import "GiftInfoItemObject.h"
#import "LiveRoomConfigItemObject.h"
#import "FollowItemObject.h"
#import "RoomInfoItemObject.h"
#import "EmoticonItemObject.h"
#import "BookingPrivateInviteListObject.h"
#import "BookingUnreadUnhandleNumItemObject.h"
#import "BackGiftItemObject.h"
#import "ConfigItemObject.h"
#import "GiftWithIdItemObject.h"
#import "GetTalentItemObject.h"
#import "GetTalentStatusItemObject.h"
#import "GetNewFansBaseInfoItemObject.h"
#import "GetCreateBookingInfoItemObject.h"
#import "VoucherItemObject.h"
#import "RideItemObject.h"
#import "GetBackPackUnreadNumItemObject.h"

#include <httpcontroller/HttpRequestEnum.h>

@interface RequestManager : NSObject

/**
 版本号
 */
@property (nonatomic, strong) NSString* _Nonnull versionCode;

/**
 无效的请求号
 */
@property (nonatomic, readonly) NSInteger invalidRequestId;

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

#pragma mark - 公共模块
/**
 *  设置是否打印日志
 *
 *  @param enable <#enable description#>
 */
+ (void)setLogEnable:(BOOL)enable;
/**
 *  设置接口目录
 *
 *  @param directory 可写入目录
 */
+ (void)setLogDirectory:(NSString * _Nonnull)directory;
/**
 *  设置接口服务器域名
 *
 *  @param webSite 服务器域名
 */
- (void)setWebSite:(NSString * _Nonnull)webSite;
/**
 *  设置接口服务器用户认证
 *
 *  @param user     用户名
 *  @param password 密码
 */
- (void)setAuthorization:(NSString * _Nonnull)user password:(NSString * _Nonnull)password;

/**
 *  清除Cookies
 */
- (void)cleanCookies;

/**
 *  根据域名获取Cookies
 *
 *  @param site 域名
 */
- (void)getCookies:(NSString * _Nonnull)site;

/**
 *  停止请求接口
 *
 *  @param request 请求
 */
- (void)stopRequest:(NSInteger)request;

/**
 *  停止所有请求接口
 *
 */
- (void)stopAllRequest;

/**
 *  获取设备Id
 *
 *  @return 设备Id
 */
- (NSString * _Nonnull)getDeviceId;

#pragma mark - 登陆认证模块

/**
 *  2.1.验证手机是否已注册接口回调
 *
 *  @param success        成功失败
 *  @param errnum         错误码
 *  @param errmsg         错误提示
 *  @param isRegistered   是否已注册
 */
typedef void (^RegisterCheckPhoneFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, int isRegistered);



/**
 *  2.1.登陆接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^LoginFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, LoginItemObject * _Nonnull item);

/**
 *  2.1.登陆接口
 *
 * @param qnsid			    QN系统登录验证返回的标识
 * @param deviceid		    设备唯一标识
 * @param model				设备型号（格式：设备型号－系统版本号）
 * @param manufacturer		制造厂商
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)login:(NSString * _Nonnull)qnsid
          deviceid:(NSString * _Nonnull)deviceid
             model:(NSString * _Nonnull)model
      manufacturer:(NSString * _Nonnull)manufacturer
     finishHandler:(LoginFinishHandler _Nullable)finishHandler;

/**
 *  2.2.注销接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^LogoutFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  2.2.注销接口
 *
 *  @param finishHandler  接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)logout:(LogoutFinishHandler _Nullable)finishHandler;

/**
 *  2.3.上传tokenid接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 */
typedef void (^UpdateTokenIdFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  2.3.上传tokenid接口
 *
 *  @param tokenId			用于Push Notification的ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)updateTokenId:(NSString * _Nonnull)tokenId
                     finishHandler:(UpdateTokenIdFinishHandler _Nullable)finishHandler;

#pragma mark - 直播间模块
/**
 *  3.1.获取Hot列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   热门列表
 */
typedef void (^GetAnchorListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomInfoItemObject *>* _Nullable array);

/**
 *  3.1.获取Hot列表接口
 *
 *  @param start			起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getAnchorList:(int)start
                      step:(int)step
             finishHandler:(GetAnchorListFinishHandler _Nullable)finishHandler;

/**
 *  3.2.获取Hot列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   热门列表
 */
typedef void (^GetFollowListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<FollowItemObject *>* _Nullable array);

/**
 *  3.2.获取Following列表接口
 *
 *  @param start			起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getFollowList:(int)start
                      step:(int)step
             finishHandler:(GetFollowListFinishHandler _Nullable)finishHandler;

/**
 *  3.3.获取本人有效直播间或邀请信息接口回调(已废弃)
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   热门列表
 */
typedef void (^GetRoomInfoFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, RoomInfoItemObject* _Nullable array);

/**
 *  3.3.获取本人有效直播间或邀请信息接口(已废弃)
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getRoomInfo:(GetRoomInfoFinishHandler _Nullable)finishHandler;

/**
 *  3.4.获取直播间观众头像列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   观众列表
 */
typedef void (^LiveFansListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<ViewerFansItemObject *>* _Nullable array);

/**
 *  3.4.获取直播间观众头像列表接口
 *
 *  @param roomId			直播间ID
 *  @param finishHandler    接口回调
 * @param page                          页数（可0， 0则表示获取所有， ）
 * @param number                        每页的元素数量（可0， 0则表示获取所有）
 *
 *  @return 成功请求Id
 */
- (NSInteger)liveFansList:(NSString * _Nonnull)roomId
                     page:(int)page
                   number:(int)number
            finishHandler:(LiveFansListFinishHandler _Nullable)finishHandler;

/**
 *  3.5.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   封面图列表
 */
typedef void (^GetAllGiftListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<GiftInfoItemObject *>* _Nullable array);

/**
 *  3.5.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getAllGiftList:(GetAllGiftListFinishHandler _Nullable)finishHandler;

/**
 *  3.6.获取直播间可发送的礼物列表（观众端/主播端获取直播间的可发送的礼物列表, 包括背包礼物）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   封面图列表
 */
typedef void (^GetGiftListByUserIdFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<GiftWithIdItemObject *>* _Nullable array);

/**
 *  3.6.获取直播间可发送的礼物列表（观众端/主播端获取直播间的可发送的礼物列表, 包括背包礼物）接口
 *
 *  @param roomId           直播间ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getGiftListByUserId:(NSString * _Nonnull)roomId
                   finishHandler:(GetGiftListByUserIdFinishHandler _Nullable)finishHandler;

/**
 *  3.7.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    指定礼物详情
 */
typedef void (^GetGiftDetailFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, GiftInfoItemObject * _Nullable item);

/**
 *  3.7.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）接口
 *
 *  @param giftId           礼物ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getGiftDetail:(NSString * _Nonnull)giftId
                           finishHandler:(GetGiftDetailFinishHandler _Nullable)finishHandler;

/**
 *  3.8.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    指定礼物详情
 */
typedef void (^GetEmoticonListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<EmoticonItemObject*>* _Nullable item);

/**
 *  3.8.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getEmoticonList:(GetEmoticonListFinishHandler _Nullable)finishHandler;

/**
 *  3.9.获取指定立即私密邀请信息接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    邀请信息
 */
typedef void (^GetInviteInfoFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, InviteIdItemObject * _Nonnull item);

/**
 *  3.9.获取指定立即私密邀请信息接口
 *
 *  @param inviteId         邀请ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getInviteInfo:(NSString * _Nonnull)inviteId
             finishHandler:(GetInviteInfoFinishHandler _Nullable)finishHandler;

/**
 *  3.10.获取才艺点播列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   邀请信息
 */
typedef void (^GetTalentListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<GetTalentItemObject*> * _Nonnull array);

/**
 *  3.10.获取才艺点播列表接口
 *
 *  @param roomId           直播间ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getTalentList:(NSString * _Nonnull)roomId
             finishHandler:(GetTalentListFinishHandler _Nullable)finishHandler;

/**
 *  3.11.获取才艺点播邀请状态接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item   邀请信息
 */
typedef void (^GetTalentStatusFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, GetTalentStatusItemObject* _Nonnull item);

/**
 *  3.11.获取才艺点播邀请状态接口
 *
 *  @param roomId           直播间ID
 *  @param talentInviteId   才艺点播邀请ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getTalentStatus:(NSString * _Nonnull)roomId
              talentInviteId:(NSString * _Nonnull)talentInviteId
               finishHandler:(GetTalentStatusFinishHandler _Nullable)finishHandler;

/**
 *  3.12.获取指定观众信息接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item   邀请信息
 */
typedef void (^GetNewFansBaseInfoFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, GetNewFansBaseInfoItemObject* _Nonnull item);

/**
 *  3.12.获取指定观众信息接口
 *
 *  @param userId           观众ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getNewFansBaseInfo:(NSString * _Nonnull)userId
                  finishHandler:(GetNewFansBaseInfoFinishHandler _Nullable)finishHandler;

/**
 *  3.13.观众开始／结束视频互动（废弃）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ControlManPushFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSMutableArray<NSString*>* _Nonnull manPushUrl);

/**
 *  3.13.观众开始／结束视频互动接口（废弃）
 *
 *  @param roomId           观众ID
 *  @param control           观众ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)controlManPush:(NSString * _Nonnull)roomId
                    control:(ControlType)control
                  finishHandler:(ControlManPushFinishHandler _Nullable)finishHandler;

/**
 *  3.14.获取推荐主播列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GetPromoAnchorListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomInfoItemObject *>* _Nullable array);

/**
 *  3.14.获取推荐主播列表接口
 *
 *  @param number           获取推荐个数
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getPromoAnchorList:(int)number
                  finishHandler:(GetPromoAnchorListFinishHandler _Nullable)finishHandler;

#pragma mark - 预约私密

/**
 *  4.1.观众待处理的预约邀请列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    邀请信息
 */
typedef void (^ManHandleBookingListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, BookingPrivateInviteListObject * _Nonnull item);

/**
 *  4.1.观众待处理的预约邀请列表接口
 *
 *  @param type            列表类型（0:等待观众处理 1:等待主播处理 2:已确认 3：历史）
 *  @param start           起始，用于分页，表示从第几个元素开始获取
 *  @param step            步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler   接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)manHandleBookingList:(BookingListType)type
                            start:(int)start
                             step:(int)step
                    finishHandler:(ManHandleBookingListFinishHandler _Nullable)finishHandler;

/**
 *  4.2.观众处理预约邀请接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^HandleBookingFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  4.2.观众处理预约邀请接口
 *
 *  @param inviteId            邀请ID
 *  @param isConfirm           是否同意（0:否 1:是）
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)handleBooking:(NSString * _Nonnull)inviteId
                 isConfirm:(BOOL)isConfirm
             finishHandler:(HandleBookingFinishHandler _Nullable)finishHandler;

/**
 *  4.3.取消预约邀请接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^SendCancelPrivateLiveInviteFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  4.3.取消预约邀请接口
 *
 *  @param invitationId            邀请ID
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)sendCancelPrivateLiveInvite:(NSString * _Nonnull)invitationId
                    finishHandler:(SendCancelPrivateLiveInviteFinishHandler _Nullable)finishHandler;

/**
 *  4.4.获取预约邀请未读或待处理数量接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ManBookingUnreadUnhandleNumFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, BookingUnreadUnhandleNumItemObject * _Nonnull item);

/**
 *  4.4.获取预约邀请未读或待处理数量接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)manBookingUnreadUnhandleNum:(ManBookingUnreadUnhandleNumFinishHandler _Nullable)finishHandler;

/**
 *  4.5.获取新建预约邀请信息接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GetCreateBookingInfoFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, GetCreateBookingInfoItemObject * _Nonnull item);

/**
 *  4.5.获取新建预约邀请信息接口
 *
 *  @param userId               主播ID
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getCreateBookingInfo:(NSString* _Nullable)userId
                    finishHandler:(GetCreateBookingInfoFinishHandler _Nullable)finishHandler;

/**
 *  4.6.新建预约邀请接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^SendBookingRequestFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  4.6.新建预约邀请接口
 *
 *  @param userId               主播ID
 *  @param timeId               预约时间ID
 *  @param bookTime             预约时间
 *  @param giftId               礼物ID
 *  @param giftNum              礼物数量
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)sendBookingRequest:(NSString* _Nullable)userId
                         timeId:(NSString* _Nullable)timeId
                       bookTime:(NSInteger)bookTime
                         giftId:(NSString* _Nullable)giftId
                        giftNum:(int)giftNum
                    finishHandler:(SendBookingRequestFinishHandler _Nullable)finishHandler;

#pragma mark - 背包

/**
 *  5.1.获取背包礼物列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GiftListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<BackGiftItemObject *>* _Nullable array);

/**
 *  5.1.获取背包礼物列表接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)giftList:(GiftListFinishHandler _Nullable)finishHandler;

/**
 *  5.2.获取使用劵列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^VoucherListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<VoucherItemObject *>* _Nullable array);

/**
 *  5.2.获取使用劵列表接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)voucherList:(VoucherListFinishHandler _Nullable)finishHandler;

/**
 *  5.3.获取座驾列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^RideListFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<RideItemObject *>* _Nullable array);

/**
 *  5.3.获取座驾列表接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)rideList:(RideListFinishHandler _Nullable)finishHandler;

/**
 *  5.4.使用／取消座驾接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^SetRideFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  5.4.使用／取消座驾接口
 *
 *  @param finishHandler       接口回调
 *  @param rideId  座驾ID
 *  @return 成功请求Id
 */
- (NSInteger)setRide:(NSString* _Nonnull)rideId
       finishHandler:(SetRideFinishHandler _Nullable)finishHandler;

/**
 *  5.5.获取背包未读数量接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GetBackpackUnreadNumFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, GetBackPackUnreadNumItemObject * _Nonnull item);

/**
 *  5.5.获取背包未读数量接口
 *
 *  @param finishHandler       接口回调
 *  @return 成功请求Id
 */
- (NSInteger)getBackpackUnreadNum:(GetBackpackUnreadNumFinishHandler _Nullable)finishHandler;

#pragma mark - 其它
/**
 *  6.1.同步配置接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GetConfigFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, ConfigItemObject *_Nullable item);

/**
 *  6.1.同步配置接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getConfig:(GetConfigFinishHandler _Nullable)finishHandler;

/**
 *  6.2.获取账号余额接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GetLeftCreditFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, double credit);

/**
 *  6.2.获取账号余额接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLeftCredit:(GetLeftCreditFinishHandler _Nullable)finishHandler;

/**
 *  6.3.添加／取消收藏接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^SetFavoriteFinishHandler)(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg);

/**
 *  6.3.添加／取消收藏接口
 *
 *  @param finishHandler        接口回调
 *  @param roomId               直播间ID（可无，无则表示不在直播间操作）
 *  @param userId               主播ID
 *  @param isFav                是否收藏（0:否 1:是）
 *
 *  @return 成功请求Id
 */
- (NSInteger)setFavorite:(NSString* _Nonnull)userId
                  roomId:(NSString* _Nonnull)roomId
                   isFav:(BOOL)isFav
           finishHandler:(SetFavoriteFinishHandler _Nullable)finishHandler;

@end
