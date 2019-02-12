//
//  LSLiveChatCamshareManager.cpp
//  Common-C-Library
//  Camshare会话管理器
//  Created by Max on 2017/2/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#include "LSLiveChatCamshareManager.h"

// 允许取消邀请超时
#define INVITE_CANCEL_TIMEOUT 20 * 1000
// 会话邀请超时
#define INVITE_TIMEOUT 120 * 1000
// 会话应邀超时
#define INVITED_TIMEOUT 60 * 1000
// 检查会话邀请超时时间步长
#define CHECK_INVITE_TIME_STEP 5 * 1000

// 会话接收视频超时
#define INVITED_VIDEO_TIMEOUT 60 * 1000
// 检查会话接收视频超时时间步长
#define CHECK_INVITED_VIDEO_TIME_STEP 5 * 1000

// 检查会话心跳超时时间步长
//#define CHECK_HEARTBEART_TIME_STEP 15 * 1000

// 后台会话超时提示
#define BACKGROUND_TIPS_TIMEOUT 120 * 1000
// 后台会话超时结束会话
#define BACKGROUND_END_TIMEOUT 170 * 1000
// 后台会话超时时间步长
#define CHECK_BACKGROUND_TIME_STEP 5 * 1000

// 定时业务类型
typedef enum {
    Request_Task_Unknow,                            // 未知请求类型
    Request_Task_RemoveSession,                     // 删除会话
    Request_Task_SendAllCamSessionInvite,           // 发送所有待发邀请
    Request_Task_SendCamSessionInvite,              // 发送指定会话待发邀请
    Request_Task_TryUseTicket,                      // 执行使用试聊券流程
    Request_Task_GetCount,                          // 执行获取余额流程
    Request_Task_SendAllSessionHeartBeat,           // 发送所有会话心跳
    Request_Task_ErrorCheckOnline,                  // 发送邀请失败, 检查女士是否在线
    Request_Task_ErrorCheckCam,                     // 发送邀请失败, 检查女士是否打开Camshare服务
    Request_Task_CheckAllSessionVideoTimeout,       // 检查所有会话视频超时
    Request_Task_CheckAllSessionInviteTimeout,      // 检查所有会话邀请超时
    Request_Task_CheckAllSessionBackgroundTimeout,  // 检查所有会话后台超时
} Request_Task_Type;

// 定时业务结构体
class RequestItem
{
public:
    RequestItem()
    {
        requestType = Request_Task_Unknow;
        param = 0;
    }
    
    RequestItem(const RequestItem& item)
    {
        requestType = item.requestType;
        param = item.param;
    }
    
    ~RequestItem(){};
    
    Request_Task_Type requestType;
    unsigned long long param;
};

LSLiveChatCamshareManager::LSLiveChatCamshareManager(
                                                 ILSLiveChatManManagerOperator* pOperator,
                                                 ILSLiveChatManManagerListener* pListener,
                                                 ILSLiveChatClient* pClient,
                                                 LSLiveChatSender* pLSLiveChatSender,
                                                 LSLCUserManager* pUserMgr,
                                                 LSLCBlockManager* pBlockManager,
                                                 LSLiveChatHttpRequestManager* pHttpRequestManager
                                                 ) {
    m_operator = pOperator;
    m_listener = pListener;
    m_client = pClient;
    m_liveChatSender = pLSLiveChatSender;
    
    m_userMgr = pUserMgr;
    m_blockMgr = pBlockManager;
    
    m_requestController = new LSLiveChatRequestLiveChatController(pHttpRequestManager, this);
    m_requestOtherController = new LSLiveChatRequestOtherController(pHttpRequestManager, this);
    
    m_counter.Init();
    
    m_sessionMapLock = IAutoLock::CreateAutoLock();
    m_sessionMapLock->Init(IAutoLock::IAutoLockType_Recursive);
    
    m_checkHeartBeatTimeStep = 0;
    m_minCamshareBalance = 0.0;
    
    if( m_client) {
        m_client->AddListener(this);
    }
}

LSLiveChatCamshareManager::~LSLiveChatCamshareManager() {
    Reset();
    
    if( m_requestController ) {
        delete m_requestController;
        m_requestController = NULL;
    }
    
    if( m_requestOtherController ) {
        delete m_requestOtherController;
        m_requestOtherController = NULL;
    }
    
    if( m_client) {
        m_client->RemoveListener(this);
    }
    
    IAutoLock::ReleaseAutoLock(m_sessionMapLock);
    m_sessionMapLock = NULL;
}

void LSLiveChatCamshareManager::Reset() {
    m_sessionMapLock->Lock();
    for(SessionMap::iterator itr = m_sessionMap.begin(); itr != m_sessionMap.end();) {
        LSLiveChatSession* session = itr->second;
        delete session;

        itr = m_sessionMap.erase(itr);
    }
    m_sessionMapLock->Unlock();
}

void LSLiveChatCamshareManager::Start() {
    FileLog("LiveChatManager",
            "LSLiveChatCamshareManager::Start()"
            );
    
    RequestItem* requestItem  = NULL;
    
    // 启动发送心跳任务
    requestItem = new RequestItem();
    requestItem->requestType = Request_Task_SendAllSessionHeartBeat;
    m_operator->InsertRequestTask(this, (TaskParam)requestItem);
    
    // 启动检查所有会话视频超时任务
    requestItem = new RequestItem();
    requestItem->requestType = Request_Task_CheckAllSessionVideoTimeout;
    m_operator->InsertRequestTask(this, (TaskParam)requestItem);
    
    // 启动检查所有会话邀请超时任务
    requestItem = new RequestItem();
    requestItem->requestType = Request_Task_CheckAllSessionInviteTimeout;
    m_operator->InsertRequestTask(this, (TaskParam)requestItem);
    
    // 启动检查所有会话后台超时任务
    requestItem = new RequestItem();
    requestItem->requestType = Request_Task_CheckAllSessionBackgroundTimeout;
    m_operator->InsertRequestTask(this, (TaskParam)requestItem);
}

bool LSLiveChatCamshareManager::SendMsg(LSLCUserItem* userItem, LSLCMessageItem* msgItem) {
    bool result = false;
    
    if (IsSendMessageNow(userItem))
    {
        m_sessionMapLock->Lock();
        LSLiveChatSession* session = GetSessionByUserItem(userItem);
        if( session != NULL ) {
            session->Lock();
            if ( session->GetSessionStatus() == SessionStatus_InChat ) {
                // 立即发送
                msgItem->m_inviteType = INVITE_TYPE_CAMSHARE;
                m_liveChatSender->SendMessageItem(msgItem);
                result = true;
            }
            session->Unlock();
        }
        m_sessionMapLock->Unlock();
    }
    
    return result;
}

bool LSLiveChatCamshareManager::SendCamShareInvite(LSLCUserItem* userItem) {
    bool bFlag = false;
    
    if (CanSendInvite(userItem))
    {
        m_sessionMapLock->Lock();
        LSLiveChatSession* session = GetSessionByUserItem(userItem);
        if( session == NULL ) {
            // 创建新会话
            session = CreateSessionByUserItem(userItem);
            
        }
        session->Lock();
        if( session->GetSessionStatus() == SessionStatus_Unknow ) {
            if (session->GetInviteType() == SessionInviteType_Invite) {
                // 设置会话邀请状态为处理男士邀请状态
                session->SetSessionCamshareInviteStatus(SessionCamshareStatus_SendInvite);
            }
            else
            {
                // 设置会话邀请状态为处理接受女士发过来的邀请
                session->SetSessionCamshareInviteStatus(SessionCamshareStatus_RecvLadyInvite);
            }

            // 检测女士是否开启cam
            bFlag = InsideGetLadyCamStatu(session);
            
        } else {
            // 不允许重复发送邀请
        }
        session->Unlock();

        m_sessionMapLock->Unlock();
    }

    return bFlag;
}

bool LSLiveChatCamshareManager::EndTalk(LSLCUserItem* userItem) {
    bool bFlag = false;
    
    m_sessionMapLock->Lock();
    LSLiveChatSession* session = GetSessionByUserItem(userItem);
    if( session != NULL ) {
        FileLog("LiveChatManager",
                "LSLiveChatCamshareManager::EndTalk( "
                "userId : %s, "
                "session : %p, "
                "sessionStatus : %d "
                ")",
                userItem->m_userId.c_str(),
                session,
                session->GetSessionStatus()
                );
        
        session->Lock();
        
        bool bContinue = true;
        if( session->GetSessionStatus() == SessionStatus_Invite ) {
            // [会话状态]为(邀请), 发送取消邀请
            bContinue = SendCamShareCancelInviteCmd(session);
            
        } else if( session->GetSessionStatus() == SessionStatus_InChat ) {
            // [会话状态]为(在聊), 发送结束会话命令, 发送完成会销毁会话
            bFlag = SendEndTalkCmd(session);
            bContinue = false;
            bFlag = true;

            
        } else {
            if( session->GetInviteType() == SessionInviteType_Invite ) {
                // [邀请状态]为主动邀请
                if( session->GetSessionStatus() == SessionStatus_Unknow
                   ) {
                    // [会话状态]为(未知), 销毁会话
                    bContinue = false;
                    
                } else if( session->GetSessionStatus() != SessionStatus_Error ) {
                    // [会话状态]为(试聊券|应邀), 标记为已经取消
                    session->SetSessionStatus(SessionStatus_Cancel);
                }
            } else {
                // 邀请不处理
            }
        }
        session->Unlock();

        if( !bContinue ) {
            // 销毁会话
            RemoveSessionByUserItem(userItem);
        }
        
    }
    m_sessionMapLock->Unlock();
    
    return bFlag;
}

bool LSLiveChatCamshareManager::GetCamLadyStatus(LSLCUserItem* userItem) {
    bool bFlag = false;
    if (m_operator->IsLogin()) {
        bFlag = m_client->GetLadyCamStatus(userItem->m_userId);
    }

    return bFlag;
}

bool LSLiveChatCamshareManager::CheckCamCoupon(LSLCUserItem* userItem) {
    bool bFlag = false;
    long requestId = m_requestController->CheckCoupon(userItem->m_userId, LSLiveChatRequestLiveChatController::ServiceType_Camshare);
    bFlag = HTTPREQUEST_INVALIDREQUESTID != requestId;
    return bFlag;
}

bool LSLiveChatCamshareManager::UpdateRecvVideo(LSLCUserItem* userItem) {
    bool bFlag = false;
    m_sessionMapLock->Lock();
    LSLiveChatSession* session = GetSessionByUserItem(userItem);
    if( session ) {
        session->Lock();
        if( session->GetSessionStatus() == SessionStatus_InChat ) {

            session->UpdateRecvVideoTime();
        }
        session->Unlock();
    }
    m_sessionMapLock->Unlock();
    return bFlag;
}

bool LSLiveChatCamshareManager::IsCamShareInChat(LSLCUserItem* userItem) {
    bool bFlag = false;
    m_sessionMapLock->Lock();
    LSLiveChatSession* session = GetSessionByUserItem(userItem);
    if( session ) {
        session->Lock();
        if( session->GetSessionStatus() == SessionStatus_InChat ) {
            bFlag = true;
        }
        session->Unlock();
    }
    m_sessionMapLock->Unlock();
    return bFlag;
}

bool LSLiveChatCamshareManager::IsUploadVideo() {
    bool bFlag = false;
    
    m_sessionMapLock->Lock();
    for(SessionMap::const_iterator itr = m_sessionMap.begin(); itr != m_sessionMap.end(); itr++) {
        LSLiveChatSession* session = itr->second;
        session->Lock();
        if( session->GetSessionStatus() == SessionStatus_InChat ) {
            bFlag = true;
        }
        session->Unlock();
        
        if( bFlag ) {
            break;        }
    }
    m_sessionMapLock->Unlock();

    return bFlag;
}

bool LSLiveChatCamshareManager::IsCamShareInvite(LSLCUserItem* userItem) {
    bool bFlag = false;
    m_sessionMapLock->Lock();
    LSLiveChatSession* session = GetSessionByUserItem(userItem);
    if( session ) {
        session->Lock();
        if( session->GetInviteType() == SessionInviteType_Invited ) {
            bFlag = true;
        }
        session->Unlock();
    }
    m_sessionMapLock->Unlock();
    return bFlag;
}

bool LSLiveChatCamshareManager::SetCamShareBackground(LSLCUserItem* userItem, bool bBackground) {
    bool bFlag = false;
    
    m_sessionMapLock->Lock();
    LSLiveChatSession* session = GetSessionByUserItem(userItem);
    if( session ) {
        session->Lock();
        session->SetBackground(bBackground);
        session->Unlock();
        bFlag = true;
    }
     m_sessionMapLock->Unlock();
    return bFlag;
}


bool LSLiveChatCamshareManager::SetCheckCamShareHeartBeatTimeStep(int timeStep)
{
    bool bFlag = false;
    if (timeStep > 0) {
        m_checkHeartBeatTimeStep = timeStep;
        bFlag = true;
    }
    return bFlag;
}

// 设置camshare最少点数
void LSLiveChatCamshareManager::SetMinCamshareBalance(double balance)
{
    if (balance > 0.0000000001) {
        m_minCamshareBalance = balance;
    }
}

void LSLiveChatCamshareManager::OnRecvInviteMessage(const string& toId, const string& fromId, const string& inviteId, INVITE_TYPE inviteType) {
    // 收到女士邀请
    
    if( INVITE_TYPE_CAMSHARE == inviteType ) {
        LSLCUserItem* userItem = m_userMgr->GetUserItem(fromId);
        if( userItem ) {
            // 改变女士状态为打开摄像头
            userItem->Lock();
            userItem->m_isOpenCam = true;
            userItem->Unlock();
            
            m_sessionMapLock->Lock();
            LSLiveChatSession* session = GetSessionByUserItem(userItem);
            if( session == NULL ) {
                // 创建新会话
                session = CreateSessionByUserItem(userItem);
            }
            
            FileLog("LiveChatManager",
                    "LSLiveChatCamshareManager::OnRecvInviteMessage( "
                    "userId : %s, "
                    "session : %p, "
                    "sessionStatus : %d "
                    ")",
                    userItem->m_userId.c_str(),
                    session,
                    session->GetSessionStatus()
                    );
            
            session->Lock();
            if( session->GetSessionStatus() != SessionStatus_Apply
               && session->GetSessionStatus() != SessionStatus_InChat
               && session->GetSessionStatus() != SessionStatus_Cancel
               ) {
                // [会话状态]不为(应邀)|(在聊)|(取消邀请)
                if( session->GetSessionStatus() != SessionStatus_Invite ) {
                    // [会话状态]为(未发送邀请), 切换[邀请类型]为(被邀)
                    session->SetInviteType(SessionInviteType_Invited);
                    session->SetInviteTime(getCurrentTime());
                } else {
                    // [会话状态]为(已发送邀请), 直接应答
                    if( !CheckCoupon(session) ) {
//                        // 直接发送
//                        SendCamShareApplyCmd(session);
//                        
                        // 检测是否有点
                        RequestItem* requestItem = new RequestItem();
                        requestItem->requestType = Request_Task_GetCount;
                        requestItem->param = (TaskParam)session;
                        m_operator->InsertRequestTask(this, (TaskParam)requestItem);
                    }
                }
            }
            session->Unlock();
            
            m_sessionMapLock->Unlock();
        }
    }
    else
    {
        LSLCUserItem* userItem = m_userMgr->GetUserItem(fromId);
        if( userItem ) {
            m_sessionMapLock->Lock();
            LSLiveChatSession* session = GetSessionByUserItem(userItem);
            bool isDeleteSession = false;
            if( session) {
                session->Lock();
                if( session->GetSessionStatus() == SessionStatus_Unknow) {
                    isDeleteSession = true;
                }
                session->Unlock();

            }
            if (isDeleteSession) {
                RemoveSessionByUserItem(session->GetUserItem());
            }
            m_sessionMapLock->Unlock();
        }

    }
    
}

void LSLiveChatCamshareManager::OnGetTalkList(const TalkListInfo& talkListInfo) {
    TalkUserList::const_iterator iter;
    TalkSessionList::const_iterator iterSession;

    // 处理在聊列表，只保留一个，其他直接EndChat
    bool bFlag = false;
    for (iterSession = talkListInfo.chatingSession.begin();
         iterSession != talkListInfo.chatingSession.end();
         iterSession++) {
        
        TalkSessionListItem item = *iterSession;
        if( TalkSessionServiceType_Camshare == item.serviceType ) {
            // Camshare会话才处理
            LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
            if (NULL != userItem) {
                if( !bFlag ) {
                    m_sessionMapLock->Lock();
                    CreateCamShareInChatSession(userItem);
                    m_sessionMapLock->Unlock();

                    // 标记已经处理过
                    bFlag = true;
                    
                } else {
                    // 已经处理过一个会话, 其他直接结束
                    if (m_operator->IsLogin()) {
                        m_client->EndTalk(userItem->m_userId);
                    }
                    
                }
            }
        }
    }
    
    // 处理暂停列表，所有EndChat
    for (iterSession = talkListInfo.pauseSession.begin();
         iterSession != talkListInfo.pauseSession.end();
         iterSession++) {
        
        TalkSessionListItem item = *iterSession;
        if( TalkSessionServiceType_Camshare == item.serviceType ) {
            // Camshare会话才处理
            LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
            if (NULL != userItem) {
                // 已经处理过一个会话, 其他直接结束
                if (m_operator->IsLogin()) {
                    m_client->EndTalk(userItem->m_userId);
                }
                
            }
        }
    }
    
    // Camshare会话管理器开始任务
    Start();
}

bool LSLiveChatCamshareManager::CheckCoupon(LSLiveChatSession* session)
{
    session->Lock();
    session->SetSessionStatus(SessionStatus_CheckCoupon);
    session->Unlock();
    
    bool result = false;
    LSLCUserItem* userItem = session->GetUserItem();
    
    if (NULL != userItem)
    {
        long requestId = m_requestController->CheckCoupon(userItem->m_userId, LSLiveChatRequestLiveChatController::ServiceType_Camshare);
        result = HTTPREQUEST_INVALIDREQUESTID != requestId;
        
        session->Lock();
        session->SetParam((unsigned long long)requestId);
        session->Unlock();
    }

    return result;
}

bool LSLiveChatCamshareManager::CheckInsideCoupon(LSLiveChatSession* session)
{

    session->SetSessionStatus(SessionStatus_CheckCoupon);
    bool result = false;
    LSLCUserItem* userItem = session->GetUserItem();
    
    if (NULL != userItem)
    {
        long requestId = m_requestController->CheckCoupon(userItem->m_userId, LSLiveChatRequestLiveChatController::ServiceType_Camshare);
        result = HTTPREQUEST_INVALIDREQUESTID != requestId;
        session->SetParam((unsigned long long)requestId);
    }
    
    return result;
}

void LSLiveChatCamshareManager::OnCheckCoupon(long requestId, bool success, const LSLCCoupon& item, const string& userId, const string& errnum, const string& errmsg) {
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if (NULL != userItem)
    {
        // 判断试聊券是否可用
        bool canUse = (item.status == CouponStatus_Yes || item.status == CouponStatus_Started);
        bool externCheck = true;
        
        LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
        m_sessionMapLock->Lock();
        LSLiveChatSession* session = GetSessionByUserItem(userItem);
        if( session ) {
            session->Lock();
            
            if( (long)session->GetParam() == requestId ) {
                // 标记为内部请求
                externCheck = false;
                
                if (success && canUse)
                {
                    // 尝绑定试聊劵
                    RequestItem* requestItem = new RequestItem();
                    requestItem->requestType = Request_Task_TryUseTicket;
                    requestItem->param = (TaskParam)session;
                    m_operator->InsertRequestTask(this, (TaskParam)requestItem);

                }
                else {
                    // 检测是否有点
                    RequestItem* requestItem = new RequestItem();
                    requestItem->requestType = Request_Task_GetCount;
                    requestItem->param = (TaskParam)session;
                    m_operator->InsertRequestTask(this, (TaskParam)requestItem);
                }
            }
            
            session->Unlock();
        }
        m_sessionMapLock->Unlock();
        
        if( externCheck ) {
            // 不是内部请求, 通知界面
            if( m_listener ) {
                // 外部操作
                CouponStatus status = (canUse ? CouponStatus_Yes : item.status);
                int couponTime = item.time;
                m_listener->OnCheckCamCoupon(success, errnum, errmsg, userId, status, couponTime);
            }
        }
    }
}

bool LSLiveChatCamshareManager::UseCoupon(LSLiveChatSession* session)
{
    session->Lock();
    session->SetSessionStatus(SessionStatus_UseCoupon);

    bool result = false;
    LSLCUserItem* userItem = session->GetUserItem();
    if (NULL != userItem)
    {
        long requestId = m_requestController->UseCoupon(userItem->m_userId, LSLiveChatRequestLiveChatController::ServiceType_Camshare);
        result = HTTPREQUEST_INVALIDREQUESTID != requestId;
    }
    
    session->Unlock();
    
    return result;
}
    
void LSLiveChatCamshareManager::OnUseCoupon(long requestId, bool success, const string& errnum, const string& errmsg, const string& userId, const string& couponid)
{
    bool isUseTryTicketOk = false;
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    
    m_sessionMapLock->Lock();
    LSLiveChatSession* session = GetSessionByUserItem(userItem);
    
    if( session ) {
        session->Lock();
        if (success) {
            m_sessionMapLock->Unlock();
            if (session->GetSessionCamshareInviteStatus() == SessionCamshareStatus_SendInvite) {
                // 在主动邀请前，做试聊劵绑定成功就发送
                isUseTryTicketOk = SendCamShareInviteByStatus(session);
                
            }
            else
            {
                if (m_operator->IsLogin()) {
                    isUseTryTicketOk = m_client->CamshareUseTryTicket(userId, couponid);
                }
            }
        }
        
        if (!isUseTryTicketOk) {
                RequestItem* requestItem = new RequestItem();
                requestItem->requestType = Request_Task_GetCount;
                requestItem->param = (TaskParam)session;
                m_operator->InsertRequestTask(this, (TaskParam)requestItem);
           
        }
         session->Unlock();
    }
   
    m_sessionMapLock->Unlock();
}

void LSLiveChatCamshareManager::OnCamshareUseTryTicket(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& ticketId, const string& inviteId)
{
    m_listener->OnUseCamCoupon(err, errmsg, userId);

    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        m_sessionMapLock->Lock();
        LSLiveChatSession* session = GetSessionByUserItem(userItem);
        if( session ) {
            
            if (err != LSLIVECHAT_LCC_ERR_SUCCESS) {
                // 检测是否有足够余额
                
                RequestItem* requestItem = new RequestItem();
                requestItem->requestType = Request_Task_GetCount;
                requestItem->param = (TaskParam)session;
                m_operator->InsertRequestTask(this, (TaskParam)requestItem);
                
            }
            else {
                // 使用成功
                // 启动服务成功, 改变会话Id
                userItem->Lock();
                userItem->m_inviteId = inviteId;
                userItem->Unlock();
                
                bool bFlag = true;
                session->Lock();
                if( session->GetSessionStatus() == SessionStatus_UseCoupon ) {
                    session->SetSessionStatus(SessionStatus_InChat);
                    session->UpdateRecvVideoTime();
                    
                    
                } else {
                    // [会话状态]出错，结束会话
                    bFlag = false;
                }
                session->Unlock();
                
                if( !bFlag ) {
                    // 销毁会话
                    RemoveSessionByUserItem(userItem);
                }
                else
                {
                    // 通知界面
                    if( m_listener ) {
                        m_listener->OnRecvCamAcceptInvite(userId, true);
                    }
                }
            }
        }
        m_sessionMapLock->Unlock();
    }

}

bool LSLiveChatCamshareManager::GetCount(LSLiveChatSession* session)
{
    session->Lock();
    session->SetSessionStatus(SessionStatus_GetCount);
    session->Unlock();
    
    bool result = false;
    
    LSLCUserItem* userItem = session->GetUserItem();
    if (NULL != userItem)
    {
        long requestId = m_requestOtherController->GetCount(true, false, false, false, false, false);
        result = HTTPREQUEST_INVALIDREQUESTID != requestId;
        if (result) {
            m_inviteMsgMap.lock();
            m_inviteMsgMap.insert(map<long, LSLiveChatSession*>::value_type(requestId, session));
            m_inviteMsgMap.unlock();
        }
    }
    return result;
}

void LSLiveChatCamshareManager::OnGetCount(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherGetCountItem& item)
{
    bool isSuccess = success;
    LSLCOtherGetCountItem CountItem = item;
    
    LSLiveChatSession* session = NULL;
    
    // 获取待发消息的userItem
    m_inviteMsgMap.lock();
    map<long, LSLiveChatSession*>::iterator iter = m_inviteMsgMap.find(requestId);
    if (iter != m_inviteMsgMap.end()) {
        session = (*iter).second;
        m_inviteMsgMap.erase(iter);
    }
    m_inviteMsgMap.unlock();
    
    // 会话是否继续
    bool bFlag = true;
    if( session ) {
        session->Lock();
        if (isSuccess) {
            // 判断点是不是大于聊天最少点
            if (CountItem.money >= GetMinCamshareBalance()) {
                if( session->GetSessionStatus() == SessionStatus_GetCount) {
                    // 直接发送
                    bFlag = SendCamShareInviteByStatus(session);
                    if (!bFlag) {
                        session->SetErrorType(LSLIVECHAT_LCC_ERR_CONNECTFAIL);
                    }
                  
                
                } else {
                    // [会话状态]出错，结束会话
                    bFlag = false;
                }

            }
            else {
                // 失败, 没钱
                LSLIVECHAT_LCC_ERR_TYPE err = LSLIVECHAT_LCC_ERR_NOMONEY;
                session->SetErrorType(err);
                
                bFlag = false;
            }
        }
        // 连接失败
        else
        {
            if( session->GetSessionStatus() == SessionStatus_GetCount ) {
                // 直接发送
                bFlag = SendCamShareInviteByStatus(session);
                
            } else {
                // [会话状态]出错，结束会话
                bFlag = false;
            }
            
        }
        session->Unlock();
        
        if( !bFlag ) {
            // 通知界面
            if( m_listener ) {
                m_listener->OnRecvCamDisconnect(session->GetErrorType(), session->GetUserItem()->m_userId);
            }
            
            // 销毁会话
            m_sessionMapLock->Lock();
            if (session->GetSessionCamshareInviteStatus() != SessionCamshareStatus_RecvLadyInvite) {
                // 是男士会话邀请状态为：非女士发送camshare邀请就删除了会话。
                RemoveSessionByUserItem(session->GetUserItem());
            }
            else
            {
                session->Lock();
                //是男士会话邀请状态为：女士发送camshare邀请, 设置会话状态为刚开始
                session->SetSessionStatus(SessionStatus_Unknow);
                session->Unlock();
            }
            
            m_sessionMapLock->Unlock();
        }
    }

}

bool LSLiveChatCamshareManager::GetLeftCreditProc(LSLiveChatSession* session) {
    session->Lock();
    session->SetSessionStatus(SessionStatus_GetCount);
    session->Unlock();
    
    bool result = false;
    
    LSLCUserItem* userItem = session->GetUserItem();
    if (NULL != userItem)
    {
        long requestId = m_requestOtherController->GetLeftCredit();
        result = HTTPREQUEST_INVALIDREQUESTID != requestId;
        if (result) {
            m_inviteMsgMap.lock();
            m_inviteMsgMap.insert(map<long, LSLiveChatSession*>::value_type(requestId, session));
            m_inviteMsgMap.unlock();
        }
    }
    return result;
}

// 直播http接口6.2.获取帐号余额
void LSLiveChatCamshareManager::OnGetLeftCredit(long requestId, bool success, int errnum, const string& errmsg, double credit, int coupon) {
    bool isSuccess = success;

    
    LSLiveChatSession* session = NULL;
    
    // 获取待发消息的userItem
    m_inviteMsgMap.lock();
    map<long, LSLiveChatSession*>::iterator iter = m_inviteMsgMap.find(requestId);
    if (iter != m_inviteMsgMap.end()) {
        session = (*iter).second;
        m_inviteMsgMap.erase(iter);
    }
    m_inviteMsgMap.unlock();
    
    // 会话是否继续
    bool bFlag = true;
    if( session ) {
        session->Lock();
        if (isSuccess) {
            // 判断点是不是大于聊天最少点
            if (credit >= GetMinCamshareBalance()) {
                if( session->GetSessionStatus() == SessionStatus_GetCount) {
                    // 直接发送
                    bFlag = SendCamShareInviteByStatus(session);
                    if (!bFlag) {
                        session->SetErrorType(LSLIVECHAT_LCC_ERR_CONNECTFAIL);
                    }
                    
                    
                } else {
                    // [会话状态]出错，结束会话
                    bFlag = false;
                }
                
            }
            else {
                // 失败, 没钱
                LSLIVECHAT_LCC_ERR_TYPE err = LSLIVECHAT_LCC_ERR_NOMONEY;
                session->SetErrorType(err);
                
                bFlag = false;
            }
        }
        // 连接失败
        else
        {
            if( session->GetSessionStatus() == SessionStatus_GetCount ) {
                // 直接发送
                bFlag = SendCamShareInviteByStatus(session);
                
            } else {
                // [会话状态]出错，结束会话
                bFlag = false;
            }
            
        }
        session->Unlock();
        
        if( !bFlag ) {
            // 通知界面
            if( m_listener ) {
                m_listener->OnRecvCamDisconnect(session->GetErrorType(), session->GetUserItem()->m_userId);
            }
            
            // 销毁会话
            m_sessionMapLock->Lock();
            if (session->GetSessionCamshareInviteStatus() != SessionCamshareStatus_RecvLadyInvite) {
                // 是男士会话邀请状态为：非女士发送camshare邀请就删除了会话。
                RemoveSessionByUserItem(session->GetUserItem());
            }
            else
            {
                session->Lock();
                //是男士会话邀请状态为：女士发送camshare邀请, 设置会话状态为刚开始
                session->SetSessionStatus(SessionStatus_Unknow);
                session->Unlock();
            }
            
            m_sessionMapLock->Unlock();
        }
    }
}


// 获取camshare最少点数
double LSLiveChatCamshareManager::GetMinCamshareBalance()
{
    return m_minCamshareBalance;
}

bool LSLiveChatCamshareManager::CanSendInvite(LSLCUserItem* userItem) {
    bool bFlag = false;
    
//    // 检查黑名单
//    bFlag = !m_blockMgr->IsExist(userItem->m_userId);
    // 检查是否已经登录
    bFlag = IsSendMessageNow(userItem);
    
    return bFlag;
}

bool LSLiveChatCamshareManager::IsSendMessageNow(LSLCUserItem* userItem)
{
    bool result = false;
    if (NULL != userItem)
    {
        // 已经登录, 已经获取历史聊天记录
        result = m_operator->IsLogin() && m_operator->IsGetHistory();
 
    }
    return result;
}

bool LSLiveChatCamshareManager::SendCamShareInviteByStatus(LSLiveChatSession* session) {
    bool bFlag = false;
    if( session->GetInviteType() == SessionInviteType_Invite ) {
        // [邀请状态]为(主动邀请)，发送邀请
       // bFlag = SendCamShareInviteCmd(session);
        
        if (session->GetSessionCamshareInviteStatus() == SessionCamshareStatus_SendInvite) {
            // 在主动邀请前，只检测试聊劵
             bFlag = SendCamShareInviteCmd(session);
        }
        else
        {
            bFlag = SendCamShareApplyCmd(session);
        }
        
    } else {
        // [邀请状态]为(被邀)
        if( getCurrentTime() - session->GetInviteTime() > INVITED_TIMEOUT ) {
            // 邀请超时，发送邀请
            bFlag = SendCamShareInviteCmd(session);
        } else {
            // 发送开始会话
            bFlag = SendCamShareApplyCmd(session);
//            if( !CheckCoupon(session) ) {
//                bFlag = true;
//                // 检测是否有点
//                RequestItem* requestItem = new RequestItem();
//                requestItem->requestType = Request_Task_GetCount;
//                requestItem->param = (TaskParam)session;
//                m_operator->InsertRequestTask(this, (TaskParam)requestItem);
//            }
        }
    }
    return bFlag;
}

bool LSLiveChatCamshareManager::SendCamShareInviteCmd(LSLiveChatSession* session) {
    bool bFlag = false;
    // 判断客户端是否有登录
    if (m_operator->IsLogin()) {
        LSLCUserItem* userItem = session->GetUserItem();
        
        // 主动发起邀请
        session->Lock();
        session->SetSessionStatus(SessionStatus_Invite);
        session->SetInviteType(SessionInviteType_Invite);
        
        session->SetCamSessionId(m_counter.GetAndIncrement());
        session->SetInviteTime(getCurrentTime());
        
        int sessionId = session->GetCamSessionId();
        
        FileLog("LiveChatManager",
                "LSLiveChatCamshareManager::SendCamShareInviteCmd( "
                "userId : %s, "
                "session : %p, "
                "sessionId : %d "
                ")",
                userItem->m_userId.c_str(),
                session,
                session->GetCamSessionId()
                );
         bFlag = m_client->SendCamShareInvite(userItem->m_userId, CamshareInviteType_Ask, sessionId, m_operator->GetUserName());
        
        session->Unlock();
    }
   
    return bFlag;
}

bool LSLiveChatCamshareManager::SendCamShareCancelInviteCmd(LSLiveChatSession* session) {
    bool bFlag = false;
    if (m_operator->IsLogin()) {
        LSLCUserItem* userItem = session->GetUserItem();
        
        // 主动发送取消
        session->Lock();
        session->SetSessionStatus(SessionStatus_Cancel);
        
        FileLog("LiveChatManager",
                "LSLiveChatCamshareManager::SendCamShareCancelInviteCmd( "
                "userId : %s, "
                "session : %p, "
                "sessionId : %d "
                ")",
                userItem->m_userId.c_str(),
                session,
                session->GetCamSessionId()
                );
        
        bFlag = m_client->SendCamShareInvite(userItem->m_userId, CamshareInviteType_Cancel, session->GetCamSessionId(), m_operator->GetUserName());
        
        session->Unlock();
    }

    
    return bFlag;
}

void LSLiveChatCamshareManager::OnSendCamShareInvite(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    LSLCUserItem* userItem = m_userMgr->GetUserItem(inUserId);
    if( userItem ) {
        m_sessionMapLock->Lock();
        LSLiveChatSession* session = GetSessionByUserItem(userItem);
        
        bool isStatusInvite = false;
        if( session ) {
            session->Lock();
            // 是否销毁会话
            bool bFlag = false;
            if( session->GetSessionStatus() == SessionStatus_Invite ) {
                FileLog("LiveChatManager",
                        "LSLiveChatCamshareManager::OnSendCamShareInvite( "
                        "userId : %s, "
                        "session : %p, "
                        "sessionId : %d, "
                        "err : %d "
                        ")",
                        inUserId.c_str(),
                        session,
                        session->GetCamSessionId(),
                        err
                        );
                isStatusInvite = true;
                // ErrorCheck有删除session，而上面有session->Lock();下面才session->Unlock();导致crash
//                if( err != LSLIVECHAT_LCC_ERR_SUCCESS ) {
//                    // 发送邀请失败
//                    ErrorCheck(inUserId, err);
//                }

            } else {
                FileLog("LiveChatManager",
                        "LSLiveChatCamshareManager::OnSendCamShareInviteCancel( "
                        "userId : %s, "
                        "session : %p, "
                        "sessionId : %d, "
                        "err : %d "
                        ")",
                        inUserId.c_str(),
                        session,
                        session->GetCamSessionId(),
                        err
                        );
                
                // 发送取消邀请, 销毁会话
                bFlag = true;
            }
            session->Unlock();
            if (isStatusInvite) {
                if( err != LSLIVECHAT_LCC_ERR_SUCCESS ) {
                    // 发送邀请失败
                    ErrorCheck(inUserId, err);
                }
            }
            
            if( bFlag ) {
                RemoveSessionByUserItem(userItem);
            }
        }
        m_sessionMapLock->Unlock();
    }
    
}

bool LSLiveChatCamshareManager::SendEndTalkCmd(LSLiveChatSession* session) {
    bool bFlag = false;
    
    if (m_operator->IsLogin()) {
        LSLCUserItem* userItem = session->GetUserItem();
        
        session->Lock();
        session->SetSessionStatus(SessionStatus_Cancel);
        
        FileLog("LiveChatManager",
                "LSLiveChatCamshareManager::SendEndTalkCmd( "
                "userId : %s, "
                "session : %p "
                ")",
                userItem->m_userId.c_str(),
                session
                );
        
        bFlag = m_client->EndTalk(userItem->m_userId);
        
        session->Unlock();
    }
    
    return bFlag;
}

void LSLiveChatCamshareManager::OnEndTalk(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
//    LCUserItem* userItem = m_userMgr->GetUserItem(inUserId);
//    if( userItem ) {
//        // 是否销毁会话
//        bool bFlag = false;
//        m_sessionMapLock->Lock();
//        Session* session = GetSessionByUserItem(userItem);
//        if( session ) {
//            // 找到会话
//            FileLog("LiveChatManager",
//                    "LSLiveChatCamshareManager::OnEndTalk( "
//                    "userId : %s, "
//                    "session : %p "
//                    ")",
//                    inUserId.c_str(),
//                    session
//                    );
//            
//            session->Lock();
//            if( session->GetSessionStatus() == SessionStatus_Cancel ) {
//                // 销毁会话
//                bFlag = true;
//                session->SetErrorType(err);
//            }
//            session->Unlock();
//            
//            if( bFlag ) {
//                // 启动删除会话任务
//                RequestItem* requestItem = new RequestItem();
//                requestItem->requestType = Request_Task_RemoveSession;
//                requestItem->param = (TaskParam)session;
//                m_operator->InsertRequestTask(this, (TaskParam)requestItem);
//            }
//        }
//        m_sessionMapLock->Unlock();
//    }
}

bool LSLiveChatCamshareManager::SendCamShareApplyCmd(LSLiveChatSession* session) {
    bool bFlag = false;
    // 判断是否登录
    if (m_operator->IsLogin()) {
        
        LSLCUserItem* userItem = session->GetUserItem();
        
        session->Lock();
        session->SetSessionStatus(SessionStatus_Apply);
        
        FileLog("LiveChatManager",
                "LSLiveChatCamshareManager::SendCamShareApplyCmd( "
                "userId : %s, "
                "session : %p "
                ")",
                userItem->m_userId.c_str(),
                session
                );
        bFlag = m_client->ApplyCamShare(userItem->m_userId);
        session->Unlock();
    }

    
    return bFlag;
}

void LSLiveChatCamshareManager::OnApplyCamShare(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isSuccess, const string& inviteId) {
    LSLCUserItem* userItem = m_userMgr->GetUserItem(inUserId);
    if (userItem) {
        if( err == LSLIVECHAT_LCC_ERR_SUCCESS ) {
            // 启动服务成功, 改变会话Id
            userItem->Lock();
            userItem->m_inviteId = inviteId;
            userItem->Unlock();
            
            // 会话是否继续
            bool bFlag = true;
            m_sessionMapLock->Lock();
            LSLiveChatSession* session = GetSessionByUserItem(userItem);
            if( session ) {
                FileLog("LiveChatManager",
                        "LSLiveChatCamshareManager::OnApplyCamShare( "
                        "userId : %s, "
                        "session : %p, "
                        "sessionId : %d "
                        ")",
                        userItem->m_userId.c_str(),
                        session,
                        session->GetCamSessionId()
                        );
                
                session->Lock();
                if( session->GetSessionStatus() != SessionStatus_Cancel ) {
                    // 不是应答过程中被取消
                    session->SetSessionStatus(SessionStatus_InChat);
                    session->UpdateRecvVideoTime();
                    
                } else {
                    // 应答过程中被取消
                    bFlag = false;
                }
                session->Unlock();
            }
            
            if( !bFlag ) {
                // 发送结束会话命令, 发送完成会销毁会话
                SendEndTalkCmd(session);
                RemoveSessionByUserItem(session->GetUserItem());
                
            } else {
                // 通知界面
                if( m_listener ) {
                    m_listener->OnRecvCamAcceptInvite(inUserId, true);
                }
            }

        } else {
            // 启动服务失败
            ErrorCheck(inUserId, err);
        }
        
        m_sessionMapLock->Unlock();
    }
}

bool LSLiveChatCamshareManager::SendCamShareHeartBeat(LSLiveChatSession* session) {
    bool bFlag = false;
    
    if (m_operator->IsLogin()) {
        
        LSLCUserItem* userItem = session->GetUserItem();
        FileLog("LiveChatManager",
                "LSLiveChatCamshareManager::SendCamShareHeartBeat( "
                "userId : %s, "
                "session : %p, "
                "sessionId : %d "
                ")",
                userItem->m_userId.c_str(),
                session,
                session->GetCamSessionId()
                );
        
        bFlag = m_client->CamShareHearbeat(session->GetUserItem()->m_userId, session->GetUserItem()->m_inviteId);
    }
    return bFlag;
}

void LSLiveChatCamshareManager::OnRecvCamHearbeatException(const string& exceptionName, LSLIVECHAT_LCC_ERR_TYPE err, const string& targetId) {
    // 收到会话心跳异常, 删除会话
    LSLCUserItem* userItem = m_userMgr->GetUserItem(targetId);
    if (userItem) {
        FileLog("LiveChatManager",
                "LSLiveChatCamshareManager::OnRecvCamHearbeatException( "
                "userId : %s, "
                "exceptionName : %s "
                ")",
                userItem->m_userId.c_str(),
                exceptionName.c_str()
                );
        
        ErrorCheck(targetId, err);
    }
}

void LSLiveChatCamshareManager::OnRecvAcceptCamInvite(const string& fromId, const string& toId, CamshareLadyInviteType inviteType, int sessionId, const string& fromName, bool isCamOpen) {
    // 收到女士应邀
    LSLCUserItem* userItem = m_userMgr->GetUserItem(fromId);
    if( userItem ) {
        m_sessionMapLock->Lock();
        LSLiveChatSession* session = GetSessionByUserItem(userItem);
        if( session ) {
            // 是否继续会话
            bool bFlag = true;
            
            FileLog("LiveChatManager",
                    "LSLiveChatCamshareManager::OnRecvAcceptCamInvite( "
                    "userId : %s, "
                    "session : %p, "
                    "sessionId : %d, "
                    "sessionId(Recv) : %d, "
                    "inviteType : %d "
                    ")",
                    userItem->m_userId.c_str(),
                    session,
                    session->GetCamSessionId(),
                    sessionId,
                    inviteType
                    );
            
            session->Lock();
            if( (session->GetSessionStatus() == SessionStatus_Invite)
               && (session->GetInviteType() == SessionInviteType_Invite)
               ) {
                // [会话状态]为(已发送邀请), 表示(应邀状态)
                if( inviteType == CamshareLadyInviteType_Anwser ) {
                    session->SetSessionCamshareInviteStatus(SessionCamshareStatus_LadyRespondInvite);
                    InsideGetLadyCamStatu(session);
//                    if( !CheckCoupon(session) ) {
////                        // 直接发送
////                        bFlag = SendCamShareApplyCmd(session);
//                        bFlag = true;
//                        // 检测是否有点
//                        RequestItem* requestItem = new RequestItem();
//                        requestItem->requestType = Request_Task_GetCount;
//                        requestItem->param = (TaskParam)session;
//                        m_operator->InsertRequestTask(this, (TaskParam)requestItem);
//                    }
                    
                    
                } else if( inviteType == CamshareLadyInviteType_Cancel ) {
                    // 女士拒绝, 回调失败
                    
                    // 通知界面
                    if( m_listener ) {
                        m_listener->OnRecvCamAcceptInvite(fromId, false);
                    }
                    
                    bFlag = false;
                }
            }
            session->Unlock();
            
            if( !bFlag ) {
                RemoveSessionByUserItem(userItem);
            }
            
        }
        m_sessionMapLock->Unlock();
    }
}

void LSLiveChatCamshareManager::OnRecvLadyCamStatus(const string& userId, USER_STATUS_PROTOCOL statusId, const string& server, CLIENT_TYPE clientType, CamshareLadySoundType sound, const string& version) {
    
    bool isCamStatus = false;
    bool isOpenCam = (statusId == USTATUSPRO_CAMOPEN)?true:false;
    
    // 修改女士状态
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        // 女士Camshare状态改变
        if( (statusId == USTATUSPRO_CAMOPEN) || (statusId == USTATUSPRO_CAMCLOSE) ) {
            isCamStatus = true;
            
            userItem->Lock();
            userItem->m_isOpenCam = isOpenCam;
            userItem->Unlock();
            
            FileLog("LiveChatManager",
                    "LSLiveChatCamshareManager::OnRecvLadyCamStatus( "
                    "userId : %s, "
                    "isOpenCam : %d "
                    ")",
                    userItem->m_userId.c_str(),
                    isOpenCam
                    );
        }
    }

    // 通知界面
    if( m_listener && isCamStatus ) {
        m_listener->OnRecvLadyCamStatus(userId, isOpenCam);
    }
}

void LSLiveChatCamshareManager::ErrorCheck(const string& userId, LSLIVECHAT_LCC_ERR_TYPE err) {
    // 启动邀请失败或者启动服务失败任务
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        m_sessionMapLock->Lock();
        LSLiveChatSession* session = GetSessionByUserItem(userItem);
        if( session ) {
            // 找对对应会话
            FileLog("LiveChatManager",
                    "LSLiveChatCamshareManager::ErrorCheck( "
                    "userId : %s, "
                    "err : %d "
                    ")",
                    userItem->m_userId.c_str(),
                    err
                    );
            
            // 是否继续会话
            bool bFlag = true;
            
            session->Lock();
            session->SetSessionStatus(SessionStatus_Error);
            session->SetErrorType(err);
            
            if( err == LSLIVECHAT_LCC_ERR_FAIL ) {
                // 未知错误, 开始检查流程
                RequestItem* requestItem = new RequestItem();
                requestItem->requestType = Request_Task_ErrorCheckOnline;
                requestItem->param = (TaskParam)session;
                m_operator->InsertRequestTask(this, (TaskParam)requestItem);
                
            } else {
                // 销毁会话
                bFlag = false;
            }
            session->Unlock();

            if( !bFlag ) {
                // 通知界面
                if( m_listener ) {
                    m_listener->OnRecvCamDisconnect(session->GetErrorType(), userItem->m_userId);
                }
                // 销毁会话
                RemoveSessionByUserItem(userItem);
                
            }
        }
        m_sessionMapLock->Unlock();
    }
}

bool LSLiveChatCamshareManager::ErrorCheckLadyOnline(LSLiveChatSession* session) {
    bool bFlag = false;
    LSLCUserItem* userItem = session->GetUserItem();
    if( userItem && m_operator->IsLogin()) {
        int seq = m_client->GetUserInfo(userItem->m_userId);
        bFlag = (seq >= 0);
        session->Lock();
        session->SetParam(seq);
        session->Unlock();
    }
    
//    // 没有登录
//    if (!bFlag) {
//        if( m_listener ) {
//            session->Lock();
//            session->SetErrorType(LSLIVECHAT_LCC_ERR_CONNECTFAIL);
//            m_listener->OnRecvCamDisconnect(session->GetErrorType(), session->GetUserItem()->m_userId);
//            session->Unlock();
//            // 销毁会话
//            RemoveSessionByUserItem(userItem);
//        }
//    }
    
    return bFlag;
}

void LSLiveChatCamshareManager::OnGetUserInfo(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserInfoItem& userInfo) {
    LSLCUserItem* userItem = m_userMgr->GetUserItem(inUserId);
    m_sessionMapLock->Lock();
    LSLiveChatSession* session = GetSessionByUserItem(userItem);
    if( session ) {
        // 是否继续会话
        bool bFlag = true;
        session->Lock();
        if( session->GetParam() == seq ) {
            FileLog("LiveChatManager",
                    "LSLiveChatCamshareManager::OnGetUserInfo( "
                    "userId : %s, "
                    "session : %p "
                    ")",
                    userItem->m_userId.c_str(),
                    session
                    );
            
            // 会话发送的请求才处理
            if( session->GetSessionStatus() == SessionStatus_Error
               || session->GetSessionStatus() == SessionStatus_Cancel
               ) {
                // 会话已经结束
                bool bHandle = true;
                if( err == LSLIVECHAT_LCC_ERR_SUCCESS ) {
                    if( userInfo.status == USTATUS_ONLINE ) {
                        // 用户在线，标记为不能处理
                        bHandle = false;
                    }
                }
                
                if( bHandle ) {
                    // 用户不在线, 回调界面，删除会话
                    bFlag = false;
                    session->SetErrorType(LSLIVECHAT_LCC_ERR_SIDEOFFLINE);
                    
                } else {
                    // 用户在线, 继续检查Camshare服务
                    RequestItem* requestItem = new RequestItem();
                    requestItem->requestType = Request_Task_ErrorCheckCam;
                    requestItem->param = (TaskParam)session;
                    m_operator->InsertRequestTask(this, (TaskParam)requestItem);
                }
            }
        }

        session->Unlock();
        
        if( !bFlag ) {
            // 通知界面
            if( m_listener ) {
                m_listener->OnRecvCamDisconnect(session->GetErrorType(), inUserId);
            }
            // 销毁会话
            RemoveSessionByUserItem(userItem);
        }
    }
    m_sessionMapLock->Unlock();
}

bool LSLiveChatCamshareManager::ErrorCheckLadyCam(LSLiveChatSession* session) {
    bool bFlag = false;
    LSLCUserItem* userItem = session->GetUserItem();
    if( userItem && m_operator->IsLogin()) {
        int seq = m_client->GetLadyCamStatus(userItem->m_userId);
        bFlag = (seq >= 0);
        session->Lock();
        session->SetParam(seq);
        session->Unlock();
    }
//    if (!bFlag) {
//        if( m_listener ) {
//            session->Lock();
//            session->SetErrorType(LSLIVECHAT_LCC_ERR_CONNECTFAIL);
//            m_listener->OnRecvCamDisconnect(session->GetErrorType(), session->GetUserItem()->m_userId);
//            session->Unlock();
//            // 销毁会话
//            RemoveSessionByUserItem(userItem);
//        }
//    }
//    
    return bFlag;
}

void LSLiveChatCamshareManager::OnGetLadyCamStatus(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, bool isOpenCam) {
    // 修改女士状态
    LSLCUserItem* userItem = m_userMgr->GetUserItem(inUserId);
    if( userItem ) {
        if( err == LSLIVECHAT_LCC_ERR_SUCCESS ) {
            userItem->Lock();
            userItem->m_isOpenCam = isOpenCam;
            userItem->Unlock();
        }
        
        // 是否外部命令
        bool bExtern = true;
        m_sessionMapLock->Lock();
        LSLiveChatSession* session = GetSessionByUserItem(userItem);
        if( session ) {
            // 是否继续会话
            bool bFlag = true;
            
            session->Lock();
            if( session->GetParam() == seq  || session->GetLadyCamParam() == seq) {
                // 会话发送的请求才处理
                bExtern = false;
                
                FileLog("LiveChatManager",
                        "LSLiveChatCamshareManager::OnGetLadyCamStatus( "
                        "userId : %s, "
                        "session : %p "
                        ")",
                        userItem->m_userId.c_str(),
                        session
                        );
                
                if( session->GetSessionStatus() == SessionStatus_Error
                   || session->GetSessionStatus() == SessionStatus_Cancel
                   ) {
                    // 会话已经结束，回调界面，删除会话
                    if( err == LSLIVECHAT_LCC_ERR_SUCCESS && isOpenCam ) {
                        session->SetErrorType(LSLIVECHAT_LCC_ERR_FAIL);
                        
                    } else {
                        session->SetErrorType(err);
                    }
                    
                    bFlag = false;
                }
                else
                {
                    // camshare内部发送
                    if ( session->GetLadyCamParam() == seq) {
                        bExtern = false;
                        bFlag = HandleCamshareCheckCoupon(session, err, isOpenCam);
                    }
                }
            }

            session->Unlock();
            
            if( !bFlag ) {
                // 通知界面
                if( m_listener ) {
                    m_listener->OnRecvCamDisconnect(session->GetErrorType(), inUserId);
                }
                // 销毁会话
                RemoveSessionByUserItem(userItem);
            }
        }
        m_sessionMapLock->Unlock();
        
        if( bExtern ) {
            // 通知界面
            if( m_listener ) {
                m_listener->OnGetLadyCamStatus(inUserId, err, errmsg, isOpenCam);
            }
        }
    }
    
}

LSLiveChatSession* LSLiveChatCamshareManager::GetSessionByUserItem(LSLCUserItem* userItem) {
    LSLiveChatSession* session = NULL;
    
    SessionMap::iterator itr = m_sessionMap.find(userItem->m_userId);
    if( itr != m_sessionMap.end() ) {
        session = itr->second;
    }
    
    return session;
}

LSLiveChatSession* LSLiveChatCamshareManager::CreateSessionByUserItem(LSLCUserItem* userItem) {
    LSLiveChatSession* session = NULL;
    
    SessionMap::iterator itr = m_sessionMap.find(userItem->m_userId);
    if( itr != m_sessionMap.end() ) {
        session = itr->second;
        session->Reset();
        
    } else {
        session = new LSLiveChatSession();
        m_sessionMap.insert(SessionMap::value_type(userItem->m_userId, session));
    }
    
    session->SetLCUserItem(userItem);
    
    FileLog("LiveChatManager",
            "LSLiveChatCamshareManager::CreateSessionByUserItem( "
            "userId : %s, "
            "session : %p "
            ")",
            userItem->m_userId.c_str(),
            session
            );
    
    return session;
}

void LSLiveChatCamshareManager::RemoveSessionByUserItem(LSLCUserItem* userItem) {
    SessionMap::iterator itr = m_sessionMap.find(userItem->m_userId);
    if( itr != m_sessionMap.end() ) {
        LSLiveChatSession* session = itr->second;
        m_sessionMap.erase(itr);
        
        FileLog("LiveChatManager",
                "LSLiveChatCamshareManager::RemoveSessionByUserItem( "
                "userId : %s, "
                "session : %p "
                ")",
                userItem->m_userId.c_str(),
                session
                );
        
        delete session;
    }
}

bool LSLiveChatCamshareManager::CreateCamShareInChatSession(LSLCUserItem* userItem) {
    bool bFlag = false;
    
    LSLiveChatSession* session = CreateSessionByUserItem(userItem);
    if( session ) {
        session->Lock();
        session->SetSessionType(SessionType_Camshare);
        session->SetInviteType(SessionInviteType_Invite);
        session->SetSessionStatus(SessionStatus_InChat);
        session->UpdateRecvVideoTime();
        bFlag = true;
        session->Unlock();
    }
    return bFlag;
}

// 内部检查女士cam是否开启
bool LSLiveChatCamshareManager::InsideGetLadyCamStatu(LSLiveChatSession* session) {
    bool bFlag = false;
//        LSLCUserItem* userItem = session->GetUserItem();
//    if( userItem && m_operator->IsLogin()) {
//        session->SetSessionStatus(SessionStatus_GetLadyCamStatus);
//        int seq = m_client->GetLadyCamStatus(userItem->m_userId);
//        bFlag = (seq >= 0);
//        session->Lock();
//        session->SetLadyCamParam(seq);
//        session->Unlock();
//    }

//    if (!bFlag) {
//        if( m_listener ) {
//            session->Lock();
//            session->SetErrorType(LSLIVECHAT_LCC_ERR_CONNECTFAIL);
//            m_listener->OnRecvCamDisconnect(session->GetErrorType(), session->GetUserItem()->m_userId);
//            session->Unlock();
//            // 销毁会话
//            RemoveSessionByUserItem(userItem);
//        }
//    }

    
    return bFlag;


}

// 处理内部检查女士cam
bool LSLiveChatCamshareManager::HandleCamshareCheckCoupon(LSLiveChatSession* session, LSLIVECHAT_LCC_ERR_TYPE err, bool isOpenCam) {
    bool bFlag = false;
    if( err == LSLIVECHAT_LCC_ERR_SUCCESS && isOpenCam ) {
        bFlag = true;
        if( !CheckInsideCoupon(session) ) {
            // 检测是否有点
            RequestItem* requestItem = new RequestItem();
            requestItem->requestType = Request_Task_GetCount;
            requestItem->param = (TaskParam)session;
            m_operator->InsertRequestTask(this, (TaskParam)requestItem);
            
        }
    }
    else {
        // 女士没有打开cam
        if (session->GetSessionCamshareInviteStatus() == SessionCamshareStatus_SendInvite) {
        // 发送邀请前检查到女士没有开cam
             session->SetErrorType(err);
            
        }
        else if (session->GetSessionCamshareInviteStatus() == SessionCamshareStatus_LadyRespondInvite) {
        // 男士接受女士应邀的回复前检查到女士没有开cam
             session->SetErrorType(err);
        }
        else
        {
        // 接收到女士发送的邀请前检查到女士没有开cam
             session->SetErrorType(err);
        
        }
    }

    return bFlag;
}

// ---------------------------------------------------- 任务分发 ----------------------------------------------------
void LSLiveChatCamshareManager::OnLiveChatManManagerTaskRun(TaskParam param) {
    RequestItem* item = (RequestItem *)param;
    if( item ) {
        RequestHandler(item);
        delete item;
    }
}

void LSLiveChatCamshareManager::OnLiveChatManManagerTaskClose(TaskParam param) {
    RequestItem* item = (RequestItem *)param;
    if( item ) {
        delete item;
    }
}

void LSLiveChatCamshareManager::RequestHandler(RequestItem* item) {
    switch (item->requestType)
    {
        case Request_Task_RemoveSession:{
            // 删除会话
//            Session* session = (Session*)item->param;
//            m_sessionMapLock->Lock();
//            RemoveSessionByUserItem(session->GetUserItem());
//            m_sessionMapLock->Unlock();
            
        }break;
        case Request_Task_SendAllCamSessionInvite:{
            // 发送所有待发邀请
        }break;
        case Request_Task_SendCamSessionInvite:{
            // 发送指定会话待发邀请
        }break;
        case Request_Task_TryUseTicket:{
            // 执行使用试聊券流程
            LSLiveChatSession* session = (LSLiveChatSession*)item->param;
            
            if (!UseCoupon(session)) {
                // 执行失败，检测是否有点
                RequestItem* requestItem = new RequestItem();
                requestItem->requestType = Request_Task_GetCount;
                requestItem->param = (TaskParam)session;
                m_operator->InsertRequestTask(this, (TaskParam)requestItem);
            }
            
        }break;
        case Request_Task_GetCount:{
            // 执行获取余额流程
            LSLiveChatSession* session = (LSLiveChatSession*)item->param;
            
            // 暂不检测是否有足够点数，直接发送
            if (!GetLeftCreditProc(session)) {
                // 执行失败，照常发送
                SendCamShareInviteCmd(session);
            }
            
        }break;
        case Request_Task_SendAllSessionHeartBeat:{
            // 发送所有会话心跳
            SendAllSessionHeartBeat();
            
        }break;
        case Request_Task_ErrorCheckOnline:{
            // 发送邀请失败, 检查女士是否在线
            LSLiveChatSession* session = (LSLiveChatSession*)item->param;
            ErrorCheckLadyOnline(session);
            
        }break;
        case Request_Task_ErrorCheckCam:{
            // 发送邀请失败, 检查女士是否打开Camshare服务
            LSLiveChatSession* session = (LSLiveChatSession*)item->param;
            //ErrorCheckLadyCam(session);
            
        }break;
        case Request_Task_CheckAllSessionVideoTimeout:{
            // 检查所有会话视频超时
            CheckAllSessionVideoTimeout();
            
        }break;
        case Request_Task_CheckAllSessionInviteTimeout:{
            // 检查所有会话邀请超时
            CheckAllSessionInviteTimeout();
            
        }break;
        case Request_Task_CheckAllSessionBackgroundTimeout:{
            // 检查所有会话后台超时
            CheckAllSessionBackgroundTimeout();
            
        }break;
        default:break;
            
    }
}
// ---------------------------------------------------- 任务分发 End ----------------------------------------------------

// ---------------------------------------------------- 消息处理器 ----------------------------------------------------
void LSLiveChatCamshareManager::SendAllSessionHeartBeat() {
    m_sessionMapLock->Lock();
    for(SessionMap::const_iterator itr = m_sessionMap.begin(); itr != m_sessionMap.end(); itr++) {
        LSLiveChatSession* session = itr->second;
        session->Lock();
        if( session->GetSessionStatus() == SessionStatus_InChat ) {
            // 会话中发送心跳
            SendCamShareHeartBeat(session);
            
        }
        session->Unlock();
    }
    m_sessionMapLock->Unlock();
    
    static const long stepTime = m_checkHeartBeatTimeStep;
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = Request_Task_SendAllSessionHeartBeat;
    m_operator->InsertRequestTask(this, (TaskParam)requestItem, stepTime);
}

void LSLiveChatCamshareManager::CheckAllSessionVideoTimeout() {
    bool bContinue = true;
    
    list<LSLiveChatSession*> SessionList;
    list<string> strList;
    m_sessionMapLock->Lock();
    for(SessionMap::const_iterator itr = m_sessionMap.begin(); itr != m_sessionMap.end(); itr++) {
        bContinue = true;
        LSLiveChatSession* session = itr->second;
        session->Lock();
        if( session->GetSessionStatus() == SessionStatus_InChat) {
            // [会话状态]为(在聊)
            // 检查超时
            if( getCurrentTime() - session->GetRecvVideoTime() > INVITED_VIDEO_TIMEOUT ) {
                FileLog("LiveChatManager",
                        "LSLiveChatCamshareManager::CheckAllSessionVideoTimeout( "
                        "[Session Video Timeout End], "
                        "userId : %s, "
                        "session : %p "
                        ")",
                        session->GetUserItem()->m_userId.c_str(),
                        session
                        );
                
                SessionList.push_back(session);
                strList.push_back(session->GetUserItem()->m_userId);
                bContinue = false;
            }
        }
        session->Unlock();
    }
    m_sessionMapLock->Unlock();
    
    // 防止外面回调锁死主线程
    for (list<string>::iterator itor = strList.begin(); itor != strList.end(); itor++) {
        if (m_listener) {
            string str = *itor;
            m_listener->OnRecvCamDisconnect(LSLIVECHAT_LCC_ERR_NOVIDEOTIMEOUT, str);
        }
    }
    
    m_sessionMapLock->Lock();
    for(SessionMap::const_iterator itr = m_sessionMap.begin(); itr != m_sessionMap.end(); itr++) {
        bContinue = true;
        LSLiveChatSession* session = itr->second;
        session->Lock();
        if( session->GetSessionStatus() == SessionStatus_InChat) {
            // [会话状态]为(在聊)
            // 检查超时
            if( getCurrentTime() - session->GetRecvVideoTime() > INVITED_VIDEO_TIMEOUT ) {
                FileLog("LiveChatManager",
                        "LSLiveChatCamshareManager::CheckAllSessionVideoTimeout( "
                        "[Session Video Timeout End], "
                        "userId : %s, "
                        "session : %p "
                        ")",
                        session->GetUserItem()->m_userId.c_str(),
                        session
                        );

               // 发送结束会话命令, 发送完成会销毁会话
                for (list<LSLiveChatSession*>::const_iterator itor = SessionList.begin(); itor != SessionList.end(); itor++) {
                    LSLiveChatSession* oldSession = *itor;
                    if (oldSession == session) {
                        SendEndTalkCmd(session);
                        bContinue = false;
                    }
                }

            }
        }
        session->Unlock();
        
        if( !bContinue ) {
            RemoveSessionByUserItem(session->GetUserItem());
            break;
        }
    }
    m_sessionMapLock->Unlock();
    
    static const long stepTime = CHECK_INVITED_VIDEO_TIME_STEP;
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = Request_Task_CheckAllSessionVideoTimeout;
    m_operator->InsertRequestTask(this, (TaskParam)requestItem, stepTime);
}

void LSLiveChatCamshareManager::CheckAllSessionInviteTimeout() {
    m_sessionMapLock->Lock();
    for(SessionMap::const_iterator itr = m_sessionMap.begin(); itr != m_sessionMap.end(); itr++) {
        LSLiveChatSession* session = itr->second;
        bool bContinue = true;
        session->Lock();
        if( session->GetSessionStatus() == SessionStatus_Invite
           && session->GetInviteType() == SessionInviteType_Invite
           ) {
            // [会话状态]为(邀请中)， [邀请状态]为(主动邀请)
            // 检查超时
            if( getCurrentTime() - session->GetInviteTime() > INVITE_TIMEOUT ) {
                // 超过2分钟, 或调失败，销毁会话
                FileLog("LiveChatManager",
                        "LSLiveChatCamshareManager::CheckAllSessionInviteTimeout( "
                        "[Session Invite Timeout End], "
                        "userId : %s, "
                        "session : %p "
                        ")",
                        session->GetUserItem()->m_userId.c_str(),
                        session
                        );
                
                // 通知界面
                if( m_listener ) {
                    m_listener->OnRecvCamDisconnect(LSLIVECHAT_LCC_ERR_INVITETIMEOUT, session->GetUserItem()->m_userId);
                }
                
                if (session->GetBackground()) {
                    bContinue = false;
                }
                else
                {
                    // 发送取消邀请, 发送完成会销毁会话
                    SendCamShareCancelInviteCmd(session);
                }

                
            } else if( getCurrentTime() - session->GetInviteTime() > INVITE_CANCEL_TIMEOUT ) {
                // 超过1分钟, 或调可以取消邀请
                FileLog("LiveChatManager",
                        "LSLiveChatCamshareManager::CheckAllSessionInviteTimeout( "
                        "[Session Invite Can Cancel], "
                        "userId : %s, "
                        "session : %p "
                        ")",
                        session->GetUserItem()->m_userId.c_str(),
                        session
                        );
                
                // 通知界面
                if( m_listener ) {
                    m_listener->OnRecvCamInviteCanCancel(session->GetUserItem()->m_userId);
                }
                
            }
        } else if( session->GetInviteType() == SessionInviteType_Invited ) {
            // [邀请状态]为(被邀)
            if( getCurrentTime() - session->GetInviteTime() > INVITED_TIMEOUT ) {
                // 邀请超时，暂时不处理，等待下次发送邀请会检测超时
            }
        }
        session->Unlock();
        
        if( !bContinue ) {
            RemoveSessionByUserItem(session->GetUserItem());
            break;
        }
    }
    m_sessionMapLock->Unlock();
    
    static const long stepTime = CHECK_INVITE_TIME_STEP;
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = Request_Task_CheckAllSessionInviteTimeout;
    m_operator->InsertRequestTask(this, (TaskParam)requestItem, stepTime);
}

void LSLiveChatCamshareManager::CheckAllSessionBackgroundTimeout() {
    bool bContinue = true;
    m_sessionMapLock->Lock();
    for(SessionMap::const_iterator itr = m_sessionMap.begin(); itr != m_sessionMap.end(); itr++) {
        LSLiveChatSession* session = itr->second;
        session->Lock();
        if( session->GetSessionStatus() == SessionStatus_InChat && session->GetBackground() ) {
            // [会话状态]为(会话中), 并且当前在后台
            // 检查超时
            if( getCurrentTime() - session->GetBackgroundTime() > BACKGROUND_END_TIMEOUT ) {
                // 超过3分钟, 回调失败，销毁会话
                FileLog("LiveChatManager",
                        "LSLiveChatCamshareManager::CheckAllSessionBackgroundTimeout( "
                        "[Session Background Timeout End], "
                        "userId : %s, "
                        "session : %p "
                        ")",
                        session->GetUserItem()->m_userId.c_str(),
                        session
                        );
                
                // 通知界面
                if( m_listener ) {
                    m_listener->OnRecvCamDisconnect(LSLIVECHAT_LCC_ERR_BACKGROUNDTIMEOUT, session->GetUserItem()->m_userId);
                }
                
                // 发送结束会话命令, 发送完成会销毁会话
                SendEndTalkCmd(session);
                bContinue = false;
                
            } else if( getCurrentTime() - session->GetBackgroundTime() > BACKGROUND_TIPS_TIMEOUT ) {
                // 超过2分钟, 回调提示
                FileLog("LiveChatManager",
                        "LSLiveChatCamshareManager::CheckAllSessionBackgroundTimeout( "
                        "[Session Background Timeout Tips], "
                        "userId : %s, "
                        "session : %p "
                        ")",
                        session->GetUserItem()->m_userId.c_str(),
                        session
                        );
                
                // 通知界面
                if( m_listener ) {
                    m_listener->OnRecvBackgroundTimeout(session->GetUserItem()->m_userId);
                }
                
            }
        }
        session->Unlock();
        
        if( !bContinue ) {
            RemoveSessionByUserItem(session->GetUserItem());
            break;
        }
    }
    m_sessionMapLock->Unlock();
    
    static const long stepTime = CHECK_INVITE_TIME_STEP;
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = Request_Task_CheckAllSessionBackgroundTimeout;
    m_operator->InsertRequestTask(this, (TaskParam)requestItem, stepTime);
}
// ---------------------------------------------------- 消息处理器 End ----------------------------------------------------
