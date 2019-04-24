//
//  LSLiveChatSender.cpp
//  Common-C-Library
//
//  Created by Max on 2017/2/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#include "LSLiveChatSender.h"
#include "LSLiveChatEnumDefine.h"

LSLiveChatSender::LSLiveChatSender(
                                     ILSLiveChatManManagerOperator* pOperator,
                                     ILSLiveChatManManagerListener* pListener,
                                     ILSLiveChatClient* pClient,
                                     LSLCTextManager* pTextMgr,
                                     LSLCEmotionManager* pEmotionMgr,
                                     LSLCVoiceManager* pVoiceMgr,
                                     LSLCPhotoManager* pPhotoMgr,
                                     LSLCVideoManager* pVideoMgr,
                                     LSLCMagicIconManager* pMagicIconMgr,
                                     LSLCUserManager* pUserMgr,
                                     LSLCInviteManager* pInviteMgr,
                                     LSLiveChatHttpRequestManager* pHttpRequestManager
                                     ) {
    m_operator = pOperator;
    m_listener = pListener;
    m_client = pClient;
    
    m_textMgr = pTextMgr;
    m_emotionMgr = pEmotionMgr;
    m_voiceMgr = pVoiceMgr;
    m_photoMgr = pPhotoMgr;
    m_videoMgr = pVideoMgr;
    m_magicIconMgr = pMagicIconMgr;
    
    m_userMgr = pUserMgr;
    m_inviteMgr = pInviteMgr;
    
    m_requestController = new LSLiveChatRequestLiveChatController(pHttpRequestManager, this);
    m_requestOtherController = new LSLiveChatRequestOtherController(pHttpRequestManager, this);
    
    if( m_client ) {
        m_client->AddListener(this);
    }
}

LSLiveChatSender::~LSLiveChatSender() {
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

void LSLiveChatSender::SendMessageListProc(LSLCUserItem* userItem)
{
    if (NULL != userItem)
    {
        userItem->LockSendMsgList();
        userItem->m_tryingSend = false;
        for (LCMessageList::iterator iter = userItem->m_sendMsgList.begin();
             iter != userItem->m_sendMsgList.end();
             iter++)
        {
            // 发送消息item
            SendMessageItem((*iter));
        }
        userItem->m_sendMsgList.clear();
        userItem->UnlockSendMsgList();
    }
    else {
        FileLog("LSLiveChatSender", "SendMessageListProc() get user item fail");
    }
}

void LSLiveChatSender::SendMessageListFailProc(LSLCUserItem* userItem, LSLIVECHAT_LCC_ERR_TYPE errType)
{
    if (NULL != userItem) {
        userItem->LockSendMsgList();
        userItem->m_tryingSend = false;
        for (LCMessageList::iterator iter = userItem->m_sendMsgList.begin();
             iter != userItem->m_sendMsgList.end();
             iter++)
        {
            (*iter)->m_statusType = StatusType_Fail;
            (*iter)->m_procResult.SetResult(errType, "", "");
        }
        m_listener->OnSendMessageListFail(errType, userItem->m_sendMsgList);
        m_operator->BuildAndInsertWarningWithErrType(userItem->m_userId, errType);
        userItem->m_sendMsgList.clear();
        userItem->UnlockSendMsgList();
    }
    else {
        FileLog("LSLiveChatSender", "SendMessageListFailProc() get user item fail");
    }
}

void LSLiveChatSender::SendMessageItem(LSLCMessageItem* item)
{
    // 发送消息
    switch (item->m_msgType)
    {
        case MT_Text:
            SendTextMessageProc(item);
            break;
        case MT_Emotion:
            SendEmotionProc(item);
            break;
        case MT_Photo:
            SendPhotoProc(item);
            break;
        case MT_Voice:
            SendVoiceProc(item);
            break;
        case MT_MagicIcon:
            SendMagicIconProc(item);
            break;
        default:
            FileLog("LSLiveChatSender", "SendMessageList() msgType error, msgType:%s", item->m_msgType);
            break;
    }
}

void LSLiveChatSender::SendTextMessageProc(LSLCMessageItem* item)
{
    if (m_client->SendTextMessage(item->m_toId, item->GetTextItem()->m_message, item->GetTextItem()->m_illegal, item->m_msgId, item->m_inviteType))
    {
        m_textMgr->AddSendingItem(item);
    }
    else
    {
        item->m_statusType = StatusType_Fail;
        item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "", "");
        if (NULL != m_listener)
        {
            m_listener->OnSendTextMessage(item->m_procResult.m_errType, item->m_procResult.m_errMsg, item);
        }
    }
}

void LSLiveChatSender::OnSendTextMessage(const string& inUserId, const string& inMessage, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg)
{
    LSLCMessageItem* item = m_textMgr->GetAndRemoveSendingItem(inTicket);
    if (NULL != item) {
        // 修改在线状态
        m_operator->SetUserOnlineStatusWithLccErrType(item->GetUserItem(), err);
        
        // 处理消息
        item->m_statusType = (LSLIVECHAT_LCC_ERR_SUCCESS==err ? StatusType_Finish : StatusType_Fail);
        item->m_procResult.SetResult(err, "", errmsg);
        //发送消息成功，如果会话状态为默认状态或 女士主动邀请（在节目男士端修改了，为了可以点击取消邀请），修改为男士邀请状态
        OnSendMessageSessionProcess(item);
        if (NULL != m_listener) {
            m_listener->OnSendTextMessage(err, errmsg, item);
        }
    }
    else {
        FileLog("LiveChatManager", "OnSendTextMessage() get sending item fail, ticket:%d", inTicket);
    }
    
    // 生成警告消息
    if (LSLIVECHAT_LCC_ERR_SUCCESS != err) {
        m_operator->BuildAndInsertWarningWithErrType(inUserId, err);
    }
    
    FileLog("LiveChatManager", "OnSendTextMessage() err:%d, userId:%s, message:%s", err, inUserId.c_str(), inMessage.c_str());
}

void LSLiveChatSender::OnSendVGift(const string& inUserId, const string& inGiftId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg)
{
    
}

void LSLiveChatSender::SendEmotionProc(LSLCMessageItem* item)
{
    if (m_client->SendEmotion(item->m_toId, item->GetEmotionItem()->m_emotionId, item->m_msgId))
    {
        m_emotionMgr->AddSendingItem(item);
    }
    else {
        item->m_statusType = StatusType_Fail;
        item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "", "");
        m_listener->OnSendEmotion(item->m_procResult.m_errType, item->m_procResult.m_errMsg, item);
    }
}

void LSLiveChatSender::OnSendEmotion(const string& inUserId, const string& inEmotionId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg)
{
    LSLCMessageItem* item = m_emotionMgr->GetAndRemoveSendingItem(inTicket);
    if (NULL != item) {
        // 修改在线状态
        m_operator->SetUserOnlineStatusWithLccErrType(item->GetUserItem(), err);
        
        // 处理消息
        item->m_statusType = (err==LSLIVECHAT_LCC_ERR_SUCCESS ? StatusType_Finish : StatusType_Fail);
        item->m_procResult.SetResult(err, "", errmsg);
        //发送消息成功，如果会话状态为默认状态或 女士主动邀请（在节目男士端修改了，为了可以点击取消邀请），修改为男士邀请状态
        OnSendMessageSessionProcess(item);
        m_listener->OnSendEmotion(err, errmsg, item);
    }
    else {
        FileLog("LiveChatManager", "OnSendEmotion() get sending item fail, ticket:%d", inTicket);
    }
    
    // 生成警告消息
    if (err != LSLIVECHAT_LCC_ERR_SUCCESS) {
        m_operator->BuildAndInsertWarningWithErrType(inUserId, err);
    }
}

void LSLiveChatSender::SendPhotoProc(LSLCMessageItem* item)
{
    LSLCUserItem* userItem = item->GetUserItem();
    LSLCPhotoItem* photoItem = item->GetPhotoItem();

    if (photoItem->m_loadUrl.empty()) {
        // 没上传文件成功，请求上传文件
        long requestId = m_requestOtherController->UploadManPhoto(photoItem->m_srcFilePath);
        if (HTTPREQUEST_INVALIDREQUESTID != requestId) {
            // 请求成功
            item->m_statusType = StatusType_Processing;
            
            // 添加到请求表
            if (!m_photoMgr->AddRequestItem(requestId, item)) {
                FileLog("LSLiveChatSender", "SendPhotoProc() add request item fail, requestId:%d", requestId);
            }
        }
        else {
            item->m_statusType = StatusType_Fail;
            item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "", "");
            m_listener->OnSendPhoto(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
        }
    }
	else if (photoItem->m_photoId.empty() || photoItem->m_sendId.empty()) {
		// 没上传文件成功，请求上传文件
		long requestId = m_requestController->SendPhoto(userItem->m_userId, userItem->m_inviteId, m_operator->GetUserId(), m_operator->GetSid(), photoItem->m_loadUrl);
		if (HTTPREQUEST_INVALIDREQUESTID != requestId) {
			// 请求成功
			item->m_statusType = StatusType_Processing;
	        
			// 添加到请求表
			if (!m_photoMgr->AddRequestItem(requestId, item)) {
				FileLog("LSLiveChatSender", "SendPhotoProc() add request item fail, requestId:%d", requestId);
			}
		}
		else {
			item->m_statusType = StatusType_Fail;
			item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "", "");
			m_listener->OnSendPhoto(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
		}
	}
	else {
		// 上传文件成功，仅发送LiveChat消息
		SendPhotoLiveChatMsgProc(item);
	}
}

void LSLiveChatSender::OnUploadManPhoto(long requestId, bool success, int errnum, const string& errmsg, const string& url, const string& md5)
{
    LSLCMessageItem* msgItem = m_photoMgr->GetAndRemoveRequestItem(requestId);
    if (NULL == msgItem) {
        FileLog("LSLiveChatSender", "OnUploadManPhoto() get request item fail, requestId:%d", requestId);
        return;
    }
    
    if (success) {
        // 发送请求成功
        LSLCPhotoItem* photoItem = msgItem->GetPhotoItem();
        photoItem->m_loadUrl = url;
//        // 更新PhotoItem
//        photoItem = m_photoMgr->UpdatePhotoItem(photoItem, msgItem);
//        
//        // 把源文件copy到LiveChat目录下
//        m_photoMgr->CopyPhotoFileToDir(photoItem, photoItem->m_srcFilePath);
        
        // 发送图片HTTP消息
        m_operator->OnUploadPhoto(msgItem);
    }
    else {
        // 上传文件不成功
        msgItem->m_statusType = StatusType_Fail;
        msgItem->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "", errmsg);
        // 判断是否时token过期
        HandleTokenOverWithErrCode(errnum, "", errmsg);

        m_listener->OnSendPhoto(msgItem->m_procResult.m_errType, msgItem->m_procResult.m_errNum, msgItem->m_procResult.m_errMsg, msgItem);
    }
}

void LSLiveChatSender::OnSendPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCLCSendPhotoItem& item)
{
    LSLCMessageItem* msgItem = m_photoMgr->GetAndRemoveRequestItem(requestId);
    if (NULL == msgItem) {
        FileLog("LSLiveChatSender", "OnSendPhoto() get request item fail, requestId:%d", requestId);
        return;
    }
    
    if (success) {
        // 发送请求成功
        LSLCPhotoItem* photoItem = msgItem->GetPhotoItem();
        photoItem->m_photoId = item.photoId;
        photoItem->m_sendId = item.sendId;
        // 更新PhotoItem
        photoItem = m_photoMgr->UpdatePhotoItem(photoItem, msgItem);
        
        // 把源文件copy到LiveChat目录下
        m_photoMgr->CopyPhotoFileToDir(photoItem, photoItem->m_srcFilePath);
        
		// 发送图片LiveChat消息
		SendPhotoLiveChatMsgProc(msgItem);
    }
    else {
        // 上传文件不成功
        msgItem->m_statusType = StatusType_Fail;
        msgItem->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, errnum, errmsg);
        // 判断是否时余额不足
        HandleNotSufficientFunds(errnum, msgItem->m_toId);
        // 判断是否时token过期
        HandleTokenOverWithErrCode(0, errnum, errmsg);
        m_listener->OnSendPhoto(msgItem->m_procResult.m_errType, msgItem->m_procResult.m_errNum, msgItem->m_procResult.m_errMsg, msgItem);
    }
}

// 发送图片消息（仅LiveChat消息）
void LSLiveChatSender::SendPhotoLiveChatMsgProc(LSLCMessageItem* msgItem)
{
    if (m_client->SendPhoto(msgItem->m_toId
                            , msgItem->GetUserItem()->m_inviteId
                            , msgItem->GetPhotoItem()->m_photoId
                            , msgItem->GetPhotoItem()->m_sendId
                            , false
                            , msgItem->GetPhotoItem() ->m_photoDesc
                            , msgItem->m_msgId))
    {
        // 添加到发送map
        m_photoMgr->AddSendingItem(msgItem);
    }
    else {
        // LiveChatClient发送不成功
        msgItem->m_statusType = StatusType_Fail;
        msgItem->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "", "");
        m_listener->OnSendPhoto(msgItem->m_procResult.m_errType, msgItem->m_procResult.m_errNum, msgItem->m_procResult.m_errMsg, msgItem);
    }
}

// 发送消息成功后，更新会话状态(包括文字，表情，图片)，功能：为了endtalk的取消，判断是否时男士自动邀请
void LSLiveChatSender::OnSendMessageSessionProcess(LSLCMessageItem* item) {
    //发送消息成功，如果会话状态为默认状态或 女士主动邀请（在节目男士端修改了，为了可以点击取消邀请），修改为男士邀请状态
    if (item != NULL) {
        LSLCUserItem* userItem = item->GetUserItem();
        if (userItem != NULL) {
            if (userItem->m_chatType == LC_CHATTYPE_OTHER || userItem->m_chatType == LC_CHATTYPE_INVITE) {
                userItem->m_chatType = LC_CHATTYPE_MANINVITE;
            }
        }
    }
}

void LSLiveChatSender::HandleTokenOverWithErrCode(int errNum, const string& errNo, const string& errmsg) {
    if (IsTokenOverWithString(errNo) || IsTokenOverWithInt(errNum)) {
        m_listener->OnTokenOverTimeHandler(LIVECHATERRCODE_TOKEN_OVER, errmsg);
    }
}

void LSLiveChatSender::HandleNotSufficientFunds(const string& errNo, const string& userId) {
    if (IsNotSufficientFundsWithErrCode(errNo)) {
        m_operator->BuildAndInsertWarningWithErrType(userId, LSLIVECHAT_LCC_ERR_NOMONEY);
    }
}

void LSLiveChatSender::OnSendPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket)
{
    LSLCMessageItem* item = m_photoMgr->GetAndRemoveSendingItem(ticket);
    if (NULL != item) {
        // 修改在线状态
        m_operator->SetUserOnlineStatusWithLccErrType(item->GetUserItem(), err);
        
        // 处理消息
		if (err != LSLIVECHAT_LCC_ERR_CONNECTFAIL) {
			// 非服务器断开连接
			item->m_statusType = (err==LSLIVECHAT_LCC_ERR_SUCCESS ? StatusType_Finish : StatusType_Fail);
			item->m_procResult.SetResult(err, "", errmsg);
            //发送消息成功，如果会话状态为默认状态 或 女士主动邀请（在节目男士端修改了，为了可以点击取消邀请），修改为男士邀请状态
            OnSendMessageSessionProcess(item);
			m_listener->OnSendPhoto(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
		}
		else {
			// 服务器断开连接，插入待发送队列
			LSLCUserItem* userItem = item->GetUserItem();
			userItem->InsertSendMsgList(item);
		}
    }
    else {
        FileLog("LSLiveChatSender", "OnSendPhoto() get sending item fail, ticket:%d", ticket);
    }
    
    // 生成警告消息
    if (err != LSLIVECHAT_LCC_ERR_SUCCESS) {
        if (NULL != item && NULL != item->GetUserItem()) {
            m_operator->BuildAndInsertWarningWithErrType(item->GetUserItem()->m_userId, err);
        }
    }
}

void LSLiveChatSender::SendVoiceProc(LSLCMessageItem* item)
{
    if (m_client->GetVoiceCode(item->m_toId, item->m_msgId))
    {
        m_voiceMgr->AddSendingItem(item->m_msgId, item);
    }
    else {
        item->m_statusType = StatusType_Fail;
        item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "", "");
        m_listener->OnSendVoice(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
    }
}

void LSLiveChatSender::OnSendVoice(const string& inUserId, const string& inVoiceId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg)
{
    LSLCMessageItem* item = m_voiceMgr->GetAndRemoveSendingItem(inTicket);
    if (NULL == item
        || item->m_msgType != MT_Voice
        || NULL == item->GetVoiceItem())
    {
        FileLog("LSLiveChatSender", "OnSendVoice() param fail.");
        m_listener->OnSendVoice(LSLIVECHAT_LCC_ERR_FAIL, "", "", item);
        return;
    }
    
    // 修改在线状态
    m_operator->SetUserOnlineStatusWithLccErrType(item->GetUserItem(), err);
    //发送消息成功，如果会话状态为默认状态或 女士主动邀请（在节目男士端修改了，为了可以点击取消邀请），修改为男士邀请状态
    OnSendMessageSessionProcess(item);
    
    // 发送成功
    if (err == LSLIVECHAT_LCC_ERR_SUCCESS) {
        m_voiceMgr->CopyVoiceFileToDir(item);
    }
    
    // 回调
    item->m_statusType = (LSLIVECHAT_LCC_ERR_SUCCESS==err ? StatusType_Finish : StatusType_Fail);
    item->m_procResult.SetResult(err, "", errmsg);
    m_listener->OnSendVoice(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
    
    // 生成警告消息
    if (err != LSLIVECHAT_LCC_ERR_SUCCESS) {
        m_operator->BuildAndInsertWarningWithErrType(inUserId, err);
    }
}

void LSLiveChatSender::OnGetVoiceCode(const string& inUserId, int ticket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& voiceCode)
{
    LSLCMessageItem* item = m_voiceMgr->GetAndRemoveSendingItem(ticket);
    if (err == LSLIVECHAT_LCC_ERR_SUCCESS) {
        if (NULL != item
            && item->m_msgType == MT_Voice
            && NULL != item->GetVoiceItem())
        {
            LSLCVoiceItem* voiceItem = item->GetVoiceItem();
            voiceItem->m_checkCode = voiceCode;
            LSLCUserItem* userItem = item->GetUserItem();
            
            // 请求上传语音文件
            long requestId = m_requestController->UploadVoice(
                                                              voiceItem->m_checkCode
                                                              , userItem->m_inviteId
                                                              , m_operator->GetUserId()
                                                              , true
                                                              , m_operator->GetUserId()
                                                              , (OTHER_SITE_TYPE)m_operator->GetSiteType()
                                                              , voiceItem->m_fileType
                                                              , voiceItem->m_timeLength
                                                              , voiceItem->m_filePath);
            if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
                // 添加item到请求map
                m_voiceMgr->AddRequestItem(requestId, item);
            }
            else {
                item->m_statusType = StatusType_Fail;
                item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "", "");
                m_listener->OnSendVoice(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
            }
        }
        else {
            FileLog("LSLiveChatSender", "OnGetVoiceCode() param fail.");
        }
    }
    else {
        item->m_statusType = StatusType_Fail;
        item->m_procResult.SetResult(err, "", errmsg);
        m_listener->OnSendVoice(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
    }
    
    // 生成警告消息
    if (err != LSLIVECHAT_LCC_ERR_SUCCESS) {
        m_operator->BuildAndInsertWarningWithErrType(inUserId, err);
    }
}

void LSLiveChatSender::OnUploadVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& voiceId)
{
    LSLCMessageItem* item = m_voiceMgr->GetAndRemoveRquestItem(requestId);
    LSLCVoiceItem* voiceItem = item->GetVoiceItem();
    if (NULL == voiceItem) {
        FileLog("LiveChatManager", "LiveChatManager::OnUploadVoice() param fail. voiceItem is NULL.");
        m_listener->OnSendVoice(LSLIVECHAT_LCC_ERR_FAIL, "", "", item);
    }
    
    if (success) {
        voiceItem->m_voiceId = voiceId;
        if (m_client->SendVoice(item->m_toId, voiceItem->m_voiceId, voiceItem->m_timeLength, item->m_msgId)) {
            m_voiceMgr->AddSendingItem(item->m_msgId, item);
        }
        else {
            m_listener->OnSendVoice(LSLIVECHAT_LCC_ERR_FAIL, "", "", item);
        }
    }
    else {
        item->m_statusType = StatusType_Fail;
        item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, errnum, errmsg);
        m_listener->OnSendVoice(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
        
        // 判断是否时token过期
        HandleTokenOverWithErrCode(0, errnum, errmsg);
    }
}


void LSLiveChatSender::SendMagicIconProc(LSLCMessageItem* item)
{
    if (m_client->SendMagicIcon(item->m_toId, item->GetMagicIconItem()->m_magicIconId, item->m_msgId)) {
        m_magicIconMgr->AddSendingItem(item);
    }
    else{
        item->m_statusType = StatusType_Fail;
        item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "", "");
        m_listener->OnSendMagicIcon(item->m_procResult.m_errType, item->m_procResult.m_errMsg, item);
    }
}

void LSLiveChatSender::OnSendMagicIcon(const string& inUserId, const string& inIconId, int inTicket, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg)
{
    FileLog("LSLiveChatSender", "OnSendMagicIcon() begin");
    LSLCMessageItem* item = m_magicIconMgr->GetAndRemoveSendingItem(inTicket);
    if (NULL != item) {
        // 修改在线状态
        m_operator->SetUserOnlineStatusWithLccErrType(item->GetUserItem(), err);
        
        //处理消息
        item->m_statusType = (err == LSLIVECHAT_LCC_ERR_SUCCESS ? StatusType_Finish : StatusType_Fail);
        item->m_procResult.SetResult(err, "", errmsg);
        //发送消息成功，如果会话状态为默认状态 或 女士主动邀请（在节目男士端修改了，为了可以点击取消邀请），修改为男士邀请状态
        OnSendMessageSessionProcess(item);
        m_listener->OnSendMagicIcon(err, errmsg, item);
    }
    else{
        FileLog("LSLiveChatSender", "OnSendMagicIcon() get sending item fail, ticket:%d", inTicket);
    }
    // 生成警告消息
    if (err != LSLIVECHAT_LCC_ERR_SUCCESS) {
        m_operator->BuildAndInsertWarningWithErrType(inUserId, err);
    }
}
