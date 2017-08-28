package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener.InviteReplyType;
import com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE;

/**
 * 直播邀请及启动相关回调
 * @author Hunter Mun
 * @since 2017.8.21
 */
public interface IMInviteLaunchEventListener {
	/**
	 * 3.1.观众进入直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param roomInfo
	 */
	public void OnRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo);
	
	/**
	 * 3.11.直播间开播通知
	 * @param roomId
	 * @param leftSeconds		开播前的倒数秒数
	 */
	public void OnRecvLiveStart(String roomId, int leftSeconds);
	
	/**
	 * 7.1.观众立即私密邀请
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param inviteId
	 */
	public void OnSendImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String inviteId);
	
	/**
	 * 7.2.观众取消立即私密邀请
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param roomId
	 */
	public void OnCancelImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String roomId);
	
	/**
	 * 7.3.接收立即私密邀请回复通知
	 * @param inviteId
	 * @param replyType
	 * @param roomId
	 */
	public void OnRecvInviteReply(String inviteId, InviteReplyType replyType, String roomId);
	
	
	/**
	 * 7.4.接收主播立即私密邀请通知
	 * @param anchorId
	 * @param anchorName
	 * @param anchorPhotoUrl
	 */
	public void OnRecvAnchoeInviteNotify(String anchorId, String anchorName, String anchorPhotoUrl);
	
	/**
	 * 7.5.接收主播预约私密邀请通知
	 * @param anchorId
	 * @param anchorName
	 * @param anchorPhotoUrl
	 * @param bookTime
	 * @param inviteId
	 */
	public void OnRecvScheduledInviteNotify(String anchorId, String anchorName, String anchorPhotoUrl, int bookTime, String inviteId);
}
