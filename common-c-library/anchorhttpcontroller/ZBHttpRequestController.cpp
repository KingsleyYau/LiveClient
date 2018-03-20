//
//  ZBHttpRequestController.cpp
//  Common-C-Library
//
//  Created by Alex on 2018/2/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#include "ZBHttpRequestController.h"

ZBHttpRequestController::ZBHttpRequestController() {

}

ZBHttpRequestController::~ZBHttpRequestController() {
    
}

void ZBHttpRequestController::OnTaskFinish(IZBHttpTask* task) {
    FileLog(LIVESHOW_HTTP_LOG, "ZBHttpRequestController::OnTaskFinish( task : %p )", task);
    
    // 清除回调
    mRequestMap.Lock();
    mRequestMap.Erase(task);
    mRequestMap.Unlock();
    
    // 删除请求
    delete task;
}

void ZBHttpRequestController::Stop(long long requestId) {
    mRequestMap.Lock();
    IZBHttpTask* task = (IZBHttpTask*)requestId;
    RequestMap::iterator itr = mRequestMap.Find(task);
    if( itr != mRequestMap.End() ) {
        task->Stop();
    }
    mRequestMap.Unlock();
}


long long ZBHttpRequestController::ZBLogin(
                                           HttpRequestManager *pHttpRequestManager,
                                           const string& anchorId,
                                           const string& password,
                                           const string& code,
                                           const string& deviceid,
                                           const string& model,
                                           const string& manufacturer,
                                           IRequestZBLoginCallback* callback
                                       ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpLoginTask* task = new ZBHttpLoginTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId, password, code, deviceid, model, manufacturer);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long  ZBHttpRequestController::ZBUpdateTokenId(
                              HttpRequestManager *pHttpRequestManager,
                              const string& tokenId,
                              IRequestZBUpdateTokenIdCallback* callback
                                                    ) {
    
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpUpdateTokenIdTask* task = new ZBHttpUpdateTokenIdTask();
    task->Init(pHttpRequestManager);
    task->SetParam(tokenId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBGetVerificationCode(
                                HttpRequestManager *pHttpRequestManager,
                                IRequestZBGetVerificationCodeCallback* callback
                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpGetVerificationCodeTask* task = new ZBHttpGetVerificationCodeTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBLiveFansList(
                         HttpRequestManager *pHttpRequestManager,
                         const string& roomId,
                         int start,
                         int step,
                         IRequestZBLiveFansListCallback* callback
                                                  ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpLiveFansListTask* task = new ZBHttpLiveFansListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomId, start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBGetNewFansBaseInfo(
                               HttpRequestManager *pHttpRequestManager,
                               const string& userId,
                               IRequestZBGetNewFansBaseInfoCallback* callback
                                                        ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpGetNewFansBaseInfoTask* task = new ZBHttpGetNewFansBaseInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(userId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBGetAllGiftList(
                         HttpRequestManager *pHttpRequestManager,
                         IRequestZBGetAllGiftListCallback* callback
                                                  ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpGetAllGiftListTask* task = new ZBHttpGetAllGiftListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBGiftList(
                     HttpRequestManager *pHttpRequestManager,
                     const string& roomId,
                     IRequestZBGiftListCallback* callback
                                              ) {
    
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpGiftListTask* task = new ZBHttpGiftListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBGetGiftDetail(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& giftId,
                                               IRequestZBGetGiftDetailCallback* callback
                                               ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpGetGiftDetailTask* task = new ZBHttpGetGiftDetailTask();
    task->Init(pHttpRequestManager);
    task->SetParam(giftId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBGetEmoticonList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 IRequestZBGetEmoticonListCallback* callback
                                                 ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpGetEmoticonListTask* task = new ZBHttpGetEmoticonListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBDealTalentRequest(
                              HttpRequestManager *pHttpRequestManager,
                              const string talentInviteId,
                              ZBTalentReplyType status,
                              IRequestZBDealTalentRequestCallback* callback
                                                       ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpDealTalentRequestTask* task = new ZBHttpDealTalentRequestTask();
    task->Init(pHttpRequestManager);
    task->SetParam(talentInviteId, status);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBSetAutoPush(
                        HttpRequestManager *pHttpRequestManager,
                        ZBSetPushType status,
                        IRequestZBSetAutoPushCallback* callback
                                                 ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpSetAutoPushTask* task = new ZBHttpSetAutoPushTask();
    task->Init(pHttpRequestManager);
    task->SetParam(status);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBManHandleBookingList(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      ZBBookingListType type,
                                                      int start,
                                                      int step,
                                                      IRequestZBManHandleBookingListCallback* callback
                                                      ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpManHandleBookingListTask* task = new ZBHttpManHandleBookingListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(type, start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBAcceptScheduledInvite(
                                                           HttpRequestManager *pHttpRequestManager,
                                                           const string& inviteId,
                                                           IRequestZBAcceptScheduledInviteCallback* callback
                                                           ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpAcceptScheduledInviteTask* task = new ZBHttpAcceptScheduledInviteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBRejectScheduledInvite(
                                                         HttpRequestManager *pHttpRequestManager,
                                                         const string& invitationId,
                                                         IRequestZBRejectScheduledInviteCallback* callback
                                                         ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpRejectScheduledInviteTask* task = new ZBHttpRejectScheduledInviteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(invitationId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBGetScheduleListNoReadNum(
                                                             HttpRequestManager *pHttpRequestManager,
                                                             IRequestZBGetScheduleListNoReadNumCallback* callback
                                                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpManBookingUnreadUnhandleNumTask* task = new ZBHttpManBookingUnreadUnhandleNumTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

/**
 *  4.5.获取已确认的预约数(用于主播端获取已确认的预约数量)
 *
 * @param pHttpRequestManager           http管理器
 * @param callback                      接口回调
 *
 * @return                              成功请求Id
 */
long long ZBHttpRequestController::ZBGetScheduledAcceptNum(
                                  HttpRequestManager *pHttpRequestManager,
                                  IRequestZBGetScheduledAcceptNumCallback* callback
                                                           ) {
    
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpGetScheduledAcceptNumTask* task = new ZBHttpGetScheduledAcceptNumTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBAcceptInstanceInvite(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& inviteId,
                                 IRequestZBAcceptInstanceInviteCallback* callback
                                                          ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpAcceptInstanceInviteTask* task = new ZBHttpAcceptInstanceInviteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBRejectInstanceInvite(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& inviteId,
                                 const string& rejectReason,
                                 IRequestZBRejectInstanceInviteCallback* callback
                                                          ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpRejectInstanceInviteTask* task = new ZBHttpRejectInstanceInviteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId, rejectReason);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBCancelInstantInviteUser(
                                                             HttpRequestManager *pHttpRequestManager,
                                                             const string& inviteId,
                                                             IRequestZBCancelInstantInviteUserCallback* callback
                                    ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpCancelInstantInviteUserTask* task = new ZBHttpCancelInstantInviteUserTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBSetRoomCountDown(
                             HttpRequestManager *pHttpRequestManager,
                             const string& roomId,
                             IRequestZBSetRoomCountDownCallback* callback
                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpSetRoomCountDownTask* task = new ZBHttpSetRoomCountDownTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long ZBHttpRequestController::ZBGetConfig(
                                           HttpRequestManager *pHttpRequestManager,
                                           IRequestZBGetConfigCallback* callback
                                           ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpGetConfigTask* task = new ZBHttpGetConfigTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBGetTodayCredit(
                                               HttpRequestManager *pHttpRequestManager,
                                               IRequestZBGetTodayCreditCallback* callback
                                               ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpGetTodayCreditTask* task = new ZBHttpGetTodayCreditTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBServerSpeed(
                                             HttpRequestManager *pHttpRequestManager,
                                             const string& sid,
                                             int res,
                                             IRequestZBServerSpeedCallback* callback
                                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpServerSpeedTask* task = new ZBHttpServerSpeedTask();
    task->Init(pHttpRequestManager);
    task->SetParam(sid, res);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long ZBHttpRequestController::ZBCrashFile(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& deviceId,
                                               const string& crashFile,
                                               IRequestZBCrashFileCallback* callback
                                               ){
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    ZBHttpCrashFileTask* task = new ZBHttpCrashFileTask();
    task->Init(pHttpRequestManager);
    task->SetParam(deviceId, crashFile);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}
