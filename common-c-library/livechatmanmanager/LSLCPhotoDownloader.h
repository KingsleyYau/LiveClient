/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCPhotoDownloader.h
 *   desc: LiveChat图片下载器
 */

#pragma once

#include <string>
#include <common/map_lock.h>
#include <manrequesthandler/LSLiveChatRequestLiveChatController.h>
using namespace std;

class LSLiveChatHttpRequestManager;
class LSLCMessageItem;
class LSLCPhotoManager;
class LSLCPhotoDownloaderCallback;
class LSLCPhotoDownloader
{
public:
	LSLCPhotoDownloader();
	virtual ~LSLCPhotoDownloader();

public:
	bool Init(LSLiveChatHttpRequestManager* requestMgr, LSLiveChatRequestLiveChatController* requestController, LSLCPhotoManager* photoMgr);
	bool StartGetPhoto(
			LSLCPhotoDownloaderCallback* callback
			, LSLCMessageItem* item
			, const string& userId
			, const string& sid
			, GETPHOTO_PHOTOSIZE_TYPE sizeType
			, GETPHOTO_PHOTOMODE_TYPE modeType);
	bool Stop();
	long GetRequestId() const;

	// 回调函数
public:
	void OnGetPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath);
    
private:
    bool IsStart();
    bool IsFinish();

private:
	LSLCPhotoManager*	m_photoMgr;
	LSLiveChatHttpRequestManager*	m_requestMgr;
	LSLiveChatRequestLiveChatController*	m_requestController;
	LSLCPhotoDownloaderCallback*	m_callback;
	long	m_requestId;
	LSLCMessageItem*	m_item;
	GETPHOTO_PHOTOSIZE_TYPE	m_sizeType;
	GETPHOTO_PHOTOMODE_TYPE m_modeType;
    bool    m_isStart;
};

class LSLCPhotoDownloaderCallback
{
public:
	LSLCPhotoDownloaderCallback() {};
	virtual ~LSLCPhotoDownloaderCallback() {};
public:
	virtual void onSuccess(LSLCPhotoDownloader* downloader, GETPHOTO_PHOTOSIZE_TYPE sizeType, LSLCMessageItem* item) = 0;
	virtual void onFail(LSLCPhotoDownloader* downloader, GETPHOTO_PHOTOSIZE_TYPE sizeType, const string& errnum, const string& errmsg, LSLCMessageItem* item) = 0;
};
