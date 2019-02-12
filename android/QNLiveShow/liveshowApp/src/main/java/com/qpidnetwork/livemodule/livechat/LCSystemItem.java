package com.qpidnetwork.livemodule.livechat;

import java.io.Serializable;

/**
 * 系统消息item
 * @author Samson Fan
 *
 */
public class LCSystemItem implements Serializable{

	private static final long serialVersionUID = 1606706562042191316L;
	/**
	 * 消息内容
	 */
	public String message;
	
	/**
	 * 链接 item 
	 */
	public LCSystemLinkItem linkItem;
	
	/**
	 * 操作相关的数据
	 */
	public Object data;
	
	
	public LCSystemItem() {
		message = "";
	}
	
	public void init(String message) {
		this.message = message;
		linkItem = null;
	}
	
	public void initWithLinkMsg(String message, LCSystemLinkItem linkItem, Object data) {
		this.message = message;
		this.linkItem = linkItem;
		this.data = data;
	}
}
