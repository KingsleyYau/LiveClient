/*
 * author: Samson.Fan
 *   date: 2017-05-09
 *   file: ImClient.cpp
 *   desc: IM客户端实现类
 */

#include "ImClient.h"
#include "TaskManager.h"
#include <common/KLog.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>


const int IMCLIENT_VERSION = 100;                // IM客户端内部版本号
const long long HEARTBEAT_STEP = 10*1000;        // 心跳发送间隔（毫秒）
const long long HEARTBEAT_TIMEOUT = 25*1000;     // 心跳超时（毫秒）

// task include
#include "LoginTask.h"
#include "HearbeatTask.h"

#include "RoomInTask.h"
#include "RoomOutTask.h"
#include "SendLiveChatTask.h"
#include "SendGiftTask.h"
#include "SendToastTask.h"
#include "SendPrivateLiveInviteTask.h"
#include "SendCancelPrivateLiveInviteTask.h"
#include "SendTalentTask.h"
#include "PublicRoomInTask.h"
#include "ControlManPushTask.h"
#include "GetInviteInfoTask.h"
#include "SendInstantInviteUserReportTask.h"


ImClient::ImClient()
{
    m_taskManager = NULL;
    m_bInit = false;
    
    m_listenerListLock = IAutoLock::CreateAutoLock();
    m_listenerListLock->Init();

    m_isHearbeatThreadRun = false;
    m_hearbeatThread = NULL;
	m_lastHearbeatTimeLock = IAutoLock::CreateAutoLock();
	m_lastHearbeatTimeLock->Init();
	m_lastHearbeatTime = 0;
    
    m_loginStatusLock = IAutoLock::CreateAutoLock();
    m_loginStatusLock->Init();
    m_loginStatus = LOGOUT;
    
    m_user = "";
    m_password = "";
    m_clientType = CLIENTTYPE_UNKNOW;
    m_token = "";
    m_pageName = PAGENAMETYPE_UNKNOW;
}

ImClient::~ImClient()
{
	FileLog("ImClient", "ImClient::~ImClient()");
	// 注销
	Logout();
	
	delete m_taskManager;
	m_taskManager = NULL;

    IAutoLock::ReleaseAutoLock(m_loginStatusLock);
	IAutoLock::ReleaseAutoLock(m_lastHearbeatTimeLock);
    IAutoLock::ReleaseAutoLock(m_listenerListLock);
    
	FileLog("ImClient", "ImClient::~ImClient() end");
}

// ------------------------ IImClient接口函数 -------------------------
// 调用所有接口函数前需要先调用Init
bool ImClient::Init(const list<string>& urls)
{
	bool result = false;

	// 初始化 TaskManager
	if (NULL == m_taskManager) {
		m_taskManager = new CTaskManager();
		if (NULL != m_taskManager) {
			result = m_taskManager->Init(urls, this, this);
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
void ImClient::AddListener(IImClientListener* listener)
{
    m_listenerListLock->Lock();
    m_listenerList.push_back(listener);
    m_listenerListLock->Unlock();
}

// 移除监听器
void ImClient::RemoveListener(IImClientListener* listener)
{
    m_listenerListLock->Lock();
    for(ImClientListenerList::iterator itr = m_listenerList.begin();
        itr != m_listenerList.end();
        itr++)
    {
        if( *itr == listener ) {
            m_listenerList.erase(itr);
            break;
        }
    }
    m_listenerListLock->Unlock();
}

// 判断是否无效seq
bool ImClient::IsInvalidReqId(SEQ_T seq)
{
	return m_seqCounter.IsInvalidValue(seq);
}

// 获取seq
SEQ_T ImClient::GetReqId()
{
	return m_seqCounter.GetAndIncrement();
}

// 连接服务器
bool ImClient::ConnectServer()
{
	bool result = false;

	FileLog("ImClient", "ImClient::ConnectServer() begin");

	if (m_bInit) {
		if (NULL != m_taskManager) {
			if (m_taskManager->IsStart()) {
				m_taskManager->StopAndWait();
			}
			result = m_taskManager->Start();
			FileLog("ImClient", "ImClient::ConnectServer() result: %d", result);
		}
	}

	FileLog("ImClient", "ImClient::ConnectServer() end");

	return result;
}

// 获取用户账号
string ImClient::GetUser()
{
    return m_user;
}

// ------------------------ ITaskManagerListener接口函数 -------------------------
// 连接成功回调
void ImClient::OnConnect(bool success)
{
    FileLevelLog("ImClient", KLog::LOG_WARNING, "ImClient::OnConnect() success: %d", success);
    if (success) {
        FileLog("ImClient", "ImClient::OnConnect() CheckVersionProc()");
        // 开始登录
        LoginProc();
        // 启动发送心跳包线程
        HearbeatThreadStart();
    }
    else {
        FileLevelLog("ImClient", KLog::LOG_WARNING, "ImClient::OnConnect() LCC_ERR_CONNECTFAIL, this:%p", this);
        LoginReturnItem item;
        this->OnLogin(LCC_ERR_CONNECTFAIL, "", item);
    }
    FileLevelLog("ImClient", KLog::LOG_WARNING, "ImClient::OnConnect() end");
}

// 断开连接或连接失败回调（先回调OnDisconnect()再回调OnDisconnect(const TaskList& list)）
void ImClient::OnDisconnect()
{
    FileLevelLog("ImClient", KLog::LOG_WARNING, "ImClient::OnDisconnect() begin");
	// 停止心跳
	HearbearThreadStop();
    FileLevelLog("ImClient", KLog::LOG_WARNING, "ImClient::OnDisconnect() end");
}

// 断开连接或连接失败回调(listUnsentTask：未发送的task列表)
void ImClient::OnDisconnect(const TaskList& listUnsentTask)
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
	this->OnLogout(LCC_ERR_CONNECTFAIL, "");
}

// 已完成交互的task
void ImClient::OnTaskDone(ITask* task)
{
	if (NULL != task) {
		if (task->GetCmdCode() == CMD_HEARTBEAT) {
			// 处理心跳成功，更新最后心跳时间
			m_lastHearbeatTimeLock->Lock();
			m_lastHearbeatTime = getCurrentTime();
			m_lastHearbeatTimeLock->Unlock();
		}
	}
}

// 登录
bool ImClient::Login(const string& token, PageNameType pageName) {

	bool result = false;

    FileLevelLog("ImClient", KLog::LOG_WARNING ,"ImClient::Login() begin");
    
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();

    if (LOGOUT == loginStatus) {
        // 先释放资源
        Logout();
        
        if (!token.empty()
            && pageName >= PAGENAMETYPE_BEGIN
            && pageName <= PAGENAMETYPE_END)
        {
            m_token = token;
            m_pageName = pageName;
            
            if (ConnectServer()) {
                m_loginStatusLock->Lock();
                m_loginStatus = LOGINING;
                //m_loginStatus =  LOGINED;
                m_loginStatusLock->Unlock();

                result = true;
            }
        }
    }
    else {
        // 正在login或已login
        result = true;
    }
    
    // 登录失败，释放资源
    if (!result) {
        Logout();
    }

	FileLevelLog("ImClient", KLog::LOG_WARNING, "ImClient::Login() end");

	return result;
}

// 注销
bool ImClient::Logout()
{
	bool result = false;

	FileLevelLog("ImClient", KLog::LOG_WARNING, "ImClient::Logout() begin, m_taskManager:%p", m_taskManager);

	if (NULL != m_taskManager) {
		FileLog("ImClient", "ImClient::Logout() m_taskManager->StopAndWait(), m_taskManager:%p", m_taskManager);
		result = m_taskManager->StopAndWait();

		if (result) {
			m_user = "";
			m_password = "";
            m_clientType = CLIENTTYPE_UNKNOW;
            
            m_token = "";
            m_pageName = PAGENAMETYPE_UNKNOW;
		}
	}

	FileLevelLog("ImClient", KLog::LOG_WARNING, "ImClient::Logout() end");

	return result;
}

// 获取login状态
IImClient::LoginStatus ImClient::GetLoginStatus()
{
    return m_loginStatus;
}

// ------------------------ 心跳处理函数 ------------------------------
void ImClient::HearbeatThreadStart()
{
    // 启动心跳处理线程
    m_isHearbeatThreadRun = true;
    if (NULL == m_hearbeatThread) {
        m_hearbeatThread = IThreadHandler::CreateThreadHandler();
        m_hearbeatThread->Start(HearbeatThread, this);
    }
}

// 停止发送心跳包线程
void ImClient::HearbearThreadStop()
{
	if (NULL != m_hearbeatThread) {
        m_isHearbeatThreadRun = false;
        m_hearbeatThread->WaitAndStop();
        IThreadHandler::ReleaseThreadHandler(m_hearbeatThread);
        m_hearbeatThread = NULL;
    }
}

TH_RETURN_PARAM ImClient::HearbeatThread(void* arg)
{
    ImClient* pThis = (ImClient*)arg;
    pThis->HearbeatProc();
    return NULL;
}

void ImClient::HearbeatProc()
{
    FileLog("ImClient", "ImClient::HearbeatProc() begin");
    
    const unsigned long nSleepStep = 200;	// ms
    
    long long preTime = getCurrentTime();
    long long curTime = getCurrentTime();
	m_lastHearbeatTime = getCurrentTime();
    do {
        curTime = getCurrentTime();

		// 发送心跳流程
        if (DiffTime(preTime, curTime) >= HEARTBEAT_STEP) {
            HearbeatTask* task = new HearbeatTask();
            if (NULL != task) {
                task->Init(this);
                SEQ_T seq = m_seqCounter.GetAndIncrement();
                task->SetSeq(seq);
                m_taskManager->HandleRequestTask(task);
            }
            preTime = curTime;
        }

		// 检测心跳超时流程
		m_lastHearbeatTimeLock->Lock();
		long long lastHearbeatTime = m_lastHearbeatTime;
		m_lastHearbeatTimeLock->Unlock();
		if (DiffTime(lastHearbeatTime, curTime) > HEARTBEAT_TIMEOUT) {
			m_taskManager->Stop();
		}
        Sleep(nSleepStep);
    } while (m_isHearbeatThreadRun);
    
    FileLog("ImClient", "ImClient::HearbeatProc() end");
}

// ------------------------ 登录函数 ------------------------------
bool ImClient::LoginProc()
{
    bool result = false;
    LoginTask* task = new LoginTask();
    if (NULL != task) {
        task->Init(this);
        task->InitParam(m_token, m_pageName);
        
        SEQ_T seq = m_seqCounter.GetAndIncrement();
        task->SetSeq(seq);
        result = m_taskManager->HandleRequestTask(task);
    }
    return result;
}

void ImClient::OnLogin(LCC_ERR_TYPE err, const string& errmsg, const LoginReturnItem& item)
{
    // 获取之前的登录状态，并修改当前登录状态
    LoginStatus loginStatus;
    m_loginStatusLock->Lock();
    loginStatus = m_loginStatus;
    m_loginStatus = (LCC_ERR_SUCCESS == err) ? LOGINED : LOGOUT;
    m_loginStatusLock->Unlock();

    // 若为登录中状态，则回调OnLogin
    if (LOGINING == loginStatus) {
        m_listenerListLock->Lock();
        for(ImClientListenerList::const_iterator itr = m_listenerList.begin();
            itr != m_listenerList.end();
            itr++)
        {
            IImClientListener* callback = *itr;
            callback->OnLogin(err, errmsg, item);
        }
        m_listenerListLock->Unlock();
    }
}

void ImClient::OnKickOff(LCC_ERR_TYPE err, const string& errmsg)
{
    // 获取之前的登录状态，并修改当前登录状态
    LoginStatus loginStatus;
    m_loginStatusLock->Lock();
    loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    
    // 若为登录中状态，则回调OnLogin
    if (LOGINED == loginStatus) {
        m_listenerListLock->Lock();
        for(ImClientListenerList::const_iterator itr = m_listenerList.begin();
            itr != m_listenerList.end();
            itr++)
        {
            IImClientListener* callback = *itr;
            callback->OnKickOff(err, errmsg);
        }
        m_listenerListLock->Unlock();
    }
}

// ------------------------ 注销函数 ------------------------------
void ImClient::OnLogout(LCC_ERR_TYPE err, const string& errmsg)
{
    FileLevelLog("ImClient", KLog::LOG_WARNING, "ImClient::OnLogout() begin");
    
    // 获取之前的登录状态，并修改当前登录状态
    LoginStatus loginStatus;
    m_loginStatusLock->Lock();
    loginStatus = m_loginStatus;
    m_loginStatus = LOGOUT;
    m_loginStatusLock->Unlock();
    
    // 若为已登录状态，则回调OnLogout
    if (LOGINED == loginStatus) {
        m_listenerListLock->Lock();
        for(ImClientListenerList::const_iterator itr = m_listenerList.begin();
            itr != m_listenerList.end();
            itr++)
        {
            IImClientListener* callback = *itr;
            callback->OnLogout(err, errmsg);
        }
        m_listenerListLock->Unlock();
    }
    
    FileLevelLog("ImClient", KLog::LOG_WARNING, "ImClient::OnLogout() end");
}

// --------- 直播间 ---------
// 观众进入直播间
bool ImClient::RoomIn(SEQ_T reqId, const string& roomId) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
     FileLog("ImClient", "ImClient::RoomIn() begin, m_taskManager:%p roomId:%s", m_taskManager, roomId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        RoomInTask* task = new RoomInTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        // 没有登录
        result = false;
    }
    FileLog("ImClient", "ImClient::RoomIn() end, m_taskManager:%proomId:%s result:%d", m_taskManager, roomId.c_str(), result);
    return result;
};

void ImClient::OnRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item) {
    FileLog("ImClient", "ImClient::OnRoomIn begin, ImClient:%p reqId:%d success:%d err:%d errMsg:%s userId:%s nickName:%s photoUrl:%s fansNum%d", this, reqId, success, err, errMsg.c_str(), item.userId.c_str(), item.nickName.c_str(), item.photoUrl.c_str(), item.fansNum);
    m_listenerListLock->Lock();
    for(ImClientListenerList::const_iterator itr = m_listenerList.begin();
        itr != m_listenerList.end();
        itr++)
    {
        IImClientListener* callback = *itr;
        callback->OnRoomIn(reqId, success, err, errMsg, item);
    }
        FileLog("ImClient", "ImClient::OnRoomIn end, ImClient:%p reqId:%d success:%d err:%d errMsg:%s userId:%s nickName:%s photoUrl:%s fansNum%d", this, reqId, success, err, errMsg.c_str(), item.userId.c_str(), item.nickName.c_str(), item.photoUrl.c_str(), item.fansNum);
    m_listenerListLock->Unlock();
}

// 观众退出直播间
bool ImClient::RoomOut(SEQ_T reqId, const string& roomId) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::RoomOut() begin, m_taskManager:%p roomId:%s", m_taskManager, roomId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        RoomOutTask* task = new RoomOutTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        // 没有登录
        result = false;
    }
    FileLog("ImClient", "ImClient::RoomOut() end, m_taskManager:%p roomId:%s result:%d", m_taskManager, roomId.c_str(), result);
    return result;
};

void ImClient::OnRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ImClient", "ImClient::OnRoomOut() begin, ImClient:%p reqId:%d success:%d err:%d errMsg:%s", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnRoomOut(reqId, success, err, errMsg);
    }
    FileLog("ImClient", "ImClient::OnRoomOut() end, ImClient:%p reqId:%d success:%d err:%d errMsg:%s", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}

// 3.13.观众进入公开直播间接口
bool ImClient::PublicRoomIn(SEQ_T reqId, const string& userId) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::PublicRoomIn() begin, m_taskManager:%p userId:%s reqId:%u", m_taskManager, userId.c_str(), reqId);
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        class PublicRoomInTask* task = new PublicRoomInTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(userId);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        // 没有登录
        result = false;
    }
    FileLog("ImClient", "ImClient::PublicRoomIn() end, m_taskManager:%p userId:%s result:%d", m_taskManager, userId.c_str(), result);
    return result;
}

/**
 *  3.13.观众进入公开直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param item         直播间信息
 *
 */
void ImClient::OnPublicRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const RoomInfoItem& item) {
    FileLog("ImClient", "ImClient::OnPublicRoomIn() begin, ImClient:%p", this);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnPublicRoomIn(reqId, success, err, errMsg, item);
    }
    FileLog("ImClient", "ImClient::OnPublicRoomIn() end, ImClient:%p", this);
    m_listenerListLock->Unlock();
}

/**
 *  3.14.观众开始／结束视频互动
 *
 *  @param reqId         请求序列号
 *  @param roomId        直播间ID
 *  @param control       视频操作（1:开始 2:关闭）
 *
 */
bool ImClient::ControlManPush(SEQ_T reqId, const string& roomId, IMControlType control) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::ControlManPush() begin, m_taskManager:%p roomId:%s", m_taskManager, roomId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        ControlManPushTask* task = new ControlManPushTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId, control);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        // 没有登录
        result = false;
    }
    FileLog("ImClient", "ImClient::ControlManPush() end, m_taskManager:%p roomId:%s result:%d", m_taskManager, roomId.c_str(), result);
    return result;
}

/**
 *  3.14.观众开始／结束视频互动接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *  @param manPushUrl       观众视频流url
 *
 */
void ImClient::OnControlManPush(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) {
    FileLog("ImClient", "ImClient::OnControlManPush() begin, ImClient:%p", this);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnControlManPush(reqId, success, err, errMsg, manPushUrl);
    }
    FileLog("ImClient", "ImClient::OnControlManPush() end, ImClient:%p", this);
    m_listenerListLock->Unlock();
}

/**
 *  3.15.获取指定立即私密邀请信息
 *
 *  @param reqId            请求序列号
 *  @param invitationId     邀请ID
 *
 */
bool ImClient::GetInviteInfo(SEQ_T reqId, const string& invitationId) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::GetInviteInfo() begin, m_taskManager:%p invitationId:%s", m_taskManager, invitationId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        GetInviteInfoTask* task = new GetInviteInfoTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(invitationId);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        // 没有登录
        result = false;
    }
    FileLog("ImClient", "ImClient::GetInviteInfo() end, m_taskManager:%p invitationId:%s result:%d", m_taskManager, invitationId.c_str(), result);
    return result;
}

/**
 *  3.15.获取指定立即私密邀请信息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *  @param item             立即私密邀请
 *
 */
void ImClient::OnGetInviteInfo(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const PrivateInviteItem& item) {
    FileLog("ImClient", "ImClient::OnGetInviteInfo() begin, ImClient:%p", this);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnGetInviteInfo(reqId, success, err, errMsg, item);
    }
    FileLog("ImClient", "ImClient::OnGetInviteInfo() end, ImClient:%p", this);
    m_listenerListLock->Unlock();
}

// --------- 直播间文本消息 ---------
// 4.1.发送直播间文本消息
bool ImClient::SendLiveChat(SEQ_T reqId, const string& roomId, const string& nickName, const string& msg, const list<string> at) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendLiveChat() begin, m_taskManager:%p roomId:%s nickName:%s msg:%s", m_taskManager, roomId.c_str(), nickName.c_str(), msg.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        SendLiveChatTask* task = new SendLiveChatTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId, nickName, msg, at);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendLiveChat() end, m_taskManager:%p roomId:%s nickName:%s msg:%s result:%d", m_taskManager, roomId.c_str(), nickName.c_str(), msg.c_str(), result);
    return result;
};

// 4.1.发送直播间文本消息回调
void ImClient::OnSendLiveChat(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ImClient", "ImClient::OnSendLiveChat() begin, ImClient:%p reqId:%d err:%d errMsg:%s", this, reqId, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendLiveChat(reqId, success, err, errMsg);
    }
    FileLog("ImClient", "ImClient::OnSendLiveChat() end, ImClient:%p reqId:%d err:%d errMsg:%s", this, reqId, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}

// ------------- 直播间点赞 -------------
// 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
bool ImClient::SendGift(SEQ_T reqId, const string& roomId, const string& nickName, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendGift() begin, m_taskManager:%p roomId:%s nickName:%s giftId:%s giftName:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d multi_click_id;%d", m_taskManager, roomId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        SendGiftTask* task = new SendGiftTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId, nickName, giftId, giftName, isBackPack, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);

            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendGift() end, m_taskManager:%p roomId:%s nickName:%s giftId:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d result:%d", m_taskManager, roomId.c_str(), nickName.c_str(), giftId.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, result);
    return result;
}

// 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
void ImClient::OnSendGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit, double rebateCredit) {
    FileLog("ImClient", "ImClient::OnSendGift() begin, ImClient:%p reqId:%d err:%d errMsg:%s credit:%f rebateCredit:%f", this, reqId, err, errMsg.c_str(), credit, rebateCredit);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendGift(reqId, success, err, errMsg, credit, rebateCredit);
    }
    FileLog("ImClient", "ImClient::OnSendGift() end, ImClient:%p reqId:%d err:%d errMsg:%s credit:%f rebateCredit:%f", this, reqId, err, errMsg.c_str(), credit, rebateCredit);
   
    m_listenerListLock->Unlock();
}

// ------------- 直播间弹幕消息 -------------
// 6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
bool ImClient::SendToast(SEQ_T reqId, const string& roomId, const string& nickName, const string& msg) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendRoomToast() begin, m_taskManager:%p roomId:%s nickName:%s msg:%s", m_taskManager, roomId.c_str(), nickName.c_str(), msg.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        SendToastTask* task = new SendToastTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId, nickName, msg);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendToast() end, m_taskManager:%p roomId:%s nickName:%s msg:%s result:%d", m_taskManager, roomId.c_str(), nickName.c_str(), msg.c_str(), result);
    return result;
}
// 6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）回调
void ImClient::OnSendToast(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double credit, double rebateCredit) {
    FileLog("ImClient", "ImClient::OnSendToast() begin, ImClient:%p reqId:%d err:%d errMsg:%s credit:%f rebateCredit:%f", this, reqId, err, errMsg.c_str(), credit, rebateCredit);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendToast(reqId, success,err, errMsg, credit, rebateCredit);
    }
    FileLog("ImClient", "ImClient::OnSendToast() end, ImClient:%p reqId:%d err:%d errMsg:%s credit:%f rebateCredit:%f", this, reqId, err, errMsg.c_str(), credit, rebateCredit);
    
    m_listenerListLock->Unlock();
}

// 7.1.观众立即私密邀请
bool ImClient::SendPrivateLiveInvite(SEQ_T reqId, const string& userId, const string& logId, bool force)
{
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendPrivateLiveInvite() begin, m_taskManager:%p userId:%s logId:%s", m_taskManager, userId.c_str(), logId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        SendPrivateLiveInviteTask* task = new SendPrivateLiveInviteTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(userId, logId, force);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendPrivateLiveInvite() end, m_taskManager:%p userId:%s logId:%s result:%d", m_taskManager,  userId.c_str(), logId.c_str(), result);
    return result;
}

/**
 *  7.1.观众立即私密邀请 回调
 *
 *  @param success       操作是否成功
 *  @param reqId         请求序列号
 *  @param err           结果类型
 *  @param errMsg        结果描述
 *  @param invitationId      邀请ID
 *  @param timeOut           邀请的剩余有效时间
 *  @param roomId            直播间ID
 *
 */
void ImClient::OnSendPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& invitationId, int timeOut, const string& roomId)
{
    FileLog("ImClient", "ImClient::OnSendPrivateLiveInvite() begin, ImClient:%p reqId:%d err:%d errMsg:%s invitationId:%s time:%d roomId:%s", this, reqId, err, errMsg.c_str(), invitationId.c_str(), timeOut, roomId.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendPrivateLiveInvite(reqId, success,err, errMsg, invitationId, timeOut, roomId);
    }
    FileLog("ImClient", "ImClient::OnSendPrivateLiveInvite() end, ImClient:%p reqId:%d err:%d errMsg:%s invitationId:%s time:%d roomId:%s", this, reqId, err, errMsg.c_str(), invitationId.c_str(), timeOut, roomId.c_str());
    
    m_listenerListLock->Unlock();
}

/**
 *  7.2.观众取消立即私密邀请
 *
 *  @param reqId                 请求序列号
 *  @param inviteId              邀请ID
 *
 */
bool ImClient::SendCancelPrivateLiveInvite(SEQ_T reqId, const string& inviteId)
{
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendCancelPrivateLiveInvite() begin, m_taskManager:%p inviteId:%s", m_taskManager, inviteId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        SendCancelPrivateLiveInviteTask* task = new SendCancelPrivateLiveInviteTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(inviteId);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendCancelPrivateLiveInvite() end, m_taskManager:%p inviteId:%s result:%d", m_taskManager,  inviteId.c_str(), result);
    return result;
}

/**
 *  7.2.观众取消立即私密邀请 回调
 *
 *  @param success       操作是否成功
 *  @param reqId         请求序列号
 *  @param err           结果类型
 *  @param errMsg        结果描述
 *  @param roomId        直播间ID
 *
 */
void ImClient::OnSendCancelPrivateLiveInvite(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& roomId)
{
    FileLog("ImClient", "ImClient::OnSendPrivateLiveInvite() begin, ImClient:%p reqId:%d err:%d errMsg:%s roomId:%s", this, reqId, err, errMsg.c_str(), roomId.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendCancelPrivateLiveInvite(reqId, success,err, errMsg, roomId);
    }
    FileLog("ImClient", "ImClient::OnSendPrivateLiveInvite() end, ImClient:%p reqId:%d err:%d errMsg:%s roomId:%s", this, reqId, err, errMsg.c_str(), roomId.c_str());
    
    m_listenerListLock->Unlock();
}

/**
 *  7.8.观众端是否显示主播立即私密邀请
 *
 *  @param reqId                 请求序列号
 *  @param inviteId              邀请ID
 *  @param isshow                观众端是否弹出邀请（整型）（0：否，1：是）
 *
 */
bool ImClient::SendInstantInviteUserReport(SEQ_T reqId, const string& inviteId, bool isShow)
{
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendInstantInviteUserReport() begin, m_taskManager:%p inviteId:%s isShow:%d", m_taskManager, inviteId.c_str(), isShow);
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        SendInstantInviteUserReportTask* task = new SendInstantInviteUserReportTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(inviteId, isShow);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendCancelPrivateLiveInvite() end, m_taskManager:%p inviteId:%s isShow:%d result:%d", m_taskManager,  inviteId.c_str(), isShow, result);
    return result;
}

/**
 *  7.8.观众端是否显示主播立即私密邀请 回调
 *
 *  @param success       操作是否成功
 *  @param reqId         请求序列号
 *  @param err           结果类型
 *  @param errMsg        结果描述
 *
 */
void ImClient::OnSendInstantInviteUserReport(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg)
{
    FileLog("ImClient", "ImClient::OnSendInstantInviteUserReportTask() begin, ImClient:%p reqId:%d err:%d errMsg:%s roomId:%s", this, reqId, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendInstantInviteUserReport(reqId, success,err, errMsg);
    }
    FileLog("ImClient", "ImClient::OnSendInstantInviteUserReportTask() end, ImClient:%p reqId:%d err:%d errMsg:%s roomId:%s", this, reqId, err, errMsg.c_str());
    
    m_listenerListLock->Unlock();
}

// ------------- 直播间才艺点播邀请 -------------
/**
 *  8.1.发送直播间才艺点播邀请
 *
 *  @param reqId                 请求序列号
 *  @param roomId                直播间ID
 *  @param talentId              才艺点播ID
 *
 */
bool ImClient::SendTalent(SEQ_T reqId, const string& roomId, const string& talentId)
{
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendTalent() begin, m_taskManager:%p roomId:%s talentId:%s", m_taskManager, roomId.c_str(), talentId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        SendTalentTask* task = new SendTalentTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId, talentId);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendTalent() end, m_taskManager:%p roomId:%s talentId:%s result:%d", m_taskManager,  roomId.c_str(), talentId.c_str(), result);
    return result;
}

/**
 *  8.1.发送直播间才艺点播邀请 回调
 *
 *  @param success           操作是否成功
 *  @param reqId             请求序列号
 *  @param err               结果类型
 *  @param errMsg            结果描述
 *
 */
void ImClient::OnSendTalent(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& talentInviteId)
{
    FileLog("ImClient", "ImClient::OnSendPrivateLiveInvite() begin, ImClient:%p reqId:%d err:%d errMsg:%s talentInviteId:%s", this, reqId, err, errMsg.c_str(), talentInviteId.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendTalent(reqId, success,err, errMsg, talentInviteId);
    }
    FileLog("ImClient", "ImClient::OnSendPrivateLiveInvite() end, ImClient:%p reqId:%d err:%d errMsg:%s talentInviteId:%s", this, reqId, err, errMsg.c_str(), talentInviteId.c_str());
    
    m_listenerListLock->Unlock();
}

// 服务端主动请求
// 接收直播间关闭通知(观众)
void ImClient::OnRecvRoomCloseNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ImClient", "ImClient::OnRecvCloseFans() begin, ImClient:%p roomId:%s", this, roomId.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvRoomCloseNotice(roomId, err, errMsg);
    }
    FileLog("ImClient", "ImClient::OnRecvCloseFans() end, ImClient:%p roomId:%s", this, roomId.c_str());
    m_listenerListLock->Unlock();
    
}

// 3.4.接收观众进入直播间通知
void ImClient::OnRecvEnterRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, const string& riderId, const string& riderName, const string& riderUrl, int fansNum, const string& honorImg) {
    FileLog("ImClient", "ImClient::OnRecvEnterRoomNotice() begin, ImClient:%p roomId:%s userId:%s nickName:%s photoUrl:%s riderId;%s riderName:%s riderUrl:%s fansNum:%d honorImg:%s", this, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), riderId.c_str(), riderName.c_str(), riderUrl.c_str(), fansNum, honorImg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvEnterRoomNotice(roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum, honorImg);
    }
    FileLog("ImClient", "ImClient::OnRecvEnterRoomNotice() end, ImClient:%p roomId:%s userId:%s nickName:%s photoUrl:%s riderId:%s riderName:%s riderUrl:%s fansNum:%d honorImg", this, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), riderId.c_str(), riderName.c_str(), riderUrl.c_str(), fansNum, honorImg.c_str());
    m_listenerListLock->Unlock();
}

// 3.5.接收观众退出直播间通知
void ImClient::OnRecvLeaveRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int fansNum) {
    FileLog("ImClient", "ImClient::OnRecvLeaveRoomNotice() begin, ImClient:%p roomId:%s userId:%s nickName:%s photoUrl:%s fansNum:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), fansNum);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvLeaveRoomNotice(roomId, userId, nickName, photoUrl, fansNum);
    }
    FileLog("ImClient", "ImClient::OnRecvLeaveRoomNotice() end, ImClient:%p roomId:%s userId:%s nickName:%s photoUrl:%s fansNum:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), fansNum);
    m_listenerListLock->Unlock();
}

// 3.6.接收返点通知
void ImClient::OnRecvRebateInfoNotice(const string& roomId, const RebateInfoItem& item) {
    FileLog("ImClient", "ImClient::OnRecvRebateInfoNotice() begin, ImClient:%p roomId:%s", this, roomId.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvRebateInfoNotice(roomId, item);
    }
    FileLog("ImClient", "ImClient::OnRecvRebateInfoNotice() end, ImClient:%p roomId:%s", this, roomId.c_str());
    m_listenerListLock->Unlock();

}

// 3.7.接收关闭直播间倒数通知
void ImClient::OnRecvLeavingPublicRoomNotice(const string& roomId, int leftSeconds, LCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ImClient", "ImClient::OnRecvLeavingPublicRoomNotice() begin, ImClient:%p roomId:%s leftSeconds:%d err:%d errMsg:%s", this, roomId.c_str(), leftSeconds, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, err, errMsg);
    }
    FileLog("ImClient", "ImClient::OnRecvLeavingPublicRoomNotice() end, ImClient:%p roomId:%s leftSeconds:%d err:%d errMsg:%s", this, roomId.c_str(), leftSeconds, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}

void ImClient::OnRecvRoomKickoffNotice(const string& roomId, LCC_ERR_TYPE err, const string& errMsg, double credit) {
    FileLog("ImClient", "ImClient::OnRecvRoomKickoffNotice() begin, ImClient:%p roomId:%s err:%d errMsg:%s credit:%f", this, roomId.c_str(), err, errMsg.c_str(), credit);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvRoomKickoffNotice(roomId, err, errMsg, credit);
    }
   FileLog("ImClient", "ImClient::OnRecvRoomKickoffNotice() begin, ImClient:%p roomId:%s err:%d errMsg:%s credit:%f", this, roomId.c_str(), err, errMsg.c_str(), credit);
    m_listenerListLock->Unlock();
}

void ImClient::OnRecvLackOfCreditNotice(const string& roomId, const string& msg, double credit) {
    FileLog("ImClient", "ImClient::OnRecvLackOfCreditNotice() begin, ImClient:%p roomId:%s msg:%s credit:%f", this, roomId.c_str(), msg.c_str(), credit);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvLackOfCreditNotice(roomId, msg, credit);
    }
    FileLog("ImClient", "ImClient::OnRecvLackOfCreditNotice() begin, ImClient:%p roomId:%s msg:%s credit:%f", this, roomId.c_str(), msg.c_str(), credit);
    m_listenerListLock->Unlock();
    
}
// 3.10.接收定时扣费通知 （观众端在付费公开直播间，普通私密直播间，豪华私密直播间时，接收服务器定时扣费通知）
void ImClient::OnRecvCreditNotice(const string& roomId, double credit) {
    FileLog("ImClient", "ImClient::OnRecvCreditNotice() begin, ImClient:%p roomId:%s credit:%f", this, roomId.c_str(), credit);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvCreditNotice(roomId, credit);
    }
    FileLog("ImClient", "ImClient::OnRecvCreditNotice() begin, ImClient:%p roomId:%s credit:%f", this, roomId.c_str(), credit);
    m_listenerListLock->Unlock();
    
}

/**
 *  3.11.直播间开播通知 回调
 *
 *  @param roomId       直播间ID
 *  @param leftSeconds  开播前的倒数秒数（可无，无或0表示立即开播）
 *
 */
void ImClient::OnRecvWaitStartOverNotice(const StartOverRoomItem& item)
{
    FileLog("ImClient", "ImClient::OnRecvWaitStartOverNotice() begin, ImClient:%p", this);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvWaitStartOverNotice(item);
    }
    FileLog("ImClient", "ImClient::OnRecvWaitStartOverNotice() begin, ImClient:%p", this);
    m_listenerListLock->Unlock();
}

/**
 *  3.12.接收观众／主播切换视频流通知接口 回调
 *
 *  @param roomId       房间ID
 *  @param isAnchor     是否是主播推流（1:是 0:否）
 *  @param playUrl      播放url
 *
 */
void ImClient::OnRecvChangeVideoUrl(const string& roomId, bool isAnchor, const list<string>& playUrl)
{
    FileLog("ImClient", "ImClient::OnRecvChangeVideoUrl() begin, ImClient:%p roomId:%s isAnchor:%d", this, roomId.c_str(), isAnchor);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvChangeVideoUrl(roomId, isAnchor, playUrl);
    }
    FileLog("ImClient", "ImClient::OnRecvChangeVideoUrl() end, ImClient:%p roomId:%s isAnchor:%d", this, roomId.c_str(), isAnchor);
    m_listenerListLock->Unlock();
}


// 4.2.接收直播间文本消息通知
void ImClient::OnRecvSendChatNotice(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) {
    FileLog("ImClient", "ImClient::OnRecvSendChatNotice() begin, ImClient:%p roomId:%s level:%d fromId:%s nickName:%s msg:%s honorUrl:%s", this, roomId.c_str(), level, fromId.c_str(), nickName.c_str(), msg.c_str(), honorUrl.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvSendChatNotice(roomId, level, fromId, nickName, msg, honorUrl);
    }
    FileLog("ImClient", "ImClient::OnRecvSendChatNotice() end, ImClient:%p roomId:%s level:%d fromId:%s nickName:%s msg:%s honorUrl:%s", this, roomId.c_str(), level, fromId.c_str(), nickName.c_str(), msg.c_str(), honorUrl.c_str());
    m_listenerListLock->Unlock();
}

// 4.3.接收直播间公告消息回调
void ImClient::OnRecvSendSystemNotice(const string& roomId, const string& msg, const string& link, IMSystemType type) {
    FileLog("ImClient", "ImClient::OnRecvSendSystemNotice() begin, ImClient:%p roomId:%s msg:%s link:%s type:%d", this, roomId.c_str(), msg.c_str(), link.c_str(), type);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvSendSystemNotice(roomId, msg, link, type);
    }
    FileLog("ImClient", "ImClient::OnRecvSendSystemNotice() end, ImClient:%p roomId:%s msg:%s link:%s type:%d", this, roomId.c_str(), msg.c_str(), link.c_str(), type);
    m_listenerListLock->Unlock();
}

// 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
void ImClient::OnRecvSendGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId, const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id, const string& honorUrl) {
    FileLog("ImClient", "ImClient::OnRecvSendGiftNotice() begin, ImClient:%p roomId:%s fromId:%s nickName:%s giftId:%s giftName:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d , multi_click_id:%d honorUrl:%s", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id, honorUrl.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvSendGiftNotice(roomId, fromId, nickName, giftId, giftName, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id, honorUrl);
    }
    FileLog("ImClient", "ImClient::OnRecvSendGiftNotice() end, ImClient:%p roomId:%s fromId:%s nickName:%s giftId:%s giftName:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d multi_click_id:%d honorUrl:%s", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id, honorUrl.c_str());
    m_listenerListLock->Unlock();
}

// 6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
void ImClient::OnRecvSendToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) {
    FileLog("ImClient", "ImClient::OnRecvSendToastNotice() begin, ImClient:%p roomId:%s fromId:%s nickName:%s msg:%s honorUrl:%s", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), msg.c_str(), honorUrl.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvSendToastNotice(roomId, fromId, nickName, msg, honorUrl);
    }
    FileLog("ImClient", "ImClient::OnRecvSendToastNotice() end, ImClient:%p roomId:%s fromId:%s nickName:%s msg:%s honorUrl:%s", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), msg.c_str(), honorUrl.c_str());
    m_listenerListLock->Unlock();
}

/**
 *  7.3.接收立即私密邀请回复通知 回调
 *
 *  @param inviteId      邀请ID
 *  @param replyType     主播回复 （0:拒绝 1:同意）
 *  @param roomId        直播间ID （可无，m_replyType ＝ 1存在）
 *
 */
void ImClient::OnRecvInstantInviteReplyNotice(const string& inviteId, ReplyType replyType ,const string& roomId, RoomType roomType, const string& anchorId, const string& nickName, const string& avatarImg, const string& msg) {
    FileLog("ImClient", "ImClient::OnRecvInstantInviteReplyNotice() begin, ImClient:%p inviteId:%s replyType:%d roomId:%s", this, inviteId.c_str(), replyType, roomId.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvInstantInviteReplyNotice(inviteId, replyType, roomId, roomType, anchorId, nickName, avatarImg, msg);
    }
    FileLog("ImClient", "ImClient::OnRecvInstantInviteReplyNotice() end, ImClient:%p inviteId:%s replyType:%d roomId:%s", this, inviteId.c_str(), replyType, roomId.c_str());
    m_listenerListLock->Unlock();
}

/**
 *  7.4.接收主播立即私密邀请通知 回调
 *
 *  @param inviteId     邀请ID
 *  @param anchorId     主播ID
 *  @param nickName     主播昵称
 *  @param avatarImg    主播头像url
 *  @param msg          提示文字
 *
 */
void ImClient::OnRecvInstantInviteUserNotice(const string& inviteId, const string& anchorId, const string& nickName ,const string& avatarImg, const string& msg) {
    FileLog("ImClient", "ImClient::OnRecvInstantInviteUserNotice() begin, ImClient:%p inviteId:%s anchorId:%s nickName:%s", this, inviteId.c_str(), anchorId.c_str(), nickName.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvInstantInviteUserNotice(inviteId, anchorId, nickName, avatarImg, msg);
    }
    FileLog("ImClient", "ImClient::OnRecvInstantInviteUserNotice() end,  ImClient:%p inviteId:%s anchorId:%s nickName:%s", this, inviteId.c_str(), anchorId.c_str(), nickName.c_str());
    m_listenerListLock->Unlock();
}


/**
 *  7.5.接收主播预约私密邀请通知 回调
 *
 *  @param inviteId     邀请ID
 *  @param anchorId     主播ID
 *  @param nickName     主播昵称
 *  @param avatarImg    主播头像url
 *  @param msg          提示文字
 *
 */
void ImClient::OnRecvScheduledInviteUserNotice(const string& inviteId, const string& anchorId ,const string& nickName, const string& avatarImg, const string& msg)
{
    FileLog("ImClient", "ImClient::OnRecvScheduledInviteUserNotice() begin, ImClient:%p inviteId:%s anchorId:%s nickName:%s", this, inviteId.c_str(), anchorId.c_str(), nickName.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvScheduledInviteUserNotice(inviteId, anchorId, nickName, avatarImg, msg);
    }
    FileLog("ImClient", "ImClient::OnRecvScheduledInviteUserNotice() end,  ImClient:%p inviteId:%s anchorId:%s nickName:%s", this, inviteId.c_str(), anchorId.c_str(), nickName.c_str());
    m_listenerListLock->Unlock();
}

/**
 *  7.6.接收预约私密邀请回复通知 回调
 *
 *  @param item    预约私密邀请回复知结构体
 *
 */
void ImClient::OnRecvSendBookingReplyNotice(const BookingReplyItem& item)
{
    FileLog("ImClient", "ImClient::OnRecvSendBookingReplyNotice() begin, ImClient:%p", this);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvSendBookingReplyNotice(item);
    }
    FileLog("ImClient", "ImClient::OnRecvSendBookingReplyNotice() end,  ImClient:%p", this);
    m_listenerListLock->Unlock();
}

/**
 *  7.7.接收预约开始倒数通知 回调
 *
 *  @param roomId       直播间ID
 *  @param userId       对端ID
 *  @param nickName     对端昵称
 *  @param avatarImg    对端头像url
 *  @param leftSeconds  倒数时间（秒）
 *
 */
void ImClient::OnRecvBookingNotice(const string& roomId, const string& userId, const string& nickName, const string& avatarImg, int leftSeconds)
{
    FileLog("ImClient", "ImClient::OnRecvBookingNotice() begin, ImClient:%p roomId:%s userId:%s nickName:%s avatarImg:%s leftSeconds:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), avatarImg.c_str(), leftSeconds);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvBookingNotice(roomId, userId, nickName, avatarImg, leftSeconds);
    }
    FileLog("ImClient", "ImClient::OnRecvBookingNotice() end,  ImClient:%p roomId:%s userId:%s nickName:%s avatarImg:%s leftSeconds:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), avatarImg.c_str(), leftSeconds);
    m_listenerListLock->Unlock();
}

/**
 *  8.2.接收直播间才艺点播回复通知 回调
 *
 *  @param roomId           直播间ID
 *  @param talentInviteId   才艺邀请ID
 *  @param talentId         才艺ID
 *  @param name             才艺名称
 *  @param credit           观众当前的信用点余额
 *  @param status           状态（1:已接受 2:拒绝）
 *
 */
void ImClient::OnRecvSendTalentNotice(const TalentReplyItem& item)
{
    FileLog("ImClient", "ImClient::OnRecvSendTalentNotice() begin, ImClient:%p roomId:%s talentInviteId:%s talentId:%s name:%s", this, item.roomId.c_str(), item.talentInviteId.c_str(), item.talentId.c_str(), item.name.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvSendTalentNotice(item);
    }
    FileLog("ImClient", "ImClient::OnRecvSendTalentNotice() end,  ImClient:%p roomId:%s talentInviteId:%s talentId:%s name:%s", this, item.roomId.c_str(), item.talentInviteId.c_str(), item.talentId.c_str(), item.name.c_str());
    m_listenerListLock->Unlock();
}

/**
 *  9.1.观众等级升级通知 回调
 *
 *  @param level           当前等级
 *
 */
void ImClient::OnRecvLevelUpNotice(int level)
{
    FileLog("ImClient", "ImClient::OnRecvLevelUpNotice() begin, ImClient:%p level:%d", this, level);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvLevelUpNotice(level);
    }
    FileLog("ImClient", "ImClient::OnRecvLevelUpNotice() end,  ImClient:%p level:%d", this, level);
    m_listenerListLock->Unlock();
}

/**
 *  9.2.观众亲密度升级通知
 *
 *  @param loveLevel           当前等级
 *
 */
void ImClient::OnRecvLoveLevelUpNotice(int loveLevel)
{
    FileLog("ImClient", "ImClient::OnRecvLoveLevelUpNotice() begin, ImClient:%p loveLevel:%d", this, loveLevel);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvLoveLevelUpNotice(loveLevel);
    }
    FileLog("ImClient", "ImClient::OnRecvLoveLevelUpNotice() end,  ImClient:%p loveLevel:%d", this, loveLevel);
    m_listenerListLock->Unlock();
}

/**
 *  9.3.背包更新通知
 *
 *  @param item          新增的背包礼物
 *
 */
void ImClient::OnRecvBackpackUpdateNotice(const BackpackInfo& item)
{
    FileLog("ImClient", "ImClient::OnRecvBackpackUpdateNotice() begin, ImClient:%p", this);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvBackpackUpdateNotice(item);
    }
    FileLog("ImClient", "ImClient::OnRecvBackpackUpdateNotice() end,  ImClient:%p", this);
    m_listenerListLock->Unlock();
}

/**
 *  9.4.观众勋章升级通知
 *
 *  @param honorId          勋章ID
 *  @param honorUrl         勋章图片url
 *
 */
void ImClient::OnRecvGetHonorNotice(const string& honorId, const string& honorUrl)
{
    FileLog("ImClient", "ImClient::OnRecvGetHonorNotice() begin, ImClient:%p honorId:%s honorUrl:%s", this, honorId.c_str(), honorUrl.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvGetHonorNotice(honorId, honorUrl);
    }
    FileLog("ImClient", "ImClient::OnRecvGetHonorNotice() end,  ImClient:%p honorId:%s honorUrl:%s", this, honorId.c_str(), honorUrl.c_str());
    m_listenerListLock->Unlock();
}

