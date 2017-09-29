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
    FileLog("httpcontroller", "HttpRequestController::OnTaskFinish( task : %p )", task);
    
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
                                       const string& qnsid,
                                       const string& deviceid,
                                       const string& model,
                                       const string& manufacturer,
                                       IRequestLoginCallback* callback
                                       ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpLoginTask* task = new HttpLoginTask();
    task->Init(pHttpRequestManager);
    task->SetParam(qnsid, deviceid, model, manufacturer);
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetAnchorList(
                                               HttpRequestManager *pHttpRequestManager,
                                               int start,
                                               int step,
                                               bool hasWatch,
                                               IRequestGetAnchorListCallback* callback
                                               ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetAnchorListTask* task = new HttpGetAnchorListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(start, step, hasWatch);
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
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
        mRequestMap.Lock();
        mRequestMap.Erase(task);
        mRequestMap.Unlock();
        
        delete task;
        requestId = HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}
