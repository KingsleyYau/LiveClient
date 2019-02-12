/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LMUserItem.h
 *   desc: 直播用户item
 */

#pragma once

#include "LiveMessageItem.h"

using namespace std;

typedef map<int, LMMessageListType>   RequestPrivateMsgMap;
class IAutoLock;
class LMUserItem
{

public:
	LMUserItem();
	virtual ~LMUserItem();

public:
    // -------------- 私信联系人列表用户信息 公开操作 begin --------------------------------
    // 根据私信联系人更新信息, 根据userId是否相同修改用户其它属性，当m_userId
    bool UpdateWithUserInfo(const string& userId, const string& nickName, const string& avatarImg, const string& msg, long sysTime, OnLineStatus onLineStatus, bool isAnchor, long diffTime, bool isUpdateMark);
    // 设置最后更新时间
    void SetLastUpdateTime(bool isUpdateMark, long sysTime, long diffTime, const string& msg);
    // 设置没读数
    void SetUnreadNum(int num);
    // 判断是否要请求设置最大msgId已读
    bool IsSetMaxReadMsgId(int& msgId);
    // 根据接口成功是否更新已读和设置已读最大msgId
    void UpdateReadMsgId(bool success);
    // 内部更新没读数
    void UpdateUnreadNum();
    // -------------- 私信联系人列表用户信息 公开操作 end ----------------------------------
    
    // -------------- 私信消息列表 公开操作 begin -----------------------------------------
	// 获取私信消息记录列表
	LMMessageList GetMsgList();
    // 清除所有聊天记录
    void ClearMsgList();
    // 根据消息ID获取LCMessageItem
    LiveMessageItem* GetMsgItemWithId(int msgId);
    // 根据发送消息ID获取LCMessageItem
    LiveMessageItem* GetSendMsgItemWithId(int sendMsgId);
    // 插入接收到的私信消息， 返回一个数组
    LMMessageList InsertMsgList(LiveMessageItem* item);
    // 更新私信队列
    LMMessageList UpdateMessageList(const HttpPrivateMsgList& list, LMMessageListType& type, bool success, LMMessageList& moreList);
    // -------------- 私信消息列表 公开操作 end -------------------------------------------
	// 比较函数
	static bool Sort(LMUserItem* item1, LMUserItem* item2);
    // 设置请求的处理状态
    void SetHandleRequestType(LMRequstHandleType type);
    LMRequstHandleType GetHandleRequestType();
    bool AddRequestMap(int requestId, LMMessageListType type);
    // 获取最新的私信请求（返回ture 可以请求， false 为不能请求（可能本用户已经在请求私信请求接口中， 也可能没有请求队列））
    bool GetNewRequest(string& toId, string& startMsg, PrivateMsgOrderType& order, int& limit, int& reqId);
    // 将接收到的IM类转化为LM类
    LiveMessageItem* GetRecvPrivateMsg(const IMPrivateMessageItem& item);
    // 创建发送私信的消息item, userId为用户userId，
    LMMessageList GetSendPrivateMsg(const string& userId, const string& message, int sendMsgId);
    // 获取重发的发送私信的消息item, userId为用户userId，
    LMMessageList GetRepeatSendPrivateMsg(int sendMsgId);
    // 设置插入msgList队列的最大和最大值
    void SetInsertListMsgIdMinAndMax(int msgId);
    // 判断是否需要插入
    bool IsInsertTimeMsgItem(LiveMessageItem* msg1, LiveMessageItem* msg2);
    // 插入其他本地消息（如系统提示，余额不足）
    LiveMessageItem* InsertOtherMessage(LMMessageType msgType, const string& message = "", LMWarningType warnType = LMWarningType_Unknow, long updateTime = 0, LMSystemType systemType = LMSystemType_NoMore);
    // 私信列表重新插入时间item
    LMMessageList AgainInsertTimeMsgList();
    // 获取私信队列最近一个timeitem（是否是从后面算起）
    LiveMessageItem* GetMsgListLastTimeItme(bool isFromBack);
    // 设置最新用户消息
    void SetUserItemLastMsg(long time, const string& msg);
    // 插入待发队列
    void InsertSendingList(LiveMessageItem* msgItem);
    // 设置私信聊天界面没有聊天记录时的提示
    static void SetPrivateNotice(const string& privateNotice);

private:
    // 将http的私信转换为liveMessageItem
    LiveMessageItem* GetNewLiveMessageItem(const HttpPrivateMsgItem& item);
    // 将刷新的消息列表插入本地消息列表
    void InsertMessageRefresh(LMMessageList& msgList);
    // 将更多的消息列表插入本地消息列表
    void InsertMessageMore(LMMessageList& msgList);
    
public:
	// 聊天消息列表加锁
	void LockMsgList();
	// 聊天消息列表解徜
	void UnlockMsgList();
	// 待发送消息列表加锁
	void LockSendMsgList();
	// 待发送消息列表解锁
	void UnlockSendMsgList();

    // 状态加锁
    void Lock();
    // 状态解锁
    void Unlock();
    // 请求列表加锁
    void LockRequestList();
    // 请求列表解锁
    void UnlockRequestList();
    
public:
    bool                m_refreshMark;      // 刷新标志（true， 需要获取最新私信）
	string			    m_userId;			// 用户ID
	string			    m_userName;			// 昵称
    string              m_imageUrl;         // 头像URL
	OnLineStatus	    m_onlineStatus;		// 在线状态（0：离线，1：在线）
	string		        m_lastMsg;		    // 最近一条私信（包括自己及对方）
	long	            m_updateTime;	    // 最近一条私信服务器处理时间戳（1970年起的秒数）
    long                m_UnsnyUpdateTime;  // 还没有同步的服务器时间戳（1970年起的秒数，当同步后需要加到相差时间）
	int			        m_unreadNum;		// 未读条数
    bool                m_isAnchor;         // 是否主播（0：否，1：是）
    
    int                 m_minMsgId;         // 在列表中私信列表中最小msgId
    int                 m_maxMsgId;         // 在列表中私信列表中最大的msgId
    
    //int                 m_minRecvMsgId;       // 
    int                 m_maxRecvMsgId;         // 在处理的私信列表最大的msgId
    
    int                 m_maxReadMsgId;         // 设置已读最大MsgId
    int                 m_maxSuccessReadmsgId;  // 成功已读最大MsgId
    
    bool                m_isHasMoreMsg;        // 是否可以下拉更多
    
    
	bool			    m_tryingSend;		// 是否正在尝试发送（可能正在检测是否可聊天，包括检测是否有试聊券，是否可使用，是否有足够点数等)
	int				    m_order;			// 排序分值（用于邀请排序）
    
	LMMessageList	m_msgList;			  // 私信消息列表
    LMMessageList   m_handleMsgList;      // 需要处理的私信列表（接收到的私信， 即还没有插入消息列表中的）
	IAutoLock*		m_msgListLock;		  // 私信消息列表锁 和 处理的私信列RequestListv表锁
	LMMessageList	m_sendMsgList;		  // 待发消息列表
	IAutoLock*		m_sendMsgListLock;	  // 待发消息列表锁
    IAutoLock*		m_statusLock;         // 状态锁(用于用户数据改变),一般用在外面，里面不加
    RequestPrivateMsgMap      m_requestMap;        // 请求列表
    IAutoLock*      m_requestListLock;         // 请求列表锁
    
private:
    LMRequstHandleType m_requestHandleType;   // 获取私信消息列表的类型（暂时http 10.3.获取私信消息列表每个用户item不能同时有2个请求，都是一个请求完了，在有下一个请求）
    
    static string   m_privateNotice;        // 私信聊天界面没有聊天记录时的提示
};
typedef list<LMUserItem*>		LMUserList;
