package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;

public interface OnGetAudienceDetailInfoCallback {
	public void onGetAudienceDetailInfo(boolean isSuccess, int errCode, String errMsg, AudienceInfoItem audienceInfo);
}
