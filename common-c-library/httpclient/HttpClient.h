/*
 * HttpClient.h
 *
 *  Created on: 2014-12-24
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HttpClient_H_
#define HttpClient_H_

#include "HttpEntiy.h"

#include <list>
#include "CookiesItem.h"

class HttpClient;
class IHttpClientCallback {
public:
	virtual ~IHttpClientCallback(){};
	virtual void OnReceiveBody(HttpClient* client, const char* buf, int size) = 0;
};

class HttpClient {
public:
	HttpClient();
	virtual ~HttpClient();

	static void Init();
	static void SetLogEnable(bool enable);
	static void SetLogDirectory(string directory);
    static void SetProxy(string proxyUrl);
    
	// 设置cookies路径
	static void SetCookiesDirectory(string directory);
	// 清除所有域名cookies
	static void CleanCookies();
	// 清除指定域名cookies
	static void CleanCookies(string site);
	// 获取指定域名cookies
	static string GetCookies(string site);
	// 获取所有域名的cookies
	static list<string> GetCookiesInfo();
	// 设置cookies
	static void SetCookiesInfo(const list<string>& cookies);
	// 获取所有域名的cookieItem
	static list<CookiesItem> GetCookiesItem();

	void Stop();
	void Init(string url);
	bool Request(const HttpEntiy* entiy);

	void SetCallback(IHttpClientCallback *callback);
	string GetUrl() const;

	// 获取http头系列方法
	string GetContentType() const;
	// 获取上传ContentLength
	double GetUploadContentLength() const;
	// 获取已上传的数据长度
	double GetUploadDataLength() const;
	// 获取下载ContentLength
	double GetDownloadContentLength() const;
	// 获取已下载的数据长度
	double GetDownloadDataLength() const;

private:
	static size_t CurlHandle(void *buffer, size_t size, size_t nmemb, void *data);
	void HttpHandle(void *buffer, size_t size, size_t nmemb);
    
	static size_t CurlProgress(
			void *data,
            double downloadTotal,
            double downloadNow,
            double uploadTotal,
            double uploadNow
            );
	size_t HttpProgress(
            double downloadTotal,
            double downloadNow,
            double uploadTotal,
            double uploadNow
            );

	IHttpClientCallback *mpIHttpClientCallback;

	void *mpCURL;
	string mUrl;
	string mContentType;
	double mContentLength;

	// stop manually
	bool mbStop;

	// application timeout
	double mdUploadTotal;
	double mdUploadLast;
	double mdUploadLastTime;
	double mdDownloadTotal;
	double mdDownloadLast;
	double mdDownloadLastTime;
    double mdDownloadTimeout;
    // 判断是否是没有文本大小关闭curl，alex，2019-09-23
    bool mIsAborted;
};

#endif /* HttpClient_H_ */
