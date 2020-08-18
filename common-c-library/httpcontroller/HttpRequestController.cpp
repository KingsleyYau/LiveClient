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
                                       LSLoginSidType userSidType,
                                       IRequestLoginCallback* callback
                                       ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpLoginTask* task = new HttpLoginTask();
    task->Init(pHttpRequestManager);
    task->SetParam(manId, userSid, deviceid, model, manufacturer, userSidType);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::Logout(
                                        HttpRequestManager *pHttpRequestManager,
                                        IRequestLogoutCallback* callback
                                        ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::UpdateTokenId(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string& tokenId,
                                                IRequestUpdateTokenIdCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::OwnFindPassword(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string sendMail,
                                                 const string checkCode,
                                                 IRequestOwnFindPasswordCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::OwnCheckMail(
                                              HttpRequestManager *pHttpRequestManager,
                                              const string email,
                                              IRequestOwnCheckMailRegistrationCallback* callback
                                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::OwnUploadPhoto(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string photoName,
                                                IRequestUploadPhotoCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetVerificationCode(
                                                     HttpRequestManager *pHttpRequestManager,
                                                     VerifyCodeType verifyType,
                                                     bool useCode,
                                                     IRequestGetVerificationCodeCallback* callback
                                                     ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetValidsiteId(
                              HttpRequestManager *pHttpRequestManager,
                              const string& email,
                              const string& password,
                              IRequestGetValidsiteIdCallback* callback
                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetValidsiteIdTask* task = new HttpGetValidsiteIdTask();
    task->Init(pHttpRequestManager);
    task->SetParam(email, password);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::AddToken(
                   HttpRequestManager *pHttpRequestManager,
                   const string token,
                   const string appId,
                   const string deviceId,
                   IRequestAddTokenCallback* callback
                                          ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpAddTokenTask* task = new HttpAddTokenTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token, appId, deviceId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::DestroyToken(
                                          HttpRequestManager *pHttpRequestManager,
                                          IRequestDestroyTokenCallback* callback
                                          ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpDestroyTokenTask* task = new HttpDestroyTokenTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::FindPassword(
                       HttpRequestManager *pHttpRequestManager,
                       const string sendMail,
                       const string checkCode,
                       IRequestFindPasswordCallback* callback
                       ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpFindPasswordTask* task = new HttpFindPasswordTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ChangePassword(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string passwordNew,
                                                const string passwordOld,
                                                IRequestChangePasswordCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpChangePasswordTask* task = new HttpChangePasswordTask();
    task->Init(pHttpRequestManager);
    task->SetParam(passwordNew, passwordOld);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::DoLogin(
                                         HttpRequestManager *pHttpRequestManager,
                                         const string& token,
                                         const string& memberId,
                                         const string& deviceId,
                                         const string& versionCode,
                                         const string& model,
                                         const string& manufacturer,
                                         IRequestDoLoginCallback* callback
                                         ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpDoLoginTask* task = new HttpDoLoginTask();
    task->Init(pHttpRequestManager);
    task->SetParam(token, memberId, deviceId, versionCode, model, manufacturer);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetToken(
                                          HttpRequestManager *pHttpRequestManager,
                                          const string& url,
                                          HTTP_OTHER_SITE_TYPE siteId,
                                          IRequestGetTokenCallback* callback
                                          ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetTokenTask* task = new HttpGetTokenTask();
    task->Init(pHttpRequestManager);
    task->SetParam(url, siteId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::PasswordLogin(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& email,
                                               const string& password,
                                               const string& authcode,
                                               HTTP_OTHER_SITE_TYPE siteId,
                                               const string& afDeviceId,
                                               const string& gaid,
                                               const string& deviceId,
                                               IRequestPasswordLoginCallback* callback
                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpPasswordLoginTask* task = new HttpPasswordLoginTask();
    task->Init(pHttpRequestManager);
    task->SetParam(email, password, authcode, siteId, afDeviceId, gaid, deviceId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::TokenLogin(
                                            HttpRequestManager *pHttpRequestManager,
                                            const string& memberId,
                                            const string& sid,
                                            IRequestTokenLoginCallback* callback
                                            ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpTokenLoginTask* task = new HttpTokenLoginTask();
    task->Init(pHttpRequestManager);
    task->SetParam(memberId, sid);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetValidateCode(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 LSValidateCodeType validateCodeType,
                                                 IRequestGetValidateCodeCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetValidateCodeTask* task = new HttpGetValidateCodeTask();
    task->Init(pHttpRequestManager);
    task->SetParam(validateCodeType);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::UploadUserPhoto(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string& photoName,
                                                 IRequestUploadUserPhotoCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpUploadUserPhotoTask* task = new HttpUploadUserPhotoTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetFollowList(
                                                HttpRequestManager *pHttpRequestManager,
                                                int start,
                                                int step,
                                                IRequestGetFollowListCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetRoomInfo(
                                             HttpRequestManager *pHttpRequestManager,
                                             IRequestGetRoomInfoCallback* callback
                                             ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}



long long HttpRequestController::GetAllGiftList(
                                                HttpRequestManager *pHttpRequestManager,
                                                IRequestGetAllGiftListCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetGiftListByUserId(
                                                     HttpRequestManager *pHttpRequestManager,
                                                     const string& roomId,
                                                     IRequestGetGiftListByUserIdCallback* callback
                                                     ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetGiftDetail(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& giftId,
                                               IRequestGetGiftDetailCallback* callback
                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;

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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::GetEmoticonList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 IRequestGetEmoticonListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetInviteInfo(
                        HttpRequestManager *pHttpRequestManager,
                        const string& inviteId,
                        IRequestGetInviteInfoCallback* callback
                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetTalentList(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& roomId,
                                               IRequestGetTalentListCallback* callback
                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetTalentStatus(
                          HttpRequestManager *pHttpRequestManager,
                          const string& roomId,
                          const string& talentInviteId,
                          IRequestGetTalentStatusCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::GetNewFansBaseInfo(
                                                    HttpRequestManager *pHttpRequestManager,
                                                    const string& userId,
                                                    IRequestGetNewFansBaseInfoCallback* callback
                                                    ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ControlManPush(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string& roomId,
                                                ControlType type,
                                                IRequestControlManPushCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetLiveEndRecommendAnchorList(
                                        HttpRequestManager *pHttpRequestManager,
                                        IRequestGetLiveEndRecommendAnchorListCallback* callback
                                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetLiveEndRecommendAnchorListTask* task = new HttpGetLiveEndRecommendAnchorListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetContactList(
                                                HttpRequestManager *pHttpRequestManager,
                                                int start,
                                                int step,
                                                IRequestGetContactListCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetContactListTask* task = new HttpGetContactListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetGiftTypeList(
                                                  HttpRequestManager *pHttpRequestManager,
                                                  LSGiftRoomType roomType,
                                                  IRequestGetGiftTypeListtCallback* callback
                                                  ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetGiftTypeListTask* task = new HttpGetGiftTypeListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomType);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetFeaturedAnchorList(
                                                       HttpRequestManager *pHttpRequestManager,
                                                       int start,
                                                       int step,
                                                       IRequestGetFeaturedAnchorListCallback* callback
                                                       ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetFeaturedAnchorListTask* task = new HttpGetFeaturedAnchorListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::HandleBooking(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& inviteId,
                                               bool isConfirm,
                                               IRequestHandleBookingCallback* callback
                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SendCancelPrivateLiveInvite(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      const string& invitationId,
                                                      IRequestSendCancelPrivateLiveInviteCallback* callback
                                                      ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ManBookingUnreadUnhandleNum(
                                                             HttpRequestManager *pHttpRequestManager,
                                                             IRequestManBookingUnreadUnhandleNumCallback* callback
                                                             ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetCreateBookingInfo(
                                 HttpRequestManager *pHttpRequestManager,
                                 const string& userId,
                                 IRequestGetCreateBookingInfoCallback* callback
                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SendBookingRequest(
                             HttpRequestManager *pHttpRequestManager,
                             const string& userId,
                             const string& timeId,
                             long long bookTime,
                             const string& giftId,
                             int giftNum,
                             bool needSms,
                             IRequestSendBookingRequestCallback* callback
                                                    ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::AcceptInstanceInvite(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      const string& inviteId,
                                                      bool isConfirm,
                                                      IRequestAcceptInstanceInviteCallback* callback
                                                      ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GiftList(
                   HttpRequestManager *pHttpRequestManager,
                   IRequestGiftListCallback* callback
                                          ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::VoucherList(
                                             HttpRequestManager *pHttpRequestManager,
                                             IRequestVoucherListCallback* callback
                                             ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::RideList(
                                          HttpRequestManager *pHttpRequestManager,
                                          IRequestRideListCallback* callback
                                          ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SetRide(
                                         HttpRequestManager *pHttpRequestManager,
                                         const string& rideId,
                                         IRequestSetRideCallback* callback
                                         ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetBackpackUnreadNum(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      IRequestGetBackpackUnreadNumCallback* callback
                                                      ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetVoucherAvailableInfo(
                                                         HttpRequestManager *pHttpRequestManager,
                                                         IRequestGetVoucherAvailableInfoCallback* callback
                                                         ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetChatVoucherList(
                             HttpRequestManager *pHttpRequestManager,
                             int start,
                             int step,
                             IRequestGetChatVoucherListCallback* callback
                             ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetChatVoucherListTask* task = new HttpGetChatVoucherListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
    
}

long long HttpRequestController::GetConfig(
                                           HttpRequestManager *pHttpRequestManager,
                                           IRequestGetConfigCallback* callback
                                           ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetLeftCredit(
                                           HttpRequestManager *pHttpRequestManager,
                                           IRequestGetLeftCreditCallback* callback
                                           ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::GetAdAnchorList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 int number,
                                                 IRequestGetAdAnchorListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::CloseAdAnchorList(
                                                   HttpRequestManager *pHttpRequestManager,
                                                   IRequestCloseAdAnchorListCallback* callback
                                                   ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ServerSpeed(
                                             HttpRequestManager *pHttpRequestManager,
                                             const string& sid,
                                             int res,
                                             const string& liveRoomId,
                                             IRequestServerSpeedCallback* callback
                                             ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpServerSpeedTask* task = new HttpServerSpeedTask();
    task->Init(pHttpRequestManager);
    task->SetParam(sid, res, liveRoomId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::Banner(
                                        HttpRequestManager *pHttpRequestManager,
                                        IRequestBannerCallback* callback
                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetUserInfo(
                                             HttpRequestManager *pHttpRequestManager,
                                             const string& userId,
                                             IRequestGetUserInfoCallback* callback
                                             ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SetShareSuc(
                                             HttpRequestManager *pHttpRequestManager,
                                             const string& shareId,
                                             IRequestSetShareSucCallback* callback
                                             ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SubmitFeedBack(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string& mail,
                                                const string& msg,
                                                IRequestSubmitFeedBackCallback* callback
                                                )   {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetManBaseInfo(
                         HttpRequestManager *pHttpRequestManager,
                         IRequestGetManBaseInfoCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SetManBaseInfo(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string& nickName,
                                                IRequestSetManBaseInfoCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::CrashFile(
                                            HttpRequestManager *pHttpRequestManager,
                                            const string& deviceId,
                                            const string& crashFile,
                                            IRequestCrashFileCallback* callback
                                            ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetTotalNoreadNum(
                                                   HttpRequestManager *pHttpRequestManager,
                                                   IRequestGetTotalNoreadNumCallback* callback
                                                   ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetTotalNoreadNumTask* task = new HttpGetTotalNoreadNumTask();
    task->Init(pHttpRequestManager);
    task->SetParam( );
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetMyProfile(
                                              HttpRequestManager *pHttpRequestManager,
                                              
                                              IRequestGetMyProfileCallback* callback
                                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetMyProfileTask* task = new HttpGetMyProfileTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::UpdateProfile(
                        HttpRequestManager *pHttpRequestManager,
                        int weight,
                        int height,
                        int language,
                        int ethnicity,
                        int religion,
                        int education,
                        int profession,
                        int income,
                        int children,
                        int smoke,
                        int drink,
                        const string resume,
                        list<string> interests,
                        int zodiac,
                        IRequestUpdateProfileCallback* callback
                        ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpUpdateProfileTask* task = new HttpUpdateProfileTask();
    task->Init(pHttpRequestManager);
    task->SetParam(weight, height, language, ethnicity, religion, education, profession, income, children, smoke, drink, resume, interests, zodiac);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::VersionCheck(
                       HttpRequestManager *pHttpRequestManager,
                       int currVersion,
                       IRequestVersionCheckCallback* callback
                       ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpVersionCheckTask* task = new HttpVersionCheckTask();
    task->Init(pHttpRequestManager);
    task->SetParam(currVersion);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::StartEditResume(
                          HttpRequestManager *pHttpRequestManager,
                          IRequestStartEditResumeCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpStartEditResumeTask* task = new HttpStartEditResumeTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::PhoneInfo(
                                           HttpRequestManager *pHttpRequestManager,
                                           const string& manId, int verCode, const string& verName,
                                           int action, HTTP_OTHER_SITE_TYPE siteId, double density,
                                           int width, int height, const string& densityDpi,
                                           const string& model, const string& manufacturer, const string& os,
                                           const string& release, const string& sdk, const string& language,
                                           const string& region, const string& lineNumber, const string& simOptName,
                                           const string& simOpt, const string& simCountryIso, const string& simState,
                                           int phoneType, int networkType, const string& deviceId,
                                           IRequestPhoneInfoCallback* callback
                                           ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpPhoneInfoTask* task = new HttpPhoneInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(manId, verCode, verName,
                   action, siteId, density,
                   width, height, densityDpi,
                   model, manufacturer, os,
                   release, sdk, language,
                   region, lineNumber, simOptName,
                   simOpt, simCountryIso, simState,
                   phoneType, networkType, deviceId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::PushPullLogs(
                                           HttpRequestManager *pHttpRequestManager,
                                           const string& liveRoomId,
                                           IRequestPushPullLogsCallback* callback
                                           ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpPushPullLogsTask* task = new HttpPushPullLogsTask();
    task->Init(pHttpRequestManager);
    task->SetParam(liveRoomId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::PremiumMembership(
                                                   HttpRequestManager *pHttpRequestManager,
                                                   const string& siteId,
                                                   IRequestPremiumMembershipCallback* callback
                                                   ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::IOSGetPay(
                    HttpRequestManager *pHttpRequestManager,
                    const string& manid,
                    const string& sid,
                    const string& number,
                    IRequestIOSGetPayCallback* callback
                    ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpIOSGetPayTask* task = new HttpIOSGetPayTask();
    task->Init(pHttpRequestManager);
    task->SetParam(manid, sid, number);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::IOSCheckPayCall(
                          HttpRequestManager *pHttpRequestManager,
                          const string& manid,
                          const string& sid,
                          const string& receipt,
                          const string& orderNo,
                          AppStorePayCodeType code,
                          IRequestIOSCheckPayCallCallback* callback
                          ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpIOSCheckPayCallTask* task = new HttpIOSCheckPayCallTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::IOSPremiumMemberShip(
                               HttpRequestManager *pHttpRequestManager,
                               IRequestIOSPremiumMemberShipCallback* callback
                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpIOSPremiumMemberShipTask* task = new HttpIOSPremiumMemberShipTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::MobilePayGoto(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& url,
                                               HTTP_OTHER_SITE_TYPE siteId,
                                               LSOrderType orderType,
                                               const string& clickFrom,
                                               const string& number,
                                               const string& orderNo,
                                               IRequestMobilePayGotoCallback* callback
                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpMobilePayGotoTask* task = new HttpMobilePayGotoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(url, siteId, orderType, clickFrom, number, orderNo);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetPostStampsPriceList(
                                                        HttpRequestManager *pHttpRequestManager,
                                                        IRequestGetPostStampsPriceListCallback* callback
                                                        ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPostStampsPriceListTask* task = new HttpGetPostStampsPriceListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetAppPay(
                                           HttpRequestManager *pHttpRequestManager,
                                           const string& number,
                                           IRequestGetAppPayCallback* callback
                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetAppPayTask* task = new HttpGetAppPayTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::AndroidPremiumMemberShip(
                                   HttpRequestManager *pHttpRequestManager,
                                   IRequestAndroidPremiumMemberShipCallback* callback
                                   ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpAndroidPremiumMemberShipTask* task = new HttpAndroidPremiumMemberShipTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::AndroidCheckPayCall(
                              HttpRequestManager *pHttpRequestManager,
                              LSPaidCallType callType,
                              string manid,
                              string orderNo,
                              string number,
                              string token,
                              string data,
                              IRequestAndroidCheckPayCallCallback* callback
                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpAndroidCheckPayCallTask* task = new HttpAndroidCheckPayCallTask();
    task->Init(pHttpRequestManager);
    task->SetParam(callType, manid, orderNo, number, token, data);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::UploadFailPayInfo(
                            HttpRequestManager *pHttpRequestManager,
                            string manid,
                            string orderNo,
                            string number,
                            string errNo,
                            string errMsg,
                            IRequestUploadFailPayInfoCallback* callback
                            ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpUploadFailPayInfoTask* task = new HttpUploadFailPayInfoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(manid, orderNo, number, errNo, errMsg);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::OrderExpiredReport(
                                                    HttpRequestManager *pHttpRequestManager,
                                                    string manid,
                                                    string deviceId,
                                                    string deviceModel,
                                                    string system,
                                                    string appSdk,
                                                    OrderExpiredList list,
                                                    IRequestOrderExpiredReportCallback* callback
                                                    ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpOrderExpiredReportTask* task = new HttpOrderExpiredReportTask();
    task->Init(pHttpRequestManager);
    task->SetParam(manid, deviceId, deviceModel, system, appSdk, list);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;

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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::SendInvitationHangout(
                                                       HttpRequestManager *pHttpRequestManager,
                                                       const string& roomId,
                                                       const string& anchorId,
                                                       const string& recommendId,
                                                       bool isCreateOnly,
                                                       IRequestSendInvitationHangoutCallback* callback
                                                       ){
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;

    HttpSendInvitationHangoutTask* task = new HttpSendInvitationHangoutTask();
    task->Init(pHttpRequestManager);
    task->SetParam(roomId, anchorId, recommendId, isCreateOnly);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::CancelInviteHangout(
                                                     HttpRequestManager *pHttpRequestManager,
                                                     const string& inviteId,
                                                     IRequestCancelInviteHangoutCallback* callback
                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;

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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::GetHangoutInvitStatus(
                                                       HttpRequestManager *pHttpRequestManager,
                                                       const string& inviteId,
                                                       IRequestGetHangoutInvitStatusCallback* callback
                                                       ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;

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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::DealKnockRequest(
                                                  HttpRequestManager *pHttpRequestManager,
                                                  const string& knockId,
                                                  IRequestDealKnockRequestCallback* callback
                                                  ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;

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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }

    return requestId;
}

long long HttpRequestController::GetHangoutGiftList(
                                                    HttpRequestManager *pHttpRequestManager,
                                                    const string& roomId,
                                                    IRequestGetHangoutGiftListCallback* callback
                                                    ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetHangoutGiftListTask* task = new HttpGetHangoutGiftListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetHangoutOnlineAnchor(
                                 HttpRequestManager *pHttpRequestManager,
                                 IRequestGetHangoutOnlineAnchorCallback* callback
                                                        ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetHangoutOnlineAnchorTask* task = new HttpGetHangoutOnlineAnchorTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetHangoutFriends(
                                                    HttpRequestManager *pHttpRequestManager,
                                                    const string& anchorId,
                                                    IRequestGetHangoutFriendsCallback* callback
                                                    ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetHangoutFriendsTask* task = new HttpGetHangoutFriendsTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::AutoInvitationHangoutLiveDisplay(
                                                   HttpRequestManager *pHttpRequestManager,
                                                   const string& anchorId,
                                                   bool isAuto,
                                                   IRequestAutoInvitationHangoutLiveDisplayCallback* callback
                                                   ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpAutoInvitationHangoutLiveDisplayTask* task = new HttpAutoInvitationHangoutLiveDisplayTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId, isAuto);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::AutoInvitationClickLog(
                                                   HttpRequestManager *pHttpRequestManager,
                                                   const string& anchorId,
                                                   bool isAuto,
                                                   IRequestAutoInvitationClickLogCallback* callback
                                                   ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpAutoInvitationClickLogTask* task = new HttpAutoInvitationClickLogTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId, isAuto);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetHangoutStatus(
                                                  HttpRequestManager *pHttpRequestManager,
                                                  IRequestGetHangoutStatusCallback* callback
                                                  ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetHangoutStatusTask* task = new HttpGetHangoutStatusTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetNoReadNumProgram(
                              HttpRequestManager *pHttpRequestManager,
                              IRequestGetNoReadNumProgramCallback* callback
                                                     ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::BuyProgram(
                                            HttpRequestManager *pHttpRequestManager,
                                            const string& liveShowId,
                                            IRequestBuyProgramCallback* callback
                                            ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::FollowShow(
                                            HttpRequestManager *pHttpRequestManager,
                                            const string& liveShowId,
                                            bool isCancel,
                                            IRequestChangeFavouriteCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetShowRoomInfo(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string& liveShowId,
                                                 IRequestGetShowRoomInfoCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
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
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetPrivateMsgFriendList(
                                                         HttpRequestManager *pHttpRequestManager,
                                                         IRequestGetPrivateMsgFriendListCallback* callback
                                                         ){
    
    FileLevelLog(LIVESHOW_HTTP_LOG,
                 KLog::LOG_MSG,
                 "HttpRequest::StartRequest( "
                 "pHttpRequestManager : %p, "
                 "this : %p, "
                 ") \n\n",
                 pHttpRequestManager,
                 this);
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPrivateMsgFriendListTask* task = new HttpGetPrivateMsgFriendListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetFollowPrivateMsgFriendList(
                                                               HttpRequestManager *pHttpRequestManager,
                                                               IRequestGetFollowPrivateMsgFriendListCallback* callback
                                                               ){
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetFollowPrivateMsgFriendListTask* task = new HttpGetFollowPrivateMsgFriendListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetPrivateMsgHistoryById(
                                                          HttpRequestManager *pHttpRequestManager,
                                                          const string& toId,
                                                          const string& startMsgId,
                                                          PrivateMsgOrderType order,
                                                          int limit,
                                                          int reqId,
                                                          IRequestGetPrivateMsgHistoryByIdCallback* callback
                                                          ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPrivateMsgHistoryByIdTask* task = new HttpGetPrivateMsgHistoryByIdTask();
    task->Init(pHttpRequestManager);
    task->SetParam(toId, startMsgId, order, limit, reqId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SetPrivateMsgReaded(
                              HttpRequestManager *pHttpRequestManager,
                              const string& toId,
                              const string& msgId,
                              IRequestSetPrivateMsgReadedCallback* callback
                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSetPrivateMsgReadedTask* task = new HttpSetPrivateMsgReadedTask();
    task->Init(pHttpRequestManager);
    task->SetParam(toId, msgId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetPushConfig(
                        HttpRequestManager *pHttpRequestManager,
                        IRequestGetPushConfigCallback* callback
                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPushConfigTask* task = new HttpGetPushConfigTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::SetPushConfig(
                        HttpRequestManager *pHttpRequestManager,
                        bool isPriMsgAppPush,
                        bool isMailAppPush,
                        bool isSayHiAppPush,
                        IRequestSetPushConfigCallback* callback
                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSetPushConfigTask* task = new HttpSetPushConfigTask();
    task->Init(pHttpRequestManager);
    task->SetParam(isPriMsgAppPush, isMailAppPush, isSayHiAppPush);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetLoiList(
                                            HttpRequestManager *pHttpRequestManager,
                                            LSLetterTag tag,
                                            int start,
                                            int step,
                                            IRequestGetLoiListCallback* callback
                                            ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetLoiListTask* task = new HttpGetLoiListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(tag, start, step);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetLoiDetail(
                                              HttpRequestManager *pHttpRequestManager,
                                              string loiId,
                                              IRequestGetLoiDetailCallback* callback
                                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetLoiDetailTask* task = new HttpGetLoiDetailTask();
    task->Init(pHttpRequestManager);
    task->SetParam(loiId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetEmfboxList(
                          HttpRequestManager *pHttpRequestManager,
                          LSEMFType type,
                          LSLetterTag tag,
                          int start,
                          int step,
                          IRequestGetEmfListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetEmfListTask* task = new HttpGetEmfListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(type, tag, start, step);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::GetEmfDetail(
                                              HttpRequestManager *pHttpRequestManager,
                                              string emfId,
                                              IRequestGetEmfDetailCallback* callback
                                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetEmfDetailTask* task = new HttpGetEmfDetailTask();
    task->Init(pHttpRequestManager);
    task->SetParam(emfId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SendEmf(
                  HttpRequestManager *pHttpRequestManager,
                  string anchorId,
                  string loiId,
                  string emfId,
                  string content,
                  list<string> imgList,
                  LSLetterComsumeType comsumeType,
                  string sayHiResponseId,
                 bool isSchedule,
                 string timeZoneId,
                 string startTime,
                 int duration,
                  IRequestSendEmfCallback* callback
                  ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSendEmfTask* task = new HttpSendEmfTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId, loiId, emfId, content, imgList, comsumeType, sayHiResponseId, isSchedule, timeZoneId, startTime, duration);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

/**
 * 13.6.上传附件
 *
 * @param pHttpRequestManager           http管理器
 * @param emfId                         意向信ID
 * @param callback                      接口回调
 *
 * @return                              成功请求Id
 */
long long HttpRequestController::UploadLetterPhoto(
                            HttpRequestManager *pHttpRequestManager,
                            string file,
                            string fileName,
                            IRequestUploadLetterPhotoCallback* callback
                            ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpUploadLetterPhotoTask* task = new HttpUploadLetterPhotoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(file, fileName);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::BuyPrivatePhotoVideo(
                               HttpRequestManager *pHttpRequestManager,
                               string emfId,
                               string resourceId,
                               LSLetterComsumeType comsumeType,
                               IRequestBuyPrivatePhotoVideoCallback* callback
                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpBuyPrivatePhotoVideoTask* task = new HttpBuyPrivatePhotoVideoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(emfId, resourceId, comsumeType);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetSendMailPrice(
                                                  HttpRequestManager *pHttpRequestManager,
                                                  int imgNumber,
                                                  IRequestGetSendMailPriceCallback* callback
                                                  ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetSendMailPriceTask* task = new HttpGetSendMailPriceTask();
    task->Init(pHttpRequestManager);
    task->SetParam(imgNumber);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::CanSendEmf(
                                            HttpRequestManager *pHttpRequestManager,
                                            const string& anchorId,
                                            IRequestCanSendEmfCallback* callback
                                            ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpCanSendEmfTask* task = new HttpCanSendEmfTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetEmfStatus(
                                              HttpRequestManager *pHttpRequestManager,
                                              const string& emfId,
                                              IRequestGetEmfStatusCallback* callback
                                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetEmfStatusTask* task = new HttpGetEmfStatusTask();
    task->Init(pHttpRequestManager);
    task->SetParam(emfId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SayHiConfig(
                                             HttpRequestManager *pHttpRequestManager,
                                             IRequestResourceConfigCallback* callback
                                             ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpResourceConfigTask* task = new HttpResourceConfigTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetSayHiAnchorList(
                                                    HttpRequestManager *pHttpRequestManager,
                                                    IRequestGetSayHiAnchorListCallback* callback
                                                    ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetSayHiAnchorListTask* task = new HttpGetSayHiAnchorListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::IsCanSendSayHi(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string& anchorId,
                                                IRequestIsCanSendSayHiCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpIsCanSendSayHiTask* task = new HttpIsCanSendSayHiTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SendSayHi(
                                           HttpRequestManager *pHttpRequestManager,
                                           const string& anchorId,
                                           const string& themeId,
                                           const string& textId,
                                           IRequestSendSayHiCallback* callback
                                           ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSendSayHiTask* task = new HttpSendSayHiTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId, themeId, textId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetAllSayHiList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 int start,
                                                 int step,
                                                 IRequestGetAllSayHiListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetAllSayHiListTask* task = new HttpGetAllSayHiListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetResponseSayHiList(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      LSSayHiListType type,
                                                      int start,
                                                      int step,
                                                      IRequestGetResponseSayHiListCallback* callback
                                                      ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetResponseSayHiListTask* task = new HttpGetResponseSayHiListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SayHiDetail(
                                             HttpRequestManager *pHttpRequestManager,
                                             LSSayHiDetailType type,
                                             const string& sayHiId,
                                             IRequestSayHiDetailCallback* callback
                                             ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSayHiDetailTask* task = new HttpSayHiDetailTask();
    task->Init(pHttpRequestManager);
    task->SetParam(type, sayHiId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ReadResponse(
                                              HttpRequestManager *pHttpRequestManager,
                                              const string& sayHiId,
                                              const string& responseId,
                                              IRequestReadResponseCallback* callback
                                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpReadResponseTask* task = new HttpReadResponseTask();
    task->Init(pHttpRequestManager);
    task->SetParam(sayHiId, responseId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::UpQnInviteId(
                                              HttpRequestManager *pHttpRequestManager,
                                              const string& manId,
                                              const string& anchorId,
                                              const string& inviteId,
                                              const string& roomId,
                                              LSBubblingInviteType inviteType,
                                              IRequestUpQnInviteIdCallback* callback
                                              ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpUpQnInviteIdTask* task = new HttpUpQnInviteIdTask();
    task->Init(pHttpRequestManager);
    task->SetParam(manId, anchorId, inviteId, roomId, inviteType);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::RetrieveBanner(
                         HttpRequestManager *pHttpRequestManager,
                         string manId,
                         bool isAnchorPage,
                         LSBannerType bannerType,
                         IRequestRetrieveBannerCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpRetrieveBannerTask* task = new HttpRetrieveBannerTask();
    task->Init(pHttpRequestManager);
    task->SetParam(manId, isAnchorPage, bannerType);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetStoreGiftList(
                                                  HttpRequestManager *pHttpRequestManager,
                                                  const string& anchorId,
                                                  IRequestGetStoreGiftListCallback* callback
                                                  ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetStoreGiftListTask* task = new HttpGetStoreGiftListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetFlowerGiftDetail(
                                                     HttpRequestManager *pHttpRequestManager,
                                                     const string& giftId,
                                                     IRequestGetFlowerGiftDetailCallback* callback
                                                     ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetFlowerGiftDetailTask* task = new HttpGetFlowerGiftDetailTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetRecommendGiftList(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      const string& giftId,
                                                      const string& anchorId,
                                                      int number,
                                                      IRequestGetRecommendGiftListCallback* callback
                                                      ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetRecommendGiftListTask* task = new HttpGetRecommendGiftListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(giftId, anchorId, number);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetResentRecipientList(
                                                        HttpRequestManager *pHttpRequestManager,
                                                        IRequestGetResentRecipientListCallback* callback
                                                        ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetResentRecipientListTask* task = new HttpGetResentRecipientListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetDeliveryList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 IRequestGetDeliveryListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetDeliveryListTask* task = new HttpGetDeliveryListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetCartGiftTypeNum(
                                                    HttpRequestManager *pHttpRequestManager,
                                                    const string& anchorId,
                                                    IRequestGetCartGiftTypeNumCallback* callback
                                                    ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetCartGiftTypeNumTask* task = new HttpGetCartGiftTypeNumTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::GetCartGiftList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 int start,
                                                 int step,
                                                 IRequestGetCartGiftListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetCartGiftListTask* task = new HttpGetCartGiftListTask();
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::AddCartGift(
                                             HttpRequestManager *pHttpRequestManager,
                                             const string& anchorId,
                                             const string& giftId,
                                             IRequestAddCartGiftCallback* callback
                                             ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpAddCartGiftTask* task = new HttpAddCartGiftTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId, giftId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::ChangeCartGiftNumber(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      const string& anchorId,
                                                      const string& giftId,
                                                      int giftNumber,
                                                      IRequestChangeCartGiftNumberCallback* callback
                                                      ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpChangeCartGiftNumberTask* task = new HttpChangeCartGiftNumberTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId, giftId, giftNumber);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::RemoveCartGift(
                                                HttpRequestManager *pHttpRequestManager,
                                                const string& anchorId,
                                                const string& giftId,
                                                IRequestRemoveCartGiftCallback* callback
                                                ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpRemoveCartGiftTask* task = new HttpRemoveCartGiftTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId, giftId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::CheckOutCartGift(
                                                  HttpRequestManager *pHttpRequestManager,
                                                  const string& anchorId,
                                                  IRequestCheckOutCartGiftCallback* callback
                                                  ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpCheckOutCartGiftTask* task = new HttpCheckOutCartGiftTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::CreateGiftOrder(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string& anchorId,
                                                 const string& greetingMessage,
                                                 const string& specialDeliveryRequest,
                                                 IRequestCreateGiftOrderCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpCreateGiftOrderTask* task = new HttpCreateGiftOrderTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId, greetingMessage, specialDeliveryRequest);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::CheckDiscount(
                                               HttpRequestManager *pHttpRequestManager,
                                               const string& anchorId,
                                               IRequestCheckDiscountCallback* callback
                                               ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpCheckDiscountTask* task = new HttpCheckDiscountTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::WomanListAdvert(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string& deviceId,
                                                 LSAdvertSpaceType adspaceId,
                                                 IRequestWomanListAdvertCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpWomanListAdvertTask* task = new HttpWomanListAdvertTask();
    task->Init(pHttpRequestManager);
    task->SetParam(deviceId, adspaceId);
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
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetScheduleDurationList(
                                                         HttpRequestManager *pHttpRequestManager,
                                                         IRequestGetScheduleDurationListCallback* callback
                                                         ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetScheduleDurationListTask* task = new HttpGetScheduleDurationListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetCountryTimeZoneList(
                                                        HttpRequestManager *pHttpRequestManager,
                                                        IRequestGetCountryTimeZoneListCallback* callback
                                                        ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetCountryTimeZoneListTask* task = new HttpGetCountryTimeZoneListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SendScheduleInvite(
                                                    HttpRequestManager *pHttpRequestManager,
                                                    LSScheduleInviteType type,
                                                    string refId,
                                                    string anchorId,
                                                    string timeZoneId,
                                                    string startTime,
                                                    int duration,
                                                    IRequestSendScheduleInviteCallback* callback
                                                    ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSendScheduleInviteTask* task = new HttpSendScheduleInviteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(type, refId, anchorId, timeZoneId, startTime, duration);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::AcceptScheduleInvite(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      string inviteId,
                                                      int duration,
                                                      IRequestAcceptScheduleInviteCallback* callback
                                                      ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpAcceptScheduleInviteTask* task = new HttpAcceptScheduleInviteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId, duration);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::DeclinedScheduleInvite(
                                                        HttpRequestManager *pHttpRequestManager,
                                                        string inviteId,
                                                        IRequestDeclinedScheduleInviteCallback* callback
                                                        ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpDeclinedScheduleInviteTask* task = new HttpDeclinedScheduleInviteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::CancelScheduleInvite(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      string inviteId,
                                                      IRequestCancelScheduleInviteCallback* callback
                                                      ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpCancelScheduleInviteTask* task = new HttpCancelScheduleInviteTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetScheduleInviteList(
                                                       HttpRequestManager *pHttpRequestManager,
                                                       LSScheduleInviteStatus status,
                                                       LSScheduleSendFlagType sendFlag,
                                                       string anchorId,
                                                       int start,
                                                       int step,
                                                       IRequestGetScheduleInviteListCallback* callback
                                                       ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetScheduleInviteListTask* task = new HttpGetScheduleInviteListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(status, sendFlag, anchorId, start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetScheduleInviteDetail(
                                                         HttpRequestManager *pHttpRequestManager,
                                                         string inviteId,
                                                         IRequestGetScheduleInviteDetailCallback* callback
                                                         ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetScheduleInviteDetailTask* task = new HttpGetScheduleInviteDetailTask();
    task->Init(pHttpRequestManager);
    task->SetParam(inviteId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetSessionInviteList(
                                                      HttpRequestManager *pHttpRequestManager,
                                                      LSScheduleInviteType type,
                                                      string refId,
                                                      IRequestGetSessionInviteListCallback* callback
                                                      ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetSessionInviteListTask* task = new HttpGetSessionInviteListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(type, refId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetScheduleInviteStatus(
                                                         HttpRequestManager *pHttpRequestManager,
                                                         IRequestGetScheduleInviteStatusCallback* callback
                                                         ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetScheduleInviteStatusTask* task = new HttpGetScheduleInviteStatusTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetActivityTime(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 IRequestGetActivityTimeCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetActivityTimeTask* task = new HttpGetActivityTimeTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetPremiumVideoTypeList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 IRequestGetPremiumVideoTypeListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPremiumVideoTypeListTask* task = new HttpGetPremiumVideoTypeListTask();
    task->Init(pHttpRequestManager);
    task->SetParam();
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::GetPremiumVideoList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                     const string& typeIds,
                                                     int start,
                                                     int step,
                                                 IRequestGetPremiumVideoListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPremiumVideoListTask* task = new HttpGetPremiumVideoListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(typeIds, start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetPremiumVideoKeyRequestList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                     LSAccessKeyType type,
                                                     int start,
                                                     int step,
                                                 IRequestGetPremiumVideoKeyRequestListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPremiumVideoKeyRequestListTask* task = new HttpGetPremiumVideoKeyRequestListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(type, start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::SendPremiumVideoKeyRequest(
                                                 HttpRequestManager *pHttpRequestManager,
                                                     const string& videoId,
                                                 IRequestSendPremiumVideoKeyRequestCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpSendPremiumVideoKeyRequestTask* task = new HttpSendPremiumVideoKeyRequestTask();
    task->Init(pHttpRequestManager);
    task->SetParam(videoId );
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::RemindeSendPremiumVideoKeyRequest(
                                                 HttpRequestManager *pHttpRequestManager,
                                                     const string& keyRequestId,
                                                 IRequestRemindeSendPremiumVideoKeyRequestCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpRemindeSendPremiumVideoKeyRequestTask* task = new HttpRemindeSendPremiumVideoKeyRequestTask();
    task->Init(pHttpRequestManager);
    task->SetParam(keyRequestId );
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetPremiumVideoRecentlyWatchedList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                     int start,
                                                     int step,
                                                 IRequestGetPremiumVideoRecentlyWatchedListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPremiumVideoRecentlyWatchedListTask* task = new HttpGetPremiumVideoRecentlyWatchedListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::DeletePremiumVideoRecentlyWatched(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string& watchedId,
                                                 IRequestDeletePremiumVideoRecentlyWatchedCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpDeletePremiumVideoRecentlyWatchedTask* task = new HttpDeletePremiumVideoRecentlyWatchedTask();
    task->Init(pHttpRequestManager);
    task->SetParam(watchedId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetInterestedPremiumVideoList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                     int start,
                                                     int step,
                                                 IRequestGetInterestedPremiumVideoListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetInterestedPremiumVideoListTask* task = new HttpGetInterestedPremiumVideoListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(start, step);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::DeleteInterestedPremiumVideo(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string& videoId,
                                                 IRequestDeleteInterestedPremiumVideoCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpDeleteInterestedPremiumVideoTask* task = new HttpDeleteInterestedPremiumVideoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(videoId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::AddInterestedPremiumVideo(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string& videoId,
                                                 IRequestAddInterestedPremiumVideoCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpAddInterestedPremiumVideoTask* task = new HttpAddInterestedPremiumVideoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(videoId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::RecommendPremiumVideoList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 int num,
                                                 IRequestRecommendPremiumVideoListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpRecommendPremiumVideoListTask* task = new HttpRecommendPremiumVideoListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(num);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetAnchorPremiumVideoList(
                                                 HttpRequestManager *pHttpRequestManager,
                                                 const string& anchorId,
                                                 IRequestGetAnchorPremiumVideoListCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetAnchorPremiumVideoListTask* task = new HttpGetAnchorPremiumVideoListTask();
    task->Init(pHttpRequestManager);
    task->SetParam(anchorId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}

long long HttpRequestController::GetPremiumVideoDetail(
                                                 HttpRequestManager *pHttpRequestManager,
                                                     const string& videoId,
                                                 IRequestGetPremiumVideoDetailCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpGetPremiumVideoDetailTask* task = new HttpGetPremiumVideoDetailTask();
    task->Init(pHttpRequestManager);
    task->SetParam(videoId );
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}


long long HttpRequestController::UnlockPremiumVideo(
                                                 HttpRequestManager *pHttpRequestManager,
                                                LSUnlockActionType type,
                                                const string& accessKey,
                                                const string& videoId,
                                                 IRequestUnlockPremiumVideoCallback* callback
                                                 ) {
    long long requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    
    HttpUnlockPremiumVideoTask* task = new HttpUnlockPremiumVideoTask();
    task->Init(pHttpRequestManager);
    task->SetParam(type, accessKey, videoId);
    task->SetCallback(callback);
    task->SetHttpTaskCallback(this);
    
    requestId = (long long)task;
    
    mRequestMap.Lock();
    mRequestMap.Insert(task, task);
    mRequestMap.Unlock();
    
    if( !task->Start() ) {
        // 当task->start为fail已经delet 了，如线程太多时b  ::Start( [Create Thread Fail : Resource temporarily unavailable] )
        //        mRequestMap.Lock();
        //        mRequestMap.Erase(task);
        //        mRequestMap.Unlock();
        //
        //        delete task;
        requestId = LS_HTTPREQUEST_INVALIDREQUESTID;
    }
    
    return requestId;
}
