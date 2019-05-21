
/*
 * author: Alex.Shum
 *   date: 2018-6-13
 *   file: LiveMessageManManager.cpp
 *   desc: 直播信息男士Manager实现类
 */

#include "LiveMessageManManager.h"


// 用户管理器
#include "LMUserManager.h"

#include "LMPrivateContactManager.h"
#include <common/IAutoLock.h>

static const int s_msgIdBegin = 1;        // 消息ID起始值
static const int s_requestIdBegin = 1;    // http请求ID起始值


// 定时业务类型
typedef enum {
    REQUEST_TASK_Unknow = 0,                         // 未知请求类型
    REQUEST_TASK_GetPrivateMsg = 1,                 // 获取个人私信
    REQUEST_TASK_SendMsg = 2,                       // 发送消息
} REQUEST_TASK_TYPE;

// 定时业务结构体
class RequestItem
{
public:
    RequestItem()
    {
        requestType = REQUEST_TASK_Unknow;
        param = 0;
    }

    RequestItem(const RequestItem& item)
    {
        requestType = item.requestType;
        param = item.param;
    }

    ~RequestItem(){};

    REQUEST_TASK_TYPE requestType;
    unsigned long long param;
};

LiveMessageManManager::LiveMessageManManager()
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LiveMessageManManager() begin");
    m_msgIdBuilder.Init(s_msgIdBegin);
    
    m_requestIdBuilder.Init(s_requestIdBegin);

    // LiveChat客户端
    m_client = NULL;
//    m_client = IImClient::CreateClient();
//    m_client->AddListener(this);
    
    m_userId = "";
    m_contactRequstStatus = LMRequstHandleType_Unknow;

    // 用户管理器
    m_userMgr = new LMUserManager;            // 用户管理器
    m_contactMgr = new LMPrivateContactManager;    // 联系人管理器
    // 初始化私信联系人管理器
    m_contactMgr->Init(m_userMgr);

    // 请求线程
    m_requestThread = NULL;
    m_requestThreadStart = false;
    m_requestQueueLock = IAutoLock::CreateAutoLock();
    m_requestQueueLock->Init();
    // 请求管理器及控制器
    //m_RequestPrivateMsgController = NULL;
    
    m_RequestPrivateMsgController = new HttpRequestPrivateMsgController(this);
    
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LiveMessageManManager() end");
}

LiveMessageManManager::~LiveMessageManManager()
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::~LiveMessageManManager() begin");
    // 停止所有请求
    StopRequestThread();
    IAutoLock::ReleaseAutoLock(m_requestQueueLock);

    m_contactRequstStatus = LMRequstHandleType_Unknow;

//    // 去除回调 (防止imclient已经delede)
//    if( m_client ) {
//        m_client->RemoveListener(this);
//    }

//    // 释放连接
//    ILiveChatClient::ReleaseClient(m_client);

    if (m_userMgr) {
         delete m_userMgr;
        m_userMgr = NULL;
    }
   
    if (m_contactMgr) {
        delete m_contactMgr;
        m_contactMgr = NULL;
    }
    
    if (m_RequestPrivateMsgController) {
        delete m_RequestPrivateMsgController;
        m_RequestPrivateMsgController = NULL;
    }

    m_userId = "";

     FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::~LiveMessageManManager() end");
}

// 清除历史记录
void LiveMessageManManager::CleanHistory() {
    if (m_userMgr) {
        m_userMgr->RemoveAllUserItem();
        m_userMgr->ResetParam();
    }
    
    if (m_contactMgr) {
        m_contactMgr->RemoveAllUserItem();
    }
}

// -------- 初始化 begin -------------------------------------------------
bool LiveMessageManManager::InitUserInfo(string userId, PrivateSupportTypeList supportList, const string& privateNotice) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::InitUserInfo( userId : %s, supportList.size():%d privateNotice:%s) begin", userId.c_str(), supportList.size(), privateNotice.c_str());
    bool result = false;
    
    if (userId.length() > 0 && m_userId.length() > 0 && userId != m_userId) {
        CleanHistory();
    }
    
    LMUserItem::SetPrivateNotice(privateNotice);
    LiveMessageItem::SetSupportMsgTypeList(supportList);
    if (userId.length() > 0) {
        m_userId = userId;
        // 启动请求队列处理线程
        result = StartRequestThread();
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::InitUserInfo( userId : %s result:%d) end", userId.c_str(), result);
    return result;
}

// 获取用户ID
string LiveMessageManManager::GetUserId() {
    return m_userId;
}

// 初始化
bool LiveMessageManManager::Init(IImClient* client,
                                 const IHttpRequestPrivateMsgControllerHandler& requestListener,
                                 ILiveMessageManManagerListener* listener)
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::Init( client : %p, requestListener: %p, listener:%p ) begin", client, &requestListener, listener);
    bool result = false;
    
    if (NULL != client) {
        if (m_RequestPrivateMsgController != NULL) {
            m_RequestPrivateMsgController->SetRequestHandler(requestListener);
        }
//        m_RequestPrivateMsgController = NULL;
//        m_RequestPrivateMsgController = new HttpRequestPrivateMsgController(requestListener, this);
        m_client = client;
        if (m_client != NULL) {
            m_client->AddListener(this);
        }
        m_listener = listener;
        
        
        
        result = true;
    }
    
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::Init( client : %p, listener:%p, result:%d ) end", client, listener, result);
    
    return result;
}

bool LiveMessageManManager::CheckIMClientRelease(IImClient* client)
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::CheckIMClientRelease( client : %p) begin", client);
    bool result = false;
    
    if (NULL != client && NULL != m_client && client == m_client) {
        // 去除回调, 用在~LiveMessageManManager()时
         m_client->RemoveListener(this);
        result = true;
    }
    
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::CheckIMClientRelease( client : %p) end", client);
    
    return result;
}

/******************************************* 定时任务处理 *******************************************/
// 请求线程启动
bool LiveMessageManManager::StartRequestThread()
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::StartRequestThread() begin");
    bool result = false;
    
    // 停止之前的请求线程
    StopRequestThread();
    
    // 启动线程
    m_requestThread = IThreadHandler::CreateThreadHandler();
    if (NULL != m_requestThread)
    {
        m_requestThreadStart = true;
        result = m_requestThread->Start(LiveMessageManManager::RequestThread, this);
        
        if (!result) {
            m_requestThreadStart = false;
        }
    }
    
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::StartRequestThread(m_requestThreadStart:%d m_requestThread:%p) end", m_requestThreadStart, m_requestThread);
    return result;
}

// 请求线程结束
void LiveMessageManManager::StopRequestThread()
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::StopRequestThread(m_requestThreadStart:%d m_requestThread:%p) begin", m_requestThreadStart, m_requestThread);
    if (NULL != m_requestThread)
    {
        m_requestThreadStart = false;
        m_requestThread->WaitAndStop();
        IThreadHandler::ReleaseThreadHandler(m_requestThread);
        m_requestThread = NULL;
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::StopRequestThread(m_requestThreadStart:%d m_requestThread:%p) end", m_requestThreadStart, m_requestThread);
}

// 请求线程函数
TH_RETURN_PARAM LiveMessageManManager::RequestThread(void* obj)
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RequestThread() begin");
    LiveMessageManManager* pThis = (LiveMessageManManager*)obj;
    pThis->RequestThreadProc();
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RequestThread() end");
    return 0;
}

// 请求线程处理函数
void LiveMessageManManager::RequestThreadProc()
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RequestThreadProc(m_requestThreadStart:%d) begin", m_requestThreadStart);
    while (m_requestThreadStart)
    {
        TaskItem* item = PopRequestTask();
        if ( item )
        {
            if (getCurrentTime() >= item->delayTime)
            {
                RequestItem* param = (RequestItem *)item->param;
                RequestHandler(param);
                delete item;
            }
            else
            {
                // 任务时间未到
                PushRequestTask(item);
                Sleep(50);
            }
        }
        else
        {
            // 请求队列为空
            Sleep(50);
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RequestThreadProc(m_requestThreadStart:%d) end", m_requestThreadStart);
}

// 插入任务到处理队列
void LiveMessageManManager::InsertRequestTask(TaskParam param, long long delayTime) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::InsertRequestTask(m_requestThreadStart:%d requestType:%d) begin", m_requestThreadStart, ((RequestItem *)param)->requestType);
    TaskItem* taskItem = new (TaskItem);
    taskItem->param = param;
    if (delayTime > 0) {
        taskItem->delayTime = getCurrentTime() + delayTime;
    }
    PushRequestTask(taskItem);
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::InsertRequestTask(m_requestThreadStart:%d requestType:%d) end", m_requestThreadStart, ((RequestItem *)taskItem->param)->requestType);
}

// 判断请求队列是否为空
bool LiveMessageManManager::IsRequestQueueEmpty()
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::IsRequestQueueEmpty(m_requestThreadStart:%d) begin", m_requestThreadStart);
    bool result = false;
    // 加锁
    if (NULL != m_requestQueueLock) {
        m_requestQueueLock->Lock();
    }
    
    // 处理
    result = m_requestQueue.empty();
    
    // 解锁
    if (NULL != m_requestQueueLock) {
        m_requestQueueLock->Unlock();
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::IsRequestQueueEmpty(m_requestThreadStart:%d) end", m_requestThreadStart);
    return result;
}

// 弹出请求队列第一个item
LiveMessageManManager::TaskItem* LiveMessageManManager::PopRequestTask()
{
    // FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::PopRequestTask(m_requestThreadStart:%d m_requestQueue.size():%d) begin", m_requestThreadStart, m_requestQueue.size());
    TaskItem* item = NULL;
    
    // 加锁
    if (NULL != m_requestQueueLock) {
        m_requestQueueLock->Lock();
    }
    
    // 处理
    if (!m_requestQueue.empty())
    {
        item = m_requestQueue.front();
        m_requestQueue.pop_front();
    }
    
    // 解锁
    if (NULL != m_requestQueueLock) {
        m_requestQueueLock->Unlock();
    }
    //FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::PopRequestTask(m_requestThreadStart:%d m_requestQueue.size():%d) end", m_requestThreadStart, m_requestQueue.size());
    return item;
}

// 插入请求队列
bool LiveMessageManManager::PushRequestTask(TaskItem* item)
{
    //RequestItem* param = (RequestItem *)item->param;
   // FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::PushRequestTask(m_requestThreadStart:%d m_requestQueue.size():%d requestType:%d) begin", m_requestThreadStart, m_requestQueue.size(), ((RequestItem *)item->param)->requestType);
    bool result = false;
    
    // 加锁
    if (NULL != m_requestQueueLock) {
        m_requestQueueLock->Lock();
    }
    
    // 处理
    if( item ) {
        m_requestQueue.push_back(item);
        result = true;
    }
    
    // 解锁
    if (NULL != m_requestQueueLock) {
        m_requestQueueLock->Unlock();
    }
    //FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::PushRequestTask(m_requestThreadStart:%d m_requestQueue.size():%d) end", m_requestThreadStart, m_requestQueue.size());
    
    return result;
}

// 清空请求队列
void LiveMessageManManager::CleanRequestTask()
{
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::CleanRequestTask(m_requestThreadStart:%d m_requestQueue.size():%d) begin", m_requestThreadStart, m_requestQueue.size());
    // 加锁
    if (NULL != m_requestQueueLock) {
        m_requestQueueLock->Lock();
    }
    
    // 处理
    TaskItem* item = NULL;
    while( (item = m_requestQueue.front()) ) {
        m_requestQueue.pop_front();
        
        delete item;
    }
    
    m_requestQueue.clear();
    
    // 解锁
    if (NULL != m_requestQueueLock) {
        m_requestQueueLock->Unlock();
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::CleanRequestTask(m_requestThreadStart:%d m_requestQueue.size():%d) end", m_requestThreadStart, m_requestQueue.size());
}

void LiveMessageManManager::RequestHandler(RequestItem* item) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RequestHandler(requestType:%d) begin", item->requestType);
    switch (item->requestType)
    {
        case REQUEST_TASK_Unknow:break;
        case REQUEST_TASK_GetPrivateMsg:
        {
            LMUserItem* userItem = (LMUserItem*)item->param;
            if (NULL != userItem) {
                // 请求用户私信
                RequestPrivateMsgList(userItem);
            }
            
        }
            break;
        case REQUEST_TASK_SendMsg:
        {
            LMUserItem* userItem = (LMUserItem*)item->param;
            if (NULL != userItem) {
                // 发送私信列表
                SendPrviateMsgProc(userItem);
            }
        }
            break;
            
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RequestHandler(requestType:%d) end", item->requestType);
}
///******************************************* 定时任务处理 End *******************************************/


// ---------- 私信联系人列表操作 公开操作 begin----------
// 获取私信联系人列表（同步返回）
LMUserList LiveMessageManManager::GetLocalPrivateMsgFriendList() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetLocalPrivateMsgFriendList() begin");
    LMUserList friendList;
    friendList = LMGetLocalPrivateMsgFriendList();
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetLocalPrivateMsgFriendList(friendList.size:%d) end", friendList.size());
    return friendList;
}
// 获取私信联系人列表（异步返回）
long long LiveMessageManManager::GetPrivateMsgFriendList() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetPrivateMsgFriendList() begin");
    long long taskId = -1;
    taskId = LMGetPrivateMsgFriendList();
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetPrivateMsgFriendList() end");
    return taskId;
}

// 获取本地私信Follow联系人列表（同步返回）
LMUserList LiveMessageManManager::GetLocalFollowPrivateMsgFriendList() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetLocalFollowPrivateMsgFriendList() begin");
    LMUserList friendList;
    friendList = LMGetLocalFollowPrivateMsgFriendList();
    
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetLocalFollowPrivateMsgFriendList(friendList.size:%d) end", friendList.size());
    return friendList;
}
// 获取私信Follow联系人列表（异步返回）
long long LiveMessageManManager::GetFollowPrivateMsgFriendList() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetFollowPrivateMsgFriendList() begin");
    long long taskId = -1;
    taskId = LMGetFollowPrivateMsgFriendList();
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetFollowPrivateMsgFriendList() end");
    return taskId;
}

// ---------- 私信联系人列表操作 公开操作 end----------

// ---------- 用户私信列表公开操作 begin -------------
// 增加私信在聊列表(用于断网后，重连成功后获取在聊列表用户的最新消息，解决断网后，重连没有最新消息，要自己发送或接收后马上生成一片数据)
bool LiveMessageManManager::AddPrivateMsgLiveChat(const string& userId) {
    bool result = false;
    bool isHas = false;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::AddPrivateMsgLiveChat(m_liveChatList.size():%d userId:%s) begin", m_liveChatList.size(), userId.c_str());
    if (userId.length() > 0) {
        for (LMLiveChatList::const_iterator iter = m_liveChatList.begin(); iter != m_liveChatList.end(); iter++) {
            if ((*iter) == userId) {
                isHas = true;
                break;
            }
        }
        // 在聊列表没有就添加
        if (!isHas) {
            m_liveChatList.push_back(userId);
            result = true;
        }
    }
    
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::AddPrivateMsgLiveChat(m_liveChatList.size():%d  userId:%s result:%d) end", m_liveChatList.size(), userId.c_str(), result);
    return result;
}
// 删除私信在聊列表
bool LiveMessageManManager::RemovePrivateMsgLiveChat(const string& userId) {
    bool result = false;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RemovePrivateMsgLiveChat(m_liveChatList.size():%d userId:%s) begin", m_liveChatList.size(), userId.c_str());
    if (userId.length() > 0) {
        for (LMLiveChatList::const_iterator iter = m_liveChatList.begin(); iter != m_liveChatList.end(); ) {
            LMLiveChatList::const_iterator iter_e = iter++;
            string LMuserId = (*iter_e);
            if (LMuserId == userId) {
                result = true;
                m_liveChatList.remove(LMuserId);
                break;
            }
        }
    }
    
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RemovePrivateMsgLiveChat(m_liveChatList.size():%d  userId:%s result:%d) end", m_liveChatList.size(), userId.c_str(), result);
    return result;
}

// 获取指定用户Id的用户的本地消息(直接返回本地消息列表（深拷贝？防止消息被修改）， 不需要向服务器请求的)
LMMessageList LiveMessageManManager::GetLocalPrivateMsgWithUserId(const string& userId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetLocalPrivateMsgWithUserId(userId:%s) begin", userId.c_str());
    LMMessageList msgList;
    if (NULL != m_userMgr && NULL != m_contactMgr) {
        // 获取接收用户item
        LMUserItem* userItem = m_contactMgr->GetUser(userId);
        if (NULL != userItem) {
            msgList = userItem->GetMsgList();
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetLocalPrivateMsgWithUserId(userId:%s, msgList.size:%d) end", userId.c_str(), msgList.size());
    return msgList;
}
// 刷新指定用户Id的用户的私信消息（不能直接返回的，需要考虑刷新消息标记）， 之后才返回并合后的本地数据或错误信息
int LiveMessageManManager::RefreshPrivateMsgWithUserId(const string& userId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RefreshPrivateMsgWithUserId(userId:%s) begin", userId.c_str());

    //result = LMGetPrivateMessageHistoryById(userId);
    
    int reqId = REQUEST_INVALIDREQUESTID;
    if (NULL != m_userMgr && NULL != m_contactMgr) {
        // 获取接收用户item
        LMUserItem* userItem = m_contactMgr->GetUser(userId);
        if (NULL != userItem) {
            reqId = m_requestIdBuilder.GetAndIncrement();
            bool result = userItem->AddRequestMap(reqId, LMMessageListType_Refresh);
            if (result) {
                RequestItem* requestItem = new RequestItem();
                requestItem->requestType = REQUEST_TASK_GetPrivateMsg;
                requestItem->param = (TaskParam)userItem;
                InsertRequestTask((TaskParam)requestItem);
            } else {
                // 请求列表中已经有了这个请求了，就返回-1，上层不要等回调了
                reqId = REQUEST_INVALIDREQUESTID;
            }
            
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RefreshPrivateMsgWithUserId(userId:%s, reqId:%d) end", userId.c_str(), reqId);
    return reqId;
}
// 获取指定用户Id的用户更多私信消息（不能直接返回的，需要考虑刷新消息标记和是否有本地数据）
int LiveMessageManManager::GetMorePrivateMsgWithUserId(const string& userId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetMorePrivateMsgWithUserId(userId:%s) begin", userId.c_str());
    int reqId = REQUEST_INVALIDREQUESTID;
    if (NULL != m_userMgr && NULL != m_contactMgr) {
        // 获取接收用户item
        LMUserItem* userItem = m_contactMgr->GetUser(userId);
        if (NULL != userItem) {
            reqId = m_requestIdBuilder.GetAndIncrement();
            bool result = userItem->AddRequestMap(reqId, LMMessageListType_More);
            if (result) {
                RequestItem* requestItem = new RequestItem();
                requestItem->requestType = REQUEST_TASK_GetPrivateMsg;
                requestItem->param = (TaskParam)userItem;
                InsertRequestTask((TaskParam)requestItem);
            }else {
                // 请求列表中已经有了这个请求了，就返回-1，上层不要等回调了
                reqId = REQUEST_INVALIDREQUESTID;
            }

        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::GetMorePrivateMsgWithUserId(userId:%s, msgList.size:%d reqId:%d) end", userId.c_str(), reqId);
    return reqId;
}

long long LiveMessageManManager::SetPrivateMsgReaded(const string& userId) {
    long long taskId = -1;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::SetPrivateMsgReaded(userId:%s) begin", userId.c_str());
    taskId = LMSetPrivateMsgReaded(userId);
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::SetPrivateMsgReaded(userId:%s, ) end", userId.c_str());
    return taskId;
}

// 发送私信消息，返回是要发送的消息（是否成功是看回调）
bool LiveMessageManManager::SendPrivateMessage(const string& userId, const string& message) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::SendPrivateMessage(userId:%s message:%s) begin", userId.c_str(), message.c_str());
    bool result = false;
    bool sendFail = false;
    LiveMessageItem* sendItem = NULL;
    LMMessageList msgList;
    if (NULL != m_userMgr && NULL != m_contactMgr) {
        // 获取接收用户item
        LMUserItem* userItem = m_contactMgr->GetUser(userId);
        if (NULL != userItem) {
            userItem->Lock();
            msgList = userItem->GetSendPrivateMsg(m_userId, message, -1);
            if (msgList.size() > 0) {
                // 设置本地唯一标识ID
                for (LMMessageList::const_iterator iter = msgList.begin(); iter != msgList.end(); iter++) {
                    (*iter)->SetSendMsgId(m_msgIdBuilder.GetAndIncrement());
                    if ((*iter)->IsLiveChatPrivateMsgType()) {
                        sendItem = (*iter);
                    }
                }
                sendFail = HandleSendingMsg(userItem, sendItem);
//                userItem->LockSendMsgList();
//                if (!userItem->m_refreshMark) {
//                    if (userItem->m_sendMsgList.size() <= 0) {
//                        if (sendItem != NULL) {
//                            sendFail = !(LMSendPrivateMessage(userItem->m_userId, (sendItem->GetPrivateMsgItem())->m_message, sendItem->m_sendMsgId));
//                            if (sendFail) {
//                                sendItem->m_sendErr = LCC_ERR_CONNECTFAIL;
//                                sendItem->SetSendPrivateHandleStatus(LMStatusType_Fail);
//                            }
//                        }
//
//                    } else {
//                        userItem->InsertSendingList(sendItem);
//                        RequestItem* requestItem = new RequestItem();
//                        requestItem->requestType = REQUEST_TASK_SendMsg;
//                        requestItem->param = (TaskParam)userItem;
//                        InsertRequestTask((TaskParam)requestItem);
//                    }
//                } else {
//                    bool isFlag = userItem->AddRequestMap(m_requestIdBuilder.GetAndIncrement(), LMMessageListType_Update);
//                    if (isFlag) {
//                        RequestItem* requestItem = new RequestItem();
//                        requestItem->requestType = REQUEST_TASK_GetPrivateMsg;
//                        requestItem->param = (TaskParam)userItem;
//                        InsertRequestTask((TaskParam)requestItem);
//                    }
//                }
//
//                userItem->UnlockSendMsgList();
            }
           userItem->Unlock();
        }
        result = true;
    }
    if (m_listener && result) {
        m_listener->OnLMUpdatePrivateMsgWithUserId(userId, msgList);
        m_listener->OnUpdateFriendListNotice(true, 0, "");
        if (sendFail) {
            m_listener->OnLMSendPrivateMessage(userId, false, LCC_ERR_CONNECTFAIL, "", sendItem);
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::SendPrivateMessage(userId:%s message:%s) end", userId.c_str(), message.c_str());
    return result;
}

// 重发私信消息
bool LiveMessageManManager::RepeatSendPrivateMsg(const string& userId, int sendMsgId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RepeatSendPrivateMsg(userId:%s sendMsgId:%d) begin", userId.c_str(), sendMsgId);
    bool result = false;
    bool sendFail = false;
    LiveMessageItem* sendItem = NULL;
    LMMessageList msgList;
    if (NULL != m_userMgr && NULL != m_contactMgr) {
        // 获取接收用户item
        LMUserItem* userItem = m_contactMgr->GetUser(userId);
        if (NULL != userItem) {
            userItem->Lock();
            msgList = userItem->GetRepeatSendPrivateMsg(sendMsgId);
            if (msgList.size() > 0) {
                // 设置本地唯一标识ID
                for (LMMessageList::const_iterator iter = msgList.begin(); iter != msgList.end(); iter++) {
                    if ((*iter)->m_msgType == LMMT_Time) {
                        (*iter)->SetSendMsgId(m_msgIdBuilder.GetAndIncrement());
                    }
                    if ( (*iter)->m_sendMsgId == sendMsgId) {
                        sendItem = (*iter);
                    }
                }
                sendFail = HandleSendingMsg(userItem, sendItem);
//                if (userItem->m_refreshMark) {
//                    bool result = userItem->AddRequestMap(m_requestIdBuilder.GetAndIncrement(), LMMessageListType_Update);
//                    if (result) {
//                        RequestItem* requestItem = new RequestItem();
//                        requestItem->requestType = REQUEST_TASK_GetPrivateMsg;
//                        requestItem->param = (TaskParam)userItem;
//                        InsertRequestTask((TaskParam)requestItem);
//                    }
//
//                } else {
//                    RequestItem* requestItem = new RequestItem();
//                    requestItem->requestType = REQUEST_TASK_SendMsg;
//                    requestItem->param = (TaskParam)userItem;
//                    InsertRequestTask((TaskParam)requestItem);
//                }
                
                result = true;
            }
            userItem->Unlock();
        }
    }
    if (m_listener && result) {
        if (msgList.size() > 0) {
            m_listener->OnRepeatSendPrivateMsgNotice(userId, msgList);
        }
        m_listener->OnUpdateFriendListNotice(true, 0, "");
        if (sendFail) {
            m_listener->OnLMSendPrivateMessage(userId, false, LCC_ERR_CONNECTFAIL, "", sendItem);
        }
    }

    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RepeatSendPrivateMsg(userId:%s sendMsgId:%d) end", userId.c_str(), sendMsgId);
    return result;
}

bool LiveMessageManManager::IsHasMorePrivateMsgWithUserId(const string& userId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::IsHasMorePrivateMsgWithUserId(userId:%s) begin", userId.c_str());
    bool result = true;
    if (NULL != m_userMgr && NULL != m_contactMgr) {
        // 获取接收用户item
        LMUserItem* userItem = m_contactMgr->GetUser(userId);
        if (NULL != userItem) {
            userItem->Lock();
            result = userItem->m_isHasMoreMsg;
            userItem->Unlock();
        }
    }

    
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::IsHasMorePrivateMsgWithUserId(userId:%s) end", userId.c_str());
    return result;
}

// ---------- 用户私信列表公开操作 end -------------


#pragma mark - 内部函数
// ------------------ 私信联系人 私密操作 begin-----------------------------------
LMUserList LiveMessageManManager::LMGetLocalPrivateMsgFriendList() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetLocalPrivateMsgFriendList() begin");
    LMUserList list;
    if (NULL != m_contactMgr) {
        list = m_contactMgr->GetContactList();
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetLocalPrivateMsgFriendList(list.size():%d) end", list.size());
    return list;
}

LMUserList LiveMessageManManager::LMGetLocalFollowPrivateMsgFriendList() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetLocalFollowPrivateMsgFriendList() begin");
    LMUserList list;
    if (NULL != m_contactMgr) {
        list = m_contactMgr->GetFollowContactList();
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetLocalFollowPrivateMsgFriendList(list.size():%d) end", list.size());
    return list;
}
long long LiveMessageManManager::LMGetPrivateMsgFriendList() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetPrivateMsgFriendList() begin");
    long long taskId = REQUEST_INVALIDREQUESTID;
    if (NULL != m_RequestPrivateMsgController && m_contactRequstStatus != LMRequstHandleType_Processing) {
        taskId = m_RequestPrivateMsgController->GetPrivateMsgFriendList();
        if (taskId != REQUEST_INVALIDREQUESTID) {
            m_contactRequstStatus = LMRequstHandleType_Processing;
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetPrivateMsgFriendList(taskId:%lld) end", taskId);
    return taskId;
}
long long LiveMessageManManager::LMGetFollowPrivateMsgFriendList() {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetFollowPrivateMsgFriendList() begin");
    long long taskId = -1;
    if (NULL != m_RequestPrivateMsgController) {
        taskId = m_RequestPrivateMsgController->GetFollowPrivateMsgFriendList();
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetFollowPrivateMsgFriendList(taskId:%lld) end", taskId);
    return taskId;
}

// 处理接收到私信消息的联系人更新
void LiveMessageManManager::HandlePrivateContactUpdate(const IMPrivateMessageItem& item) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::HandlePrivateContactUpdate(item:%s) begin",item.fromId.c_str());
    if (NULL != m_contactMgr) {
        // 获取接收用户item
        LMUserItem* userItem = m_contactMgr->GetUser(item.fromId);
        userItem->Lock();
        userItem->m_unreadNum++;
        userItem->Unlock();
        if(m_contactMgr->GetSynTimeMark()&& m_contactMgr->UpdatePrivateContactList(item) && NULL != m_listener) {
            m_listener->OnUpdateFriendListNotice(true, 0, "");
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::HandlePrivateContactUpdate(item:%s) end", item.fromId.c_str());
    
}

// 处理要发送的item, userItem不能加锁
bool LiveMessageManManager::HandleSendingMsg(LMUserItem* userItem, LiveMessageItem* sendItem) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::HandleSendingMsg() begin");
    bool result = false;
    if (NULL != userItem && NULL != sendItem) {
        userItem->LockSendMsgList();
        if (!userItem->m_refreshMark) {
            if (userItem->m_sendMsgList.size() <= 0) {
                if (sendItem != NULL) {
                    result = !(LMSendPrivateMessage(userItem->m_userId, (sendItem->GetPrivateMsgItem())->m_message, sendItem->m_sendMsgId));
                    if (result) {
                        sendItem->m_sendErr = LCC_ERR_CONNECTFAIL;
                        sendItem->SetSendPrivateHandleStatus(LMStatusType_Fail);
                    }
                }
                
            } else {
                userItem->InsertSendingList(sendItem);
                RequestItem* requestItem = new RequestItem();
                requestItem->requestType = REQUEST_TASK_SendMsg;
                requestItem->param = (TaskParam)userItem;
                InsertRequestTask((TaskParam)requestItem);
            }
        } else {
            userItem->InsertSendingList(sendItem);
            bool isFlag = userItem->AddRequestMap(m_requestIdBuilder.GetAndIncrement(), LMMessageListType_Update);
            if (isFlag) {
                RequestItem* requestItem = new RequestItem();
                requestItem->requestType = REQUEST_TASK_GetPrivateMsg;
                requestItem->param = (TaskParam)userItem;
                InsertRequestTask((TaskParam)requestItem);
            }
        }
        
        userItem->UnlockSendMsgList();
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::HandleSendingMsg() end");
    return result;

}


// ------------------ 私信联系人 私密操作 end-----------------------------------

// ---------- 用户私信列表私密操作 begin ---------------------------------------

bool LiveMessageManManager::LMSendPrivateMessage(const string& toId, const string& content, int sendMsgId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMSendPrivateMessage() begin");
    bool result = false;
    if (NULL != m_client) {
        result = m_client->SendPrivateMessage(m_client->GetReqId(), toId, content, sendMsgId);
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMSendPrivateMessage(result:%d) end", result);
    return result;
}

long long LiveMessageManManager::LMSetPrivateMsgReaded(const string& userId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMSetPrivateMsgReaded() begin");
    long long taskId = -1;
    if (NULL != m_userMgr && NULL != m_contactMgr){
        LMUserItem* userItem = m_contactMgr->GetUserNotCreate(userId);
        if (NULL != userItem) {
            int msgId = -1;
            if (userItem->IsSetMaxReadMsgId(msgId)) {
                string strMsgId = "";
                if (msgId >= 0) {
                    char temp[16];
                    snprintf(temp, sizeof(temp), "%d", msgId);
                    strMsgId = temp;
                }
                // http请求不能在其他锁里面
                taskId = m_RequestPrivateMsgController->SetPrivateMsgReaded(userId, strMsgId);
            }
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMSetPrivateMsgReaded(taskId:%lld) end", taskId);
    return taskId;
}

bool LiveMessageManManager::LMGetPrivateMessageHistoryById(const string& toId, const string& startMsgId, PrivateMsgOrderType order, int limit, int reqId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetPrivateMessageHistoryById(toId:%s, startMsgId:%s, order:%d limit:%d, reqId:%d) begin", toId.c_str(), startMsgId.c_str(), order, limit, reqId);
    bool result = false;
    if (NULL != m_RequestPrivateMsgController) {
        result = m_RequestPrivateMsgController->GetPrivateMsgHistoryById(toId, startMsgId, order, limit, reqId);
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::LMGetPrivateMessageHistoryById(toId:%s, startMsgId:%s, order:%d limit:%d reqId:%d) end", toId.c_str(), startMsgId.c_str(), order, limit, reqId);
    return result;
}

// 定时请求私信列表
void LiveMessageManManager::RequestPrivateMsgList(LMUserItem* userItem) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RequestPrivateMsgList(userItem:%p userItem.userId:%s) begin", userItem, userItem->m_userId.c_str());
    bool result = false;
    string toId = "";
    string startMsgId = "";
    PrivateMsgOrderType order = PRIVATEMSGORDERTYPE_UNKNOW;
    int reqId = REQUEST_INVALIDREQUESTID;
    int limit = PRIVATEMESSAGE_LIMIT;
    if (NULL != userItem) {
        userItem->Lock();
        result = userItem->GetNewRequest(toId, startMsgId, order, limit, reqId);
        // 当刷新标志为false 而 没有请求处理中时（有刷新请求，刷新标志为false不去请求，直接返回）
        if (!result && userItem->GetHandleRequestType() != LMRequstHandleType_Processing) {
            HttpPrivateMsgList tempList;
            LMMessageListType type = LMMessageListType_Unknow;
            LMMessageList list;
            // 请求成功，又有发送的（本地有数据），请求个数没有超过50（没有更多了），需要添加一个系统消息头
            LMMessageList tempMoreList;
            userItem->UpdateMessageList(tempList, type, false, tempMoreList);
            // 当标志位为false，刷新不用刷新，直接返回
            if (m_listener) {
                if (type == LMMessageListType_Refresh && !userItem->m_refreshMark) {
                    LMMessageList list;
                    m_listener->OnLMRefreshPrivateMsgWithUserId(userItem->m_userId, true, 0, "", list, reqId);
                }

            }
        }
        userItem->Unlock();
    }
    if (result) {
        result = LMGetPrivateMessageHistoryById(toId, startMsgId, order, limit, reqId);
        if (result && NULL != userItem) {
            userItem->SetHandleRequestType(LMRequstHandleType_Processing);
        }
    } 
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::RequestPrivateMsgList(toId:%s, startMsgId:%s, order:%d limit:%d) end", toId.c_str(), startMsgId.c_str(), order, limit);
}

// 发送私信列表
void LiveMessageManManager::SendPrviateMsgProc(LMUserItem* userItem) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::SendPrviateMsgProc(userItem:%p userItem.userId:%s) begin", userItem, userItem->m_userId.c_str());
    LMMessageList falseList;
    if (NULL != userItem) {
        userItem->Lock();
            userItem->LockSendMsgList();
            for (LMMessageList::iterator iter = userItem->m_sendMsgList.begin(); iter != userItem->m_sendMsgList.end(); ) {
                LMMessageList::const_iterator iter_e = iter++;
                LiveMessageItem* msgItem = (*iter_e);
                if (msgItem->m_statusType == LMStatusType_Processing) {
                    bool result = false;
                    if (!userItem->m_refreshMark) {
                        result = LMSendPrivateMessage(userItem->m_userId, (msgItem->GetPrivateMsgItem())->m_message, msgItem->m_sendMsgId);
                    }
                    if (result == false) {
                        if (m_listener) {
                            msgItem->m_sendErr = LCC_ERR_CONNECTFAIL;
                            msgItem->SetSendPrivateHandleStatus(LMStatusType_Fail);
                            falseList.push_back(msgItem);
                           // m_listener->OnLMSendPrivateMessage(userItem->m_userId, false, LCC_ERR_FAIL, "", msgItem);
                        }
                    }
                }
                userItem->m_sendMsgList.remove(msgItem);
            }
            userItem->UnlockSendMsgList();
        userItem->Unlock();
    }
    if (m_listener) {
        for (LMMessageList::const_iterator itr = falseList.begin(); itr != falseList.end(); itr++) {
            m_listener->OnLMSendPrivateMessage(userItem->m_userId, false, LCC_ERR_CONNECTFAIL, "", *itr);
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::SendPrviateMsgProc() end");
}
// ---------- 用户私信列表私密操作 end ----------------------------------------------------------------------

#pragma mark - 回调
// ------------------- IImClientListener -------------------
void LiveMessageManManager::OnLogin(LCC_ERR_TYPE err, const string& errmsg, const LoginReturnItem& item) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnLogin(err:%d errmsg:%s m_liveChatList:%d) begin", err, errmsg.c_str(), m_liveChatList.size());
    if (err == LCC_ERR_SUCCESS) {
        // 重连登录成功都先获取一次联系人列表
        LMGetPrivateMsgFriendList();
        
        // 遍历一下私信在聊列表消息
        for (LMLiveChatList::const_iterator iter = m_liveChatList.begin(); iter != m_liveChatList.end(); iter++) {
            int reqId = REQUEST_INVALIDREQUESTID;
            if (NULL != m_userMgr && NULL != m_contactMgr) {
                // 获取接收用户item
                LMUserItem* userItem = m_contactMgr->GetUser(*iter);
                if (NULL != userItem) {
                    reqId = m_requestIdBuilder.GetAndIncrement();
                    bool result = userItem->AddRequestMap(reqId, LMMessageListType_Update);
                    if (result) {
                        RequestItem* requestItem = new RequestItem();
                        requestItem->requestType = REQUEST_TASK_GetPrivateMsg;
                        requestItem->param = (TaskParam)userItem;
                        InsertRequestTask((TaskParam)requestItem);
                    }
                    
                }
            }
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnLogin() end");
}

void LiveMessageManManager::OnLogout(LCC_ERR_TYPE err, const string& errmsg) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnLogout( err : %d, errmsg: %s) begin", err, errmsg.c_str());

    // 启动请求队列处理线程
   // StartRequestThread();
    if (NULL != m_userMgr && NULL != m_contactMgr) {
        // 设置所有联系人的刷新标志位true
        m_userMgr->SetRefreshMark(true);
        // 重设参数
        m_userMgr->ResetParam();
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnLogout( err : %d, errmsg: %s) end", err, errmsg.c_str());

}
/**
 *  12.1.发送私信文本消息接口 回调
 *
 */
void LiveMessageManManager::OnSendPrivateMessage(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, int messageId, double credit, const string& toId, int sendMsgId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnSendPrivateMessage(success:%d err:%d errmsg:%s messageId;%d credit;%f toId:%s sendMsgId:%d) begin", success, err, errMsg.c_str(), messageId, credit, toId.c_str(), sendMsgId);
    LiveMessageItem* msgItem = NULL;
    LMMessageList msgList;
    // 从IM接收回调回来成功
    if (NULL != m_userMgr && NULL != m_contactMgr) {
        
        // 获取接收用户item
        LMUserItem* userItem = m_contactMgr->GetUser(toId);
        if (NULL != userItem) {
            // 将接收到的IM类转化为LM类，并加进接收处理列表里
            msgItem = userItem->GetSendMsgItemWithId(sendMsgId);
            if (success) {
                userItem->SetInsertListMsgIdMinAndMax(messageId);
            }
            
            if (msgItem != NULL) {
                msgItem->Lock();
                LMStatusType status = success ? LMStatusType_Finish : LMStatusType_Fail;
                msgItem->m_msgId = messageId;
                msgItem->m_sendErr = err;
                msgItem->SetSendPrivateHandleStatus(status);
                msgItem->Unlock();
                

                if (err == LCC_ERR_NO_CREDIT) {
                    LiveMessageItem* warningItem = userItem->InsertOtherMessage(LMMT_Warning, "", LMWarningType_NoCredit);
                    userItem->m_msgList.push_back(warningItem);
                    msgList.push_back(warningItem);
                    // 设置本地唯一标识ID
                    for (LMMessageList::const_iterator iter = msgList.begin(); iter != msgList.end(); iter++) {
                        (*iter)->SetSendMsgId(m_msgIdBuilder.GetAndIncrement());
                    }
                }

                
            }
        }
        
    }

    if (m_listener) {
        //if (NULL != msgItem) {
            m_listener->OnLMSendPrivateMessage(toId, success, err, errMsg, msgItem);
       // }
        if (msgList.size() > 0) {
            m_listener->OnLMUpdatePrivateMsgWithUserId(toId, msgList);
        }
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnSendPrivateMessage() end");
}
/**
 *  12.2.接收私信文本消息通知接口 回调
 *
 *  @param item         私信文本消息
 *
 */
void LiveMessageManManager::OnRecvPrivateMessageNotice(const IMPrivateMessageItem& item) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnRecvPrivateMessageNotice(item.fromId:%s item.toId:%s msgId:%d msg:%s time:%lld msgType:%d) begin", item.fromId.c_str(), item.toId.c_str(), item.msgId, item.msg.c_str(), item.sendTime, item.msgType);
    LMMessageList msgList;
    
    // 判断是否接收到自己发送的私信
    bool isSame = (m_userId == item.fromId);
    // 从IM接收回调回来成功
    if (NULL != m_contactMgr && !isSame) {
        // 处理接收到私信消息的联系人更新
        HandlePrivateContactUpdate(item);
            // 获取接收用户item
            LMUserItem* userItem = m_contactMgr->GetUser(item.fromId);
            if (NULL != userItem) {
                userItem->Lock();
                // 将接收到的IM类转化为LM类，并加进接收处理列表里
                LiveMessageItem* msgItem = userItem->GetRecvPrivateMsg(item);
                if (msgItem != NULL) {
                    // 用户数据加锁，防止其它线程有对m_refreshMark修改
                    if (userItem->m_refreshMark) {
                        // 需要刷新就加进
                        bool result = userItem->AddRequestMap(m_requestIdBuilder.GetAndIncrement(), LMMessageListType_Update);
                        if (result) {
                            RequestItem* requestItem = new RequestItem();
                            requestItem->requestType = REQUEST_TASK_GetPrivateMsg;
                            requestItem->param = (TaskParam)userItem;
                            InsertRequestTask((TaskParam)requestItem);
                        }
                    }
                    else {
                        // 如果刷新标志位不需要刷新就插入本地消息列表，返回增量数组（可能没有（怕异步时，获取私信消息时，已经增加了,导致本地有了就不作为增量了），或只有一个）
                        msgList = userItem->InsertMsgList(msgItem);
                        // 设置本地唯一标识ID
                        for (LMMessageList::const_iterator iter = msgList.begin(); iter != msgList.end(); iter++) {
                            (*iter)->SetSendMsgId(m_msgIdBuilder.GetAndIncrement());
                        }
                    }
                }
                
                userItem->Unlock();
                
                if (NULL != m_listener) {
                    // 通知上层没读界面（这是名字有点奇怪了）
                    m_listener->OnLMRecvPrivateMessage(msgItem);
                }
            }
        
    }
    
    // 如果增量有数据，就回调到上层，注意考虑要不要也回调接收的接口（问题是怕联系人列表时，需要用到）
    if (msgList.size() > 0) {
        if (NULL != m_listener) {
            m_listener->OnLMUpdatePrivateMsgWithUserId(item.fromId, msgList);
        }
    }
    
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnRecvPrivateMessageNotice(msgList.size();%d) end", msgList.size());
}

// ------------------- HttpRequestManManageListener -------------------
void LiveMessageManManager::OnHttpGetPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list, long dbtime) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnHttpGetPrivateMsgFriendList(success:%d, errnum:%d, errmsg:%s, list.size();%d) begin", success, errnum, errmsg.c_str(), list.size());

    
    if (success) {
        // 从http回调回来成功，
        if (NULL != m_contactMgr && list.size() > 0) {
            // 刷新私信联系人列表
            m_contactMgr->RefreshPrivateContactList(list, dbtime);
        }
    }
    
    if (NULL != m_listener) {
        m_listener->OnUpdateFriendListNotice(success, errnum, errmsg);
    }
    m_contactRequstStatus = LMRequstHandleType_Finish;
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnHttpGetPrivateMsgFriendList() end");
}

// 已弃用了
void LiveMessageManManager::OnHttpGetFollowPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnHttpGetFollowPrivateMsgFriendList(success:%d, errnum:%d, errmsg:%s, list.size();%d) begin", success, errnum, errmsg.c_str(), list.size());
    if (success) {
        // 从http回调回来成功，
        if (NULL != m_userMgr && NULL != m_contactMgr && list.size() > 0) {
//            // 1.将列表的用户增加到用户管理器里,里面已经进行了排重和创建，返回的是http回调回来的数据（并没有增加没有的数据）
//            LMUserList userList = m_userMgr->GetAndAddUsers(list);
//            // 2.将用户列表增加或修改关注私信联系人列表
//            m_contactMgr->UpdateFollowPrivateContactList(userList);
        }
    }
    
//    if (NULL != m_listener) {
//        m_listener->OnLMGetFollowPrivateMsgFriendList(requestId, success, errnum, errmsg, LMGetLocalFollowPrivateMsgFriendList());
//    }
   FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnHttpGetFollowPrivateMsgFriendList() end");
}

void LiveMessageManManager::OnHttpGetPrivateMsgHistoryById(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgList& list, const long dbtime, const string& userId, int reqId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnHttpGetPrivateMsgHistoryById(success:%d, errnum:%d, errmsg:%s, list.size():%d userId:%s reqId:%d dbtime:%lld durrent:%lld) begin", success, errnum, errmsg.c_str(), list.size(), userId.c_str(), reqId, dbtime, (long)(getCurrentTime() / 1000));
    

    LMMessageList tempList;
    // 请求成功，又有发送的（本地有数据），请求个数没有超过50（没有更多了），需要添加一个系统消息头
    LMMessageList tempMoreList;
    LMMessageListType type = LMMessageListType_Unknow;
    bool isMuchMore = true;
    if (success && list.size() <= 0) {
        isMuchMore = false;
    }
    // 从http回调回来成功
    if (NULL != m_userMgr && NULL != m_contactMgr) {
        LMUserItem* userItem = m_contactMgr->GetUserNotCreate(userId);
        if (success) {
            m_userMgr->SetDbTime(dbtime);
        }
        
        if (NULL != userItem) {

        
        tempList = userItem->UpdateMessageList(list, type, success, tempMoreList);

        // 设置本地唯一标识ID
        for (LMMessageList::const_iterator itr = tempMoreList.begin(); itr != tempMoreList.end(); itr++) {
            (*itr)->SetSendMsgId(m_msgIdBuilder.GetAndIncrement());
        }
        
            // 设置本地唯一标识ID
            for (LMMessageList::const_iterator iter = tempList.begin(); iter != tempList.end(); iter++) {
                (*iter)->SetSendMsgId(m_msgIdBuilder.GetAndIncrement());
            }
            FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnHttpGetPrivateMsgHistoryById(success:%d, errnum:%d, errmsg:%s, list.size():%d, userItem->m_refreshMark:%d, userItem->m_sendMsgList.size():%d type:%d)", success, errnum, errmsg.c_str(), list.size(), userItem->m_refreshMark, userItem->m_sendMsgList.size(), type);
            if (userItem->m_sendMsgList.size() > 0 && (type == LMMessageListType_Refresh || type == LMMessageListType_Update)) {
                RequestItem* requestItem = new RequestItem();
                requestItem->requestType = REQUEST_TASK_SendMsg;
                requestItem->param = (TaskParam)userItem;
                InsertRequestTask((TaskParam)requestItem);
            }
            userItem->SetHandleRequestType(LMRequstHandleType_Finish);
            userItem->Unlock();
            NextRequestWithUserItem(userItem);
        }
        
    }
    
    if (NULL != m_listener) {
        if (type == LMMessageListType_More) {
            if (tempMoreList.size() > 0) {
                for (LMMessageList::reverse_iterator itr = tempMoreList.rbegin(); itr != tempMoreList.rend(); itr++) {
                    //(*itr)->SetSendMsgId(m_msgIdBuilder.GetAndIncrement());
                    tempList.push_front((*itr));
                }
                tempMoreList.clear();
            }
            m_listener->OnLMGetMorePrivateMsgWithUserId(userId, success, errnum, errmsg, tempList, reqId, isMuchMore, false);
        }
        else if (type == LMMessageListType_Refresh) {
            m_listener->OnLMRefreshPrivateMsgWithUserId(userId, success, errnum, errmsg, tempList, reqId);
        }
        else if (type == LMMessageListType_Update) {
            m_listener->OnLMUpdatePrivateMsgWithUserId(userId, tempList);
        }
        if (tempMoreList.size() > 0) {
             m_listener->OnLMGetMorePrivateMsgWithUserId(userId, success, errnum, errmsg, tempMoreList, reqId, true, true);
        }
        
    }

    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnHttpGetPrivateMsgHistoryById() end");
}

void LiveMessageManManager::OnHttpSetPrivateMsgReaded(long long requestId, bool success, int errnum, const string& errmsg, bool isModify, const string& userId) {
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnHttpSetPrivateMsgReaded(success:%d, errnum:%d, errmsg:%s, isModify;%d, userId:%s) begin", success, errnum, errmsg.c_str(), isModify, userId.c_str());
    if (NULL != m_userMgr && NULL != m_contactMgr) {
        // 获取已有的联系人用户
        LMUserItem* userItem = m_contactMgr->GetUserNotCreate(userId);
        if (NULL != userItem) {
            userItem->Lock();
            // 更新已读最大msgId
            userItem->UpdateReadMsgId(success);
            userItem->UpdateUnreadNum();
            userItem->Unlock();
        }
    }
    
    if (NULL != m_listener) {
        if (success) {
            m_listener->OnUpdateFriendListNotice(true, 0, "");
        }
        m_listener->OnLMSetPrivateMsgReaded(requestId, success, errnum, errmsg, isModify, userId);
    }
    FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "LiveMessageManManager::OnHttpSetPrivateMsgReaded() end");
}

// 请求私信请求列表下一个请求
void LiveMessageManManager::NextRequestWithUserItem(LMUserItem* userItem) {
    if (userItem != NULL) {
        userItem->Lock();
        if (userItem->m_requestMap.size() > 0 && userItem->GetHandleRequestType() != LMRequstHandleType_Processing) {
            RequestItem* requestItem = new RequestItem();
            requestItem->requestType = REQUEST_TASK_GetPrivateMsg;
            requestItem->param = (TaskParam)userItem;
            InsertRequestTask((TaskParam)requestItem);
        }
        userItem->Unlock();
    }
}

