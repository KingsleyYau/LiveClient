/*
 * author: Alex
 *   date: 2018-03-02
 *   file: ZBImClient.cpp
 *   desc: 主播IM客户端实现类
 */

#include "ZBImClient.h"
#include "ZBTaskManager.h"
#include <common/KLog.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>


const int IMCLIENT_VERSION = 100;                // IM客户端内部版本号
const long long HEARTBEAT_STEP = 10*1000;        // 心跳发送间隔（毫秒）
const long long HEARTBEAT_TIMEOUT = 25*1000;     // 心跳超时（毫秒）

// task include
#include "ZBLoginTask.h"
#include "ZBHearbeatTask.h"
//
#include "ZBRoomInTask.h"
#include "ZBRoomOutTask.h"
#include "ZBSendLiveChatTask.h"
#include "ZBSendGiftTask.h"
//#include "SendToastTask.h"
#include "ZBSendPrivateLiveInviteTask.h"
//#include "SendCancelPrivateLiveInviteTask.h"
//#include "SendTalentTask.h"
#include "ZBPublicRoomInTask.h"
//#include "ControlManPushTask.h"
#include "ZBGetInviteInfoTask.h"
//#include "SendInstantInviteUserReportTask.h"


ZBImClient::ZBImClient()
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
    m_loginStatus = ZBLOGOUT;
    
    m_user = "";
    m_password = "";
    m_clientType = ZBCLIENTTYPE_UNKNOW;
    m_token = "";
    m_pageName = ZBPAGENAMETYPE_UNKNOW;
    
}

ZBImClient::~ZBImClient()
{
	FileLog("ImClient", "ImClient::~ImClient()");
	// 注销
	ZBLogout();
	
	delete m_taskManager;
	m_taskManager = NULL;

    IAutoLock::ReleaseAutoLock(m_loginStatusLock);
	IAutoLock::ReleaseAutoLock(m_lastHearbeatTimeLock);
    IAutoLock::ReleaseAutoLock(m_listenerListLock);
    
	FileLog("ZBImClient", "ZBImClient::~ImClient() end");
}

// ------------------------ IImClient接口函数 -------------------------
// 调用所有接口函数前需要先调用Init
bool ZBImClient::Init(const list<string>& urls)
{
	bool result = false;

	// 初始化 TaskManager
	if (NULL == m_taskManager) {
		m_taskManager = new ZBCTaskManager();
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
void ZBImClient::AddListener(IZBImClientListener* listener)
{
    m_listenerListLock->Lock();
    m_listenerList.push_back(listener);
    m_listenerListLock->Unlock();
}

// 移除监听器
void ZBImClient::RemoveListener(IZBImClientListener* listener)
{
    m_listenerListLock->Lock();
    for(ZBImClientListenerList::iterator itr = m_listenerList.begin();
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
bool ZBImClient::IsInvalidReqId(SEQ_T seq)
{
	return m_seqCounter.IsInvalidValue(seq);
}

// 获取seq
SEQ_T ZBImClient::GetReqId()
{
	return m_seqCounter.GetAndIncrement();
}

// 连接服务器
bool ZBImClient::ConnectServer()
{
	bool result = false;

	FileLog("ZBImClient", "ZBImClient::ConnectServer() begin");

	if (m_bInit) {
		if (NULL != m_taskManager) {
			if (m_taskManager->IsStart()) {
				m_taskManager->StopAndWait();
			}
			result = m_taskManager->Start();
			FileLog("ZBImClient", "ZBImClient::ConnectServer() result: %d", result);
		}
	}

	FileLog("ZBImClient", "ZBImClient::ConnectServer() end");

	return result;
}

// 获取用户账号
string ZBImClient::GetUser()
{
    return m_user;
}

// ------------------------ ITaskManagerListener接口函数 -------------------------
// 连接成功回调
void ZBImClient::OnConnect(bool success)
{
    FileLevelLog("ZBImClient", KLog::LOG_WARNING, "ZBImClient::OnConnect() success: %d", success);
    if (success) {
        FileLog("ZBImClient", "ZBImClient::OnConnect() CheckVersionProc()");
        // 开始登录
        LoginProc();
        // 启动发送心跳包线程
        HearbeatThreadStart();
    }
    else {
        FileLevelLog("ZBImClient", KLog::LOG_WARNING, "ZBImClient::OnConnect() ZBLCC_ERR_CONNECTFAIL, this:%p", this);
        ZBLoginReturnItem item;
        this->OnZBLogin(ZBLCC_ERR_CONNECTFAIL, "", item);
    }
    FileLevelLog("ZBImClient", KLog::LOG_WARNING, "ZBImClient::OnConnect() end");
}

// 断开连接或连接失败回调（先回调OnDisconnect()再回调OnDisconnect(const TaskList& list)）
void ZBImClient::OnDisconnect()
{
    FileLevelLog("ZBImClient", KLog::LOG_WARNING, "ZBImClient::OnDisconnect() begin");
	// 停止心跳
	HearbearThreadStop();
    FileLevelLog("ZBImClient", KLog::LOG_WARNING, "ZBImClient::OnDisconnect() end");
}

// 断开连接或连接失败回调(listUnsentTask：未发送的task列表)
void ZBImClient::OnDisconnect(const ZBTaskList& listUnsentTask)
{
	// 各任务回调OnDisconnect
	ZBTaskList::const_iterator iter;
	for (iter = listUnsentTask.begin();
		iter != listUnsentTask.end();
		iter++)
	{
		(*iter)->OnDisconnect();
	}

	// 回调 OnLogout
    this->OnZBLogout(ZBLCC_ERR_CONNECTFAIL, "");
}

// 已完成交互的task
void ZBImClient::OnTaskDone(IZBTask* task)
{
	if (NULL != task) {
		if (task->GetCmdCode() == ZB_CMD_HEARTBEAT) {
			// 处理心跳成功，更新最后心跳时间
			m_lastHearbeatTimeLock->Lock();
			m_lastHearbeatTime = getCurrentTime();
			m_lastHearbeatTimeLock->Unlock();
		}
	}
}

// 登录
bool ZBImClient::ZBLogin(const string& token, ZBPageNameType pageName) {

	bool result = false;

//    char* a = NULL;
//    char b = *a;
    
    
    FileLevelLog("ZBImClient", KLog::LOG_WARNING ,"ZBImClient::Login() begin");
    
    m_loginStatusLock->Lock();
    ZBLoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();

    if (ZBLOGOUT == loginStatus) {
        // 先释放资源
        ZBLogout();
        
        if (!token.empty()
            && pageName >= ZBPAGENAMETYPE_BEGIN
            && pageName <= ZBPAGENAMETYPE_END)
        {
            m_token = token;
            m_pageName = pageName;
            
            if (ConnectServer()) {
                m_loginStatusLock->Lock();
                m_loginStatus = ZBLOGINING;
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
        ZBLogout();
    }

	FileLevelLog("ZBImClient", KLog::LOG_WARNING, "ZBImClient::Login() end");

	return result;
}

// 注销
bool ZBImClient::ZBLogout()
{
	bool result = false;

	FileLevelLog("ZBImClient", KLog::LOG_WARNING, "ZBImClient::Logout() begin, m_taskManager:%p", m_taskManager);

	if (NULL != m_taskManager) {
		FileLog("ZBImClient", "ZBImClient::Logout() m_taskManager->StopAndWait(), m_taskManager:%p", m_taskManager);
		result = m_taskManager->StopAndWait();

		if (result) {
			m_user = "";
			m_password = "";
            m_clientType = ZBCLIENTTYPE_UNKNOW;
            
            m_token = "";
            m_pageName = ZBPAGENAMETYPE_UNKNOW;
            
		}
	}

	FileLevelLog("ZBImClient", KLog::LOG_WARNING, "ZBImClient::Logout() end");

	return result;
}

// 获取login状态
IZBImClient::ZBLoginStatus ZBImClient::ZBGetLoginStatus()
{
    return m_loginStatus;
}

// ------------------------ 心跳处理函数 ------------------------------
void ZBImClient::HearbeatThreadStart()
{
    // 启动心跳处理线程
    m_isHearbeatThreadRun = true;
    if (NULL == m_hearbeatThread) {
        m_hearbeatThread = IZBThreadHandler::CreateThreadHandler();
        m_hearbeatThread->Start(HearbeatThread, this);
    }
}

// 停止发送心跳包线程
void ZBImClient::HearbearThreadStop()
{
	if (NULL != m_hearbeatThread) {
        m_isHearbeatThreadRun = false;
        m_hearbeatThread->WaitAndStop();
        IZBThreadHandler::ReleaseThreadHandler(m_hearbeatThread);
        m_hearbeatThread = NULL;
    }
}

TH_RETURN_PARAM ZBImClient::HearbeatThread(void* arg)
{
    ZBImClient* pThis = (ZBImClient*)arg;
    pThis->HearbeatProc();
    return NULL;
}

void ZBImClient::HearbeatProc()
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
            ZBHearbeatTask* task = new ZBHearbeatTask();
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
            FileLog("ImClient", "ImClient::HearbeatProc() Stop() start");
			m_taskManager->Stop();
            FileLog("ImClient", "ImClient::HearbeatProc() Stop() end");
		}
        Sleep(nSleepStep);
    } while (m_isHearbeatThreadRun);
    
    FileLog("ImClient", "ImClient::HearbeatProc() end");
}

// ------------------------ 登录函数 ------------------------------
bool ZBImClient::LoginProc()
{
    bool result = false;
    ZBLoginTask* task = new ZBLoginTask();
    if (NULL != task) {
        task->Init(this);
        task->InitParam(m_token, m_pageName);
        
        SEQ_T seq = m_seqCounter.GetAndIncrement();
        task->SetSeq(seq);
        result = m_taskManager->HandleRequestTask(task);
    }
    return result;
}

void ZBImClient::OnZBLogin(ZBLCC_ERR_TYPE err, const string& errmsg, const ZBLoginReturnItem& item)
{
    // 获取之前的登录状态，并修改当前登录状态
    ZBLoginStatus loginStatus;
    m_loginStatusLock->Lock();
    loginStatus = m_loginStatus;
    m_loginStatus = (ZBLCC_ERR_SUCCESS == err) ? ZBLOGINED : ZBLOGOUT;
    m_loginStatusLock->Unlock();

    // 若为登录中状态，则回调OnLogin
    if (ZBLOGINING == loginStatus) {
        m_listenerListLock->Lock();
        for(ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
            itr != m_listenerList.end();
            itr++)
        {
            IZBImClientListener* callback = *itr;
            callback->OnZBLogin(err, errmsg, item);
        }
        m_listenerListLock->Unlock();
    }
}

void ZBImClient::OnZBKickOff(ZBLCC_ERR_TYPE err, const string& errmsg)
{
    // 获取之前的登录状态，并修改当前登录状态
    ZBLoginStatus loginStatus;
    m_loginStatusLock->Lock();
    loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    
    // 若为登录中状态，则回调OnLogin
    if (ZBLOGINED == loginStatus) {
        m_listenerListLock->Lock();
        for(ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
            itr != m_listenerList.end();
            itr++)
        {
            IZBImClientListener* callback = *itr;
            callback->OnZBKickOff(err, errmsg);
        }
        m_listenerListLock->Unlock();
    }
}

// ------------------------ 注销函数 ------------------------------
void ZBImClient::OnZBLogout(ZBLCC_ERR_TYPE err, const string& errmsg)
{
    FileLevelLog("ZBImClient", KLog::LOG_WARNING, "ZBImClient::OnZBLogout() begin");
    
    // 获取之前的登录状态，并修改当前登录状态
    ZBLoginStatus loginStatus;
    m_loginStatusLock->Lock();
    loginStatus = m_loginStatus;
    m_loginStatus = ZBLOGOUT;
    m_loginStatusLock->Unlock();
    
    // 若为已登录状态，则回调OnLogout
    if (ZBLOGINED == loginStatus) {
        m_listenerListLock->Lock();
        for(ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
            itr != m_listenerList.end();
            itr++)
        {
            IZBImClientListener* callback = *itr;
            callback->OnZBLogout(err, errmsg);
        }
        m_listenerListLock->Unlock();
    }
    
    FileLevelLog("ZBImClient", KLog::LOG_WARNING, "ZBImClient::OnLogout() end");
}

// --------- 直播间 ---------
// 3.1.新建/进入公开直播间接口
bool ZBImClient::ZBPublicRoomIn(SEQ_T reqId) {
    bool result = false;
    m_loginStatusLock->Lock();
    ZBLoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ZBImClient", "ZBImClient::ZBPublicRoomIn() begin, m_taskManager:%p reqId:%u", m_taskManager,  reqId);
    // 若为已登录状态
    if (ZBLOGINED == loginStatus) {
        class ZBPublicRoomInTask* task = new ZBPublicRoomInTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam();

            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        // 没有登录
        result = false;
    }
    FileLog("ZBImClient", "ZBImClient::ZBPublicRoomIn() end, m_taskManager:%p result:%d", m_taskManager, result);
    return result;
}

/**
 *  3.1.新建/进入公开直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param item         直播间信息
 *
 */
void ZBImClient::OnZBPublicRoomIn(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const ZBRoomInfoItem& item) {
    FileLog("ZBImClient", "ZBImClient::OnZBPublicRoomIn() begin, ZBImClient:%p", this);
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBPublicRoomIn(reqId, success, err, errMsg, item);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBPublicRoomIn() end, ImClient:%p", this);
    m_listenerListLock->Unlock();
}

// 3.2.主播进入指定直播间
bool ZBImClient::ZBRoomIn(SEQ_T reqId, const string& roomId) {
    bool result = false;
    m_loginStatusLock->Lock();
    ZBLoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
     FileLog("ZBImClient", "ZBImClient::RoomIn() begin, m_taskManager:%p roomId:%s", m_taskManager, roomId.c_str());
    // 若为已登录状态
    if (ZBLOGINED == loginStatus) {
        ZBRoomInTask* task = new ZBRoomInTask();
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
    FileLog("ZBImClient", "ZBImClient::ZBRoomIn() end, m_taskManager:%proomId:%s result:%d", m_taskManager, roomId.c_str(), result);
    return result;
};

void ZBImClient::OnZBRoomIn(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const ZBRoomInfoItem& item) {
    FileLog("ZBImClient", "ZBImClient::OnZBRoomIn begin, ImClient:%p reqId:%d success:%d err:%d errMsg:%s", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for(ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
        itr != m_listenerList.end();
        itr++)
    {
        IZBImClientListener* callback = *itr;
        callback->OnZBRoomIn(reqId, success, err, errMsg, item);
    }
        FileLog("ZBImClient", "ZBImClient::OnZBRoomIn end, ImClient:%p reqId:%d success:%d err:%d errMsg:%s", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}

// 观众退出直播间
bool ZBImClient::ZBRoomOut(SEQ_T reqId, const string& roomId) {
    bool result = false;
    m_loginStatusLock->Lock();
    ZBLoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ZBImClient", "ZBImClient::ZBRoomOut() begin, m_taskManager:%p roomId:%s", m_taskManager, roomId.c_str());
    // 若为已登录状态
    if (ZBLOGINED == loginStatus) {
        ZBRoomOutTask* task = new ZBRoomOutTask();
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
    FileLog("ImClient", "ZBImClient::ZBRoomOut() end, m_taskManager:%p roomId:%s result:%d", m_taskManager, roomId.c_str(), result);
    return result;
};

void ZBImClient::OnZBRoomOut(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ZBImClient", "ZBImClient::OnZBRoomOut() begin, ImClient:%p reqId:%d success:%d err:%d errMsg:%s", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRoomOut(reqId, success, err, errMsg);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRoomOut() end, ImClient:%p reqId:%d success:%d err:%d errMsg:%s", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}


///**
// *  3.14.观众开始／结束视频互动
// *
// *  @param reqId         请求序列号
// *  @param roomId        直播间ID
// *  @param control       视频操作（1:开始 2:关闭）
// *
// */
//bool ImClient::ControlManPush(SEQ_T reqId, const string& roomId, IMControlType control) {
//    bool result = false;
//    m_loginStatusLock->Lock();
//    LoginStatus loginStatus = m_loginStatus;
//    m_loginStatusLock->Unlock();
//    FileLog("ImClient", "ImClient::ControlManPush() begin, m_taskManager:%p roomId:%s", m_taskManager, roomId.c_str());
//    // 若为已登录状态
//    if (LOGINED == loginStatus) {
//        ControlManPushTask* task = new ControlManPushTask();
//        if (NULL != task) {
//            task->Init(this);
//            task->InitParam(roomId, control);
//            
//            task->SetSeq(reqId);
//            result = m_taskManager->HandleRequestTask(task);
//        }
//    }
//    else
//    {
//        // 没有登录
//        result = false;
//    }
//    FileLog("ImClient", "ImClient::ControlManPush() end, m_taskManager:%p roomId:%s result:%d", m_taskManager, roomId.c_str(), result);
//    return result;
//}
//
///**
// *  3.14.观众开始／结束视频互动接口 回调
// *
// *  @param success          操作是否成功
// *  @param reqId            请求序列号
// *  @param errMsg           结果描述
// *  @param manPushUrl       观众视频流url
// *
// */
//void ImClient::OnControlManPush(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const list<string>& manPushUrl) {
//    FileLog("ImClient", "ImClient::OnControlManPush() begin, ImClient:%p", this);
//    m_listenerListLock->Lock();
//    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
//         itr != m_listenerList.end();
//         itr++) {
//        IImClientListener* callback = *itr;
//        callback->OnControlManPush(reqId, success, err, errMsg, manPushUrl);
//    }
//    FileLog("ImClient", "ImClient::OnControlManPush() end, ImClient:%p", this);
//    m_listenerListLock->Unlock();
//}
//
///**
// *  3.15.获取指定立即私密邀请信息
// *
// *  @param reqId            请求序列号
// *  @param invitationId     邀请ID
// *
// */
//bool ImClient::GetInviteInfo(SEQ_T reqId, const string& invitationId) {
//    bool result = false;
//    m_loginStatusLock->Lock();
//    LoginStatus loginStatus = m_loginStatus;
//    m_loginStatusLock->Unlock();
//    FileLog("ImClient", "ImClient::GetInviteInfo() begin, m_taskManager:%p invitationId:%s", m_taskManager, invitationId.c_str());
//    // 若为已登录状态
//    if (LOGINED == loginStatus) {
//        GetInviteInfoTask* task = new GetInviteInfoTask();
//        if (NULL != task) {
//            task->Init(this);
//            task->InitParam(invitationId);
//            
//            task->SetSeq(reqId);
//            result = m_taskManager->HandleRequestTask(task);
//        }
//    }
//    else
//    {
//        // 没有登录
//        result = false;
//    }
//    FileLog("ImClient", "ImClient::GetInviteInfo() end, m_taskManager:%p invitationId:%s result:%d", m_taskManager, invitationId.c_str(), result);
//    return result;
//}
//

// --------- 直播间文本消息 ---------
// 4.1.发送直播间文本消息
bool ZBImClient::ZBSendLiveChat(SEQ_T reqId, const string& roomId, const string& nickName, const string& msg, const list<string> at) {
    bool result = false;
    m_loginStatusLock->Lock();
    ZBLoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ZBImClient", "ZBImClient::SendLiveChat() begin, m_taskManager:%p roomId:%s nickName:%s msg:%s", m_taskManager, roomId.c_str(), nickName.c_str(), msg.c_str());
    // 若为已登录状态
    if (ZBLOGINED == loginStatus) {
        ZBSendLiveChatTask* task = new ZBSendLiveChatTask();
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
    FileLog("ZBImClient", "ZBImClient::ZBSendLiveChat() end, m_taskManager:%p roomId:%s nickName:%s msg:%s result:%d", m_taskManager, roomId.c_str(), nickName.c_str(), msg.c_str(), result);
    return result;
};

// 4.1.发送直播间文本消息回调
void ZBImClient::OnZBSendLiveChat(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ZBImClient", "ZBImClient::OnZBSendLiveChat() begin, ImClient:%p reqId:%d err:%d errMsg:%s", this, reqId, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBSendLiveChat(reqId, success, err, errMsg);
    }
    FileLog("ZBImClient", "ZBImClient::OnSendLiveChat() end, ZBImClient:%p reqId:%d err:%d errMsg:%s", this, reqId, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}

// ------------- 直播间点赞 -------------
// 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
bool ZBImClient::ZBSendGift(SEQ_T reqId, const string& roomId, const string& nickName, const string& giftId, const string& giftName, bool isBackPack, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) {
    bool result = false;
    m_loginStatusLock->Lock();
    ZBLoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ZBImClient", "ZBImClient::ZBSendGift() begin, m_taskManager:%p roomId:%s nickName:%s giftId:%s giftName:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d multi_click_id;%d", m_taskManager, roomId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
    // 若为已登录状态
    if (ZBLOGINED == loginStatus) {
        ZBSendGiftTask* task = new ZBSendGiftTask();
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
    FileLog("ZBImClient", "ZBImClient::ZBSendGift() end, m_taskManager:%p roomId:%s nickName:%s giftId:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d result:%d", m_taskManager, roomId.c_str(), nickName.c_str(), giftId.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, result);
    return result;
}

// 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
void ZBImClient::OnZBSendGift(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ZBImClient", "ZBImClient::OnZBSendGift() begin, ImClient:%p reqId:%d err:%d errMsg:%s", this, reqId, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBSendGift(reqId, success, err, errMsg);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBSendGift() end, ImClient:%p reqId:%d err:%d errMsg:%s", this, reqId, err, errMsg.c_str());
   
    m_listenerListLock->Unlock();
}

// 9.1.主播发送立即私密邀请
bool ZBImClient::ZBSendPrivateLiveInvite(SEQ_T reqId, const string& userId)
{
    bool result = false;
    m_loginStatusLock->Lock();
    ZBLoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ZBImClient", "ZBImClient::ZBSendPrivateLiveInvite() begin, m_taskManager:%p userId:%s", m_taskManager, userId.c_str());
    // 若为已登录状态
    if (ZBLOGINED == loginStatus) {
        ZBSendPrivateLiveInviteTask* task = new ZBSendPrivateLiveInviteTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(userId);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ZBImClient", "ZBImClient::ZBSendPrivateLiveInvite() end, m_taskManager:%p userId:%s result:%d", m_taskManager,  userId.c_str(), result);
    return result;
}

/**
 *  9.1.主播发送立即私密邀请 回调
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
void ZBImClient::OnZBSendPrivateLiveInvite(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const string& invitationId, int timeOut, const string& roomId)
{
    FileLog("ZBImClient", "ZBImClient::OnZBSendPrivateLiveInvite() begin, ZBImClient:%p reqId:%d err:%d errMsg:%s invitationId:%s time:%d roomId:%s", this, reqId, err, errMsg.c_str(), invitationId.c_str(), timeOut, roomId.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBSendPrivateLiveInvite(reqId, success,err, errMsg, invitationId, timeOut, roomId);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBSendPrivateLiveInvite() end, ImClient:%p reqId:%d err:%d errMsg:%s invitationId:%s time:%d roomId:%s", this, reqId, err, errMsg.c_str(), invitationId.c_str(), timeOut, roomId.c_str());
    
    m_listenerListLock->Unlock();
}


/**
 *  9.5.获取指定立即私密邀请信息
 *
 *  @param reqId            请求序列号
 *  @param invitationId     邀请ID
 *
 */
bool ZBImClient::ZBGetInviteInfo(SEQ_T reqId, const string& invitationId) {
    bool result = false;
    m_loginStatusLock->Lock();
    ZBLoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ZBImClient", "ZBImClient::ZBGetInviteInfo() begin, m_taskManager:%p invitationId:%s", m_taskManager, invitationId.c_str());
    // 若为已登录状态
    if (ZBLOGINED == loginStatus) {
        ZBGetInviteInfoTask* task = new ZBGetInviteInfoTask();
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
    FileLog("ZBImClient", "ZBImClient::ZBGetInviteInfo() end, m_taskManager:%p invitationId:%s result:%d", m_taskManager, invitationId.c_str(), result);
    return result;
}

/**
 *  9.5.获取指定立即私密邀请信息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *  @param item             立即私密邀请
 *
 */
void ZBImClient::OnZBGetInviteInfo(SEQ_T reqId, bool success, ZBLCC_ERR_TYPE err, const string& errMsg, const ZBPrivateInviteItem& item) {
    FileLog("ZBImClient", "ZBImClient::OnZBGetInviteInfo() begin, ImClient:%p", this);
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBGetInviteInfo(reqId, success, err, errMsg, item);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBGetInviteInfo() end, ImClient:%p", this);
    m_listenerListLock->Unlock();
}

//// 服务端主动请求
// 接收直播间关闭通知(观众)
void ZBImClient::OnZBRecvRoomCloseNotice(const string& roomId, ZBLCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvCloseFans() begin, ImClient:%p roomId:%s", this, roomId.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvRoomCloseNotice(roomId, err, errMsg);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvCloseFans() end, ImClient:%p roomId:%s", this, roomId.c_str());
    m_listenerListLock->Unlock();
    
}

// 3.5.接收踢出直播间通知
void ZBImClient::OnZBRecvRoomKickoffNotice(const string& roomId, ZBLCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ZBImClient", "ZBImClient::OnRecvRoomKickoffNotice() begin, ZBImClient:%p roomId:%s err:%d errMsg:%s ", this, roomId.c_str(), err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvRoomKickoffNotice(roomId, err, errMsg);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvRoomKickoffNotice() begin, ImClient:%p roomId:%s err:%d errMsg:%s ", this, roomId.c_str(), err, errMsg.c_str());
    m_listenerListLock->Unlock();
}


// 3.6.接收观众进入直播间通知
void ZBImClient::OnZBRecvEnterRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, const string& riderId, const string& riderName, const string& riderUrl, int fansNum) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvEnterRoomNotice() begin, ImClient:%p roomId:%s userId:%s nickName:%s photoUrl:%s riderId;%s riderName:%s riderUrl:%s fansNum:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), riderId.c_str(), riderName.c_str(), riderUrl.c_str(), fansNum);
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvEnterRoomNotice(roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvEnterRoomNotice() end, ImClient:%p roomId:%s userId:%s nickName:%s photoUrl:%s riderId:%s riderName:%s riderUrl:%s fansNum:%d ", this, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), riderId.c_str(), riderName.c_str(), riderUrl.c_str(), fansNum);
    m_listenerListLock->Unlock();
}

// 3.7.接收观众退出直播间通知
void ZBImClient::OnZBRecvLeaveRoomNotice(const string& roomId, const string& userId, const string& nickName, const string& photoUrl, int fansNum) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvLeaveRoomNotice() begin, ImClient:%p roomId:%s userId:%s nickName:%s photoUrl:%s fansNum:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), fansNum);
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvLeaveRoomNotice(roomId, userId, nickName, photoUrl, fansNum);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvLeaveRoomNotice() end, ImClient:%p roomId:%s userId:%s nickName:%s photoUrl:%s fansNum:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), fansNum);
    m_listenerListLock->Unlock();
}

// 3.8.接收关闭直播间倒数通知
void ZBImClient::OnZBRecvLeavingPublicRoomNotice(const string& roomId, int leftSeconds, ZBLCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvLeavingPublicRoomNotice() begin, ZBImClient:%p roomId:%s leftSeconds:%d err:%d errMsg:%s", this, roomId.c_str(), leftSeconds, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvLeavingPublicRoomNotice(roomId, leftSeconds, err, errMsg);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvLeavingPublicRoomNotice() end, ImClient:%p roomId:%s leftSeconds:%d err:%d errMsg:%s", this, roomId.c_str(), leftSeconds, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}

// 4.2.接收直播间文本消息通知
void ZBImClient::OnZBRecvSendChatNotice(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvSendChatNotice() begin, ZBImClient:%p roomId:%s level:%d fromId:%s nickName:%s msg:%s honorUrl:%s", this, roomId.c_str(), level, fromId.c_str(), nickName.c_str(), msg.c_str(), honorUrl.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvSendChatNotice(roomId, level, fromId, nickName, msg, honorUrl);
    }
    FileLog("ZBImClient", "ZBImClient::OnRecvSendChatNotice() end, ZBImClient:%p roomId:%s level:%d fromId:%s nickName:%s msg:%s honorUrl:%s", this, roomId.c_str(), level, fromId.c_str(), nickName.c_str(), msg.c_str(), honorUrl.c_str());
    m_listenerListLock->Unlock();
}

// 4.3.接收直播间公告消息回调
void ZBImClient::OnZBRecvSendSystemNotice(const string& roomId, const string& msg, const string& link, ZBIMSystemType type) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvSendSystemNotice() begin, ImClient:%p roomId:%s msg:%s link:%s type:%d", this, roomId.c_str(), msg.c_str(), link.c_str(), type);
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvSendSystemNotice(roomId, msg, link, type);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvSendSystemNotice() end, ZBImClient:%p roomId:%s msg:%s link:%s type:%d", this, roomId.c_str(), msg.c_str(), link.c_str(), type);
    m_listenerListLock->Unlock();
}

// 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
void ZBImClient::OnZBRecvSendGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId, const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id, const string& honorUrl, int totalCredit) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvSendGiftNotice() begin, ZBImClient:%p roomId:%s fromId:%s nickName:%s giftId:%s giftName:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d , multi_click_id:%d honorUrl:%s", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id, honorUrl.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvSendGiftNotice(roomId, fromId, nickName, giftId, giftName, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id, honorUrl, totalCredit);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvSendGiftNotice() end, ZBImClient:%p roomId:%s fromId:%s nickName:%s giftId:%s giftName:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d multi_click_id:%d honorUrl:%s", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id, honorUrl.c_str());
    m_listenerListLock->Unlock();
}

// 6.1.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
void ZBImClient::OnZBRecvSendToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg, const string& honorUrl) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvSendToastNotice() begin, ImClient:%p roomId:%s fromId:%s nickName:%s msg:%s honorUrl:%s", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), msg.c_str(), honorUrl.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvSendToastNotice(roomId, fromId, nickName, msg, honorUrl);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvSendToastNotice() end, ZBImClient:%p roomId:%s fromId:%s nickName:%s msg:%s honorUrl:%s", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), msg.c_str(), honorUrl.c_str());
    m_listenerListLock->Unlock();
}

// ------------- 直播间才艺点播邀请 -------------
/**
 *  7.1.接收直播间才艺点播邀请通知回调
 *
 *  @param talentRequestItem             才艺点播请求
 *
 */
void ZBImClient::OnZBRecvTalentRequestNotice(const ZBTalentRequestItem talentRequestItem) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvTalentRequestNotice() begin, ZBImClient:%p", this);
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvTalentRequestNotice(talentRequestItem);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvTalentRequestNotice() end, ZBImClient:%p", this);
    m_listenerListLock->Unlock();
}

// ------------- 直播间视频互动 -------------
/**
 *  8.1.接收观众启动/关闭视频互动通知回调
 *
 *  @param Item            互动切换
 *
 */
void ZBImClient::OnZBRecvControlManPushNotice(const ZBControlPushItem Item) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvControlManPushNotice() begin, ZBImClient:%p", this);
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvControlManPushNotice(Item);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvControlManPushNotice() end, ZBImClient:%p", this);
    m_listenerListLock->Unlock();
}

/**
 *  9.2.接收立即私密邀请回复通知 回调
 *
 *  @param inviteId      邀请ID
 *  @param replyType     主播回复 （0:拒绝 1:同意）
 *  @param roomId        直播间ID （可无，m_replyType ＝ 1存在）
 *
 */
void ZBImClient::OnZBRecvInstantInviteReplyNotice(const string& inviteId, ZBReplyType replyType ,const string& roomId, ZBRoomType roomType, const string& userId, const string& nickName, const string& avatarImg) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvInstantInviteReplyNotice() begin, ImClient:%p inviteId:%s replyType:%d roomId:%s", this, inviteId.c_str(), replyType, roomId.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvInstantInviteReplyNotice(inviteId, replyType, roomId, roomType, userId, nickName, avatarImg);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvInstantInviteReplyNotice() end, ImClient:%p inviteId:%s replyType:%d roomId:%s", this, inviteId.c_str(), replyType, roomId.c_str());
    m_listenerListLock->Unlock();
}
/**
 *  9.3.接收立即私密邀请通知 回调
 *
 *  @param userId           观众ID
 *  @param nickName         观众昵称
 *  @param photoUrl         观众头像url
 *  @param invitationId     邀请ID
 
 *
 */
void ZBImClient::OnZBRecvInstantInviteUserNotice(const string& userId, const string& nickName, const string& photoUrl ,const string& invitationId) {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvInstantInviteUserNotice() begin, ImClient:%p userId:%s nickName:%s photoUrl:%s invitationId:%s", this, userId.c_str(), nickName.c_str(), photoUrl.c_str(), invitationId.c_str());
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvInstantInviteUserNotice(userId, nickName, photoUrl, invitationId);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvInstantInviteUserNotice() end,  ImClient:%p userId:%s nickName:%s photoUrl:%s invitationId:%s", this, userId.c_str(), nickName.c_str(), photoUrl.c_str(), invitationId.c_str());
    m_listenerListLock->Unlock();
}


/**
 *  9.4.接收预约开始倒数通知 回调
 *
 *  @param roomId       直播间ID
 *  @param userId       对端ID
 *  @param nickName     对端昵称
 *  @param avatarImg    对端头像url
 *  @param leftSeconds  倒数时间（秒）
 *
 */
void ZBImClient::OnZBRecvBookingNotice(const string& roomId, const string& userId, const string& nickName, const string& avatarImg, int leftSeconds)
{
    FileLog("ZBImClient", "ZBImClient::OnZBRecvBookingNotice() begin, ImClient:%p roomId:%s userId:%s nickName:%s avatarImg:%s leftSeconds:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), avatarImg.c_str(), leftSeconds);
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvBookingNotice(roomId, userId, nickName, avatarImg, leftSeconds);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvBookingNotice() end,  ImClient:%p roomId:%s userId:%s nickName:%s avatarImg:%s leftSeconds:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), avatarImg.c_str(), leftSeconds);
    m_listenerListLock->Unlock();
}


/**
 *  9.6.接收观众接受预约通知接口 回调
 *
 *  @param userId           观众ID
 *  @param nickName         观众昵称
 *  @param photoUrl         观众头像url
 *  @param invitationId     预约ID
 *  @param bookTime         预约时间（1970年起的秒数）
 */
void ZBImClient::OnZBRecvInvitationAcceptNotice(const string& userId, const string& nickName, const string& photoUrl, const string& invitationId, long bookTime)  {
    FileLog("ZBImClient", "ZBImClient::OnZBRecvInvitationAcceptNotice() begin, ImClient:%p userId:%s nickName:%s photoUrl:%s invitationId:%s bookTime:%d", this, userId.c_str(), nickName.c_str(), photoUrl.c_str(), invitationId.c_str(), bookTime);
    m_listenerListLock->Lock();
    for (ZBImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IZBImClientListener* callback = *itr;
        callback->OnZBRecvInvitationAcceptNotice(userId, nickName, photoUrl, invitationId, bookTime);
    }
    FileLog("ZBImClient", "ZBImClient::OnZBRecvInvitationAcceptNotice() end, ImClient:%p userId:%s nickName:%s photoUrl:%s invitationId:%s bookTime:%d", this, userId.c_str(), nickName.c_str(), photoUrl.c_str(), invitationId.c_str(), bookTime);
    m_listenerListLock->Unlock();
}



