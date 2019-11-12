package com.qpidnetwork.anchor.im;

import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMClientListener.InviteReplyType;
import com.qpidnetwork.anchor.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.anchor.im.listener.IMInviteListItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMSendInviteInfoItem;

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
	 * 3.11. 主播切换推流
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	void OnAnchorSwitchFlow(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String[] pushUrl, IMClientListener.IMDeviceType deviceType);

	/**
	 * 9.1.观众立即私密邀请
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
    void OnSendImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMSendInviteInfoItem inviteInfoItem);

	/**
	 * 9.2.接收立即私密邀请回复通知
	 * @param inviteId
	 * @param replyType
	 * @param roomId
	 * @param roomType
	 * @param anchorId
	 * @param nickName
	 * @param avatarImg
	 */
    void OnRecvInviteReply(String inviteId, InviteReplyType replyType, String roomId, LiveRoomType roomType, String anchorId,
                           String nickName, String avatarImg);

	/**
	 *  9.5.获取指定立即私密邀请信息接口 回调
	 *
	 *  @param success          操作是否成功
	 *  @param reqId            请求序列号
	 *  @param errMsg           结果描述
	 *  @param inviteItem       立即私密邀请
	 *
	 */
	void OnGetInviteInfo(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem);
}
