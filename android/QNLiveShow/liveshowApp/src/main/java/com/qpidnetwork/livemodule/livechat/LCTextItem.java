package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.LCMessageItem.SendType;

import java.io.Serializable;

/**
 * 文本消息item
 * @author Samson Fan
 *
 */
public class LCTextItem implements Serializable{

	private static final long serialVersionUID = 7392858016957384450L;
	/**
	 * 消息显示内容
	 */
	public String message;
	/**
	 * 保存消息原内容
	 */
	private String content = "";

	/**
	 * 内容是否合法
	 */
	public boolean illegal;
	
	public LCTextItem() {
		message = "";
		illegal = false;
	}
	
	public void init(String message, SendType sendType) {
		this.content = message;
		this.illegal = LCMessageFilter.isIllegalMessage(message);
		if (this.illegal && (sendType == SendType.Recv)) {
			this.message = LCMessageFilter.filterMessage(message);
		} 
		else {
			this.message = message;
		}
	}
}
