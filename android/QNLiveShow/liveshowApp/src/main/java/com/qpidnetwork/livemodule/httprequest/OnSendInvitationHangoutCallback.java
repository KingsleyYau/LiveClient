package com.qpidnetwork.livemodule.httprequest;


public interface OnSendInvitationHangoutCallback {
	/**
	 * 8.2.发起多人互动邀请接口回调
	 * Created by Hunter Mun on 2018/5/7.
	 * @param roomId		多人互动直播间ID（可无，有则表示邀请成功且多人互动直播间已存在）
	 * @param inviteId		邀请ID（可无，若room_id不为空则无）
	 * @param expire		邀请有效的剩余秒数（整型）（可无，若invite_id不存在或为空则无）
	 */

	public void onSendInvitationHangout(boolean isSuccess, int errCode, String errMsg, String roomId, String inviteId, int expire);
}
