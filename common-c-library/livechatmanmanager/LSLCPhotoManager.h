/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCPhotoManager.h
 *   desc: LiveChat图片管理类
 */

#pragma once

#include <string>
#include <common/list_lock.h>
#include <map>
#include <common/dualmap_lock.h>
#include <manrequesthandler/LSLiveChatRequestLiveChatDefine.h>
#include "LSLCPhotoDownloader.h"
#include "LSLCMessageItem.h"
using namespace std;

class LSLiveChatHttpRequestManager;
class LSLiveChatRequestLiveChatController;
class LSLCPhotoManagerCallback;
class LSLCMessageItem;
class LSLCUserItem;
class IAutoLock;
class LSLCPhotoItem;
class LSLCPhotoManager : public LSLCPhotoDownloaderCallback
{
private:
	typedef map<int, LSLCMessageItem*>		SendingMap;		// 正在发送消息map表(msgId, LSLCMessageItem)
	typedef map_lock<long, LSLCMessageItem*>	RequestMap;		// 正在请求map表(requestId, LSLCMessageItem)
	typedef dualmap_lock<long, LSLCPhotoDownloader*>	DownloadMap;	// 正在下载map表(requestId, downloader)
    typedef map_lock<string, LSLCPhotoItem*>  PhotoMap;       // Photo map表(PhotoID, LSLCPhotoItem)
    typedef map_lock<string, LCMessageList> PhotoMsgMap;    // PhotoID被哪些MessageItem引用(PhotoID, LCMessageList)

private:
	// 已下载完成的downloader（待释放）
	typedef struct _tagFinishDownloaderItem {
		LSLCPhotoDownloader*	downloader;
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
	LSLCPhotoManager();
	virtual ~LSLCPhotoManager();

public:
	// 初始化
	bool Init(LSLCPhotoManagerCallback* callback);
	// 设置本地缓存目录
	bool SetDirPath(const string& dirPath);
    // 设置临时本地缓存目录路径
    bool SetTempDirPath(const string& dirPath);
	// 设置http接口参数
	bool SetHttpRequest(LSLiveChatHttpRequestManager* requestMgr, LSLiveChatRequestLiveChatController* requestController);
	// 获取图片本地缓存文件路径
	string GetPhotoPath(LSLCMessageItem* item, GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType);
	// 获取图片本地缓存文件路径(全路径)
	string GetPhotoPath(const string& photoId, GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType);
    // 获取图片本地临时缓存文件路径
    string GetPhotoTempPath(LSLCMessageItem* item, GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType);
    // 获取图片本地临时缓存文件路径(全路径)
    string GetPhotoTempPath(const string& photoId, GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType);
    // 下载完成设置文件路径
	bool SetPhotoFilePath(LSLCMessageItem* item, GETPHOTO_PHOTOMODE_TYPE modeType, GETPHOTO_PHOTOSIZE_TYPE sizeType);
	// 复制文件至缓冲目录(用于发送图片消息)
	bool CopyPhotoFileToDir(LSLCPhotoItem* item, const string& srcFilePath);
	// 删除朦胧图片
	bool RemoveFuzzyPhotoFile(LSLCPhotoItem* item);
	// 清除所有图片
	void RemoveAllPhotoFile();
	// 合并图片消息记录（把女士发出及男士已购买的图片记录合并为一条聊天记录）
	void CombineMessageItem(LSLCUserItem* userItem);
    
    // --------------------- LSLCPhotoItem管理 --------------------------
public:
    // ---- PhotoMap管理 ----
    // 获取/生成PhotoItem
    LSLCPhotoItem* GetPhotoItem(const string& photoId, LSLCMessageItem* msgItem);
    // 更新/生成PhotoItem(以返回的PhotoItem为准)
    LSLCPhotoItem* UpdatePhotoItem(LSLCPhotoItem* photoItem, LSLCMessageItem* msgItem);
    // 清除PhotoMap
    void ClearPhotoMap();
    // ---- PhotoMsgMap管理 ----
    // 绑定关联
    bool BindPhotoIdWithMsgItem(const string& photoId, LSLCMessageItem* msgItem);
    // 获取关联的MessageList
    LCMessageList GetMsgListWithBindMap(const string& photoId);
    // 清除关联
    void ClearBindMap();

	// --------------------- sending（正在发送） --------------------------
public:
	// 获取指定票根的item并从待发送map表中移除
	LSLCMessageItem* GetAndRemoveSendingItem(int msgId);
	// 添加指定票根的item到待发送map表中
	bool AddSendingItem(LSLCMessageItem* item);
	// 清除所有待发送表map表的item
	void ClearAllSendingItems();

	// --------------------------- Download Photo（正在下载 ） -------------------------
public:
	// 开始下载
	bool DownloadPhoto(
			LSLCMessageItem* item
			, const string& userId
			, const string& sid
			, GETPHOTO_PHOTOSIZE_TYPE sizeType
			, GETPHOTO_PHOTOMODE_TYPE modeType);
	// 下载完成的回调(ILSLiveChatRequestLiveChatControllerCallback)
	void OnGetPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath);
	// 清除超过一段时间已下载完成的downloader
	void ClearFinishDownloaderWithTimer();
	// 清除下载
	void ClearAllDownload();
private:
	// 清除所有已下载完成的downloader
	void ClearAllFinishDownloader();
	// LSLCPhotoDownloaderCallback
	virtual void onSuccess(LSLCPhotoDownloader* downloader, GETPHOTO_PHOTOSIZE_TYPE sizeType, LSLCMessageItem* item);
	virtual void onFail(LSLCPhotoDownloader* downloader, GETPHOTO_PHOTOSIZE_TYPE sizeType, const string& errnum, const string& errmsg, LSLCMessageItem* item);

	// --------------------------- Request Photo（正在请求） -------------------------
public:
	// 添加到正在请求的map表
	bool AddRequestItem(long requestId, LSLCMessageItem* item);
	// 获取并移除正在请求的map表
	LSLCMessageItem* GetAndRemoveRequestItem(long requestId);
	// 获取并清除所有正在的请求
	void ClearAllRequestItems();

private:
	// 获取图片指定类型路径(非全路径)
	string GetPhotoPathWithMode(const string& photoId, GETPHOTO_PHOTOMODE_TYPE modeType);
	// 正在发送消息map表加锁
	void LockSendingMap();
	// 正在发送消息map表解锁
	void UnlockSendingMap();
    
    // --------------------------- Temp Photo Manage（临时图片管理） -------------------------
public:
    // 复制文件到临时目录（返回是否复制成功）
    bool CopyPhotoToTempDir(const string& srcPhotoPath, string& dstPhotoPath);
    // 清除临时目录的图片文件
    void RemoveAllTempPhotoFile();
    
private:
    // 生成临时文件名
    string GetTempPhotoFileName(const string& srcPhotoPath) const;
    
    // --------------------------- Request Photo Check -------------------------
public:
    // http 请求 检查私密照是否已经收费
    bool RequestCheckPhotoList(const string& userId, const string& sid);
    bool RequestCheckPhoto(LSLCMessageItem* item, const string& userId, const string& sid);
    //void OnCheckPhoto(long requestId, bool success, const string& errnum, const string& errmsg);
    
public:
	LSLCPhotoManagerCallback*		m_callback;				// callback
	LSLiveChatHttpRequestManager*			m_requestMgr;			// http request管理器
	LSLiveChatRequestLiveChatController*	m_requestController;	// LiveChat的http request控制器
	SendingMap		m_sendingMap;			// 正在发送消息map表
	IAutoLock*		m_sendingMapLock;		// 正在发送消息map表锁
	RequestMap		m_requestMap;			// 正在请求map表

	DownloadMap		m_downloadMap;			// 正在下载map表
	FinishDownloaderList	m_finishDownloaderList;	// 已完成下载列表（待释放）

	string			m_dirPath;				// 本地缓存目录路径
    string          m_tempDirPath;          // 临时本地缓存目录路径
    
    PhotoMap        m_photoMap;             // Photo map表
    PhotoMsgMap     m_photoBindMap;         // PhotoID被哪些MessageItem引用
};

class LSLCPhotoManagerCallback
{
public:
	LSLCPhotoManagerCallback() {};
	virtual ~LSLCPhotoManagerCallback() {}
public:
	virtual void OnDownloadPhoto(bool success, GETPHOTO_PHOTOSIZE_TYPE sizeType, const string& errnum, const string& errmsg, const LCMessageList& msgList) = 0;
    virtual void OnManagerCheckPhoto( bool success, const string& errnum, const string& errmsg, LSLCMessageItem* msgItem) = 0;
};

