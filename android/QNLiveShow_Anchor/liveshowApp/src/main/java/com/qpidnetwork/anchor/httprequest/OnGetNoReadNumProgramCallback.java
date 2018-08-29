package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.AnchorInfoItem;

/**
 * 7.2.获取节目未读数回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetNoReadNumProgramCallback {

	/**
	 * 7.2.获取节目未读数回调（用于主播端向服务器获取节目未读数，包括节目未读数量<审核通过/取消> + 已开播数量）
	 * @param  Num  未读数量

	 */
	public void onGetNoReadNumProgram(boolean isSuccess, int errCode, String errMsg, int Num);
}
