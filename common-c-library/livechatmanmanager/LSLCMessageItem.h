/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LSLCMessageItem.h
 *   desc: LiveChat消息item
 */

#pragma once

#include "LSLCTextItem.h"
#include "LSLCWarningItem.h"
#include "LSLCEmotionItem.h"
#include "LSLCVoiceItem.h"
#include "LSLCPhotoItem.h"
#include "LSLCVideoItem.h"
#include "LSLCSystemItem.h"
#include "LSLCCustomItem.h"
#include "LSLCMagicIconItem.h"
#include <livechat/ILSLiveChatClient.h>
#include "ILSLiveChatManManagerEnumDef.h"
#include <string>
#include <list>
using namespace std;

class LSLCEmotionManager;
class LSLCVoiceManager;
class LSLCPhotoManager;
class LSLCVideoManager;
class LSLCMagicIconManager;
class LSLCUserItem;
class LSLCRecord;
class LSLCMessageItem
{
public:

	// 处理（发送/接收/购买）结果
	class ProcResult 
	{
	public:
		ProcResult() {
			SetSuccess();
		}
		virtual ~ProcResult() {}
	public:
		void SetSuccess() {
			m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
			m_errNum = "";
			m_errMsg = "";
		}
		void SetResult(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errNum, const string& errMsg) {
			m_errType = errType;
			m_errNum = errNum;
			m_errMsg = errMsg;
		}
	public:
		LSLIVECHAT_LCC_ERR_TYPE	m_errType;	// 处理结果类型
		string	m_errNum;			// 处理结果代码
		string	m_errMsg;			// 处理结果描述
	};

public:
	LSLCMessageItem();
	virtual ~LSLCMessageItem();

public:
	// 初始化
	bool Init(
			int msgId
			, SendType sendType
			, const string& fromId
			, const string& toId
			, const string& inviteId
			, StatusType statusType);
	// 获取生成时间
	static long GetCreateTime();
	// 更新生成时间
	void RenewCreateTime();
	// 设置服务器当前数据库时间
	static void SetDbTime(long dbTime);
	// 把服务器时间转换为手机时间
	static long GetLocalTimeWithServerTime(long serverTime);
	// 使用Record初始化MessageItem
	bool InitWithRecord(
					int msgId
					, const string& selfId
					, const string& userId
					, const string& inviteId
					, const LSLCRecord& record
					, LSLCEmotionManager* emotionMgr
					, LSLCVoiceManager* voiceMgr
					, LSLCPhotoManager* photoMgr
					, LSLCVideoManager* videoMgr
                    , LSLCMagicIconManager* magicIconMgr);
	// 设置语音item
	void SetVoiceItem(LSLCVoiceItem* theVoiceItem);
	// 获取语音item
	LSLCVoiceItem* GetVoiceItem() const;
	// 设置图片item
	void SetPhotoItem(LSLCPhotoItem* thePhotoItem);
	// 获取图片item
	LSLCPhotoItem* GetPhotoItem() const;
	// 设置视频item
	void SetVideoItem(lcmm::LSLCVideoItem* theVideoItem);
	// 获取视频item
	lcmm::LSLCVideoItem* GetVideoItem() const;
	// 设置文本item
	void SetTextItem(LSLCTextItem* theTextItem);
	// 获取文本item
	LSLCTextItem* GetTextItem() const;
	// 设置warning item
	void SetWarningItem(LSLCWarningItem* theWarningItem);
	// 获取warning item
	LSLCWarningItem* GetWarningItem() const;
	// 设置高级表情item
	void SetEmotionItem(LSLCEmotionItem* theEmotionItem);
	// 获取高级表情item
	LSLCEmotionItem* GetEmotionItem() const;
	// 设置系统消息item
	void SetSystemItem(LSLCSystemItem* theSystemItem);
	// 获取系统消息item
	LSLCSystemItem* GetSystemItem() const;
	// 设置自定义消息item
	void SetCustomItem(LSLCCustomItem* theCustomItem);
	// 获取自定义消息item
	LSLCCustomItem* GetCustomItem() const;
	// 判断子消息item（如：语音、图片、视频等）是否正在处理
	bool IsSubItemProcssign() const;
    //  设置小高级表情item alex 2016－09-12
    void SetMagicIconItem(LSLCMagicIconItem* theMagicIconItem);
    //  设置小高级表情item alex 2016-09-12
    LSLCMagicIconItem* GetMagicIconItem() const;
	// 设置用户item
	void SetUserItem(LSLCUserItem* theUserItem);
	// 获取用户item
	LSLCUserItem* GetUserItem() const;
	// 重置所有成员变量
	void Clear();

	// 排序函数
	static bool Sort(const LSLCMessageItem* item1, const LSLCMessageItem* item2);
    
    // 判断是否聊天消息
    bool IsChatMessage();
    
    // 初始化深拷贝messageItem
    void InitWithMessageItem(const LSLCMessageItem* messageItem);

public:
	int 			m_msgId;		// 消息ID
	SendType 		m_sendType;		// 消息发送方向
	string			m_fromId;		// 发送者ID
	string 			m_toId;			// 接收者ID
	string 			m_inviteId;		// 邀请ID
	long			m_createTime;	// 接收/发送时间
	StatusType 		m_statusType;	// 处理状态
	MessageType		m_msgType;		// 消息类型
	ProcResult		m_procResult;	// 处理(发送/接收/购买)结果
    INVITE_TYPE     m_inviteType;   // 会话类型
    
private:
	LSLCTextItem*		m_textItem;		// 文本item
	LSLCWarningItem*	m_warningItem;	// 警告item
	LSLCEmotionItem*	m_emotionItem;	// 高级表情ID
	LSLCVoiceItem*	m_voiceItem;	// 语音item
	LSLCPhotoItem*	m_photoItem;	// 图片item
	lcmm::LSLCVideoItem*	m_videoItem;	// 微视频item
	LSLCSystemItem*	  m_systemItem;	// 系统消息item
	LSLCCustomItem*	  m_customItem;	// 自定义消息item
    LSLCMagicIconItem*  m_magicIconItem;  // 小高级表情Item

	LSLCUserItem*		m_userItem;		// 用户item

	static long		m_dbTime;		// 服务器数据库当前时间
    
};
typedef list<LSLCMessageItem*>	LCMessageList;

