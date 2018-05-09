//
//  LSRequestManager.h
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSLoginItemObject.h"
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
#import "AcceptInstanceInviteItemObject.h"
#import "LSUserInfoItemObject.h"
#import "LSVoucherAvailableInfoItemObject.h"
#import "LSHangoutAnchorItemObject.h"

#import "LSProgramItemObject.h"

#include <httpcontroller/HttpRequestEnum.h>

@interface LSRequestManager : NSObject

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
 设置代理服务器

 @param proxyUrl <#proxyUrl description#>
 */
+ (void)setProxy:(NSString * _Nullable)proxyUrl;

/**
 *  设置同步配置接口服务器域名
 *
 *  @param webSite 服务器域名
 */
- (void)setConfigWebSite:(NSString * _Nonnull)webSite;

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
 *  清除所有Cookies
 */
- (void)cleanCookies;

/**
 获取所有Cookies
 
 @return cookies
 */
- (NSArray<NSHTTPCookie *> * _Nullable)getCookies;

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
typedef void (^RegisterCheckPhoneFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, int isRegistered);



/**
 *  2.1.登陆接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^LoginFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSLoginItemObject * _Nonnull item);

/**
 *  2.1.登陆接口
 * @param manId             QN会员ID
 * @param userSid			QN系统登录验证返回的标识
 * @param deviceid		    设备唯一标识
 * @param model				设备型号（格式：设备型号－系统版本号）
 * @param manufacturer		制造厂商
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)login:(NSString *_Nonnull)manId
           userSid:(NSString *_Nonnull)userSid
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
typedef void (^LogoutFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

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
typedef void (^UpdateTokenIdFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

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
typedef void (^GetAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomInfoItemObject *>* _Nullable array);

/**
 *  3.1.获取Hot列表接口
 *
 *  @param start			起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param hasWatch         是否只获取观众看过的主播（0: 否 1: 是  可无，无则默认为0）
 *  @param isForTest        是否可看到测试主播（0：否，1：是）（整型）（可无，无则默认为0）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getAnchorList:(int)start
                      step:(int)step
                  hasWatch:(BOOL)hasWatch
                 isForTest:(BOOL)isForTest
             finishHandler:(GetAnchorListFinishHandler _Nullable)finishHandler;

/**
 *  3.2.获取Hot列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   热门列表
 */
typedef void (^GetFollowListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<FollowItemObject *>* _Nullable array);

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
typedef void (^GetRoomInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, RoomInfoItemObject* _Nullable array);

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
typedef void (^LiveFansListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<ViewerFansItemObject *>* _Nullable array);

/**
 *  3.4.获取直播间观众头像列表接口
 *
 *  @param roomId                       直播间ID
 *  @param finishHandler                接口回调
 *  @param start                        起始，用于分页，表示从第几个元素开始获取
 *  @param step                         步长，用于分页，表示本次请求获取多少个元素
 *
 *  @return 成功请求Id
 */
- (NSInteger)liveFansList:(NSString * _Nonnull)roomId
                    start:(int)start
                     step:(int)step
            finishHandler:(LiveFansListFinishHandler _Nullable)finishHandler;

/**
 *  3.5.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   封面图列表
 */
typedef void (^GetAllGiftListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<GiftInfoItemObject *>* _Nullable array);

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
typedef void (^GetGiftListByUserIdFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<GiftWithIdItemObject *>* _Nullable array);

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
typedef void (^GetGiftDetailFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, GiftInfoItemObject * _Nullable item);

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
typedef void (^GetEmoticonListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<EmoticonItemObject*>* _Nullable item);

/**
 *  3.8.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getEmoticonList:(GetEmoticonListFinishHandler _Nullable)finishHandler;

/**
 *  3.9.获取指定立即私密邀请信息接口(已废弃)回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    邀请信息
 */
typedef void (^GetInviteInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, InviteIdItemObject * _Nonnull item);

/**
 *  3.9.获取指定立即私密邀请信息接口(已废弃)
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
typedef void (^GetTalentListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<GetTalentItemObject*> * _Nonnull array);

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
typedef void (^GetTalentStatusFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, GetTalentStatusItemObject* _Nonnull item);

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
typedef void (^GetNewFansBaseInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, GetNewFansBaseInfoItemObject* _Nonnull item);

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
typedef void (^ControlManPushFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSMutableArray<NSString*>* _Nonnull manPushUrl);

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
typedef void (^GetPromoAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomInfoItemObject *>* _Nullable array);

/**
 *  3.14.获取推荐主播列表接口
 *
 *  @param number           获取推荐个数
 *  @param type             获取界面的类型（1:直播间 2:主播个人页）
 *  @param userId           当前界面的主播ID，返回结果将不包含当前主播（可无， 无则表示不过滤结果）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getPromoAnchorList:(int)number
                           type:(PromoAnchorType)type
                         userId:(NSString *_Nonnull)userId
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
typedef void (^ManHandleBookingListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, BookingPrivateInviteListObject * _Nonnull item);

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
typedef void (^HandleBookingFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

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
typedef void (^SendCancelPrivateLiveInviteFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

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
typedef void (^ManBookingUnreadUnhandleNumFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, BookingUnreadUnhandleNumItemObject * _Nonnull item);

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
typedef void (^GetCreateBookingInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, GetCreateBookingInfoItemObject * _Nonnull item);

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
typedef void (^SendBookingRequestFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  4.6.新建预约邀请接口
 *
 *  @param userId               主播ID
 *  @param timeId               预约时间ID
 *  @param bookTime             预约时间
 *  @param giftId               礼物ID
 *  @param giftNum              礼物数量
 *  @param needSms              是否需要短信通知（0:否 1:是 ）
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)sendBookingRequest:(NSString* _Nullable)userId
                         timeId:(NSString* _Nullable)timeId
                       bookTime:(NSInteger)bookTime
                         giftId:(NSString* _Nullable)giftId
                        giftNum:(int)giftNum
                        needSms:(BOOL)needSms
                    finishHandler:(SendBookingRequestFinishHandler _Nullable)finishHandler;

/**
 *  4.7.观众处理立即私密邀请接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^AcceptInstanceInviteFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, AcceptInstanceInviteItemObject *   _Nonnull item);

/**
 *  4.7.观众处理立即私密邀请接口
 *
 *  @param inviteId             邀请ID
 *  @param isConfirm            是否同意（0: 否， 1: 是）
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)acceptInstanceInvite:(NSString* _Nullable)inviteId
                        isConfirm:(BOOL)isConfirm
                    finishHandler:(AcceptInstanceInviteFinishHandler _Nullable)finishHandler;

#pragma mark - 背包

/**
 *  5.1.获取背包礼物列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        背包礼物列表
 *  @param totalCount   列表总数
 */
typedef void (^GiftListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<BackGiftItemObject *>* _Nullable array, int totalCount);

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
 *  @param array        使用卷列表
 *  @param totalCount   列表总数
 */
typedef void (^VoucherListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<VoucherItemObject *>* _Nullable array, int totalCount);

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
 *  @param array        座驾列表
 *  @param totalCount   列表总数
 */
typedef void (^RideListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<RideItemObject *>* _Nullable array, int totalCount);

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
typedef void (^SetRideFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

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
typedef void (^GetBackpackUnreadNumFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, GetBackPackUnreadNumItemObject * _Nonnull item);

/**
 *  5.5.获取背包未读数量接口
 *
 *  @param finishHandler       接口回调
 *  @return 成功请求Id
 */
- (NSInteger)getBackpackUnreadNum:(GetBackpackUnreadNumFinishHandler _Nullable)finishHandler;

/**
 *  5.6.获取试用券可用信息接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GetVoucherAvailableInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSVoucherAvailableInfoItemObject * _Nonnull item);

/**
 *  5.6.获取试用券可用信息接口
 *
 *  @param finishHandler       接口回调
 *  @return 成功请求Id
 */
- (NSInteger)getVoucherAvailableInfo:(GetVoucherAvailableInfoFinishHandler _Nullable)finishHandler;

#pragma mark - 其它
/**
 *  6.1.同步配置接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^GetConfigFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ConfigItemObject *_Nullable item);

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
typedef void (^GetLeftCreditFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, double credit);

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
typedef void (^SetFavoriteFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

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

/**
 *  6.4.获取QN广告列表接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 *  @param array    直播间列表
 */
typedef void (^GetAdAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomInfoItemObject *>* _Nullable array);

/**
 *  6.4.获取QN广告列表接口
 *
 *  @param finishHandler        接口回调
 *  @param number               客户段需要获取的数量
 *
 *  @return 成功请求Id
 */
- (NSInteger)getAdAnchorList:(int)number
               finishHandler:(GetAdAnchorListFinishHandler _Nullable)finishHandler;

/**
 *  6.5.关闭QN广告列表接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 */
typedef void (^CloseAdAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  6.5.关闭QN广告列表接口
 *
 
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)closeAdAnchorList:(CloseAdAnchorListFinishHandler _Nullable)finishHandler;


/**
 *  6.6.获取手机验证码接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 */
typedef void (^GetPhoneVerifyCodeFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  6.6.获取手机验证码接口
 *
 *  @param country              国家
 *  @param areaCode             手机区号
 *  @param phoneNo              手机号码
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getPhoneVerifyCode:(NSString* _Nonnull)country
                       areaCode:(NSString* _Nonnull)areaCode
                        phoneNo:(NSString* _Nonnull)phoneNo
                  finishHandler:(GetPhoneVerifyCodeFinishHandler _Nullable)finishHandler;

/**
 *  6.7.提交手机验证码接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 */
typedef void (^SubmitPhoneVerifyCodeFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  6.7.提交手机验证码接口
 *
 *  @param country              国家
 *  @param areaCode             手机区号
 *  @param phoneNo              手机号码
 *  @param verifyCode           验证码
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)submitPhoneVerifyCode:(NSString* _Nonnull)country
                          areaCode:(NSString* _Nonnull)areaCode
                           phoneNo:(NSString* _Nonnull)phoneNo
                        verifyCode:(NSString* _Nonnull)verifyCode
                  finishHandler:(SubmitPhoneVerifyCodeFinishHandler _Nullable)finishHandler;

/**
 *  6.8.提交流媒体服务器测速结果接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 */
typedef void (^ServerSpeedFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  6.8.提交流媒体服务器测速结果接口
 *
 *  @param sid             流媒体服务器ID
 *  @param res             http请求完成时间（毫秒）
 *  @param finishHandler   接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)serverSpeed:(NSString* _Nonnull)sid
                     res:(int)res
           finishHandler:(ServerSpeedFinishHandler _Nullable)finishHandler;

/**
 *  6.9.获取Hot/Following列表头部广告接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 *  @param bannerImg 广告图片url
 *  @param bannerLink 广告点击进入的Web页面url
 *  @param bannerName 广告名称，用于App Webview加载网页时，在Navigation显示的title
 */
typedef void (^BannerFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull bannerImg, NSString * _Nonnull bannerLink, NSString * _Nonnull bannerName);

/**
 *  6.9.获取Hot/Following列表头部广告接口
 *
 *  @param finishHandler   接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)banner:(BannerFinishHandler _Nullable)finishHandler;

/**
 *  6.10.获取主播/观众信息接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param userInfoItem 观众/主播信息
 */
typedef void (^GetUserInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSUserInfoItemObject * _Nullable userInfoItem);

/**
 *  6.10.获取主播/观众信息接口
 *
 *  @param userId           观众ID或主播ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getUserInfo:(NSString * _Nonnull) userId
           finishHandler:(GetUserInfoFinishHandler _Nullable)finishHandler;

/**
 *  8.1.获取可邀请多人互动的主播列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        多人互动的主播列表
 */
typedef void (^GetCanHangoutAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LSHangoutAnchorItemObject *>* _Nullable array);

/**
 *  8.1.获取可邀请多人互动的主播列表接口
 *
 *  @param type             列表类型（HANGOUTANCHORLISTTYPE_FOLLOW：已关注，HANGOUTANCHORLISTTYPE_WATCHED：Watched，HANGOUTANCHORLISTTYPE_FRIEND：主播好友）
 *  @param anchorId         主播ID（可无，仅当type=3才存在）
 *  @param start            起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getCanHangoutAnchorList:(HangoutAnchorListType)type
                            anchorId:(NSString *_Nullable)anchorId
                               start:(int)start
                                step:(int)step
                       finishHandler:(GetCanHangoutAnchorListFinishHandler _Nullable)finishHandler;

/**
 *  8.2.发起多人互动邀请接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param roomId       多人互动直播间ID（可无，有则表示邀请成功且多人互动直播间已存在）
 *  @param inviteId     邀请ID（可无，若room_id不为空则无）
 *  @param expire       邀请有效的剩余秒数（整型）（可无，若invite_id不存在或为空则无）
 */
typedef void (^SendInvitationHangoutFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, NSString *_Nonnull inviteId, int expire);

/**
 *  8.2.发起多人互动邀请接口
 *
 *  @param roomId           当前发起的直播间ID
 *  @param anchorId         主播ID
 *  @param recommendId      推荐ID（可无，无则表示不是因推荐导致观众发起邀请）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)sendInvitationHangout:(NSString *_Nullable)roomId
                          anchorId:(NSString *_Nullable)anchorId
                       recommendId:(NSString *_Nullable)recommendId
                     finishHandler:(SendInvitationHangoutFinishHandler _Nullable)finishHandler;

/**
 *  8.3.取消多人互动邀请接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^CancelInviteHangoutFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  8.3.取消多人互动邀请接口
 *
 *  @param inviteId         邀请ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)cancelInviteHangout:(NSString *_Nullable)inviteId
                   finishHandler:(CancelInviteHangoutFinishHandler _Nullable)finishHandler;

/**
 *  8.4.获取多人互动邀请状态接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param status       邀请状态（HANGOUTINVITESTATUS_PENDING：待确定，HANGOUTINVITESTATUS_ACCEPT：已接受，HANGOUTINVITESTATUS_REJECT：已拒绝，HANGOUTINVITESTATUS_OUTTIME：已超时）
 *  @param roomId       多人互动直播间ID
 *  @param expire       邀请有效的剩余秒数
 */
typedef void (^GetHangoutInvitStatusFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, HangoutInviteStatus status, NSString * _Nonnull roomId, int expire);

/**
 *  8.4.获取多人互动邀请状态接口
 *
 *  @param inviteId         邀请ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getHangoutInvitStatus:(NSString *_Nullable)inviteId
                   finishHandler:(GetHangoutInvitStatusFinishHandler _Nullable)finishHandler;

/**
 *  8.5.同意主播敲门请求接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^DealKnockRequestFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  8.5.同意主播敲门请求接口
 *
 *  @param knockId          敲门ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)dealKnockRequest:(NSString *_Nullable)knockId
                finishHandler:(DealKnockRequestFinishHandler _Nullable)finishHandler;

/**
 *  9.1.获取节目未读数接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param num          未读数量
 */
typedef void (^GetNoReadNumProgramFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, int num);

/**
 *  9.1.获取节目未读数接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getNoReadNumProgram:(GetNoReadNumProgramFinishHandler _Nullable)finishHandler;

/**
 *  9.2.获取节目列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        节目列表
 */
typedef void (^GetProgramListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LSProgramItemObject *>* _Nullable array);

/**
 *  9.2.获取节目列表接口
 *
 *  @param sortType          列表类型（PROGRAMLISTTYPE_STARTTIEM：按节目开始时间排序，PROGRAMLISTTYPE_VERIFYTIEM：按节目审核时间排序，PROGRAMLISTTYPE_FEATURE：按广告排序，，PROGRAMLISTTYPE_BUYTICKET：已购票列表， PROGRAMLISTTYPE_HISTORY: 购票历史列表）
 *  @param start                         起始，用于分页，表示从第几个元素开始获取
 *  @param step                          步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getProgramListProgram:(ProgramListType)sortType
                             start:(int)start
                              step:(int)step
                     finishHandler:(GetProgramListFinishHandler _Nullable)finishHandler;

/**
 *  9.3.购买节目接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^BuyProgramFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, double leftCredit);

/**
 *  9.3.购买节目接口
 *
 *  @param liveShowId       节目ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)buyProgram:(NSString *_Nullable)liveShowId
                       finishHandler:(BuyProgramFinishHandler _Nullable)finishHandler;

/**
 *  9.4.关注/取消关注接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^FollowShowFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  9.4.关注/取消关注节目接口
 *
 *  @param liveShowId        节目ID
 *  @param isCancle          是否取消
 *  @param finishHandler     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)followShow:(NSString *_Nullable)liveShowId
               isCancle:(BOOL)isCancle
          finishHandler:(FollowShowFinishHandler _Nullable)finishHandler;

/**
 *  9.5.获取可进入的节目信息接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         节目信息
 *  @param roomId       直播间ID
 */
typedef void (^GetShowRoomInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSProgramItemObject * _Nullable item, NSString * _Nonnull roomId);

/**
 *  9.5.获取可进入的节目信息接口
 *
 *  @param liveShowId        节目ID
 *  @param finishHandler     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getShowRoomInfo:(NSString *_Nullable)liveShowId
          finishHandler:(GetShowRoomInfoFinishHandler _Nullable)finishHandler;

/**
 *  9.6.获取节目推荐列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        节目列表
 */
typedef void (^ShowListWithAnchorIdFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<LSProgramItemObject *>* _Nullable array);


/**
 *  9.6.获取节目推荐列表接口
 *
 *  @param anchorId          主播ID
 *  @param start             起始，用于分页，表示从第几个元素开始获取
 *  @param step              步长，用于分页，表示本次请求获取多少个元素
 *  @param sortType          推荐列表类型（SHOWRECOMMENDLISTTYPE_ENDRECOMMEND：直播结束推荐<包括指定主播及其它主播>，SHOWRECOMMENDLISTTYPE_PERSONALRECOMMEND：主播个人节目推荐<仅包括指定主播>，SHOWRECOMMENDLISTTYPE_NOHOSTRECOMMEND：不包括指定主播）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)showListWithAnchorId:(NSString *_Nullable)anchorId
                             start:(int)start
                              step:(int)step
                        sortType:(ShowRecommendListType)sortType
                     finishHandler:(ShowListWithAnchorIdFinishHandler _Nullable)finishHandler;

@end
