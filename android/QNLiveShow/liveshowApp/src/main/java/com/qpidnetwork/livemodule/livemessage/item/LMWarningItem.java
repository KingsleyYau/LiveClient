package com.qpidnetwork.livemodule.livemessage.item;


public class LMWarningItem {

	/**
	 * 私信警告类型
	 */
	public enum LMWarningType {
		Unknow,		// 未知类型
		NoCredit	// 点数不足警告

	}

	public LMWarningItem(){

	}
	/**
	 * 直播消息中的私信消息
	 * @author Hunter Mun
	 *
	 * @param warnType 私信的内容
	 */
	public LMWarningItem(
			int warnType
			){
		if( warnType < 0 || warnType >= LMWarningType.values().length ) {
			this.warnType = LMWarningType.Unknow;
		} else {
			this.warnType = LMWarningType.values()[warnType];
		}
	}

	public LMWarningType warnType;

	@Override
	public String toString() {
		return "LMWarningItem[warnType: "+warnType
				+ "]";
	}

}
