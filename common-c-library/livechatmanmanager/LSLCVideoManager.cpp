/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCVideoManager.h
 *   desc: LiveChat视频管理器
 */

#include "LSLCVideoManager.h"
#include <common/IAutoLock.h>
#include "LSLCUserItem.h"
#include "LSLCVideoItem.h"
#include "LSLCMessageItem.h"
#include <manrequesthandler/LSLiveChatRequestLiveChatDefine.h>
#include <httpclient/HttpRequestDefine.h>
#include <httpclient/HttpDownloader.h>
#include <common/md5.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

LSLCVideoManager::LSLCVideoManager()
{
	m_callback = NULL;
	m_userMgr = NULL;

	m_requestMgr = NULL;
	m_requestController = NULL;
	m_httpUser = "";
	m_httpPassword = "";

	m_dirPath = "";
}

LSLCVideoManager::~LSLCVideoManager()
{

}

// 初始化
bool LSLCVideoManager::Init(LSLCVideoManagerCallback* callback, LSLCUserManager* userMgr)
{
	bool result= false;
	if (NULL != callback
		&& NULL != userMgr)
	{
		m_callback = callback;
		m_userMgr = userMgr;

		result = true;
	}
	return result;
}

// 设置本地缓存目录
bool LSLCVideoManager::SetDirPath(const string& dirPath)
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

// 设置http接口参数
bool LSLCVideoManager::SetHttpRequest(LSLiveChatHttpRequestManager* requestMgr, LSLiveChatRequestLiveChatController* requestController)
{
	bool result = false;

	if (NULL != requestMgr
		&& NULL != requestController)
	{
		m_requestMgr = requestMgr;
		m_requestController = requestController;
	}
	return result;
}

// 设置http认证帐号
void LSLCVideoManager::SetAuthorization(const string& httpUser, const string& httpPassword)
{
	m_httpUser = httpUser;
	m_httpPassword = httpPassword;
}

// --------------------------- 获取视频本地缓存路径 -------------------------
// 获取视频图片本地缓存文件路径(全路径)
string LSLCVideoManager::GetVideoPhotoPath(const string& userId
										, const string& videoId
										, const string& inviteId
										, VIDEO_PHOTO_TYPE type)
{
	string path = "";
	if (!userId.empty()
		&& !videoId.empty()
		&& !inviteId.empty())
	{
		// 生成文件名
		string temp = userId + videoId + inviteId;
		char cFileName[128] = {0};
		GetMD5String(temp.c_str(), cFileName);

		// 生成类型
		char cType[32] = {0};
		snprintf(cType, sizeof(cType), "%d", type);

		// 生成文件全路径
		path = m_dirPath
				+ cFileName
				+ "_"
				+ "img"
				+ "_"
				+ cType;
	}
	return path;
}

// 获取视频图片文件路径（仅已存在）
string LSLCVideoManager::GetVideoPhotoPathWithExist(const string& userId
						, const string& videoId
						, const string& inviteId
						, VIDEO_PHOTO_TYPE type)
{
	string filePath = "";
	string path = GetVideoPhotoPath(userId, videoId, inviteId, type);
	if (!path.empty())
	{
		if (IsFileExist(path))
		{
			filePath = path;
		}
	}
	return filePath;
}

// 获取视频图片临时文件路径
string LSLCVideoManager::GetVideoPhotoTempPath(const string& userId
											, const string& videoId
											, const string& inviteId
											, VIDEO_PHOTO_TYPE type)
{
	string tempPath = "";
	string path = GetVideoPhotoPath(userId, videoId, inviteId, type);
	if (!path.empty())
	{
		tempPath = path + "_temp";
	}
	return tempPath;
}

// 获取视频本地缓存文件路径(全路径)
string LSLCVideoManager::GetVideoPath(const string& userId, const string& videoId, const string& inviteId)
{
	string path = "";
	if (!userId.empty()
		&& !videoId.empty()
		&& !inviteId.empty())
	{
		// 生成文件名
		string temp = userId + videoId + inviteId;
		char cFileName[256] = {0};
		GetMD5String(temp.c_str(), cFileName);

		// 生成文件全路径
		path = m_dirPath + cFileName;
	}
	return path;
}

// 获取视频文件路径(仅已存在)
string LSLCVideoManager::GetVideoPathWithExist(const string& userId, const string& videoId, const string& inviteId)
{
	string filePath = "";
	string path = GetVideoPath(userId, videoId, inviteId);
	if (!path.empty())
	{
		if (IsFileExist(path))
		{
			filePath = path;
		}
	}
	return filePath;
}

// 获取视频临时文件路径
string LSLCVideoManager::GetVideoTempPath(const string& userId, const string& videoId, const string& inviteId)
{
	string tempPath = "";
	string path = GetVideoPath(userId, videoId, inviteId);
	if (!path.empty())
	{
		tempPath = path + "_temp";
	}
	return tempPath;
}

// 下载完成的临时文件转换成正式文件
bool LSLCVideoManager::TempFileToDesFile(const string& tempPath, const string& desPath)
{
	bool result = false;
	if (!tempPath.empty()
		&& !desPath.empty())
	{
		if (RenameFile(tempPath, desPath))
		{
			result = true;
		}
	}
	return result;
}

// 清除所有视频文件
void LSLCVideoManager::RemoveAllVideoFile()
{
	if (!m_dirPath.empty())
	{
		CleanDir(m_dirPath);
	}
}

// --------------------------- Video消息处理 -------------------------
// 根据videoId获取消息列表里的所有视频消息
LCMessageList LSLCVideoManager::GetMessageItem(const string& userId, const string& videoId)
{
	LCMessageList result;
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL != userItem)
	{
		userItem->LockMsgList();
		if (!userItem->m_msgList.empty())
		{
			for (LCMessageList::iterator iter = userItem->m_msgList.begin();
					iter != userItem->m_msgList.end();
					iter++)
			{
				LSLCMessageItem* item = (*iter);
				if (item->m_msgType == MT_Video
					&& NULL != item->GetVideoItem()
					&& item->GetVideoItem()->m_videoId == videoId)
				{
					result.push_back(item);
				}
			}
		}
		userItem->UnlockMsgList();
	}
	return result;
}

// 合并视频消息记录（把女士发出及男士已购买的视频记录合并为一条聊天记录）
void LSLCVideoManager::CombineMessageItem(LSLCUserItem* userItem)
{
	userItem->LockMsgList();
	if (!userItem->m_msgList.empty())
	{
		// 女士发送视频消息列表
		LCMessageList womanList;
		// 男士发送视频消息列表
		LCMessageList manList;
		// 找出所有男士和女士发出的视频消息
		for (LCMessageList::iterator iter = userItem->m_msgList.begin();
				iter != userItem->m_msgList.end();
				iter++)
		{
			LSLCMessageItem* item = (*iter);
			if (item->m_msgType == MT_Video
				&& NULL != item->GetVideoItem()
				&& !item->GetVideoItem()->m_videoId.empty())
			{
				if (item->m_sendType == SendType_Recv) {
					womanList.push_back(item);
				}
				else if (item->m_sendType == SendType_Send) {
					manList.push_back(item);
				}
			}
		}

		// 合并男士购买的视频消息
		if (!manList.empty() && !womanList.empty())
		{
			for (LCMessageList::iterator manIter = manList.begin();
					manIter != manList.end();
					manIter++)
			{
				for (LCMessageList::iterator womanIter = womanList.begin();
						womanIter != womanList.end();
						womanIter++)
				{
					LSLCMessageItem* manItem = (*manIter);
					LSLCMessageItem* womanItem = (*womanIter);
					lcmm::LSLCVideoItem* manVideoItem = manItem->GetVideoItem();
					lcmm::LSLCVideoItem* womanVideoItem = womanItem->GetVideoItem();
					if (manVideoItem->m_videoId == womanVideoItem->m_videoId
						&& manVideoItem->m_sendId == womanVideoItem->m_sendId)
					{
						// 男士发出的视频ID与女士发出的视频ID一致，需要合并
						userItem->m_msgList.remove(manItem);
						womanVideoItem->m_charge = true;
					}
				}
			}
		}
	}
	userItem->UnlockMsgList();
}

// --------------------------- 视频图片 -------------------------
// 开始下载视频图片
bool LSLCVideoManager::DownloadVideoPhoto(const string& userId, const string& sId, const string& womanId, const string& videoId, const string& inviteId, VIDEO_PHOTO_TYPE type)
{
	bool result = false;

	result = IsDownloadVideoPhoto(videoId);
	if (!result) 
	{
		LSLCVideoPhotoDownloader* downloader = new LSLCVideoPhotoDownloader;
		if (NULL != downloader)
		{
			string filePath = GetVideoPhotoPath(womanId, videoId, inviteId, type);
			result = downloader->Init(m_requestMgr, m_requestController, this);
			result = result && downloader->StartDownload(this, userId, sId, womanId, videoId, inviteId, type, filePath);
			if (result)
			{
				m_downloadVideoPhotoMap.lock();
				m_downloadVideoPhotoMap.insertItem(videoId, downloader);
				m_downloadVideoPhotoMap.unlock();
			}
			else {
				delete downloader;
			}
		}
	}

	return result;
}
	
// 判断视频图片是否正在下载
bool LSLCVideoManager::IsDownloadVideoPhoto(const string& videoId)
{
	bool result = false;

	LSLCVideoPhotoDownloader* downloader = NULL;

	m_downloadVideoPhotoMap.lock();
	result = m_downloadVideoPhotoMap.findWithKey(videoId, downloader);
	m_downloadVideoPhotoMap.unlock();

	return result;
}
	
// 停止下载视频图片
bool LSLCVideoManager::StopDownloadVideoPhoto(const string& videoId)
{
	bool result = false;

	LSLCVideoPhotoDownloader* downloader = NULL;
	m_downloadVideoPhotoMap.lock();
	if (m_downloadVideoPhotoMap.findWithKey(videoId, downloader))
	{
		result = downloader->Stop();
	}
	m_downloadVideoPhotoMap.unlock();

	return result;
}

// 清除超过一段时间已下载完成的视频图片下载器
void LSLCVideoManager::ClearFinishVideoPhotoDownloaderWithTimer()
{
	// 清除间隔时间（1秒）
	static const int stepSecond = 1 * 1000;

	m_finishVideoPhotoDownloaderList.lock();
	for (FinishVideoPhotoDownloaderList::iterator iter = m_finishVideoPhotoDownloaderList.begin();
		iter != m_finishVideoPhotoDownloaderList.end();
		iter = m_finishVideoPhotoDownloaderList.begin())
	{
		if (getCurrentTime() - (*iter).finishTime >= stepSecond)
		{
			// 超过限制时间
			delete (*iter).downloader;
			m_finishVideoPhotoDownloaderList.erase(iter);
			continue;
		}
		else {
			break;
		}
	}
	m_finishVideoPhotoDownloaderList.unlock();
}
	
// 停止并清除所有视频图片下载
void LSLCVideoManager::ClearAllDownloadVideoPhoto()
{
	// 获取正在下载的下载器列表
	DownloadVideoPhotoMap::ValueList downloaderList;
	m_downloadVideoPhotoMap.lock();
	downloaderList = m_downloadVideoPhotoMap.getValueList();
	m_downloadVideoPhotoMap.unlock();

	// 停止所有下载
	for (DownloadVideoPhotoMap::ValueList::iterator iter = downloaderList.begin();
		iter != downloaderList.end();
		iter++)
	{
		(*iter)->Stop();
	}

	// 清除已完成的下载器
	ClearAllFinishVideoPhotoDownloader();
}

// 清除所有已下载完成的视频图片下载器
void LSLCVideoManager::ClearAllFinishVideoPhotoDownloader()
{
	m_finishVideoPhotoDownloaderList.lock();
	for (FinishVideoPhotoDownloaderList::iterator iter = m_finishVideoPhotoDownloaderList.begin();
		iter != m_finishVideoPhotoDownloaderList.end();
		iter++)
	{
		delete (*iter).downloader;
	}
	m_finishVideoPhotoDownloaderList.clear();
	m_finishVideoPhotoDownloaderList.unlock();
}

// 接口请求回调
void LSLCVideoManager::OnGetVideoPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath)
{
	// 获取对应的下载器
	LSLCVideoPhotoDownloader* downloader = NULL;
	m_downloadVideoPhotoMap.lock();
	DownloadVideoPhotoMap::ValueList downloaderList;
	downloaderList = m_downloadVideoPhotoMap.getValueList();
	for (DownloadVideoPhotoMap::ValueList::iterator iter = downloaderList.begin();
		iter != downloaderList.end();
		iter++)
	{
		if ((*iter)->GetRequestId() == requestId)
		{
			downloader = (*iter);
			break;
		}
	}
	m_downloadVideoPhotoMap.unlock();

	// 回调到downloader
	if (NULL != downloader)
	{
		downloader->OnGetVideoPhoto(requestId, success, errnum, errmsg, filePath);
	}
}

// -- LSLCVideoPhotoDownloaderCallback --
void LSLCVideoManager::onFinish(LSLCVideoPhotoDownloader* downloader, bool success, const string& errnum, const string& errmsg)
{
	// 获取该视频对应的消息列表
	LCMessageList msgList = GetMessageItem(downloader->GetWomanId(), downloader->GetVideoId());

	// callback
	if (NULL != m_callback)
	{
		m_callback->OnDownloadVideoPhoto(
			success
			, errnum
			, errmsg
			, downloader->GetWomanId()
			, downloader->GetInviteId()
			, downloader->GetVideoId()
			, downloader->GetVideoPhotoType()
			, downloader->GetFilePath()
			, msgList);
	}

	// 插入到已完成列表
	FinishVideoPhotoDownloaderItem finishItem;
	finishItem.downloader = downloader;
	finishItem.finishTime = getCurrentTime();
	m_finishVideoPhotoDownloaderList.lock();
	m_finishVideoPhotoDownloaderList.push_back(finishItem);
	m_finishVideoPhotoDownloaderList.unlock();
}

// --------------------------- 视频 -------------------------
// 开始下载视频
bool LSLCVideoManager::DownloadVideo(const string& userId, const string& sid, const string& womanId, const string& videoId, const string& inviteId, const string& videoUrl)
{
	bool result = false;

	result = IsDownloadVideo(videoId);
	if (!result)
	{
		// 需要下载
		LSLCVideoDownloader* downloader = new LSLCVideoDownloader;
		if (NULL != downloader)
		{
			string filePath = GetVideoPath(womanId, videoId, inviteId);
			result = downloader->StartDownload(this, userId, sid, womanId, videoId, inviteId, videoUrl, filePath, m_httpUser, m_httpPassword);
			if (result)
			{
				m_downloadVideoMap.lock();
				m_downloadVideoMap.insertItem(videoId, downloader);
				m_downloadVideoMap.unlock();
			}
			else {
				delete downloader;
			}
		}
	}

	return result;
}
	
// 判断视频是否正在下载
bool LSLCVideoManager::IsDownloadVideo(const string& videoId)
{
	bool result = false;

	LSLCVideoDownloader* downloader = NULL;
	m_downloadVideoMap.lock();
	result = m_downloadVideoMap.findWithKey(videoId, downloader);
	m_downloadVideoMap.unlock();

	return result;
}
	
// 停止下载视频
bool LSLCVideoManager::StopDownloadVideo(const string& videoId)
{
	bool result = false;

	LSLCVideoDownloader* downloader = NULL;
	m_downloadVideoMap.lock();
	if (m_downloadVideoMap.findWithKey(videoId, downloader))
	{
		downloader->Stop();
		result = true;
	}
	m_downloadVideoMap.unlock();

	return result;
}

// 清除超过一段时间已下载完成的视频图片下载器
void LSLCVideoManager::ClearFinishVideoDownloaderWithTimer()
{
	// 清除间隔时间（1秒）
	static const int stepSecond = 1 * 1000;

	m_finishVideoDownloaderList.lock();
	for (FinishVideoDownloaderList::iterator iter = m_finishVideoDownloaderList.begin();
		iter != m_finishVideoDownloaderList.end();
		iter = m_finishVideoDownloaderList.begin())
	{
		if (getCurrentTime() - (*iter).finishTime >= stepSecond)
		{
			// 超过限制时间
			delete (*iter).downloader;
			m_finishVideoDownloaderList.erase(iter);
			continue;
		}
		else {
			break;
		}
	}
	m_finishVideoDownloaderList.unlock();
}
	
// 清除所有下载的视频
void LSLCVideoManager::ClearAllDownloadVideo()
{
	// 获取所有正在下载的视频下载器
	DownloadVideoMap::ValueList downloaderList;
	m_downloadVideoMap.lock();
	downloaderList = m_downloadVideoMap.getValueList();
	m_downloadVideoMap.unlock();

	// 停止所有下载器
	for (DownloadVideoMap::ValueList::iterator iter = downloaderList.begin();
		iter != downloaderList.end();
		iter++)
	{
		(*iter)->Stop();
	}

	// 清除所有已完成的下载器
	ClearAllFinishVideoDownloader();
}

// 清除所有已下载完成的视频下载器
void LSLCVideoManager::ClearAllFinishVideoDownloader()
{
	m_finishVideoDownloaderList.lock();
	for (FinishVideoDownloaderList::iterator iter = m_finishVideoDownloaderList.begin();
		iter != m_finishVideoDownloaderList.end();
		iter++)
	{
		delete (*iter).downloader;
	}
	m_finishVideoDownloaderList.clear();
	m_finishVideoDownloaderList.unlock();
}

// -- LSLCVideoDownloaderCallback --
void LSLCVideoManager::onFinish(LSLCVideoDownloader* downloader, bool success)
{
	// 获取该视频对应的消息列表
	LCMessageList msgList = GetMessageItem(downloader->GetWomanId(), downloader->GetVideoId());

	// callback
	if (NULL != m_callback)
	{
		m_callback->OnDownloadVideo(
			success
			, downloader->GetWomanId()
			, downloader->GetVideoId()
			, downloader->GetInviteId()
			, downloader->GetFilePath()
			, msgList);
	}

	// 插入到已完成列表
	FinishVideoDownloaderItem finishItem;
	finishItem.downloader = downloader;
	finishItem.finishTime = getCurrentTime();
	m_finishVideoDownloaderList.lock();
	m_finishVideoDownloaderList.push_back(finishItem);
	m_finishVideoDownloaderList.unlock();
}

// --------------------------- 付费 -------------------------
// 添加正在付费视频
bool LSLCVideoManager::AddPhotoFee(LSLCMessageItem* item, long requestId)
{
	bool result = false;

	m_videoFeeMap.lock();
	result = m_videoFeeMap.insertItem(item, requestId);
	m_videoFeeMap.unlock();

	return result;
}
	
// 判断视频是否正在付费
bool LSLCVideoManager::IsPhotoFee(LSLCMessageItem* item)
{
	bool result = false;

	long requestId = HTTPREQUEST_INVALIDREQUESTID;
	m_videoFeeMap.lock();
	result = m_videoFeeMap.findWithKey(item, requestId);
	m_videoFeeMap.unlock();

	return result;
}
	
// 移除正在付费视频
LSLCMessageItem* LSLCVideoManager::RemovePhotoFee(long requestId)
{
	LSLCMessageItem* item = NULL;

	m_videoFeeMap.lock();
	m_videoFeeMap.findWithValue(requestId, item);
	m_videoFeeMap.unlock();

	return item;
}
	
// 清除所有正在付费的视频
void LSLCVideoManager::ClearAllPhotoFee()
{
	// 获取请求列表
	VideoFeeMap::ValueList requestIdList;
	m_videoFeeMap.lock();
	requestIdList = m_videoFeeMap.getValueList();
	m_videoFeeMap.clear();
	m_videoFeeMap.unlock();

	// 停止请求
	for (VideoFeeMap::ValueList::iterator iter = requestIdList.begin();
		iter != requestIdList.end();
		iter++)
	{
		m_requestMgr->StopRequest((*iter));
	}
}
