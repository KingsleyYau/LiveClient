/*
 * author: Samson.Fan
 *   date: 2016-01-28
 *   file: LSLCVideoPhotoDownloader.h
 *   desc: LiveChat视频图片下载器
 */

#pragma once

#include <string>
#include <manrequesthandler/LSLiveChatRequestLiveChatController.h>
using namespace std;

class LSLCVideoManager;
class LSLiveChatHttpRequestManager;
class LSLiveChatRequestLiveChatController;
class LSLCVideoPhotoDownloaderCallback;
class LSLCVideoPhotoDownloader
{
public:
	LSLCVideoPhotoDownloader();
	virtual ~LSLCVideoPhotoDownloader();

public:
	bool Init(LSLiveChatHttpRequestManager* requestMgr, LSLiveChatRequestLiveChatController* requestController, LSLCVideoManager* videoMgr);
	bool StartDownload(
			LSLCVideoPhotoDownloaderCallback* callback
			, const string& userId
			, const string& sid
			, const string& womanId
			, const string& videoId
			, const string& inviteId
			, VIDEO_PHOTO_TYPE type
			, const string& filePath);
	bool Stop();
	long GetRequestId() const;
	
	// 获取请求参数
	string GetVideoId() const;
	string GetWomanId() const;
	string GetInviteId() const;
	VIDEO_PHOTO_TYPE GetVideoPhotoType() const;
	string GetFilePath() const;

	// 回调函数
public:
	void OnGetVideoPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath);

private:
	LSLCVideoManager*	m_videoMgr;
	LSLiveChatHttpRequestManager*	m_requestMgr;
	LSLiveChatRequestLiveChatController*	m_requestController;
	LSLCVideoPhotoDownloaderCallback*	m_callback;
	
	long	m_requestId;

	string	m_womanId;
	string	m_videoId;
	string	m_inviteId;
	VIDEO_PHOTO_TYPE	m_type;
	string	m_filePath;
};

class LSLCVideoPhotoDownloaderCallback
{
public:
	LSLCVideoPhotoDownloaderCallback() {};
	virtual ~LSLCVideoPhotoDownloaderCallback() {};
public:
	virtual void onFinish(LSLCVideoPhotoDownloader* downloader, bool success, const string& errnum, const string& errmsg) = 0;
};
