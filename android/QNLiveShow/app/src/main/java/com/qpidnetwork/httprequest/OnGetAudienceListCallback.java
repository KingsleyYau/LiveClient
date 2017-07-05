package com.qpidnetwork.httprequest;

import com.qpidnetwork.httprequest.item.AudienceInfoItem;

/**
 * 获取观众列表回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetAudienceListCallback {
	void onGetAudienceList(boolean isSuccess, int errCode, String errMsg, AudienceInfoItem[] audienceList);
}
