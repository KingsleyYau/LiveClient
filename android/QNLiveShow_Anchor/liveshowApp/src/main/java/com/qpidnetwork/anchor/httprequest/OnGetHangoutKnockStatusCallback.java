package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.AnchorKnockType;

/**
 * 6.5.发起敲门请求回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetHangoutKnockStatusCallback {

	/**
	 * 6.6.获取敲门状态回调
	 * @param roomId	多人互动直播间ID
	 * @param status	当前状态（1：待确认，2：已接受，3：已拒绝，4：已超时） 请转换为AnchorKnockType枚举
	 * @param expire	敲门请求的有效秒数（整型）（可无，若无或为0则表示可直接进入）
	 * @author Hunter Mun
	 * @since 2017-5-22
	 */
	public void onGetHangoutKnockStatus(boolean isSuccess, int errCode, String errMsg, String roomId, int status, int expire);
}