package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.SetAutoPushType;
import com.qpidnetwork.anchor.httprequest.item.TalentReplyType;
import com.qpidnetwork.anchor.httprequest.item.HangoutInviteReplyType;

/**
 * 多人互动直播间相关接口
 * @author Hunter Mun
 * @since 2017-5-22
 */
public class RequestJniHangout {

	/**
	 * 6.1.获取可推荐的好友列表
	 * @param start		起始，用于分页，表示从第几个元素开始获取
	 * @param step		步长，用于分页，表示本次请求获取多少个元素
	 * @param callback
	 * @return
	 */
	static public native long GetCanRecommendFriendList(int start, int step, OnGetAnchorListCallback callback);


	/**
	 * 6.2.主播推荐好友给观众
	 * @param friendId			主播好友ID
	 * @param roomId			直播间ID
	 * @param callback
	 * @return
	 */
	static public native long RecommendFriendJoinHangout(String friendId, String roomId, OnRecommendFriendCallback callback);


	/**
	 * 6.3.主播回复多人互动邀请
	 * @param inviteId		多人互动邀请ID
	 * @param type			回复结果（AGREE：接受，REJECT：拒绝）
	 * @param callback
	 * @return
	 */
	static public long DealInvitationHangout(String inviteId, HangoutInviteReplyType type, OnDealInvitationHangoutCallback callback) {
		return DealInvitationHangout(inviteId, type.ordinal(), callback);
	}
	static protected native long DealInvitationHangout(String inviteId, int type, OnDealInvitationHangoutCallback callback);

	/**
	 * 6.4.获取未结束的多人互动直播间列表
	 * @param start		起始，用于分页，表示从第几个元素开始获取
	 * @param step		步长，用于分页，表示本次请求获取多少个元素
	 * @param callback
	 * @return
	 */
	static public native long GetOngoingHangoutList(int start, int step, OnGetOngoingHangoutCallback callback);

	/**
	 * 6.5. 发起敲门请求
	 * @param roomId			多人互动直播间ID
	 * @param callback
	 * @return
	 */
	static public native long SendKnockRequest(String roomId, OnSendKnockRequestCallback callback);

	/**
	 * 6.6.获取敲门状态
	 * @param knockId		敲门ID
	 * @param callback
	 * @return
	 */
	static public native long GetHangoutKnockStatus(String knockId, OnGetHangoutKnockStatusCallback callback);

	/**
	 * 6.7.取消敲门请求
	 * @param knockId		敲门ID
	 * @param callback
	 * @return
	 */
	static public native long CancelHangoutKnock(String knockId, OnRequestCallback callback);


	/**
	 * 6.8.获取多人互动直播间礼物列表
	 * @param roomId		多人互动直播间ID
	 * @param callback
	 * @return
	 */
	static public native long HangoutGiftList(String roomId, OnHangoutGiftListCallback callback);

	/**
	 * 6.9.请求添加好友
	 * @param userId		主播ID
	 * @param callback
	 * @return
	 */
	static public native long AddAnchorFriend(String userId, OnRequestCallback callback);

	/**
	 * 6.10.获取好友关系信息
	 * @param anchorId		主播ID
	 * @param callback
	 * @return
	 */
	static public native long GetHangoutFriendRelation(String anchorId, OnGetHangoutFriendRelationCallback callback);
	
}
