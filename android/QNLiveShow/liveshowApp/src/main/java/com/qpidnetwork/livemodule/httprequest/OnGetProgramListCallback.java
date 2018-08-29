package com.qpidnetwork.livemodule.httprequest;
import com.qpidnetwork.livemodule.httprequest.item.ProgramInfoItem;

/**
 * 获取节目列表回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetProgramListCallback {

	public void onGetProgramList(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem[] array);
}
