/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCVideoItem.h
 *   desc: LiveChat视频消息item
 */

#include "LSLCVideoItem.h"
#include <common/CommonFunc.h>
#include <manrequesthandler/LSLiveChatRequestLiveChatDefine.h>
#include <common/CheckMemoryLeak.h>

using namespace lcmm;

LSLCVideoItem::LSLCVideoItem()
{
	m_videoId = "";
	m_videoDesc = "";
	m_sendId = "";
	m_videoUrl = "";
	m_charge = false;
    m_thumbPhotoFilePath = "";
    m_bigPhotoFilePath = "";
    m_videoFilePath = "";
}

LSLCVideoItem::LSLCVideoItem(LSLCVideoItem* videoItem) {
    if (NULL != videoItem) {
        m_videoId = videoItem->m_videoId;
        m_videoDesc = videoItem->m_videoDesc;
        m_sendId = videoItem->m_sendId;
        m_videoUrl = videoItem->m_videoUrl;
        m_charge = videoItem->m_charge;
        
        //m_statusList里面有指针，直接赋值没有深拷贝
        for (ProcessStatusList::const_iterator itr = videoItem->GetStatusList().begin(); itr != videoItem->GetStatusList().end(); itr++) {
            ProcessStatus status = (*itr);
            if (!m_statusList.has(status)) {
                m_statusList.push_back(status);
            }
        }
        //m_statusList = videoItem->GetStatusList();
        
        m_thumbPhotoFilePath = videoItem->m_thumbPhotoFilePath;
        m_bigPhotoFilePath = videoItem->m_bigPhotoFilePath;
        m_videoFilePath = videoItem->m_videoFilePath;
    }
}


LSLCVideoItem::~LSLCVideoItem()
{

}

// 初始化
bool LSLCVideoItem::Init(
		const string& videoId
		, const string& sendId
		, const string& videoDesc
		, const string& videoUrl
		, bool charge
        , const string& thumbPhotoFilePath
        , const string& bigPhotoFilePath
        , const string& videoFilePath)
{
	bool result = false;

	if (!videoId.empty())
	{
		m_videoId = videoId;
		m_sendId = sendId;
		m_videoDesc = videoDesc;
		m_charge = charge;
		m_videoUrl = videoUrl;
        if (IsFileExist(thumbPhotoFilePath)) {
            m_thumbPhotoFilePath = thumbPhotoFilePath;
        }
        if (IsFileExist(bigPhotoFilePath)) {
            m_bigPhotoFilePath = bigPhotoFilePath;
        }
        if (IsFileExist(videoFilePath)) {
            m_videoFilePath = videoFilePath;
        }

		result = true;
	}

	return result;
}

// 添加视频付费状态
void LSLCVideoItem::AddProcessStatusFee()
{
	m_statusList.lock();
	if (!m_statusList.has(VideoFee)) {
		m_statusList.push_back(VideoFee);
	}
	m_statusList.unlock();
}

// 删除视频付费状态
void LSLCVideoItem::RemoveProcessStatusFee()
{
	m_statusList.lock();
	if (m_statusList.has(VideoFee)) {
		m_statusList.erase(VideoFee);
	}
	m_statusList.unlock();
}
	
// 判断视频是否付费状态
bool LSLCVideoItem::IsFee()
{
	bool result = false;
	m_statusList.lock();
	result = m_statusList.has(VideoFee);
	m_statusList.unlock();
	return result;
}

// 获取处理状态列表
lcmm::LSLCVideoItem::ProcessStatusList& LSLCVideoItem::GetStatusList() {
    return m_statusList;
}
