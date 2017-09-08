package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;

public interface OnGetTalentListCallback {
	public void onGetTalentList(boolean isSuccess, int errCode, String errMsg, TalentInfoItem[] talentList);
}
