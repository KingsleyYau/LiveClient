//
//  LSLiveChatSessionManager.cpp
//  Common-C-Library
//
//  Created by Max on 2017/2/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#include "LSLiveChatSessionManager.h"
#include "LSLiveChatEnumDefine.h"

// 定时业务类型
typedef enum {
    REQUEST_TASK_Unknow,						// 未知请求类型
    REQUEST_TASK_CheckCouponWithToSendUser,		// 有待发消息的用户调用检测试聊券流程
    REQUEST_TASK_SendMessageList,				// 发送指定用户的待发消息
    REQUEST_TASK_TryUseTicket,					// 执行使用试聊券流程
    REQUEST_TASK_GetCount,						// 执行获取余额流程
} REQUEST_TASK_TYPE;

// 定时业务结构体
class RequestItem
{
public:
    RequestItem()
    {
        requestType = REQUEST_TASK_Unknow;
        param = 0;
    }
    
    RequestItem(const RequestItem& item)
    {
        requestType = item.requestType;
        param = item.param;
    }
    
    ~RequestItem(){};
    
    REQUEST_TASK_TYPE requestType;
    unsigned long long param;
};

LSLiveChatSessionManager::LSLiveChatSessionManager(
                                               ILSLiveChatManManagerOperator* pOperator,
                                               ILSLiveChatManManagerListener* pListener,
                                               ILSLiveChatClient*	pClient,
                                               LSLiveChatSender* pLSLiveChatSender,
                                               LSLCUserManager* pUserMgr,

                                               LSLiveChatHttpRequestManager* pHttpRequestManager
                                               ) {
    m_operator = pOperator;
    m_listener = pListener;
    m_client = pClient;
    m_liveChatSender = pLSLiveChatSender;
    
    m_userMgr = pUserMgr;
    
    m_requestController = new LSLiveChatRequestLiveChatController(pHttpRequestManager, this);
    m_requestOtherController = new LSLiveChatRequestOtherController(pHttpRequestManager, this);
    
    if( m_client ) {
        m_client->AddListener(this);
    }
}

LSLiveChatSessionManager::~LSLiveChatSessionManager() {
    if( m_requestController ) {
        delete m_requestController;
        m_requestController = NULL;
    }
    
    if( m_requestOtherController ) {
        delete m_requestOtherController;
        m_requestOtherController = NULL;
    }
    
    if( m_client ) {
        m_client->RemoveListener(this);
    }
}

void LSLiveChatSessionManager::Reset() {
}

void LSLiveChatSessionManager::Start() {
    // 使用试聊券，发送待发消息
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = REQUEST_TASK_CheckCouponWithToSendUser;
    m_operator->InsertRequestTask(this, (TaskParam)requestItem);
}

bool LSLiveChatSessionManager::EndTalk(LSLCUserItem* userItem) {
    bool bFlag = false;

    // 判断是否是登录成功了（解决在livechat时，断网了，在重连时不能发endtalk，防止在重连中，按了endtalk，等了重连成功会，关闭会话框）
    if (m_operator->IsLogin()) {
        bFlag = m_client->EndTalk(userItem->m_userId);
    }
    return bFlag;
}

void LSLiveChatSessionManager::OnLiveChatManManagerTaskRun(TaskParam param) {
    RequestItem* item = (RequestItem *)param;
    if( item ) {
        RequestHandler(item);
        delete item;
    }
}

void LSLiveChatSessionManager::OnLiveChatManManagerTaskClose(TaskParam param) {
    RequestItem* item = (RequestItem *)param;
    if( item ) {
        delete item;
    }
}

void LSLiveChatSessionManager::RequestHandler(RequestItem* item) {
    switch (item->requestType)
    {
        case REQUEST_TASK_Unknow:break;
        case REQUEST_TASK_CheckCouponWithToSendUser:{
            // 有待发消息的用户调用检测试聊券流程
            LCUserList userList = m_userMgr->GetToSendUsers();
            for (LCUserList::iterator iter = userList.begin();
                 iter != userList.end();
                 iter++)
            {
                LSLCUserItem* userItem = (*iter);
                if (NULL != userItem) {
                    if ( IsCheckCoupon(userItem) || !CheckCouponProc(userItem)) {
                        // 执行失败，照常发送
                        SendMessageList(userItem);
                    }
                }
            }
        }break;
        case REQUEST_TASK_SendMessageList:{
            // 发送指定用户的待发消息
            LSLCUserItem* userItem = (LSLCUserItem*)item->param;
            if (NULL != userItem) {
                m_liveChatSender->SendMessageListProc(userItem);
            }
        }break;
        case REQUEST_TASK_TryUseTicket:{
            // 执行使用试聊券流程
            LSLCUserItem* userItem = (LSLCUserItem*)item->param;
            if (NULL != userItem) {
                if (!UseTryTicketProc(userItem)) {
                    // 执行失败，检测是否有点
                    RequestItem* requestItem = new RequestItem();
                    requestItem->requestType = REQUEST_TASK_GetCount;
                    requestItem->param = (TaskParam)userItem;
                    m_operator->InsertRequestTask(this, (TaskParam)requestItem);
                }
            }
        }break;
        case REQUEST_TASK_GetCount:{
            // 执行获取余额流程
            LSLCUserItem* userItem = (LSLCUserItem*)item->param;
            if (NULL != userItem) {
                // 暂不检测是否有足够点数，直接发送
                if (!GetLeftCreditProc(userItem)) {
                    // 执行失败，照常发送
                    LSLIVECHAT_LCC_ERR_TYPE errType = LSLIVECHAT_LCC_ERR_CONNECTFAIL;
                    m_liveChatSender->SendMessageListFailProc(userItem, errType);
                }
            }
        }break;

    }
}

bool LSLiveChatSessionManager::CheckCouponProc(LSLCUserItem* userItem)
{
    bool result = false;
    if (NULL != userItem)
    {
        long requestId = m_requestController->CheckCoupon(userItem->m_userId);
        result = HTTPREQUEST_INVALIDREQUESTID != requestId;
        
        FileLog("LiveChatManager", "LiveChatSessionManager::CheckCouponProc() userId:%s", userItem->m_userId.c_str());
    }
    return result;
}

void LSLiveChatSessionManager::OnCheckCoupon(long requestId, bool success, const LSLCCoupon& item, const string& userId, const string& errnum, const string& errmsg) {
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    
    FileLog("LiveChatManager", "LiveChatSessionManager::OnCheckCoupon() userId:%s, userItem:%p, success:%d, errnum:%s, errmsg:%s, status:%d"
            , userId.c_str(), userItem, success, errnum.c_str(), errmsg.c_str(), item.status);
    if (NULL != userItem)
    {
        FileLog("LiveChatManager", "LiveChatSessionManager::OnCheckCoupon() userId:%s", userId.c_str());
        
        // 判断试聊券是否可用
        bool canUse = (item.status == CouponStatus_Yes || item.status == CouponStatus_Started);
        
        // LiveChatManManager内部操作
        if (success && canUse)
        {
            // 尝试使用试聊券
            LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
            RequestItem* requestItem = new RequestItem();
            requestItem->requestType = REQUEST_TASK_TryUseTicket;
            requestItem->param = (TaskParam)userItem;
            m_operator->InsertRequestTask(this, (TaskParam)requestItem);
        }
        else {
            // 检测是否有点
            LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
            RequestItem* requestItem = new RequestItem();
            requestItem->requestType = REQUEST_TASK_GetCount;
            requestItem->param = (TaskParam)userItem;
            m_operator->InsertRequestTask(this, (TaskParam)requestItem);
        }
        
    }

    HandleTokenOverErrCode(0, errnum, errmsg);
    
}

void LSLiveChatSessionManager::OnUseCoupon(long requestId, bool success, const string& errnum, const string& errmsg, const string& userId, const string& couponid)
{
	bool isUseTryTicketOk = false;
	if (success) {
		isUseTryTicketOk = m_client->UseTryTicket(userId);
	}

	if (!isUseTryTicketOk) {
		// 使用试聊券失败，检测是否有点
		LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
        RequestItem* requestItem = new RequestItem();
        requestItem->requestType = REQUEST_TASK_GetCount;
        requestItem->param = (TaskParam)userItem;
		m_operator->InsertRequestTask(this, (TaskParam)requestItem);
	}

    HandleTokenOverErrCode(0, errnum, errmsg);
}

bool LSLiveChatSessionManager::SendMsg(LSLCUserItem* userItem, LSLCMessageItem* msgItem) {
    bool result = false;
    
    if (IsSendMessageNow(userItem))
    {
        if (!IsCheckCoupon(userItem)) {
            // 立即发送
            m_liveChatSender->SendMessageItem(msgItem);
        }
        else {
            // 把消息添加到待发列表
            userItem->InsertSendMsgList(msgItem);
            // 执行尝试使用试聊券流程
            CheckCouponProc(userItem);
        }
        
        result = true;
    }
    else if (m_operator && m_operator->IsAutoLogin())
    {
        // 把消息添加到待发列表
        userItem->InsertSendMsgList(msgItem);
        result = true;
    }
    
    return result;
}

bool LSLiveChatSessionManager::IsSendMessageNow(LSLCUserItem* userItem)
{
    bool result = false;
    if (NULL != userItem)
    {
        result = m_operator->IsLogin() && m_operator->IsGetHistory();
    }
    return result;
}

bool LSLiveChatSessionManager::IsCheckCoupon(LSLCUserItem* userItem)
{
    bool result = false;
    result = !(userItem->m_chatType == LC_CHATTYPE_IN_CHAT_CHARGE
               || userItem->m_chatType == LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET
               || userItem->m_chatType == LC_CHATTYPE_MANINVITE );
    return result;
}

void LSLiveChatSessionManager::HandleTokenOverErrCode(int errNum, const string& errNo, const string& errmsg)
{
    if (IsTokenOverWithString(errNo) || IsTokenOverWithInt(errNum)) {
        m_listener->OnTokenOverTimeHandler(LIVECHATERRCODE_TOKEN_OVER, errmsg);
    }
}

bool LSLiveChatSessionManager::UseTryTicketProc(LSLCUserItem* userItem)
{
    bool result = false;
    if (NULL != userItem)
    {
        long requestId = m_requestController->UseCoupon(userItem->m_userId);
        result = HTTPREQUEST_INVALIDREQUESTID != requestId;
    }
    return result;
}

void LSLiveChatSessionManager::OnUseTryTicket(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, TRY_TICKET_EVENT tickEvent)
{
	m_listener->OnUseTryTicket(err, errmsg, userId, tickEvent);

	if (err != LSLIVECHAT_LCC_ERR_SUCCESS) {
		// 使用不成功，生成警告消息
		m_operator->BuildAndInsertWarningWithErrType(inUserId, err);
		// 检测是否有足够余额
		LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
        RequestItem* requestItem = new RequestItem();
        requestItem->requestType = REQUEST_TASK_GetCount;
        requestItem->param = (TaskParam)userItem;
        m_operator->InsertRequestTask(this, (TaskParam)requestItem);
	}
	else {
		// 若当前状态为Other或女士邀请，则标记为ManInvite(男士邀请)状态
		LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
		if (NULL != userItem) {
			if (userItem->m_chatType == LC_CHATTYPE_OTHER
				|| userItem->m_chatType == LC_CHATTYPE_INVITE)
			{
				userItem->m_chatType = LC_CHATTYPE_MANINVITE;
			}
		}
		// 使用成功，发送待发消息
        RequestItem* requestItem = new RequestItem();
        requestItem->requestType = REQUEST_TASK_SendMessageList;
        requestItem->param = (TaskParam)userItem;
        m_operator->InsertRequestTask(this, (TaskParam)requestItem);
	}
}

bool LSLiveChatSessionManager::GetCountProc(LSLCUserItem* userItem)
{
    bool result = false;
    if (NULL != userItem)
    {
        long requestId = m_requestOtherController->GetCount(true, false, false, false, false, false);
        result = HTTPREQUEST_INVALIDREQUESTID != requestId;
        if (result) {
            m_inviteMsgMap.lock();
            m_inviteMsgMap.insert(map<long, LSLCUserItem*>::value_type(requestId, userItem));
            m_inviteMsgMap.unlock();
        }
    }
    return result;
}

void LSLiveChatSessionManager::OnGetCount(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherGetCountItem& item)
{
    FileLog("LiveChatManager", "LiveChatSessionManager::OnGetCount() begin");
    bool isSuccess = success;
    LSLCOtherGetCountItem CountItem = item;
    LSLCUserItem* userItem = NULL;
    
    // 获取待发消息的userItem
    m_inviteMsgMap.lock();
    map<long, LSLCUserItem*>::iterator iter = m_inviteMsgMap.find(requestId);
    if (iter != m_inviteMsgMap.end()) {
        userItem = (*iter).second;
        m_inviteMsgMap.erase(iter);
    }
    m_inviteMsgMap.unlock();
    
    if (isSuccess) {
        // 判断点是不是大于聊天最少点
        if (CountItem.money >= m_operator->GetMinBalance() && NULL != userItem) {
            // 发送代发消息
            SendMessageList(userItem);
        }
        else{
            // 失败
            LSLIVECHAT_LCC_ERR_TYPE errType = LSLIVECHAT_LCC_ERR_NOMONEY;
            m_liveChatSender->SendMessageListFailProc(userItem, errType);
        }
    }
    // 连接失败
    else
    {
        LSLIVECHAT_LCC_ERR_TYPE fErrType = LSLIVECHAT_LCC_ERR_CONNECTFAIL;
        m_liveChatSender->SendMessageListFailProc(userItem, fErrType);
    }
}

bool LSLiveChatSessionManager::GetLeftCreditProc(LSLCUserItem* userItem) {
    bool result = false;
    if (NULL != userItem)
    {
        long requestId = m_requestOtherController->GetLeftCredit();
        result = HTTPREQUEST_INVALIDREQUESTID != requestId;
        if (result) {
            m_inviteMsgMap.lock();
            m_inviteMsgMap.insert(map<long, LSLCUserItem*>::value_type(requestId, userItem));
            m_inviteMsgMap.unlock();
        }
    }
    return result;
}

// 直播http接口6.2.获取帐号余额
void LSLiveChatSessionManager::OnGetLeftCredit(long requestId, bool success, int errnum, const string& errmsg, double credit, int coupon) {
    FileLog("LiveChatManager", "LiveChatSessionManager::OnGetLeftCredit(credit:%f coupon:%d) begin", credit, coupon);
    bool isSuccess = success;
    LSLCUserItem* userItem = NULL;
    
    // 获取待发消息的userItem
    m_inviteMsgMap.lock();
    map<long, LSLCUserItem*>::iterator iter = m_inviteMsgMap.find(requestId);
    if (iter != m_inviteMsgMap.end()) {
        userItem = (*iter).second;
        m_inviteMsgMap.erase(iter);
    }
    m_inviteMsgMap.unlock();
    
    if (isSuccess) {
        // 判断点是不是大于聊天最少点
        if (credit >= m_operator->GetMinBalance() && NULL != userItem) {
            // 发送代发消息
            SendMessageList(userItem);
        }
        else{
            // 失败
            LSLIVECHAT_LCC_ERR_TYPE errType = LSLIVECHAT_LCC_ERR_NOMONEY;
            m_liveChatSender->SendMessageListFailProc(userItem, errType);
        }
    }
    // 连接失败
    else
    {
        HandleTokenOverErrCode(errnum, "", errmsg);
        LSLIVECHAT_LCC_ERR_TYPE fErrType = LSLIVECHAT_LCC_ERR_CONNECTFAIL;
        m_liveChatSender->SendMessageListFailProc(userItem, fErrType);
    }
}

void LSLiveChatSessionManager::SendMessageList(LSLCUserItem* userItem)
{
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = REQUEST_TASK_SendMessageList;
    requestItem->param = (TaskParam)userItem;
    m_operator->InsertRequestTask(this, (TaskParam)requestItem);
}

void LSLiveChatSessionManager::OnEndTalk(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {

}
