
/*
 * author: Alex.Shum
 *   date: 2018-7-11
 *   file: HttpRequestPrivateMsgController.cpp
 *   desc: 男士http请求管理器实现类
 */

#include "HttpRequestPrivateMsgController.h"
#include "ILiveMessageDef.h"

//-------- 私信接口 Begin --------
class IRequestPrivateMsgCallback {
 public:
    IRequestPrivateMsgCallback() {
        m_callback = NULL;
    }
    virtual ~IRequestPrivateMsgCallback(){};
public:
    bool IsHasCallback() {
        return (NULL == m_callback);
    }
    virtual void SetCallback(IRequestPrivateMsgControllerCallback *callback) {
        m_callback = callback;
    }
public:
    IRequestPrivateMsgControllerCallback *m_callback;
};
/***********************************  10.1.获取私信联系人列表 ****************************************/
class RequestGetPrivateMsgFriendListCallbackImp: public IRequestGetPrivateMsgFriendListCallback
                                                        ,IRequestPrivateMsgCallback
{
public:
    RequestGetPrivateMsgFriendListCallbackImp(){};
    virtual ~RequestGetPrivateMsgFriendListCallbackImp(){};
    void OnGetPrivateMsgFriendList(HttpGetPrivateMsgFriendListTask* task, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list, long dbtime) {
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::OnGetPrivateMsgFriendList( success : %d, list.size(): %d,  m_callback:%p dbtime:%lld) begin", success, list.size(), m_callback, dbtime);
        if (m_callback != NULL) {
            m_callback->OnGetPrivateMsgFriendList((long long)task, success, errnum, errmsg, list, dbtime);
        }
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::OnGetPrivateMsgFriendList( success : %d, list.size(): %d,  m_callback:%p) end", success, list.size(), m_callback);
    }
 public:
    void SetCallback(IRequestPrivateMsgControllerCallback *callback) { IRequestPrivateMsgCallback::SetCallback(callback);}
};
static RequestGetPrivateMsgFriendListCallbackImp gRequestGetPrivateMsgFriendListCallbackImp;

/***********************************  10.2.获取私信Follow联系人列表 ****************************************/
class RequestGetFollowPrivateMsgFriendListCallbackImp: public IRequestGetFollowPrivateMsgFriendListCallback
                                                             ,IRequestPrivateMsgCallback
{
public:
    RequestGetFollowPrivateMsgFriendListCallbackImp(){};
    virtual ~RequestGetFollowPrivateMsgFriendListCallbackImp(){};
    void OnGetFollowPrivateMsgFriendList(HttpGetFollowPrivateMsgFriendListTask* task, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list) {
                FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::OnGetFollowPrivateMsgFriendList( success : %d, list.size(): %d,  m_callback:%p) begin", success, list.size(), m_callback);
        if (m_callback != NULL) {
            m_callback->OnGetFollowPrivateMsgFriendList((long long)task, success, errnum, errmsg, list);
        }
                FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::OnGetFollowPrivateMsgFriendList( success : %d, list.size(): %d,  m_callback:%p) end", success, list.size(), m_callback);
    }
public:
    void SetCallback(IRequestPrivateMsgControllerCallback *callback) { IRequestPrivateMsgCallback::SetCallback(callback);}
};
static RequestGetFollowPrivateMsgFriendListCallbackImp gRequestGetFollowPrivateMsgFriendListCallbackImp;

/***********************************  10.3.获取私信消息列表 ****************************************/
class RequestGetPrivateMsgHistoryByIdCallbackImp: public IRequestGetPrivateMsgHistoryByIdCallback
                                                         ,IRequestPrivateMsgCallback
{
public:
    RequestGetPrivateMsgHistoryByIdCallbackImp(){};
    virtual ~RequestGetPrivateMsgHistoryByIdCallbackImp(){};
    void OnGetPrivateMsgHistoryById(HttpGetPrivateMsgHistoryByIdTask* task, bool success, int errnum, const string& errmsg, const HttpPrivateMsgList& list, long dbtime, const string& userId, int reqId) {
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::OnGetPrivateMsgHistoryById( success : %d, userId: %s, reqId:%d, list.size(): %d,  m_callback:%p) begin", success, userId.c_str(), reqId, list.size(), m_callback);
        if (m_callback != NULL) {
            m_callback->OnGetPrivateMsgHistoryById((long long)task, success, errnum, errmsg, list, dbtime, userId, reqId);
        }
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::OnGetPrivateMsgHistoryById( success : %d, userId: %s, reqId:%d, list.size(): %d, m_callback:%p) end", success, userId.c_str(), reqId, list.size(), m_callback);
    }
public:
    void SetCallback(IRequestPrivateMsgControllerCallback *callback) { IRequestPrivateMsgCallback::SetCallback(callback);}
};
static RequestGetPrivateMsgHistoryByIdCallbackImp gRequestGetPrivateMsgHistoryByIdCallbackImp;
/***********************************  10.4.标记私信已读 ****************************************/
class RequestSetPrivateMsgReadedCallbackImp: public IRequestSetPrivateMsgReadedCallback
                                                    ,IRequestPrivateMsgCallback
{
public:
    RequestSetPrivateMsgReadedCallbackImp(){};
    virtual ~RequestSetPrivateMsgReadedCallbackImp(){};
    void OnSetPrivateMsgReaded(HttpSetPrivateMsgReadedTask* task, bool success, int errnum, const string& errmsg, bool isModify, const string& toId) {
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::OnSetPrivateMsgReaded( success : %d, toId: %s, isModify : %d, m_callback:%p) begin", success, toId.c_str(), isModify, m_callback);
        if (m_callback != NULL) {
            m_callback->OnSetPrivateMsgReaded((long long)task, success, errnum, errmsg, isModify, toId);
        }
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::OnSetPrivateMsgReaded( success : %d, toId: %s, isModify : %d,  m_callback:%p) end", success, toId.c_str(), isModify, m_callback);
    }
public:
    void SetCallback(IRequestPrivateMsgControllerCallback *callback) { IRequestPrivateMsgCallback::SetCallback(callback);}
};
static RequestSetPrivateMsgReadedCallbackImp gRequestSetPrivateMsgReadedCallbackImp;
//-------- 私信接口 End--------

void HttpRequestPrivateMsgController::OnGetPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list, long dbtime) {
    if (NULL != m_listener) {
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::OnGetPrivateMsgFriendList( success : %d,  m_requesthandler:%p) begin", success, m_requesthandler);
        for (HttpPrivateMsgContactList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::OnGetPrivateMsgFriendList( userId : %s,  avatarImg:%s) ", (*iter).userId.c_str(), (*iter).avatarImg.c_str());
        }
        m_listener->OnHttpGetPrivateMsgFriendList(requestId, success, errnum, errmsg, list, dbtime);
    }
}
void HttpRequestPrivateMsgController::OnGetFollowPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list) {
    if (NULL != m_listener) {
        m_listener->OnHttpGetFollowPrivateMsgFriendList(requestId, success, errnum, errmsg, list);
    }
}
void HttpRequestPrivateMsgController::OnGetPrivateMsgHistoryById(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgList& list, const long dbtime, const string& userId, int reqId) {
    if (NULL != m_listener) {
        m_listener->OnHttpGetPrivateMsgHistoryById(requestId, success, errnum, errmsg, list, dbtime, userId, reqId);
    }
}

void HttpRequestPrivateMsgController::OnSetPrivateMsgReaded(long long requestId, bool success, int errnum, const string& errmsg, bool isModify, const string& userId) {
    if (NULL != m_listener) {
        m_listener->OnHttpSetPrivateMsgReaded(requestId, success, errnum, errmsg, isModify, userId);
    }
}

HttpRequestPrivateMsgController::HttpRequestPrivateMsgController(HttpRequestManManageListener* listener)
{
    // 请求管理器及控制器
    //m_Callback = callback;
    m_listener = listener;
    
    SetReqeustHandlerCallback();
}

void HttpRequestPrivateMsgController::SetReqeustHandlerCallback() {
    gRequestGetPrivateMsgFriendListCallbackImp.SetCallback(this);
    gRequestGetFollowPrivateMsgFriendListCallbackImp.SetCallback(this);
    gRequestGetPrivateMsgHistoryByIdCallbackImp.SetCallback(this);
    gRequestSetPrivateMsgReadedCallbackImp.SetCallback(this);
}

HttpRequestPrivateMsgController::~HttpRequestPrivateMsgController()
{

    if (m_listener != NULL) {
        m_listener = NULL;
    }
    
    gRequestSetPrivateMsgReadedCallbackImp.SetCallback(NULL);
    gRequestGetPrivateMsgFriendListCallbackImp.SetCallback(NULL);
    gRequestGetPrivateMsgHistoryByIdCallbackImp.SetCallback(NULL);
    gRequestGetFollowPrivateMsgFriendListCallbackImp.SetCallback(NULL);
}

void HttpRequestPrivateMsgController::SetRequestHandler(const IHttpRequestPrivateMsgControllerHandler& requesthandler) {
   m_requesthandler = requesthandler;
}

// -------- 私信请求接口 --------
long long HttpRequestPrivateMsgController::GetPrivateMsgFriendList() {
    long long taskId = -1;
    if (m_requesthandler.handleRequestPrivateMsgFriendList != NULL) {
        taskId = m_requesthandler.handleRequestPrivateMsgFriendList(&gRequestGetPrivateMsgFriendListCallbackImp);
        FileLevelLog(LIVESHOW_LIVEMESSAGE_LOG, KLog::LOG_MSG, "HttpRequestPrivateMsgController::LMGetPrivateMsgFriendList(taskId:%lld) end", taskId);
    }
    return taskId;
}

long long HttpRequestPrivateMsgController::GetFollowPrivateMsgFriendList() {
    long long taskId = -1;
    if (m_requesthandler.handleRequestFollowPrivateMsgFriendList != NULL) {
        taskId = m_requesthandler.handleRequestFollowPrivateMsgFriendList(&gRequestGetFollowPrivateMsgFriendListCallbackImp);
    }
    return taskId;
}

bool HttpRequestPrivateMsgController::GetPrivateMsgHistoryById(const string& toId,
                                                     const string& startMsgId,
                                                     PrivateMsgOrderType order,
                                                     int limit,
                                                     int reqId) {
    bool result = false;
    if (m_requesthandler.handleRequestPrivateMsgWithUserId != NULL) {
        m_requesthandler.handleRequestPrivateMsgWithUserId(toId, startMsgId, order, limit, reqId, &gRequestGetPrivateMsgHistoryByIdCallbackImp);
    }
    return result;
}

long long HttpRequestPrivateMsgController::SetPrivateMsgReaded(const string& toId,
                                                               const string& msgId) {
    long long taskId = -1;
    if (m_requesthandler.handleRequestSetPrivateMsgReaded != NULL) {
        taskId = m_requesthandler.handleRequestSetPrivateMsgReaded(toId, msgId, &gRequestSetPrivateMsgReadedCallbackImp);
    }
    return taskId;
}
