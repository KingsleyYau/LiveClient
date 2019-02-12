/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCVoiceItem.h
 *   desc: LiveChat语音消息item
 */

#include "LSLCVoiceItem.h"
#include <common/CommonFunc.h>
#include <manrequesthandler/LSLiveChatRequestLiveChatDefine.h>
#include <common/CheckMemoryLeak.h>

LSLCVoiceItem::LSLCVoiceItem()
{
	m_voiceId = "";
	m_filePath = "";
	m_timeLength = 0;
	m_fileType = "";
	m_checkCode = "";
	m_charge = false;
	m_processing = false;
}

LSLCVoiceItem::LSLCVoiceItem(LSLCVoiceItem* voiceItem) {
    if (NULL != voiceItem) {
        m_voiceId = voiceItem->m_voiceId;
        m_filePath = voiceItem->m_filePath;
        m_timeLength = voiceItem->m_timeLength;
        m_fileType = voiceItem->m_fileType;
        m_checkCode = voiceItem->m_checkCode;
        m_charge = voiceItem->m_charge;
        m_processing = voiceItem->m_processing;
    }
}

LSLCVoiceItem::~LSLCVoiceItem()
{

}

// 初始化
bool LSLCVoiceItem::Init(
					const string& voiceId
					, const string& filePath
					, int timeLength
					, const string& fileType
					, const string& checkCode
					, bool charge)
{
	m_voiceId = voiceId;
	m_timeLength = timeLength;
	m_fileType = fileType;
	m_checkCode = checkCode;
	m_charge = charge;
	m_processing = false;

	if ( IsFileExist(filePath) )
	{
		m_filePath = filePath;
	}

	return true;
}

