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
#include "HttpRegisterPhoneTask.h"
#include "HttpRegisterCheckPhoneTask.h"
#include "HttpRegisterGetSMSCodeTask.h"
#include "HttpLiveRoomCreateTask.h"
#include "HttpCheckLiveRoomTask.h"
#include "HttpCloseLiveRoomTask.h"
#include "HttpGetLiveRoomFansListTask.h"
#include "HttpGetLiveRoomHotTask.h"
#include "HttpGetLiveRoomAllFansListTask.h"
#include "HttpGetLiveRoomUserPhotoTask.h"
#include "HttpGetLiveRoomModifyInfoTask.h"
#include "HttpSetLiveRoomModifyInfoTask.h"
#include "HttpUpdateLiveRoomTokenIdTask.h"
#include "HttpUploadLiveRoomImgTask.h"
#include "HttpGetLiveRoomPhotoListTask.h"
#include "HttpAddLiveRoomPhotoTask.h"
#include "HttpSetUsingLiveRoomPhotoTask.h"
#include "HttpDelLiveRoomPhotoTast.h"
#include "HttpGetLiveRoomAllGiftListTask.h"
#include "HttpGetLiveRoomGiftListByUserIdTask.h"
#include "HttpGetLiveRoomGiftDetailTask.h"
#include "HttpGetLiveRoomConfigTask.h"
#include <common/KSafeMap.h>
#include "HttpRequestEnum.h"

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
     *  2.1.验证手机是否已注册接口
     *
     * @param pHttpRequestManager           http管理器
     * @param phoneno                       手机号码
     * @param areno                         手机区号
     * @param callback                      接口回调
     *
     *  @return                             成功请求Id
     */
    long long RegisterCheckPhone(
                          HttpRequestManager *pHttpRequestManager,
                          const string& phoneno,
                          const string& areno,
                          IRequestRegisterCheckPhoneCallback* callback = NULL
                          );
    
    /**
     *  2.2.获取手机注册短信验证码接口
     *
     * @param pHttpRequestManager           http管理器
     * @param phoneno                       手机号码
     * @param areno                         手机区号
     * @param callback                      接口回调
     *
     *  @return                             成功请求Id
     */
    long long RegisterGetSMSCode(
                          HttpRequestManager *pHttpRequestManager,
                          const string& phoneno,
                          const string& areno,
                          IRequestRegisterGetSMSCodeCallback* callback = NULL
                          );
    
    
    /**
     *  2.3.手机注册接口
     *
     * @param pHttpRequestManager           http管理器
     * @param phoneno                       手机号码（仅当type ＝ 0 时使用）
     * @param areno                         手机区号（仅当type ＝ 0 时使用）
     * @param checkCode                     验证码
     * @param password                      登录密码
     * @param deviceId                      设备唯一标识
     * @param model                         设备型号（格式：设备型号－系统版本号）
     * @param manufacturer                  制造厂商
     * @param callback                      接口回调
     *
     *  @return                             成功请求Id
     */
    long long RegisterPhone(
                          HttpRequestManager *pHttpRequestManager,
                          const string& phoneno,
                          const string& areno,
                          const string& checkCode,
                          const string& password,
                          const string& deviceId,
                          const string& model,
                          const string& manufacturer,
                          IRequestRegisterPhoneCallback* callback = NULL
    );
    
    /**
     *  2.4.登陆接口
     *
     * @param pHttpRequestManager           http管理器
     * @param type                          登录类型（0: 手机登录 1:邮箱登录）
     * @param phoneno                       手机号码（仅当type ＝ 0 时使用）
     * @param areno                         手机区号（仅当type ＝ 0 时使用）
     * @param password                      登录密码
     * @param deviceid                      设备唯一标识
     * @param model                         设备型号（格式：设备型号－系统版本号）
     * @param manufacturer                  制造厂商
     * @param autoLogin                     是否自动登录
     *  @param callback                     接口回调
     *
     *  @return                             成功请求Id
     */
    long long     Login(
                        HttpRequestManager *pHttpRequestManager,
                        LoginType type,
                        const string& phoneno,
                        const string& areno,
                        const string& password,
                        const string& deviceid,
                        const string& model,
                        const string& manufacturer,
                        bool autoLogin,
                        IRequestLoginCallback* callback = NULL
                        );
    
    
    /**
     *  2.5.注销接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long Logout(
                     HttpRequestManager *pHttpRequestManager,
                     const string& token,
                     IRequestLogoutCallback* callback = NULL
                     );
    
    /**
     *  2.6.上传tokenid接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param tokenId                       用于Push Notification的ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long UpdateLiveRoomTokenId(
                                    HttpRequestManager *pHttpRequestManager,
                                    const string& token,
                                    const string& tokenId,
                                    IRequestUpdateLiveRoomTokenIdCallback* callback = NULL
                                    );
    
    /**
     *  3.1.新建直播间接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param roomName                      直播间名称
     * @param roomPhotoId                   封面图ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long CreateLiveRoom(
                     HttpRequestManager *pHttpRequestManager,
                     const string& token,
                     const string& roomName,
                     const string& roomPhotoId,
                     IRequestLiveRoomCreateCallback* callback = NULL
                     );
    
    /**
     *  3.2.获取本人正在直播的直播间信息接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long CheckLiveRoom(
                             HttpRequestManager *pHttpRequestManager,
                             const string& token,
                             IRequestCheckLiveRoomCallback* callback = NULL
                             );
    
    /**
     *  3.3.关闭直播间息接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param roomId                        直播间ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long CloseLiveRoom(
                            HttpRequestManager *pHttpRequestManager,
                            const string& token,
                            const string& roomId,
                            IRequestCloseLiveRoomCallback* callback = NULL
                            );
    /**
     *  3.4.获取直播间观众头像列表（限定数量）接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param roomId                        直播间ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLiveRoomFansList(
                            HttpRequestManager *pHttpRequestManager,
                            const string& token,
                            const string& roomId,
                            IRequestGetLiveRoomFansListCallback* callback = NULL
                            );
    
    /**
     *  3.5.获取直播间所有观众头像列表接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param roomId                        直播间ID
     * @param start                         起始，用于分页，表示从第几个元素开始获取
     * @param step                          步长，用于分页，表示本次请求获取多少个元素
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLiveRoomAllFansList(
                                     HttpRequestManager *pHttpRequestManager,
                                     const string& token,
                                     const string& roomId,
                                     int start,
                                     int step,
                                     IRequestGetLiveRoomAllFansListCallback* callback = NULL
                                     );
    
    /**
     *  3.6.获取Hot列表接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param start                         起始，用于分页，表示从第几个元素开始获取
     * @param step                          步长，用于分页，表示本次请求获取多少个元素
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLiveRoomHotList(
                                  HttpRequestManager *pHttpRequestManager,
                                  const string& token,
                                  int start,
                                  int step,
                                  IRequestGetLiveRoomHotCallback* callback = NULL
                                  );

    /**
     *  3.7.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLiveRoomAllGiftList(
                                   HttpRequestManager *pHttpRequestManager,
                                   const string& token,
                                   IRequestGetLiveRoomAllGiftListCallback* callback = NULL
                                   );
    
    /**
     *  3.8.获取直播间可发送的礼物列表（观众端获取已进入的直播间可发送的礼物列表）
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param roomId                        直播间ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLiveRoomGiftListByUserId(
                                     HttpRequestManager *pHttpRequestManager,
                                     const string& token,
                                     const string& roomId,
                                     IRequestGetLiveRoomGiftListByUserIdCallback* callback = NULL
                                     );
    
    /**
     *  3.9.获取指定礼物详情（用于观众端／主播端在直播间收到《3.7.》没有礼物时，获取指定礼物详情来显示）
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param giftId                        礼物ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLiveRoomGiftDetail(
                                    HttpRequestManager *pHttpRequestManager,
                                    const string& token,
                                    const string& giftId,
                                    IRequestGetLiveRoomGiftDetailCallback* callback = NULL
                                    );
    
    
    /**
     *  3.10.获取开播封面图列表（用于主播开播前，获取封面图列表）
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLiveRoomPhotoList(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& token,
                                 IRequestGetLiveRoomPhotoListCallback* callback = NULL
                                 );
    
    /**
     *  3.11.添加开播封面图（用于主播添加开播封面图）
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param photoId                       封面图ID    
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long AddLiveRoomPhoto(
                             HttpRequestManager *pHttpRequestManager,
                             const string& token,
                             const string& photoId,
                             IRequestAddLiveRoomPhotoCallback* callback = NULL
                            );
    
    /**
     *  3.12.设置默认使用封面图（用于主播设置默认的封面图）
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param photoId                       封面图ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long SetUsingLiveRoomPhoto(
                               HttpRequestManager *pHttpRequestManager,
                               const string& token,
                               const string& photoId,
                               IRequestSetUsingLiveRoomPhotoCallback* callback = NULL
                               );
    
    /**
     *  3.13.删除开播封面图（用于主播删除开播封面图）
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param photoId                       封面图ID
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long DelLiveRoomPhoto(
                            HttpRequestManager *pHttpRequestManager,
                            const string& token,
                            const string& photoId,
                            IRequestDelLiveRoomPhotoCallback* callback = NULL
                            );
    
    
    /**
     *  4.1.获取用户头像接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param userId                        用户ID
     * @param photoType                     头像类型（0：小图（用于直播间显示头像） 1:大图（用于个人信息界面等显示头像））
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLiveRoomUserPhoto(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& token,
                                 const string& userId,
                                 PhotoType photoType,
                                 IRequestGetLiveRoomUserPhotoCallback* callback = NULL
                                 );
    
    /**
     *  4.2.获取可编辑的本人资料接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLiveRoomModifyInfo(
                                   HttpRequestManager *pHttpRequestManager,
                                   const string& token,
                                   IRequestGetLiveRoomModifyInfoCallback* callback = NULL
                                   );
    
    /**
     *  4.3.提交本人资料接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param photoId                       头像图片ID（可无，无则表示不修改）
     * @param nickName                      昵称
     * @param gender                        性别（0：男性 1:女性）
     * @param birthday                      出生日期（格式： 1980-01-01）
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long SetLiveRoomModifyInfo(
                                   HttpRequestManager *pHttpRequestManager,
                                   const string& token,
                                   const string& photoId,
                                   const string& nickName,
                                   Gender gender,
                                   const string& birthday,
                                   IRequestSetLiveRoomModifyInfoCallback* callback = NULL
                                   );
    
    /**
     *  5.1.同步配置（用于客户端获取http接口服务器，IM服务器及上传图片服务器域名及端口等配置）
     *
     * @param pHttpRequestManager           http管理器
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long GetLiveRoomConfig(
                                HttpRequestManager *pHttpRequestManager,
                                IRequestGetLiveRoomConfigCallback* callback = NULL
                                );
    
    /**
     *  5.2.上传图片接口
     *
     * @param pHttpRequestManager           http管理器
     * @param token                         用户身份唯一标识
     * @param imageType                     图片类型（1：用户头像， 2:直播间封面图）
     * @param imageFileName                 图片文件二进制数据
     * @param callback                      接口回调
     *
     * @return                              成功请求Id
     */
    long long UploadLiveRoomImg(
                                HttpRequestManager *pHttpRequestManager,
                                const string& token,
                                const ImageType imageType,
                                const string& imageFileName,
                                IRequestUploadLiveRoomImgCallback* callback = NULL
                                );
    
private:
    void OnTaskFinish(IHttpTask* task);
    
private:
    RequestMap mRequestMap;
};

#endif /* HttpRequestController_h */
