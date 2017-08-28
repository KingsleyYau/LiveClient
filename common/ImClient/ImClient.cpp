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

#include "FansRoomInTask.h"
#include "FansRoomOutTask.h"
#include "SendRoomMsgTask.h"
#include "GetRoomInfoTask.h"
#include "FansShutUpTask.h"
#include "FansKickOffRoomTask.h"
#include "SendRoomFavTask.h"
#include "SendRoomGiftTask.h"
#include "SendRoomToastTask.h"

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
    FileLog("ImClient", "ImClient::OnConnect() success: %d", success);
    if (success) {
        FileLog("ImClient", "ImClient::OnConnect() CheckVersionProc()");
        // 开始登录
        LoginProc();
        // 启动发送心跳包线程
        HearbeatThreadStart();
    }
    else {
        FileLog("ImClient", "ImClient::OnConnect() LCC_ERR_CONNECTFAIL, this:%p", this);
        this->OnLogin(LCC_ERR_CONNECTFAIL, "");
    }
    FileLog("ImClient", "ImClient::OnConnect() end");
}

// 连接失败回调(listUnsentTask：未发送的task列表)
void ImClient::OnDisconnect(const TaskList& listUnsentTask)
{
    TaskList::const_iterator iter;
    for (iter = listUnsentTask.begin();
         iter != listUnsentTask.end();
         iter++)
    {
        (*iter)->OnDisconnect();
    }
    
	// 停止心跳
	HearbearThreadStop();

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
bool ImClient::Login(const string& user, const string& password, ClientType clientType) {

	bool result = false;

	FileLog("ImClient", "ImClient::Login() begin");
    
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();

    if (LOGOUT == loginStatus) {
        // 先释放资源
        Logout();
        
        if (!user.empty()
            && !password.empty()
            && clientType >= CLIENTTYPE_BEGIN
            && clientType < CLIENTTYPE_END
            && ConnectServer())
        {
            m_user = user;
            m_password = password;
            m_clientType = clientType;
            
            m_loginStatusLock->Lock();
            m_loginStatus = LOGINING;
            //m_loginStatus =  LOGINED;
            m_loginStatusLock->Unlock();

            result = true;
        }
    }
    else {
        // 正在login或已login
        result = true;
    }

	FileLog("ImClient", "ImClient::Login() end");

	return result;
}

// 注销
bool ImClient::Logout()
{
	bool result = false;

	FileLog("ImClient", "ImClient::Logout() begin, m_taskManager:%p", m_taskManager);

	if (NULL != m_taskManager) {
		FileLog("ImClient", "ImClient::Logout() m_taskManager->StopAndWait(), m_taskManager:%p", m_taskManager);
		result = m_taskManager->StopAndWait();

		if (result) {
			m_user = "";
			m_password = "";
            m_clientType = CLIENTTYPE_UNKNOW;
		}
	}

	FileLog("ImClient", "ImClient::Logout() end");

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
        task->InitParam(IMCLIENT_VERSION, m_user, m_password, m_clientType);
        
        SEQ_T seq = m_seqCounter.GetAndIncrement();
        task->SetSeq(seq);
        result = m_taskManager->HandleRequestTask(task);
    }
    return result;
}

void ImClient::OnLogin(LCC_ERR_TYPE err, const string& errmsg)
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
            callback->OnLogin(err, errmsg);
        }
        m_listenerListLock->Unlock();
    }
}

void ImClient::OnKickOff(const string reason)
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
            callback->OnKickOff(reason);
        }
        m_listenerListLock->Unlock();
    }
}

// ------------------------ 注销函数 ------------------------------
void ImClient::OnLogout(LCC_ERR_TYPE err, const string& errmsg)
{
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
}

// --------- 直播间 ---------
// 观众进入直播间
bool ImClient::FansRoomIn(SEQ_T reqId, const string& token, const string& roomId) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
     FileLog("ImClient", "ImClient::FansRoomIn() begin, m_taskManager:%p token:%s roomId:%s", m_taskManager, token.c_str(), roomId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        FansRoomInTask* task = new FansRoomInTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(token, roomId);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        // 没有登录
        result = false;
    }
    FileLog("ImClient", "ImClient::FansRoomIn() end, m_taskManager:%p token:%s roomId:%s result:%d", m_taskManager, token.c_str(), roomId.c_str(), result);
    return result;
};

void ImClient::OnFansRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& userId, const string& nickName, const string& photoUrl, const string& country, const list<string>& videoUrls, int fansNum, int contribute, const RoomTopFanList& fans) {
    FileLog("ImClient", "ImClient::OnFansRoomIn begin, ImClient:%p reqId:%d success:%d err:%d errMsg:%s userId:%s nickName:%s photoUrl:%s country:%s fansNum%d contribute:%d", this, reqId, success, err, errMsg.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), country.c_str(), fansNum, contribute);
    m_listenerListLock->Lock();
    for(ImClientListenerList::const_iterator itr = m_listenerList.begin();
        itr != m_listenerList.end();
        itr++)
    {
        IImClientListener* callback = *itr;
        callback->OnFansRoomIn(reqId, success, err, errMsg, userId, nickName, photoUrl, country, videoUrls, fansNum, contribute, fans);
    }
        FileLog("ImClient", "ImClient::OnFansRoomIn end, ImClient:%p reqId:%d success:%d err:%d errMsg:%s userId:%s nickName:%s photoUrl:%s country:%s fansNum%d contribute:%d", this, reqId, success, err, errMsg.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str(), country.c_str(), fansNum, contribute);
    m_listenerListLock->Unlock();
}

// 观众退出直播间
bool ImClient::FansRoomOut(SEQ_T reqId, const string& token, const string& roomId) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::FansRoomOut() begin, m_taskManager:%p token:%s roomId:%s", m_taskManager, token.c_str(), roomId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        FansRoomOutTask* task = new FansRoomOutTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(token, roomId);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        // 没有登录
        result = false;
    }
    FileLog("ImClient", "ImClient::FansRoomOut() end, m_taskManager:%p token:%s roomId:%s result:%d", m_taskManager, token.c_str(), roomId.c_str(), result);
    return result;
};

void ImClient::OnFansRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ImClient", "ImClient::OnFansRoomOut() begin, ImClient:%p reqId:%d success:%d err:%d errMsg:%s", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnFansRoomOut(reqId, success, err, errMsg);
    }
    FileLog("ImClient", "ImClient::OnFansRoomOut() end, ImClient:%p reqId:%d success:%d err:%d errMsg:%s", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}


// 获取直播间信息
bool ImClient::GetRoomInfo(SEQ_T reqId, const string& token, const string& roomId) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::GetRoomInfo() begin, m_taskManager:%p token:%s roomId:%s", m_taskManager, token.c_str(), roomId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        GetRoomInfoTask* task = new GetRoomInfoTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(token, roomId);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::GetRoomInfo() end, m_taskManager:%p token:%s roomId:%s result:%d", m_taskManager, token.c_str(), roomId.c_str(), result);
    return result;
    
}

// 获取直播间信息
void ImClient::OnGetRoomInfo(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, int fansNum, int contribute) {
    FileLog("ImClient", "ImClient::OnGetRoomInfo() begin, ImClient:%p reqId:%d success:%d err:%d errMsg:%s fansNum:%d contribute:%d", this, reqId, success, err, errMsg.c_str(), fansNum, contribute);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnGetRoomInfo(reqId, success, err, errMsg, fansNum, contribute);
    }
    FileLog("ImClient", "ImClient::OnGetRoomInfo() end, ImClient:%p reqId:%d success:%d err:%d errMsg:%s fansNum:%d contribute:%d", this, reqId, success, err, errMsg.c_str(), fansNum, contribute);
    m_listenerListLock->Unlock();
}

// 3.7.主播禁言观众（直播端把制定观众禁言）
bool ImClient::FansShutUp(SEQ_T reqId, const string& roomId, const string& userId, int timeOut) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::FansShutUp() begin, m_taskManager:%p roomId:%s userId:%s timeOut:%d", m_taskManager, roomId.c_str(), userId.c_str(), timeOut);
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        FansShutUpTask* task = new FansShutUpTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId, userId, timeOut);

            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::FansShutUp() end, m_taskManager:%p roomId:%s userId:%s timeOut:%d result:%d", m_taskManager, roomId.c_str(), userId.c_str(), timeOut, result);
    return result;
}

 // 3.7.主播禁言观众（直播端把制定观众禁言）
void ImClient::OnFansShutUp(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ImClient", "ImClient::OnFansShutUp() begin, ImClient:%p reqId:%d success:%d err:%d errMsg:%s ", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnFansShutUp(reqId, success, err, errMsg);
    }
    FileLog("ImClient", "ImClient::OnFansShutUp() end, ImClient:%p reqId:%d success:%d err:%d errMsg:%s ", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}

// 3.9.主播踢观众出直播间（主播端把指定观众踢出直播间）
bool ImClient::FansKickOffRoom(SEQ_T reqId, const string& roomId, const string& userId) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::FansKickOffRoom() begin, m_taskManager:%p roomId:%s userId:%s", m_taskManager, roomId.c_str(), userId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        FansKickOffRoomTask* task = new FansKickOffRoomTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId, userId);

            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::FansKickOffRoom() end, m_taskManager:%p roomId:%s userId:%s result:%d", m_taskManager, roomId.c_str(), userId.c_str(), result);
    return result;
}
// 3.9.主播踢观众出直播间（主播端把指定观众踢出直播间）
void ImClient::OnFansKickOffRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ImClient", "ImClient::OnFansKickOffRoom() begin, ImClient:%p reqId:%d success:%d err:%d errMsg:%s ", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnFansKickOffRoom(reqId, success, err, errMsg);
    }
    FileLog("ImClient", "ImClient::OnFansKickOffRoom() end, ImClient:%p reqId:%d success:%d err:%d errMsg:%s ", this, reqId, success, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}

// --------- 直播间文本消息 ---------
// 发送直播间文本消息
bool ImClient::SendRoomMsg(SEQ_T reqId, const string& token, const string& roomId, const string& nickName, const string& msg) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendRoomMsg() begin, m_taskManager:%p token:%s roomId:%s nickName:%s msg:%s", m_taskManager, token.c_str(), roomId.c_str(), nickName.c_str(), msg.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        SendRoomMsgTask* task = new SendRoomMsgTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId, token, nickName, msg);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendRoomMsg() end, m_taskManager:%p token:%s roomId:%s nickName:%s msg:%s result:%d", m_taskManager, token.c_str(), roomId.c_str(), nickName.c_str(), msg.c_str(), result);
    return result;
};

void ImClient::OnSendRoomMsg(SEQ_T reqId, LCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ImClient", "ImClient::OnSendRoomMsg() begin, ImClient:%p reqId:%d err:%d errMsg:%s", this, reqId, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendRoomMsg(reqId, err, errMsg);
    }
    FileLog("ImClient", "ImClient::OnSendRoomMsg() end, ImClient:%p reqId:%d err:%d errMsg:%s", this, reqId, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}

// ------------- 直播间点赞 -------------
// 5.1.发送直播间点赞消息（观众端向直播间发送点赞消息）
bool ImClient::SendRoomFav(SEQ_T reqId, const string& roomId, const string& token, const string& nickName) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendRoomFav() begin, m_taskManager:%p token:%s roomId:%s", m_taskManager, token.c_str(), roomId.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
    SendRoomFavTask* task = new SendRoomFavTask();
    if (NULL != task) {
        task->Init(this);
        task->InitParam(roomId, token, nickName);
        
        task->SetSeq(reqId);
        result = m_taskManager->HandleRequestTask(task);
    }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendRoomFav() end, m_taskManager:%p token:%s roomId:%s result:%d", m_taskManager, token.c_str(), roomId.c_str(), result);
    return result;
}
// 5.1.发送直播间点赞消息（观众端向直播间发送点赞消息）
void ImClient::OnSendRoomFav(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {
    FileLog("ImClient", "ImClient::OnSendRoomFav() begin, ImClient:%p reqId:%d err:%d errMsg:%s", this, reqId, err, errMsg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendRoomFav(reqId, success, err, errMsg);
    }
    FileLog("ImClient", "ImClient::OnSendRoomFav() end, ImClient:%p reqId:%d err:%d errMsg:%s", this, reqId, err, errMsg.c_str());
    m_listenerListLock->Unlock();
}

// ------------- 直播间点赞 -------------
// 6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
bool ImClient::SendRoomGift(SEQ_T reqId, const string& roomId, const string& token, const string& nickName, const string& giftId, const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendRoomGift() begin, m_taskManager:%p token:%s roomId:%s nickName:%s giftId:%s giftName:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d multi_click_id;%d", m_taskManager, token.c_str(), roomId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        SendRoomGiftTask* task = new SendRoomGiftTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId, token, nickName, giftId, giftName, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);

            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendRoomGift() end, m_taskManager:%p token:%s roomId:%s nickName:%s giftId:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d result:%d", m_taskManager, token.c_str(), roomId.c_str(), nickName.c_str(), giftId.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, result);
    return result;
}

// 6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
void ImClient::OnSendRoomGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double coins, int multi_click_id) {
    FileLog("ImClient", "ImClient::OnSendRoomGift() begin, ImClient:%p reqId:%d err:%d errMsg:%s coins:%f, multi_click_id:%d", this, reqId, err, errMsg.c_str(), coins, multi_click_id);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendRoomGift(reqId, success, err, errMsg, coins, multi_click_id);
    }
    FileLog("ImClient", "ImClient::OnSendRoomGift() end, ImClient:%p reqId:%d err:%d errMsg:%s coins:%f, multi_click_id:%d", this, reqId, err, errMsg.c_str(), coins, multi_click_id);
   
    m_listenerListLock->Unlock();
}

// ------------- 直播间弹幕消息 -------------
// 7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
bool ImClient::SendRoomToast(SEQ_T reqId, const string& roomId, const string& token, const string& nickName, const string& msg) {
    bool result = false;
    m_loginStatusLock->Lock();
    LoginStatus loginStatus = m_loginStatus;
    m_loginStatusLock->Unlock();
    FileLog("ImClient", "ImClient::SendRoomToast() begin, m_taskManager:%p token:%s roomId:%s nickName:%s msg:%s", m_taskManager, token.c_str(), roomId.c_str(), nickName.c_str(), msg.c_str());
    // 若为已登录状态
    if (LOGINED == loginStatus) {
        SendRoomToastTask* task = new SendRoomToastTask();
        if (NULL != task) {
            task->Init(this);
            task->InitParam(roomId, token, nickName, msg);
            
            task->SetSeq(reqId);
            result = m_taskManager->HandleRequestTask(task);
        }
    }
    else
    {
        result = false;
    }
    FileLog("ImClient", "ImClient::SendRoomToast() end, m_taskManager:%p token:%s roomId:%s nickName:%s msg:%s result:%d", m_taskManager, token.c_str(), roomId.c_str(), nickName.c_str(), msg.c_str(), result);
    return result;
}
// 7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
void ImClient::OnSendRoomToast(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double coins) {
    FileLog("ImClient", "ImClient::OnSendRoomToast() begin, ImClient:%p reqId:%d err:%d errMsg:%s coins:%f", this, reqId, err, errMsg.c_str(), coins);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnSendRoomToast(reqId, success,err, errMsg, coins);
    }
    FileLog("ImClient", "ImClient::OnSendRoomToast() end, ImClient:%p reqId:%d err:%d errMsg:%s coins:%f", this, reqId, err, errMsg.c_str(), coins);
    
    m_listenerListLock->Unlock();
}

// 服务端主动请求
// 接收直播间关闭通知(观众)
void ImClient::OnRecvRoomCloseFans(const string& roomId, const string& userId, const string& nickName, int fansNum) {
    FileLog("ImClient", "ImClient::OnRecvCloseFans() begin, ImClient:%p roomId:%s userId:%s nickName:%s fansNum:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), fansNum);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvRoomCloseFans(roomId, userId, nickName, fansNum);
    }
    FileLog("ImClient", "ImClient::OnRecvCloseFans() end, ImClient:%p roomId:%s userId:%s nickName:%s fansNum:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), fansNum);
    m_listenerListLock->Unlock();
    
}
// 接收直播间关闭通知(直播)
void ImClient::OnRecvRoomCloseBroad(const string& roomId, int fansNum, int inCome, int newFans, int shares, int duration) {
    FileLog("ImClient", "ImClient::OnRecvRoomCloseBrod() begin, ImClient:%p roomId:%s fansNum:%d inCome:%d newFans:%d shares:%d duration:%d", this, roomId.c_str(), fansNum, inCome, newFans, shares, duration);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end(); itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvRoomCloseBroad(roomId, fansNum, inCome, newFans, shares, duration);
    }
    FileLog("ImClient", "ImClient::OnRecvRoomCloseBroad() end, ImClient:%p roomId:%s fansNum:%d inCome:%d newFans:%d shares:%d duration:%d", this, roomId.c_str(), fansNum, inCome, newFans, shares, duration);
    m_listenerListLock->Unlock();
}
// 接收观众进入直播间通知
void ImClient::OnRecvFansRoomIn(const string& roomId, const string& userId, const string& nickName, const string& photoUrl) {
    FileLog("ImClient", "ImClient::OnRecvFansRoomIn() begin, ImClient:%p roomId:%s userId:%s nickName:%s photoUrl:%s", this, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvFansRoomIn(roomId, userId, nickName, photoUrl);
    }
    FileLog("ImClient", "ImClient::OnRecvFansRoomIn() end, ImClient:%p roomId:%s userId:%s nickName:%s photoUrl:%s", this, roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str());
    m_listenerListLock->Unlock();
}
// 3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）
void ImClient::OnRecvShutUpNotice(const string& roomId, const string& userId, const string& nickName, int timeOut) {
    FileLog("ImClient", "ImClient::OnRecvShutUpNotice() begin, ImClient:%p roomId:%s userId:%s nickName:%s timeOut:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), timeOut);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvShutUpNotice(roomId, userId, nickName, timeOut);
    }
    FileLog("ImClient", "ImClient::OnRecvShutUpNotice() end, ImClient:%p roomId:%s userId:%s nickName:%s timeOut:%d", this, roomId.c_str(), userId.c_str(), nickName.c_str(), timeOut);
    m_listenerListLock->Unlock();
}
// 3.10.接收观众踢出直播间通知（观众端／主播端接收观众踢出直播间通知）
void ImClient::OnRecvKickOffRoomNotice(const string& roomId, const string& userId, const string& nickName) {
    FileLog("ImClient", "ImClient::OnRecvKickOffNoticeRoom() begin, ImClient:%p roomId;%s userId:%s nickName:%s ", this, roomId.c_str(), userId.c_str(), nickName.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvKickOffRoomNotice(roomId, userId, nickName);
    }
    FileLog("ImClient", "ImClient::OnRecvKickOffNoticeRoom() end, ImClient:%p roomId;%s userId:%s nickName:%s ", this, roomId.c_str(), userId.c_str(), nickName.c_str());
    m_listenerListLock->Unlock();
}


// 接收直播间文本消息通知
void ImClient::OnRecvRoomMsg(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg) {
    FileLog("ImClient", "ImClient::OnRecvRoomMsg() begin, ImClient:%p roomId:%s level:%d fromId:%s nickName:%s msg:%s", this, roomId.c_str(), level, fromId.c_str(), nickName.c_str(), msg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvRoomMsg(roomId, level, fromId, nickName, msg);
    }
    FileLog("ImClient", "ImClient::OnRecvRoomMsg() end, ImClient:%p roomId:%s level:%d fromId:%s nickName:%s msg:%s", this, roomId.c_str(), level, fromId.c_str(), nickName.c_str(), msg.c_str());
    m_listenerListLock->Unlock();
}

// 5.2.接收直播间点赞通知（观众端／主播端接收服务器的直播间点赞通知）
void ImClient::OnRecvPushRoomFav(const string& roomId, const string& fromId, const string& nickName, bool isFirst) {
    FileLog("ImClient", "ImClient::OnRecvPushRoomFav() begin, ImClient:%p roomId:%s fromId:%s nickName: %s isFirst: %d", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), isFirst?1:0);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvPushRoomFav(roomId, fromId, nickName, isFirst);
    }
    FileLog("ImClient", "ImClient::OnRecvPushRoomFav() end, ImClient:%p roomId:%s ImClient::fromId:%s", this, roomId.c_str(), fromId.c_str());
    m_listenerListLock->Unlock();
}

// 6.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
void ImClient::OnRecvRoomGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId, const string& giftName, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) {
    FileLog("ImClient", "ImClient::OnRecvRoomGiftNotice() begin, ImClient:%p roomId:%s fromId:%s nickName:%s giftId:%s giftName:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d , multi_click_id:%d", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvRoomGiftNotice(roomId, fromId, nickName, giftId, giftName, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
    }
    FileLog("ImClient", "ImClient::OnRecvRoomGiftNotice() end, ImClient:%p roomId:%s fromId:%s nickName:%s giftId:%s giftName:%s giftNum:%d multi_click:%d multi_click_start:%d multi_click_end:%d multi_click_id:%d", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), giftId.c_str(), giftName.c_str(), giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
    m_listenerListLock->Unlock();
}

// 7.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
void ImClient::OnRecvRoomToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg) {
    FileLog("ImClient", "ImClient::OnRecvRoomToastNotice() begin, ImClient:%p roomId:%s fromId:%s nickName:%s msg:%s", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), msg.c_str());
    m_listenerListLock->Lock();
    for (ImClientListenerList::const_iterator itr = m_listenerList.begin();
         itr != m_listenerList.end();
         itr++) {
        IImClientListener* callback = *itr;
        callback->OnRecvRoomToastNotice(roomId, fromId, nickName, msg);
    }
    FileLog("ImClient", "ImClient::OnRecvRoomToastNotice() end, ImClient:%p roomId:%s fromId:%s nickName:%s msg:%s", this, roomId.c_str(), fromId.c_str(), nickName.c_str(), msg.c_str());
    m_listenerListLock->Unlock();
}
