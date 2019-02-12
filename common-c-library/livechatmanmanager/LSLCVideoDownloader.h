/*
 * author: Samson.Fan
 *   date: 2016-01-28
 *   file: LSLCVideoDownloader.h
 *   desc: LiveChat视频下载器
 */

#pragma once

#include <string>
#include <common/map_lock.h>
#include <httpclient/HttpDownloader.h>
using namespace std;

class LSLiveChatHttpRequestManager;
class LSLiveChatRequestLiveChatController;
class LSLCVideoManager;
class LSLCVideoDownloaderCallback;
class LSLCVideoDownloader : private IHttpDownloaderCallback
{
public:
	LSLCVideoDownloader();
	virtual ~LSLCVideoDownloader();

public:
	bool Init(LSLCVideoManager* videoMgr);
	bool StartDownload(
			LSLCVideoDownloaderCallback* callback
			, const string& userId
			, const string& sid
			, const string& womanId
			, const string& videoId
			, const string& inviteId
			, const string& videoUrl
			, const string& filePath
			, const string& httpUser
			, const string& httpPasswrod);
	void Stop();
	
	// 获取请求参数
	string GetWomanId() const;
	string GetVideoId() const;
	string GetInviteId() const;
	string GetVideoUrl() const;
	string GetFilePath() const;

	// ---- IHttpDownloaderCallback ----
private:
	// 下载成功
	virtual void onSuccess(HttpDownloader* loader);
	// 下载失败
	virtual void onFail(HttpDownloader* loader);
	// 下载进度更新
	virtual void onUpdate(HttpDownloader* loader);

private:
	LSLCVideoManager*	m_videoMgr;
	HttpDownloader	m_downloader;
	LSLCVideoDownloaderCallback*	m_callback;

	string	m_womanId;
	string	m_videoId;
	string	m_inviteId;
	string	m_videoUrl;
	string	m_filePath;
};

class LSLCVideoDownloaderCallback
{
public:
	LSLCVideoDownloaderCallback() {};
	virtual ~LSLCVideoDownloaderCallback() {};
public:
	virtual void onFinish(LSLCVideoDownloader* downloader, bool success) = 0;
};
