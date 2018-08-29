package com.qpidnetwork.anchor.httprequest;

/**
 * 主播回复多人互动邀请回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnDealInvitationHangoutCallback {

	/**
	 * 主播回复多人互动邀请回调
	 * @param roomId	多人互动直播间ID（可无，仅当type=同意存在）
	 * @author Hunter Mun
	 * @since 2017-5-22
	 */
	public void onDealInvitationHangout(boolean isSuccess, int errCode, String errMsg, String roomId);
}
