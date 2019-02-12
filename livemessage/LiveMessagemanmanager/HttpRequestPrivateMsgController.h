/*
 * author: Alex.Shum
 *   date: 2018-7-11
 *   file: HttpRequestPrivateMsgController.h
 *   desc: 男士http请求管理器
 */

#pragma once

//#include <httpclient/HttpRequestManager.h>
#include <httpcontroller/HttpRequestController.h>
#include <list>
#include <string>
using namespace std;

typedef long long (*HandleRequestPrivateMsgFriendList)(IRequestGetPrivateMsgFriendListCallback* callback);
typedef long long (*HandleRequestFollowPrivateMsgFriendList)(IRequestGetFollowPrivateMsgFriendListCallback* callback);
typedef void (*HandleRequestPrivateMsgWithUserId)(const string& userId, const string& startMsgId, PrivateMsgOrderType order, int limit, int reqId, IRequestGetPrivateMsgHistoryByIdCallback* callback);
typedef long long (*HandleRequestSetPrivateMsgReaded)(const string& userId, const string& msgId,IRequestSetPrivateMsgReadedCallback* callback);
typedef struct _tagIHttpRequestPrivateMsgControllerCallback {
    HandleRequestPrivateMsgFriendList handleRequestPrivateMsgFriendList;
    HandleRequestFollowPrivateMsgFriendList handleRequestFollowPrivateMsgFriendList;
    HandleRequestPrivateMsgWithUserId handleRequestPrivateMsgWithUserId;
    HandleRequestSetPrivateMsgReaded handleRequestSetPrivateMsgReaded;
} IHttpRequestPrivateMsgControllerHandler;

class IRequestPrivateMsgControllerCallback
{
public:
    IRequestPrivateMsgControllerCallback() {}
    virtual ~IRequestPrivateMsgControllerCallback() {}
public:
    virtual void OnGetPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list, long dbtime) {};
    virtual void OnGetFollowPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list) {};
    virtual void OnGetPrivateMsgHistoryById(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgList& list, const long dbtime, const string& userId, int reqId) {};
    virtual void OnSetPrivateMsgReaded(long long requestId, bool success, int errnum, const string& errmsg, bool isModify, const string& userId) {};
};

class HttpRequestManManageListener
{
public:
    HttpRequestManManageListener() {};
    virtual ~HttpRequestManManageListener() {}

public:
    virtual void OnHttpGetPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list, long dbtime) {};
    virtual void OnHttpGetFollowPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list) {};
    virtual void OnHttpGetPrivateMsgHistoryById(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgList& list, const long dbtime, const string& userId, int reqId) {};
    virtual void OnHttpSetPrivateMsgReaded(long long requestId, bool success, int errnum, const string& errmsg, bool isModify, const string& userId) {};
};

class HttpRequestPrivateMsgController : public IRequestPrivateMsgControllerCallback
{
public:                                   
    HttpRequestPrivateMsgController(HttpRequestManManageListener* listener);
    virtual ~HttpRequestPrivateMsgController();
    
private:
    // ------------------- IRequestPrivateMsgControllerCallback -------------------
    virtual void OnGetPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list, long dbtime) override;
    virtual void OnGetFollowPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list) override;
    virtual void OnGetPrivateMsgHistoryById(long long requestId, bool success, int errnum, const string& errmsg, const HttpPrivateMsgList& list, const long dbtime, const string& userId, int reqId) override;
    virtual void OnSetPrivateMsgReaded(long long requestId, bool success, int errnum, const string& errmsg, bool isModify, const string& userId) override;

public:
    void SetRequestHandler(const IHttpRequestPrivateMsgControllerHandler& requesthandler);
    // -------- 私信请求接口 --------
    //10.1.获取私信联系人列表
    long long GetPrivateMsgFriendList();
    //10.2.获取私信Follow联系人列表
    long long GetFollowPrivateMsgFriendList();
    /**
     * 10.3.获取私信消息列表
     *
     * @param toId                          私信联系人ID
     * @param startMsgId                    起始私信消息ID（可无，无或空则表示从最新获取批定条数）
     * @param order                         排序类型（PRIVATEMSGORDERTYPE_OLD：获取比start_msgid旧的消息，PRIVATEMSGORDERTYPE_NEW：获取比start_msgid新的消息）（整型）（可无，仅当start_msgid不为空时有效）
     * @param limit                         消息数量（整型）（可无，当start_msgid不为空且order=1时无效）
     * @param reqId                         请求Id
     *
     * @return                              成功请求Id
     */
    bool GetPrivateMsgHistoryById(const string& toId,
                                       const string& startMsgId,
                                       PrivateMsgOrderType order,
                                       int limit,
                                       int reqId);
    
    /**
     * 10.4.标记私信已读
     *
     * @param toId                          私信联系人ID
     * @param msgId                         最后一条消息id
     *
     * @return                              成功请求Id
     */
    long long SetPrivateMsgReaded(const string& toId,
                                  const string& msgId);
private:
    // 设置请求回调
    void SetReqeustHandlerCallback();
    
private:
    IHttpRequestPrivateMsgControllerHandler m_requesthandler;
    HttpRequestManManageListener* m_listener;
};
