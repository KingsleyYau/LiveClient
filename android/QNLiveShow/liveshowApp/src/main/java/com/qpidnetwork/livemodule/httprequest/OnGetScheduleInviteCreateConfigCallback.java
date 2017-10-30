package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteConfig;


public interface OnGetScheduleInviteCreateConfigCallback {
	public void onGetScheduleInviteCreateConfig(boolean isSuccess, int errCode, String errMsg, ScheduleInviteConfig scheduleInviteConfig);
}
