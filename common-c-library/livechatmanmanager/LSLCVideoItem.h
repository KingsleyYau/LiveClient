/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCVideoItem.h
 *   desc: LiveChat视频消息item
 */

#pragma once

#include <manrequesthandler/LSLiveChatRequestLiveChatDefine.h>
#include <string>
#include <common/list_lock.h>
using namespace std;

namespace lcmm
{

class LSLCVideoItem
{
public:
	// 视频处理状态
	typedef enum {
		Unknow,						// 未知状态
		VideoFee,					// 正在付费
	} ProcessStatus;
	typedef list_lock<ProcessStatus> ProcessStatusList;

public:
	LSLCVideoItem();
    LSLCVideoItem(LSLCVideoItem* videoItem);
	virtual ~LSLCVideoItem();

public:
	// 初始化
	bool Init(
		const string& videoId
		, const string& sendId
		, const string& videoDesc
		, const string& videoUrl
		, bool charge);

	// 添加/删除视频付费状态
	void AddProcessStatusFee();
	void RemoveProcessStatusFee();
	// 判断视频是否付费状态
	bool IsFee();
    // 获取处理状态列表
    ProcessStatusList GetStatusList();

public:
	string	m_videoId;				// 视频ID
	string	m_sendId;				// 发送ID
	string	m_videoDesc;			// 视频描述
	string	m_videoUrl;				// 视频URL
	bool	m_charge;				// 是否已付费
private:
	ProcessStatusList m_statusList;	// 处理状态列表
};

}
