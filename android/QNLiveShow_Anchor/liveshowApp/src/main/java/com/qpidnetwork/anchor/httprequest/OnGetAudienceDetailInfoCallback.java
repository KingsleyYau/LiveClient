package com.qpidnetwork.anchor.httprequest;


import com.qpidnetwork.anchor.httprequest.item.AudienceBaseInfoItem;

public interface OnGetAudienceDetailInfoCallback {
	public void onGetAudienceDetailInfo(boolean isSuccess, int errCode, String errMsg, AudienceBaseInfoItem audienceInfo);
}
