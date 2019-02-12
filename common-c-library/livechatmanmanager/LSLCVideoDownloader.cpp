/*
 * author: Samson.Fan
 *   date: 2016-01-28
 *   file: LSLCVideoDownloader.h
 *   desc: LiveChat视频下载类
 */

#include "LSLCVideoDownloader.h"
#include "LSLCVideoManager.h"
#include <manrequesthandler/LSLiveChatHttpRequestManager.h>
#include <manrequesthandler/LSLiveChatRequestLiveChatController.h>
#include <common/CheckMemoryLeak.h>

LSLCVideoDownloader::LSLCVideoDownloader()
{
	m_videoMgr = NULL;
	m_callback = NULL;

	m_womanId = "";
	m_videoId = "";
	m_inviteId = "";
	m_filePath = "";
}

LSLCVideoDownloader::~LSLCVideoDownloader()
{
	Stop();
}

bool LSLCVideoDownloader::Init(LSLCVideoManager* videoMgr)
{
	bool result = false;
	if (NULL != videoMgr)
	{
		m_videoMgr = videoMgr;
		result = true;
	}

	FileLog("LiveChatManager", "LSLCVideoDownloader::Init()videoMgr:%p, result:%d"
			, videoMgr, result);

	return result;
}

bool LSLCVideoDownloader::StartDownload(
			LSLCVideoDownloaderCallback* callback
			, const string& userId
			, const string& sid
			, const string& womanId
			, const string& videoId
			, const string& inviteId
			, const string& videoUrl
			, const string& filePath
			, const string& httpUser
			, const string& httpPassword)
{
	bool result = false;
	if (NULL != callback
		&& !userId.empty()
		&& !sid.empty()
		&& !womanId.empty()
		&& !videoId.empty()
		&& !inviteId.empty()
		&& !filePath.empty())
	{
		result = m_downloader.StartDownload(videoUrl, filePath, this, httpUser, httpPassword);
		if (result)
		{
			m_callback = callback;

			m_womanId = womanId;
			m_videoId = videoId;
			m_inviteId = inviteId;
			m_videoUrl = videoUrl;
			m_filePath = filePath;
		}
	}
	return result;
}
	
void LSLCVideoDownloader::Stop()
{
	m_downloader.Stop();
}
	
string LSLCVideoDownloader::GetWomanId() const
{
	return m_womanId;
}
	
string LSLCVideoDownloader::GetVideoId() const
{
	return m_videoId;
}

string LSLCVideoDownloader::GetInviteId() const
{
	return m_inviteId;
}

string LSLCVideoDownloader::GetVideoUrl() const
{
	return m_videoUrl;
}
	
string LSLCVideoDownloader::GetFilePath() const
{
	return m_filePath;
}

// ---- IHttpDownloaderCallback ----
// 下载成功
void LSLCVideoDownloader::onSuccess(HttpDownloader* loader)
{
	if (NULL != m_callback) {
		m_callback->onFinish(this, true);
	}
}
	
// 下载失败
void LSLCVideoDownloader::onFail(HttpDownloader* loader)
{
	if (NULL != m_callback) {
		m_callback->onFinish(this, false);
	}
}

// 下载进度更新
void LSLCVideoDownloader::onUpdate(HttpDownloader* loader)
{
	
}
