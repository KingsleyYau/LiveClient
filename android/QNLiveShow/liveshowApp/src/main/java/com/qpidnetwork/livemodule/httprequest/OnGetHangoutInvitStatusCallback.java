package com.qpidnetwork.livemodule.httprequest;

public interface OnGetHangoutInvitStatusCallback {
	/**
	 * 8.4.获取多人互动邀请状态接口回调
	 * Created by Hunter Mun on 2018/5/7.
	 * @param status		邀请状态（Penging：待确定，Accept：已接受，Reject：已拒绝，OutTime：已超时, Cancle: 观众取消邀, NoCredit: 余额不足, Busy: 主播繁忙）要转为HangoutInviteStatus
	 * @param roomId		多人互动直播间ID（可无，有则表示邀请成功且多人互动直播间已存在）
	 * @param expire		邀请有效的剩余秒数（整型）（可无，若invite_id不存在或为空则无）
	 */

	public void onGetHangoutInvitStatus(boolean isSuccess, int errCode, String errMsg, int status, String roomId, int expire);
}
