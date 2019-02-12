/*
 * author: Alex shum
 *   date: 2016-09-08
 *   file: LSLCMagicIconDownloader.cpp
 *   desc: LiveChat小高级表情下载器
 */

#include "LSLCMagicIconDownloader.h"
#include <common/CommonFunc.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

LSLCMagicIconDownloader::LSLCMagicIconDownloader()
{
	m_callback = NULL;
	m_magicIconItem = NULL;
	m_downloadType = DEFAULT;
}

LSLCMagicIconDownloader::~LSLCMagicIconDownloader()
{

}

// 开始下载
bool LSLCMagicIconDownloader::Start(const string& url
								, const string& filePath
								, MagicIconDownloadType downloadType
								, LSLCMagicIconItem* item
								, LSLCMagicIconDownloaderCallback* callback
								, const string& httpUser
								, const string& httpPassword)
{
	bool result = false;

	FileLog("LiveChatManager", "LSLCMagicIconDownloader::Start() url:%s, filePath:%s, downloadType:%d, item:%p, callback:%p"
			, url.c_str(), filePath.c_str(), downloadType, item, callback);

	if (!url.empty()
		&& !filePath.empty()
		&& downloadType != DEFAULT
		&& item != NULL
		&& callback != NULL)
	{
		m_magicIconItem = item;
		m_callback = callback;
		m_downloadType = downloadType;
		result = m_downloader.StartDownload(url, filePath, this, httpUser, httpPassword);

		FileLog("LiveChatManager", "LSLCMagicIconDownloader::Start() url:%s, filePath:%s, downloadType:%d, result:%d"
				, url.c_str(), filePath.c_str(), downloadType, result);
	}

	return result;
}

// 停止下载
void LSLCMagicIconDownloader::Stop()
{
	m_downloader.Stop();
}

// --------------- IHttpDownloaderCallback ---------------
// 下载成功
void LSLCMagicIconDownloader::onSuccess(HttpDownloader* loader)
{
	if (m_magicIconItem != NULL) {
		if (m_downloadType == THUMB) {
			m_magicIconItem->m_thumbPath = loader->GetFilePath();
		}
		else if (m_downloadType == SOURCE) {
			m_magicIconItem->m_sourcePath = loader->GetFilePath();
		}
	}

	if (m_callback != NULL) {
		m_callback->onSuccess(this, m_downloadType, m_magicIconItem);
	}
}

// 下载失败
void LSLCMagicIconDownloader::onFail(HttpDownloader* loader)
{
	if (m_callback != NULL) {
		m_callback->onFail(this, m_downloadType, m_magicIconItem);
	}
}

// 下载进度更新
void LSLCMagicIconDownloader::onUpdate(HttpDownloader* loader)
{

}
