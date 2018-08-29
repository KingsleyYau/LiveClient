package com.qpidnetwork.livemodule.livemessage.item;


public class LMTimeMsgItem {


	public LMTimeMsgItem(){

	}
	/**
	 * 直播消息中的时间类型私信消息
	 * @author Hunter Mun
	 *
	 * @param msgTime  时间类型的消息时间
	 */
	public LMTimeMsgItem(
			int msgTime
			){
		this.msgTime = msgTime;
	}

	public int msgTime;

	@Override
	public String toString() {
		return "LMTimeMsgItem[msgTime: "+msgTime
				+ "]";
	}

}
