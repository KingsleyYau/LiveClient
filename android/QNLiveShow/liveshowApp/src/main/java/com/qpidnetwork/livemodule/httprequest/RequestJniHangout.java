package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorListType;

/**
 * 8. 多人互动接口
 * @author Hunter Mun
 * @since 2017-6-8
 */
public class RequestJniHangout {

	/**
	 * 8.1. 获取可邀请多人互动的主播列表
	 * @param callback
	 * @return
	 */
	static  public  long GetCanHangoutAnchorList(HangoutAnchorListType type, String anchorId, int start, int step, OnGetCanHangoutAnchorListCallback callback) {
		return  GetCanHangoutAnchorList(type.ordinal(), anchorId, start, step, callback);
	}
	static private native long GetCanHangoutAnchorList(int type, String anchorId, int start, int step, OnGetCanHangoutAnchorListCallback callback);

	/**
	 * 8.2.发起多人互动邀请
     * @param roomId            当前发起的直播间ID
     * @param anchorId          主播ID
     * @param recommendId       推荐ID（可无，无则表示不是因推荐导致观众发起邀请）
	 * @param callback
	 * @return
	 */
	static public native long SendInvitationHangout(String roomId, String anchorId, String recommendId, OnSendInvitationHangoutCallback callback);

	/**
	 * 8.3.取消多人互动邀请
	 * @param inviteId      邀请ID
	 * @param callback
	 * @return
	 */
	static public native long CancelHangoutInvit(String inviteId, OnRequestCallback callback);

	/**
	 * 8.4.获取多人互动邀请状态
	 * @param inviteId     邀请ID
	 * @param callback
	 * @return
	 */
	static public native long GetHangoutInvitStatus(String inviteId, OnGetHangoutInvitStatusCallback callback);


	/**
	 * 8.5.同意主播敲门请求
     * @param knockId       敲门ID
     * @param callback
	 * @return
	 */
	static public native long DealKnockRequest(String knockId, OnRequestCallback callback);

	/**
	 * 8.6.获取多人互动直播间可发送的礼物列表
	 * @param roomId       直播间ID
	 * @param callback
	 * @return
	 */
	static public native long GetHangoutGiftList(String roomId, OnGetHangoutGiftListCallback callback);


}
