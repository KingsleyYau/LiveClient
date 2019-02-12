package com.qpidnetwork.livemodule.livechat;

import java.io.Serializable;

/**
 * 警告消息的link item
 * @author Samson Fan
 *
 */
public class LCWarningLinkItem implements Serializable{

	private static final long serialVersionUID = -3775729690194367293L;
	/**
	 * 链接文字内容
	 */
	public String linkMsg;
	/**
	 * 链接操作类型
	 */
	public LinkOptType linkOptType;
	
	/**
	 * 链接操作类型
	 */
	public enum LinkOptType {
		/**
		 * 默认/未知
		 */
		Unknow,
		/**
		 * 充值
		 */
		Rechange,
	}
	
	public LCWarningLinkItem() {
		linkMsg = "";
		linkOptType = LinkOptType.Unknow;
	}
	
	public void init(String linkMsg, LinkOptType linkOptType) {
		this.linkMsg = linkMsg;
		this.linkOptType = linkOptType;
	}
}
