/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file: LiveChatManManager.h
 *   desc: LiveChat男士Manager
 */

#pragma once

#include "ILSLiveChatManManager.h"
#include "ILSLiveChatManManagerOperator.h"

#include <livechat/ILSLiveChatClient.h>
#include <livechat/LSLiveChatCounter.h>
#include <livechat/ILSLiveChatThreadHandler.h>

#include <manrequesthandler/LSLiveChatRequestLiveChatController.h>
#include <manrequesthandler/LSLiveChatRequestOtherController.h>

#include <common/map_lock.h>
#include <common/CommonFunc.h>

#include "LSLCUserItem.h"
#include "LSLCEmotionManager.h"
#include "LSLCPhotoManager.h"
#include "LSLCVideoManager.h"
#include "LSLCMagicIconManager.h"

#include "LSLiveChatCamshareManager.h"
#include "LSLiveChatSessionManager.h"
#include "LSLiveChatSender.h"

#include <list>
#include <string>
using namespace std;

// 消息管理器
class LSLCTextManager;
class LSLCVoiceManager;
class LSLCVideoManager;
// 用户管理器
class LSLCUserManager;
class LSLCInviteManager;
class LSLCBlockManager;
class LSLCContactManager;
// LiveChat客户端
class ILiveChatClient;
// 其它
class ILSLiveChatThreadHandler;
class IAutoLock;

class RequestItem;
class LSLiveChatManManager : public ILSLiveChatManManager
								, ILSLiveChatClientListener
                                , ILSLiveChatManManagerOperator
                                , ILSLiveChatManManagerTaskCallback
								, ILSLiveChatRequestLiveChatControllerCallback
								, ILSLiveChatRequestOtherControllerCallback
								, LSLCEmotionManagerCallback
								, LSLCPhotoManagerCallback
								, LSLCVideoManagerCallback
                                , LSLCMagicIconManagerCallback
{
public:
    LSLiveChatManManager();
    virtual ~LSLiveChatManManager();

public:
    /******************************************* 定时任务处理 *******************************************/
    // 定时任务结构体
    typedef struct _tagTaskItem
    {
        ILSLiveChatManManagerTaskCallback* callback;
        unsigned long long param;
        long long delayTime;
        
        _tagTaskItem()
        {
            callback = NULL;
            param = 0;
            delayTime = -1;
        }
        
        _tagTaskItem(const _tagTaskItem& item)
        {
            callback = item.callback;
            param = item.param;
            delayTime = item.delayTime;
        }
        
        void SetDelayTime(long milliseconds)
        {
            delayTime = getCurrentTime() + milliseconds;
        }
        
    } TaskItem;
    
    // 插入任务到处理队列
    void InsertRequestTask(ILSLiveChatManManagerTaskCallback* callback, TaskParam param, long long delayTime = -1) override;
    // 处理队列任务实现
    void OnLiveChatManManagerTaskRun(TaskParam param) override;
    // 处理队列任务不能实现
    void OnLiveChatManManagerTaskClose(TaskParam param) override;
    // 定时业务处理器
    void RequestHandler(RequestItem* item);
    
private:
    // 定时任务处理队列
    list<TaskItem*>	m_requestQueue;
    // 定时任务处理队列锁
    IAutoLock* m_requestQueueLock;
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
    
    // 请求线程
    ILSLiveChatThreadHandler*	m_requestThread;
    // 请求线程启动标记
    bool m_requestThreadStart;
    
    /******************************************* 定时任务处理 End *******************************************/
    
public:
    /******************************************* 提供给外部获取的状态 *******************************************/
    // 是否自动登录
    bool IsAutoLogin() override;
    // 是否已经登录
    virtual bool IsLogin() override;
    // 是否已经获取历史记录
    virtual bool IsGetHistory() override;
    // 获取登录用户Id
    string GetUserId() override;
    // 获取用户名
    string GetUserName() override;
    // 获取登录用户Sid
    string GetSid() override;
    // 获取站点ID
    int GetSiteType() override;
    // 获取最小点数
    double GetMinBalance() override;
    /******************************************* 提供给外部获取的状态 End *******************************************/
    
public:
    /******************************************* 本地生成消息 *******************************************/
    // 根据错误类型生成警告消息
    void BuildAndInsertWarningWithErrType(const string& userId, LSLIVECHAT_LCC_ERR_TYPE errType) override;
    // 生成警告消息
    void BuildAndInsertWarningMsg(const string& userId, WarningCodeType codeType) override;
    // 生成系统消息
    void BuildAndInsertSystemMsg(const string& userId, CodeType codeType) override;
    /******************************************* 本地生成消息 End *******************************************/
    
public:
    // 改变用户状态
    void SetUserOnlineStatusWithLccErrType(LSLCUserItem* userItem, LSLIVECHAT_LCC_ERR_TYPE errType) override;
private:
    // 改变用户状态
    void SetUserOnlineStatus(LSLCUserItem* userItem, USER_STATUS_TYPE statusType);
    
public:
	// -------- 初始化/登录/注销 --------
	// 初始化
	bool Init(list<string> ipList
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
					, ILSLiveChatManManagerListener* listener) override;
	// 登录
	bool Login(const string& userId, const string& userName, const string& sid, CLIENT_TYPE clientType, const list<string>& cookies, const string& deviceId, bool isRecvVideoMsg, LIVECHATINVITE_RISK_TYPE riskType, bool liveChatRisk, bool camShareRisk) override;
	// 注销
	bool Logout(bool isResetParam) override;
    // 重新登录
    bool Relogin() override;
    // 获取原始socket
    int GetSocket() override;
    
	// ---------- 会话操作 ----------
	// 检测是否可使用试聊券
	bool CheckCoupon(const string& userId) override;
	// 结束会话, 判断是否是livechat 还是camshare endtalk
	bool EndTalk(const string& userId, bool isLiveChat) override;
    // 结束会话，没有根据是否是livechat还是camshare会话（用于停止所有会话）
    bool EndTalkWithNoType(const string& userId) override;
    // ---------- 在线状态操作 ----------
    // 获取用户状态(多个)
    bool GetUserStatus(const list<string>& userIds) override;
    
    // ---------- 获取用户信息操作 ----------
    // 获取用户信息
    int GetUserInfo(const string& userId) override;
    // 获取多个用户信息
    int GetUsersInfo(const list<string>& userList) override;
    // 获取登录用户server
    string GetMyServer() override;
    
	// ---------- 公共操作 ----------
	// 获取指定消息Id的消息Item
	LSLCMessageItem* GetMessageWithMsgId(const string& userId, int msgId) override;
	// 获取指定用户Id的用户item
	LSLCUserItem* GetUserWithId(const string& userId) override;
	// 获取邀请的用户列表（使用前需要先完成GetTalkList()调用）
	LCUserList GetInviteUsers() override;
	// 获取最后一个邀请用户
	LSLCUserItem* GetLastInviteUser() override;
	// 获取在聊用户列表（使用前需要先完成GetTalkList()调用）
	LCUserList GetChatingUsers() override;
    // 获取男士自动邀请用户列表（使用前需要先完成GetTalkList()调用）
    LCUserList GetManInviteUsers() override;
    // 获取在聊用户列表某个用户InChat状态
    bool IsChatingUserInChatState(const string& userId) override;
//    // 获取用户最后一条聊天消息
//    LSLCMessageItem* GetLastMessage(const string& userId) override;
//    // 获取对方最后一条聊天消息
//    LSLCMessageItem* GetTheOtherLastMessage(const string& userId) override;
    // 获取用户第一条邀请聊天记录是否超过2分钟
    bool IsInManInviteCanCancel(const string& userId) override;
    // 是否处于男士邀请状态
    bool IsInManInvite(const string& userId) override;
    // 获取对方最后一条聊天消息(返回MessageItem类型，不是指针，防止LCMessageItem转换OC类型时，指针被其他线程清除记录)
    bool GetOtherUserLastRecvMessage(const string& userId, LSLCMessageItem& messageItem) override;
    // 获取用户最后一条聊天消息(返回MessageItem类型，不是指针，防止LCMessageItem转换OC类型时，指针被其他线程清除记录)
    bool GetOtherUserLastMessage(const string& userId, LSLCMessageItem& messageItem) override;
	// -------- 文本消息 --------
	// 发送文本消息
	LSLCMessageItem* SendTextMessage(const string& userId, const string& message) override;
	// 获取单个用户历史聊天记录（包括文本、高级表情、语音、图片）
	bool GetHistoryMessage(const string& userId) override;
	// 删除历史消息记录
	bool RemoveHistoryMessage(const string& userId, int msgId) override;
	// 插入历史消息记录
	bool InsertHistoryMessage(const string& userId, LSLCMessageItem* msgItem) override;
	// 获取消息处理状态
	StatusType GetMessageItemStatus(const string& userId, int msgId) override;

	// --------- 高级表情消息 --------
	// 发送高级表情
	LSLCMessageItem* SendEmotion(const string& userId, const string& emotionId) override;
	// 获取高级表情配置item
	LSLCOtherEmotionConfigItem GetEmotionConfigItem() const override;
	// 获取高级表情item
	LSLCEmotionItem* GetEmotionInfo(const string& emotionId) override;
	// 手动下载/更新高级表情图片文件
	bool GetEmotionImage(const string& emotionId) override;
	// 手动下载/更新高级表情图片文件
	bool GetEmotionPlayImage(const string& emotionId) override;

	// ---------- 语音消息 ----------
	// 发送语音（包括获取语音验证码(livechat)、上传语音文件(livechat)、发送语音(livechat)）
	LSLCMessageItem* SendVoice(const string& userId, const string& voicePath, const string& fileType, int timeLength) override;
	// 获取语音（包括下载语音(livechat)）
	bool GetVoice(const string& userId, int msgId) override;

	// ---------- 图片消息 ----------
	// 发送图片（包括上传图片文件(php)、发送图片(livechat)）
	LSLCMessageItem* SendPhoto(const string& userId, const string& photoPath) override;
	// 购买图片（包括付费购买图片(php)）
    bool PhotoFee(const string& userId, const string& photoId) override;
	// 根据消息ID获取图片(模糊或清晰)（包括获取/下载对方私密照片(php)、显示图片(livechat)）
    bool GetPhoto(const string& userId, const string& photoId, GETPHOTO_PHOTOSIZE_TYPE sizeType, SendType sendType) override;
    // 检查私密照片是否已付费
    bool CheckPhoto(const string& userId, const string& photoId) override;

	// --------- 视频消息 --------
	// 获取微视频图片
	bool GetVideoPhoto(const string& userId, const string& videoId, const string& inviteId) override;
	// 购买微视频
	bool VideoFee(const string& userId, int msgId) override;
	// 获取微视频播放文件
	bool GetVideo(const string& userId, const string& videoId, const string& inviteId, const string& videoUrl) override;
	// 获取视频当前下载状态
	bool IsGetingVideo(const string& videoId) override;
	// 获取视频图片文件路径（仅文件存在）
	string GetVideoPhotoPathWithExist(const string& userId, const string& inviteId, const string& videoId, VIDEO_PHOTO_TYPE type) override;
	// 获取视频文件路径（仅文件存在）
	string GetVideoPathWithExist(const string& userId, const string& inviteId, const string& videoId) override;
    
    // --------- 小高级表情消息（小高表） --------
    // 发送小高级表情
    LSLCMessageItem* SendMagicIcon(const string& userId, const string& iconId) override;
    // 获取小高级表情配置item
    LSLCMagicIconConfig GetMagicIconConfigItem() const override;
    // 获取小高级表情item
    LSLCMagicIconItem* GetMagicIconInfo(const string& magicIconId) override;
    // 手动下载／更新小高级表情原图
    bool GetMagicIconSrcImage(const string& magicIconId) override;
    // 手动下载／更新小高级表情拇子图
    bool GetMagicIconThumbImage(const string& magicIconId) override;
    //获取小高级表情原图的路径
    string GetMagicIconThumbPath(const string& magicIconId) override;
    
    // --------- Camshare --------
    // 发送Camshare邀请
    bool SendCamShareInvite(const string& userId) override;
    // 接受女士发过来的Camshare邀请
    bool AcceptLadyCamshareInvite(const string& userId) override;
    // 获取Camshare女士状态
    bool GetLadyCamStatus(const string& userId) override;
    // 检查Camshare女士试聊券
    bool CheckCamCoupon(const string& userId) override;
    // 更新收到视频流时间
    bool UpdateRecvVideo(const string& userId) override;
    // 检查用户是否Camshare会话中
    bool IsCamshareInChat(const string& userId) override;
    // 判断用户最后一条消息是否是camshare邀请
    bool IsCamshareInviteMsg(const string& userId) override;
    // 检测是否需要上传视频
    bool IsUploadVideo() override;
    // 检查用户是否Camshare被邀请
    bool IsCamShareInvite(const string& userId) override;
    // 设置Camshare会话前后台
    bool SetCamShareBackground(const string& userId, bool background) override;
    // 设置Camshare心跳超时步长
    bool SetCheckCamShareHeartBeatTimeStep(int timeStep) override;
private:
	// 获取log路径
	string GetLogPath();
	// 设置本地缓存目录路径
	bool SetDirPath(const string& path);
	// 设置http认证帐号
	bool SetAuthorization(const string& user, const string& password);
	// 清除所有图片、视频等资源文件
	void RemoveSourceFile();
	// 重置参数（用于非自动登录时重置参数）
	void ResetParamWithNotAutoLogin();
	// 重置参数（用于自动登录时重置参数）
	void ResetParamWithAutoLogin();
	// 是否自动重登录
	bool IsAutoRelogin(LSLIVECHAT_LCC_ERR_TYPE err);
	// 插入重登录任务
	void InsertReloginTask();
	// 自动重登录
	void AutoRelogin();
	// 是否处理发送操作
	bool IsHandleSendOpt();
    // 是否处理发送操作
    bool IsHandleRecvOpt();
	// 获取多个用户历史聊天记录（包括文本、高级表情、语音、图片）
	bool GetUsersHistoryMessage(const list<string>& userIds);
    // 判断是否是邀请状态（只包括男士要求，不包括女士邀请为了发送风控）
    bool IsManInviteChatState(const LSLCUserItem* userItem);
    // 清空用户历史记录（当endtalk的返回不是断网时就清空历史， 1.endtalk没发出去 2，onendtalk因为断网，返回ondisconnect 都不用清空历史）
    void CleanHistotyMessage(const string& userId);
    // --------- 所有消息 --------
    bool SendMsg(LSLCUserItem* userItem, LSLCMessageItem* msgItem);
	// --------- 高级表情消息 --------
	// 获取高级表情配置
	bool GetEmotionConfig();
	// 购买图片（包括付费购买图片(php)）
	bool PhotoFee(LSLCMessageItem* item);
    // 检查私密照片是否已付费
    bool CheckPhoto(LSLCMessageItem* item);
	// 获取图片(模糊或清晰)（包括获取/下载对方私密照片(php)、显示图片(livechat)）
	bool GetPhoto(LSLCMessageItem* item, GETPHOTO_PHOTOSIZE_TYPE sizeType);
    // --------- 小高级表情消息 --------
    // 获取小高级表情配置
    bool GetMagicIconConfig();
    
   // --------- 风控操作 ---------
    bool IsRecvInviteRisk(bool charge, TALK_MSG_TYPE msgType, INVITE_TYPE inviteType);
    
    
    
private:
    // -------- 回调获取聊天列表处理 ---------
    // livechat的获取聊天列表处理
    void OnGetTalkListLiveChatProc(const TalkListInfo& talkListInfo);
    // 公共获取聊天列表处理
    void OnGetTalkListPublicProc(const TalkListInfo& talkListInfo);
    
    
	// ------------------- LSLCEmotionManagerCallback -------------------
private:
	virtual void OnDownloadEmotionImage(bool result, LSLCEmotionItem* emotionItem) override;
	virtual void OnDownloadEmotionPlayImage(bool result, LSLCEmotionItem* emotionItem) override;

	// ------------------- LSLCPhotoManagerCallback -------------------
private:
	virtual void OnDownloadPhoto(bool success, GETPHOTO_PHOTOSIZE_TYPE sizeType, const string& errnum, const string& errmsg, const LCMessageList& msgList) override;
    virtual void OnManagerCheckPhoto( bool success, const string& errnum, const string& errmsg, LSLCMessageItem* msgItem) override;

	// ------------------- LSLCVideoManagerCallback -------------------
private:
		// 视频图片下载完成回调
	virtual void OnDownloadVideoPhoto(
					bool success
					, const string& errnum
					, const string& errmsg
					, const string& womanId
					, const string& inviteId
					, const string& videoId
					, VIDEO_PHOTO_TYPE type
					, const string& filePath
					, const LCMessageList& msgList) override;
	// 视频下载完成回调
	virtual void OnDownloadVideo(bool success, const string& userId, const string& videoId, const string& inviteId, const string& filePath, const LCMessageList& msgList) override;

    // ------------------- LSLCMagicIconManagerCallback -------------------
    // 小高级表情原图下载完成回调
    virtual void OnDownloadMagicIconImage(bool result, LSLCMagicIconItem* magicIconItem) override;
    // 小高级表情拇子图下载完成回调
    virtual void OnDownloadMagicIconThumbImage(bool result, LSLCMagicIconItem* magicIconItem) override;
    
	// ------------------- ILSLiveChatClientListener -------------------
private:
	// 客户端主动请求
	virtual void OnLogin(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
	virtual void OnLogout(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
	virtual void OnSetStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
	virtual void OnGetUserStatus(const UserIdList& inList, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserStatusList& userList) override;
	virtual void OnGetTalkInfo(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& invitedId, bool charge, unsigned int chatTime) override;
    virtual void OnEndTalk(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
	virtual void OnGetTalkList(int inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkListInfo& talkListInfo) override;
	virtual void OnShowPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) override;
	virtual void OnGetUserInfo(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserInfoItem& userInfo) override ;
	virtual void OnGetUsersInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int seq, const list<string>& userIdList, const UserInfoList& userList) override;;
	virtual void OnGetContactList(CONTACT_LIST_TYPE inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkUserList& userList) override;
	virtual void OnGetBlockUsers(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& users) override;
	virtual void OnSearchOnlineMan(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) override;
	virtual void OnReplyIdentifyCode(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
	virtual void OnGetRecentContactList(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) override;
	virtual void OnGetFeeRecentContactList(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList) override;
	virtual void OnGetLadyChatInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& chattingList, const list<string>& chattingInviteIdList, const list<string>& missingList, const list<string>& missingInviteIdList) override;
	virtual void OnPlayVideo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) override;
    
	// 服务器主动请求
	virtual void OnRecvMessage(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& message,INVITE_TYPE inviteType) override;
	virtual void OnRecvEmotion(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& emotionId) override;
	virtual void OnRecvVoice(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, TALK_MSG_TYPE msgType, const string& voiceId, const string& fileType, int timeLen) override;
	virtual void OnRecvWarning(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& message) override;
	virtual void OnUpdateStatus(const string& userId, const string& server, CLIENT_TYPE clientType, USER_STATUS_TYPE statusType) override;
	virtual void OnUpdateTicket(const string& fromId, int ticket) override;
	virtual void OnRecvEditMsg(const string& fromId) override;
	virtual void OnRecvTalkEvent(const string& userId, TALK_EVENT_TYPE eventType) override;
	virtual void OnRecvTryTalkBegin(const string& toId, const string& fromId, int time) override;
	virtual void OnRecvTryTalkEnd(const string& userId) override;
	virtual void OnRecvEMFNotice(const string& fromId, TALK_EMF_NOTICE_TYPE noticeType) override;
	virtual void OnRecvKickOffline(KICK_OFFLINE_TYPE kickType) override;
	virtual void OnRecvPhoto(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket) override;
	virtual void OnRecvShowPhoto(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDec, int ticket) override;
	virtual void OnRecvLadyVoiceCode(const string& voiceCode) override;
	virtual void OnRecvIdentifyCode(const unsigned char* data, long dataLen) override;
	virtual void OnRecvVideo(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket) override;
	virtual void OnRecvShowVideo(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDec, int ticket) override;
	void OnRecvMagicIcon(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& iconId) override;

	// ------------------- ILSLiveChatRequestLiveChatControllerCallback -------------------
private:
    virtual void OnCheckCoupon(long requestId, bool success, const LSLCCoupon& item, const string& userId, const string& errnum, const string& errmsg) override;
	virtual void OnQueryChatRecord(long requestId, bool success, int dbTime, const list<LSLCRecord>& recordList, const string& errnum, const string& errmsg, const string& inviteId) override;
	virtual void OnQueryChatRecordMutiple(long requestId, bool success, int dbTime, const list<LSLCRecordMutiple>& recordMutiList, const string& errnum, const string& errmsg) override;
	virtual void OnPhotoFee(long requestId, bool success, const string& errnum, const string& errmsg) override;
	virtual void OnGetPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath) override;
	virtual void OnUploadVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& voiceId) override;
	virtual void OnPlayVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath) override;
	virtual void OnGetVideoPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath) override;
	virtual void OnGetVideo(long requestId, bool success, const string& errnum, const string& errmsg, const string& url) override;
    //获取小高级表情配置回调 alex 2016-09-09
    virtual void OnGetMagicIconConfig(long requestId, bool success, const string& errnum, const string& errmsg,const LSLCMagicIconConfig& config) override;
    virtual void OnCheckPhoto(long requestId, bool success, const string& errnum, const string& errmsg) override;
    
	// ------------------- ILSLiveChatRequestOtherControllerCallback -------------------
private:
	virtual void OnEmotionConfig(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherEmotionConfigItem& item) override;

private:
	ILSLiveChatClient*                m_client;		// LiveChat客户端
	ILSLiveChatManManagerListener*	m_listener;     // 回调

	string          m_dirPath;			// 本地缓存目录路径
	list<string>	m_ipList;           // LiveChat服务器IP列表(从同步配置获取)
	int             m_port;				// LiveChat服务器端口(从同步配置获取)
	int             m_siteType;			// 站点ID
	string          m_appVer;			// app的版本号
	double          m_minBalance;		// 最少可以聊天的点数(从同步配置获取)
    double          m_minCamshareBalance;  // 最少可以camshare的点数(从同步配置获取)

	string          m_userId;                       // 用户Id
    string          m_userName;                     // 用户Name
	string          m_sId;                          // sId
    string          m_myServer;                     // 流媒体服务器名
    CLIENT_TYPE     m_clientType;                   // 设备类型
	list<string>	m_cookies;                      // cookies
	string          m_deviceId;                     // 设备唯一标识
	LIVECHATINVITE_RISK_TYPE            m_riskControl;                  // 风控标志（true:需要风控, 用于邀请风控）
    bool            m_riskLiveChat;                                     // livechat聊天风控
    bool            m_riskCamShare;                                     // camshare风控
	bool            m_isRecvVideoMsg;               // 是否接收视频消息
	bool            m_isLogin;                      // 是否已经登录
    bool            m_isGetHistory;                 // 是否获取历史记录
    bool            m_isResetParam;                 // 是否重置参数
	bool            m_isAutoLogin;                  // 是否尝试自动重登录（如断线后自动尝试重）
	long            m_getUsersHistoryMsgRequestId;	// 获取多个用户历史聊天记录的requestId
	LSLiveChatCounter         m_msgIdBuilder;                 // 消息ID生成器

	// 消息管理器
	LSLCTextManager*		m_textMgr;		// 文本管理器
	LSLCEmotionManager*	m_emotionMgr;	// 高级表情管理器
	LSLCVoiceManager*		m_voiceMgr;		// 语音管理器
	LSLCPhotoManager*		m_photoMgr;		// 图片管理器
	LSLCVideoManager*		m_videoMgr;		// 视频管理器
    //添加小高级管理器 alex 2016－09-09
    LSLCMagicIconManager* m_magicIconMgr; //小高级表情管理器

	// 用户管理器
	LSLCUserManager*		m_userMgr;		// 用户管理器
	LSLCInviteManager*	m_inviteMgr;	// 邀请管理器
	LSLCBlockManager*		m_blockMgr;		// 黑名单管理器
	LSLCContactManager*	m_contactMgr;	// 联系人管理器

    // 消息发送器材
    LSLiveChatSender* m_liveChatSender;
    // Livechat会话管理器
    LSLiveChatSessionManager* m_liveChatSessionManager;
    // Camshare会话管理器
    LSLiveChatCamshareManager* m_liveChatCamshareManager;
    
    // Http请求管理器
	LSLiveChatHttpRequestManager*	m_httpRequestManager;			// 请求管理器
	LSLiveChatHttpRequestHostManager* m_httpRequestHostManager;	// 请求host管理器
	LSLiveChatRequestLiveChatController* m_requestController;		// LiveChat请求控制器
	LSLiveChatRequestOtherController*	m_requestOtherController;	// Other请求控制器
};
