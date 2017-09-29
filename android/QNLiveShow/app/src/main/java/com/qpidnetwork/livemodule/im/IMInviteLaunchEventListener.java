package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.im.listener.IMInviteListItem;
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
    void OnRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo);

	/**
	 * 3.2.观众退出直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
    void OnRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);

	/**
	 * 3.11.直播间开播通知
	 * @param roomId
	 * @param leftSeconds		开播前的倒数秒数
	 */
    void OnRecvLiveStart(String roomId, int leftSeconds);

	/**
	 * 3.15.获取指定立即私密邀请信息接口
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param inviteItem
	 */
	void OnGetInviteInfo(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem);

	/**
	 * 7.1.观众立即私密邀请
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param invitationId
	 * @param timeout
	 * @param roomId
	 */
    void OnSendImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String invitationId, int timeout, String roomId);

	/**
	 * 7.2.观众取消立即私密邀请
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param roomId
	 */
    void OnCancelImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String roomId);

	/**
	 * 7.3.接收立即私密邀请回复通知
	 * @param inviteId
	 * @param replyType
	 * @param roomId
	 * @param roomType
	 * @param anchorId
	 * @param nickName
	 * @param avatarImg
	 * @param message
	 */
    void OnRecvInviteReply(String inviteId, InviteReplyType replyType, String roomId, LiveRoomType roomType, String anchorId,
                           String nickName, String avatarImg, String message);
}
