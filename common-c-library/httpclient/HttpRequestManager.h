/*
 * HttpRequestManager.h
 *
 *  Created on: 2015-2-28
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPREQUESTMANAGER_H_
#define HTTPREQUESTMANAGER_H_

#include "HttpRequest.h"

#include <common/KMutex.h>

#include <map>
using namespace std;

class IHttpRequestManagerCallback {
public:
    virtual ~IHttpRequestManagerCallback(){};
    virtual void OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size) = 0;
    virtual void OnReceiveBody(HttpRequest* request, const char* buf, int size){};
};

typedef map<HttpRequest*, HttpRequest*> HttpRequestMap;
typedef map<HttpRequest*, IHttpRequestManagerCallback*> IHttpRequestManagerCallbackMap;

class HttpRequestManager : public IHttpRequestCallback {
public:
	HttpRequestManager();
	virtual ~HttpRequestManager();

	void SetWebSite(string website);

	/**
	 * 设置客户端版本号
	 */
	void SetVersionCode(string versionKey, string versionCode);

	/**
	 * 设置认证信息
	 */
	void SetAuthorization(string user, string password);

	/**
	 * 开始发起请求
	 * @param path		请求路径
	 * @param entiy		请求体
	 * @param callback	回调实例
	 * @param bNoCache	是否不缓存结果, 如果是, 可通过onReceiveBody处理自定义数据, onSuccess没有数据返回
	 * 							           如果否, 在onSuccess可以获得缓存的所有结果
	 * @return 请求实例
	 */
	const HttpRequest* StartRequest(
                                    const string& path,
                                    HttpEntiy& entiy,
                                    IHttpRequestManagerCallback* callback = NULL,
                                    void* custom = NULL,
                                    bool bNoCache = false
                                    );

    /**
     * 停止请求
     * @param request	请求
     */
    void StopRequest(const HttpRequest* request);
    
	/**
	 * 停止请求
	 */
	void StopAllRequest(bool bWait = false);

protected:
    // Implement IHttpRequestCallback 
    void OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size);
	void OnReceiveBody(HttpRequest* request, const char* buf, int size);
    
private:
	string mWebSite;

	string mUser;
	string mPassword;
	string mVersionKey;
	string mVersionCode;

    KMutex mRequestMutex;
	HttpRequestMap mHttpRequestMap;
	IHttpRequestManagerCallbackMap mIHttpRequestManagerCallbackMap;
    
    KMutex mStopAllRequestMutex;
    bool mStopAllRequest;
	
};

#endif /* HTTPREQUESTMANAGER_H_ */
