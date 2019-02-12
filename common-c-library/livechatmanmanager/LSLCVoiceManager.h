/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCVoiceManager.h
 *   desc: LiveChat语音管理器
 */

#pragma once

#include <httpclient/HttpDownloader.h>
#include <map>
#include <list>
#include <string>
using namespace std;

class IAutoLock;
class LSLCMessageItem;
class LSLCVoiceManager : public IHttpDownloaderCallback
{
private:
	typedef map<int, LSLCMessageItem*>		SendingMap;		// 正在发送map表(msgId, item)（记录未发送成功item，发送成功则移除）
	typedef map<long, LSLCMessageItem*>		RequestIdMap;	// 正在请求map表(requestId, item)
	typedef map<int, long>					RequestMsgMap;	// 正在请求map表(msgId, requestId)

public:
	LSLCVoiceManager();
	virtual ~LSLCVoiceManager();

public:
	// 初始化
	bool Init(const string& dirPath);
	// 获取语音本地缓存文件路径
	string GetVoicePath(LSLCMessageItem* item);
	// 获取语音本地缓存文件路径
	string GetVoicePath(const string& voiceId, const string& fileType);
	// 复制文件至缓冲目录(用于发送语音消息)
	bool CopyVoiceFileToDir(LSLCMessageItem* item);

	// --------------------- sending（正在发送） --------------------------
public:
	// 获取从待发送map表中获取指定文件路径的item，并把item从照表中移除
	LSLCMessageItem* GetAndRemoveSendingItem(int msgId);
	// 添加到待发送map表中
	bool AddSendingItem(int msgId, LSLCMessageItem* item);
	// 清除所有待发送表map表的item
	void ClearAllSendingItems();

	// ----------------------- Uploading/Downloading Voice（正在上传/下载） -------------------------
public:
	// 获取正在上传/下载的RequestId
	long GetRequestIdWithItem(LSLCMessageItem* item);
	// 添加到正在上传/下载的map
	bool AddRequestItem(long requestId, LSLCMessageItem* item);
	// 获取并移除正在上传/下载的item
	LSLCMessageItem* GetAndRemoveRquestItem(long requestId);
	// 清除所有上传/下载item
	list<long> ClearAllRequestItem();

	// ----------------------- HttpDownloader -------------------------
private:
	// 下载成功
	virtual void onSuccess(HttpDownloader* loader);
	// 下载失败
	virtual void onFail(HttpDownloader* loader);
	// 下载进度更新
	virtual void onUpdate(HttpDownloader* loader);

	// ----------------------- Map Lock -------------------------
private:
	// 正在发送map表(msgId, item)加锁
	void LockSendingMap();
	// 正在发送map表(msgId, item)解锁
	void UnlockSendingMap();

	// 正在请求map表(requestId, item)加锁
	void LockRequestIdMap();
	// 正在请求map表(requestId, item)解锁
	void UnlockRequestIdMap();

	// 正在请求map表(item, requestId)加锁
	void LockRequestMsgMap();
	// 正在请求map表(item, requestId)解锁
	void UnlockRequestMsgMap();

private:
	string	m_dirPath;		// 本地缓存目录路径

	SendingMap		m_sendingMap;			// 正在发送map表(msgId, item)（记录未发送成功item，发送成功则移除）
	IAutoLock*		m_sendingMapLock;		// 正在发送map表(msgId, item)锁

	RequestIdMap	m_requestIdMap;			// 正在请求map表(requestId, item)
	IAutoLock*		m_requestIdMapLock;		// 正在请求map表(requestId, item)锁

	RequestMsgMap	m_requestMsgMap;		// 正在请求map表(item, requestId)
	IAutoLock*		m_requestMsgMapLock;	// 正在请求map表(item, requestId)锁
};
