package com.qpidnetwork.livemodule.livechat;

import java.io.Serializable;

/**
 * 通知类消息item
 * @author Hunter
 * @since 2016.5.4
 */
public class LCNotifyItem implements Serializable{

	private static final long serialVersionUID = -2813674591853487011L;
	/**
	 * 通知类型
	 */
	public NotifyType notifyType;
	/**
	 * 通知附带数据抽象
	 */
	public Object data;
	
	public LCNotifyItem(){
		
	}
	
	public LCNotifyItem(NotifyType type, Object data){
		this.notifyType = type;
		this.data = data;
	}
	
	public enum NotifyType{
		Unknow,
		Theme_recommand,
		Theme_nomoney,
		Monthly_fee,
		Session_Pause
	}

}
