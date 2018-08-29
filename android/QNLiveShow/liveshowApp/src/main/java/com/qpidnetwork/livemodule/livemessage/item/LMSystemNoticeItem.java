package com.qpidnetwork.livemodule.livemessage.item;


public class LMSystemNoticeItem {

	/**
	 * 系统消息类型
	 */
	public enum LMSystemType {
		Unknow,		// 未知类型
		NoMuchMore	// 没有更多了

	}

	public LMSystemNoticeItem(){

	}
	/**
	 * 直播消息中的私信消息
	 * @author Hunter Mun
	 *
	 * @param message 私信的内容
	 */
	public LMSystemNoticeItem(
							String message,
							int systemType
			){
		this.message = message;
		if( systemType < 0 || systemType >= LMSystemType.values().length ) {
			this.systemType = LMSystemType.Unknow;
		} else {
			this.systemType = LMSystemType.values()[systemType];
		}
	}

	public String message;
	public LMSystemType systemType;

	@Override
	public String toString() {
		return "LMSystemNoticeItem[message:"+message
				+ " systemType:" + systemType + "]";
	}

}
