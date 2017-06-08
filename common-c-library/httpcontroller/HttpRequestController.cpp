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

//long long HttpRequestController::Login(
//                                       HttpRequestManager *pHttpRequestManager,
//                                       const string& user,
//                                       const string& password,
//                                       IRequestLoginCallback* callback
//                                       ) {
//    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
//    
//    HttpLoginTask* task = new HttpLoginTask();
//    task->Init(pHttpRequestManager);
//    task->SetParam(user, password);
//    task->SetCallback(callback);
//    task->SetHttpTaskCallback(this);
//    
//    requestId = (long long)task;
//    
//    mRequestMap.Lock();
//    mRequestMap.Insert(task, task);
//    mRequestMap.Unlock();
//    
//    if( !task->Start() ) {
//        mRequestMap.Lock();
//        mRequestMap.Erase(task);
//        mRequestMap.Unlock();
//        
//        delete task;
//        requestId = HTTPREQUEST_INVALIDREQUESTID;
//    }
//    
//    return requestId;
//}

long long HttpRequestController::RegisterCheckPhone(
                             HttpRequestManager *pHttpRequestManager,
                             const string& phoneno,
                             const string& areno,
                             IRequestRegisterCheckPhoneCallback* callback
                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpRegisterCheckPhoneTask* task = new HttpRegisterCheckPhoneTask();
    task->Init(pHttpRequestManager);
    task->SetParam(phoneno, areno);
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

long long HttpRequestController::RegisterGetSMSCode(
                             HttpRequestManager *pHttpRequestManager,
                             const string& phoneno,
                             const string& areno,
                             IRequestRegisterGetSMSCodeCallback* callback
                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpRegisterGetSMSCodeTask* task = new HttpRegisterGetSMSCodeTask();
    task->Init(pHttpRequestManager);
    task->SetParam(phoneno, areno);
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


long long HttpRequestController::RegisterPhone(
                        HttpRequestManager *pHttpRequestManager,
                        const string& phoneno,
                        const string& areno,
                        const string& checkCode,
                        const string& password,
                        const string& deviceId,
                        const string& model,
                        const string& manufacturer,
                        IRequestRegisterPhoneCallback* callback
                        ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpRegisterPhoneTask* task = new HttpRegisterPhoneTask();
    task->Init(pHttpRequestManager);
    task->SetParam(phoneno, areno, checkCode, password, deviceId, model, manufacturer);
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


long long HttpRequestController::Login(
                      HttpRequestManager *pHttpRequestManager,
                      LoginType type,
                      const string& phoneno,
                      const string& areno,
                      const string& password,
                      const string& deviceid,
                      const string& model,
                      const string& manufacturer,
                      bool autoLogin,
                      IRequestLoginCallback* callback
                      ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpLoginTask* task = new HttpLoginTask();
    task->Init(pHttpRequestManager);
    task->SetParam(type, phoneno, areno, password, deviceid, model, manufacturer, autoLogin);
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
                                        const string& token,
                                        IRequestLogoutCallback* callback
                                        ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpLogoutTask* task = new HttpLogoutTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token);
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


long long HttpRequestController::UpdateLiveRoomTokenId(
                                                       HttpRequestManager *pHttpRequestManager,
                                                       const string& token,
                                                       const string& tokenId,
                                                       IRequestUpdateLiveRoomTokenIdCallback* callback
                                                       ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpUpdateLiveRoomTokenIdTask* task = new HttpUpdateLiveRoomTokenIdTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token, tokenId);
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

long long HttpRequestController::CreateLiveRoom(
                         HttpRequestManager *pHttpRequestManager,
                         const string& token,
                         const string& roomName,
                         const string& roomPhotoId,
                         IRequestLiveRoomCreateCallback* callback
                                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpLiveRoomCreateTask* task = new HttpLiveRoomCreateTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token, roomName, roomPhotoId);
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

long long HttpRequestController::CheckLiveRoom(
                        HttpRequestManager *pHttpRequestManager,
                        const string& token,
                        IRequestCheckLiveRoomCallback* callback
                        ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpCheckLiveRoomTask* task = new HttpCheckLiveRoomTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token);
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

long long HttpRequestController::CloseLiveRoom(
                        HttpRequestManager *pHttpRequestManager,
                        const string& token,
                        const string& roomId,
                        IRequestCloseLiveRoomCallback* callback
                        ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpCloseLiveRoomTask* task = new HttpCloseLiveRoomTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token, roomId);
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


long long HttpRequestController::GetLiveRoomFansList(
                              HttpRequestManager *pHttpRequestManager,
                              const string& token,
                              const string& roomId,
                              IRequestGetLiveRoomFansListCallback* callback
                                                     ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetLiveRoomFansListTask* task = new HttpGetLiveRoomFansListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token, roomId);
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


long long HttpRequestController::GetLiveRoomAllFansList(
                                                        HttpRequestManager *pHttpRequestManager,
                                                        const string& token,
                                                        const string& roomId,
                                                        int start,
                                                        int step,
                                                        IRequestGetLiveRoomAllFansListCallback* callback
                                                        ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetLiveRoomAllFansListTask* task = new HttpGetLiveRoomAllFansListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token, roomId, start, step);
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

long long HttpRequestController::GetLiveRoomHotList(
                             HttpRequestManager *pHttpRequestManager,
                             const string& token,
                             int start,
                             int step,
                             IRequestGetLiveRoomHotCallback* callback
                             ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetLiveRoomHotTask* task = new HttpGetLiveRoomHotTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token, start, step);
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

long long HttpRequestController::GetLiveRoomUserPhoto(
                               HttpRequestManager *pHttpRequestManager,
                               const string& token,
                               const string& userId,
                               PhotoType photoType,
                               IRequestGetLiveRoomUserPhotoCallback* callback
                                                      ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetLiveRoomUserPhotoTask* task = new HttpGetLiveRoomUserPhotoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token, userId, photoType);
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

long long HttpRequestController::GetLiveRoomModifyInfo(
                                HttpRequestManager *pHttpRequestManager,
                                const string& token,
                                IRequestGetLiveRoomModifyInfoCallback* callback
                                ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetLiveRoomModifyInfoTask* task = new HttpGetLiveRoomModifyInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token);
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

long long HttpRequestController::SetLiveRoomModifyInfo(
                                HttpRequestManager *pHttpRequestManager,
                                const string& token,
                                const string& photoUrl,
                                const string& nickName,
                                Gender gender,
                                const string& birthday,
                                IRequestSetLiveRoomModifyInfoCallback* callback
                                                       ) {
    long long requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSetLiveRoomModifyInfoTask* task = new HttpSetLiveRoomModifyInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token, photoUrl, nickName, gender, birthday);
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

