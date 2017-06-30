/*
 * author: Samson.Fan
 *   date: 2017-05-09
 *   file: IImClient.h
 *   desc: IM客户端接口类
 *   注意不能在[客户端主动请求]回调函数里面再次调用接口
 */

#pragma once

#include "IImClientDef.h"

#define SEQ_T unsigned int

// IM客户端监听接口类
class IImClientListener
{
public:
	IImClientListener() {};
	virtual ~IImClientListener() {}

public:
	// ------------- 登录/注销 -------------
    virtual void OnLogin(LCC_ERR_TYPE err, const string& errmsg) {}
    virtual void OnLogout(LCC_ERR_TYPE err, const string& errmsg) {}
    // 2.4.用户被挤掉线
    virtual void OnKickOff(const string reason) {}
    
    // ------------- 直播间处理(非消息) -------------
    // 观众进入直播间回调
    virtual void OnFansRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& userId, const string& nickName, const string& photoUrl, const string& country, const list<string>& videoUrls, int fansNum, int contribute, const RoomTopFanList& fans) {};
    // 观众退出直播间回调
    virtual void OnFansRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {};
    // 接收直播间关闭通知(观众)
    virtual void OnRecvRoomCloseFans(const string& roomId, const string& userId, const string& nickName, int fansNum) {};
    // 接收直播间关闭通知(直播)
    virtual void OnRecvRoomCloseBroad(const string& roomId, int fansNum, int inCome, int newFans, int shares, int duration) {};
    // 接收观众进入直播间通知
    virtual void OnRecvFansRoomIn(const string& roomId, const string& userId, const string& nickName, const string& photoUrl) {};
    // 获取直播间信息
    virtual void OnGetRoomInfo(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, int fansNum, int contribute) {};
    // 3.7.主播禁言观众（直播端把制定观众禁言）
    virtual void OnFansShutUp(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {};
    // 3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）
    virtual void OnRecvShutUpNotice(const string& roomId, const string& userId, const string& nickName, int timeOut){};
    // 3.9.主播踢观众出直播间（主播端把指定观众踢出直播间）
    virtual void OnFansKickOffRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {};
    // 3.10.接收观众踢出直播间通知（观众端／主播端接收观众踢出直播间通知）
    virtual void OnRecvKickOffRoomNotice(const string& roomId, const string& userId, const string& nickName) {};
    
    // ------------- 直播间处理(非消息) -------------
    // 发送直播间文本消息回调
    virtual void OnSendRoomMsg(SEQ_T reqId, LCC_ERR_TYPE err, const string& errMsg) {};
    // 接收直播间文本消息通知
    virtual void OnRecvRoomMsg(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg) {};
    
    // ------------- 直播间点赞 -------------
    // 5.1.发送直播间点赞消息（观众端向直播间发送点赞消息）
    virtual void OnSendRoomFav(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {};
    // 5.2.接收直播间点赞通知（观众端／主播端接收服务器的直播间点赞通知）
    virtual void OnRecvPushRoomFav(const string& roomId, const string& fromId, const string& nickName, bool isFirst) {};
    
    // ------------- 直播间礼物消息 -------------
    // 6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
    virtual void OnSendRoomGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double coins) {};
    // 6.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
    virtual void OnRecvRoomGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) {};

    // ------------- 直播间弹幕消息 -------------
    // 7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
    virtual void OnSendRoomToast(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double coins) {};
    // 7.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
    virtual void OnRecvRoomToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg) {};
};

// IM客户端接口类
class IImClient
{
public:
    typedef enum _tLoginStatus{
        LOGINING,   // login中
        LOGINED,    // 已login
        LOGOUT,     // logout
    } LoginStatus;
    
public:
	static IImClient* CreateClient();
	static void ReleaseClient(IImClient* client);

public:
	IImClient(void) {};
	virtual ~IImClient(void) {};

public:
	// 调用所有接口函数前需要先调用Init
	virtual bool Init(const list<string>& urls) = 0;
    // 增加监听器
    virtual void AddListener(IImClientListener* listener) = 0;
    // 移除监听器
    virtual void RemoveListener(IImClientListener* listener) = 0;
	// 判断是否无效seq
	virtual bool IsInvalidReqId(SEQ_T reqId) = 0;
	// 获取reqId
	virtual SEQ_T GetReqId() = 0;
    
    // --------- 登录/注销 ---------
	// 登录
	virtual bool Login(const string& user, const string& password, ClientType clientType) = 0;
	// 注销
	virtual bool Logout() = 0;
    // 获取login状态
    virtual LoginStatus GetLoginStatus() = 0;
    
    // --------- 直播间 ---------
    // 观众进入直播间
    virtual bool FansRoomIn(SEQ_T reqId, const string& token, const string& roomId) = 0;
    // 观众退出直播间
    virtual bool FansRoomOut(SEQ_T reqId, const string& token, const string& roomId) = 0;
    // 获取直播间信息
    virtual bool GetRoomInfo(SEQ_T reqId, const string& token, const string& roomId) = 0;
    // 3.7.主播禁言观众（直播端把制定观众禁言）
    virtual bool FansShutUp(SEQ_T reqId, const string& roomId, const string& userId, int timeOut) = 0;
    // 3.9.主播踢观众出直播间（主播端把指定观众踢出直播间）
    virtual bool FansKickOffRoom(SEQ_T reqId, const string& roomId, const string& userId) = 0;
    
    // --------- 直播间文本消息 ---------
    // 发送直播间文本消息
    virtual bool SendRoomMsg(SEQ_T reqId, const string& token, const string& roomId, const string& nickName, const string& msg) = 0;
    
    // ------------- 直播间点赞 -------------
    // 5.1.发送直播间点赞消息（观众端向直播间发送点赞消息）
    virtual bool SendRoomFav(SEQ_T reqId, const string& roomId, const string& token, const string& nickName) = 0;
    
    // ------------- 直播间点赞 -------------
    // 6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
    virtual bool SendRoomGift(SEQ_T reqId, const string& roomId, const string& token, const string& nickName, const string& giftId, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) = 0;

    // ------------- 直播间弹幕消息 -------------
    // 7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
    virtual bool SendRoomToast(SEQ_T reqId, const string& roomId, const string& token, const string& nickName, const string& msg) = 0;
    
public:
	// 获取用户账号
	virtual string GetUser() = 0;
};
