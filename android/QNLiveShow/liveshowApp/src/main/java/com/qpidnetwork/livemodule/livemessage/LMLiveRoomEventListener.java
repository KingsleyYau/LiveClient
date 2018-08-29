package com.qpidnetwork.livemodule.livemessage;

import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.livemessage.item.LMClientListener;
import com.qpidnetwork.livemodule.livemessage.item.LMPrivateMsgContactItem;
import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;


/**
 * 直播间仅有相关事件
 * @author Hunter Mun
 * @since 2018.8.21
 */
public interface LMLiveRoomEventListener {

    void OnUpdateFriendListNotice(boolean success, HttpLccErrType errType, String errMsg);
//
//    void OnGetFollowPrivateMsgFriendList(boolean success, HttpLccErrType errType, String errMsg, LMPrivateMsgContactItem[] contactList);

    void OnRefreshPrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId);

    void OnGetMorePrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId, boolean isMuchMore);

    void OnUpdatePrivateMsgWithUserId(String userId, LiveMessageItem[] messageList);

    void OnSendPrivateMessage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String userId, LiveMessageItem messageItem);

    void OnRecvUnReadPrivateMsg(LiveMessageItem messageItem);

    // 重发通知（上层按了重发，c层删除所有时间item（android不好删除可能有时间item），把所有发送给上层）
    void OnRepeatSendPrivateMsgNotice(String userId, LiveMessageItem[] messageList);

}
