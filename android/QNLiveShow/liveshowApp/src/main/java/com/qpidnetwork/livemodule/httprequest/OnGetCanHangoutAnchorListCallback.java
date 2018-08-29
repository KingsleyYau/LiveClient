package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;

/**
 * 8.1.获取可邀请多人互动的主播列表
 * @author Hunter Mun
 * @since 2018-4-18
 */
public interface OnGetCanHangoutAnchorListCallback {
	public void onGetCanHangoutAnchorListCallback(boolean isSuccess, int errCode, String errMsg, HangoutAnchorInfoItem[] audienceList);
}
