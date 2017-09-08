package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.RideItem;

public interface OnGetRidesListCallback {
	public void onGetRidesList(boolean isSuccess, int errCode, String errMsg, RideItem[] rideList);
}
