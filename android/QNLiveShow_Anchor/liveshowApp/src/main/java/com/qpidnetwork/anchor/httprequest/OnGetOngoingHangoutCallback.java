package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.AnchorHangoutItem;

/**
 * 6.4.获取未结束的多人互动直播间列表回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetOngoingHangoutCallback {

	public void onGetOngoingHangout(boolean isSuccess, int errCode, String errMsg, AnchorHangoutItem[] anchorList);
}
