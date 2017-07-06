/*
 * HttpRequestManager.cpp
 *
 *  Created on: 2015-2-28
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "HttpRequestManager.h"

#include <common/CommonFunc.h>
#include <common/KLog.h>

HttpRequestManager::HttpRequestManager()
:mRequestMutex(KMutex::MutexType_Recursive)
{
	// TODO Auto-generated constructor stub
	HttpClient::Init();
	mUser = "";
	mPassword = "";
    mStopAllRequest = false;
}

HttpRequestManager::~HttpRequestManager() {
	// TODO Auto-generated destructor stub
}

void HttpRequestManager::SetWebSite(string website) {
	FileLog("httprequest", "HttpRequestManager::SetWebSite( website : %s )", website.c_str());
	mWebSite = website;
}

void HttpRequestManager::SetVersionCode(string versionKey, string versionCode) {
	mVersionKey = versionKey;
	mVersionCode = versionCode;
}

void HttpRequestManager::SetAuthorization(string user, string password) {
	FileLog("httprequest", "HttpRequestManager::SetAuthorization( user : %s, password : %s )",
			user.c_str(), password.c_str());
	mUser = user;
	mPassword = password;
}

const HttpRequest* HttpRequestManager::StartRequest(
                                                    const string& path,
                                                    HttpEntiy& entiy,
                                                    IHttpRequestManagerCallback* callback,
                                                    void* custom,
                                                    bool bNoCache
                            
                                                    ) {
    HttpRequest *request = new HttpRequest();
    
    // 正在停止, 不能再发起新请求
    mStopAllRequestMutex.lock();
    if( !mStopAllRequest ) {
        string host = mWebSite;

        // 配置http用户认证
        entiy.SetAuthorization(mUser, mPassword);
        // 配置客户端版本
        entiy.AddHeader(mVersionKey, mVersionCode);

        // 开始请求
        request->SetCallback(this);
        request->SetNoCacheData(bNoCache);
        long long requestId = request->StartRequest(host, path, entiy);

        if( requestId != (long long)INVALID_REQUEST ) {
            // 发起请求成功
            FileLog("httprequest",
                    "HttpRequestManager::StartRequest( "
                    "[Success], "
                    "request : %p, "
                    "url : %s, "
                    "callback : %p, "
                    "custom : %p "
                    ") ",
                    request,
                    request->GetUrl().c_str(),
                    callback,
                    custom
                    );
            
            mRequestMutex.lock();
            mHttpRequestMap.insert(HttpRequestMap::value_type(request, request));
            if( callback != NULL ) {
                mIHttpRequestManagerCallbackMap.insert(IHttpRequestManagerCallbackMap::value_type(request, callback));
            }
            mRequestMutex.unlock();
            
        } else {
            // 发起请求失败
            FileLog("httprequest",
                    "HttpRequestManager::StartRequest( "
                    "[Fail], "
                    "request : %p, "
                    "url : %s, "
                    "callback : %p, "
                    "custom : %p "
                    ") ",
                    request,
                    request->GetUrl().c_str(),
                    callback,
                    custom
                    );
            
            delete request;
            request = NULL;
        }

    }
    mStopAllRequestMutex.unlock();
    
	return request;
}

void HttpRequestManager::StopRequest(const HttpRequest* request) {
    FileLog("httprequest", "HttpRequestManager::StopRequest( "
            "request : %p "
            ")",
            request
            );
    
    mRequestMutex.lock();
    HttpRequestMap::iterator itr = mHttpRequestMap.find((HttpRequest*)request);
    if( itr != mHttpRequestMap.end() ) {
        HttpRequest* requestStop = itr->second;
        requestStop->StopRequest();
    }
    mRequestMutex.unlock();
}

void HttpRequestManager::StopAllRequest(bool bWait) {
	FileLog("httprequest", "HttpRequestManager::StopAllRequest( "
            "bWait : %s "
            ")",
            bWait?"true":"false"
            );
    
    mStopAllRequestMutex.lock();
    mStopAllRequest = true;
    mStopAllRequestMutex.unlock();
    
	mRequestMutex.lock();
	for(HttpRequestMap::iterator itr = mHttpRequestMap.begin(); itr != mHttpRequestMap.end(); itr++) {
		HttpRequest* request = itr->second;

		if( request != NULL ) {
			request->StopRequest(false);
		}
	}
	mRequestMutex.unlock();
    
    mStopAllRequestMutex.lock();
    if( bWait ) {
        // 等待请求结束
        while( !mHttpRequestMap.empty() ) {
            Sleep(10);
        }
    }
    mStopAllRequest = false;
    mStopAllRequestMutex.unlock();
}

void HttpRequestManager::OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size) {
	FileLog("httprequest",
            "HttpRequestManager::OnFinish( "
			"request : %p, "
            "bFlag : %s, "
			"url : %s "
			")",
			request,
            bFlag?"true":"false",
			request->GetUrl().c_str()
			);

	mRequestMutex.lock();
    
    // 回调
    IHttpRequestManagerCallbackMap::iterator itr = mIHttpRequestManagerCallbackMap.find(request);
    if( itr != mIHttpRequestManagerCallbackMap.end() ) {
        if( itr->second != NULL ) {
            itr->second->OnFinish(request, bFlag, buf, size);
        }
        mIHttpRequestManagerCallbackMap.erase(itr);
    }

    // 删除请求
    if( request != NULL ) {
        delete request;
    }
    mHttpRequestMap.erase(request);
    
	mRequestMutex.unlock();
}

void HttpRequestManager::OnReceiveBody(HttpRequest* request, const char* buf, int size) {
	mRequestMutex.lock();

    IHttpRequestManagerCallbackMap::iterator itr = mIHttpRequestManagerCallbackMap.find(request);
    if( itr != mIHttpRequestManagerCallbackMap.end() ) {
        itr->second->OnReceiveBody(request, buf, size);
    }
	
	mRequestMutex.unlock();
}
