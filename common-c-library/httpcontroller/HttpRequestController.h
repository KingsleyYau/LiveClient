//
//  HttpRequestController.h
//  Common-C-Library
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#ifndef HttpRequestController_h
#define HttpRequestController_h

#include "HttpLoginTask.h"
#include "HttpLogoutTask.h"
#include "HttpUpdateTokenIdTask.h"
#include "HttpGetAnchorListTask.h"
#include "HttpGetFollowListTask.h"
#include "HttpGetRoomInfoTask.h"
#include "HttpLiveFansListTask.h"
#include "HttpGetAllGiftListTask.h"
#include "HttpGetGiftListByUserIdTask.h"
#include "HttpGetGiftDetailTask.h"
#include "HttpGetEmoticonListTask.h"
#include "HttpGetInviteInfoTask.h"
#include "HttpGiftListTask.h"
#include "HttpGetConfigTask.h"
#include "HttpGetLeftCreditTask.h"
#include "HttpManHandleBookingListTask.h"
#include "HttpHandleBookingTask.h"
#include "HttpSendCancelPrivateLiveInviteTask.h"
#include "HttpManBookingUnreadUnhandleNumTask.h"
#include "HttpGetTalentListTask.h"
#include "HttpGetTalentStatusTask.h"
#include "HttpGetCreateBookingInfoTask.h"
#include "HttpSendBookingRequestTask.h"
#include "HttpVoucherListTask.h"
#include "HttpRideListTask.h"
#include "HttpSetRideTask.h"
#include "HttpGetBackpackUnreadNumTask.h"
#include "HttpSetFavoriteTask.h"
#include "HttpGetNewFansBaseInfoTask.h"
#include "HttpControlManPushTask.h"
#include "HttpGetPromoAnchorListTask.h"
#include "HttpAcceptInstanceInviteTask.h"
#include "HttpGetAdAnchorListTask.h"
#include "HttpCloseAdAnchorListTask.h"
#include "HttpGetPhoneVerifyCodeTask.h"
#include "HttpSubmitPhoneVerifyCodeTask.h"
#include "HttpServerSpeedTask.h"
#include "HttpBannerTask.h"
#include "HttpGetUserInfoTask.h"
#include "HttpOwnFackBookLoginTask.h"
#include "HttpOwnRegisterTask.h"
#include "HttpOwnEmailLoginTask.h"
#include "HttpOwnFindPasswordTask.h"
#include "HttpOwnCheckMailRegistrationTask.h"
#include "HttpGetShareLinkTask.h"
#include "HttpSetShareSucTask.h"
#include "HttpUploadPhotoTask.h"
#include "HttpPremiumMembershipTask.h"
#include "HttpGetIOSPayTask.h"
#include "HttpIOSPayCallTask.h"
#include "HttpSubmitFeedBackTask.h"
#include "HttpGetManBaseInfoTask.h"
#include "HttpSetManBaseInfoTask.h"
#include "HttpGetVerificationCodeTask.h"
#include <common/KSafeMap.h>

#include <stdio.h>

#include <string>
using namespace std;

#define HTTPREQUEST_INVALIDREQUESTID	0

class IHttpTask;
typedef KSafeMap<IHttpTask*, IHttpTask*> RequestMap;

class HttpRequestController : public IHttpTaskCallback {
public:
    HttpRequestController();
    ~HttpRequestController();
    
    void Stop(long long requestId);

    /**
     *  2.1.登陆接口
     *
     * @param pHttpRequestManager           http管理器
     * @param manId                         QN会员ID
     * @param userSid                       QN系统登录验证返回的标识
     * @param deviceid                      设备唯一标识
     * @param model                         设备型号（格式：设备型号－系统版本号）
     * @param manufacturer                  制造厂商
     *  @param callback                     接口回调
     *
     *  @return                             成功请求Id
     */
    long long     Login(
                        HttpRequestManager *pHttpRequestManager,
                        const string& manId,
                        const string& userSid,
                        const string& deviceid,
                        const string& model,
                        const string& manufacturer,
                        IRequestLoginCallback* callback = NULL
                        );
    
    
    /**
     *  2.2.注销接口
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long Logout(
                     HttpRequestManager *pHttpRequestManager,
                     IRequestLogoutCallback* callback = NULL
                     );
    
    /**
     *  2.3.上传tokenid接口
     *
     * @param pHttpRequestManager           http管理器
     * @param tokenId                       用于Push Notification的ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long UpdateTokenId(
                            HttpRequestManager *pHttpRequestManager,
                            const string& tokenId,
                            IRequestUpdateTokenIdCallback* callback = NULL
                            );
    
    /**
     *  2.4.Facebook注册及登录（仅独立）
     *
     * @param pHttpRequestManager           http管理器
     * @param fToken                              Facebook登录返回的accessToken
     * @param versionCode                         客户端内部版本号
     * @param utmReferrer                         APP推广参数（google play返回的referrer，格式：UrlEncode(referrer)）
     * @param model                               设备型号
     * @param deviceId                            设备唯一标识
     * @param manufacturer                        制造厂商
     * @param inviteCode                          推荐码（可无）
     * @param email                               用户注册的邮箱（可无）
     * @param passWord                            登录密码（可无）
     * @param birthDay                            出生日期（可无，但未绑定时必须提交，格式为：2015-02-20）
     
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long OwnFackBookLogin(
                               HttpRequestManager *pHttpRequestManager,
                               const string& fToken,
                               const string& versionCode,
                               const string& utmReferrer,
                               const string& model,
                               const string& deviceId,
                               const string& manufacturer,
                               const string& inviteCode = "",
                               const string& email = "",
                               const string& passWord = "",
                               const string& birthDay = "",
                               IRequestOwnFackBookLoginCallback* callback = NULL
                            );
    
    
    /**
     *  2.5.邮箱注册（仅独立）
     *
     * @param pHttpRequestManager           http管理器
     * @param email                电子邮箱
     * @param passWord             密码
     * @param gender               性别（M：男，F：女）
     * @param nickName             昵称
     * @param birthDay             出生日期（格式为：2015-02-20）
     * @param inviteCode           推荐码（可无）
     * @param model                设备型号
     * @param deviceid             设备唯一标识
     * @param manufacturer         制造厂商
     * @param utmReferrer          APP推广参数（google play返回的referrer，格式：UrlEncode(referrer)）
     
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long OwnRegister(
                              HttpRequestManager *pHttpRequestManager,
                              const string email,
                              const string passWord,
                              GenderType gender,
                              const string nickName,
                              const string birthDay,
                              const string inviteCode,
                              const string model,
                              const string deviceid,
                              const string manufacturer,
                              const string utmReferrer,
                               IRequestOwnRegisterCallback* callback = NULL
                               );
    
    /**
     *  2.6.邮箱登录（仅独立）
     *
     * @param pHttpRequestManager           http管理器
     * @param email                         用户的email或id
     * @param passWord                      登录密码
     * @param versionCode                   客户端内部版本号
     * @param model                         设备型号（格式：设备型号-系统版本号-API版本号-分辨率）
     * @param deviceid                      设备唯一标识
     * @param manufacturer                  制造厂商
     * @param checkCode                     验证码
     
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long OwnEmailLogin(
                          HttpRequestManager *pHttpRequestManager,
                          const string email,
                          const string passWord,
                          const string versionCode,
                          const string model,
                          const string deviceid,
                          const string manufacturer,
                          const string checkCode,
                          IRequestOwnEmailLoginCallback* callback = NULL
                          );
    
    /**
     *  2.7.找回密码（仅独立）
     *
     * @param pHttpRequestManager           http管理器
     * @param sendMail                      用户的email或id
     * @param checkCode                     验证码
     
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long OwnFindPassword(
                            HttpRequestManager *pHttpRequestManager,
                            const string sendMail,
                            const string checkCode,
                            IRequestOwnFindPasswordCallback* callback = NULL
                            );
    
    /**
     *  2.8.检测邮箱注册状态（仅独立）
     *
     * @param pHttpRequestManager           http管理器
     * @param email                         电子邮箱
     
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long OwnCheckMail(
                          HttpRequestManager *pHttpRequestManager,
                          const string email,
                          IRequestOwnCheckMailRegistrationCallback* callback = NULL
                          );
    
    /**
     *  2.9.提交用户头像接口（仅独立）
     *
     * @param pHttpRequestManager           http管理器
     * @param photoName                     上传头像文件名
     
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long OwnUploadPhoto(
                           HttpRequestManager *pHttpRequestManager,
                           const string photoName,
                           IRequestUploadPhotoCallback* callback = NULL
                           );
    
    /**
     *  2.10.获取验证码（仅独立）
     *
     * @param pHttpRequestManager           http管理器
     * @param verifyType                    验证码种类，（“login”：登录；“findpw”：找回密码）
     * @param useCode                       是否需要验证码，（1：必须；0：不限，服务端自动检测ip国家）
     
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetVerificationCode(
                                  HttpRequestManager *pHttpRequestManager,
                                  VerifyCodeType verifyType,
                                  bool useCode,
                                  IRequestGetVerificationCodeCallback* callback = NULL
                                  );
    
    /**
     *  3.1.获取Hot列表接口
     *
     * @param pHttpRequestManager           http管理器
     * @param start                         起始，用于分页，表示从第几个元素开始获取
     * @param step                          步长，用于分页，表示本次请求获取多少个元素
     * @param hasWatch                      是否只获取观众看过的主播（0: 否 1: 是  可无，无则默认为0
     * @param isForTest                     是否可看到测试主播（0：否，1：是）（整型）（可无，无则默认为0）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetAnchorList(
                            HttpRequestManager *pHttpRequestManager,
                            int start,
                            int step,
                            bool hasWatch,
                            bool isForTest,
                            IRequestGetAnchorListCallback* callback = NULL
                            );
    
    /**
     *  3.2.获取Following列表接口
     *
     * @param pHttpRequestManager           http管理器
     * @param start                         起始，用于分页，表示从第几个元素开始获取
     * @param step                          步长，用于分页，表示本次请求获取多少个元素
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetFollowList(
                             HttpRequestManager *pHttpRequestManager,
                             int start,
                             int step,
                             IRequestGetFollowListCallback* callback = NULL
                            );
    
    /**
     *  3.3.获取本人有效直播间或邀请信息接口(已废弃)
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetRoomInfo(
                        HttpRequestManager *pHttpRequestManager,
                        IRequestGetRoomInfoCallback* callback = NULL
                        );
    
    /**
     *  3.4.获取直播间观众头像列表接口
     *
     * @param pHttpRequestManager           http管理器
     * @param roomId                        直播间ID
     * @param start                         起始，用于分页，表示从第几个元素开始获取
     * @param step                          步长，用于分页，表示本次请求获取多少个元素
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long LiveFansList(
                           HttpRequestManager *pHttpRequestManager,
                           const string& roomId,
                           int start,
                           int step,
                           IRequestLiveFansListCallback* callback = NULL
                          );

    /**
     *  3.5.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetAllGiftList(
                            HttpRequestManager *pHttpRequestManager,
                            IRequestGetAllGiftListCallback* callback = NULL
                            );
    
    /**
     *  3.6.获取直播间可发送的礼物列表（观众端/主播端获取直播间的可发送的礼物列表, 包括背包礼物）
     *
     * @param pHttpRequestManager           http管理器
     * @param roomId                        直播间ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetGiftListByUserId(
                                  HttpRequestManager *pHttpRequestManager,
                                  const string& roomId,
                                  IRequestGetGiftListByUserIdCallback* callback = NULL
                                 );
    
    /**
     *  3.7.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）
     *
     * @param pHttpRequestManager           http管理器
     * @param giftId                        礼物ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetGiftDetail(
                            HttpRequestManager *pHttpRequestManager,
                            const string& giftId,
                            IRequestGetGiftDetailCallback* callback = NULL
                            );
    
    /**
     *  3.8.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetEmoticonList(
                            HttpRequestManager *pHttpRequestManager,
                            IRequestGetEmoticonListCallback* callback = NULL
                            );
    
    /**
     *  3.9.获取指定立即私密邀请信息
     *
     * @param pHttpRequestManager           http管理器
     * @param inviteId                      邀请ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetInviteInfo(
                            HttpRequestManager *pHttpRequestManager,
                            const string& inviteId,
                            IRequestGetInviteInfoCallback* callback = NULL
                            );
    
    /**
     *  3.10.获取才艺点播列表
     *
     * @param pHttpRequestManager           http管理器
     * @param roomId                        直播间ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetTalentList(
                            HttpRequestManager *pHttpRequestManager,
                            const string& roomId,
                            IRequestGetTalentListCallback* callback = NULL
                            );
    
    /**
     *  3.11.获取才艺点播邀请状态
     *
     * @param pHttpRequestManager           http管理器
     * @param roomId                        直播间ID
     * @param talentInviteId                才艺点播邀请ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetTalentStatus(
                            HttpRequestManager *pHttpRequestManager,
                            const string& roomId,
                            const string& talentInviteId,
                            IRequestGetTalentStatusCallback* callback = NULL
                            );
    
    /**
     *   3.12.获取指定观众信息
     *
     * @param pHttpRequestManager           http管理器
     * @param userId                        观众ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetNewFansBaseInfo(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& userId,
                                 IRequestGetNewFansBaseInfoCallback* callback = NULL
                                 );
    
    /**
     *  3.13.获取指定观众信息
     *
     * @param pHttpRequestManager           http管理器
     * @param roomId                        直播间ID
     * @param type                          视频操作（1:开始 2:关闭）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long ControlManPush(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& roomId,
                                 ControlType type,
                                 IRequestControlManPushCallback* callback = NULL
                                 );
    
    /**
     *  3.14.获取推荐主播列表
     *
     * @param pHttpRequestManager           http管理器
     * @param number                        获取推荐个数
     * @param type                          获取界面的类型（1:直播间 2:主播个人页）
     * @param userId                        当前界面的主播ID，返回结果将不包含当前主播（可无， 无则表示不过滤结果）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetPromoAnchorList(
                                 HttpRequestManager *pHttpRequestManager,
                                 int number,
                                 PromoAnchorType type,
                                 const string& userId,
                                 IRequestGetPromoAnchorListCallback* callback = NULL
                             );
    
    /**
     *  4.1.观众待处理的预约邀请列表
     *
     * @param pHttpRequestManager           http管理器
     * @param type                          列表类型（0:等待观众处理 1:等待主播处理 2:已确认 3：历史
     * @param start                         起始，用于分页，表示从第几个元素开始获取
     * @param step                          步长，用于分页，表示本次请求获取多少个元素
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long ManHandleBookingList(
                                   HttpRequestManager *pHttpRequestManager,
                                   BookingListType type,
                                   int start,
                                   int step,
                                   IRequestManHandleBookingListCallback* callback = NULL
                                   );
    
    /**
     *  4.2.观众处理预约邀请
     *
     * @param pHttpRequestManager           http管理器
     * @param inviteId                      邀请ID
     * @param isConfirm                     是否同意（0:否 1:是）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long HandleBooking(
                            HttpRequestManager *pHttpRequestManager,
                            const string& inviteId,
                            bool isConfirm,
                            IRequestHandleBookingCallback* callback = NULL
                            );
    
    /**
     *  4.3.取消预约邀请
     *
     * @param pHttpRequestManager           http管理器
     * @param invitationId                  邀请ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long SendCancelPrivateLiveInvite(
                                          HttpRequestManager *pHttpRequestManager,
                                          const string& invitationId,
                                          IRequestSendCancelPrivateLiveInviteCallback* callback = NULL
                                          );
    
    /**
     *  4.4.获取预约邀请未读或待处理数量
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long ManBookingUnreadUnhandleNum(
                                          HttpRequestManager *pHttpRequestManager,
                                          IRequestManBookingUnreadUnhandleNumCallback* callback = NULL
                                          );
    
    /**
     *  4.5.获取新建预约邀请信息
     *
     * @param pHttpRequestManager           http管理器
     * @param userId                        主播ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetCreateBookingInfo(
                                    HttpRequestManager *pHttpRequestManager,
                                    const string& userId,
                                    IRequestGetCreateBookingInfoCallback* callback = NULL
                                );
    /**
     *  4.6.新建预约邀请
     *
     * @param pHttpRequestManager           http管理器
     * @param userId                        主播ID
     * @param timeId                        预约时间ID
     * @param bookTime                      预约时间
     * @param giftId                        礼物ID
     * @param giftNum                       礼物数量
     * @param needSms                       是否需要短信通知（0:否 1:是 ）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long SendBookingRequest(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& userId,
                                 const string& timeId,
                                 long bookTime,
                                 const string& giftId,
                                 int giftNum,
                                 bool needSms,
                                 IRequestSendBookingRequestCallback* callback = NULL
                                );
    
    /**
     *  4.7.观众处理立即私密邀请
     *
     * @param pHttpRequestManager           http管理器
     * @param inviteId                      邀请ID
     * @param isConfirm                     是否同意（0: 否， 1: 是）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long AcceptInstanceInvite(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& inviteId,
                                 bool isConfirm,
                                 IRequestAcceptInstanceInviteCallback* callback = NULL
                                 );
    
    /**
     *  5.1.获取背包礼物列表
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GiftList(
                       HttpRequestManager *pHttpRequestManager,
                       IRequestGiftListCallback* callback = NULL
                       );
    
    /**
     *  5.2.获取使用劵列表
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long VoucherList(
                          HttpRequestManager *pHttpRequestManager,
                          IRequestVoucherListCallback* callback = NULL
                          );
    /**
     *  5.3.获取座驾列表
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long RideList(
                       HttpRequestManager *pHttpRequestManager,
                       IRequestRideListCallback* callback = NULL
                       );
    
    /**
     *  5.4.使用／取消座驾
     *
     * @param pHttpRequestManager           http管理器
     * @param rideId                        座驾ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long SetRide(
                       HttpRequestManager *pHttpRequestManager,
                       const string& rideId,
                       IRequestSetRideCallback* callback = NULL
                       );
    
    /**
     *  5.5.获取背包未读数量
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetBackpackUnreadNum(
                                   HttpRequestManager *pHttpRequestManager,
                                   IRequestGetBackpackUnreadNumCallback* callback = NULL
                                   );
    
    /**
     *  6.1.同步配置
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetConfig(
                       HttpRequestManager *pHttpRequestManager,
                       IRequestGetConfigCallback* callback = NULL
                       );

    /**
     *  6.2.获取账号余额
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLeftCredit(
                        HttpRequestManager *pHttpRequestManager,
                        IRequestGetLeftCreditCallback* callback = NULL
                        );
    
    /**
     *  6.3.添加／取消收藏
     *
     * @param pHttpRequestManager           http管理器
     * @param userId                        主播ID
     * @param roomId                        直播间ID（可无，无则表示不在直播间操作）
     * @param isFav                         是否收藏（0:否 1:是）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long SetFavorite(
                            HttpRequestManager *pHttpRequestManager,
                            const string& userId,
                            const string& roomId,
                            bool isFav,
                            IRequestSetFavoriteCallback* callback = NULL
                            );
    
    /**
     *  6.4.获取QN广告列表
     *
     * @param pHttpRequestManager           http管理器
     * @param number                        客户段需要获取的数量
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetAdAnchorList(
                              HttpRequestManager *pHttpRequestManager,
                              int number,
                              IRequestGetAdAnchorListCallback* callback = NULL
                              );
    
    /**
     *  6.5.关闭QN广告列表
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long CloseAdAnchorList(
                                HttpRequestManager *pHttpRequestManager,
                                IRequestCloseAdAnchorListCallback* callback = NULL
                              );
    
    /**
     * 6.6.获取手机验证码
     *
     * @param pHttpRequestManager           http管理器
     * @param country                       国家
     * @param areaCode                      手机区号
     * @param phoneNo                       手机号码
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetPhoneVerifyCode(
                                HttpRequestManager *pHttpRequestManager,
                                const string& country,
                                const string& areaCode,
                                const string& phoneNo,
                                IRequestGetPhoneVerifyCodeCallback* callback = NULL
                                 );
    
    /**
     * 6.7.提交手机验证码
     *
     * @param pHttpRequestManager           http管理器
     * @param country                       国家
     * @param areaCode                      手机区号
     * @param phoneNo                       手机号码
     * @param verifyCode                    验证码
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long SubmitPhoneVerifyCode(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& country,
                                 const string& areaCode,
                                 const string& phoneNo,
                                 const string& verifyCode,
                                 IRequestSubmitPhoneVerifyCodeCallback* callback = NULL
                                 );
    
    /**
     * 6.8.提交流媒体服务器测速结果
     *
     * @param pHttpRequestManager           http管理器
     * @param sid                           流媒体服务器ID
     * @param res                           http请求完成时间（毫秒）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long ServerSpeed(
                        HttpRequestManager *pHttpRequestManager,
                        const string& sid,
                        int res,
                        IRequestServerSpeedCallback* callback = NULL
                        );
    
    /**
     * 6.9.获取Hot/Following列表头部广告
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long Banner(
                     HttpRequestManager *pHttpRequestManager,
                    IRequestBannerCallback* callback = NULL
                    );
    
    /**
     * 6.10.获取主播/观众信息
     *
     * @param pHttpRequestManager           http管理器
     * @param userId                        观众ID或主播ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetUserInfo(
                          HttpRequestManager *pHttpRequestManager,
                          const string& userId,
                          IRequestGetUserInfoCallback* callback = NULL
                     );
    
    /**
     * 6.11.获取分享链接
     *
     * @param pHttpRequestManager           http管理器
     * @param shareuserId                   发起分享的主播/观众ID
     * @param anchorId                      被分享的主播ID
     * @param shareType                     分享渠道（0：其它，1：Facebook，2：Twitter）
     * @param sharePageType                 分享类型（1：主播资料页，2：免费公开直播间）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetShareLink(
                          HttpRequestManager *pHttpRequestManager,
                          const string& shareuserId,
                          const string& anchorId,
                          ShareType shareType,
                          SharePageType sharePageType,
                          IRequestGetShareLinkCallback* callback = NULL
                          );
    
    /**
     * 6.12.分享链接成功
     *
     * @param pHttpRequestManager           http管理器
     * @param shareId                       分享ID（参考《6.11.获取分享链接（http post）》的shareid参数）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long SetShareSuc(
                           HttpRequestManager *pHttpRequestManager,
                           const string& shareId,
                           IRequestSetShareSucCallback* callback = NULL
                           );
    
    /**
     * 6.13.提交Feedback（仅独立）
     *
     * @param pHttpRequestManager           http管理器
     * mail                                 用户邮箱
     * msg                                  feedback内容）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long SubmitFeedBack(
                             HttpRequestManager *pHttpRequestManager,
                             const string& mail,
                             const string& msg,
                             IRequestSubmitFeedBackCallback* callback = NULL
                             );
    
    /**
     * 6.14.获取个人信息（仅独立）
     *
     * @param pHttpRequestManager           http管理器）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetManBaseInfo(
                             HttpRequestManager *pHttpRequestManager,
                             IRequestGetManBaseInfoCallback* callback = NULL
                             );
    
    /**
     * 6.15.设置个人信息（仅独立）
     *
     * @param pHttpRequestManager           http管理器）
     * @param nickName                      昵称
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long SetManBaseInfo(
                             HttpRequestManager *pHttpRequestManager,
                             const string& nickName,
                             IRequestSetManBaseInfoCallback* callback = NULL
                             );
    
    /**
     * 7.1.获取买点信息（仅独立）（仅iOS）
     *
     * @param pHttpRequestManager           http管理器
     * @param siteId                        站点ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long PremiumMembership(
                          HttpRequestManager *pHttpRequestManager,
                          const string& siteId,
                          IRequestPremiumMembershipCallback* callback = NULL
                          );
    
    /**
     * 7.2.获取订单信息（仅独立）（仅iOS）
     *
     * @param pHttpRequestManager           http管理器
     * @param manid            男士ID
     * @param sid              跨服务器唯一标识
     * @param number           信用点套餐ID
     * @param siteid           站点ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetIOSPay(
                        HttpRequestManager *pHttpRequestManager,
                        const string& manid,
                        const string& sid,
                        const string& number,
                        const string& siteid,
                        IRequestGetIOSPayCallback* callback = NULL
                        );
    
    /**
     * 7.3.验证订单信息（仅独立）（仅iOS）
     *
     * @param pHttpRequestManager           http管理器
     * manid            男士ID
     * sid              跨服务器唯一标识
     * receipt          AppStore支付成功返回的receipt参数
     * orderNo          订单号
     * code             AppStore支付完成返回的状态code（APPSTOREPAYTYPE_PAYSUCCES：支付成功，APPSTOREPAYTYPE_PAYFAIL：支付失败，APPSTOREPAYTYPE_PAYRECOVERY：恢复交易(仅非消息及自动续费商品)，APPSTOREPAYTYPE_NOIMMEDIATELYPAY：无法立即支付）（可无，默认：APPSTOREPAYTYPE_PAYSUCCES）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long IOSPayCall(
                        HttpRequestManager *pHttpRequestManager,
                        const string& manid,
                        const string& sid,
                        const string& receipt,
                        const string& orderNo,
                        AppStorePayCodeType code,
                        IRequestIOSPayCallCallback* callback = NULL
                        );
private:
    void OnTaskFinish(IHttpTask* task);
    
private:
    RequestMap mRequestMap;
};

#endif /* HttpRequestController_h */
