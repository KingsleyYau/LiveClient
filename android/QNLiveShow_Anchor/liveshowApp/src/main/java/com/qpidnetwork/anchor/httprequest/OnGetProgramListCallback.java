package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.ProgramInfoItem;

/**
 * 7.1.获取节目列表回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetProgramListCallback {

	/**
	 * 7.1.获取节目列表回调
	 * @param  list 节目列表
	 *
	 */
	public void onGetProgramList (boolean isSuccess, int errCode, String errMsg, ProgramInfoItem[] list);
}
