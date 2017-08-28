package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.ImmediateInviteItem;

public interface OnGetImediateInviteInfoCallback {
	public void onGetImediateInviteInfo(boolean isSuccess, int errCode, String errMsg, ImmediateInviteItem inviteInfo);
}
