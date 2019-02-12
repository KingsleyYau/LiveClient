/*
 * HttpRequest.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPREQUEST_H_
#define HTTPREQUEST_H_

#include "HttpClient.h"
#include "HttpRequestDefine.h"
#include <common/KThread.h>

#define MAX_RESPONED_BUFFER 4 * 1024
#define INVALID_REQUEST INVALID_PTHREAD

class HttpRequestRunnable;
class HttpRequest;
class IHttpRequestCallback {
public:
	virtual ~IHttpRequestCallback(){};
    virtual void OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size) = 0;
	virtual void OnReceiveBody(HttpRequest* request, const char* buf, int size) = 0;
};

class HttpRequest : public IHttpClientCallback {
	friend class HttpRequestRunnable;
    
public:
	HttpRequest();
	virtual ~HttpRequest();

	/**
     * 开始请求
     */
	long long StartRequest(const string& url, const HttpEntiy& entiy);
	long long StartRequest(string host, string path, const HttpEntiy& entiy);
    
    /**
     * 停止请求
     */
	void StopRequest(bool bWait = false);
	void SetCallback(IHttpRequestCallback *callback);
    
	// 设置是否缓存返回结果, 默认是缓存
	void SetNoCacheData(bool bCache = true);

    // 获取属性
	string GetUrl() const;
	string GetHost() const;
	string GetPath() const;

	// 获取下载总数据量及已收数据字节数
	void GetRecvDataCount(int& total, int& recv) const;
	// 获取上传总数据量及已收数据字节数
	void GetSendDataCount(int& total, int& send) const;
	// 获取 Content-Type
	string GetContentType() const;
    
    // 自定义数据
    void SetCustom(void *custom);
    void* GetCustom();
    
    // 获取requestId(也是线程id，为了兼容Qn的httpRequestManager回调用到的requestId)
    long GetLivechatRequsetId();
    
    
protected:
	void OnReceiveBody(HttpClient* client, const char* buf, int size);

private:
	void InitRespondBuffer();
	bool AddRespondBuffer(const char* buf, int size);

	HttpClient mHttpClient;
	KThread mKThread;
	HttpRequestRunnable* mpHttpRequestRunnable;
	IHttpRequestCallback* mpIHttpRequestCallback;

	string mUrl;
	string mHost;
	string mPath;
	HttpEntiy mEntiy;

	char* mpRespondBuffer;
	int miCurrentSize;
	int miCurrentCapacity;
	bool mbCache;
    
    void* mpCustom;
};

#endif /* HTTPREQUEST_H_ */
