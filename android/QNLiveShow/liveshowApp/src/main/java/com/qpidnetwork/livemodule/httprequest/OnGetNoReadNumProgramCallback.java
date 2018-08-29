package com.qpidnetwork.livemodule.httprequest;

/**
 * 获取节目列表未读回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetNoReadNumProgramCallback {
	/**
	 * 9.1.获取节目未读数(用于观众端向服务器获取节目未读数，已购或已关注的开播中节目数 + 退票未读数)
	 *
	 * @param num  未读数量
	 */
	public void onGetNoReadNumProgram(boolean isSuccess, int errCode, String errMsg, int num);
}
