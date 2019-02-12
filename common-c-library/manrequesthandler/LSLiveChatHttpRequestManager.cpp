/*
 * LSLiveChatHttpRequestManager.cpp
 *
 *  Created on: 2015-2-28
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLiveChatHttpRequestManager.h"
#include "LSLiveChatRequestDefine.h"
#include <common/CheckMemoryLeak.h>

LSLiveChatHttpRequestManager::LSLiveChatHttpRequestManager() {
	// TODO Auto-generated constructor stub
	mUser = "";
	mPassword = "";
}

LSLiveChatHttpRequestManager::~LSLiveChatHttpRequestManager() {
	// TODO Auto-generated destructor stub
}

//void LSLiveChatHttpRequestManager::SetWebSite(string website) {
//	FileLog("httprequest", "LSLiveChatHttpRequestManager::SetWebSite( website : %s )", website.c_str());
//	mWebSite = website;
//}


void LSLiveChatHttpRequestManager::SetVersionCode(string version) {
	mVersionCode = version;
}

void LSLiveChatHttpRequestManager::SetAppId(string appId) {
    mAppId = appId;
}

void LSLiveChatHttpRequestManager::SetHostManager(LSLiveChatHttpRequestHostManager *httpRequestHostManager) {
	mHttpRequestHostManager = httpRequestHostManager;
}

void LSLiveChatHttpRequestManager::SetAuthorization(string user, string password) {
	FileLog("httprequest", "LSLiveChatHttpRequestManager::SetAuthorization( user : %s, password : %s )",
			user.c_str(), password.c_str());
	mUser = user;
	mPassword = password;
}

long LSLiveChatHttpRequestManager::StartRequest(string path, HttpEntiy& entiy, ILSLiveChatHttpRequestManagerCallback* callback,
		SiteType type, bool bNoCache) {
	FileLog("httprequest", "LSLiveChatHttpRequestManager::StartRequest( "
			"path : %s, "
			"entiy : %p, "
			"callback : %p )",
			path.c_str(),
			&entiy,
			callback
			);

	long requestId = HTTPREQUEST_INVALIDREQUESTID;

	string host = mHttpRequestHostManager->GetHostByType(type);

	// 配置http用户认证
	entiy.SetAuthorization(mUser, mPassword);

	// 配置客户端版本
	entiy.AddHeader(COMMON_VERSION_CODE, mVersionCode);
    
    // app唯一标识
    entiy.AddHeader(COMMON_APPID, mAppId);

	FileLog("httprequest", "LSLiveChatHttpRequestManager::StartRequest() request lock begin, path:%s", path.c_str());
	mKMutex.lock();
	FileLog("httprequest", "LSLiveChatHttpRequestManager::StartRequest() request lock ok, path:%s", path.c_str());

	HttpRequest *request = new HttpRequest();
	request->SetCallback(this);
	request->SetNoCacheData(bNoCache);
	requestId = request->StartRequest(host, path, entiy);

	mHttpRequestMap.insert(LSLCHttpRequestMap::value_type(requestId, request));
	if( callback != NULL ) {
		mIHttpRequestManagerCallbackMap.insert(ILSLCHttpRequestManagerCallbackMap::value_type(requestId, callback));
	}

	FileLog("httprequest", "LSLiveChatHttpRequestManager::StartRequest() request lock finish, path:%s", path.c_str());
	mKMutex.unlock();
	FileLog("httprequest", "LSLiveChatHttpRequestManager::StartRequest() request unlocked, path:%s", path.c_str());

	return requestId;
}

bool LSLiveChatHttpRequestManager::StopRequest(long requestId, bool bWait) {
	FileLog("httprequest", "LSLiveChatHttpRequestManager::StopRequest( requestId : %ld, bWait : %s )", requestId, bWait?"true":"false");

	bool bFlag = false;

	HttpRequest *request = NULL;
	mKMutex.lock();
	LSLCHttpRequestMap::iterator itr = mHttpRequestMap.find(requestId);
	if( itr != mHttpRequestMap.end() ) {

		request = itr->second;
		request->StopRequest(false);
//		mHttpRequestMap.erase(itr);

		bFlag = true;
	}
	mKMutex.unlock();

//	if( request != NULL ) {
//		request->StopRequest(bWait);
//		delete request;
//	}

	return bFlag;
}

void LSLiveChatHttpRequestManager::StopAllRequest(bool bWait, bool isCleanCallback) {
	FileLog("httprequest", "LSLiveChatHttpRequestManager::StopAllRequest()");

//    HttpRequest *request = NULL;
//    mKMutex.lock();
//    for(LSLCHttpRequestMap::iterator itr = mHttpRequestMap.begin(); itr != mHttpRequestMap.end(); itr++) {
//        request = itr->second;
//
//        if( request != NULL ) {
//            if (isCleanCallback) {
//                request->SetCallback(NULL);
//            }
//
//            request->StopRequest(bWait);
//        }
//    }
//    mKMutex.unlock();
    
    if (bWait) {
        // 停止所有请求需要等待时（之前没有这部分，会锁死在 onFail中mKMutex.lock()）
        while (true) {
            // 加锁遍历http所有请求map， 先erase后解锁， 在自己返回onFail， 可根据request是否时空，跳出循环
            HttpRequest *request = NULL;
            long requestId = -1;
            ILSLiveChatHttpRequestManagerCallback* callback = NULL;
            string path = "";
            mKMutex.lock();
            LSLCHttpRequestMap::iterator itr = mHttpRequestMap.begin();
            if (itr != mHttpRequestMap.end()) {
                request = itr->second;
                path = itr->second->GetPath();
                requestId = itr->first;
                ILSLCHttpRequestManagerCallbackMap::iterator callbackItr = mIHttpRequestManagerCallbackMap.find(requestId);
                if (callbackItr != mIHttpRequestManagerCallbackMap.end()) {
                    callback = callbackItr->second;
                    mIHttpRequestManagerCallbackMap.erase(callbackItr);
                }
                mHttpRequestMap.erase(itr);
            }
            mKMutex.unlock();
            
            if (request == NULL) {
                // 没有请求了，跳出循环
                break;
            } else {
                // 不加锁处理请求回调
                if (callback != NULL) {
                    callback->onFail(requestId, path);
                }
                request->StopRequest(bWait);
                delete request;
            }
        }
        
    } else {
        // 不等待请求处理
        HttpRequest *request = NULL;
        mKMutex.lock();
        for(LSLCHttpRequestMap::iterator itr = mHttpRequestMap.begin(); itr != mHttpRequestMap.end(); itr++) {
            request = itr->second;
            
            if( request != NULL ) {
                if (isCleanCallback) {
                    request->SetCallback(NULL);
                }
                
                request->StopRequest(bWait);
            }
        }
        mKMutex.unlock();
    }
    
}

const HttpRequest* LSLiveChatHttpRequestManager::GetRequestById(long requestId) {
	HttpRequest *request = NULL;
	LSLCHttpRequestMap::iterator itr = mHttpRequestMap.find(requestId);
	if( itr != mHttpRequestMap.end() ) {
		request = itr->second;
	}
	return request;
}

//void LSLiveChatHttpRequestManager::onSuccess(long requestId, string url, const char* buf, int size) {
//    FileLog("httprequest", "LSLiveChatHttpRequestManager::onSuccess( url : %s, buf( size : %d ) )", url.c_str(), size);
//
//    mKMutex.lock();
//    string path;
//    HttpRequest *request = NULL;
//
//    HttpRequestMap::iterator itr2 = mHttpRequestMap.find(requestId);
//    if( itr2 != mHttpRequestMap.end() ) {
//        path = itr2->second->GetPath();
//        IHttpRequestManagerCallbackMap::iterator itr = mIHttpRequestManagerCallbackMap.find(requestId);
//        if( itr != mIHttpRequestManagerCallbackMap.end() ) {
//            itr->second->onSuccess(requestId, path, buf, size);
//            mIHttpRequestManagerCallbackMap.erase(itr);
//        }
//
//        request = itr2->second;
//        if( request != NULL ) {
//            delete request;
//        }
//        mHttpRequestMap.erase(itr2);
//    }
//    mKMutex.unlock();
//
//
//    FileLog("httprequest", "HttpRequestManager::onSuccess( url : %s, buf( size : %d ), exit )", url.c_str(), size);
//}
//
//void LSLiveChatHttpRequestManager::onFail(long requestId, string url) {
//    FileLog("httprequest", "LSLiveChatHttpRequestManager::onFail( url : %s )", url.c_str());
//
//    mKMutex.lock();
//    string path;
//    HttpRequest *request = NULL;
//
//    HttpRequestMap::iterator itr2 = mHttpRequestMap.find(requestId);
//    if( itr2 != mHttpRequestMap.end() ) {
//        path = itr2->second->GetPath();
//
//        IHttpRequestManagerCallbackMap::iterator itr = mIHttpRequestManagerCallbackMap.find(requestId);
//        if( itr != mIHttpRequestManagerCallbackMap.end() ) {
//            itr->second->onFail(requestId, path);
//            mIHttpRequestManagerCallbackMap.erase(itr);
//        }
//
//        request = itr2->second;
//        if( request != NULL ) {
//            delete request;
//        }
//        mHttpRequestMap.erase(itr2);
//    }
//
//    mKMutex.unlock();
//
//    FileLog("httprequest", "LSLiveChatHttpRequestManager::onFail( url : %s, exit )", url.c_str());
//}
//
//void LSLiveChatHttpRequestManager::onReceiveBody(long requestId, string url, const char* buf, int size) {
//    FileLog("httprequest", "LSLiveChatHttpRequestManager::onReceiveBody( url : %s )", url.c_str());
//
//    mKMutex.lock();
//    string path;
//    HttpRequestMap::iterator itr2 = mHttpRequestMap.find(requestId);
//    if( itr2 != mHttpRequestMap.end() ) {
//        path = itr2->second->GetPath();
//
//        IHttpRequestManagerCallbackMap::iterator itr = mIHttpRequestManagerCallbackMap.find(requestId);
//        if( itr != mIHttpRequestManagerCallbackMap.end() ) {
//            itr->second->onReceiveBody(requestId, path, buf, size);
//        }
//    }
//
//    mKMutex.unlock();
//
//    FileLog("httprequest", "HttpRequestManager::onReceiveBody( url : %s, exit )", url.c_str());
//}

void LSLiveChatHttpRequestManager::OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size) {
        FileLog("httprequest", "LSLiveChatHttpRequestManager::OnFinish( url : %s bFlag：%d)", request->GetUrl().c_str(), bFlag);
    
        mKMutex.lock();
       string path = request->GetPath();
       long requestId = request->GetLivechatRequsetId();
        ILSLCHttpRequestManagerCallbackMap::iterator itr = mIHttpRequestManagerCallbackMap.find(requestId);
        if( itr != mIHttpRequestManagerCallbackMap.end() ) {
            if (bFlag) {
                 itr->second->onSuccess(requestId, path, buf, size);
            } else {
                itr->second->onFail(requestId, path);
            }
            
            mIHttpRequestManagerCallbackMap.erase(itr);
        }

        HttpRequest *livechatRequest = NULL;
        LSLCHttpRequestMap::iterator itr2 = mHttpRequestMap.find(requestId);
       if( itr2 != mHttpRequestMap.end() ) {
           livechatRequest = itr2->second;
           mHttpRequestMap.erase(itr2);
       }

    
        mKMutex.unlock();
    
    if( livechatRequest != NULL ) {
        delete livechatRequest;
    }
    
        FileLog("httprequest", "LSLiveChatHttpRequestManager::onFail( url : %s, exit )", request->GetUrl().c_str());
}
void LSLiveChatHttpRequestManager::OnReceiveBody(HttpRequest* request, const char* buf, int size) {
    FileLog("httprequest", "LSLiveChatHttpRequestManager::OnReceiveBody( url : %s )", request->GetUrl().c_str());

    mKMutex.lock();
    string path = request->GetPath();
    ILSLCHttpRequestManagerCallbackMap::iterator itr = mIHttpRequestManagerCallbackMap.find(request->GetLivechatRequsetId());
    if( itr != mIHttpRequestManagerCallbackMap.end() ) {
        itr->second->onReceiveBody(request->GetLivechatRequsetId(), path, buf, size);
    }

    mKMutex.unlock();

    FileLog("httprequest", "LSLiveChatHttpRequestManager::onReceiveBody( url : %s, exit )", request->GetUrl().c_str());
}
