              //
//  HttpRequestController.cpp
//  Common-C-Library
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#include "HttpRequestController.h"

HttpRequestController::HttpRequestController() {

}

HttpRequestController::~HttpRequestController() {
    
}

void HttpRequestController::OnTaskFinish(IHttpTask* task) {
    FileLog(LIVESHOW_HTTP_LOG, "HttpRequestController::OnTaskFinish( task : %p )", task);
    
    // 清除回调
    mRequestMap.Lock();
    mRequestMap.Erase(task);
    mRequestMap.Unlock();
    
    // 删除请求
    delete task;
}

void HttpRequestController::Stop(long long requestId) {
    mRequestMap.Lock();
    IHttpTask* task = (IHttpTask*)requestId;
    RequestMap::iterator itr = mRequestMap.Find(task);
    if( itr != mRequestMap.End() ) {
        task->Stop();
    }
    mRequestMap.Unlock();
}


long long HttpRequestController::Login(
                                       HttpRequestManager *pHttpRequestManager,
                                       const string& manId,
                                       const string& userSid,
                                       const string& deviceid,
                                       const string& model,
                                       const string& manufacturer,
                                       RegionIdType regionId,
                                       IRequestLoginCallback* callback
                                       ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpLoginTask* task = new HttpLoginTask();
    task->Init(pHttpRequestManager);
    task->SetParam(manId, userSid, deviceid, model, manufacturer, regionId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::Logout(
                                        HttpRequestManager *pHttpRequestManager,
                                        IRequestLogoutCallback* callback
                                        ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpLogoutTask* task = new HttpLogoutTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::UpdateTokenId(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string& tokenId,
                                                IRequestUpdateTokenIdCallback* callback
                                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpUpdateTokenIdTask* task = new HttpUpdateTokenIdTask();
    task->Init(pHttpRequestManager);
    task->SetParam(tokenId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::OwnFackBookLogin(
                                                  HttpRequestManager *pHttpRequestManager,
                                                  const string& fToken,
                                                  const string& nickName,
                                                  const string& utmReferrer,
                                                  const string& model,
                                                  const string& deviceId,
                                                  const string& manufacturer,
                                                  const string& inviteCode,
                                                  const string& email,
                                                  const string& passWord,
                                                  const string& birthDay ,
                                                  GenderType gender,
                                                  IRequestOwnFackBookLoginCallback* callback
                                                  ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpOwnFackBookLoginTask* task = new HttpOwnFackBookLoginTask();
    task->Init(pHttpRequestManager);
    task->SetParam(model, deviceId, manufacturer, fToken, email, passWord, birthDay, inviteCode, nickName, utmReferrer, gender);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::OwnRegister(
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
                                             IRequestOwnRegisterCallback* callback
                                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpOwnRegisterTask* task = new HttpOwnRegisterTask();
    task->Init(pHttpRequestManager);
    task->SetParam(email, passWord, gender, nickName, birthDay, inviteCode, model, deviceid, manufacturer, utmReferrer);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::OwnEmailLogin(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string email,
                                               const string passWord,
                                               const string model,
                                               const string deviceid,
                                               const string manufacturer,
                                               IRequestOwnEmailLoginCallback* callback
                                               ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpOwnEmailLoginTask* task = new HttpOwnEmailLoginTask();
    task->Init(pHttpRequestManager);
    task->SetParam(email, passWord, model, deviceid, manufacturer);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::OwnFindPassword(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string sendMail,
                                                 const string checkCode,
                                                 IRequestOwnFindPasswordCallback* callback
                                                 ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpOwnFindPasswordTask* task = new HttpOwnFindPasswordTask();
    task->Init(pHttpRequestManager);
    task->SetParam(sendMail, checkCode);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::OwnCheckMail(
                                              HttpRequestManager *pHttpRequestManager,
                                              const string email,
                                              IRequestOwnCheckMailRegistrationCallback* callback
                                              ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpOwnCheckMailRegistrationTask* task = new HttpOwnCheckMailRegistrationTask();
    task->Init(pHttpRequestManager);
    task->SetParam(email);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::OwnUploadPhoto(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string photoName,
                                                IRequestUploadPhotoCallback* callback
                                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpUploadPhotoTask* task = new HttpUploadPhotoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(photoName);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetVerificationCode(
                                                     HttpRequestManager *pHttpRequestManager,
                                                     VerifyCodeType verifyType,
                                                     bool useCode,
                                                     IRequestGetVerificationCodeCallback* callback
                                                     ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetVerificationCodeTask* task = new HttpGetVerificationCodeTask();
    task->Init(pHttpRequestManager);
    task->SetParam(verifyType, useCode);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetAnchorList(
                                               HttpRequestManager *pHttpRequestManager,
                                               int start,
                                               int step,
                                               bool hasWatch,
                                               bool isForTest,
                                               IRequestGetAnchorListCallback* callback
                                               ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetAnchorListTask* task = new HttpGetAnchorListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(start, step, hasWatch, isForTest);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetFollowList(
                                                HttpRequestManager *pHttpRequestManager,
                                                int start,
                                                int step,
                                                IRequestGetFollowListCallback* callback
                                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetFollowListTask* task = new HttpGetFollowListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetRoomInfo(
                                             HttpRequestManager *pHttpRequestManager,
                                             IRequestGetRoomInfoCallback* callback
                                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetRoomInfoTask* task = new HttpGetRoomInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::LiveFansList(
                                              HttpRequestManager *pHttpRequestManager,
                                              const string& roomId,
                                              int start,
                                              int step,
                                              IRequestLiveFansListCallback* callback
                                              ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpLiveFansListTask* task = new HttpLiveFansListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomId, start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}



long long HttpRequestController::GetAllGiftList(
                                                HttpRequestManager *pHttpRequestManager,
                                                IRequestGetAllGiftListCallback* callback
                                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetAllGiftListTask* task = new HttpGetAllGiftListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetGiftListByUserId(
                                                     HttpRequestManager *pHttpRequestManager,
                                                     const string& roomId,
                                                     IRequestGetGiftListByUserIdCallback* callback
                                                     ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetGiftListByUserIdTask* task = new HttpGetGiftListByUserIdTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetGiftDetail(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& giftId,
                                               IRequestGetGiftDetailCallback* callback
                                               ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;

    HttpGetGiftDetailTask* task = new HttpGetGiftDetailTask();
    task->Init(pHttpRequestManager);
    task->SetParam(giftId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);

    requestId = (long long)task;

    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();

    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::GetEmoticonList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 IRequestGetEmoticonListCallback* callback
                                                 ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetEmoticonListTask* task = new HttpGetEmoticonListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetInviteInfo(
                        HttpRequestManager *pHttpRequestManager,
                        const string& inviteId,
                        IRequestGetInviteInfoCallback* callback
                                               ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetInviteInfoTask* task = new HttpGetInviteInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetTalentList(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& roomId,
                                               IRequestGetTalentListCallback* callback
                                               ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetTalentListTask* task = new HttpGetTalentListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetTalentStatus(
                          HttpRequestManager *pHttpRequestManager,
                          const string& roomId,
                          const string& talentInviteId,
                          IRequestGetTalentStatusCallback* callback
                                                 ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetTalentStatusTask* task = new HttpGetTalentStatusTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomId, talentInviteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::GetNewFansBaseInfo(
                                                    HttpRequestManager *pHttpRequestManager,
                                                    const string& userId,
                                                    IRequestGetNewFansBaseInfoCallback* callback
                                                    ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetNewFansBaseInfoTask* task = new HttpGetNewFansBaseInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(userId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ControlManPush(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string& roomId,
                                                ControlType type,
                                                IRequestControlManPushCallback* callback
                                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpControlManPushTask* task = new HttpControlManPushTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomId, type);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetPromoAnchorList(
                             HttpRequestManager *pHttpRequestManager,
                             int number,
                             PromoAnchorType type,
                             const string& userId,
                             IRequestGetPromoAnchorListCallback* callback
                                                    ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPromoAnchorListTask* task = new HttpGetPromoAnchorListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(number, type, userId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ManHandleBookingList(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      BookingListType type,
                                                      int start,
                                                      int step,
                                                      IRequestManHandleBookingListCallback* callback
                                                      ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpManHandleBookingListTask* task = new HttpManHandleBookingListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(type, start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::HandleBooking(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& inviteId,
                                               bool isConfirm,
                                               IRequestHandleBookingCallback* callback
                                               ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpHandleBookingTask* task = new HttpHandleBookingTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId, isConfirm);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SendCancelPrivateLiveInvite(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      const string& invitationId,
                                                      IRequestSendCancelPrivateLiveInviteCallback* callback
                                                      ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSendCancelPrivateLiveInviteTask* task = new HttpSendCancelPrivateLiveInviteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(invitationId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ManBookingUnreadUnhandleNum(
                                                             HttpRequestManager *pHttpRequestManager,
                                                             IRequestManBookingUnreadUnhandleNumCallback* callback
                                                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpManBookingUnreadUnhandleNumTask* task = new HttpManBookingUnreadUnhandleNumTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetCreateBookingInfo(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& userId,
                                 IRequestGetCreateBookingInfoCallback* callback
                                 ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetCreateBookingInfoTask* task = new HttpGetCreateBookingInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(userId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SendBookingRequest(
                             HttpRequestManager *pHttpRequestManager,
                             const string& userId,
                             const string& timeId,
                             long bookTime,
                             const string& giftId,
                             int giftNum,
                             bool needSms,
                             IRequestSendBookingRequestCallback* callback
                                                    ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSendBookingRequestTask* task = new HttpSendBookingRequestTask();
    task->Init(pHttpRequestManager);
    task->SetParam(userId, timeId, bookTime, giftId, giftNum, needSms);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::AcceptInstanceInvite(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      const string& inviteId,
                                                      bool isConfirm,
                                                      IRequestAcceptInstanceInviteCallback* callback
                                                      ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpAcceptInstanceInviteTask* task = new HttpAcceptInstanceInviteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId, isConfirm);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GiftList(
                   HttpRequestManager *pHttpRequestManager,
                   IRequestGiftListCallback* callback
                                          ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGiftListTask* task = new HttpGiftListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::VoucherList(
                                             HttpRequestManager *pHttpRequestManager,
                                             IRequestVoucherListCallback* callback
                                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpVoucherListTask* task = new HttpVoucherListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::RideList(
                                          HttpRequestManager *pHttpRequestManager,
                                          IRequestRideListCallback* callback
                                          ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpRideListTask* task = new HttpRideListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SetRide(
                                         HttpRequestManager *pHttpRequestManager,
                                         const string& rideId,
                                         IRequestSetRideCallback* callback
                                         ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSetRideTask* task = new HttpSetRideTask();
    task->Init(pHttpRequestManager);
    task->SetParam(rideId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetBackpackUnreadNum(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      IRequestGetBackpackUnreadNumCallback* callback
                                                      ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetBackpackUnreadNumTask* task = new HttpGetBackpackUnreadNumTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetVoucherAvailableInfo(
                                                         HttpRequestManager *pHttpRequestManager,
                                                         IRequestGetVoucherAvailableInfoCallback* callback
                                                         ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetVoucherAvailableInfoTask* task = new HttpGetVoucherAvailableInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetConfig(
                                           HttpRequestManager *pHttpRequestManager,
                                           IRequestGetConfigCallback* callback
                                           ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetConfigTask* task = new HttpGetConfigTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetLeftCredit(
                                           HttpRequestManager *pHttpRequestManager,
                                           IRequestGetLeftCreditCallback* callback
                                           ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetLeftCreditTask* task = new HttpGetLeftCreditTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SetFavorite(
                                             HttpRequestManager *pHttpRequestManager,
                                             const string& userId,
                                             const string& roomId,
                                             bool isFav,
                                             IRequestSetFavoriteCallback* callback
                                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSetFavoriteTask* task = new HttpSetFavoriteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(userId, roomId, isFav);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::GetAdAnchorList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 int number,
                                                 IRequestGetAdAnchorListCallback* callback
                                                 ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetAdAnchorListTask* task = new HttpGetAdAnchorListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(number);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::CloseAdAnchorList(
                                                   HttpRequestManager *pHttpRequestManager,
                                                   IRequestCloseAdAnchorListCallback* callback
                                                   ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpCloseAdAnchorListTask* task = new HttpCloseAdAnchorListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetPhoneVerifyCode(
                                                    HttpRequestManager *pHttpRequestManager,
                                                    const string& country,
                                                    const string& areaCode,
                                                    const string& phoneNo,
                                                    IRequestGetPhoneVerifyCodeCallback* callback
                                                    ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPhoneVerifyCodeTask* task = new HttpGetPhoneVerifyCodeTask();
    task->Init(pHttpRequestManager);
    task->SetParam(country, areaCode, phoneNo);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SubmitPhoneVerifyCode(
                                                    HttpRequestManager *pHttpRequestManager,
                                                    const string& country,
                                                    const string& areaCode,
                                                    const string& phoneNo,
                                                    const string& verifyCode,
                                                    IRequestSubmitPhoneVerifyCodeCallback* callback
                                                    ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSubmitPhoneVerifyCodeTask* task = new HttpSubmitPhoneVerifyCodeTask();
    task->Init(pHttpRequestManager);
    task->SetParam(country, areaCode, phoneNo, verifyCode);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ServerSpeed(
                                             HttpRequestManager *pHttpRequestManager,
                                             const string& sid,
                                             int res,
                                             IRequestServerSpeedCallback* callback
                                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpServerSpeedTask* task = new HttpServerSpeedTask();
    task->Init(pHttpRequestManager);
    task->SetParam(sid, res);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::Banner(
                                        HttpRequestManager *pHttpRequestManager,
                                        IRequestBannerCallback* callback
                 ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpBannerTask* task = new HttpBannerTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetUserInfo(
                                             HttpRequestManager *pHttpRequestManager,
                                             const string& userId,
                                             IRequestGetUserInfoCallback* callback
                                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetUserInfoTask* task = new HttpGetUserInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(userId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetShareLink(
                                              HttpRequestManager *pHttpRequestManager,
                                              const string& shareuserId,
                                              const string& anchorId,
                                              ShareType shareType,
                                              SharePageType sharePageType,
                                              IRequestGetShareLinkCallback* callback
                                              ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetShareLinkTask* task = new HttpGetShareLinkTask();
    task->Init(pHttpRequestManager);
    task->SetParam(shareuserId, anchorId, shareType, sharePageType);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SetShareSuc(
                                             HttpRequestManager *pHttpRequestManager,
                                             const string& shareId,
                                             IRequestSetShareSucCallback* callback
                                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSetShareSucTask* task = new HttpSetShareSucTask();
    task->Init(pHttpRequestManager);
    task->SetParam(shareId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SubmitFeedBack(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string& mail,
                                                const string& msg,
                                                IRequestSubmitFeedBackCallback* callback
                                                )   {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSubmitFeedBackTask* task = new HttpSubmitFeedBackTask();
    task->Init(pHttpRequestManager);
    task->SetParam(mail, msg);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetManBaseInfo(
                         HttpRequestManager *pHttpRequestManager,
                         IRequestGetManBaseInfoCallback* callback
                                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetManBaseInfoTask* task = new HttpGetManBaseInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SetManBaseInfo(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string& nickName,
                                                IRequestSetManBaseInfoCallback* callback
                                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSetManBaseInfoTask* task = new HttpSetManBaseInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(nickName);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::CrashFile(
                                            HttpRequestManager *pHttpRequestManager,
                                            const string& deviceId,
                                            const string& crashFile,
                                            IRequestCrashFileCallback* callback
                                            ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpCrashFileTask* task = new HttpCrashFileTask();
    task->Init(pHttpRequestManager);
    task->SetParam(deviceId, crashFile );
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::PremiumMembership(
                                                   HttpRequestManager *pHttpRequestManager,
                                                   const string& siteId,
                                                   IRequestPremiumMembershipCallback* callback
                                                   ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpPremiumMembershipTask* task = new HttpPremiumMembershipTask();
    task->Init(pHttpRequestManager);
    task->SetParam(siteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetIOSPay(
                                           HttpRequestManager *pHttpRequestManager,
                                           const string& manid,
                                           const string& sid,
                                           const string& number,
                                           const string& siteid,
                                           IRequestGetIOSPayCallback* callback
                                           ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetIOSPayTask* task = new HttpGetIOSPayTask();
    task->Init(pHttpRequestManager);
    task->SetParam(manid, sid, number, siteid);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::IOSPayCall(
                                            HttpRequestManager *pHttpRequestManager,
                                            const string& manid,
                                            const string& sid,
                                            const string& receipt,
                                            const string& orderNo,
                                            AppStorePayCodeType code,
                                            IRequestIOSPayCallCallback* callback
                                            ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpIOSPayCallTask* task = new HttpIOSPayCallTask();
    task->Init(pHttpRequestManager);
    task->SetParam(manid, sid, receipt, orderNo, code);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetCanHangoutAnchorList(
                                  HttpRequestManager *pHttpRequestManager,
                                  HangoutAnchorListType type,
                                  const string& anchorId,
                                  int start,
                                  int step,
                                  IRequestGetCanHangoutAnchorListCallback* callback
                                  ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;

    HttpGetCanHangoutAnchorListTask* task = new HttpGetCanHangoutAnchorListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(type, anchorId, start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);

    requestId = (long long)task;

    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();

    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::SendInvitationHangout(
                                                       HttpRequestManager *pHttpRequestManager,
                                                       const string& roomId,
                                                       const string& anchorId,
                                                       const string& recommendId,
                                                       IRequestSendInvitationHangoutCallback* callback
                                                       ){
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;

    HttpSendInvitationHangoutTask* task = new HttpSendInvitationHangoutTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomId, anchorId, recommendId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);

    requestId = (long long)task;

    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();

    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::CancelInviteHangout(
                                                     HttpRequestManager *pHttpRequestManager,
                                                     const string& inviteId,
                                                     IRequestCancelInviteHangoutCallback* callback
                              ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;

    HttpCancelInviteHangoutTask* task = new HttpCancelInviteHangoutTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);

    requestId = (long long)task;

    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();

    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::GetHangoutInvitStatus(
                                                       HttpRequestManager *pHttpRequestManager,
                                                       const string& inviteId,
                                                       IRequestGetHangoutInvitStatusCallback* callback
                                                       ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;

    HttpGetHangoutInvitStatusTask* task = new HttpGetHangoutInvitStatusTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);

    requestId = (long long)task;

    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();

    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::DealKnockRequest(
                                                  HttpRequestManager *pHttpRequestManager,
                                                  const string& knockId,
                                                  IRequestDealKnockRequestCallback* callback
                                                  ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;

    HttpDealKnockRequestTask* task = new HttpDealKnockRequestTask();
    task->Init(pHttpRequestManager);
    task->SetParam(knockId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);

    requestId = (long long)task;

    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();

    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//
//        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::GetNoReadNumProgram(
                              HttpRequestManager *pHttpRequestManager,
                              IRequestGetNoReadNumProgramCallback* callback
                                                     ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetNoReadNumProgramTask* task = new HttpGetNoReadNumProgramTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetProgramList(
                                                HttpRequestManager *pHttpRequestManager,
                                                ProgramListType sortType,
                                                int start,
                                                int step,
                                                IRequestGetProgramListCallback* callback
                                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetProgramListTask* task = new HttpGetProgramListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(sortType, start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::BuyProgram(
                                            HttpRequestManager *pHttpRequestManager,
                                            const string& liveShowId,
                                            IRequestBuyProgramCallback* callback
                                            ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpBuyProgramTask* task = new HttpBuyProgramTask();
    task->Init(pHttpRequestManager);
    task->SetParam(liveShowId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::FollowShow(
                                            HttpRequestManager *pHttpRequestManager,
                                            const string& liveShowId,
                                            bool isCancel,
                                            IRequestChangeFavouriteCallback* callback
                                                 ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpChangeFavouriteTask* task = new HttpChangeFavouriteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(liveShowId, isCancel);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetShowRoomInfo(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string& liveShowId,
                                                 IRequestGetShowRoomInfoCallback* callback
                                                 ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetShowRoomInfoTask* task = new HttpGetShowRoomInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(liveShowId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ShowListWithAnchorId(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      const string& anchorId,
                                                      int start,
                                                      int step,
                                                      ShowRecommendListType sortType,
                                                      IRequestShowListWithAnchorIdTCallback* callback
                                                      ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpShowListWithAnchorIdTask* task = new HttpShowListWithAnchorIdTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId, start, step, sortType);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时KThread::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

