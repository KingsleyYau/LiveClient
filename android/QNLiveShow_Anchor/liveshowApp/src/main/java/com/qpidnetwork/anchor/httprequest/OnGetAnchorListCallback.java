package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.AnchorInfoItem;

/**
 * 获取观众列表回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetAnchorListCallback {

	public void onGetAnchorList(boolean isSuccess, int errCode, String errMsg, AnchorInfoItem[] anchorList);
}
