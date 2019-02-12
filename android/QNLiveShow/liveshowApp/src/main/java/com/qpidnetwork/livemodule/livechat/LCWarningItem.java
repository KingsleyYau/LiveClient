package com.qpidnetwork.livemodule.livechat;

import java.io.Serializable;

/**
 * 警告消息item
 * @author Samson Fan
 *
 */
public class LCWarningItem implements Serializable{

	private static final long serialVersionUID = -1106102998709445118L;
	/**
	 * 消息内容
	 */
	public String message;
	/**
	 * 链接 item 
	 */
	public LCWarningLinkItem linkItem;
	
	public LCWarningItem() {
		message = "";
		linkItem = null;
	}
	
	public void init(String message) {
		this.message = message;
		linkItem = null;
	}
	
	public void initWithLinkMsg(String message, LCWarningLinkItem linkItem) {
		this.message = message;
		this.linkItem = linkItem;
	}
}
