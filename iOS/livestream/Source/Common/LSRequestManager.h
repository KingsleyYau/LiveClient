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
#import "LSHangoutGiftListObject.h"
#import "LSPersonalProfileItemObject.h"
#import "LSProgramItemObject.h"
//#import "LSPrivateMsgContactItemObject.h"
#import "LSMainUnreadNumItemObject.h"
#import "LSValidSiteIdItemObject.h"
#import "LSOrderProductItemObject.h"
#import "LSVersionItemObject.h"
#import "LSPhoneInfoObject.h"
#import "LSHttpLetterListItemObject.h"
#import "LSHttpLetterListItemObject.h"
#import "LSHttpLetterDetailItemObject.h"
#import "LSBuyAttachItemObject.h"
#import "LSAnchorLetterPrivItemObject.h"
#import "LSHangoutListItemObject.h"
#import "LSHangoutStatusItemObject.h"
#import "LSSayHiResourceConfigItemObject.h"
#import "LSSayHiAnchorItemObject.h"
#import "LSSayHiAllItemObject.h"
#import "LSSayHiResponseItemObject.h"
#import "LSSayHiDetailInfoItemObject.h"
#import "LSAppPushConfigItemObject.h"
#import "LSRecommendAnchorItemObject.h"
#import "LSLeftCreditItemObject.h"
#import "LSGiftTypeItemObject.h"
#import "LSStoreFlowerGiftItemObject.h"
#import "LSDeliveryItemObject.h"
#import "LSMyCartItemObject.h"
#import "LSCheckoutItemObject.h"
#import "LSWomanListAdItemObject.h"
#include <httpcontroller/HttpRequestEnum.h>

@interface LSRequestManager : NSObject

/**
 版本号
 */
@property (nonatomic, strong) NSString *versionCode;

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
+ (instancetype)manager;

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
+ (void)setLogDirectory:(NSString *)directory;

/**
 设置代理服务器

 @param proxyUrl <#proxyUrl description#>
 */
+ (void)setProxy:(NSString *)proxyUrl;

/**
 *  设置同步配置接口服务器域名
 *
 *  @param webSite 服务器域名
 */
- (void)setConfigWebSite:(NSString *)webSite;

/**
 *  设置接口服务器域名
 *
 *  @param webSite 服务器域名
 */
- (void)setWebSite:(NSString *)webSite;

/**
 *  设置新接口服务器域名
 *
 *  @param webSite 服务器域名
 */
- (void)setDomainWebSite:(NSString *)webSite;

/**
 *  设置接口服务器用户认证
 *
 *  @param user     用户名
 *  @param password 密码
 */
- (void)setAuthorization:(NSString *)user password:(NSString *)password;

/**
 *  清除所有Cookies
 */
- (void)cleanCookies;

/**
 获取所有Cookies
 
 @return cookies
 */
- (NSArray<NSHTTPCookie *> *)getCookies;

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
- (NSString *)getDeviceId;

/**
 *  将oc中的siteId（站点Id）转换为HTTP_OTHER_SITE_TYPE类型
 *
 *  @return 设备Id
 */
- (HTTP_OTHER_SITE_TYPE)getHttpSiteTypeByServerSiteId:(NSString *)siteId;

/**
 *  将oc中的字符串错误码转为HTTP_LCC_ERR_TYPE
 *
 *  @return http错误类型
 */
- (HTTP_LCC_ERR_TYPE)getStringToHttpErrorType:(NSString *)errnum;

#pragma mark - 登陆认证模块

/**
 *  2.1.验证手机是否已注册接口回调
 *
 *  @param success        成功失败
 *  @param errnum         错误码
 *  @param errmsg         错误提示
 *  @param isRegistered   是否已注册
 */
typedef void (^RegisterCheckPhoneFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int isRegistered);

/**
 *  2.1.登陆接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    直播登录信息
 */
typedef void (^LoginFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSLoginItemObject *item);

/**
 *  2.1.登陆接口
 * @param manId             QN会员ID
 * @param userSid           QN系统登录验证返回的标识
 * @param deviceid          设备唯一标识
 * @param model             设备型号（格式：设备型号－系统版本号）
 * @param manufacturer      制造厂商
 * @param finishHandler     接口回调
 *
 * @return 成功请求Id
 */
- (NSInteger)login:(NSString *)manId
           userSid:(NSString *)userSid
          deviceid:(NSString *)deviceid
             model:(NSString *)model
      manufacturer:(NSString *)manufacturer
     finishHandler:(LoginFinishHandler)finishHandler;

/**
 *  2.2.注销接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^LogoutFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  2.2.注销接口
 *
 *  @param finishHandler  接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)logout:(LogoutFinishHandler)finishHandler;

/**
 *  2.3.上传tokenid接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 */
typedef void (^UpdateTokenIdFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  2.3.上传tokenid接口
 *
 *  @param tokenId          用于Push Notification的ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)updateTokenId:(NSString *)tokenId
             finishHandler:(UpdateTokenIdFinishHandler)finishHandler;

/**
 *  2.13.可登录的站点列表接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 *  @param array      可登录站点队列
 */
typedef void (^GetValidsiteIdFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSValidSiteIdItemObject *> *array);

/**
 *  2.13.可登录的站点列表接口
 *
 *  @param email            用户的email或id
 *  @param password         登录密码
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getValidSiteId:(NSString *)email
                   password:(NSString *)password
              finishHandler:(GetValidsiteIdFinishHandler)finishHandler;

/**
 *  2.14.添加App token接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 */
typedef void (^AddTokenFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  2.14.添加App token接口
 *
 *  @param token            app token值
 *  @param appId            app唯一标识（App包名或iOS App ID，详情参考《“App ID”对照表》）
 *  @param deviceId         设备id
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)addToken:(NSString *)token
                appId:(NSString *)appId
             deviceId:(NSString *)deviceId
        finishHandler:(AddTokenFinishHandler)finishHandler;

/**
 *  2.15.销毁App token接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 */
typedef void (^DestroyTokenFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  2.15.销毁App token接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)destroyToken:(DestroyTokenFinishHandler)finishHandler;

/**
 *  2.16.找回密码接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 */
typedef void (^FindPasswordFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  2.16.找回密码接口
 *
 *  @param sendMail         用户注册的邮箱
 *  @param checkCode        验证码（ver3.0起）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)findPassword:(NSString *)sendMail
                checkCode:(NSString *)checkCode
            finishHandler:(FindPasswordFinishHandler)finishHandler;

/**
 *  2.17.修改密码接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 */
typedef void (^ChangePasswordFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  2.17.修改密码接口
 *
 *  @param passwordNew        新密码
 *  @param passwordOld        旧密码
 *  @param finishHandler      接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)changePassword:(NSString *)passwordNew
                passwordOld:(NSString *)passwordOld
              finishHandler:(ChangePasswordFinishHandler)finishHandler;

/**
 *  2.18.token登录认证接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^LoginWithTokenAuthFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  2.18.token登录认证接口
 * @param token             用于登录其他站点的加密串
 * @param memberId          会员id
 * @param deviceid          设备唯一标识
 * @param versionCode       客户端内部版本号
 * @param model             设备型号（格式：设备型号-系统版本号-API版本号-分辨率）
 * @param manufacturer      制造厂商
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)loginWithTokenAuth:(NSString *)token
                       memberId:(NSString *)memberId
                       deviceid:(NSString *)deviceid
                    versionCode:(NSString *)versionCode
                          model:(NSString *)model
                   manufacturer:(NSString *)manufacturer
                  finishHandler:(LoginWithTokenAuthFinishHandler)finishHandler;

/**
 *  2.19.获取认证token接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 *  @param memberId   用户id
 *  @param sid        用于登录其他站点的加密串，即其它站点获取的token
 */
typedef void (^GetTokenFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *memberId, NSString *sid);

/**
 *  2.19.获取认证token接口
 *
 *  @param siteId           站点ID（参考《11.10.“站点ID”对照表》）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getToken:(HTTP_OTHER_SITE_TYPE)siteId
        finishHandler:(GetTokenFinishHandler)finishHandler;

/**
 *  2.20.帐号密码登录接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 *  @param memberId   用户id
 *  @param sid        用于登录其他站点的加密串，即其它站点获取的token
 */
typedef void (^LoginWithPasswordFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *memberId, NSString *sid);

/**
 *  2.20.帐号密码登录接口
 *
 *  @param email            用户的email或id
 *  @param password         登录密码
 *  @param authCode         验证码
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)loginWithPassword:(NSString *)email
                      password:(NSString *)password
                      authCode:(NSString *)authCode
                 finishHandler:(LoginWithPasswordFinishHandler)finishHandler;

/**
 *  2.21.token登录接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 *  @param memberId   用户id
 *  @param sid        用于登录其他站点的加密串，即其它站点获取的token
 */
typedef void (^LoginWithTokenFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *memberId, NSString *sid);

/**
 *  2.21.token登录接口
 *
 *  @param memberId           用户id
 *  @param otherToken         用于登录其他站点的加密串，即其它站点获取的token
 *  @param finishHandler      接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)loginWithToken:(NSString *)memberId
                 otherToken:(NSString *)otherToken
              finishHandler:(LoginWithTokenFinishHandler)finishHandler;

/**
 *  2.22.获取验证码接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 *  @param data       验证码二进制流
 *  @param len        验证码二进制流的大小
 */
typedef void (^GetValidateCodeFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, const char *data, int len);

/**
 *  2.22.获取验证码接口
 *
 *  @param validateCodeType   LSVALIDATECODETYPE_LOGIN:登录获取  LSVALIDATECODETYPE_FINDPW:找回密码获取
 *  @param finishHandler      接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getValidateCode:(LSValidateCodeType)validateCodeType
               finishHandler:(GetValidateCodeFinishHandler)finishHandler;

/**
 *  2.23.提交用户头像接口回调
 *
 *  @param success    成功失败
 *  @param errnum     错误码
 *  @param errmsg     错误提示
 */
typedef void (^UploadUserPhotoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  2.23.提交用户头像接口
 *
 *  @param file               上传头像文件名
 *  @param finishHandler      接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)uploadUserPhoto:(NSString*)file
               finishHandler:(UploadUserPhotoFinishHandler)finishHandler;

#pragma mark - 直播间模块
/**
 *  3.1.获取Hot列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   热门列表
 */
typedef void (^GetAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LiveRoomInfoItemObject *> *array);

/**
 *  3.1.获取Hot列表接口
 *
 *  @param start            起始，用于分页，表示从第几个元素开始获取
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
             finishHandler:(GetAnchorListFinishHandler)finishHandler;

/**
 *  3.2.获取Hot列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   关注主播列表
 */
typedef void (^GetFollowListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<FollowItemObject *> *array);

/**
 *  3.2.获取Following列表接口
 *
 *  @param start            起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getFollowList:(int)start
                      step:(int)step
             finishHandler:(GetFollowListFinishHandler)finishHandler;

/**
 *  3.3.获取本人有效直播间或邀请信息接口回调(已废弃)
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   直播间信息
 */
typedef void (^GetRoomInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, RoomInfoItemObject *array);

/**
 *  3.3.获取本人有效直播间或邀请信息接口(已废弃)
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getRoomInfo:(GetRoomInfoFinishHandler)finishHandler;

/**
 *  3.4.获取直播间观众头像列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   观众列表
 */
typedef void (^LiveFansListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<ViewerFansItemObject *> *array);

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
- (NSInteger)liveFansList:(NSString *)roomId
                    start:(int)start
                     step:(int)step
            finishHandler:(LiveFansListFinishHandler)finishHandler;

/**
 *  3.5.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   礼物列表
 */
typedef void (^GetAllGiftListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<GiftInfoItemObject *> *array);

/**
 *  3.5.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getAllGiftList:(GetAllGiftListFinishHandler)finishHandler;

/**
 *  3.6.获取直播间可发送的礼物列表（观众端/主播端获取直播间的可发送的礼物列表, 包括背包礼物）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   可发送礼物列表
 */
typedef void (^GetGiftListByUserIdFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<GiftWithIdItemObject *> *array);

/**
 *  3.6.获取直播间可发送的礼物列表（观众端/主播端获取直播间的可发送的礼物列表, 包括背包礼物）接口
 *
 *  @param roomId           直播间ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getGiftListByUserId:(NSString *)roomId
                   finishHandler:(GetGiftListByUserIdFinishHandler)finishHandler;

/**
 *  3.7.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    礼物详情
 */
typedef void (^GetGiftDetailFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, GiftInfoItemObject *item);

/**
 *  3.7.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）接口
 *
 *  @param giftId           礼物ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getGiftDetail:(NSString *)giftId
             finishHandler:(GetGiftDetailFinishHandler)finishHandler;

/**
 *  3.8.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    文本表情列表
 */
typedef void (^GetEmoticonListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<EmoticonItemObject *> *item);

/**
 *  3.8.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getEmoticonList:(GetEmoticonListFinishHandler)finishHandler;

/**
 *  3.9.获取指定立即私密邀请信息接口(已废弃)回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    邀请信息
 */
typedef void (^GetInviteInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, InviteIdItemObject *item);

/**
 *  3.9.获取指定立即私密邀请信息接口(已废弃)
 *
 *  @param inviteId         邀请ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getInviteInfo:(NSString *)inviteId
             finishHandler:(GetInviteInfoFinishHandler)finishHandler;

/**
 *  3.10.获取才艺点播列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   才艺列表
 */
typedef void (^GetTalentListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<GetTalentItemObject *> *array);

/**
 *  3.10.获取才艺点播列表接口
 *
 *  @param roomId           直播间ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getTalentList:(NSString *)roomId
             finishHandler:(GetTalentListFinishHandler)finishHandler;

/**
 *  3.11.获取才艺点播邀请状态接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    才艺邀请信息
 */
typedef void (^GetTalentStatusFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, GetTalentStatusItemObject *item);

/**
 *  3.11.获取才艺点播邀请状态接口
 *
 *  @param roomId           直播间ID
 *  @param talentInviteId   才艺点播邀请ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getTalentStatus:(NSString *)roomId
              talentInviteId:(NSString *)talentInviteId
               finishHandler:(GetTalentStatusFinishHandler)finishHandler;

/**
 *  3.12.获取指定观众信息接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    观众信息
 */
typedef void (^GetNewFansBaseInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, GetNewFansBaseInfoItemObject *item);

/**
 *  3.12.获取指定观众信息接口
 *
 *  @param userId           观众ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getNewFansBaseInfo:(NSString *)userId
                  finishHandler:(GetNewFansBaseInfoFinishHandler)finishHandler;

/**
 *  3.13.观众开始／结束视频互动（废弃）接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param manPushUrl   视频流队列
 */
typedef void (^ControlManPushFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSMutableArray<NSString *> *manPushUrl);

/**
 *  3.13.观众开始／结束视频互动接口（废弃）
 *
 *  @param roomId           观众ID
 *  @param control          观众ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)controlManPush:(NSString *)roomId
                    control:(ControlType)control
              finishHandler:(ControlManPushFinishHandler)finishHandler;

/**
 *  3.14.获取推荐主播列表接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 *  @param array    推荐主播列表
 */
typedef void (^GetPromoAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LiveRoomInfoItemObject *> *array);

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
                         userId:(NSString *)userId
                  finishHandler:(GetPromoAnchorListFinishHandler)finishHandler;

/**
 *  3.15.获取页面推荐的主播列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        推荐主播列表
 */
typedef void (^GetLiveEndRecommendAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSRecommendAnchorItemObject *> *array);

/**
 *  3.15.获取页面推荐的主播列表接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLiveEndRecommendAnchorList:(GetLiveEndRecommendAnchorListFinishHandler)finishHandler;

/**
 *  3.16.获取我的联系人列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        推荐主播列表
 */
typedef void (^GetContactListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSRecommendAnchorItemObject *> *array, int totalCount);

/**
 *  3.16.获取我的联系人列表接口
 *
 *  @param start            起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getContactList:(int)start
                       step:(int)step
              finishHandler:(GetContactListFinishHandler)finishHandler;

/**
 *  3.17.获取虚拟礼物分类列接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        推荐主播列表
 */
typedef void (^GetGiftTypeListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSGiftTypeItemObject *> *array);

/**
 *  3.17.获取虚拟礼物分类列接口
 *
 *  @param roomType         场次类型(LSGIFTROOMTYPE_PUBLIC : 公开, LSGIFTROOMTYPE_PRIVATE : 私密)
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getGiftTypeList:(LSGiftRoomType)roomType
              finishHandler:(GetGiftTypeListFinishHandler)finishHandler;

/**
 *  3.18.Featured欄目的推荐主播列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array   热门列表
 */
typedef void (^GetFeaturedAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LiveRoomInfoItemObject *> *array);

/**
 *  3.18.Featured欄目的推荐主播列表接口
 *
 *  @param start            起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getFeaturedAnchorList:(int)start
                              step:(int)step
                     finishHandler:(GetFeaturedAnchorListFinishHandler)finishHandler;


#pragma mark - 预约私密

/**
 *  4.1.观众待处理的预约邀请列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    邀请信息
 */
typedef void (^ManHandleBookingListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, BookingPrivateInviteListObject *item);

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
                    finishHandler:(ManHandleBookingListFinishHandler)finishHandler;

/**
 *  4.2.观众处理预约邀请接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^HandleBookingFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  4.2.观众处理预约邀请接口
 *
 *  @param inviteId            邀请ID
 *  @param isConfirm           是否同意（0:否 1:是）
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)handleBooking:(NSString *)inviteId
                 isConfirm:(BOOL)isConfirm
             finishHandler:(HandleBookingFinishHandler)finishHandler;

/**
 *  4.3.取消预约邀请接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^SendCancelPrivateLiveInviteFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  4.3.取消预约邀请接口
 *
 *  @param invitationId            邀请ID
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)sendCancelPrivateLiveInvite:(NSString *)invitationId
                           finishHandler:(SendCancelPrivateLiveInviteFinishHandler)finishHandler;

/**
 *  4.4.获取预约邀请未读或待处理数量接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    没读数信息
 */
typedef void (^ManBookingUnreadUnhandleNumFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, BookingUnreadUnhandleNumItemObject *item);

/**
 *  4.4.获取预约邀请未读或待处理数量接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)manBookingUnreadUnhandleNum:(ManBookingUnreadUnhandleNumFinishHandler)finishHandler;

/**
 *  4.5.获取新建预约邀请信息接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 *  @param item     预约邀请信息
 */
typedef void (^GetCreateBookingInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, GetCreateBookingInfoItemObject *item);

/**
 *  4.5.获取新建预约邀请信息接口
 *
 *  @param userId               主播ID
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getCreateBookingInfo:(NSString *)userId
                    finishHandler:(GetCreateBookingInfoFinishHandler)finishHandler;

/**
 *  4.6.新建预约邀请接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^SendBookingRequestFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

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
- (NSInteger)sendBookingRequest:(NSString *)userId
                         timeId:(NSString *)timeId
                       bookTime:(NSInteger)bookTime
                         giftId:(NSString *)giftId
                        giftNum:(int)giftNum
                        needSms:(BOOL)needSms
                  finishHandler:(SendBookingRequestFinishHandler)finishHandler;

/**
 *  4.7.观众处理立即私密邀请接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 *  @param item     接受邀请信息
 *  @param priv     错误权限信息
 */
typedef void (^AcceptInstanceInviteFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, AcceptInstanceInviteItemObject *item, LSHttpAuthorityItemObject* priv);

/**
 *  4.7.观众处理立即私密邀请接口
 *
 *  @param inviteId             邀请ID
 *  @param isConfirm            是否同意（0: 否， 1: 是）
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)acceptInstanceInvite:(NSString *)inviteId
                        isConfirm:(BOOL)isConfirm
                    finishHandler:(AcceptInstanceInviteFinishHandler)finishHandler;

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
typedef void (^GiftListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<BackGiftItemObject *> *array, int totalCount);

/**
 *  5.1.获取背包礼物列表接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)giftList:(GiftListFinishHandler)finishHandler;

/**
 *  5.2.获取使用劵列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array        使用卷列表
 *  @param totalCount   列表总数
 */
typedef void (^VoucherListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<VoucherItemObject *> *array, int totalCount);

/**
 *  5.2.获取使用劵列表接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)voucherList:(VoucherListFinishHandler)finishHandler;

/**
 *  5.3.获取座驾列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        座驾列表
 *  @param totalCount   列表总数
 */
typedef void (^RideListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<RideItemObject *> *array, int totalCount);

/**
 *  5.3.获取座驾列表接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)rideList:(RideListFinishHandler)finishHandler;

/**
 *  5.4.使用／取消座驾接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^SetRideFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  5.4.使用／取消座驾接口
 *
 *  @param finishHandler       接口回调
 *  @param rideId  座驾ID
 *  @return 成功请求Id
 */
- (NSInteger)setRide:(NSString *)rideId
       finishHandler:(SetRideFinishHandler)finishHandler;

/**
 *  5.5.获取背包未读数量接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    背包未读数
 */
typedef void (^GetBackpackUnreadNumFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, GetBackPackUnreadNumItemObject *item);

/**
 *  5.5.获取背包未读数量接口
 *
 *  @param finishHandler       接口回调
 *  @return 成功请求Id
 */
- (NSInteger)getBackpackUnreadNum:(GetBackpackUnreadNumFinishHandler)finishHandler;

/**
 *  5.6.获取试用券可用信息接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    试聊劵信息
 */
typedef void (^GetVoucherAvailableInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSVoucherAvailableInfoItemObject *item);

/**
 *  5.6.获取试用券可用信息接口
 *
 *  @param finishHandler       接口回调
 *  @return 成功请求Id
 */
- (NSInteger)getVoucherAvailableInfo:(GetVoucherAvailableInfoFinishHandler)finishHandler;

/**
 *  5.7.获取LiveChat聊天试用券列表接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param array        使用卷列表
 *  @param totalCount   列表总数
 */
typedef void (^GetChatVoucherListFinishHandler)(BOOL success, NSString * errnum, NSString *errmsg, NSArray<VoucherItemObject *> *array, int totalCount);

/**
 *  5.7.获取LiveChat聊天试用券列表接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getChatVoucherList:(int)start
                           step:(int)step
                  finishHandler:(GetChatVoucherListFinishHandler)finishHandler;

#pragma mark - 其它
/**
 *  6.1.同步配置接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 *  @param item    同步配置信息
 */
typedef void (^GetConfigFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, ConfigItemObject *item);

/**
 *  6.1.同步配置接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getConfig:(GetConfigFinishHandler)finishHandler;

/**
 *  6.2.获取账号余额接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 *  @param item     余额信息
 */
typedef void (^GetLeftCreditFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSLeftCreditItemObject *item);

/**
 *  6.2.获取账号余额接口
 *
 *  @param finishHandler       接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getLeftCredit:(GetLeftCreditFinishHandler)finishHandler;

/**
 *  6.3.添加／取消收藏接口回调
 *
 *  @param success 成功失败
 *  @param errnum  错误码
 *  @param errmsg  错误提示
 */
typedef void (^SetFavoriteFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

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
- (NSInteger)setFavorite:(NSString *)userId
                  roomId:(NSString *)roomId
                   isFav:(BOOL)isFav
           finishHandler:(SetFavoriteFinishHandler)finishHandler;

/**
 *  6.4.获取QN广告列表接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 *  @param array    直播间列表
 */
typedef void (^GetAdAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LiveRoomInfoItemObject *> *array);

/**
 *  6.4.获取QN广告列表接口
 *
 *  @param finishHandler        接口回调
 *  @param number               客户段需要获取的数量
 *
 *  @return 成功请求Id
 */
- (NSInteger)getAdAnchorList:(int)number
               finishHandler:(GetAdAnchorListFinishHandler)finishHandler;

/**
 *  6.5.关闭QN广告列表接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 */
typedef void (^CloseAdAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  6.5.关闭QN广告列表接口
 *
 
 *  @param finishHandler        接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)closeAdAnchorList:(CloseAdAnchorListFinishHandler)finishHandler;

/**
 *  6.6.获取手机验证码接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 */
typedef void (^GetPhoneVerifyCodeFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

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
- (NSInteger)getPhoneVerifyCode:(NSString *)country
                       areaCode:(NSString *)areaCode
                        phoneNo:(NSString *)phoneNo
                  finishHandler:(GetPhoneVerifyCodeFinishHandler)finishHandler;

/**
 *  6.7.提交手机验证码接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 */
typedef void (^SubmitPhoneVerifyCodeFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

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
- (NSInteger)submitPhoneVerifyCode:(NSString *)country
                          areaCode:(NSString *)areaCode
                           phoneNo:(NSString *)phoneNo
                        verifyCode:(NSString *)verifyCode
                     finishHandler:(SubmitPhoneVerifyCodeFinishHandler)finishHandler;

/**
 *  6.8.提交流媒体服务器测速结果接口回调
 *
 *  @param success  成功失败
 *  @param errnum   错误码
 *  @param errmsg   错误提示
 */
typedef void (^ServerSpeedFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  6.8.提交流媒体服务器测速结果接口
 *
 *  @param sid             流媒体服务器ID
 *  @param res             http请求完成时间（毫秒）
 *  @param finishHandler   接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)serverSpeed:(NSString *)sid
                     res:(int)res
           finishHandler:(ServerSpeedFinishHandler)finishHandler;

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
typedef void (^BannerFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *bannerImg, NSString *bannerLink, NSString *bannerName);

/**
 *  6.9.获取Hot/Following列表头部广告接口
 *
 *  @param finishHandler   接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)banner:(BannerFinishHandler)finishHandler;

/**
 *  6.10.获取主播/观众信息接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param userInfoItem 观众/主播信息
 */
typedef void (^GetUserInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSUserInfoItemObject *userInfoItem);

/**
 *  6.10.获取主播/观众信息接口
 *
 *  @param userId           观众ID或主播ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getUserInfo:(NSString *)userId
           finishHandler:(GetUserInfoFinishHandler)finishHandler;

/**
 *  6.17.获取私信消息列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param userInfoItem 观众/主播信息
 */
typedef void (^GetTotalNoreadNumFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSMainUnreadNumItemObject *userInfoItem);

/**
 *  6.17.获取私信消息列表接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getTotalNoreadNum:(GetTotalNoreadNumFinishHandler)finishHandler;

/**
 *  6.18.查询个人信息接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param userInfoItem 观众/主播信息
 */
typedef void (^GetMyProfileFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSPersonalProfileItemObject *userInfoItem);

/**
 *  6.18.查询个人信息接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getMyProfile:(GetMyProfileFinishHandler)finishHandler;

/**
 *   6.19.修改个人信息接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param isModify     简介修改结果（YES：成功，NO：不用修改）
 */
typedef void (^UpdateProfileFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, BOOL isModify);

/**
 *  6.19.修改个人信息接口
 *
 *  @param weight        体重
 *  @param height        高度
 *  @param language      语言
 *  @param ethnicity     人种
 *  @param religion      宗教
 *  @param education     教育程度
 *  @param profession    职业
 *  @param income        收入
 *  @param children      孩子
 *  @param smoke         吸烟
 *  @param drink         喝酒
 *  @param resume        详情
 *  @param interests     兴趣爱好
 *  @param zodiac        星座
*  @param finishHandler    接口回调
 *  @return 成功请求Id
 */
- (NSInteger)updateProfile:(int)weight
                    height:(int)height
                  language:(int)language
                 ethnicity:(int)ethnicity
                  religion:(int)religion
                 education:(int)education
                profession:(int)profession
                    income:(int)income
                  children:(int)children
                     smoke:(int)smoke
                     drink:(int)drink
                    resume:(NSString *)resume
                 interests:(NSArray *)interests
                    zodiac:(int)zodiac
                    finish:(UpdateProfileFinishHandler)finishHandler;

/**
 *  6.20.检查客户端更新接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param userInfoItem 观众/主播信息
 */
typedef void (^VersionCheckFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSVersionItemObject *userInfoItem);

/**
 *  6.20.检查客户端更新接口
 *
 *  @param currVersion      当前客户端内部版本号
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)versionCheck:(int)currVersion
                   finish:(VersionCheckFinishHandler)finishHandler;

/**
 *  6.21.开始编辑简介触发计时接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^StartEditResumeFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  6.21.开始编辑简介触发计时接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)startEditResume:(StartEditResumeFinishHandler)finishHandler;

/**
 *  6.22.收集手机硬件信息接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^PhoneInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  6.22.收集手机硬件信息接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)phoneInfo:(LSPhoneInfoObject *)phoneInfo
         finishHandler:(PhoneInfoFinishHandler)finishHandler;

#pragma mark - IOS买点
/**
 * 7.4.获取订单信息（仅iOS）
 *
 *  @param success      成功失败
 *  @param errCode      失败状态码
 *  @param orderNo      订单号
 *  @param productId    产品号
 */
typedef void (^GetIOSPayFinishHandler)(BOOL success, NSString *errCode, NSString *orderNo, NSString *productId);

/**
 *  7.4.获取订单信息（仅iOS））接口
 *
 *  @param  manid            男士ID
 *   @param sid              跨服务器唯一标识
 *   @param number           信用点套餐ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getIOSPay:(NSString *)manid
                   sid:(NSString *)sid
                number:(NSString *)number
         finishHandler:(GetIOSPayFinishHandler)finishHandler;

/**
 * 7.5.验证订单信息（仅iOS）
 *
 *  @param success      成功失败
 *  @param errCode      失败状态码
 */
typedef void (^IOSPayCallFinishHandler)(BOOL success, NSString *errCode);

/**
 *  7.5.验证订单信息（仅iOS）接口
 *
 * @param manid            男士ID
 * @param sid              跨服务器唯一标识
 * @param receipt          AppStore支付成功返回的receipt参数
 * @param orderNo          订单号
 * @param code             AppStore支付完成返回的状态code（APPSTOREPAYTYPE_PAYSUCCES：支付成功，APPSTOREPAYTYPE_PAYFAIL：支付失败，APPSTOREPAYTYPE_PAYRECOVERY：恢复交易(仅非消息及自动续费商品)，APPSTOREPAYTYPE_NOIMMEDIATELYPAY：无法立即支付）（可无，默认：APPSTOREPAYTYPE_PAYSUCCES）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)iOSPayCall:(NSString *)manid
                    sid:(NSString *)sid
                receipt:(NSString *)receipt
                orderNo:(NSString *)orderNo
                   code:(AppStorePayCodeType)code
          finishHandler:(IOSPayCallFinishHandler)finishHandler;

/**
 * 7.6.获取产品列表（仅iOS）接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param productItem  产品列表
 */
typedef void (^PremiumMembershipFinishHandler)(BOOL success, NSString *errnum, NSString *errmsg, LSOrderProductItemObject *productItem);

/**
 * 7.6.获取产品列表（仅iOS）接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)premiumMembership:(PremiumMembershipFinishHandler)finishHandler;


/**
 * 7.7.获取h5买点页面URL 接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param redirtctUrl  h5买点页面URL
 */
typedef void (^MobilePayGotoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *redirtctUrl);

/**
 * 7.7.获取h5买点页面URL 接口
 *
 *  @param orderType    购买产品类型（LSORDERTYPE_CREDIT：信用点，LSORDERTYPE_FLOWERGIFT：鲜花礼品, LSORDERTYPE_MONTHFEE：月费服务，LSORDERTYPE_STAMP：邮票）
 *  @param clickFrom    点击来源（Axx表示不可切换，Bxx表示可切换）（可""，""则表示不指定）
 *  @param number       已选中的充值包ID（可""，""表示不指定充值包）
 *  @param orderNo      鲜花礼品订单ID（可无，无或空表示无订单ID）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)mobilePayGoto:(LSOrderType)orderType
                 clickFrom:(NSString *)clickFrom
                    number:(NSString *)number
                   orderNo:(NSString *)orderNo
             finishHandler:(MobilePayGotoFinishHandler)finishHandler;

/**
 *  8.1.获取可邀请多人互动的主播列表接口回调（已废弃）
 *
 *  @param success      成功失败m
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        多人互动的主播列表
 */
typedef void (^GetCanHangoutAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSHangoutAnchorItemObject *> *array);

/**
 *  8.1.获取可邀请多人互动的主播列表接口（已废弃）
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
                            anchorId:(NSString *)anchorId
                               start:(int)start
                                step:(int)step
                       finishHandler:(GetCanHangoutAnchorListFinishHandler)finishHandler;

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
typedef void (^SendInvitationHangoutFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *roomId, NSString *inviteId, int expire);

/**
 *  8.2.发起多人互动邀请接口
 *
 *  @param roomId           当前发起的直播间ID
 *  @param anchorId         主播ID
 *  @param recommendId      推荐ID（可无，无则表示不是因推荐导致观众发起邀请）
 *  @param isCreateOnly     是否仅创建新的Hangout直播间，若已有Hangout直播间则先关闭（NO：否，YES：是）（整型）（可无，无则默认为NO）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)sendInvitationHangout:(NSString *)roomId
                          anchorId:(NSString *)anchorId
                       recommendId:(NSString *)recommendId
                      isCreateOnly:(BOOL)isCreateOnly
                     finishHandler:(SendInvitationHangoutFinishHandler)finishHandler;

/**
 *  8.3.取消多人互动邀请接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^CancelInviteHangoutFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg);

/**
 *  8.3.取消多人互动邀请接口
 *
 *  @param inviteId         邀请ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)cancelInviteHangout:(NSString *)inviteId
                   finishHandler:(CancelInviteHangoutFinishHandler )finishHandler;

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
typedef void (^GetHangoutInvitStatusFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, HangoutInviteStatus status, NSString *  roomId, int expire);

/**
 *  8.4.获取多人互动邀请状态接口
 *
 *  @param inviteId         邀请ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getHangoutInvitStatus:(NSString *)inviteId
                   finishHandler:(GetHangoutInvitStatusFinishHandler )finishHandler;

/**
 *  8.5.同意主播敲门请求接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^DealKnockRequestFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg);

/**
 *  8.5.同意主播敲门请求接口
 *
 *  @param knockId          敲门ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)dealKnockRequest:(NSString *)knockId
                finishHandler:(DealKnockRequestFinishHandler )finishHandler;

/**
 *  8.6.获取多人互动直播间可发送的礼物列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         可发送的礼物列表
 */
typedef void (^GetHangoutGiftListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, LSHangoutGiftListObject*  item);

/**
 *  8.6.获取多人互动直播间可发送的礼物列表接口
 *
 *  @param roomId           直播间ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getHangoutGiftList:(NSString *)roomId
                finishHandler:(GetHangoutGiftListFinishHandler )finishHandler;

/**
 *  8.7.获取Hang-out在线主播列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array         获取指定主播的Hang-out好友列表
 */
typedef void (^GetHangoutOnlineAnchorFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, NSArray<LSHangoutListItemObject *> *array);

/**
 *  8.7.获取Hang-out在线主播列表接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getHangoutOnlineAnchor:(GetHangoutOnlineAnchorFinishHandler )finishHandler;

/**
 *  8.8.获取指定主播的Hang-out好友列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        多人互动的主播列表
 */
typedef void (^GetHangoutFriendsFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *anchorId, NSArray<LSHangoutAnchorItemObject *> *array);

/**
 *  8.8.获取指定主播的Hang-out好友列表接口
 *
 *  @param anchorId         主播ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getHangoutFriends:(NSString *)anchorId
                 finishHandler:(GetHangoutFriendsFinishHandler)finishHandler;

/**
 *  8.9.自动邀请Hangout直播邀請展示條件接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^AutoInvitationHangoutLiveDisplayFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  8.9.自动邀请Hangout直播邀請展示條件接口
 *
 *  @param anchorId         主播ID（可无，仅当type=3才存在）
 *  @param isAuto         是否自动（1：自动  0：手动）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)autoInvitationHangoutLiveDisplay:(NSString *)anchorId
                                       isAuto:(BOOL)isAuto
                                finishHandler:(AutoInvitationHangoutLiveDisplayFinishHandler)finishHandler;

/**
 *  8.10.自动邀请hangout点击记录接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^AutoInvitationClickLogFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  8.10.获取指定主播的Hang-out好友列表接口
 *
 *  @param anchorId         主播ID（可无，仅当type=3才存在）
 *  @param isAuto         是否自动（1：自动  0：手动）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)autoInvitationClickLog:(NSString *)anchorId
                             isAuto:(BOOL)isAuto
                      finishHandler:(AutoInvitationClickLogFinishHandler)finishHandler;

/**
 *  8.11.获取当前会员Hangout直播状态接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param list        多人间的状态信息组（ps：当错误码为HTTP_LCC_ERR_EXIST_HANGOUT = 18003才做处理，当前会员已在hangout直播间， 其实只有一个）
 */
typedef void (^GetHangoutStatusFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg,  NSArray<LSHangoutStatusItemObject *> *list);

/**
 *  8.11.获取当前会员Hangout直播状态接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getHangoutStatus:(GetHangoutStatusFinishHandler)finishHandler;

/**
 *  9.1.获取节目未读数接口回调(已废弃)
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param num          未读数量
 */
typedef void (^GetNoReadNumProgramFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, int num);

/**
 *  9.1.获取节目未读数接口(已废弃)
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getNoReadNumProgram:(GetNoReadNumProgramFinishHandler )finishHandler;

/**
 *  9.2.获取节目列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        节目列表
 */
typedef void (^GetProgramListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, NSArray<LSProgramItemObject *>*  array);

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
                     finishHandler:(GetProgramListFinishHandler )finishHandler;

/**
 *  9.3.购买节目接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param leftCredit   购买后的余额
 */
typedef void (^BuyProgramFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, double leftCredit);

/**
 *  9.3.购买节目接口
 *
 *  @param liveShowId       节目ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)buyProgram:(NSString *)liveShowId
                       finishHandler:(BuyProgramFinishHandler )finishHandler;

/**
 *  9.4.关注/取消关注接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^FollowShowFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg);

/**
 *  9.4.关注/取消关注节目接口
 *
 *  @param liveShowId        节目ID
 *  @param isCancle          是否取消
 *  @param finishHandler     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)followShow:(NSString *)liveShowId
               isCancle:(BOOL)isCancle
          finishHandler:(FollowShowFinishHandler )finishHandler;

/**
 *  9.5.获取可进入的节目信息接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         节目信息
 *  @param roomId       直播间ID
 *  @param privItem     错误权限信息
 */
typedef void (^GetShowRoomInfoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, LSProgramItemObject *  item, NSString *  roomId, LSHttpAuthorityItemObject * privItem);

/**
 *  9.5.获取可进入的节目信息接口
 *
 *  @param liveShowId        节目ID
 *  @param finishHandler     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getShowRoomInfo:(NSString *)liveShowId
          finishHandler:(GetShowRoomInfoFinishHandler )finishHandler;

/**
 *  9.6.获取节目推荐列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        节目列表
 */
typedef void (^ShowListWithAnchorIdFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, NSArray<LSProgramItemObject *>*  array);


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
- (NSInteger)showListWithAnchorId:(NSString *)anchorId
                             start:(int)start
                              step:(int)step
                        sortType:(ShowRecommendListType)sortType
                     finishHandler:(ShowListWithAnchorIdFinishHandler )finishHandler;


/**
 *  10.1.获取私信联系人列表接口(外部不调用，在私信管理器调用)
 *
 *  @param callback    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getPrivateMsgFriendList:(long)callback;

/**
 *  10.2.获取私信Follow联系人列表接口 (外部不调用，在私信管理器调用，已弃用)
 *
 *  @param callback    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getFollowPrivateMsgFriendList:(long)callback;

/**
 *  10.3.获取私信消息列表接口 (外部不调用，在私信管理器调用)
 *
 *  @param userId       私信用户
 *  @param startMsgId   开始查询的msgId（返回不包含这个）
 *  @param order        查询的类型
 *  @param limit        查询的数量
 *  @param reqId        reqId
 *  @param callback     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getPrivateMsgWithUserId:(NSString * )userId startMsgId:(NSString * )startMsgId order:(PrivateMsgOrderType)order limit:(int)limit reqId:(int)reqId callback:(long)callback;

/**
 *  10.4.标记私信已读接口 (外部不调用，在私信管理器调用)
 *
 *  @param userId       私信用户
 *  @param callback     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)setPrivateMsgReaded:(NSString * )userId msgId:(NSString * )msgId callback:(long)callback;

/**
 *  11.1.获取推送设置接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         App推送设置
 */
typedef void (^GetPushConfigFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, LSAppPushConfigItemObject* item);


/**
 *  11.1.获取推送设置接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getPushConfig:(GetPushConfigFinishHandler )finishHandler;

/**
 *  11.2.修改推送设置接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^SetPushConfigFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg);


/**
 *  11.2.修改推送设置接口
 *
 *  @param finishHandler    接口回调
 *  @param isPriMsgAppPush        是否接收私信推送通知
 *  @param isMailAppPush          是否接收私信推送通知
 *  @param isSayHiAppPush         是否接收SayHi推送通知
 *  @return 成功请求Id
 */
- (NSInteger)setPushConfig:(BOOL)isPriMsgAppPush
             isMailAppPush:(BOOL)isMailAppPush
            isSayHiAppPush:(BOOL)isSayHiAppPush
             finishHandler:(SetPushConfigFinishHandler )finishHandler;

/**
 *  13.1.获取意向信列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        loi列表
 */
typedef void (^GetLoiListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, NSArray<LSHttpLetterListItemObject *>*  array);


/**
 *  13.1.获取意向信列表接口
 *
 *  @param tag              tag类型（LSLETTERTAG_ALL：所有，LSLETTERTAG_UNREAD：未读，LSLETTERTAG_UNREPLIED：未回复，LSLETTERTAG_REPLIED：已回复，LSLETTERTAG_FOLLOW：已Follow）
 *  @param start            起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *  @return 成功请求Id
 */
- (NSInteger)getLoiList:(LSLetterTag)tag
                  start:(int)start
                   step:(int)step
          finishHandler:(GetLoiListFinishHandler )finishHandler;

/**
 * 13.2.获取意向信详情接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         loi详情
 */
typedef void (^GetLoiDetailFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, LSHttpLetterDetailItemObject * item);


/**
 *  13.2.获取意向信详情接口
 *
 *  @param loiId            意向信Id
 *  @param finishHandler    接口回调
 *  @return 成功请求Id
 */
- (NSInteger)getLoiDetail:(NSString*)loiId
          finishHandler:(GetLoiDetailFinishHandler )finishHandler;

/**
 *  13.3.获取信件列表(inbox)接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        inbox列表
 */
typedef void (^GetEmfListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, NSArray<LSHttpLetterListItemObject *>*  array);


/**
 *  13.3.获取信件列表接口
 *
 *  @param type             列表类型（1：Inbox，2：Outbox）
 *  @param tag              tag类型（LSLETTERTAG_ALL：所有，LSLETTERTAG_UNREAD：未读，LSLETTERTAG_UNREPLIED：未回复，LSLETTERTAG_REPLIED：已回复，LSLETTERTAG_FOLLOW：已Follow）
 *  @param start            起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *  @return 成功请求Id
 */
- (NSInteger)getEmfboxList:(LSEMFType)type
                      tag:(LSLetterTag)tag
                    start:(int)start
                     step:(int)step
         finishHandler:(GetEmfListFinishHandler )finishHandler;

/**
 * 13.4.获取信件详情接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         loi详情
 */
typedef void (^GetEmfDetailFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, LSHttpLetterDetailItemObject * item);


/**
 *  13.4.获取信件详情接口
 *
 *  @param emfId            EMFId
 *  @param finishHandler    接口回调
 *  @return 成功请求Id
 */
- (NSInteger)getEmfDetail:(NSString*)emfId
            finishHandler:(GetEmfDetailFinishHandler )finishHandler;

/**
 * 13.5.发送信件接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 */
typedef void (^SendEmfFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg);


/**
 *  13.5.发送信件接口
 *
 * @param anchorId                      主播ID
 * @param loiId                         回复的意向信ID（可无，无则为不是回复）
 * @param emfId                         回复的信件ID（可无，无则为不是回复）
 * @param content                       回复信件内容
 * @param imgList                       附件数组
 * @param comsumeType                   付费类型（LSLETTERCOMSUMETYPE_CREDIT：信用点，LSLETTERCOMSUMETYPE_STAMP：邮票）
 * @param sayHiResponseId              SayHi的回复ID（可无，无则表示不是回复）
 * @param finishHandler    接口回调
 * @return 成功请求Id
 */
- (NSInteger)sendEmf:(NSString*)anchorId
               loiId:(NSString*)loiId
               emfId:(NSString*)emfId
             content:(NSString*)content
             imgList:(NSArray<NSString *>*)imgList
         comsumeType:(LSLetterComsumeType)comsumeType
     sayHiResponseId:(NSString*)sayHiResponseId
            finishHandler:(SendEmfFinishHandler )finishHandler;

/**
 * 13.6.上传附件接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param url          成功上传的附件URL
 *  @param md5          成功上传的附件URL
 *  @param fileName     上传图片名
 */
typedef void (^UploadLetterPhotoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, NSString *  url, NSString *  md5, NSString *  fileName);


/**
 *  13.6.上传附件接口
 *  @param fileName        上传图片名
 *  @param file            上传头像文件名
 *  @param finishHandler    接口回调
 *  @return 成功请求Id
 */
- (NSInteger)uploadLetterPhoto:(NSString*)fileName
                          file:(NSString*)file
            finishHandler:(UploadLetterPhotoFinishHandler )finishHandler;

/**
 * 13.7.购买信件附件接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         购买信件附件
 */
typedef void (^BuyPrivatePhotoVideoFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, LSBuyAttachItemObject * item);


/**
 *  13.7.购买信件附件接口
 *
 * @param emfId                         信件ID
 * @param resourceId                    附件ID
 * @param comsumeType                   付费类型（LSLETTERCOMSUMETYPE_CREDIT：信用点，LSLETTERCOMSUMETYPE_STAMP：邮票）
 * @param finishHandler    接口回调
 * @return 成功请求Id
 */
- (NSInteger)buyPrivatePhotoVideo:(NSString*)emfId
                       resourceId:(NSString*)resourceId
                      comsumeType:(LSLetterComsumeType)comsumeType
                    finishHandler:(BuyPrivatePhotoVideoFinishHandler )finishHandler;

/**
 *  13.8.获取发送信件所需的余额接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param creditPrice  所需的信用点
 *  @param stampPrice   所需的邮票
 */
typedef void (^GetSendMailPriceFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, double creditPrice, double stampPrice);

/**
 *  13.8.获取发送信件所需的余额接口
 *
 *  @param imgNumber         发送图片附件数
 *  @param finishHandler     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getSendMailPrice:(int)imgNumber
                finishHandler:(GetSendMailPriceFinishHandler)finishHandler;

/**
 *  13.9.获取主播信件权限接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         主播信件权限
 */
typedef void (^GetAnchorLetterPrivFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSAnchorLetterPrivItemObject * item);

/**
 *  13.9.获取主播信件权限接口
 *
 *  @param anchorId          主播ID
 *  @param finishHandler     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getAnchorLetterPriv:(NSString*)anchorId
                   finishHandler:(GetAnchorLetterPrivFinishHandler)finishHandler;

/**
 *  14.1.获取发送SayHi的主题和文本信息接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         获取主题、文本配置信息
 */
typedef void (^SayHiConfigFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResourceConfigItemObject * item);

/**
 *  14.1.获取发送SayHi的主题和文本信息接口（用于观众端获取发送SayHi的主题和文本信息）
 *
 *  @param finishHandler     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)sayHiConfig:(SayHiConfigFinishHandler)finishHandler;

/**
 *  14.2.获取可发Say Hi的主播列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param array        合发送Say Hi的主播列表
 */
typedef void (^GetSayHiAnchorListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg,  NSArray<LSSayHiAnchorItemObject *>*  array);

/**
 *  14.2.获取可发Say Hi的主播列表接口（用于Say Hi的All列表没有数据时，观众获取可发Say Hi的主播列表）
 *
 *  @param finishHandler     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getSayHiAnchorList:(GetSayHiAnchorListFinishHandler)finishHandler;

/**
 *  14.3.检测能否对指定主播发送SayHi接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param isCanSend    是否能发送SayHi
 */
typedef void (^IsCanSendSayHiFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, BOOL isCanSend);

/**
 *  14.3.检测能否对指定主播发送SayHi接口（用于检测能否对指定主播发送SayHi，观众端暂无用到本接口）
 *
 *  @param anchorId          主播ID
 *  @param finishHandler     接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)isCanSendSayHi:(NSString*)anchorId
                   finishHandler:(IsCanSendSayHiFinishHandler)finishHandler;

/**
 *  14.4.发送sayHi接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param sayHiId      SayHiID （当错误码为 HTTP_LCC_ERR_SUCCESS（发送成功） 和发送失败HTTP_LCC_ERR_SAYHI_MAN_ALREADY_SEND_SAYHI，sayHi没有过期loiId有，sayHi过期loiId为空）
 *  @param loiId        意向信ID （当错误码为HTTP_LCC_ERR_SAYHI_ANCHOR_ALREADY_SEND_LOI，意向信没有过期loiId有，意向信过期loiId为空）
 *  @param isFollow     是否已关注（0：否，1：是） 错误才返回
 */
typedef void (^SendSayHiFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *sayHiId, NSString *loiId, BOOL isFollow, OnLineStatus onlineStatus);

/**
 *  14.4.发送sayHi接口
 *
 *  @param anchorId          主播ID
 *  @param themeId           主题ID
 *  @param textId            文本ID
 *  @param finishHandler     接口回调s
 *
 *  @return 成功请求Id
 */
- (NSInteger)sendSayHi:(NSString*)anchorId
               themeId:(NSString*)themeId
                textId:(NSString*)textId
         finishHandler:(SendSayHiFinishHandler)finishHandler;

/**
 *  14.5.获取Say Hi的All列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         All ‘Say Hi’列表
 */
typedef void (^GetAllSayHiListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiAllItemObject *item);

/**
 *  14.5.获取Say Hi的All列表接口（用于观众端获取Say Hi的All列表数据）
 *
 *  @param start            起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调s
 *
 *  @return 成功请求Id
 */
- (NSInteger)getAllSayHiList:(int)start
                        step:(int)step
               finishHandler:(GetAllSayHiListFinishHandler)finishHandler;

/**
 *  14.6.获取SayHi的Response列表接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         Waiting for your reply列表
 */
typedef void (^GetResponseSayHiListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiResponseItemObject *item);

/**
 *  14.6.获取SayHi的Response列表接口(用于观众端获取Say Hi的Response列表)
 *
 *  @param type             排序（LSSAYHIDETAILTYPE_EARLIEST：Unread First，LSSAYHIDETAILTYPE_LATEST：Latest First）
 *  @param start            起始，用于分页，表示从第几个元素开始获取
 *  @param step             步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调s
 *
 *  @return 成功请求Id
 */
- (NSInteger)getResponseSayHiList:(LSSayHiListType)type
                            start:(int)start
                             step:(int)step
                    finishHandler:(GetResponseSayHiListFinishHandler)finishHandler;

/**
 *  14.7.获取SayHi详情接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         SayHi详情
 */
typedef void (^SayHiDetailFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiDetailInfoItemObject *item);

/**
 *  14.7.获取SayHi详情接口(用于观众端获取SayHi详情)
 *
 *  @param type             排序（LSSAYHIDETAILTYPE_EARLIEST：Earliest first，LSSAYHIDETAILTYPE_LATEST：Latest First, LSSAYHIDETAILTYPE_UNREAD:Unread first）
 *  @param sayHiId          sayHi的ID
 *  @param finishHandler    接口回调s
 *
 *  @return 成功请求Id
 */
- (NSInteger)sayHiDetail:(LSSayHiDetailType)type
                 sayHiId:(NSString*)sayHiId
           finishHandler:(SayHiDetailFinishHandler)finishHandler;

/**
 *  14.8.获取SayHi回复详情接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param item             回复sayhi的详情
 */
typedef void (^ReadResponseFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSayHiDetailResponseListItemObject *item);

/**
 *  14.8.获取SayHi回复详情接口
 *
 *  @param sayHiId          sayHi的ID
 *  @param responseId       回复ID
 *  @param finishHandler    接口回调s
 *
 *  @return 成功请求Id
 */
- (NSInteger)readResponse:(NSString*)sayHiId
               responseId:(NSString*)responseId
            finishHandler:(ReadResponseFinishHandler)finishHandler;

/**
 *  6.23.qn邀请弹窗更新邀请id接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 */
typedef void (^UpQnInviteIdFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  6.23.qn邀请弹窗更新邀请id接口
 *
 *  @param manId                         用户ID
 *  @param anchorId                      主播id
 *  @param inviteId                      邀请id
 *  @param roomId                        直播间id
 *  @param inviteType                    邀請類型(LSBUBBLINGINVITETYPE_ONEONONE:one-on-one LSBUBBLINGINVITETYPE_HANGOUT:Hangout LSBUBBLINGINVITETYPE_LIVECHAT:Livechat)
 *  @param finishHandler    接口回调s
 *
 *  @return 成功请求Id
 */
- (NSInteger)upQnInviteId:(NSString*)manId
                 anchorId:(NSString*)anchorId
                 inviteId:(NSString*)inviteId
                   roomId:(NSString*)roomId
               inviteType:(LSBubblingInviteType)inviteType
            finishHandler:(UpQnInviteIdFinishHandler)finishHandler;

/**
 *  6.24.获取直播广告接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param htmUrl           广告url
 */
typedef void (^RetrieveBannerFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *htmUrl);

/**
 *  6.24.获取直播广告接口
 *
 * @param manId                         用户ID
 * @param isAnchorPage                  是否是是主播详情页
 * @param bannerType                    邀請類型(LSBANNERTYPE_NINE_SQUARED:直播站内九宫格 LSBANNERTYPE_ALL_BROADCASTERS:All Broadcasters LSBANNERTYPE_FEATURED_BROADCASTERS:Featured Broadcasters LSBANNERTYPE_SAYHI:Say Hi LSBANNERTYPE_GREETMAIL:Greeting Mail LSBANNERTYPE_MAIL:Mail LSBANNERTYPE_CHAT:Chat LSBANNERTYPE_HANGOUT:Hang-out LSBANNERTYPE_GIFTSFLOWERS:Gifts & Flowers)
 *  @param finishHandler    接口回调s
 *
 *  @return 成功请求Id
 */
- (NSInteger)retrieveBanner:(NSString*)manId
               isAnchorPage:(BOOL)isAnchorPage
                 bannerType:(LSBannerType)bannerType
              finishHandler:(RetrieveBannerFinishHandler)finishHandler;

#pragma mark - 鲜花礼品
/**
 *  15.1.获取鲜花礼品列表接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param array            商店的鲜花礼品列表
 */
typedef void (^GetStoreGiftListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSStoreFlowerGiftItemObject *> *array);

/**
 *  15.1.获取鲜花礼品列表接口
 *
 * @param anchorId          主播ID（可无）
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getStoreGiftList:(NSString*)anchorId
                finishHandler:(GetStoreGiftListFinishHandler)finishHandler;

/**
 *  15.2.获取鲜花礼品详情接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param item             鲜花礼品详情
 */
typedef void (^GetFlowerGiftDetailFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSFlowerGiftItemObject *item);

/**
 *  15.2.获取鲜花礼品详情接口
 *
 *  @param giftId           礼物ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getFlowerGiftDetail:(NSString*)giftId
                   finishHandler:(GetFlowerGiftDetailFinishHandler)finishHandler;


/**
 *  15.3.获取推荐鲜花礼品列表接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param array            推荐鲜花礼品列表
 */
typedef void (^GetRecommendGiftListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSFlowerGiftItemObject *> *array);

/**
 *  15.3.获取推荐鲜花礼品列表接口
 *
 *  @param giftId           礼物ID
 *  @param anchorId         主播ID
 *  @param number           数量
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getRecommendGiftList:(NSString*)giftId
                         anchorId:(NSString*)anchorId
                           number:(int)number
                    finishHandler:(GetRecommendGiftListFinishHandler)finishHandler;

/**
 *  15.4.获取Resent Recipient主播列表接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param array            Recipient的主播列表
 */
typedef void (^GetResentRecipientListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSRecipientAnchorItemObject *> *array);

/**
 *  15.4.获取Resent Recipient主播列表接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getResentRecipientList:(GetResentRecipientListFinishHandler)finishHandler;

/**
 *  15.5.获取My delivery列表接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param array            配送列表
 */
typedef void (^GetDeliveryListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSDeliveryItemObject *> *array);

/**
 *  15.5.获取My delivery列表接口
 *
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getDeliveryList:(GetDeliveryListFinishHandler)finishHandler;

/**
 *  15.6.获取购物车礼品种类数接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param num              礼品种类数
 */
typedef void (^GetCartGiftTypeNumFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int num);

/**
 *  15.6.获取购物车礼品种类数接口
 *
 *  @param anchorId         主播ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getCartGiftTypeNum:(NSString*)anchorId
                  finishHandler:(GetCartGiftTypeNumFinishHandler)finishHandler;

/**
 *  15.7.获取购物车My cart列表接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param total            总数
 *  @param array            购物车cart列表
 */
typedef void (^GetCartGiftListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int total, NSArray<LSMyCartItemObject *> *array);

/**
 *  15.7.获取购物车My cart列表接口
 *
 *  @param start                         起始，用于分页，表示从第几个元素开始获取
 *  @param step                          步长，用于分页，表示本次请求获取多少个元素
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)getCartGiftList:(int)start
                        step:(int)step
               finishHandler:(GetCartGiftListFinishHandler)finishHandler;

/**
 *  15.8.添加购物车商品接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 */
typedef void (^AddCartGiftFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  15.8.添加购物车商品接口
 *
 *  @param anchorId         主播ID
 *  @param giftId           礼品ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)addCartGift:(NSString*)anchorId
                  giftId:(NSString*)giftId
           finishHandler:(AddCartGiftFinishHandler)finishHandler;

/**
 *  15.9.修改购物车商品数量接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 */
typedef void (^ChangeCartGiftNumberFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  15.9.修改购物车商品数量接口
 *
 *  @param anchorId         主播ID
 *  @param giftId           礼品ID
 *  @param giftNumber       礼品数量
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)changeCartGiftNumber:(NSString*)anchorId
                           giftId:(NSString*)giftId
                       giftNumber:(int)giftNumber
                    finishHandler:(ChangeCartGiftNumberFinishHandler)finishHandler;

/**
 *  15.10.删除购物车商品接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 */
typedef void (^RemoveCartGiftFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

/**
 *  15.10.删除购物车商品接口
 *
 *  @param anchorId         主播ID
 *  @param giftId           礼品ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)removeCartGift:(NSString*)anchorId
                     giftId:(NSString*)giftId
              finishHandler:(RemoveCartGiftFinishHandler)finishHandler;

/**
 *  15.11.Checkout商品接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param item             checkout数据
 */
typedef void (^CheckOutCartGiftFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSCheckoutItemObject* item);

/**
 *  15.11.Checkout商品接口
 *
 *  @param anchorId         主播ID
 *  @param finishHandler    接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)checkOutCartGift:(NSString*)anchorId
                finishHandler:(CheckOutCartGiftFinishHandler)finishHandler;

/**
 *  15.12.生成订单接口回调
 *
 *  @param success          成功失败
 *  @param errnum           错误码
 *  @param errmsg           错误提示
 *  @param orderNumber      单号
 */
typedef void (^CreateGiftOrderFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *orderNumber);

/**
 *  15.12.生成订单接口
 *
 *  @param anchorId                 主播ID
 *  @param greetingMessage          文本信息
 *  @param specialDeliveryRequest   文本信息
 *  @param finishHandler            接口回调
 *
 *  @return 成功请求Id
 */
- (NSInteger)createGiftOrder:(NSString*)anchorId
             greetingMessage:(NSString*)greetingMessage
      specialDeliveryRequest:(NSString*)specialDeliveryRequest
               finishHandler:(CreateGiftOrderFinishHandler)finishHandler;


#pragma mark - 广告模块回调

/**
 *  9.2.查询女士列表广告接口回调
 *
 *  @param success      成功失败
 *  @param errnum       错误码
 *  @param errmsg       错误提示
 *  @param item         女士列表广告信息
 */

typedef void (^WonmanListAdvertFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, LSWomanListAdItemObject* item);
/**
 *  6.25.获取直播主播列表广告接口
 *
 *  @param finishHandler    回调
 */
- (NSInteger)wonmanListAdvert:(WonmanListAdvertFinishHandler )finishHandler;

@end
