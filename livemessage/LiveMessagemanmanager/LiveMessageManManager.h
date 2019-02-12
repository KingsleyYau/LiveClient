/*
 * author: Alex.Shum
 *   date: 2018-6-13
 *   file: LiveMessageManManager.h
 *   desc: 直播信息男士Manager
 */

#pragma once

#include "ILiveMessageManManager.h"
#include <httpclient/HttpRequestManager.h>
#include <ImClient/IThreadHandler.h>
#include <ImClient/Counter.h>

#include <list>
#include <string>
typedef unsigned long long TaskParam;
using namespace std;

//// 用户管理器
class LMUserManager;
class LMPrivateContactManager;

// 其它
class IThreadHandler;
class IAutoLock;

class RequestItem;
typedef list<string>    LMLiveChatList;
class LiveMessageManManager : public ILiveMessageManManager
                                , HttpRequestManManageListener
                                , IImClientListener

{
public:
    LiveMessageManManager();
    virtual ~LiveMessageManManager();

public:
    /******************************************* 定时任务处理 *******************************************/
    // 定时任务结构体
    typedef struct _tagTaskItem
    {
        //ILiveChatManManagerTaskCallback* callback;
        unsigned long long param;
        long long delayTime;

        _tagTaskItem()
        {
            //callback = NULL;
            param = 0;
            delayTime = -1;
        }

        _tagTaskItem(const _tagTaskItem& item)
        {
            //callback = item.callback;
            param = item.param;
            delayTime = item.delayTime;
        }

        void SetDelayTime(long milliseconds)
        {
            delayTime = getCurrentTime() + milliseconds;
        }

    } TaskItem;
    // 定时业务处理器
    void RequestHandler(RequestItem* item);

private:
    // 定时任务处理队列
    list<TaskItem*>    m_requestQueue;
    // 定时任务处理队列锁
    IAutoLock* m_requestQueueLock;
    // 插入任务到处理队列
    void InsertRequestTask(TaskParam param, long long delayTime = -1);
    // 定时任务处理队列操作函数
    bool IsRequestQueueEmpty();
    TaskItem* PopRequestTask();
    bool PushRequestTask(TaskItem* task);
    void CleanRequestTask();
    // 定时任务处理线程
    static TH_RETURN_PARAM RequestThread(void* obj);
    void RequestThreadProc();
    bool StartRequestThread();
    void StopRequestThread();
    // 请求私信请求列表下一个请求
    void NextRequestWithUserItem(LMUserItem* userItem);

    // 请求线程
    IThreadHandler*    m_requestThread;
    // 请求线程启动标记
    bool m_requestThreadStart;

    /******************************************* 定时任务处理 End *******************************************/

public:
	// -------- 初始化 begin -------------------------------------------------
    //  初始化obj的个人信息（用在创建obj之后（http登录成功才有userId和userName后调用），init之前，防止http登录成功，而im没有成功时调用私信列表不知道信件是发是收）
    bool InitUserInfo(string userId, PrivateSupportTypeList supportList, const string& privateNotice) override;
    // 获取用户ID
    string GetUserId() override;
	// 初始化(因为单例，只初始化一次)
    bool Init(
              IImClient* client,
              const IHttpRequestPrivateMsgControllerHandler& requestListener,
              ILiveMessageManManagerListener* listener) override;
    // -------- 初始化 end ---------------------------------------------------

    // ---------- 私信联系人列表操作 公开操作 begin----------
    // 获取本地私信联系人列表（同步返回）
    LMUserList GetLocalPrivateMsgFriendList() override;
    // 获取私信联系人列表（异步返回）
    long long GetPrivateMsgFriendList() override;
    // 获取本地私信Follow联系人列表（同步返回）
    LMUserList GetLocalFollowPrivateMsgFriendList() override;
    // 获取私信Follow联系人列表（异步返回）
    long long GetFollowPrivateMsgFriendList() override;

    // ---------- 私信联系人列表操作 公开操作 end----------
    
    // ---------- 用户私信列表公开操作 begin -------------
    // 增加私信在聊列表(用于断网后，重连成功后获取在聊列表用户的最新消息，解决断网后，重连没有最新消息，要自己发送或接收后马上生成一片数据)
    bool AddPrivateMsgLiveChat(const string& userId) override;
    // 删除私信在聊列表
    bool RemovePrivateMsgLiveChat(const string& userId) override;
    // 获取指定用户Id的用户的本地消息(直接返回本地消息列表（深拷贝？防止消息被修改）， 不需要向服务器请求的)
    LMMessageList GetLocalPrivateMsgWithUserId(const string& userId) override;
    // 刷新指定用户Id的用户的私信消息（不能直接返回的，需要考虑刷新消息标记,都是异步返回的。一般用于刚进私信间和重连后调用GetLocalPrivateMsgWithUserId后再使用这个）
    int RefreshPrivateMsgWithUserId(const string& userId) override;
    // 获取指定用户Id的用户更多私信消息（不能直接返回的，需要考虑刷新消息标记和是否有本地数据）
    int GetMorePrivateMsgWithUserId(const string& userId) override;
    // 提交阅读私信（用于私信聊天间，向服务器提交已读私信）
    long long SetPrivateMsgReaded(const string& userId) override;
    // 发送私信消息，返回是否成功（不要返回item，因为可能会插时间item）
    bool SendPrivateMessage(const string& userId, const string& message)override;
    // 重发私信消息
    bool RepeatSendPrivateMsg(const string& userId, int sendMsgId)override;
    // 该用户是否还有更多私信消息
    bool IsHasMorePrivateMsgWithUserId(const string& userId) override;
    // ---------- 用户私信列表公开操作 end -------------

 
private:
    // ---------- 用户私信列表私密操作 begin -------------
    bool LMSendPrivateMessage(const string& toId, const string& content, int sendMsgId);
    long long LMSetPrivateMsgReaded(const string& userId);
    bool LMGetPrivateMessageHistoryById(const string& toId, const string& startMsgId, PrivateMsgOrderType order, int limit, int reqId);
    // 定时请求私信列表
    void RequestPrivateMsgList(LMUserItem* userItem);
    // 发送私信列表
    void SendPrviateMsgProc(LMUserItem* userItem);
    // ---------- 用户私信列表私密操作 end -------------
    // ------------------ 私信联系人 私密操作 begin-----------------------------------
    // 获取本地私信联系人列表
    LMUserList LMGetLocalPrivateMsgFriendList();
    // 请求私信联系人列表
    long long LMGetPrivateMsgFriendList();
    // 获取本地私信关注联系人列表 （）
    LMUserList LMGetLocalFollowPrivateMsgFriendList();
    // 请求私信关注联系人列表
    long long LMGetFollowPrivateMsgFriendList();
    // 处理接收到私信消息的联系人更新
    void HandlePrivateContactUpdate(const IMPrivateMessageItem& item);
    // 处理要发送的item, userItem不能加锁
    bool HandleSendingMsg(LMUserItem* userItem, LiveMessageItem* sendItem);

    // ------------------ 私信联系人 私密操作 end-----------------------------------
    // 清除历史记录
    void CleanHistory();
    
    // ------------------- IImClientListener -------------------
private:
    /**
     *  2.1.登录回调
     *
     *  @param err          结果类型
     *  @param errmsg       结果描述
     *  @param item         登录返回结构体
     */
    virtual void OnLogin(LCC_ERR_TYPE err, const string& errmsg, const LoginReturnItem& item) override;
    
    virtual void OnLogout(LCC_ERR_TYPE err, const string& errmsg) override;
    /**
     *  12.1.发送私信文本消息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param messageId        消息ID
     *  @param credit           信用点（浮点型）（可无，无或小于0，则表示信用点不变）
     *  @param toId             被发送者ID
     *  @param sendMsgId        发送时的假Id
     *
     */
    virtual void OnSendPrivateMessage(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, int messageId, double credit, const string& toId, int sendMsgId) override;
    /**
     *  12.2.接收私信文本消息通知接口 回调
     *
     *  @param item         私信文本消息
     *
     */
    virtual void OnRecvPrivateMessageNotice(const IMPrivateMessageItem& item) override;
    // ------------------- HttpRequestManManageListener -------------------
private:
    virtual void OnHttpGetPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list, long dbtime) override;
    virtual void OnHttpGetFollowPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list) override;
    virtual void OnHttpGetPrivateMsgHistoryById(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgList& list, const long dbtime, const string& userId, int reqId) override;
    virtual void OnHttpSetPrivateMsgReaded(long long requestId, bool success, int errnum, const string& errmsg, bool isModify, const string& userId) override;
private:
     IImClient*                         m_client;           // LiveChat客户端
     ILiveMessageManManagerListener*    m_listener;         // 回调
     Counter                            m_msgIdBuilder;    // 消息ID生成器
     Counter                            m_requestIdBuilder; // 请求ID生成器（暂只有http的主动请求才建立）
    
    string                             m_userId;            //  用户ID
    string                             m_userName;          //  用户name
    LMLiveChatList                     m_liveChatList;      // 私信在聊列表
    
    LMRequstHandleType                 m_contactRequstStatus; // 获取联系人请求状态（同时只请一次）
    
     // 用户管理器
     LMUserManager*                     m_userMgr;          // 用户管理器
     LMPrivateContactManager*           m_contactMgr;       // 联系人管理器

    HttpRequestPrivateMsgController*  m_RequestPrivateMsgController;
    
};
