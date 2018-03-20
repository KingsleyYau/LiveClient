//
//  LSRequestManager.h
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZBLSLoginItemObject.h"
#import "ZBViewerFansItemObject.h"
#import "ZBGetNewFansBaseInfoItemObject.h"
#import "ZBGiftInfoItemObject.h"
#import "ZBGiftLimitNumItemObject.h"
#import "ZBEmoticonItemObject.h"
#import "ZBBookingPrivateInviteListObject.h"
#import "ZBBookingUnreadUnhandleNumItemObject.h"
#import "ZBTodayCreditItemObject.h"
#import "ZBConfigItemObject.h"

@interface ZBLSRequestManager : NSObject

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

- (NSString * _Nonnull)getModelType;

#pragma mark - 登陆认证模块

/**
 *  2.1.登陆接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ZBLoginFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBLSLoginItemObject * _Nonnull item);

/**
 *  2.1.登陆接口
 * @param anchorId             QN会员ID
 * @param password			QN系统登录验证返回的标识
 * @param deviceid		    设备唯一标识
 * @param model				设备型号（格式：设备型号－系统版本号）
 * @param manufacturer		制造厂商
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorLogin:(NSString *_Nonnull)anchorId
                password:(NSString *_Nonnull)password
                    code:(NSString *_Nonnull)code
                deviceid:(NSString * _Nonnull)deviceid
                   model:(NSString * _Nonnull)model
            manufacturer:(NSString * _Nonnull)manufacturer
           finishHandler:(ZBLoginFinishHandler _Nullable)finishHandler;

/**
 *  2.2.上传tokenid接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 */
typedef void (^ZBUpdateTokenIdFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  2.2.上传tokenid接口
 *
 *  @param tokenId            用于Push Notification的ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorUpdateTokenId:(NSString * _Nonnull)tokenId
             finishHandler:(ZBUpdateTokenIdFinishHandler _Nullable)finishHandler;

/**
 *  2.3.获取验证码接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 *  @parem data       验证码数据
 */
typedef void (^ZBGetVerificationCodeFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, const char * _Nullable data, int len);
/**
 *  2.3.获取验证码接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorGetVerificationCode:(ZBGetVerificationCodeFinishHandler _Nullable)finishHandler;

/**
 *  3.1.获取直播间观众列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   观众列表
 */
typedef void (^ZBLiveFansListFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<ZBViewerFansItemObject *>* _Nullable array);

/**
 *  3.1.获取直播间观众列表接口
 *
 *  @param roomId                       直播间ID
 *  @param finishHandler                接口回调
 *  @param start                        起始，用于分页，表示从第几个元素开始获取
 *  @param step                         步长，用于分页，表示本次请求获取多少个元素
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorLiveFansList:(NSString * _Nonnull)roomId
                          start:(int)start
                           step:(int)step
                  finishHandler:(ZBLiveFansListFinishHandler _Nullable)finishHandler;

/**
 *  3.2.获取指定观众信息接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item   邀请信息
 */
typedef void (^ZBGetNewFansBaseInfoFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBGetNewFansBaseInfoItemObject* _Nonnull item);

/**
 *  3.2.获取指定观众信息接口
 *
 *  @param userId           观众ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorGetNewFansBaseInfo:(NSString * _Nonnull)userId
                  finishHandler:(ZBGetNewFansBaseInfoFinishHandler _Nullable)finishHandler;

/**
 *  3.3.获取礼物列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   封面图列表
 */
typedef void (^ZBGetAllGiftListFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<ZBGiftInfoItemObject *>* _Nullable array);

/**
 *  3.3.获取礼物列表接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorGetAllGiftList:(ZBGetAllGiftListFinishHandler _Nullable)finishHandler;

/**
 *  3.4.获取主播直播间礼物列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   封面图列表
 */
typedef void (^ZBGiftListFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<ZBGiftLimitNumItemObject *>* _Nullable array);

/**
 *  3.4.获取主播直播间礼物列表接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorGiftList:(NSString * _Nonnull)roomId
              finishHandler:(ZBGiftListFinishHandler _Nullable)finishHandler;

/**
 *  3.5.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    指定礼物详情
 */
typedef void (^ZBGetGiftDetailFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBGiftInfoItemObject * _Nullable item);

/**
 *  3.5.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）接口
 *
 *  @param giftId           礼物ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorGetGiftDetail:(NSString * _Nonnull)giftId
             finishHandler:(ZBGetGiftDetailFinishHandler _Nullable)finishHandler;

/**
 *  3.6.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    指定礼物详情
 */
typedef void (^ZBGetEmoticonListFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<ZBEmoticonItemObject*>* _Nullable item);

/**
 *  3.6.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorGetEmoticonList:(ZBGetEmoticonListFinishHandler _Nullable)finishHandler;

/**
 *  3.7.主播回复才艺点播邀请（用于主播接受/拒绝观众发出的才艺点播邀请）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ZBDealTalentRequestFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  3.7.主播回复才艺点播邀请（用于主播接受/拒绝观众发出的才艺点播邀请）接口
 *
 *  @param finishHandler    接口回调
 *  @param talentInviteId   才艺点播邀请ID
 *  @param status           处理结果（ZBTALENTREPLYTYPE_AGREE：同意，ZBTALENTREPLYTYPE_REJECT：拒绝）
 *  @return 成功请求Id
 */
- (NSInteger)anchorDealTalentRequest:(NSString * _Nonnull)talentInviteId
                              status:(ZBTalentReplyType)status
                       finishHandler:(ZBDealTalentRequestFinishHandler _Nullable)finishHandler;

/**
 *  3.8.设置主播公开直播间自动邀请状态接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ZBSetAutoPushFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  3.8.设置主播公开直播间自动邀请状态接口
 *
 *  @param finishHandler    接口回调
 *  @param status           处理结果（SETPUSHTYPE_CLOSE：关闭，SETPUSHTYPE_START：启动）
 *  @return 成功请求Id
 */
- (NSInteger)anchorSetAutoPush:(ZBSetPushType)status
                       finishHandler:(ZBSetAutoPushFinishHandler _Nullable)finishHandler;

#pragma mark - 预约私密

/**
 *  4.1.观众待处理的预约邀请列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    邀请信息
 */
typedef void (^ZBManHandleBookingListFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBBookingPrivateInviteListObject * _Nonnull item);

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
- (NSInteger)anchorManHandleBookingList:(ZBBookingListType)type
                            start:(int)start
                             step:(int)step
                    finishHandler:(ZBManHandleBookingListFinishHandler _Nullable)finishHandler;

/**
 *  4.2.主播接受预约(邀请主播接受观众发起的预约邀请)接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ZBAcceptScheduledInviteFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  4.2.主播接受预约(邀请主播接受观众发起的预约邀请)接口
 *
 *  @param inviteId            邀请ID
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorAcceptScheduledInvite:(NSString * _Nonnull)inviteId
                           finishHandler:(ZBAcceptScheduledInviteFinishHandler _Nullable)finishHandler;

/**
 *  4.3.主播拒绝预约邀请(主播拒绝观众发起的预约邀请)接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ZBRejectScheduledInviteFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 * 4.3.主播拒绝预约邀请(主播拒绝观众发起的预约邀请)接口
 *
 *  @param invitationId            邀请ID
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorRejectScheduledInvite:(NSString * _Nonnull)invitationId
                           finishHandler:(ZBRejectScheduledInviteFinishHandler _Nullable)finishHandler;

/**
 *  4.4.获取预约邀请未读或待处理数量接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ZBGetScheduleListNoReadNumFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBBookingUnreadUnhandleNumItemObject * _Nonnull item);

/**
 *  4.4.获取预约邀请未读或待处理数量接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorGetScheduleListNoReadNum:(ZBGetScheduleListNoReadNumFinishHandler _Nullable)finishHandler;

/**
 *  4.5.获取已确认的预约数(用于主播端获取已确认的预约数量)接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param scheduledNum 已确认的预约数量
 */
typedef void (^ZBGetScheduledAcceptNumFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, int scheduledNum);

/**
 *  4.5.获取已确认的预约数(用于主播端获取已确认的预约数量)接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorGetScheduledAcceptNum:(ZBGetScheduledAcceptNumFinishHandler _Nullable)finishHandler;

/**
 *  4.6.主播接受立即私密邀请(用于主播接受观众发送的立即私密邀请)接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param roomId  直播间ID
 *  @param roomType  直播间类型
 */
typedef void (^ZBAcceptInstanceInviteFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString* _Nonnull roomId, ZBHttpRoomType roomType);

/**
 *  4.6.主播接受立即私密邀请(用于主播接受观众发送的立即私密邀请)接口
 *
 *  @param inviteId             邀请ID
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorAcceptInstanceInvite:(NSString* _Nullable)inviteId
                    finishHandler:(ZBAcceptInstanceInviteFinishHandler _Nullable)finishHandler;

/**
 *  4.7.主播拒绝立即私密邀请(用于主播拒绝观众发送的立即私密邀请)接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ZBRejectInstanceInviteFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  4.7.主播拒绝立即私密邀请(用于主播拒绝观众发送的立即私密邀请)接口
 *
 *  @param inviteId             邀请ID
 *  @param rejectReason         拒绝理由（可无）
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorRejectInstanceInvite:(NSString* _Nullable)inviteId
                           rejectReason:(NSString* _Nullable)rejectReason
                          finishHandler:(ZBRejectInstanceInviteFinishHandler _Nullable)finishHandler;

/**
 *  4.8.主播取消已发的立即私密邀请接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ZBCancelInstantInviteFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  4.8.主播取消已发的立即私密邀请接口
 *
 *  @param inviteId             邀请ID
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorCancelInstantInvite:(NSString* _Nullable)inviteId
                          finishHandler:(ZBCancelInstantInviteFinishHandler _Nullable)finishHandler;

/**
 *  4.9.设置直播间为开始倒数接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^ZBSetRoomCountDownFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  4.9.设置直播间为开始倒数接口
 *
 *  @param roomId               直播间ID
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorSetRoomCountDowne:(NSString* _Nullable)roomId
                         finishHandler:(ZBSetRoomCountDownFinishHandler _Nullable)finishHandler;

#pragma mark - 其它
/**
 *  5.1.同步配置接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    同步配置
 */
typedef void (^ZBGetConfigFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBConfigItemObject *_Nullable item);

/**
 *  5.1.同步配置接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorGetConfig:(ZBGetConfigFinishHandler _Nullable)finishHandler;

/**
 *  5.2.获取收入信息接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    同步配置
 */
typedef void (^ZBGetTodayCreditFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBTodayCreditItemObject *_Nullable item);

/**
 *  5.2.获取收入信息接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorGetTodayCredit:(ZBGetTodayCreditFinishHandler _Nullable)finishHandler;

/**
 *  5.3.提交流媒体服务器测速结果接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 */
typedef void (^ZBServerSpeedFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

/**
 *  5.3.提交流媒体服务器测速结果接口
 *
 *  @param sid             流媒体服务器ID
 *  @param res             http请求完成时间（毫秒）
 *  @param finishHandler   接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorServerSpeed:(NSString* _Nonnull)sid
                     res:(int)res
           finishHandler:(ZBServerSpeedFinishHandler _Nullable)finishHandler;

/**
 *   5.4.提交crash dump文件（仅独立）接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^ZBUploadCrashFileFinishHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);
/**
 *   5.4.提交crash dump文件（仅独立）接口
 *
 *  @param finishHandler    接口回调
 *  @param deviceId         设备唯一标识
 *  @param file             crash dump文件zip包二进制流
 *  @param tmpDirectory     crash dump文件zip（zip密钥：Qpid_Dating）
 *
 *  @return 成功请求Id
 */
- (NSInteger)anchorUploadCrashFile:(NSString * _Nonnull)deviceId
                        file:(NSString * _Nonnull)file
                tmpDirectory:(NSString * _Nonnull)tmpDirectory
               finishHandler:(ZBUploadCrashFileFinishHandler _Nullable)finishHandler;



@end
