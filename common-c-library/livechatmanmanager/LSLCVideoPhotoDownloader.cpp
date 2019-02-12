/*
 * author: Samson.Fan
 *   date: 2016-01-28
 *   file: LSLCVideoPhotoDownloader.h
 *   desc: LiveChat视频图片下载类
 */

#include "LSLCVideoPhotoDownloader.h"
#include <common/CheckMemoryLeak.h>
#include <httpclient/HttpRequestDefine.h>
#include <common/CommonFunc.h>

LSLCVideoPhotoDownloader::LSLCVideoPhotoDownloader()
{
	m_videoMgr = NULL;
	m_requestMgr = NULL;
	m_requestController = NULL;
	m_callback = NULL;
	
	m_requestId = HTTPREQUEST_INVALIDREQUESTID;

	m_womanId = "";
	m_videoId = "";
	m_inviteId = "";
	m_type = VPT_BIG;
	m_filePath = "";
}

LSLCVideoPhotoDownloader::~LSLCVideoPhotoDownloader()
{
	Stop();
}

bool LSLCVideoPhotoDownloader::Init(LSLiveChatHttpRequestManager* requestMgr
							, LSLiveChatRequestLiveChatController* requestController
							, LSLCVideoManager* videoMgr)
{
	bool result = false;
	if (NULL != videoMgr
		&& NULL != requestMgr
		&& NULL != requestController)
	{
		m_videoMgr = videoMgr;
		m_requestMgr = requestMgr;
		m_requestController = requestController;

		result = true;
	}

	FileLog("LiveChatManager", "LSLCVideoPhotoDownloader::Init() requestMgr:%p, requestController:%p, videoMgr:%p, result:%d"
			, requestMgr, requestController, videoMgr, result);

	return result;
}

bool LSLCVideoPhotoDownloader::StartDownload(
			LSLCVideoPhotoDownloaderCallback* callback
			, const string& userId
			, const string& sid
			, const string& womanId
			, const string& videoId
			, const string& inviteId
			, VIDEO_PHOTO_TYPE type
			, const string& filePath)
{
	bool result = false;
	if (NULL != m_videoMgr
		&& NULL != m_requestMgr
		&& NULL != m_requestController
		&& NULL != callback
		&& !userId.empty()
		&& !sid.empty()
		&& !womanId.empty()
		&& !videoId.empty()
		&& !inviteId.empty()
		&& !filePath.empty())
	{
		m_requestId = m_requestController->GetVideoPhoto(userId, sid, womanId, videoId, type, filePath);
		result = (HTTPREQUEST_INVALIDREQUESTID != m_requestId);

		if (result)
		{
			m_callback = callback;
			m_womanId = womanId;
			m_videoId = videoId;
			m_inviteId = inviteId;
			m_type = type;
			m_filePath = filePath;
		}

		FileLog("LiveChatManager", "LSLCVideoPhotoDownloader::StartDownload() requestId:%d, result:%d", m_requestId, result);
	}
	else {
		FileLog("LiveChatManager", "LSLCVideoPhotoDownloader::StartDownload() param error!");
	}

	return result;
}

bool LSLCVideoPhotoDownloader::Stop()
{
	bool result = false;
	if (NULL != m_requestMgr) {
		result = m_requestMgr->StopRequest(m_requestId, true);
	}
	return result;
}

long LSLCVideoPhotoDownloader::GetRequestId() const
{
	return m_requestId;
}

string LSLCVideoPhotoDownloader::GetVideoId() const
{
	return m_videoId;
}

string LSLCVideoPhotoDownloader::GetWomanId() const
{
	return m_womanId;
}

string LSLCVideoPhotoDownloader::GetInviteId() const
{
	return m_inviteId;
}

VIDEO_PHOTO_TYPE LSLCVideoPhotoDownloader::GetVideoPhotoType() const
{
	return m_type;
}

string LSLCVideoPhotoDownloader::GetFilePath() const
{
	return m_filePath;
}

void LSLCVideoPhotoDownloader::OnGetVideoPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath)
{
	FileLog("LiveChatManager", "LSLCVideoPhotoDownloader::OnGetVideoPhoto() requestId:%d, m_requestId:%d, success:%d, errnum:%s, errmsg:%s, filePath:%s"
			, requestId, m_requestId, success, errnum.c_str(), errmsg.c_str(), filePath.c_str());

	bool isSuccess = false;
	if (m_requestId == requestId)
	{
		if (success) {
			isSuccess = IsFileExist(filePath);
		}
		
		m_callback->onFinish(this, isSuccess, errnum, errmsg);
	}
}
