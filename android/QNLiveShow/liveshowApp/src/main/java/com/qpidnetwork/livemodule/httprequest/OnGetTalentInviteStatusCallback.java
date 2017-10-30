package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.TalentInviteItem;

public interface OnGetTalentInviteStatusCallback {
	public void onGetTalentInviteStatus(boolean isSuccess, int errCode, String errMsg, TalentInviteItem inviteItem);
}
