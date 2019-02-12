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
}

LSLCVideoItem::LSLCVideoItem(LSLCVideoItem* videoItem) {
    if (NULL != videoItem) {
        m_videoId = videoItem->m_videoId;
        m_videoDesc = videoItem->m_videoDesc;
        m_sendId = videoItem->m_sendId;
        m_videoUrl = videoItem->m_videoUrl;
        m_charge = videoItem->m_charge;
        m_statusList = videoItem->GetStatusList();
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
		, bool charge)
{
	bool result = false;

	if (!videoId.empty())
	{
		m_videoId = videoId;
		m_sendId = sendId;
		m_videoDesc = videoDesc;
		m_charge = charge;
		m_videoUrl = videoUrl;

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
	if (!m_statusList.has(VideoFee)) {
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
lcmm::LSLCVideoItem::ProcessStatusList LSLCVideoItem::GetStatusList() {
    return m_statusList;
}
