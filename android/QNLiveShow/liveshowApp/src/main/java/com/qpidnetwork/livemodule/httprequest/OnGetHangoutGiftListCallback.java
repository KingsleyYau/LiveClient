package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HangoutGiftListItem;

/**
 * 8.6.获取多人互动直播间可发送的礼物列表回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetHangoutGiftListCallback {

	/**
	 * 8.6.获取多人互动直播间可发送的礼物列表回调
	 * @author Hunter Mun
	 * @param  item  	可发送的礼物列表
	 */
	public void onGetHangoutGiftList(boolean isSuccess, int errCode, String errMsg, HangoutGiftListItem item);
}
