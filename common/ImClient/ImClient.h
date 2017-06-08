/*
 * author: Samson.Fan
 *   date: 2017-05-09
 *   file: ImClient.h
 *   desc: IM客户端实现类
 */

#pragma once

#include "IImClient.h"
#include "ITaskManager.h"
#include "IThreadHandler.h"
#include "Counter.h"

#include <common/IAutoLock.h>

typedef list<IImClientListener*> ImClientListenerList;

class ImClient : public IImClient
                , private ITaskManagerListener
                , private IImClientListener
{
public:
	ImClient();
	virtual ~ImClient();

// ILiveChatClient接口函数
public:
	// 调用所有接口函数前需要先调用Init
	bool Init(const list<string>& urls) override;
    // 增加监听器
    void AddListener(IImClientListener* listener) override;
    // 移除监听器
    void RemoveListener(IImClientListener* listener) override;
	// 判断是否无效seq
	virtual bool IsInvalidReqId(SEQ_T reqId) override;
	// 获取seq
	virtual SEQ_T GetReqId() override;
    
    // --------- 登录/注销 ---------
	// 登录
	bool Login(const string& user, const string& password) override;
	// 注销
	bool Logout() override;
    // 获取login状态
    LoginStatus GetLoginStatus() override;
    
    // --------- 直播间 ---------
    // 观众进入直播间
    bool FansRoomIn(SEQ_T reqId, const string& token, const string& roomId) override;
    // 观众退出直播间
    bool FansRoomOut(SEQ_T reqId, const string& token, const string& roomId) override;
    // 获取直播间信息
    bool GetRoomInfo(SEQ_T reqId, const string& token, const string& roomId) override;
    
    // --------- 直播间文本消息 ---------
    // 发送直播间文本消息
    bool SendRoomMsg(SEQ_T reqId, const string& token, const string& roomId, const string& nickName, const string& msg) override;
    
    
public:
	// 获取用户账号
	string GetUser() override;
    
// ITaskManagerListener接口函数
private:
	// 连接成功回调
	void OnConnect(bool success) override;
	// 连接失败回调(listUnsentTask：未发送/未回复的task列表)
	void OnDisconnect(const TaskList& list) override;
	// 已完成交互的task
	void OnTaskDone(ITask* task) override;

private:
	// 连接服务器
	bool ConnectServer();
	// 登录
	bool LoginProc();
	// 启动发送心跳包线程
	void HearbeatThreadStart();
	// 停止发送心跳包线程
	void HearbearThreadStop();

protected:
	static TH_RETURN_PARAM HearbeatThread(void* arg);
	void HearbeatProc();

private:
	bool			m_bInit;	// 初始化标志
	list<string>	m_svrIPs;	// 服务器ip列表
	string			m_svrIp;	// 当前连接的服务器IP
	unsigned int	m_svrPort;	// 服务器端口

	string			m_user;			// 用户名
	string			m_password;		// 密码
    
    IAutoLock*      m_loginStatusLock;  // 登录状态锁
    LoginStatus     m_loginStatus;  // 登录状态

	Counter			m_seqCounter;	// seq计数器

	ITaskManager*	m_taskManager;	// 任务管理器

	bool			m_isHearbeatThreadRun;	// 心跳线程运行标志
	IThreadHandler*		m_hearbeatThread;	// 心跳线程
	IAutoLock*		m_lastHearbeatTimeLock;	// 最后心跳时间锁
	long long		m_lastHearbeatTime;		// 最后心跳时间
    
    IAutoLock*		m_listenerListLock;		// 监听器锁
    ImClientListenerList m_listenerList;	// 监听器列表
    
private:
    // 客户端主动请求
    void OnLogin(LCC_ERR_TYPE err, const string& errmsg) override;
    void OnLogout(LCC_ERR_TYPE err, const string& errmsg) override;
    // ------------- 直播间处理(非消息) -------------
    // 观众进入直播间回调
    void OnFansRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& userId, const string& nickName, const string& photoUrl, const string& country, const list<string>& videoUrls, int fansNum, int contribute, const RoomTopFanList& fans) override;
    // 观众退出直播间回调
    void OnFansRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) override;
    // 发送直播间文本消息回调
    void OnSendRoomMsg(SEQ_T reqId, LCC_ERR_TYPE err, const string& errMsg) override;
    // 获取直播间信息
    void OnGetRoomInfo(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, int fansNum, int contribute) override;
    
    // 服务端主动请求
    // 接收直播间关闭通知(观众)
    void OnRecvRoomCloseFans(const string& roomId, const string& userId, const string& nickName, int fansNum) override;
    // 接收直播间关闭通知(直播)
    void OnRecvRoomCloseBroad(const string& roomId, int fansNum, int inCome, int newFans, int shares, int duration) override;
    // 接收观众进入直播间通知
    void OnRecvFansRoomIn(const string& roomId, const string& userId, const string& nickName, const string& photoUrl) override;
    // 接收直播间文本消息通知
    void OnRecvRoomMsg(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg) override;

};
