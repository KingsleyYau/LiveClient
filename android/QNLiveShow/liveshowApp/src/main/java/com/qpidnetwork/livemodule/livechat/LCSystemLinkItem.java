package com.qpidnetwork.livemodule.livechat;

import java.io.Serializable;

/**
 * 系统消息的link item
 * @author Hunter
 * @since 2016.5.3
 */
public class LCSystemLinkItem implements Serializable{

	private static final long serialVersionUID = 6143205752200862425L;
	
	/**
	 * 链接文字内容
	 */
	public String linkMsg;
	/**
	 * 链接操作类型
	 */
	public SystemLinkOptType linkOptType;
	
	/**
	 * 链接操作类型
	 */
	public enum SystemLinkOptType {
		/**
		 * 默认/未知
		 */
		Unknow,
		/**
		 * 主题重新下载
		 */
		Theme_reload,
		/**
		 * 主题重新购买
		 */
		Theme_recharge
	}
	
	public LCSystemLinkItem() {
		linkMsg = "";
		linkOptType = SystemLinkOptType.Unknow;
	}
	
	public void init(String linkMsg, SystemLinkOptType linkOptType) {
		this.linkMsg = linkMsg;
		this.linkOptType = linkOptType;
	}

}
