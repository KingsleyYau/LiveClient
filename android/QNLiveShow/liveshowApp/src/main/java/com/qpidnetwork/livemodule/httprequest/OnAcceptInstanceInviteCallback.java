package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HttpAuthorityItem;

public interface OnAcceptInstanceInviteCallback {
	public void onAcceptInstanceInvite(boolean isSuccess, int errCode, String errMsg, String roomId, int roomType, HttpAuthorityItem priv);
}
