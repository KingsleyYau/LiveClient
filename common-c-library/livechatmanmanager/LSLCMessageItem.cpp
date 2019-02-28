/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCMessageItem.cpp
 *   desc: LiveChat消息item
 */

#include "LSLCMessageItem.h"
#include "LSLCEmotionManager.h"
#include "LSLCVoiceManager.h"
#include "LSLCPhotoManager.h"
#include "LSLCVideoManager.h"
#include "LSLCMagicIconManager.h"
#include "LSLCUserItem.h"
#include <common/CommonFunc.h>
#include <manrequesthandler/item/LSLCRecord.h>
#include <common/KLog.h>
#include <common/CheckMemoryLeak.h>

using namespace lcmm;


long LSLCMessageItem::m_dbTime = 0;

LSLCMessageItem::LSLCMessageItem()
{
	m_msgId = 0;
	m_sendType = SendType_Unknow;
	m_fromId = "";
	m_toId = "";
	m_inviteId = "";
	m_createTime = 0;
	m_statusType = StatusType_Unprocess;
	m_msgType = MT_Unknow;
    m_inviteType = INVITE_TYPE_CHAT;
    
	m_textItem = NULL;
	m_warningItem = NULL;
	m_emotionItem = NULL;
	m_voiceItem = NULL;
	m_photoItem = NULL;
	m_videoItem = NULL;
	m_systemItem = NULL;
	m_customItem = NULL;
    m_magicIconItem = NULL;
    m_autoInviteItem = NULL;

	m_userItem = NULL;
    
    
}

LSLCMessageItem::~LSLCMessageItem()
{
	Clear();
}

// 初始化
bool LSLCMessageItem::Init(
		int msgId
		, SendType sendType
		, const string& fromId
		, const string& toId
		, const string& inviteId
		, StatusType statusType)
{
	bool result = false;
	if (!fromId.empty()
		&& !toId.empty()
		&& sendType != SendType_Unknow)
	{
		m_msgId = msgId;
		m_sendType = sendType;
		m_fromId = fromId;
		m_toId = toId;
		m_inviteId = inviteId;
		m_statusType = statusType;
		m_procResult.SetSuccess();
        m_inviteType = INVITE_TYPE_CHAT;
        
		m_createTime = GetCreateTime();
		result = true;
	}
	return result;
}

// 获取生成时间
long LSLCMessageItem::GetCreateTime()
{
	return (long)(getCurrentTime() / 1000);
}

// 更新生成时间
void LSLCMessageItem::RenewCreateTime()
{
	m_createTime = GetCreateTime();
}

// 设置服务器当前数据库时间
void LSLCMessageItem::SetDbTime(long dbTime)
{
	m_dbTime = dbTime;
}

// 把服务器时间转换为手机时间
long LSLCMessageItem::GetLocalTimeWithServerTime(long serverTime)
{
	long synServerTime = 0;
	if(m_dbTime > 0){
		/*同步服务器时间成功*/
		long diffTime = GetCreateTime() - m_dbTime;
		synServerTime = serverTime + diffTime;
	}else {
		/*同步服务器时间失败，使用默认时间*/
		synServerTime = serverTime;
	}
	return synServerTime;
}

// 使用Record初始化MessageItem
bool LSLCMessageItem::InitWithRecord(
				int msgId
				, const string& selfId
				, const string& userId
				, const string& inviteId
				, const LSLCRecord& record
				, LSLCEmotionManager* emotionMgr
				, LSLCVoiceManager* voiceMgr
				, LSLCPhotoManager* photoMgr
				, LSLCVideoManager* videoMgr
                , LSLCMagicIconManager* magicIconMgr)
{
	bool result = false;
	m_msgId = msgId;
	m_toId = (record.toflag == LRT_RECV ? selfId : userId);
	m_fromId = (record.toflag == LRT_RECV ? userId : selfId);
	m_inviteId = inviteId;
	m_sendType = (record.toflag == LRT_RECV ? SendType_Recv : SendType_Send);
	m_statusType = StatusType_Finish;
	m_createTime = GetLocalTimeWithServerTime(record.adddate);

	switch(record.messageType) {
	case LRM_TEXT: {
		if (!record.textMsg.empty())
		{
			LSLCTextItem* textItem = new LSLCTextItem;
			textItem->Init(record.textMsg, record.toflag != LRT_RECV);
			SetTextItem(textItem);
			result = true;
		}
	}break;
	case LRM_INVITE: {
		if (!record.inviteMsg.empty())
		{
			LSLCTextItem* textItem = new LSLCTextItem;
			textItem->Init(record.inviteMsg, record.toflag != LRT_RECV);
			SetTextItem(textItem);
			result = true;
		}
	}break;
	case LRM_WARNING: {
		if (!record.warningMsg.empty())
		{
			LSLCWarningItem* warningItem = new LSLCWarningItem;
			warningItem->Init(record.warningMsg);
			SetWarningItem(warningItem);
			result = true;
		}
	}break;
	case LRM_EMOTION: {
		if (!record.emotionId.empty())
		{
			LSLCEmotionItem* emotionItem = emotionMgr->GetEmotion(record.emotionId);
			SetEmotionItem(emotionItem);
			result = true;
		}
	}break;
	case LRM_PHOTO: {
		if (!record.photoId.empty())
		{
			// 男士端发送的为已付费
			bool photoCharge = (m_sendType == SendType_Send ? true : record.photoCharge);
            // 获取PhotoItem
            LSLCPhotoItem* photoItem = photoMgr->GetPhotoItem(record.photoId, this);
			photoItem->Init(
					record.photoId
					, record.photoSendId
					, record.photoDesc
					, photoMgr->GetPhotoPath(record.photoId, GMT_FUZZY, GPT_LARGE)
					, photoMgr->GetPhotoPath(record.photoId, GMT_FUZZY, GPT_MIDDLE)
					, photoMgr->GetPhotoPath(record.photoId, GMT_CLEAR, GPT_ORIGINAL)
					, photoMgr->GetPhotoPath(record.photoId, GMT_CLEAR, GPT_LARGE)
					, photoMgr->GetPhotoPath(record.photoId, GMT_CLEAR, GPT_MIDDLE)
					, photoCharge);
            
            
			result = true;
		}
	}break;
	case LRM_VOICE: {
		if (!record.voiceId.empty())
		{
			LSLCVoiceItem* voiceItem = new LSLCVoiceItem();
			voiceItem->Init(record.voiceId
					, voiceMgr->GetVoicePath(record.voiceId, record.voiceType)
					, record.voiceTime
					, record.voiceType
					, ""
					, true);
			SetVoiceItem(voiceItem);
			result = true;
		}
	}break;
	case LRM_VIDEO: {
		if (!record.videoId.empty())
		{
			lcmm::LSLCVideoItem* videoItem = new lcmm::LSLCVideoItem;
			videoItem->Init(
					record.videoId
					, record.videoSendId
					, record.videoDesc
					, ""
					, record.videoCharge);
			SetVideoItem(videoItem);
			result = true;
		}
	}break;
        case LRM_MAGIC_ICON: {
            if (!record.magicIconId.empty()) {
                LSLCMagicIconItem* magicIconItem = magicIconMgr->GetMagicIcon(record.magicIconId);
                SetMagicIconItem(magicIconItem);
                result = true;
            }
        }
	default: {
		FileLog("LiveChatManager", "LSLCMessageItem::InitWithRecord() unknow message type");
	}break;
	}
	return result;
}

// 设置语音item
void LSLCMessageItem::SetVoiceItem(LSLCVoiceItem* theVoiceItem)
{
	if (m_msgType == MT_Unknow
			&& theVoiceItem != NULL)
	{
		m_voiceItem = theVoiceItem;
		m_msgType = MT_Voice;
	}
}

// 获取语音item
LSLCVoiceItem* LSLCMessageItem::GetVoiceItem() const
{
	return m_voiceItem;
}

// 设置图片item
void LSLCMessageItem::SetPhotoItem(LSLCPhotoItem* thePhotoItem)
{
	if ((m_msgType == MT_Unknow || m_msgType == MT_Photo)
			&& thePhotoItem != NULL)
	{
		m_photoItem = thePhotoItem;
		m_msgType = MT_Photo;
	}
}

// 获取图片item
LSLCPhotoItem* LSLCMessageItem::GetPhotoItem() const
{
	return m_photoItem;
}

// 设置视频item
void LSLCMessageItem::SetVideoItem(lcmm::LSLCVideoItem* theVideoItem)
{
	if (m_msgType == MT_Unknow
			&& theVideoItem != NULL)
	{
		m_videoItem = theVideoItem;
		m_msgType = MT_Video;
	}
}

// 获取视频item
lcmm::LSLCVideoItem* LSLCMessageItem::GetVideoItem() const
{
	return m_videoItem;
}

// 设置文本item
void LSLCMessageItem::SetTextItem(LSLCTextItem* theTextItem)
{
	if (m_msgType == MT_Unknow
			&& theTextItem != NULL)
	{
		m_textItem = theTextItem;
		m_msgType = MT_Text;
	}
}

// 获取文本item
LSLCTextItem* LSLCMessageItem::GetTextItem() const
{
	return m_textItem;
}

// 设置warning item
void LSLCMessageItem::SetWarningItem(LSLCWarningItem* theWarningItem)
{
	if (m_msgType == MT_Unknow
			&& theWarningItem != NULL)
	{
		m_warningItem = theWarningItem;
		m_msgType = MT_Warning;
	}
}

// 获取warning item
LSLCWarningItem* LSLCMessageItem::GetWarningItem() const
{
	return m_warningItem;
}

// 设置高级表情item
void LSLCMessageItem::SetEmotionItem(LSLCEmotionItem* theEmotionItem)
{
	if (m_msgType == MT_Unknow
			&& theEmotionItem != NULL)
	{
		m_emotionItem = theEmotionItem;
		m_msgType = MT_Emotion;
	}
}

// 获取高级表情item
LSLCEmotionItem* LSLCMessageItem::GetEmotionItem() const
{
	return m_emotionItem;
}

// 设置系统消息item
void LSLCMessageItem::SetSystemItem(LSLCSystemItem* theSystemItem)
{
	if (m_msgType == MT_Unknow
			&& theSystemItem != NULL)
	{
		m_systemItem = theSystemItem;
		m_msgType = MT_System;
	}
}

// 获取系统消息item
LSLCSystemItem* LSLCMessageItem::GetSystemItem() const
{
	return m_systemItem;
}

// 设置自定义消息item
void LSLCMessageItem::SetCustomItem(LSLCCustomItem* theCustomItem)
{
	if (m_msgType == MT_Unknow
			&& theCustomItem != NULL)
	{
		m_customItem = theCustomItem;
		m_msgType = MT_Custom;
	}
}

// 获取自定义消息item
LSLCCustomItem* LSLCMessageItem::GetCustomItem() const
{
	return m_customItem;	
}

// 判断子消息item（如：语音、图片、视频等）是否正在处理
bool LSLCMessageItem::IsSubItemProcssign() const
{
	bool result = false;
	switch (m_msgType)
	{
		case MT_Voice:
			{
				LSLCVoiceItem* voiceItem = GetVoiceItem();
				result = voiceItem->m_processing;
			}
			break;
		case MT_Photo:
			{
				LSLCPhotoItem* photoItem = GetPhotoItem();
				result = photoItem->IsProcessing();
			}
			break;
		case MT_Video:
			{
				lcmm::LSLCVideoItem* videoItem = GetVideoItem();
				result = videoItem->IsFee();
			}
			break;
        default:
            break;
	}
	return result;
}

// 设置小高级表情item
void LSLCMessageItem::SetMagicIconItem(LSLCMagicIconItem* theMagicIConItem)
{

    if (m_msgType == MT_Unknow
        && theMagicIConItem != NULL)
    {
        m_magicIconItem = theMagicIConItem;
        m_msgType = MT_MagicIcon;
    }
}

// 获取小高级表情item
LSLCMagicIconItem* LSLCMessageItem::GetMagicIconItem() const
{
    return m_magicIconItem;
}

//  设置自动邀请item alex 2019－01-28
void LSLCMessageItem::SetAutoInviteItem(LSLCAutoInviteItem* theAutoInviteItem)
{
    if (NULL != theAutoInviteItem && m_autoInviteItem == NULL) {
        m_autoInviteItem = theAutoInviteItem;
    }
}
//  获取自动邀请item alex 2019－01-28
LSLCAutoInviteItem* LSLCMessageItem::GetAutoInviteItem() const
{
    return m_autoInviteItem;
}

// 设置用户item
void LSLCMessageItem::SetUserItem(LSLCUserItem* theUserItem)
{
	m_userItem = theUserItem;
}

// 获取用户item
LSLCUserItem* LSLCMessageItem::GetUserItem() const
{
	return m_userItem;
}

// 重置所有成员变量
void LSLCMessageItem::Clear()
{
	m_msgId = 0;
	m_sendType = SendType_Unknow;
	m_fromId = "";
	m_toId = "";
	m_inviteId = "";
	m_createTime = 0;
	m_statusType = StatusType_Unprocess;
	m_msgType = MT_Unknow;

	delete m_textItem;
	m_textItem = NULL;

	delete m_warningItem;
	m_warningItem = NULL;

	// release in LSLCEmotionManager
//	delete m_emotionItem;
	m_emotionItem = NULL;

	delete m_voiceItem;
	m_voiceItem = NULL;

    // release in LSLCPhotoManager
//	delete m_photoItem;
	m_photoItem = NULL;

	delete m_videoItem;
	m_videoItem = NULL;

	delete m_systemItem;
	m_systemItem = NULL;

	delete m_customItem;
	m_customItem = NULL;
    
    m_magicIconItem = NULL;
    
    if (m_autoInviteItem != NULL) {
        delete m_autoInviteItem;
        m_autoInviteItem = NULL;
    }

	m_userItem = NULL;
}

bool LSLCMessageItem::Sort(const LSLCMessageItem* item1, const LSLCMessageItem* item2)
{
	// true排前面，false排后面
	bool result = false;

	if (item1->m_createTime == item2->m_createTime)
	{
		result = item1->m_msgId < item2->m_msgId;
	}
	else
	{
		result = item1->m_createTime < item2->m_createTime;
	}

	return result;
}

// 判断是否聊天消息
bool LSLCMessageItem::IsChatMessage()
{
    bool result = false;
    switch (m_msgType) {
        case MT_Text:
        case MT_Photo:
        case MT_Video:
        case MT_Voice:
        case MT_Emotion:
        case MT_MagicIcon:
            result = true;
            break;
            
        default:
            break;
    }
    return result;
}

// 初始化深拷贝messageItem
void LSLCMessageItem::InitWithMessageItem(const LSLCMessageItem* messageItem) {
    if (NULL != messageItem) {
        m_msgId = messageItem->m_msgId;
        m_sendType = messageItem->m_sendType;
        m_fromId = messageItem->m_fromId;
        m_toId = messageItem->m_toId;
        m_inviteId = messageItem->m_inviteId;
        m_createTime = messageItem->m_createTime;
        m_statusType = messageItem->m_statusType;
        //m_msgType = messageItem->m_msgType;
        m_procResult = messageItem->m_procResult;
        m_inviteType = messageItem->m_inviteType;
        
        switch(messageItem->m_msgType) {
            case MT_Text:{
                if (messageItem->GetTextItem())
                {
                    LSLCTextItem* textItem = new LSLCTextItem(messageItem->GetTextItem());
                    SetTextItem(textItem);
                }
            }break;
            case MT_Warning: {
                if (messageItem->GetWarningItem())
                {
                    LSLCWarningItem* warningItem = new LSLCWarningItem(messageItem->GetWarningItem());
                    SetWarningItem(warningItem);
                }
            }break;
            case MT_Emotion: {
                if (messageItem->GetEmotionItem())
                {
                    LSLCEmotionItem* emotionItem = new LSLCEmotionItem(messageItem->GetEmotionItem());
                    SetEmotionItem(emotionItem);
                }
            }break;
            case MT_Photo: {
                if (messageItem->GetPhotoItem())
                {
                    // 获取PhotoItem
                    LSLCPhotoItem* photoItem = new LSLCPhotoItem(messageItem->GetPhotoItem());
                    SetPhotoItem(photoItem);
                }
            }break;
            case MT_Voice: {
                if (messageItem->GetVoiceItem())
                {
                    LSLCVoiceItem* voiceItem = new LSLCVoiceItem(messageItem->GetVoiceItem());
                    SetVoiceItem(voiceItem);
                }
            }break;
            case MT_Video: {
                if (messageItem->GetVideoItem())
                {
                    lcmm::LSLCVideoItem* videoItem = new lcmm::LSLCVideoItem(messageItem->GetVideoItem());
                    SetVideoItem(videoItem);
                }
            }break;
            case MT_MagicIcon: {
                if (messageItem->GetMagicIconItem()) {
                    LSLCMagicIconItem* magicIconItem = new LSLCMagicIconItem(messageItem->GetMagicIconItem());
                    SetMagicIconItem(magicIconItem);
                }
            }
            default: {
                FileLog("LiveChatManager", "LCMessageItem::InitWithRecord() unknow message type");
            }break;
        }
        
    }
}

