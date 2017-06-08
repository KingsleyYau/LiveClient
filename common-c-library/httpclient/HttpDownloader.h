/*
 * HttpDownloader.h
 *
 *  Created on: 2015-10-26
 *      Author: Samson
 * Description: http下载器
 */

#pragma once

#include "HttpRequest.h"

class HttpDownloader;
class IHttpDownloaderCallback
{
protected:
	IHttpDownloaderCallback() {};
	virtual ~IHttpDownloaderCallback(){};

public:
	// 下载成功
	virtual void onSuccess(HttpDownloader* loader) = 0;
	// 下载失败
	virtual void onFail(HttpDownloader* loader) = 0;
	// 下载进度更新
	virtual void onUpdate(HttpDownloader* loader) = 0;
};

class HttpDownloader : private IHttpRequestCallback
{
public:
	HttpDownloader();
	virtual ~HttpDownloader();

public:
	// 开始下载文件
	bool StartDownload(const string& url, const string& localPath, IHttpDownloaderCallback* callback, const string& httpUser = "", const string& httpPassword = "");
	// 停止下载文件
	void Stop();
	// 是否正在下载
	bool IsDownloading() const;
	// 获取下载的URL
	string GetUrl() const;
	// 获取本地文件路径
	string GetFilePath() const;
	// 获取已下载信息（total:总字节数，recv：已下载字节数）
	void GetProgress(int& total, int& recv) const;

private:
	// 获取临时文件路径
	inline string GetTempFilePath(const string& filePath) const;
	// 打开临时文件
	inline bool OpenTempFile();
	// 关闭临时文件
	inline void CloseTempFile();
	// 删除临时文件
	inline void RemoveTempFile();
	// 修改临时文件名
	inline bool RenameTempFile();

private:
    // IHttpRequestCallback
	virtual void OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size);
	virtual void OnReceiveBody(HttpRequest* request, const char* buf, int size);

private:
	HttpRequest	m_request;		// http request
	IHttpDownloaderCallback*	m_callback;			// 回调
	FILE*	m_pFile;			// 文件句柄
	string	m_filePath;			// 本地文件路径
	bool	m_isDownloading;	// 是否正在下载标志
};
