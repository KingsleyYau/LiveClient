//
//  LSLiveChatLSLiveChatSession.cpp
//  Common-C-Library
//  Camshare会话实例
//  Created by Max on 2017/2/24.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#include "LSLiveChatSession.h"
#include <common/CommonFunc.h>

using namespace LSLiveChatsession;

LSLiveChatSession::LSLiveChatSession() {
    m_lock = IAutoLock::CreateAutoLock();
    m_lock->Init(IAutoLock::IAutoLockType_Recursive);
    
    Reset();
}

LSLiveChatSession::~LSLiveChatSession() {
    IAutoLock::ReleaseAutoLock(m_lock);
}

void LSLiveChatSession::Reset() {
    m_sessionType = SessionType_Camshare;
    m_sessionInviteType = SessionInviteType_Invite;
    m_sessionStatus = SessionStatus_Unknow;
    m_camSessionId = INVALID_SESSIONID;
    
    m_userItem = NULL;
    m_param = 0;
    m_ladyCamParam = 0;
    m_errType = LSLIVECHAT_LCC_ERR_SUCCESS;
    
    m_inviteTime = 0;
    m_recvVideoTime = 0;
    m_background = false;
    m_backgroundTime = 0;
    
    mCamShareInviteStatus = SessionCamshareStatus_SendInvite;
}

LSLCUserItem* LSLiveChatSession::GetUserItem() {
    return m_userItem;
}

void LSLiveChatSession::SetLCUserItem(LSLCUserItem* userItem) {
    m_userItem = userItem;
}

int LSLiveChatSession::GetCamSessionId() {
    return m_camSessionId;
}

void LSLiveChatSession::SetCamSessionId(int camSessionId) {
    m_camSessionId = camSessionId;
}

SessionType LSLiveChatSession::GetSessionType() {
    return m_sessionType;
}

void LSLiveChatSession::SetSessionType(SessionType SessionType) {
    m_sessionType = SessionType;
}

SessionInviteType LSLiveChatSession::GetInviteType() {
    return m_sessionInviteType;
}

void LSLiveChatSession::SetInviteType(SessionInviteType SessionInviteType) {
    m_sessionInviteType = SessionInviteType;
}

SessionStatus LSLiveChatSession::GetSessionStatus() {
    return m_sessionStatus;
}

void LSLiveChatSession::SetSessionStatus(SessionStatus SessionStatus) {
    m_sessionStatus = SessionStatus;
}

void LSLiveChatSession::Lock() {
    m_lock->Lock();
}

void LSLiveChatSession::Unlock() {
    m_lock->Unlock();
}

unsigned long long LSLiveChatSession::GetParam() {
    return m_param;
}

void LSLiveChatSession::SetParam(unsigned long long param) {
    m_param = param;
}

unsigned long long LSLiveChatSession::GetLadyCamParam() {
    return m_ladyCamParam;
}

void LSLiveChatSession::SetLadyCamParam(unsigned long long param) {
    m_ladyCamParam = param;
}


LSLIVECHAT_LCC_ERR_TYPE LSLiveChatSession::GetErrorType() {
    return m_errType;
}

void LSLiveChatSession::SetErrorType(LSLIVECHAT_LCC_ERR_TYPE type) {
    m_errType = type;
}

long long LSLiveChatSession::GetInviteTime() {
    return m_inviteTime;
}

void LSLiveChatSession::SetInviteTime(long long inviteTime) {
    m_inviteTime = inviteTime;
}

long long LSLiveChatSession::GetRecvVideoTime() {
    return m_recvVideoTime;
}

void LSLiveChatSession::UpdateRecvVideoTime() {
    m_recvVideoTime = getCurrentTime();
}

bool LSLiveChatSession::GetBackground() {
    return m_background;
}

void LSLiveChatSession::SetBackground(bool background) {
    if( m_background != background ) {
        m_background = background;
        
        if ( m_background ) {
            // 开始计时
            m_backgroundTime = getCurrentTime();
        }
    }
}

long long LSLiveChatSession::GetBackgroundTime() {
    return m_backgroundTime;
}

SessionCamshareStatus LSLiveChatSession::GetSessionCamshareInviteStatus() {
    return mCamShareInviteStatus;
}

void LSLiveChatSession::SetSessionCamshareInviteStatus(SessionCamshareStatus SessionStatus) {
    mCamShareInviteStatus = SessionStatus;
}
