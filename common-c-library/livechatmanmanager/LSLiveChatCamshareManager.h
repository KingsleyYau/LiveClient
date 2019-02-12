//
//  LSLiveChatCamshareManager.h
//  Common-C-Library
//
//  Created by Max on 2017/2/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#ifndef LSLiveChatCamshareManager_h
#define LSLiveChatCamshareManager_h

#include <stdio.h>

#include "ILSLiveChatManManager.h"
#include "ILSLiveChatManManagerOperator.h"
#include "LSLiveChatSender.h"

#include "LSLCTextManager.h"
#include "LSLCEmotionManager.h"
#include "LSLCVoiceManager.h"
#include "LSLCPhotoManager.h"
#include "LSLCVideoManager.h"
#include "LSLCMagicIconManager.h"

#include "LSLCUserItem.h"
#include "LSLCUserManager.h"
#include "LSLCInviteManager.h"
#include "LSLCBlockManager.h"
#include "LSLCContactManager.h"

#include <manrequesthandler/LSLiveChatRequestLiveChatController.h>
#include <manrequesthandler/LSLiveChatRequestOtherController.h>

#include "LSLiveChatSender.h"
#include "LSLiveChatSession.h"

#include <livechat/LSLiveChatCounter.h>

using namespace LSLiveChatsession;

typedef map<string, LSLiveChatSession*> SessionMap;

class RequestItem;
class LSLiveChatCamshareManager : public ILSLiveChatManManagerTaskCallback
                                , public ILSLiveChatClientListener
                                , public ILSLiveChatRequestLiveChatControllerCallback
                                , public ILSLiveChatRequestOtherControllerCallback
{
public:
    LSLiveChatCamshareManager(
                           ILSLiveChatManManagerOperator* pOperator,
                           ILSLiveChatManManagerListener* pListener,
                           ILSLiveChatClient*	pClient,
                           LSLiveChatSender* pLSLiveChatSender,
                           LSLCUserManager* pUserMgr,
                           LSLCBlockManager* pBlockManager,
                           LSLiveChatHttpRequestManager* pHttpRequestManager
                           );
    
    ~LSLiveChatCamshareManager();
   
public:
    // 重置参数
    void Reset();
    
    // 开始任务
    void Start();
    
    // 发送消息
    bool SendMsg(LSLCUserItem* userItem, LSLCMessageItem* msgItem);
        
    // 发送Camshare邀请/应邀
    bool SendCamShareInvite(LSLCUserItem* userItem);
    // 结束会话
    bool EndTalk(LSLCUserItem* userItem);
    // 获取Camshare女士状态
    bool GetCamLadyStatus(LSLCUserItem* userItem);
    // 检查Camshare试聊券
    bool CheckCamCoupon(LSLCUserItem* userItem);
    // 更新收到视频流时间
    bool UpdateRecvVideo(LSLCUserItem* userItem);
    // 是否Camshare会话中
    bool IsCamShareInChat(LSLCUserItem* userItem);
    // 是否需要上传视频
    bool IsUploadVideo();
    // 是否Camshare的被邀请
    bool IsCamShareInvite(LSLCUserItem* userItem);
    // 设置Camshare前后台
    bool SetCamShareBackground(LSLCUserItem* userItem, bool bBackground);
    // 设置Camshare心跳超时步长
    bool SetCheckCamShareHeartBeatTimeStep(int timeStep);
    // 设置camshare最少点数
    void SetMinCamshareBalance(double balance);
    // 获取在聊列表
    void OnGetTalkList(const TalkListInfo& talkListInfo);
    // 收到女士Camshare邀请
    void OnRecvInviteMessage(const string& toId, const string& fromId, const string& inviteId, INVITE_TYPE inviteType);
    
    
private:
    // 是否能发送邀请
    bool CanSendInvite(LSLCUserItem* userItem);
    // 是否立即发送消息给用户
    bool IsSendMessageNow(LSLCUserItem* userItem);
    
    // 检查试聊券
    bool CheckCoupon(LSLiveChatSession* session);
    bool CheckInsideCoupon(LSLiveChatSession* session);
    void OnCheckCoupon(long requestId, bool success, const LSLCCoupon& item, const string& userId, const string& errnum, const string& errmsg) override;
    
    // 试聊券请求处理函数
    bool UseCoupon(LSLiveChatSession* session);
    void OnUseCoupon(long requestId, bool success, const string& errnum, const string& errmsg, const string& userId, const string& couponid) override;
    void OnCamshareUseTryTicket(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& ticketId, const string& inviteId) override;
    
    // 检查用户信息
    bool GetCount(LSLiveChatSession* session);
    void OnGetCount(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherGetCountItem& item) override;
    
    // 获取帐号余额，代替上面的OnGetCount
    bool GetLeftCreditProc(LSLiveChatSession* session);
    void OnGetLeftCredit(long requestId, bool success, int errnum, const string& errmsg, double credit, int coupon) override;
    
    // 获取camshare最少点数
    double GetMinCamshareBalance();
    
    // 根据状态判断发送邀请还是应邀
    bool SendCamShareInviteByStatus(LSLiveChatSession* session);
    
    // 直接发送邀请
    bool SendCamShareInviteCmd(LSLiveChatSession* session);
    void OnSendCamShareInvite(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    
    // 发送取消邀请
    bool SendCamShareCancelInviteCmd(LSLiveChatSession* session);
    // 发送结束会话
    bool SendEndTalkCmd(LSLiveChatSession* session);
    // 结束会话
    void OnEndTalk(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    
    // 直接发送应答
    bool SendCamShareApplyCmd(LSLiveChatSession* session);
    void OnApplyCamShare(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isSuccess, const string& targetId) override;
    
    // 收到女士应邀
    void OnRecvAcceptCamInvite(const string& fromId, const string& toId, CamshareLadyInviteType inviteType, int sessionId, const string& fromName, bool isCamOpen) override;
    
    // 发送会话心跳
    bool SendCamShareHeartBeat(LSLiveChatSession* session);
    void OnRecvCamHearbeatException(const string& exceptionName, LSLIVECHAT_LCC_ERR_TYPE err, const string& targetId) override;

    // 收到女士Camshare状态改变
    void OnRecvLadyCamStatus(const string& userId, USER_STATUS_PROTOCOL statusId, const string& server, CLIENT_TYPE clientType, CamshareLadySoundType sound, const string& version) override;
    
    // 邀请或者开启服务错误检测处理
    void ErrorCheck(const string& userId, LSLIVECHAT_LCC_ERR_TYPE err = LSLIVECHAT_LCC_ERR_FAIL);
    bool ErrorCheckLadyOnline(LSLiveChatSession* session);
    void OnGetUserInfo(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserInfoItem& userInfo) override;
    bool ErrorCheckLadyCam(LSLiveChatSession* session);
    // 获取女士Camshare状态回调
    void OnGetLadyCamStatus(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenCam) override;
    
    // 根据用户Id获取会话
    LSLiveChatSession* GetSessionByUserItem(LSLCUserItem* userItem);
    LSLiveChatSession* CreateSessionByUserItem(LSLCUserItem* userItem);
    void RemoveSessionByUserItem(LSLCUserItem* userItem);
    
    // 创建在聊的Camshare会话
    bool CreateCamShareInChatSession(LSLCUserItem* userItem);
    
    // 内部检查女士cam是否开启
    bool InsideGetLadyCamStatu(LSLiveChatSession* session);
    // 处理内部检查女士cam
    bool HandleCamshareCheckCoupon(LSLiveChatSession* session, LSLIVECHAT_LCC_ERR_TYPE err, bool isOpenCam);
    
    // -------------------------- 任务分发 --------------------------
    // 定时任务处理
    void OnLiveChatManManagerTaskRun(TaskParam param) override;
    void OnLiveChatManManagerTaskClose(TaskParam param) override;
    // 定时业务处理器
    void RequestHandler(RequestItem* item);
    // -------------------------- 任务分发 End --------------------------
    
    // -------------------------- 消息处理器 --------------------------
    // 发送所有会话心跳
    void SendAllSessionHeartBeat();
    // 检查所有会话视频超时
    void CheckAllSessionVideoTimeout();
    // 检查所有会话邀请超时
    void CheckAllSessionInviteTimeout();
    // 检查所有会话后台超时
    void CheckAllSessionBackgroundTimeout();
    // -------------------------- 消息处理器 End --------------------------
    
    // 公共信息获取
    ILSLiveChatManManagerOperator* m_operator;
    // 回调
    ILSLiveChatManManagerListener* m_listener;
    // LiveChat客户端
    ILSLiveChatClient* m_client;
    // 消息发送器
    LSLiveChatSender* m_liveChatSender;
    
    // 用户管理器
    LSLCUserManager*		m_userMgr;		// 用户管理器
    LSLCBlockManager*     m_blockMgr;     // 黑名单管理器
    
    // LiveChat请求控制器
    LSLiveChatRequestLiveChatController* m_requestController;
    // Other请求控制器
    LSLiveChatRequestOtherController*	m_requestOtherController;
    
    // 检测试聊请求map表
    map_lock<long, LSLiveChatSession*> m_inviteMsgMap;
    
    // 邀请会话自增Id管理
    LSLiveChatCounter m_counter;
    
    // 会话列表
    IAutoLock* m_sessionMapLock;
    SessionMap m_sessionMap;
    
    // 检查会话心跳时间步长
    int m_checkHeartBeatTimeStep;
    // 最少可以camshare的点数
    double m_minCamshareBalance;
    
};
#endif /* LSLiveChatCamshareManager_h */
