/*
 * author: Alex.Shum
 *   date: 2018-6-13
 *   file: ILiveMessageManManager.h
 *   desc: 直播信息男士Manager接口类（暂只有私信管理器）
 */

#pragma once

#include <httpcontroller/HttpRequestController.h>
#include "LMUserItem.h"
#include "HttpRequestPrivateMsgController.h"

using namespace std;
class ILiveMessageManManagerListener
{
public:
	ILiveMessageManManagerListener() {};
	virtual ~ILiveMessageManManagerListener() {}

public:
    // ------- 私信联系人 listener(http接口的返回) -------
    // 私信联系人有改变通知
    virtual void OnUpdateFriendListNotice(bool success, int errnum, const string& errmsg) = 0;
//    // 调用私信联系人列表的回调
//    virtual void OnLMGetPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const LMUserList& ContactList)  = 0;
//    // 调用私信follow联系人的回调（弃用了）
//    virtual void OnLMGetFollowPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const LMUserList& followList)  = 0;

    // ------- 私信消息公共操作 listener -------
    // 这个是上层调用的返回，获取指定用户Id的用户的私信消息（不能直接返回的，需要考虑刷新消息标记,都是异步返回的。一般用于刚进私信间和重连后调用GetLocalPrivateMsgWithUserId后再使用这个）,返回是全部还是增量呢？(userId 为接收者的用户id，用于上层判断是否为当前的聊天用户)
    virtual void OnLMRefreshPrivateMsgWithUserId(const string& userId, bool success, int errnum, const string& errmsg, const LMMessageList& msgList, int reqId) = 0;
    // 这个是上层调用的返回，获取指定用户Id的用户更多私信消息（不能直接返回的，需要考虑刷新消息标记和是否有本地数据），返回是以前的的数据，插在数据前面，不是全部(userId 为接收者的用户id，用于上层判断是否为当前的聊天用户)
    virtual void OnLMGetMorePrivateMsgWithUserId(const string& userId, bool success, int errnum, const string& errmsg, const LMMessageList& msgList, int reqId, bool isMuchMore, bool isInsertHead) = 0;
    // 这个不是上层调用回调过来的，是c层接收都数据或发送前判断需要更新数据后，将回调新增的数据到上层
    virtual void OnLMUpdatePrivateMsgWithUserId(const string& userId, const LMMessageList& msgList) = 0;
    // 提交阅读私信（用于私信聊天间，向服务器提交已读私信）回调
    virtual void OnLMSetPrivateMsgReaded(long long requestId, bool success, int errnum, const string& errmsg, bool isModify, const string& toId) = 0;

    // -------  私信listener(成功，一般再调用GetLocatPrivateMsgWithUserId) -------
    // 发送消息返回的状态(userId 为接收者的用户id，用于上层判断是否为当前的聊天用户)
    virtual void OnLMSendPrivateMessage(const string& userId, bool success, int errnum, const string& errmsg, LiveMessageItem* item) = 0;
    // 接收私信消息（用于提示未读数接口调用）
    virtual void OnLMRecvPrivateMessage(LiveMessageItem* item) = 0;
    // 重发通知（上层按了重发，c层删除所有时间item（android不好删除可能有时间item），把所有发送给上层）
    virtual void OnRepeatSendPrivateMsgNotice(const string& userId, const LMMessageList& msgList) = 0;
};

//class HttpRequestManager;
class ILiveMessageManManager
{
public:
	static ILiveMessageManManager* Create();
	static void Release(ILiveMessageManManager* obj);

protected:
    ILiveMessageManManager() {};
	virtual ~ILiveMessageManManager() {}

public:
	// -------- 初始化/登录/注销 --------
    //  初始化obj的个人信息（用在创建obj之后（http登录成功才有userId和userName后调用），init之前，防止http登录成功，而im没有成功时调用私信列表不知道信件是发是收）
    virtual bool InitUserInfo(string userId, PrivateSupportTypeList supportList, const string& privateNotice) = 0;
    // 获取用户ID
    virtual string GetUserId() = 0;
	// 初始化（在Imclient的obj创建后调用，防止IImClient为空）
	virtual bool Init(
                      IImClient* client,
                      const IHttpRequestPrivateMsgControllerHandler& requestListener,
                      ILiveMessageManManagerListener* listener) = 0;
//    // 上层http登录回调后通知管理器
//    virtual bool Login(bool success, string userId, string userName) = 0;
//    // 上层http注销回调后通知管理器
//    virtual bool Logout(bool success) = 0;
    // Release私信管理器的client是否init里面的client。防止client被release，私信管理器release后又使用client
    virtual bool CheckIMClientRelease(IImClient* client) = 0;
    // ---------- 私信列表操作 ----------
    // 获取本地私信联系人列表（同步返回）
    virtual LMUserList GetLocalPrivateMsgFriendList() = 0;
    // 获取私信联系人列表（异步返回）
    virtual long long GetPrivateMsgFriendList() = 0;
    // 获取本地私信Follow联系人列表（同步返回）
    virtual LMUserList GetLocalFollowPrivateMsgFriendList() = 0;
    // 获取私信Follow联系人列表异步返回）
    virtual long long GetFollowPrivateMsgFriendList() = 0;
    // 增加私信在聊列表
    virtual bool AddPrivateMsgLiveChat(const string& userId) = 0;
    // 删除私信在聊列表
    virtual bool RemovePrivateMsgLiveChat(const string& userId) = 0;
    
    // ---------- 私信消息公共操作 ----------
    // 获取指定用户Id的用户的本地消息(直接返回本地消息列表（深拷贝？防止消息被修改）， 不需要向服务器请求的)
    virtual LMMessageList GetLocalPrivateMsgWithUserId(const string& userId) = 0;
    // 获取指定用户Id的用户的私信消息（不能直接返回的，需要考虑刷新消息标记,都是异步返回的。一般用于刚进私信间和重连后调用GetLocalPrivateMsgWithUserId后再使用这个）
    virtual int RefreshPrivateMsgWithUserId(const string& userId) = 0;
    // 获取指定用户Id的用户更多私信消息（不能直接返回的，需要考虑刷新消息标记和是否有本地数据）
    virtual int GetMorePrivateMsgWithUserId(const string& userId) = 0;
    // 提交阅读私信（用于私信聊天间，向服务器提交已读私信）
    virtual long long SetPrivateMsgReaded(const string& userId) = 0;
    // -------- 私信/消息 --------
    // 发送私信消息，返回是否成功（不要返回item，因为可能会插时间item）
    virtual bool SendPrivateMessage(const string& userId, const string& message) = 0;
    // 重发私信消息
    virtual bool RepeatSendPrivateMsg(const string& userId, int sendMsgId) = 0;
    // 该用户是否还有更多私信消息
    virtual bool IsHasMorePrivateMsgWithUserId(const string& userId) = 0;

};
