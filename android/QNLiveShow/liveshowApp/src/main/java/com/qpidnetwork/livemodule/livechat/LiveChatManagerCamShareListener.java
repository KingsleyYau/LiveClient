package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareLadyInviteType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;

/**
 * LiveChat管理回调接口类(CamShare相关)
 * @author Hunter
 * @since 2016.11.1
 */
public interface LiveChatManagerCamShareListener {
	
	/**
	 * 发送CamShare邀请回调
	 * @param errType
	 * @param errmsg
	 * @param userId
	 */
	public void OnSendCamShareInvite(LiveChatErrType errType, String errmsg, String userId);
	
	/**
	 * 付费开始CamShare回调
	 * @param errType
	 * @param errmsg
	 * @param userId
	 * @param inviteId
	 */
	public void OnApplyCamShare(LiveChatErrType errType, String errmsg, String userId, String inviteId);
	
	/**
	 * CamShare邀请确认回调
	 * @param fromId
	 * @param toId
	 * @param isCam
	 */
	public void OnRecvAcceptCamInvite(String fromId, String toId, CamshareLadyInviteType inviteType, int sessionId, String fromName, boolean isCam);
	
	/**
	 * 心跳包异常推送
	 * @param errMsg
	 * @param errType
	 * @param targetId
	 */
	public void OnRecvCamHearbeatException(String errMsg, LiveChatErrType errType, String targetId);
	
	/**
	 * 使用Camshare试聊券回调
	 * @param errType
	 * @param errmsg
	 * @param userId
	 * @param ticketId
	 * @param inviteId
	 */
	public void OnCamshareUseTryTicket(LiveChatErrType errType, String errmsg, String userId, String ticketId, String inviteId);
	
}
