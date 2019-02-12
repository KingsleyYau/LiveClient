/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCVoiceManager.h
 *   desc: LiveChat语音管理器
 */

#include "LSLCVoiceManager.h"
#include "LSLCMessageItem.h"
#include <common/IAutoLock.h>
#include <httpclient/HttpRequestDefine.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

LSLCVoiceManager::LSLCVoiceManager()
{
	m_dirPath = "";

	m_sendingMapLock = IAutoLock::CreateAutoLock();
	if (NULL != m_sendingMapLock) {
		m_sendingMapLock->Init();
	}

	m_requestIdMapLock = IAutoLock::CreateAutoLock();
	if (NULL != m_requestIdMapLock) {
		m_requestIdMapLock->Init();
	}

	m_requestMsgMapLock = IAutoLock::CreateAutoLock();
	if (NULL != m_requestMsgMapLock) {
		m_requestMsgMapLock->Init();
	}
}

LSLCVoiceManager::~LSLCVoiceManager()
{
	IAutoLock::ReleaseAutoLock(m_sendingMapLock);
	IAutoLock::ReleaseAutoLock(m_requestIdMapLock);
	IAutoLock::ReleaseAutoLock(m_requestMsgMapLock);
}

// 初始化
bool LSLCVoiceManager::Init(const string& dirPath)
{
	bool result = false;
	if (!dirPath.empty())
	{
		m_dirPath = dirPath;
		if (m_dirPath.at(m_dirPath.length()-1) != '/'
			&& m_dirPath.at(m_dirPath.length()-1) != '\\')
		{
			m_dirPath += "/";
		}
        
        // 创建目录
        result = MakeDir(m_dirPath);
	}
	return result;
}

// 获取语音本地缓存文件路径
string LSLCVoiceManager::GetVoicePath(LSLCMessageItem* item)
{
	string path = "";
	if (item->m_msgType == MT_Voice
			&& !item->GetVoiceItem()->m_voiceId.empty()
			&& !m_dirPath.empty())
	{
		path = GetVoicePath(item->GetVoiceItem()->m_voiceId, item->GetVoiceItem()->m_fileType);
	}
	return path;
}

// 获取语音本地缓存文件路径
string LSLCVoiceManager::GetVoicePath(const string& voiceId, const string& fileType)
{
	string path = "";
	if (!voiceId.empty() && !fileType.empty())
	{
		path = m_dirPath + voiceId;
		path += "." + fileType;
	}
	return path;
}

// 复制文件至缓冲目录(用于发送语音消息)
bool LSLCVoiceManager::CopyVoiceFileToDir(LSLCMessageItem* item)
{
	bool result = false;
	string desFilePath = GetVoicePath(item);
	if (!desFilePath.empty()) {
		string srcFilePath = item->GetVoiceItem()->m_filePath;
		result = CopyFile(srcFilePath, desFilePath);
	}
	return result;
}

// --------------------- sending（正在发送） --------------------------
// 获取从待发送map表中获取指定文件路径的item，并把item从照表中移除
LSLCMessageItem* LSLCVoiceManager::GetAndRemoveSendingItem(int msgId)
{
	LSLCMessageItem* item = NULL;

	LockSendingMap();
	SendingMap::iterator iter = m_sendingMap.begin();
	if (iter != m_sendingMap.end())
	{
		item = (*iter).second;
		m_sendingMap.erase(iter);
	}
	UnlockSendingMap();

	return item;
}

// 添加到待发送map表中
bool LSLCVoiceManager::AddSendingItem(int msgId, LSLCMessageItem* item)
{
	bool result = false;

	LockSendingMap();
	if (item->m_msgType == MT_Voice
			&& NULL != item->GetVoiceItem()
			&& m_sendingMap.end() == m_sendingMap.find(msgId))
	{
		m_sendingMap.insert(SendingMap::value_type(msgId, item));
		result = true;
	}
	UnlockSendingMap();

	return result;
}

// 清除所有待发送表map表的item
void LSLCVoiceManager::ClearAllSendingItems()
{
	LockSendingMap();
	m_sendingMap.clear();
	UnlockSendingMap();
}

// ----------------------- Uploading/Downloading Voice（正在上传/下载） -------------------------
// 获取正在上传/下载的RequestId
long LSLCVoiceManager::GetRequestIdWithItem(LSLCMessageItem* item)
{
	long requestId = HTTPREQUEST_INVALIDREQUESTID;

	LockRequestMsgMap();
	RequestMsgMap::iterator iter = m_requestMsgMap.find(item->m_msgId);
	if (iter != m_requestMsgMap.end()) {
		requestId = (*iter).second;
	}
	UnlockRequestMsgMap();

	return requestId;
}

// 添加到正在上传/下载的map
bool LSLCVoiceManager::AddRequestItem(long requestId, LSLCMessageItem* item)
{
	bool result = false;

	LockRequestIdMap();
	LockRequestMsgMap();

	if (item->m_msgType == MT_Voice
			&& NULL != item->GetVoiceItem())
	{
		if (m_requestIdMap.end() == m_requestIdMap.find(requestId)) {
			m_requestIdMap.insert(RequestIdMap::value_type(requestId, item));
		}

		if (m_requestMsgMap.end() == m_requestMsgMap.find(item->m_msgId)) {
			m_requestMsgMap.insert(RequestMsgMap::value_type(item->m_msgId, requestId));
		}

		result = true;
	}

	UnlockRequestIdMap();
	UnlockRequestMsgMap();
	return result;
}

// 获取并移除正在上传/下载的item
LSLCMessageItem* LSLCVoiceManager::GetAndRemoveRquestItem(long requestId)
{
	LSLCMessageItem* item = NULL;

	LockRequestIdMap();
	LockRequestMsgMap();
	RequestIdMap::iterator iter = m_requestIdMap.find(requestId);
	if (iter != m_requestIdMap.end())
	{
		item = (*iter).second;
		m_requestIdMap.erase(iter);

		RequestMsgMap::iterator msgIter = m_requestMsgMap.find(item->m_msgId);
		if (msgIter != m_requestMsgMap.end())
		{
			m_requestMsgMap.erase(msgIter);
		}
	}
	UnlockRequestIdMap();
	UnlockRequestMsgMap();

	return item;
}

// 清除所有上传/下载item
list<long> LSLCVoiceManager::ClearAllRequestItem()
{
	list<long> result;

	LockRequestIdMap();
	LockRequestMsgMap();
	for (RequestIdMap::iterator iter = m_requestIdMap.begin();
			iter != m_requestIdMap.end();
			iter++)
	{
		result.push_back((*iter).first);
	}
	m_requestIdMap.clear();
	m_requestMsgMap.clear();
	UnlockRequestIdMap();
	UnlockRequestMsgMap();

	return result;
}

// ----------------------- HttpDownloader -------------------------
// 下载成功
void LSLCVoiceManager::onSuccess(HttpDownloader* loader)
{

}

// 下载失败
void LSLCVoiceManager::onFail(HttpDownloader* loader)
{

}

// 下载进度更新
void LSLCVoiceManager::onUpdate(HttpDownloader* loader)
{

}

// ----------------------- Map Lock -------------------------
// 正在发送map表(msgId, item)加锁
void LSLCVoiceManager::LockSendingMap()
{
	if (NULL != m_sendingMapLock) {
		m_sendingMapLock->Lock();
	}
}

// 正在发送map表(msgId, item)解锁
void LSLCVoiceManager::UnlockSendingMap()
{
	if (NULL != m_sendingMapLock) {
		m_sendingMapLock->Unlock();
	}
}

// 正在请求map表(requestId, item)加锁
void LSLCVoiceManager::LockRequestIdMap()
{
	if (NULL != m_requestIdMapLock) {
		m_requestIdMapLock->Lock();
	}
}

// 正在请求map表(requestId, item)解锁
void LSLCVoiceManager::UnlockRequestIdMap()
{
	if (NULL != m_requestIdMapLock) {
		m_requestIdMapLock->Unlock();
	}
}

// 正在请求map表(item, requestId)加锁
void LSLCVoiceManager::LockRequestMsgMap()
{
	if (NULL != m_requestMsgMapLock) {
		m_requestMsgMapLock->Lock();
	}
}

// 正在请求map表(item, requestId)解锁
void LSLCVoiceManager::UnlockRequestMsgMap()
{
	if (NULL != m_requestMsgMapLock) {
		m_requestMsgMapLock->Unlock();
	}
}
