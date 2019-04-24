//
//  LSLiveChatSender.h
//  Common-C-Library
//
//  Created by Max on 2017/2/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#ifndef ILSLiveChatSender_h
#define ILSLiveChatSender_h

#include <stdio.h>

#include "ILSLiveChatManManager.h"
#include "ILSLiveChatManManagerOperator.h"
//#include "ILSLiveChatClient.h"
#include <livechat/ILSLiveChatClient.h>
#include <common/KLog.h>

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

class LSLiveChatSender : public ILSLiveChatClientListener
                        , public ILSLiveChatRequestLiveChatControllerCallback
                        , public ILSLiveChatRequestOtherControllerCallback
{
public:
    LSLiveChatSender(
                      ILSLiveChatManManagerOperator* pOperator,
                      ILSLiveChatManManagerListener* pListener,
                      ILSLiveChatClient*	pClient,
                      // 消息管理器
                      LSLCTextManager* pTextMgr,
                      LSLCEmotionManager* pEmotionMgr,
                      LSLCVoiceManager* pVoiceMgr,
                      LSLCPhotoManager* ppPhotoMgr,
                      LSLCVideoManager* pVideoMgr,
                      LSLCMagicIconManager* pMagicIconMgr,
                      // 用户管理器
                      LSLCUserManager* pUserMgr,
                      LSLCInviteManager* pInviteMgr,
                      // Http接口
                      LSLiveChatHttpRequestManager* pHttpRequestManager
    );
    ~LSLiveChatSender();
    
    // 发送待发消息列表处理
    void SendMessageListProc(LSLCUserItem* userItem);
    // 返回待发送消息错误处理
    void SendMessageListFailProc(LSLCUserItem* userItem, LSLIVECHAT_LCC_ERR_TYPE errType);
    
    // 发送消息item
    void SendMessageItem(LSLCMessageItem* item);
    
    // 发送文本消息处理
    void SendTextMessageProc(LSLCMessageItem* item);
    // 发送高级表情消息处理
    void SendEmotionProc(LSLCMessageItem* item);
    // 发送语音处理
    void SendVoiceProc(LSLCMessageItem* item);
    // 发送图片处理
    void SendPhotoProc(LSLCMessageItem* item);
    // 发送小高级表情消息处理
    void SendMagicIconProc(LSLCMessageItem* item);
   
private:
    // Http
    virtual void OnSendPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCLCSendPhotoItem& item) override;
    virtual void OnUploadManPhoto(long requestId, bool success, int errnum, const string& errmsg, const string& url, const string& md5) override;
   
    // ------------------- ILSLiveChatRequestLiveChatControllerCallback -------------------
private:
    virtual void OnUploadVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& voiceId) override;
    
private:
    // Livechat
    void OnSendTextMessage(const string& inUserId, const string& inMessage, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnSendEmotion(const string& inUserId, const string& inEmotionId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnSendVGift(const string& inUserId, const string& inGiftId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnSendVoice(const string& inUserId, const string& inVoiceId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    void OnGetVoiceCode(const string& inUserId, int ticket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& voiceCode) override;
    void OnSendPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket) override;
    void OnSendMagicIcon(const string& inUserId, const string& inIconId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
    
private:
    // 设置用户在线状态，若用户在线状态改变则callback通知listener
    void SetUserOnlineStatus(LSLCUserItem* userItem, USER_STATUS_TYPE statusType);
    // 根据错误类型设置用户在线状态，若用户在线状态改变则callback通知listener
    void SetUserOnlineStatusWithLccErrType(LSLCUserItem* userItem, LSLIVECHAT_LCC_ERR_TYPE errType);
	// 发送图片处理（仅LiveChat消息）
	void SendPhotoLiveChatMsgProc(LSLCMessageItem* item);
    // 发送消息成功后，更新会话状态(包括文字，表情，图片)，功能：为了endtalk的取消，判断是否时男士自动邀请
    void OnSendMessageSessionProcess(LSLCMessageItem* item);
    // 处理错误码是否时Token过期(根据字符串和整形)
    void HandleTokenOverWithErrCode(int errNum, const string& errNo, const string& errmsg);
    // 根据错误码判断是否余额不足
    void HandleNotSufficientFunds(const string& errNo, const string& userId);
    
private:
    ILSLiveChatManManagerOperator* m_operator;
    ILSLiveChatManManagerListener* m_listener;	// 回调
    ILSLiveChatClient*	m_client;               // LiveChat客户端
    
    // 消息管理器
    LSLCTextManager*		m_textMgr;		// 文本管理器
    LSLCEmotionManager*	m_emotionMgr;	// 高级表情管理器
    LSLCVoiceManager*		m_voiceMgr;		// 语音管理器
    LSLCPhotoManager*		m_photoMgr;		// 图片管理器
    LSLCVideoManager*		m_videoMgr;		// 视频管理器
    LSLCMagicIconManager* m_magicIconMgr; //小高级表情管理器
    
    // 用户管理器
    LSLCUserManager*		m_userMgr;		// 用户管理器
    LSLCInviteManager*	m_inviteMgr;	// 邀请管理器
    
    // Http接口
    LSLiveChatRequestLiveChatController* m_requestController;		// LiveChat请求控制器
    LSLiveChatRequestOtherController*	m_requestOtherController;	// Other请求控制器
};

#endif /* LSLiveChatSender_h */
