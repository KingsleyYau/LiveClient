package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.ContactItem;

public interface OnGetMyContactListCallback {
	public void onGetMyContactList(boolean isSuccess, int errCode, String errMsg, ContactItem[] contactList, int tatalCount);
}
