package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE;

/**
 * 系统性回调
 * @author Hunter Mun
 * @since 2017.8.21
 */
public interface IMOtherEventListener {
	
	/**
	 * 2.1.登录回调
	 * @param errType
	 * @param errMsg
	 */
	public void OnLogin(LCC_ERR_TYPE errType, String errMsg);
	
	
	/**
	 * 2.2.注销回调
	 * @param errType
	 * @param errMsg
	 */
	public void OnLogout(LCC_ERR_TYPE errType, String errMsg);
	
	/**
	 * 2.4.用户被挤掉线通知
	 */
	public void OnKickOff();
	
	/**
	 * 3.9.接收充值通知
	 * @param roomId
	 * @param message
	 * @param credit
	 */
	public void OnRecvLackOfCreditNotice(String roomId, String message, double credit);
	
	/**
	 * 3.10.接收定时扣费通知
	 * @param roomId
	 * @param credit
	 */
	public void OnRecvCreditNotice(String roomId, double credit);
	
}
