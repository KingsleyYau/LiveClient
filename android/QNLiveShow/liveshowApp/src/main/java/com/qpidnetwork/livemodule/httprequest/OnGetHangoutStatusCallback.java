package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HangoutRoomStatusItem;

/**
 * 8.11.获取当前会员Hangout直播状态
 * @author Alex
 * @since 2018-4-18
 */
public interface OnGetHangoutStatusCallback {
	public void onGetHangoutStatus(boolean isSuccess, int errCode, String errMsg, HangoutRoomStatusItem[] list);
}
