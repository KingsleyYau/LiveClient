/*
 * HttpRequest.cpp
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "HttpRequest.h"

#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

class HttpRequestRunnable : public KRunnable {
public:
	HttpRequestRunnable(HttpRequest* pHttpRequest) {
		mpHttpRequest = pHttpRequest;
	}
	~HttpRequestRunnable(){
		mpHttpRequest = NULL;
	};

protected:
	void onRun() {
		bool bFlag = mpHttpRequest->mHttpClient.Request(&mpHttpRequest->mEntiy);
        if( mpHttpRequest->mpIHttpRequestCallback != NULL ) {
            mpHttpRequest->mpIHttpRequestCallback->OnFinish(
                                                            mpHttpRequest,
                                                            bFlag,
                                                            mpHttpRequest->mpRespondBuffer,
                                                            mpHttpRequest->miCurrentSize
                                                            );
        }
	}

private:
	HttpRequest *mpHttpRequest;
};

HttpRequest::HttpRequest() {
	// TODO Auto-generated constructor stub
	mpHttpRequestRunnable = new HttpRequestRunnable(this);
	mHttpClient.SetCallback(this);
	mpRespondBuffer = NULL;
	mbCache = false;
	miCurrentSize = 0;
	mpIHttpRequestCallback = NULL;
    mpCustom = NULL;
}

HttpRequest::~HttpRequest() {
	// TODO Auto-generated destructor stub
//	mHttpClient.Stop();
    StopRequest(true);

	if( mpHttpRequestRunnable != NULL ) {
		delete mpHttpRequestRunnable;
		mpHttpRequestRunnable = NULL;
	}

	if( mpRespondBuffer != NULL ) {
		delete[] mpRespondBuffer;
		mpRespondBuffer = NULL;
	}
}

long long HttpRequest::StartRequest(string host, string path, const HttpEntiy& entiy) {
	FileLog("httprequest",
            "HttpRequest::StartRequest( "
            "request : %p, "
			"host : %s, "
			"path : %s, "
			"entiy : %p "
			")",
            this,
			host.c_str(),
			path.c_str(),
			&entiy
            );

	mHost = host;
	mPath = path;

	return StartRequest(host + path, entiy);
}

long long HttpRequest::StartRequest(const string& url, const HttpEntiy& entiy)
{
	InitRespondBuffer();

	mUrl = url;
	mEntiy = entiy;

	mHttpClient.Init(mUrl);
	mKThread.Stop();
	return (long long)mKThread.Start(mpHttpRequestRunnable);
}

void HttpRequest::StopRequest(bool bWait) {
	FileLog("httprequest",
            "HttpRequest::StopRequest( "
            "request : %p, "
            "url : %s, "
            "bWait : %s "
            ")",
            this,
            mUrl.c_str(),
            bWait?"true":"false"
            );
	mHttpClient.Stop();
	if( bWait ) {
		mKThread.Stop();
	}
}

void HttpRequest::SetCallback(IHttpRequestCallback *callback){
	mpIHttpRequestCallback = callback;
}

void HttpRequest::SetNoCacheData(bool bCache) {
	mbCache = bCache;
}

string HttpRequest::GetUrl() const {
	return mUrl;
}

string HttpRequest::GetHost() const {
	return mHost;
}

string HttpRequest::GetPath() const {
	return mPath;
}

// 获取下载总数据量及已收数据字节数
void HttpRequest::GetRecvDataCount(int& total, int& recv) const {
	double dContentLength = mHttpClient.GetDownloadContentLength();
	total = (int)dContentLength;
	double dDownloadDataLength = mHttpClient.GetDownloadDataLength();
	recv = (int)dDownloadDataLength;
}

// 获取上传总数据量及已收数据字节数
void HttpRequest::GetSendDataCount(int& total, int& send) const {
	double dContentLength = mHttpClient.GetUploadContentLength();
	total = (int)dContentLength;
	double dUploadDataLength = mHttpClient.GetUploadDataLength();
	send = (int)dUploadDataLength;
}

string HttpRequest::GetContentType() const {
	FileLog("httprequest",
            "HttpRequest::GetHttpClient( "
            "request : %p, "
            "url : %s "
            ")",
            this,
            mHttpClient.GetUrl().c_str()
            );
	return mHttpClient.GetContentType();
}

void HttpRequest::OnReceiveBody(HttpClient* client, const char* buf, int size) {
	// 如果不缓存, 成功返回数据为0
	if( !mbCache ) {
		AddRespondBuffer(buf, size);
	}

	if( mpIHttpRequestCallback != NULL ) {
		mpIHttpRequestCallback->OnReceiveBody(
				this,
				buf,
				size
				);
	}
}

void HttpRequest::InitRespondBuffer() {
	if( mpRespondBuffer != NULL ) {
		delete[] mpRespondBuffer;
		mpRespondBuffer = NULL;
	}

	miCurrentSize = 0;
	miCurrentCapacity = MAX_RESPONED_BUFFER;
	mpRespondBuffer = new char[miCurrentCapacity];
    memset(mpRespondBuffer, '\0', miCurrentCapacity);
}

bool HttpRequest::AddRespondBuffer(const char* buf, int size) {
	bool bFlag = false;
	/* Add buffer if buffer is not enough */
	while( size + miCurrentSize >= miCurrentCapacity ) {
		miCurrentCapacity *= 2;
		bFlag = true;
	}
	if( bFlag ) {
		char *newBuffer = new char[miCurrentCapacity];
		if( mpRespondBuffer != NULL ) {
			memcpy(newBuffer, mpRespondBuffer, miCurrentSize);
			delete[] mpRespondBuffer;
			mpRespondBuffer = NULL;
		}
		mpRespondBuffer = newBuffer;
	}
	memcpy(mpRespondBuffer + miCurrentSize, buf, size);
	miCurrentSize += size;
	mpRespondBuffer[miCurrentSize] = '\0';
	return true;
}

void HttpRequest::SetCustom(void *custom) {
    mpCustom = custom;
}

void* HttpRequest::GetCustom() {
    return mpCustom;
}
