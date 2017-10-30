package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.ValidLiveRoomItem;
import com.qpidnetwork.livemodule.httprequest.item.ImmediateInviteItem;

public interface OnGetLivingRoomAndInvitesCallback {
	public void onGetLivingRoomAndInvites(boolean isSuccess, int errCode, String errMsg, ValidLiveRoomItem[] roomList, ImmediateInviteItem[] inviteList);
}
