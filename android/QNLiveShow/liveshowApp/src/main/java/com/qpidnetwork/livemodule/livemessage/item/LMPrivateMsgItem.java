package com.qpidnetwork.livemodule.livemessage.item;


import java.io.Serializable;

public class LMPrivateMsgItem {


	public LMPrivateMsgItem(){

	}
	/**
	 * 直播消息中的私信消息
	 * @author Hunter Mun
	 *
	 * @param message 私信的内容
	 */
	public LMPrivateMsgItem(
							String message
			){
		this.message = message;
	}

	public String message;

	@Override
	public String toString() {
		return "LMPrivateMsgItem[message:"+message
				+ "]";
	}

}
