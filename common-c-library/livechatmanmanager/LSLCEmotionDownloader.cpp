/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCEmotionDownloader.h
 *   desc: LiveChat高级表情下载器
 */

#include "LSLCEmotionDownloader.h"
#include <common/CommonFunc.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

LSLCEmotionDownloader::LSLCEmotionDownloader()
{
	m_callback = NULL;
	m_emotionItem = NULL;
	m_fileType = funknow;
}

LSLCEmotionDownloader::~LSLCEmotionDownloader()
{

}

// 开始下载
bool LSLCEmotionDownloader::Start(const string& url
								, const string& filePath
								, EmotionFileType fileType
								, LSLCEmotionItem* item
								, LSLCEmotionDownloaderCallback* callback
								, const string& httpUser
								, const string& httpPassword)
{
	bool result = false;

	FileLog("LiveChatManager", "LSLCEmotionDownloader::Start() url:%s, filePath:%s, fileType:%d, item:%p, callback:%p"
			, url.c_str(), filePath.c_str(), fileType, item, callback);

	if (!url.empty()
		&& !filePath.empty()
		&& fileType != funknow
		&& item != NULL
		&& callback != NULL)
	{
		m_emotionItem = item;
		m_callback = callback;
		m_fileType = fileType;
		result = m_downloader.StartDownload(url, filePath, this, httpUser, httpPassword);

		FileLog("LiveChatManager", "LSLCEmotionDownloader::Start() url:%s, filePath:%s, fileType:%d, result:%d"
				, url.c_str(), filePath.c_str(), fileType, result);
	}

	return result;
}

// 停止下载
void LSLCEmotionDownloader::Stop()
{
	m_downloader.Stop();
}

// --------------- IHttpDownloaderCallback ---------------
// 下载成功
void LSLCEmotionDownloader::onSuccess(HttpDownloader* loader)
{
	if (m_emotionItem != NULL) {
        m_emotionItem->LockEmotion();
		if (m_fileType == fimage) {
			m_emotionItem->m_imagePath = loader->GetFilePath();
		}
		else if (m_fileType == fplaybigimage) {
			m_emotionItem->m_playBigPath = loader->GetFilePath();
		}
        m_emotionItem->UnlockEmotion();
	}

	if (m_callback != NULL) {
		m_callback->onSuccess(this, m_fileType, m_emotionItem);
	}
}

// 下载失败
void LSLCEmotionDownloader::onFail(HttpDownloader* loader)
{
	if (m_callback != NULL) {
		m_callback->onFail(this, m_fileType, m_emotionItem);
	}
}

// 下载进度更新
void LSLCEmotionDownloader::onUpdate(HttpDownloader* loader)
{

}
