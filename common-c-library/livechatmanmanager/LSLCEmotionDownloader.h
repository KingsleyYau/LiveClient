/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCEmotionDownloader.h
 *   desc: LiveChat高级表情下载器
 */

#pragma once

#include <httpclient/HttpDownloader.h>
#include "LSLCEmotionItem.h"

class LSLCEmotionDownloaderCallback;
class LSLCEmotionDownloader : private IHttpDownloaderCallback
{
public:
	// 高级表情待下载的文件类型
	typedef enum {
		funknow,			// 未知
		fimage,				// 缩略图
		fplaybigimage		// 播放的大图
	} EmotionFileType;

public:
	LSLCEmotionDownloader();
	virtual ~LSLCEmotionDownloader();

public:
	// 开始下载
	bool Start(const string& url
				, const string& filePath
				, EmotionFileType fileType
				, LSLCEmotionItem* item
				, LSLCEmotionDownloaderCallback* callback
				, const string& httpUser = ""
				, const string& httpPassword = "");
	// 停止下载
	void Stop();

// IHttpDownloaderCallback
private:
	// 下载成功
	virtual void onSuccess(HttpDownloader* loader);
	// 下载失败
	virtual void onFail(HttpDownloader* loader);
	// 下载进度更新
	virtual void onUpdate(HttpDownloader* loader);

private:
	HttpDownloader	m_downloader;	// 下载器
	LSLCEmotionDownloaderCallback*	m_callback;		// 回调
	LSLCEmotionItem*	m_emotionItem;	// 高级表情item
	EmotionFileType	m_fileType;		// 文件类型
};

class LSLCEmotionDownloaderCallback
{
public:
	LSLCEmotionDownloaderCallback() {};
	virtual ~LSLCEmotionDownloaderCallback() {};
public:
	virtual void onSuccess(LSLCEmotionDownloader* downloader, LSLCEmotionDownloader::EmotionFileType fileType, LSLCEmotionItem* item) = 0;
	virtual void onFail(LSLCEmotionDownloader* downloader, LSLCEmotionDownloader::EmotionFileType fileType, LSLCEmotionItem* item) = 0;
};
