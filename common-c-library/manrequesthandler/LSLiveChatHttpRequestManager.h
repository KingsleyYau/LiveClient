/*
 * LSLiveChatHttpRequestManager.h
 *
 *  Created on: 2015-2-28
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATHTTPREQUESTMANAGERTT_H_
#define LSLIVECHATHTTPREQUESTMANAGERTT_H_

#include <map>
using namespace std;

#include <common/KMutex.h>

#include <httpclient/HttpRequest.h>

#include "LSLiveChatHttpRequestHostManager.h"

class ILSLiveChatHttpRequestManagerCallback {
public:
	virtual ~ILSLiveChatHttpRequestManagerCallback(){};
	virtual void onSuccess(long requestId, string path, const char* buf, int size) = 0;
	virtual void onFail(long requestId, string path) = 0;
	virtual void onReceiveBody(long requestId, string path, const char* buf, int size){};
};

typedef map<long, HttpRequest*> LSLCHttpRequestMap;
typedef map<long, ILSLiveChatHttpRequestManagerCallback*> ILSLCHttpRequestManagerCallbackMap;

class LSLiveChatHttpRequestManager : public IHttpRequestCallback {
public:
	LSLiveChatHttpRequestManager();
	virtual ~LSLiveChatHttpRequestManager();

//	void SetWebSite(string website);

	/**
	 * 设置客户端版本号
	 */
	void SetVersionCode(string version);

	/**
	 * 设置站点管理实例
	 */
	void SetHostManager(LSLiveChatHttpRequestHostManager *httpRequestHostManager);

    /**
     * app唯一标识
     */
    void SetAppId(string appId);
    
	/**
	 * 设置认证信息
	 */
	void SetAuthorization(string user, string password);

	/**
	 * 开始发起请求
	 * @param path		请求路径
	 * @param entiy		请求体
	 * @param callback	回调实例
	 * @param type		站点类型
	 * @param bNoCache	是否不缓存结果, 如果是, 可通过onReceiveBody处理自定义数据, onSuccess没有数据返回
	 * 							           如果否, 在onSuccess可以获得缓存的所有结果
	 * @return 请求唯一Id,	用于停止
	 */
	long StartRequest(string path, HttpEntiy& entiy, ILSLiveChatHttpRequestManagerCallback* callback = NULL,
			SiteType type = AppSite, bool bNoCache = false);

	/**
	 * 停止请求
	 * @param requestId	请求Id
	 */
	bool StopRequest(long requestId, bool bWait = false);

	/**
	 * 停止请求
     * @param bWait     是否等待停止
     * @param isCleanCallback	是否清除Callback（不Callback）
	 */
	void StopAllRequest(bool bWait = false, bool isCleanCallback = false);

	/**
	 * 获取请求实例
	 * 没有加锁, 只在回调里面调用
	 * @param requestId	请求Id
	 * @return 请求实例
	 */
	const HttpRequest* GetRequestById(long requestId);

protected:
//    void onSuccess(long requestId, string url, const char* buf, int size);
//    void onFail(long requestId, string url);
//    void onReceiveBody(long requestId, string url, const char* buf, int size);
    // 上面是QN男士端的回调，为兼容QN的http回调使用下面的回调
    void OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size);
    void OnReceiveBody(HttpRequest* request, const char* buf, int size);

private:
//	string mWebSite;
	LSLiveChatHttpRequestHostManager *mHttpRequestHostManager;
	string mUser;
	string mPassword;
	string mVersionCode;
    string mAppId;

	LSLCHttpRequestMap mHttpRequestMap;
	ILSLCHttpRequestManagerCallbackMap mIHttpRequestManagerCallbackMap;
	KMutex mKMutex;
};

#endif /* LIVECHATHTTPREQUESTMANAGERTT_H_ */
