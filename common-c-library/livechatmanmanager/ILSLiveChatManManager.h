/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: ILSLiveChatManManager.h
 *   desc: LiveChat男士Manager接口类
 */

#pragma once

#include "LSLCUserItem.h"
#include "LSLCMessageItem.h"
#include "ILSLiveChatManManagerEnumDef.h"
#include <manrequesthandler/LSLiveChatRequestLiveChatDefine.h>
#include <manrequesthandler/item/LSLCOther.h>
#include <manrequesthandler/item/LSLCMagicIconConfig.h>
#include "LSLCAutoInviteItem.h"

class ILSLiveChatManManagerListener
{
public:
	ILSLiveChatManManagerListener() {};
	virtual ~ILSLiveChatManManagerListener() {};

public:
	// ------- login/logout listener -------
	virtual void OnLogin(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errMsg, bool isAutoLogin) = 0;
	virtual void OnLogout(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errMsg, bool isAutoLogin) = 0;
	
	// ------- online status listener -------
	virtual void OnRecvKickOffline(KICK_OFFLINE_TYPE kickType) = 0;
	virtual void OnSetStatus(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errMsg) = 0;
	virtual void OnChangeOnlineStatus(LSLCUserItem* userItem) = 0;
	virtual void OnGetUserStatus(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errMsg, const LCUserList& userList) = 0;
	virtual void OnUpdateStatus(LSLCUserItem* userItem) = 0;
    
    // ------- user info listener -------
    virtual void OnGetUserInfo(int seq, const string& userId, LSLIVECHAT_LCC_ERR_TYPE errType, const string& errMsg, const UserInfoItem& userInfo) = 0;
    virtual void OnGetUsersInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int seq, const list<string>& userIdList, const UserInfoList& userList) = 0;
    virtual void OnGetContactList(CONTACT_LIST_TYPE inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkUserList& userList) = 0;
	
	// ------- chat status listener -------
	virtual void OnGetTalkList(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errMsg) = 0;
	virtual void OnEndTalk(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errMsg, LSLCUserItem* userItem) = 0;
	virtual void OnRecvTalkEvent(LSLCUserItem* userItem) = 0;
	
	// ------- notice listener -------
	virtual void OnRecvEMFNotice(const string& fromId, TALK_EMF_NOTICE_TYPE noticeType) = 0;
	
	// ------- try ticket listener -------
	virtual void OnCheckCoupon(bool success, const string& errNo, const string& errMsg, const string& userId, CouponStatus status) = 0;
	virtual void OnRecvTryTalkBegin(LSLCUserItem* userItem, int time) = 0;
	virtual void OnRecvTryTalkEnd(LSLCUserItem* userItem) = 0;
	virtual void OnUseTryTicket(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, TRY_TICKET_EVENT tickEvent) = 0;	

	// ------- message listener -------
	virtual void OnRecvEditMsg(const string& fromId) = 0;
	virtual void OnRecvMessage(LSLCMessageItem* msgItem) = 0;
	virtual void OnRecvSystemMsg(LSLCMessageItem* msgItem) = 0;
	virtual void OnRecvWarningMsg(LSLCMessageItem* msgItem) = 0;
	virtual void OnSendTextMessage(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errMsg, LSLCMessageItem* msgItem) = 0;
	virtual void OnSendMessageListFail(LSLIVECHAT_LCC_ERR_TYPE errType, const LCMessageList& msgList) = 0;
	virtual void OnGetHistoryMessage(bool success, const string& errNo, const string& errMsg, LSLCUserItem* userItem) = 0;
	virtual void OnGetUsersHistoryMessage(bool success, const string& errNo, const string& errMsg, const LCUserList& userList) = 0;

	// ------- emotion listener -------
	virtual void OnGetEmotionConfig(bool success, const string& errNo, const string& errMsg, const LSLCOtherEmotionConfigItem& config) = 0;
	virtual void OnGetEmotionImage(bool success, const LSLCEmotionItem* item) = 0;
	virtual void OnGetEmotionPlayImage(bool success, const LSLCEmotionItem* item) = 0;
	virtual void OnRecvEmotion(LSLCMessageItem* msgItem) = 0;
	virtual void OnSendEmotion(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errMsg, LSLCMessageItem* msgItem) = 0;

	// ------- voice listener -------
	virtual void OnGetVoice(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errNo, const string& errMsg, LSLCMessageItem* msgItem) = 0;
	virtual void OnRecvVoice(LSLCMessageItem* msgItem) = 0;
	virtual void OnSendVoice(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errNo, const string& errMsg, LSLCMessageItem* msgItem) = 0;

	// ------- photo listener -------
	virtual void OnGetPhoto(GETPHOTO_PHOTOSIZE_TYPE sizeType, LSLIVECHAT_LCC_ERR_TYPE errType, const string& errNo, const string& errMsg, const LCMessageList& msglist) = 0;
	virtual void OnPhotoFee(bool success, const string& errNo, const string& errMsg, LSLCMessageItem* msgItem) = 0;
	virtual void OnRecvPhoto(LSLCMessageItem* msgItem) = 0;
	virtual void OnSendPhoto(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errNo, const string& errMsg, LSLCMessageItem* msgItem) = 0;
    virtual void OnCheckPhoto(bool success, const string& errNo, const string& errMsg, LSLCMessageItem* msgItem) = 0;

	// ------- video listener -------
	virtual void OnGetVideo(
			LSLIVECHAT_LCC_ERR_TYPE errType
			, const string& userId
			, const string& videoId
			, const string& inviteId
			, const string& videoPath
			, const LCMessageList& msgList) = 0;
	virtual void OnGetVideoPhoto(
			LSLIVECHAT_LCC_ERR_TYPE errType
			, const string& errNo
			, const string& errMsg
			, const string& userId
			, const string& inviteId
			, const string& videoId
			, VIDEO_PHOTO_TYPE
			, const string& filePath
			, const LCMessageList& msgList) = 0;
	virtual void OnRecvVideo(LSLCMessageItem* msgItem) = 0;
	virtual void OnVideoFee(bool success, const string& errNo, const string& errMsg, LSLCMessageItem* msgItem) = 0;
    
    //------- magicIcon listener -------
	// 小高级表情配置的回调（在Onlogin 更新／获取小高级表情配置）
    virtual void OnGetMagicIconConfig(bool success, const string& errNo, const string& errMsg, const LSLCMagicIconConfig& config) = 0;
    // 手动下载／更新小高级表情原图下载
	virtual void OnGetMagicIconSrcImage(bool success, const LSLCMagicIconItem* item) = 0;
	// 手动下载／更新小高级表情拇子图
    virtual void OnGetMagicIconThumbImage(bool success, const LSLCMagicIconItem* item) = 0;
	// 发送小高级表情
    virtual void OnSendMagicIcon(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errMsg, LSLCMessageItem* msgItem) = 0;
	// 接收小高级表情
    virtual void OnRecvMagicIcon(LSLCMessageItem* msgItem) = 0;
    
    //------- camshare listener -------
    virtual void OnRecvCamAcceptInvite(const string& userId, bool isAccept) = 0;
    virtual void OnRecvCamInviteCanCancel(const string& userId) = 0;
    virtual void OnRecvCamDisconnect(LSLIVECHAT_LCC_ERR_TYPE errType, const string& userId) = 0;
    virtual void OnRecvLadyCamStatus(const string& userId, bool isOpenCam) = 0;
    virtual void OnRecvBackgroundTimeout(const string& userId) = 0;
    virtual void OnGetLadyCamStatus(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE errType, const string& errmsg, bool isOpenCam) = 0;
    virtual void OnCheckCamCoupon(bool success, const string& errNo, const string& errMsg, const string& userId, CouponStatus status, int couponTime) = 0;
    virtual void OnUseCamCoupon(LSLIVECHAT_LCC_ERR_TYPE errType, const string& errmsg, const string& userId) = 0;
    
    // 根据http的接口错误码是token过期回调到上层处理
    virtual void OnTokenOverTimeHandler(const string& errNo, const string& errmsg) = 0;
    
    // -------- invite listener -----
    // 为了区分OnRecvMessage,这个使用在Qn冒泡跳转到直播后，发送邀请语成功，如果用OnRecvMessage，直播会再冒泡 (Alex, 2019-07-26)
    virtual void OnRecvAutoInviteMessage(LSLCMessageItem* msgItem) = 0;
};

class LSLiveChatHttpRequestManager;
class ILSLiveChatManManager
{
public:
	static ILSLiveChatManManager* Create();
	static void Release(ILSLiveChatManManager* obj);

protected:
	ILSLiveChatManManager() {}
	virtual ~ILSLiveChatManManager() {}

public:
	// -------- 初始化/登录/注销 --------
	// 初始化
	virtual bool Init(list<string> ipList
					, int port
					, OTHER_SITE_TYPE siteType
					, const string& webHost
					, const string& appHost
					, const string& chatVoiceHost
					, const string& httpUser
					, const string& httpPassword
					, const string& appVer
                    , const string& appId
					, const string& path
					, double minBalance
                    , double minCamshareBalance
					, ILSLiveChatManManagerListener* listener) = 0;
	// 登录
	virtual bool Login(const string& userId, const string& userName, const string& sid, CLIENT_TYPE clientType, const list<string>& cookies, const string& deviceId, LIVECHATINVITE_RISK_TYPE riskType, bool liveChatRisk, bool camShareRisk, bool isSendPhotoPriv, bool liveChatPriv, bool isSendVoicePriv) = 0;
	// 注销
	virtual bool Logout(bool isResetParam) = 0;
    // 重新登录
    virtual bool Relogin() = 0;
	// 是否已经登录
	virtual bool IsLogin() = 0;
    // 是否获取历史记录
    virtual bool IsGetHistory() = 0;
    // 获取原始socket
    virtual int GetSocket() = 0;
    // 根据错误码判断是否时余额不足
    virtual bool IsNoMoneyWithErrCode(const string& errCode) = 0;
    
	// ---------- 会话操作 ----------
	// 检测是否可使用试聊券
	virtual bool CheckCoupon(const string& userId) = 0;
	// 结束会话, 判断是否是livechat 还是camshare endtalk
	virtual bool EndTalk(const string& userId, bool isLiveChat) = 0;
    // 结束会话，没有根据是否是livechat还是camshare会话（用于停止所有会话）
    virtual bool EndTalkWithNoType(const string& userId) = 0;
    
    // ---------- 在线状态操作 ----------
    // 获取用户状态(多个)
    virtual bool GetUserStatus(const list<string>& userIds) = 0;
    
    // ---------- 获取用户信息操作 ----------
    // 获取用户信息
    virtual int GetUserInfo(const string& userId) = 0;
    // 获取多个用户信息
    virtual int GetUsersInfo(const list<string>& userList) = 0;
    // 获取登录用户server
    virtual string GetMyServer() = 0;

	// ---------- 公共操作 ----------
	// 获取指定消息Id的消息Item
	virtual LSLCMessageItem* GetMessageWithMsgId(const string& userId, int msgId) = 0;
	// 获取指定用户Id的用户item
	virtual LSLCUserItem* GetUserWithId(const string& userId) = 0;
	// 获取邀请的用户列表（使用前需要先完成GetTalkList()调用）
	virtual LCUserList GetInviteUsers() = 0;
	// 获取最后一个邀请用户
	virtual LSLCUserItem* GetLastInviteUser() = 0;
	// 获取在聊用户列表（使用前需要先完成GetTalkList()调用）
	virtual LCUserList GetChatingUsers() = 0;
    // 获取男士自动邀请用户列表（使用前需要先完成GetTalkList()调用）
    virtual LCUserList GetManInviteUsers() = 0;
    // 获取在聊用户列表某个用户InChat状态
    virtual bool IsChatingUserInChatState(const string& userId) = 0;
//    // 获取用户最后一条聊天消息
//    virtual LSLCMessageItem* GetLastMessage(const string& userId) = 0;
//    // 获取对方最后一条聊天消息
//    virtual LSLCMessageItem* GetTheOtherLastMessage(const string& userId) = 0;
    // 获取用户第一条邀请聊天记录是否超过1分钟
    virtual bool IsInManInviteCanCancel(const string& userId)  = 0;
    // 是否处于男士邀请状态
    virtual bool IsInManInvite(const string& userId) = 0;
    // 获取对方最后一条聊天消息(返回true是有messageItem，false是没有messageItem，防止LCMessageItem转换OC类型时，指针被其他线程清除记录)
    virtual bool GetOtherUserLastRecvMessage(const string& userId, LSLCMessageItem& message) = 0;
    // 获取用户最后一条聊天消息(返回MessageItem类型，不是指针，防止LCMessageItem转换OC类型时，指针被其他线程清除记录)
    virtual bool GetOtherUserLastMessage(const string& userId, LSLCMessageItem& messageItem) = 0;
    // 获取用户的私密照和视频的消息
    virtual LCMessageList GetPrivateAndVideoMessageList(const string& userId) = 0;

	// -------- 文本消息 --------
	// 发送文本消息
	virtual LSLCMessageItem* SendTextMessage(const string& userId, const string& message) = 0;
	// 获取单个用户历史聊天记录（包括文本、高级表情、语音、图片）
	virtual bool GetHistoryMessage(const string& userId) = 0;
	// 删除历史消息记录
	virtual bool RemoveHistoryMessage(const string& userId, int msgId) = 0;
	// 插入历史消息记录
	virtual bool InsertHistoryMessage(const string& userId, LSLCMessageItem* msgItem) = 0;
	// 获取消息处理状态
	virtual StatusType GetMessageItemStatus(const string& userId, int msgId) = 0;

	// --------- 高级表情消息 --------
	// 发送高级表情
	virtual LSLCMessageItem* SendEmotion(const string& userId, const string& emotionId) = 0;
	// 获取高级表情配置item
	virtual LSLCOtherEmotionConfigItem GetEmotionConfigItem() const = 0;
	// 获取高级表情item
	virtual LSLCEmotionItem* GetEmotionInfo(const string& emotionId) = 0;
	// 手动下载/更新高级表情图片文件
	virtual bool GetEmotionImage(const string& emotionId) = 0;
	// 手动下载/更新高级表情图片文件
	virtual bool GetEmotionPlayImage(const string& emotionId) = 0;

	// ---------- 语音消息 ----------
	// 发送语音（包括获取语音验证码(livechat)、上传语音文件(livechat)、发送语音(livechat)）
	virtual LSLCMessageItem* SendVoice(const string& userId, const string& voicePath, const string& fileType, int timeLength) = 0;
	// 获取语音（包括下载语音(livechat)）
	virtual bool GetVoice(const string& userId, int msgId) = 0;

	// ---------- 图片消息 ----------
	// 发送图片（包括上传图片文件(php)、发送图片(livechat)）
	virtual LSLCMessageItem* SendPhoto(const string& userId, const string& photoPath) = 0;
	// 购买图片（包括付费购买图片(php)）
	//virtual bool PhotoFee(const string& userId, int msgId) = 0;
    // 购买图片（包括付费购买图片(php)）
    virtual bool PhotoFee(const string& userId, const string& photoId, const string& inviteId) = 0;
	// 根据消息ID获取图片(模糊或清晰)（包括获取/下载对方私密照片(php)、显示图片(livechat)）    
    virtual bool GetPhoto(const string& userId, const string& photoId, GETPHOTO_PHOTOSIZE_TYPE sizeType, SendType sendType) = 0;
    // 检查私密照片是否已付费
    virtual bool CheckPhoto(const string& userId, const string& photoId) = 0;

	// --------- 视频消息 --------
	// 获取微视频图片
	virtual bool GetVideoPhoto(const string& userId, const string& videoId, const string& inviteId) = 0;
	// 购买微视频
	virtual bool VideoFee(const string& userId, const string& videoId, const string& inviteId) = 0;
	// 获取微视频播放文件
	virtual bool GetVideo(const string& userId, const string& videoId, const string& inviteId, const string& videoUrl, int msgId) = 0;
	// 获取视频当前下载状态
	virtual bool IsGetingVideo(const string& videoId) = 0;
	// 获取视频图片文件路径（仅文件存在）
	virtual string GetVideoPhotoPathWithExist(const string& userId, const string& inviteId, const string& videoId, VIDEO_PHOTO_TYPE type) = 0;
	// 获取视频文件路径（仅文件存在）
	virtual string GetVideoPathWithExist(const string& userId, const string& inviteId, const string& videoId) = 0;
    
    // --------- 小高级表情消息 --------
    // 发送小高级表情消息
    virtual LSLCMessageItem* SendMagicIcon(const string& userId, const string& iconId) = 0;
    // 获取小高级表情配置item
    virtual LSLCMagicIconConfig GetMagicIconConfigItem() const = 0;
    // 获取小高级表情item
    virtual LSLCMagicIconItem* GetMagicIconInfo(const string& magicIconId) = 0;
    // 手动下载／更新小高级表情原图
    virtual bool GetMagicIconSrcImage(const string& magicIconId) = 0;
    // 手动下载／更新小高级表情拇子图
    virtual bool GetMagicIconThumbImage(const string& magicIconId) = 0;
    //获取小高级表情原图的路径
    virtual string GetMagicIconThumbPath(const string& magicIconId) = 0;
    // 发送邀请语
    virtual bool SendInviteMessage(const string& userId, const string& message, const string& nickName) = 0;
    
    // --------- Camshare --------
    // 发送Camshare邀请
    virtual bool SendCamShareInvite(const string& userId) = 0;
    // 接受女士发过来的Camshare邀请
    virtual bool AcceptLadyCamshareInvite(const string& userId) = 0;
    // 获取Camshare女士状态
    virtual bool GetLadyCamStatus(const string& userId) = 0;
    // 检查Camshare女士试聊券
    virtual bool CheckCamCoupon(const string& userId) = 0;
    // 更新收到视频流时间
    virtual bool UpdateRecvVideo(const string& userId) = 0;
    // 检查用户是否Camshare会话中
    virtual bool IsCamshareInChat(const string& userId) = 0;
    // 检查用户最后一条消息是否是Camshare邀请
    virtual bool IsCamshareInviteMsg(const string& userId) = 0;
    // 检测是否需要上传视频
    virtual bool IsUploadVideo() = 0;
    // 检查用户是否Camshare被邀请
    virtual bool IsCamShareInvite(const string& userId) = 0;
    // 设置Camshare会话前后台
    virtual bool SetCamShareBackground(const string& userId, bool background) = 0;
    // 设置Camshare心跳超时步长
    virtual bool SetCheckCamShareHeartBeatTimeStep(int timeStep) = 0;
};
