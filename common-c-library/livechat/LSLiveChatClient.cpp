/*
 * author: Samson.Fan
 *   date: 2015-03-19
 *   file: LSLiveChatClient.cpp
 *   desc: LiveChat客户端实现类
 */

#include "LSLiveChatClient.h"
#include "LSLiveChatTaskManager.h"
#include <common/KLog.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

// task include
#include "LSLiveChatCheckVerTask.h"
#include "LSLiveChatLoginTask.h"
#include "LSLiveChatSetStatusTask.h"
#include "LSLiveChatUploadDeviceIdTask.h"
#include "LSLiveChatUploadDeviceTypeTask.h"
#include "LSLiveChatEndTalkTask.h"
#include "LSLiveChatGetUserStatusTask.h"
#include "LSLiveChatGetTalkInfoTask.h"
#include "LSLiveChatUploadTicketTask.h"
#include "LSLiveChatSendMsgTask.h"
#include "LSLiveChatSendEmotionTask.h"
#include "LSLiveChatSendVGiftTask.h"
#include "LSLiveChatGetVoiceCodeTask.h"
#include "LSLiveChatGetLadyVoiceCodeTask.h"
#include "LSLiveChatSendVoiceTask.h"
#include "LSLiveChatUseTryTicketTask.h"
#include "LSLiveChatGetTalkListTask.h"
#include "LSLiveChatSendPhotoTask.h"
#include "LSLiveChatSendLadyPhotoTask.h"
#include "LSLiveChatShowPhotoTask.h"
#include "LSLiveChatGetUserInfoTask.h"
#include "LSLiveChatGetUsersInfoTask.h"
#include "LSLiveChatGetContactListTask.h"
#include "LSLiveChatUploadVerTask.h"
#include "LSLiveChatGetBlockUsersTask.h"
#include "LSLiveChatGetRecentContactListTask.h"
#include "LSLiveChatSearchOnlineManTask.h"
#include "LSLiveChatReplyIdentifyCodeTask.h"
#include "LSLiveChatRefreshIdentifyCodeTask.h"
#include "LSLiveChatRefreshInviteTemplateTask.h"
#include "LSLiveChatGetFeeRecentContactListTask.h"
#include "LSLiveChatGetLadyChatInfoTask.h"
#include "LSLiveChatSendLadyEditingMsgTask.h"
#include "LSLiveChatPlayVideoTask.h"
#include "LSLiveChatSendLadyVideoTask.h"
#include "LSLiveChatGetLadyConditionTask.h"
#include "LSLiveChatGetLadyCustomTemplateTask.h"
#include "LSLiveChatUploadPopLadyAutoInviteTask.h"
#include "LSLiveChatUploadAutoChargeStatusTask.h"
#include "LSLiveChatSendMagicIconTask.h"
#include "LSLiveChatGetPaidThemeTask.h"
#include "LSLiveChatGetAllPaidThemeTask.h"
#include "LSLiveChatUploadThemeListVerTask.h"
#include "LSLiveChatManFeeThemeTask.h"
#include "LSLiveChatManApplyThemeTask.h"
#include "LSLiveChatPlayThemeMotionTask.h"
#include "LSLiveChatHearbeatTask.h"
#include "LSLiveChatSendAutoInviteTask.h"
#include "LSLiveChatGetAutoInviteStatusTask.h"
#include "LSLiveChatSendThemeRecommendTask.h"
#include "LSLiveChatGetLadyCamStatusTask.h"
#include "LSLiveChatSendCamShareInviteTask.h"
#include "LSLiveChatApplyCamShareTask.h"
#include "LSLiveChatLadyAcceptCamInviteTask.h"
#include "LSLiveChatCamShareHearbeatTask.h"
#include "LSLiveChatGetUsersCamStatusTask.h"
#include "LSLiveChatGetSessionInfoTask.h"
#include "LSLiveChatCamshareUseTryTicketTask.h"
#include "LSLiveChatSummitLadyCamStatusTask.h"
#include "LSLiveChatGetSessionInfoWithManTask.h"
#include "LSLiveChatSummitAutoInviteCamFirstTask.h"

CLSLiveChatClient::CLSLiveChatClient()
{
	m_taskManager = NULL;
//	this = NULL;
	m_bInit = false;
	m_isHearbeatThreadRun = false;
	m_hearbeatThread = NULL;
    
    m_listenerListLock = IAutoLock::CreateAutoLock();
    m_listenerListLock->Init();
}

CLSLiveChatClient::~CLSLiveChatClient()
{
	FileLog("LSLiveChatClient", "CLSLiveChatClient::~CLSLiveChatClient()");
	delete m_taskManager;
	m_taskManager = NULL;
    IAutoLock::ReleaseAutoLock(m_listenerListLock);
	FileLog("LSLiveChatClient", "CLSLiveChatClient::~CLSLiveChatClient() end");
}

// ------------------------ ILSLiveChatClient接口函数 -------------------------
// 调用所有接口函数前需要先调用Init
bool CLSLiveChatClient::Init(const list<string>& svrIPs, unsigned int svrPort)
{
	bool result = false;

	// 初始化 TaskManager
	if (NULL == m_taskManager) {
		m_taskManager = new CLSLiveChatTaskManager();
		if (NULL != m_taskManager) {
			result = m_taskManager->Init(svrIPs, svrPort, this, this);
		}

		// 初始化 seq计数器
		if (result) {
			result = m_seqCounter.Init();
		}

//		if (result) {
//			// 所有初始化都成功，开始赋值
//			this = listener;
//		}

		m_bInit = result;
	}

	return result;
}

// 增加监听器
void CLSLiveChatClient::AddListener(ILSLiveChatClientListener* listener) {
    m_listenerListLock->Lock();
    m_listenerList.push_back(listener);
    FileLog("LiveChatClient", "OnUploadPopLadyAutoInvite::Handle() callback:%p", listener);
    m_listenerListLock->Unlock();
}

// 移除监听器
void CLSLiveChatClient::RemoveListener(ILSLiveChatClientListener* listener) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        if( *itr == listener ) {
            m_listenerList.erase(itr);
            break;
        }
    }
    m_listenerListLock->Unlock();
}

// 判断是否无效seq
bool CLSLiveChatClient::IsInvalidSeq(int seq)
{
	return m_seqCounter.IsInvalidValue(seq);
}

// 连接服务器
bool CLSLiveChatClient::ConnectServer()
{
	bool result = false;

	FileLog("LSLiveChatClient", "CLSLiveChatClient::ConnectServer() begin");

	if (m_bInit) {
		if (NULL != m_taskManager) {
			if (m_taskManager->IsStart()) {
				m_taskManager->Stop();
			}
			result = m_taskManager->Start();
			FileLog("LSLiveChatClient", "CLSLiveChatClient::ConnectServer() result: %d", result);
		}
	}

	FileLog("LSLiveChatClient", "CLSLiveChatClient::ConnectServer() end");

	return result;
}

// 登录
bool CLSLiveChatClient::Login(const string& user, const string& password, const string& deviceId, CLIENT_TYPE clientType, USER_SEX_TYPE sexType, AUTH_TYPE authType)
{
	bool result = false;

	FileLog("LSLiveChatClient", "CLSLiveChatClient::Login() begin");

	if (!user.empty()
		&& !password.empty()
		&& !deviceId.empty()
		&& ConnectServer())
	{
		m_user = user;
		m_password = password;
		m_deviceId = deviceId;
		m_clientType = clientType;
		m_sexType = sexType;
		m_authType = authType;

		result = true;
	}

	FileLog("LSLiveChatClient", "CLSLiveChatClient::Login() end");

	return result;
}

// 注销
bool CLSLiveChatClient::Logout()
{
	bool result = false;

	FileLog("LSLiveChatClient", "CLSLiveChatClient::Logout() begin, m_taskManager:%p", m_taskManager);

	if (NULL != m_taskManager) {
		FileLog("LSLiveChatClient", "CLSLiveChatClient::Logout() m_taskManager->Stop(), m_taskManager:%p", m_taskManager);
		result = m_taskManager->Stop();

		if (result) {
			m_user = "";
			m_password = "";
		}
	}

	FileLog("LSLiveChatClient", "CLSLiveChatClient::Logout() end");

	return result;
}

// 设置在线状态
bool CLSLiveChatClient::SetStatus(USER_STATUS_TYPE status)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SetStatus() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSetStatusTask* task = new LSLiveChatSetStatusTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SetStatus() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(status);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SetStatus() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SetStatus() end");
	return result;
}

// 结束聊天
bool CLSLiveChatClient::EndTalk(const string& userId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::EndTalk() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatEndTalkTask* task = new LSLiveChatEndTalkTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::EndTalk() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::EndTalk() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::EndTalk() end");
	return result;
}

// 获取用户在线状态
bool CLSLiveChatClient::GetUserStatus(const UserIdList& list)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUserStatus() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetUserStatusTask* task = new LSLiveChatGetUserStatusTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUserStatus() task:%p", task);
		if (NULL != task) {
			// 转换成对方的性别
			USER_SEX_TYPE sexType = (m_sexType == USER_SEX_FEMALE ? USER_SEX_MALE : USER_SEX_FEMALE);

			result = task->Init(this);
			result = result && task->InitParam(sexType, list);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUserStatus() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUserStatus() end");
	return result;
}

// 获取会话信息
bool CLSLiveChatClient::GetTalkInfo(const string& userId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetTalkInfo() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetTalkInfoTask* task = new LSLiveChatGetTalkInfoTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetTalkInfo() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetTalkInfo() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetTalkInfo() end");
	return result;
}

// 获取会话信息(仅男士端使用CMD 55)
bool CLSLiveChatClient::GetSessionInfo(const string& userId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetSessionInfo() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetSessionInfoTask* task = new LSLiveChatGetSessionInfoTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetSessionInfo() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetSessionInfo() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetSessionInfo() end");
	return result;
}




// 上传票根
bool CLSLiveChatClient::UploadTicket(const string& userId, int ticket)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadTicket() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatUploadTicketTask* task = new LSLiveChatUploadTicketTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadTicket() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadTicket() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadTicket() end");
	return result;
}

// 通知对方女士正在编辑消息
bool CLSLiveChatClient::SendLadyEditingMsg(const string& userId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyEditingMsg() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSendLadyEditingMsgTask* task = new LSLiveChatSendLadyEditingMsgTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyEditingMsg() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyEditingMsg() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyEditingMsg() end");
	return result;
}

// 发送聊天消息
bool CLSLiveChatClient::SendTextMessage(const string& userId, const string& message, bool illegal, int ticket, INVITE_TYPE inviteType)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendMessage() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSendMsgTask* task = new LSLiveChatSendMsgTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendMessage() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, message, illegal, ticket, inviteType);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendMessage() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendMessage() end");
	return result;
}

// 发送高级表情
bool CLSLiveChatClient::SendEmotion(const string& userId, const string& emotionId, int ticket)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendEmotion() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSendEmotionTask* task = new LSLiveChatSendEmotionTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendEmotion() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, emotionId, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendEmotion() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendEmotion() end");
	return result;
}

// 发送虚拟礼物
bool CLSLiveChatClient::SendVGift(const string& userId, const string& giftId, int ticket)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendVGift() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSendVGiftTask* task = new LSLiveChatSendVGiftTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendVGift() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, giftId, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendVGift() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendVGift() end");
	return result;
}

// 获取语音发送验证码
bool CLSLiveChatClient::GetVoiceCode(const string& userId, int ticket)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetVoiceCode() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetVoiceCodeTask* task = new LSLiveChatGetVoiceCodeTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetVoiceCode() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetVoiceCode() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetVoiceCode() end");
	return result;
}

// 获取女士语音发送验证码
bool CLSLiveChatClient::GetLadyVoiceCode(const string& userId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyVoiceCode() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetLadyVoiceCodeTask* task = new LSLiveChatGetLadyVoiceCodeTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyVoiceCode() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyVoiceCode() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyVoiceCode() end");
	return result;
}

// 发送语音
bool CLSLiveChatClient::SendVoice(const string& userId, const string& voiceId, int length, int ticket)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendVoice() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSendVoiceTask* task = new LSLiveChatSendVoiceTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendVoice() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, voiceId, length, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendVoice() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendVoice() end");
	return result;
}

// 使用试聊券
bool CLSLiveChatClient::UseTryTicket(const string& userId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::UseTryTicket() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatUseTryTicketTask* task = new LSLiveChatUseTryTicketTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::UseTryTicket() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::UseTryTicket() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::UseTryTicket() end");
	return result;
}

// 获取邀请列表或在聊列表
bool CLSLiveChatClient::GetTalkList(int listType)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetTalkList() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetTalkListTask* task = new LSLiveChatGetTalkListTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetTalkList() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(listType);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetTalkList() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetTalkList() end");
	return result;
}

// 发送图片
bool CLSLiveChatClient::SendPhoto(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charget, const string& photoDesc, int ticket)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendPhoto() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSendPhotoTask* task = new LSLiveChatSendPhotoTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendPhoto() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, inviteId, photoId, sendId, charget, photoDesc, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendPhoto() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendPhoto() end");
	return result;
}

// 女士发送图片
bool CLSLiveChatClient::SendLadyPhoto(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charget, const string& photoDesc, int ticket)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyPhoto() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSendLadyPhotoTask* task = new LSLiveChatSendLadyPhotoTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyPhoto() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, inviteId, photoId, sendId, charget, photoDesc, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyPhoto() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyPhoto() end");
	return result;
}

// 显示图片
bool CLSLiveChatClient::ShowPhoto(const string& userId, const string& inviteId, const string& photoId, const string& sendId, bool charget, const string& photoDesc, int ticket)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::ShowPhoto() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatShowPhotoTask* task = new LSLiveChatShowPhotoTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::ShowPhoto() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, inviteId, photoId, sendId, charget, photoDesc, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::ShowPhoto() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::ShowPhoto() end");
	return result;
}

// 获取用户信息
int CLSLiveChatClient::GetUserInfo(const string& userId)
{
	bool result = false;
    int seq = -1;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUserInfo() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetUserInfoTask* task = new LSLiveChatGetUserInfoTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUserInfo() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId);

			if (result) {
				seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUserInfo() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUserInfo() end");
	return seq;
}

// 获取多个用户信息
int CLSLiveChatClient::GetUsersInfo(const list<string>& userIdList)
{
	int seq = m_seqCounter.GetInvalidValue();

	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUsersInfo() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetUsersInfoTask* task = new LSLiveChatGetUsersInfoTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUsersInfo() task:%p", task);
		if (NULL != task) {
			bool result = task->Init(this);
			result = result && task->InitParam(userIdList);

			if (result) {
				seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUsersInfo() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUsersInfo() end");

	return seq;
}

// 获取联系人/黑名单列表
bool CLSLiveChatClient::GetContactList(CONTACT_LIST_TYPE listType)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetContactList() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetContactListTask* task = new LSLiveChatGetContactListTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetContactList() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(listType);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetContactList() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetContactList() end");
	return result;
}

// 上传客户端版本号
bool CLSLiveChatClient::UploadVer(const string& ver)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadVer() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatUploadVerTask* task = new LSLiveChatUploadVerTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadVer() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(ver);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadVer() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadVer() end");
	return result;
}

// 获取被屏蔽女士列表
bool CLSLiveChatClient::GetBlockUsers()
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetBlockUsers() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetBlockUsersTask* task = new LSLiveChatGetBlockUsersTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetBlockUsers() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetBlockUsers() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetBlockUsers() end");
	return result;
}

// 获取最近人列表
bool CLSLiveChatClient::GetRecentContactList()
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetRecentContactList() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetRecentContactListTask* task = new LSLiveChatGetRecentContactListTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetRecentContactList() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetRecentContactList() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetRecentContactList() end");
	return result;
}

// 搜索在线男士
bool CLSLiveChatClient::SearchOnlineMan(int beginAge, int endAge)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SearchOnlineMan() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSearchOnlineManTask* task = new LSLiveChatSearchOnlineManTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SearchOnlineMan() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(beginAge, endAge);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SearchOnlineMan() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SearchOnlineMan() end");
	return result;
}

// 回复验证码
bool CLSLiveChatClient::ReplyIdentifyCode(string identifyCode)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::ReplyIdentifyCode() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatReplyIdentifyCodeTask* task = new LSLiveChatReplyIdentifyCodeTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::ReplyIdentifyCode() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(identifyCode);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::ReplyIdentifyCode() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::ReplyIdentifyCode() end");
	return result;
}

// 刷新验证码
bool CLSLiveChatClient::RefreshIdentifyCode()
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::RefreshIdentifyCode() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatRefreshIdentifyCodeTask* task = new LSLiveChatRefreshIdentifyCodeTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::RefreshIdentifyCode() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::RefreshIdentifyCode() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::RefreshIdentifyCode() end");
	return result;
}

// 刷新邀请模板
bool CLSLiveChatClient::RefreshInviteTemplate()
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::RefreshInviteTemplate() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatRefreshInviteTemplateTask* task = new LSLiveChatRefreshInviteTemplateTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::RefreshInviteTemplate() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::RefreshInviteTemplate() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::RefreshInviteTemplate() end");
	return result;
}

// 获取已扣费最近联系人列表
bool CLSLiveChatClient::GetFeeRecentContactList()
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetFeeRecentContactList() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetFeeRecentContactListTask* task = new LSLiveChatGetFeeRecentContactListTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetFeeRecentContactList() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetFeeRecentContactList() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetFeeRecentContactList() end");
	return result;
}

// 获取女士聊天信息（包括在聊及邀请的男士列表等）
bool CLSLiveChatClient::GetLadyChatInfo()
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyChatInfo() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetLadyChatInfoTask* task = new LSLiveChatGetLadyChatInfoTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyChatInfo() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyChatInfo() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyChatInfo() end");
	return result;
}

// 播放视频
bool CLSLiveChatClient::PlayVideo(const string& userId, const string& inviteId, const string& videoId, const string& sendId, bool charget, const string& videoDesc, int ticket)
{
    bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::PlayVideo() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatPlayVideoTask* task = new LSLiveChatPlayVideoTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::PlayVideo() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, inviteId, videoId, sendId, charget, videoDesc, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::PlayVideo() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::PlayVideo() end");
	return result;
}

// 女士发送微视频
bool CLSLiveChatClient::SendLadyVideo(const string& userId, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyVideo() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSendLadyVideoTask* task = new LSLiveChatSendLadyVideoTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyVideo() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, inviteId, videoId, sendId, charge, videoDesc, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyVideo() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendLadyVideo() end");
	return result;
}

// 获取女士择偶条件
bool CLSLiveChatClient::GetLadyCondition(const string& userId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCondition() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetLadyConditionTask* task = new LSLiveChatGetLadyConditionTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCondition() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCondition() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCondition() end");
	return result;
}

// 获取女士自定义邀请模板
bool CLSLiveChatClient::GetLadyCustomTemplate(const string& userId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCustomTemplate() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetLadyCustomTemplateTask* task = new LSLiveChatGetLadyCustomTemplateTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCustomTemplate() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCustomTemplate() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCustomTemplate() end");
	return result;
}

// 弹出女士自动邀请消息通知
bool CLSLiveChatClient::UploadPopLadyAutoInvite(const string& userId, const string& msg, const string& key)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadPopLadyAutoInvite() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatUploadPopLadyAutoInviteTask* task = new LSLiveChatUploadPopLadyAutoInviteTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadPopLadyAutoInvite() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, msg, key);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadPopLadyAutoInvite() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadPopLadyAutoInvite() end");
	return result;
}

// 上传自动充值状态
bool CLSLiveChatClient::UploadAutoChargeStatus(bool isCharge)
{
	bool result = false;
//    FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadAutoChargeStatus() begin");
//    if (NULL != m_taskManager
//        && m_taskManager->IsStart())
//    {
//        LSLiveChatUploadAutoChargeStatusTask* task = new LSLiveChatUploadAutoChargeStatusTask();
//        FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadAutoChargeStatus() task:%p", task);
//        if (NULL != task) {
//            result = task->Init(this);
//            result = result && task->InitParam(isCharge);
//
//            if (result) {
//                int seq = m_seqCounter.GetAndIncrement();
//                task->SetSeq(seq);
//                result = m_taskManager->HandleRequestTask(task);
//            }
//        }
//        FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadAutoChargeStatus() task:%p end", task);
//    }
//    FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadAutoChargeStatus() end");
	return result;
}

// 发送小高级表情
bool CLSLiveChatClient::SendMagicIcon(const string& userId, const string& iconId, int ticket)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendMagicIcon() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatSendMagicIconTask* task = new LSLiveChatSendMagicIconTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendMagicIcon() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, iconId, ticket);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendMagicIcon() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendMagicIcon() end");
	return result;
}

// 获取指定男/女士的已购主题包
bool CLSLiveChatClient::GetPaidTheme(const string& userId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetPaidTheme() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetPaidThemeTask* task = new LSLiveChatGetPaidThemeTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetPaidTheme() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetPaidTheme() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetPaidTheme() end");
	return result;
}

// 获取男/女士所有已购主题包
bool CLSLiveChatClient::GetAllPaidTheme()
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetAllPaidTheme() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatGetAllPaidThemeTask* task = new LSLiveChatGetAllPaidThemeTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetAllPaidTheme() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetAllPaidTheme() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetAllPaidTheme() end");
	return result;
}

// 上传主题包列表版本号
bool CLSLiveChatClient::UploadThemeListVer(int themeVer)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadThemeListVer() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatUploadThemeListVerTask* task = new LSLiveChatUploadThemeListVerTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadThemeListVer() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(themeVer);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadThemeListVer() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::UploadThemeListVer() end");
	return result;
}

// 男士购买主题包
bool CLSLiveChatClient::ManFeeTheme(const string& userId, const string& themeId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::ManFeeTheme() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatManFeeThemeTask* task = new LSLiveChatManFeeThemeTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::ManFeeTheme() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, themeId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::ManFeeTheme() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::ManFeeTheme() end");
	return result;
}

// 男士应用主题包
bool CLSLiveChatClient::ManApplyTheme(const string& userId, const string& themeId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::ManApplyTheme() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatManApplyThemeTask* task = new LSLiveChatManApplyThemeTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::ManApplyTheme() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, themeId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::ManApplyTheme() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::ManApplyTheme() end");
	return result;
}

// 男/女士播放主题包动画
bool CLSLiveChatClient::PlayThemeMotion(const string& userId, const string& themeId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::PlayThemeMotion() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		LSLiveChatPlayThemeMotionTask* task = new LSLiveChatPlayThemeMotionTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::PlayThemeMotion() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, themeId);

			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::PlayThemeMotion() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::PlayThemeMotion() end");
	return result;
}

// 获取自动邀请状态（仅女士）
bool CLSLiveChatClient:: GetAutoInviteMsgSwitchStatus()
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetAutoInviteStatus() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		 LSLiveChatGetAutoInviteStatusTask* task = new LSLiveChatGetAutoInviteStatusTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetAutoInviteStatus() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetAutoInviteStatus() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetAutoInviteStatus() end");
	return result;
}

// 启动/关闭发送自动邀请消息（仅女士）
bool CLSLiveChatClient::SwitchAutoInviteMsg(bool isOpen)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendAutoInvite() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		 LSLiveChatSendAutoInviteTask* task = new LSLiveChatSendAutoInviteTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendAutoInvite() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(isOpen);
			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendAutoInvite() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendAutoInvite() end");
	return result;
}

// 女士推荐男士购买主题包（仅女士）
bool CLSLiveChatClient::RecommendThemeToMan(const string& userId, const string& themeId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendThemeRecommend() begin");
	if (NULL != m_taskManager
		&& m_taskManager->IsStart())
	{
		 LSLiveChatSendThemeRecommendTask* task = new LSLiveChatSendThemeRecommendTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendThemeRecommend() task:%p", task);
		if (NULL != task) {
			result = task->Init(this);
			result = result && task->InitParam(userId, themeId);
			if (result) {
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendThemeRecommend() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendThemeRecommend() end");
	return result;
}

// 获取女士Cam状态
int CLSLiveChatClient::GetLadyCamStatus(const string& userId)
{
	bool result = false;
    int seq = -1;
//    FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCamstatus() begin");
//    if (NULL != m_taskManager && m_taskManager->IsStart()){
//        LSLiveChatGetLadyCamStatusTask* task = new LSLiveChatGetLadyCamStatusTask();
//        FileLog("LSLiveChatClient", "CLiveChatClient::GetLadyCamStatus() task:%p begin", task);
//        if (NULL != task) {
//            result = task->Init(this);
//            result = result && task->InitParam(userId);
//
//            if(result) {
//                seq = m_seqCounter.GetAndIncrement();
//                task->SetSeq(seq);
//                result = m_taskManager->HandleRequestTask(task);
//            }
//        }
//        FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCamStatus() task:%p end", task);
//    }
//    FileLog("LSLiveChatClient", "CLSLiveChatClient::GetLadyCamStatus() end");
	return seq;
}

// 发送CamShare邀请
bool CLSLiveChatClient::SendCamShareInvite(const string& userId, CamshareInviteType inviteType, int sessionId, const string& fromName)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendCamShareInvite() begin");
	if(NULL != m_taskManager && m_taskManager->IsStart()){
		LSLiveChatSendCamShareInviteTask* task = new LSLiveChatSendCamShareInviteTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendCamShareInvite() task:%p begin", task);
		if(NULL != task){
			result = task->Init(this);
			result = result && task->InitParam(userId, inviteType, sessionId, fromName);

			if(result){
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}

		FileLog("LSLiveChatClient", "CLSLiveChatClient::SendCamShareInvite() task:%p end", task);
	}

	FileLog("LSLiveChatClient", "CLSLiveChatClient::SendCamShareInvite() end");
	return result;
}

// 男士发起CamShare并开始扣费
bool CLSLiveChatClient::ApplyCamShare(const string& userId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::ApplyCamShare() begin");
    if(NULL != m_taskManager && m_taskManager->IsStart())
	{
		LSLiveChatApplyCamShareTask* task = new LSLiveChatApplyCamShareTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::ApplyCamShare() task:%p begin", task);
		if(NULL != task){
			result = task->Init(this);
			result = result && task->InitParam(userId);
			if(result){
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::ApplyCamShare() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::ApplyCamShare() end");
	return result;
}

// 女士接受男士Cam邀请
bool CLSLiveChatClient::LadyAcceptCamInvite(const string& userId, CamshareLadyInviteType inviteType, int sessionId, const string& fromName, bool isOpenCam)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::LadyAcceptCamInvite() begin");
    if(NULL != m_taskManager && m_taskManager->IsStart())
	{
		LSLiveChatLadyAcceptCamInviteTask* task = new LSLiveChatLadyAcceptCamInviteTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::LadyAcceptCamInvite() task:%p begin", task);
		if(NULL != task){
			result = task->Init(this);
            result = result && task->InitParam(userId, inviteType, sessionId, fromName, isOpenCam);
			if(result){
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::LadyAcceptCamInvite() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::LadyAcceptCamInvite() end");
	return result;
}

// CamShare聊天扣费心跳
bool CLSLiveChatClient::CamShareHearbeat(const string& userId, const string& inviteId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::CamShareHearbeat() begin");
	if(NULL != m_taskManager && m_taskManager->IsStart())
	{
		LSLiveChatCamShareHearbeatTask* task = new LSLiveChatCamShareHearbeatTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::CamShareHearbeat() task:%p begin", task);
		if(NULL != task){
			result = task->Init(this);
			result = result && task->InitParam(userId, inviteId);
			if(result){
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::CamShareHearbeat() task:%p end", task);

	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::CamShareHearbeat() end");
	return result;
}

// 批量获取女士端Cam状态
bool CLSLiveChatClient::GetUsersCamStatus(const UserIdList& list)
{
	bool result = false;
//    FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUsersCamStatus() begin");
//    if(NULL != m_taskManager && m_taskManager->IsStart())
//    {
//        LSLiveChatGetUsersCamStatusTask* task = new LSLiveChatGetUsersCamStatusTask();
//        FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUsersCamStatus() task:%p begin", task);
//        if(NULL != task){
//            result = task->Init(this);
//            result = result && task->InitParam(list);
//            if(result){
//                int seq = m_seqCounter.GetAndIncrement();
//                task->SetSeq(seq);
//                result = m_taskManager->HandleRequestTask(task);
//            }
//        }
//        FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUsersCamStatus() task:%p end", task);
//    }
//    FileLog("LSLiveChatClient", "CLSLiveChatClient::GetUsersCamStatus() end");
	return result;
}

// Camshare使用试聊券
bool CLSLiveChatClient::CamshareUseTryTicket(const string& targetId, const string& ticketId)
{
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::CamshareUseTryTicket() begin");
	if(NULL != m_taskManager && m_taskManager->IsStart())
	{
		LSLiveChatCamshareUseTryTicketTask* task = new LSLiveChatCamshareUseTryTicketTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::CamshareUseTryTicket() task:%p begin", task);
		if(NULL != task){
			result = task->Init(this);
			result = result && task->InitParam(targetId, ticketId);
			if(result){
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::CamshareUseTryTicket() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::CamshareUseTryTicket() end");
	return result;
}
// 女士端更新Camshare服务状态到服务器
bool CLSLiveChatClient::SummitLadyCamStatus(CAMSHARE_STATUS_TYPE camStatus){
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SummitLadyCamStatusTask() begin");
	if(NULL != m_taskManager && m_taskManager->IsStart())
	{
		LSLiveChatSummitLadyCamStatusTask* task = new LSLiveChatSummitLadyCamStatusTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SummitLadyCamStatusTask() task:%p begin", task);
		if(NULL != task){
			result = task->Init(this);
			result = result && task->InitParam(camStatus);
			if(result){
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SummitLadyCamStatusTask() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SummitLadyCamStatusTask() end");
	return result;
}
// 女士端获取会话信息
bool CLSLiveChatClient::GetSessionInfoWithMan(const string& targetId){
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetSessionInfoWithManTask() begin");
	if(NULL != m_taskManager && m_taskManager->IsStart())
	{
		LSLiveChatGetSessionInfoWithManTask* task = new LSLiveChatGetSessionInfoWithManTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetSessionInfoWithManTask() task:%p begin", task);
		if(NULL != task){
			result = task->Init(this);
			result = result && task->InitParam(targetId);
			if(result){
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::GetSessionInfoWithManTask() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::GetSessionInfoWithManTask() end");
	return result;
}

// 女士端设置小助手Cam优先
bool CLSLiveChatClient::SummitAutoInviteCamFirst(bool camFirst){
	bool result = false;
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SummitAutoInviteCamFirst() begin");
	if(NULL != m_taskManager && m_taskManager->IsStart())
	{
		LSLiveChatSummitAutoInviteCamFirstTask* task = new LSLiveChatSummitAutoInviteCamFirstTask();
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SummitAutoInviteCamFirst() task:%p begin", task);
		if(NULL != task){
			result = task->Init(this);
			result = result && task->InitParam(camFirst);
			if(result){
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				result = m_taskManager->HandleRequestTask(task);
			}
		}
		FileLog("LSLiveChatClient", "CLSLiveChatClient::SummitAutoInviteCamFirst() task:%p end", task);
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::SummitAutoInviteCamFirst() end");
	return result;
}

// 获取用户账号
string CLSLiveChatClient::GetUser()
{
	return m_user;
}

int CLSLiveChatClient::GetSocket() {
    return m_taskManager->GetSocket();
}
// ------------------------ ITaskManagerListener接口函数 -------------------------
// 连接成功回调
void CLSLiveChatClient::OnConnect(bool success)
{
	FileLog("LSLiveChatClient", "CLSLiveChatClient::OnConnect() success: %d", success);
	if (success) {
		FileLog("LSLiveChatClient", "CLSLiveChatClient::OnConnect() CheckVersionProc()");
		// 连接服务器成功，检测版本号
		CheckVersionProc();
		// 启动发送心跳包线程
		HearbeatThreadStart();
	}
	else {
		FileLog("LSLiveChatClient", "CLSLiveChatClient::OnConnect() LSLIVECHAT_LCC_ERR_CONNECTFAIL, this:%p", this);
		this->OnLogin(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "");
	}
	FileLog("LSLiveChatClient", "CLSLiveChatClient::OnConnect() end");
}

// 断开连接或连接失败回调（先回调OnDisconnect()再回调OnDisconnect(const TaskList& list)）
void CLSLiveChatClient::OnDisconnect()
{
	// 停止心跳线程
	if (NULL != m_hearbeatThread) {
		m_isHearbeatThreadRun = false;
		m_hearbeatThread->WaitAndStop();
		ILSLiveChatThreadHandler::ReleaseThreadHandler(m_hearbeatThread);
		m_hearbeatThread = NULL;
	}	
}

// 断开连接或连接失败回调(listUnsentTask：未发送的task列表)
void CLSLiveChatClient::OnDisconnect(const TaskList& listUnsentTask)
{
	// 各任务回调OnDisconnect
	TaskList::const_iterator iter;
	for (iter = listUnsentTask.begin();
		iter != listUnsentTask.end();
		iter++)
	{
		(*iter)->OnDisconnect();
	}

	// 回调 OnLogout
	this->OnLogout(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "");
}

// 已完成交互的task
void CLSLiveChatClient::OnTaskDone(ILSLiveChatTask* task)
{
	if (NULL != task) {
		// 需要LSLiveChatClient处理后续相关业务逻辑的task（如：检测版本）
		switch (task->GetCmdCode()) {
		case TCMD_CHECKVER:
			OnCheckVerTaskDone(task);
			break;
		case TCMD_LOGIN:
			UploadDeviceIdProc();
			break;
		case TCMD_UPLOADDEVID:
			UploadDeviceTypeProc();
			break;
		}
	}
}

// 检测版本已经完成
void CLSLiveChatClient::OnCheckVerTaskDone(ILSLiveChatTask* task)
{
	LSLIVECHAT_LCC_ERR_TYPE errType = LSLIVECHAT_LCC_ERR_FAIL;
	string errMsg("");
	task->GetHandleResult(errType, errMsg);
	if (LSLIVECHAT_LCC_ERR_SUCCESS == errType) {
		// 检测版本成功，进行登录操作
		LoginProc();
	}
	else {
		// 检测版本失败，回调给上层
		this->OnLogin(errType, errMsg);
	}
}

// ------------------------ 操作处理函数 ------------------------------
// 检测版本号
bool CLSLiveChatClient::CheckVersionProc()
{
	bool result = false;
	LSLiveChatCheckVerTask* checkVerTask = new LSLiveChatCheckVerTask();
	if (NULL != checkVerTask) {
		checkVerTask->Init(this);
		checkVerTask->InitParam("1.1.0.0XCHAT");

		int seq = m_seqCounter.GetAndIncrement();
		checkVerTask->SetSeq(seq);
		result = m_taskManager->HandleRequestTask(checkVerTask);
	}
	return result;
}

// 登录
bool CLSLiveChatClient::LoginProc()
{
	bool result = false;
	LSLiveChatLoginTask* loginTask = new LSLiveChatLoginTask();
	if (NULL != loginTask) {
		loginTask->Init(this);
		loginTask->InitParam(m_user, m_password, m_clientType, m_sexType, m_authType);

		int seq = m_seqCounter.GetAndIncrement();
		loginTask->SetSeq(seq);
		result =  m_taskManager->HandleRequestTask(loginTask);
	}
	return result;
}

// 上传设备ID
bool CLSLiveChatClient::UploadDeviceIdProc()
{
	bool result = false;
	LSLiveChatUploadDeviceIdTask* task = new LSLiveChatUploadDeviceIdTask();
	if (NULL != task) {
		task->Init(this);
		task->InitParam(m_deviceId);

		int seq = m_seqCounter.GetAndIncrement();
		task->SetSeq(seq);
		result =  m_taskManager->HandleRequestTask(task);
	}
	return result;
}

// 上传设备类型
bool CLSLiveChatClient::UploadDeviceTypeProc()
{
	bool result = false;
	LSLiveChatUploadDeviceTypeTask* task = new LSLiveChatUploadDeviceTypeTask();
	if (NULL != task) {
		task->Init(this);
		task->InitParam(m_clientType);

		int seq = m_seqCounter.GetAndIncrement();
		task->SetSeq(seq);
		result =  m_taskManager->HandleRequestTask(task);
	}
	return result;
}

// ------------------------ 心跳处理函数 ------------------------------
void CLSLiveChatClient::HearbeatThreadStart()
{
	// 启动心跳处理线程
	m_isHearbeatThreadRun = true;
	if (NULL == m_hearbeatThread) {
		m_hearbeatThread = ILSLiveChatThreadHandler::CreateThreadHandler();
		m_hearbeatThread->Start(HearbeatThread, this);
	}
}

TH_RETURN_PARAM CLSLiveChatClient::HearbeatThread(void* arg)
{
	CLSLiveChatClient* pThis = (CLSLiveChatClient*)arg;
	pThis->HearbeatProc();
	return NULL;
}

void CLSLiveChatClient::HearbeatProc()
{
	FileLog("LSLiveChatClient", "CLSLiveChatClient::HearbeatProc() begin");

	const unsigned long nSleepStep = 200;	// ms
	const unsigned long nSendStep = 30 * 1000; // ms

	long long preTime = getCurrentTime();
	long long curTime = getCurrentTime();
	do {
		curTime = getCurrentTime();
		if (DiffTime(preTime, curTime) >= nSendStep) {
			LSLiveChatHearbeatTask* task = new LSLiveChatHearbeatTask();
			if (NULL != task) {
				task->Init(this);
				int seq = m_seqCounter.GetAndIncrement();
				task->SetSeq(seq);
				m_taskManager->HandleRequestTask(task);
			}
			preTime = curTime;
		}
		Sleep(nSleepStep);
	} while (m_isHearbeatThreadRun);

	FileLog("LSLiveChatClient", "CLSLiveChatClient::HearbeatProc() end");
}


/**************************************** LSLiveChatClient Callback ****************************************/
void CLSLiveChatClient::OnLogin(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnLogin(err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnLogout(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnLogout(err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSetStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSetStatus(err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnEndTalk(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnEndTalk(inUserId, err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetUserStatus(const UserIdList& inList, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserStatusList& list) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetUserStatus(inList, err, errmsg, list);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetTalkInfo(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& invitedId, bool charge, unsigned int chatTime) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetTalkInfo(inUserId, err, errmsg, userId, invitedId, charge, chatTime);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetSessionInfo(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const SessionInfoItem& sessionInfo) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetSessionInfo(inUserId, err, errmsg, sessionInfo);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSendTextMessage(const string& inUserId, const string& inMessage, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSendTextMessage(inUserId, inMessage, inTicket, err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSendEmotion(const string& inUserId, const string& inEmotionId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSendEmotion(inUserId, inEmotionId, inTicket, err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSendVGift(const string& inUserId, const string& inGiftId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSendVGift(inUserId, inGiftId, inTicket, err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetVoiceCode(const string& inUserId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& voiceCode) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetVoiceCode(inUserId, inTicket, err, errmsg, voiceCode);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSendVoice(const string& inUserId, const string& inVoiceId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSendVoice(inUserId, inVoiceId, inTicket, err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnUseTryTicket(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, TRY_TICKET_EVENT tickEvent) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnUseTryTicket(inUserId, err, errmsg, userId, tickEvent);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetTalkList(int inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkListInfo& talkListInfo) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetTalkList(inListType, err, errmsg, talkListInfo);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSendPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSendPhoto(err, errmsg, ticket);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSendLadyPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSendLadyPhoto(err, errmsg, ticket);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnShowPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnShowPhoto(err, errmsg, ticket);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetUserInfo(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserInfoItem& userInfo) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetUserInfo(seq, inUserId, err, errmsg, userInfo);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetUsersInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int seq, const list<string>& userIdList, const UserInfoList& userList) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetUsersInfo(err, errmsg, seq, userIdList, userList);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetContactList(CONTACT_LIST_TYPE inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkUserList& list) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetContactList(inListType, err, errmsg, list);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetBlockUsers(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& users) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetBlockUsers(err, errmsg, users);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSearchOnlineMan(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSearchOnlineMan(err, errmsg, userList);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnReplyIdentifyCode(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnReplyIdentifyCode(err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetRecentContactList(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetRecentContactList(err, errmsg, userList);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetFeeRecentContactList(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetFeeRecentContactList(err, errmsg, userList);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetLadyChatInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& chattingList, const list<string>& chattingInviteIdList, const list<string>& missingList, const list<string>& missingInviteIdList) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetLadyChatInfo(err, errmsg, chattingList, chattingInviteIdList, missingList, missingInviteIdList);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnPlayVideo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnPlayVideo(err, errmsg, ticket);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSendLadyVideo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSendLadyVideo(err, errmsg, ticket);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetLadyCondition(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const LadyConditionItem& item) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetLadyCondition(inUserId, err, errmsg, item);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetLadyCustomTemplate(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const vector<string>& contents, const vector<bool>& flags) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetLadyCustomTemplate(inUserId, err, errmsg, contents, flags);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSendMagicIcon(const string& inUserId, const string& inIconId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSendMagicIcon(inUserId, inIconId, inTicket, err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetPaidTheme(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoList& themeList) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetPaidTheme(inUserId, err, errmsg, themeList);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetAllPaidTheme(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoList& themeInfoList) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetAllPaidTheme(err, errmsg, themeInfoList);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnManFeeTheme(const string& inUserId, const string& inThemeId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoItem& item) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnManFeeTheme(inUserId, inThemeId, err, errmsg, item);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnManApplyTheme(const string& inUserId, const string& inThemeId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const ThemeInfoItem& item) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnManApplyTheme(inUserId, inThemeId, err, errmsg, item);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnPlayThemeMotion(const string& inUserId, const string& inThemeId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool success) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnPlayThemeMotion(inUserId, inThemeId, err, errmsg, success);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetAutoInviteMsgSwitchStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenStatus) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetAutoInviteMsgSwitchStatus(err, errmsg, isOpenStatus);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSwitchAutoInviteMsg(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenStatus) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSwitchAutoInviteMsg(err, errmsg, isOpenStatus);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecommendThemeToMan(const string& inUserId, const string& inThemeId,LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecommendThemeToMan(inUserId, inThemeId, err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetSessionInfoWithMan(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetSessionInfoWithMan(inUserId, err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnUploadPopLadyAutoInvite(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& msg, const string& key, const string& inviteId) {
    FileLog("LiveChatClient", "OnUploadPopLadyAutoInvite::Handle() inviteId:%s m_listenerList:%d start", inviteId.c_str(), m_listenerList.size());
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {

        ILSLiveChatClientListener* callback = *itr;
        FileLog("LiveChatClient", "OnUploadPopLadyAutoInvite::Handle() callback:%p", callback);
        callback->OnUploadPopLadyAutoInvite(err, errmsg, userId, msg, key, inviteId);
    }
    m_listenerListLock->Unlock();
    FileLog("LiveChatClient", "OnUploadPopLadyAutoInvite::Handle() inviteId:%s m_listenerList:%d end", inviteId.c_str(), m_listenerList.size());
}

void CLSLiveChatClient::OnGetLadyCamStatus(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenCam) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetLadyCamStatus(seq, inUserId, err, errmsg, isOpenCam);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSendCamShareInvite(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSendCamShareInvite(inUserId, err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnApplyCamShare(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isSuccess, const string& targetId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnApplyCamShare(inUserId, err, errmsg, isSuccess, targetId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnLadyAcceptCamInvite(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnLadyAcceptCamInvite(inUserId, err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnGetUsersCamStatus(const UserIdList& inList, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserCamStatusList& list) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnGetUsersCamStatus(inList, err, errmsg, list);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnCamshareUseTryTicket(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& ticketId, const string& inviteId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnCamshareUseTryTicket(err, errmsg, userId, ticketId, inviteId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSummitLadyCamStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSummitLadyCamStatus(err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnSummitAutoInviteCamFirst(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnSummitAutoInviteCamFirst(err, errmsg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvMessage(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& message, INVITE_TYPE inviteType) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvMessage(toId, fromId, fromName, inviteId, charge, ticket, msgType, message, inviteType);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvEmotion(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& emotionId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvEmotion(toId, fromId, fromName, inviteId, charge, ticket, msgType, emotionId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvVoice(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, TALK_MSG_TYPE msgType, const string& voiceId, const string& fileType, int timeLen) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvVoice(toId, fromId, fromName, inviteId, charge, msgType, voiceId, fileType, timeLen);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvWarning(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& message) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvWarning(toId, fromId, fromName, inviteId, charge, ticket, msgType, message);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnUpdateStatus(const string& userId, const string& server, CLIENT_TYPE clientType, USER_STATUS_TYPE statusType) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnUpdateStatus(userId, server, clientType, statusType);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnUpdateTicket(const string& fromId, int ticket) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnUpdateTicket(fromId, ticket);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvEditMsg(const string& fromId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvEditMsg(fromId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvTalkEvent(const string& userId, TALK_EVENT_TYPE eventType) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvTalkEvent(userId, eventType);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvTryTalkBegin(const string& toId, const string& fromId, int time) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvTryTalkBegin(toId, fromId, time);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvTryTalkEnd(const string& userId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvTryTalkEnd(userId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvEMFNotice(const string& fromId, TALK_EMF_NOTICE_TYPE noticeType) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvEMFNotice(fromId, noticeType);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvKickOffline(KICK_OFFLINE_TYPE kickType) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvKickOffline(kickType);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvPhoto(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvPhoto(toId, fromId, fromName, inviteId, photoId, sendId, charge, photoDesc, ticket);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvShowPhoto(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvShowPhoto(toId, fromId, fromName, inviteId, photoId, sendId, charge, photoDesc, ticket);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvLadyVoiceCode(const string& voiceCode) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvLadyVoiceCode(voiceCode);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvIdentifyCode(const unsigned char* data, long dataLen) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvIdentifyCode(data, dataLen);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvVideo(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvVideo(toId, fromId, fromName, inviteId, videoId, sendId, charge, videoDesc, ticket);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvShowVideo(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvShowVideo(toId, fromId, fromName, inviteId, videoId, sendId, charge, videoDesc, ticket);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvAutoInviteMsg(const string& womanId, const string& manId, const string& key) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvAutoInviteMsg(womanId, manId, key);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvAutoChargeResult(const string& manId, double money, TAUTO_CHARGE_TYPE type, bool result, const string& code, const string& msg) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvAutoChargeResult(manId, money, type, result, code, msg);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvMagicIcon(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& iconId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvMagicIcon(toId, fromId, fromName, inviteId, charge, ticket, msgType, iconId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvThemeMotion(const string& themeId, const string& manId, const string& womanId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvThemeMotion(themeId, manId, womanId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvThemeRecommend(const string& themeId, const string& manId, const string& womanId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvThemeRecommend(themeId, manId, womanId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnAutoInviteStatusUpdate(bool isOpenStatus) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnAutoInviteStatusUpdate(isOpenStatus);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvAutoInviteNotify(const string& womanId,const string& manId,const string& message,const string& inviteId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvAutoInviteNotify(womanId, manId, message, inviteId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnManApplyThemeNotify(const ThemeInfoItem& item) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnManApplyThemeNotify(item);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnManBuyThemeNotify(const ThemeInfoItem& item) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnManBuyThemeNotify(item);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvLadyCamStatus(const string& userId, USER_STATUS_PROTOCOL statusId, const string& server, CLIENT_TYPE clientType, CamshareLadySoundType sound, const string& version) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvLadyCamStatus(userId, statusId, server, clientType, sound, version);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvAcceptCamInvite(const string& fromId, const string& toId, CamshareLadyInviteType inviteType, int sessionId, const string& fromName, bool isCamOpen) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvAcceptCamInvite(fromId, toId, inviteType, sessionId, fromName, isCamOpen);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvManCamShareInvite(const string& fromId, const string& toId, CamshareInviteType inviteType, int sessionId, const string& fromName) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvManCamShareInvite(fromId, toId, inviteType, sessionId, fromName);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvManCamShareStart(const string& manId, const string& womanId, const string& inviteId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvManCamShareStart(manId, womanId, inviteId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvCamHearbeatException(const string& exceptionName, LSLIVECHAT_LCC_ERR_TYPE err, const string& targetId) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvCamHearbeatException(exceptionName, err, targetId);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvManSessionInfo(const SessionInfoItem& sessionInfo) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvManSessionInfo(sessionInfo);
    }
    m_listenerListLock->Unlock();
}

void CLSLiveChatClient::OnRecvManJoinOrExitConference(MAN_CONFERENCE_EVENT_TYPE eventType, const string& fromId, const string& toId, const list<string>& userList) {
    m_listenerListLock->Lock();
    for(LSLiveChatClientListenerList::const_iterator itr = m_listenerList.begin(); itr != m_listenerList.end(); itr++) {
        ILSLiveChatClientListener* callback = *itr;
        callback->OnRecvManJoinOrExitConference(eventType, fromId, toId, userList);
    }
    m_listenerListLock->Unlock();
}


/**************************************** LSLiveChatClient Callback End ****************************************/
