//
//  LSLiveChatSessionManager.h
//  Common-C-Library
//
//  Created by Max on 2017/2/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#ifndef LSLiveChatSessionManager_h
#define LSLiveChatSessionManager_h

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

class RequestItem;
class LSLiveChatSessionManager : public ILSLiveChatManManagerTaskCallback
                                , public ILSLiveChatRequestLiveChatControllerCallback
                                , public ILSLiveChatRequestOtherControllerCallback
                                , public ILSLiveChatClientListener
                                {
public:
    LSLiveChatSessionManager(
                           ILSLiveChatManManagerOperator* pOperator,
                           ILSLiveChatManManagerListener* pListener,
                           ILSLiveChatClient*	pClient,
                           LSLiveChatSender* pLSLiveChatSender,
                           LSLCUserManager* pUserMgr,
                           LSLiveChatHttpRequestManager* pHttpRequestManager
                           );
    
    ~LSLiveChatSessionManager();
    
    // 重置参数
    void Reset();
    void Start();
                                    
    // 发送消息
    bool SendMsg(LSLCUserItem* userItem, LSLCMessageItem* msgItem);
    // 结束会话
    bool EndTalk(LSLCUserItem* userItem);
                                    
private:
    // 定时任务处理
    void OnLiveChatManManagerTaskRun(TaskParam param) override;
    void OnLiveChatManManagerTaskClose(TaskParam param) override;

    // 是否立即发送消息给用户
    bool IsSendMessageNow(LSLCUserItem* userItem);
                                    
    // 检查试聊券
    bool CheckCouponProc(LSLCUserItem* userItem);
    void OnCheckCoupon(long requestId, bool success, const LSLCCoupon& item, const string& userId, const string& errnum, const string& errmsg) override;

    // 是否检测试聊券
    bool IsCheckCoupon(LSLCUserItem* userItem);

    // 试聊券请求处理函数
    bool UseTryTicketProc(LSLCUserItem* userItem);
    void OnUseTryTicket(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, TRY_TICKET_EVENT tickEvent) override;
    void OnUseCoupon(long requestId, bool success, const string& errnum, const string& errmsg, const string& userId, const string& couponid) override;
    
    // 检查用户信息
    bool GetCountProc(LSLCUserItem* userItem);
    void OnGetCount(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherGetCountItem& item) override;
                                    
    // 获取帐号余额，代替上面的OnGetCount
    bool GetLeftCreditProc(LSLCUserItem* userItem);
    void OnGetLeftCredit(long requestId, bool success, int errnum, const string& errmsg, double credit, int coupon) override;
   
    // 发送待发消息列表
    void SendMessageList(LSLCUserItem* userItem);
                                
    // 定时业务处理器
    void RequestHandler(RequestItem* item);
    
    // 结束会话
    void OnEndTalk(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) override;
                                    
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
                                    
    // LiveChat请求控制器
    LSLiveChatRequestLiveChatController* m_requestController;
    // Other请求控制器
    LSLiveChatRequestOtherController*	m_requestOtherController;

    map_lock<long, LSLCUserItem*> m_inviteMsgMap;
            
};

#endif /* LiveChatSessionManager_h */
