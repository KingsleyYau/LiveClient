//
//  LSLiveChatSession.h
//  Common-C-Library
//
//  Created by Max on 2017/2/24.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#ifndef LSLiveChatSession_h
#define LSLiveChatSession_h

#include <stdio.h>

#include "LSLCUserItem.h"

#define INVALID_SESSIONID -1

namespace LSLiveChatsession {
    typedef enum SessionType {
        SessionType_Livechat = 0,
        SessionType_Camshare = 1,
    } SessionType;

    typedef enum SessionInviteType {
        SessionInviteType_Invite = 0,
        SessionInviteType_Invited = 1,
    } SessionInviteType;

    typedef enum SessionStatus {
        SessionStatus_Unknow = 0,
        SessionStatus_GetLadyCamStatus,
        SessionStatus_CheckCoupon,
        SessionStatus_UseCoupon,
        SessionStatus_GetCount,
        SessionStatus_Invite,
        SessionStatus_Cancel,
        SessionStatus_Apply,
        SessionStatus_InChat,
        SessionStatus_Error,
    } SessionStatus;
    
    typedef enum SessionCamshareStatus {
        SessionCamshareStatus_SendInvite = 0,         // 男士发送邀请
        SessionCamshareStatus_LadyRespondInvite = 1,  // 男士接受女士应邀的回复
        SessionCamshareStatus_RecvLadyInvite = 2,     // 接收到女士发送的邀请
    } SessionCamshareStatus;
    
    
class LSLiveChatSession {
public:
    LSLiveChatSession();
    ~LSLiveChatSession();
    
    void Reset();
    
    LSLCUserItem* GetUserItem();
    void SetLCUserItem(LSLCUserItem* userItem);
    
    int GetCamSessionId();
    void SetCamSessionId(int camSessionId);
    
    SessionType GetSessionType();
    void SetSessionType(SessionType sessionType);
    
    SessionInviteType GetInviteType();
    void SetInviteType(SessionInviteType sessionInviteType);
    
    SessionStatus GetSessionStatus();
    void SetSessionStatus(SessionStatus sessionStatus);
    
    void Lock();
    void Unlock();
    
    unsigned long long GetParam();
    void SetParam(unsigned long long param);
    
    unsigned long long GetLadyCamParam();
    void SetLadyCamParam(unsigned long long param);
    
    LSLIVECHAT_LCC_ERR_TYPE GetErrorType();
    void SetErrorType(LSLIVECHAT_LCC_ERR_TYPE type);
    
    long long GetInviteTime();
    void SetInviteTime(long long inviteTime);
    
    long long GetRecvVideoTime();
    void UpdateRecvVideoTime();
    
    bool GetBackground();
    void SetBackground(bool background);
    
    long long GetBackgroundTime();
    
    SessionCamshareStatus GetSessionCamshareInviteStatus();
    void SetSessionCamshareInviteStatus(SessionCamshareStatus sessionStatus);
    
private:
    // 用户信息
    LSLCUserItem* m_userItem;
    
    // 主动发送邀请计数器
    int m_camSessionId;
    
    // 会话类型
    SessionType m_sessionType;
    // 邀请状态
    SessionInviteType m_sessionInviteType;
    // 会话状态
    SessionStatus m_sessionStatus;
    
    // 状态锁
    IAutoLock* m_lock;
    
    // 自定义参数
    unsigned long long m_param;
    
    // 自定义内部检查女士cam是否打开参数
    unsigned long long m_ladyCamParam;
    
    // 邀请开始时间
    long long m_inviteTime;
    
    // 最后收到视频流时间
    long long m_recvVideoTime;
    
    // 设置后台开始时间
    long long m_backgroundTime;
    
    // 错误码
    LSLIVECHAT_LCC_ERR_TYPE m_errType;
    
    // 会话是否在后台
    bool m_background;
    
    // 男士对camshare邀请处理状态
    SessionCamshareStatus mCamShareInviteStatus;
    
//    Coupon mCoupon;
};
}


#endif /*  LSLiveChatSession_hpp */
