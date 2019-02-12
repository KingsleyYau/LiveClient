/*
 * author: Alex shum
 *   date: 2016-09-08
 *   file: LSLCMagicIconManager.h
 *   desc: LiveChat小高级表情管理类
 */

#pragma once

#include <httpclient/HttpDownloader.h>
#include <common/IAutoLock.h>
#include <manrequesthandler/LSLiveChatRequestLiveChatController.h>
#include <manrequesthandler/item/LSLCMagicIconConfig.h>
#include "LSLCMagicIconDownloader.h"

#include <map>
#include <list>
#include <common/list_lock.h>

using namespace std;

class LSLCMagicIconManager;
class LSLCMagicIconManagerCallback
{
public:
	LSLCMagicIconManagerCallback() {};
	virtual ~LSLCMagicIconManagerCallback() {};
public:
	virtual void OnDownloadMagicIconImage(bool result, LSLCMagicIconItem* magicIconItem) = 0;
	virtual void OnDownloadMagicIconThumbImage(bool result, LSLCMagicIconItem* magicIconItem) = 0;
};

class LSLCMessageItem;
class LSLCMagicIconDownloader;
class LSLCMagicIconManager : private LSLCMagicIconDownloaderCallback
{
private:
	// <magicIconId, item>
	typedef map<string, LSLCMagicIconItem*> MagicIconMap;
	// <msgId, LSLCMessageItem>
	typedef map<int, LSLCMessageItem*> ToSendMap;
	// <magicIconId, downloader>
	typedef map<string, LSLCMagicIconDownloader*> MagicIconDownloaderMap;
private:
	// 已下载完成的downloader（待释放）
	typedef struct _tagFinishDownloaderItem {
		LSLCMagicIconDownloader*	downloader;
		long long finishTime;

		_tagFinishDownloaderItem()
		{
			downloader = NULL;
			finishTime = 0;
		}

		_tagFinishDownloaderItem(const _tagFinishDownloaderItem& item)
		{
			downloader = item.downloader;
			finishTime = item.finishTime;
		}
	} FinishDownloaderItem;
	typedef list_lock<FinishDownloaderItem>	FinishDownloaderList;	// 已下载完成的downloader（待释放）

public:
	LSLCMagicIconManager();
	virtual ~LSLCMagicIconManager();

public:
	// 设置本地缓存目录路径
	bool SetDirPath(const string& dirPath, const string& logPath);
	// 初始化
	bool Init(const string& host, LSLCMagicIconManagerCallback* callback);
	// 设置http认证帐号
	void SetAuthorization(const string& httpUser, const string& httpPassword);
private:
	// 设备下载路径
	bool SetDownloadPath(const string& downloadPath);

	// ------------------- 小高级表情配置操作 --------------------
public:
	// 判断版本是否比当前配置版本新
	bool IsVerNewThenConfigItem(long updateTime) const;
	// 更新配置
	bool UpdateConfigItem(const LSLCMagicIconConfig& configItem);
	// 获取配置item
	LSLCMagicIconConfig GetConfigItem() const;
private:
	// 从文件中获取配置item
	bool GetConfigItemWithFile();
	// 把配置item保存到文件
	bool SaveConfigItemToFile();

	// ------------------- 小高级表情ID的map表操作 --------------------
public:
	// 获取/添加小高级表情item
	LSLCMagicIconItem* GetMagicIcon(const string& MagicIconId);
private:
	// 添加配置item的小高级表情至map （批量）
	void AddMagicIconWithConfigItem(const LSLCMagicIconConfig& configItem);
	// 批量添加高级表情至map（放弃）
	//void AddEmotions(const OtherEmotionConfigItem::EmotionList& emotionList);
	// 添加小高级表情至map
	bool AddMagicIconItem(LSLCMagicIconItem* item);
	// 清除所有小高级表情item
	void RemoveAllMagicIconItem();
	// 高级小表情ID map加锁
	void LockMagicIconMap();
	// 小高级表情ID map解锁
	void UnlockMagicIconMap();

	// ------------------- 小高级表情发送map表操作 --------------------
public:
	// 获取并移除待发送的item
	LSLCMessageItem* GetAndRemoveSendingItem(int msgId);
	// 添加待发送item
	bool AddSendingItem(LSLCMessageItem* item);
	// 清除所有待发送item
	void RemoveAllSendingItems();
private:
	// 小高级表情消息发送map加锁
	void LockToSendMap();
	// 小高级表情消息发送map解锁
	void UnlockToSendMap();

	// ------------------- 路径处理（包括URL及本地路径） --------------------
public:
	// 获取小高级表情图片目录
	string GetImageDir();
    
    // 获取原图的下载URL
    string GetMagicIconImgUrl(const string& magicIconId);
    // 获取母子图的下载URL
    string GetMagicIconThumbUrl(const string& magicIconId);
    // 获取原图路径
    string GetMagicIconImagLocalPath(const string& magicIconId);
     // 获取拇子图路径
    string GetMagicIconThumbLocalPath(const string& magicIconId);
    
private:
	// 删除所有小高级表情文件
	void DeleteAllMagicIconFile();

	// ------------ 下载原图image ------------
public:
	// 开始下载原图image
	bool StartDownloadSourceImage(LSLCMagicIconItem* item);
	// 停止下载原图image
	bool StopDownloadSourceImage(LSLCMagicIconItem* item);
	// 停止所有原图image下载
	void StopAllDownloadSourceImage();
	// 释放所有待释放Downloader(已下载完成，包括成功/失败)
	void ClearAllDownloader();
	// 清除超过一段时间已下载完成的downloader
	void ClearFinishDownloaderWithTimer();
private:
	// 下载原图image map加锁
	void LockSourceImgDownloadMap();
	// 下载原图image map解锁
	void UnlockSourceImgDownloadMap();
	// 添加downloader到待释放列表(已下载完成，包括成功/失败)
	void AddToFinishDownloaderList(LSLCMagicIconDownloader* downloader);

	// ------------ 下载Thumbimage ------------
public:
	// 开始下载拇子图image
	bool StartDownloadThumbImage(LSLCMagicIconItem* item);
	// 停止下载拇子图image
	bool StopDownloadThumbImage(LSLCMagicIconItem* item);
	// 停止下载所有拇子图image
	bool StopAllDownloadThumbImage();
	// 下载拇子图image map加锁
	void LockThumbImgDownloadMap();
	// 下载拇子图image map解锁
	void UnlockThumbImgDownloadMap();

	// ------------- LSLCMagicIconDownloaderCallback -------------
private:
	virtual void onSuccess(LSLCMagicIconDownloader* downloader, LSLCMagicIconDownloader::MagicIconDownloadType downloadType, LSLCMagicIconItem* item);
	virtual void onFail(LSLCMagicIconDownloader* downloader, LSLCMagicIconDownloader::MagicIconDownloadType downloadType, LSLCMagicIconItem* item);

private:
	MagicIconMap	m_magicIconMap;		// 小高级表情ID与item的map表
	IAutoLock*	m_magicIconMapLock;	// 小高级表情map表锁

	ToSendMap	m_toSendMap;		// 正在发送map表（msgId, item）
	IAutoLock*	m_toSendMapLock;	// 正在发送map表锁

	string 		m_dirPath;			// 本地缓存目录路径
	string		m_host;				// http下载host

	string		m_downloadPath;		// 文件下载目录路径
	MagicIconDownloaderMap	m_thumbImgDownloadMap;		// 小高级表情原图片下载map表
	IAutoLock*				m_thumbImgDownloadMapLock;	// 小高级表情原图片下载map表锁
	MagicIconDownloaderMap	m_sourceImgDownloadMap;	// 小高级表情拇子图片下载map表
	IAutoLock*				m_sourceImgDownloadMapLock;	// 小高级表情拇子图片下载map表锁
	string		m_httpUser;			// http认证帐号
	string		m_httpPassword;		// http认证密码
	FinishDownloaderList	m_finishDownloaderList;		// 待释放下载器列表

	LSLCMagicIconConfig	m_configItem;			// 小高级表情配置item
	LSLCMagicIconManagerCallback*	m_callback;	// 回调

public:
	long 		m_magicIconConfigReqId;	// GetMagicIConConfig的RequestId
};
