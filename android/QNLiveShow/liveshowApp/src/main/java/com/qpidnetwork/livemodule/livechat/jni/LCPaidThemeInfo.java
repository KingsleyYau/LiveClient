package com.qpidnetwork.livemodule.livechat.jni;

import java.io.Serializable;

public class LCPaidThemeInfo implements Serializable{

	private static final long serialVersionUID = -8839686738246569126L;
	
	public LCPaidThemeInfo() {
		
	}
	
	/**
	 * 已购买主题附加信息
	 * @param themeId 主题Id
	 * @param manId   主题购买男士
	 * @param womanId 主题应用女士
	 * @param startTime 主题有效时间开始时间
	 * @param endTime   主题有效时间结束时间
	 * @param now       服务器当前时间（本地时间同步）
	 * @param updateTime 购买或最后应用时间，最大为当前正在应的主题
	 */
	public LCPaidThemeInfo(String themeId
			, String manId
			, String womanId
			, int startTime
			, int endTime
			, int now
			, int updateTime){
		int currentTime = (int)(System.currentTimeMillis()/1000);
		this.themeId = themeId;
		this.manId = manId;
		this.womanId = womanId;
		this.startTime = startTime + currentTime - now;//时间同步
		this.endTime = endTime + currentTime - now;
		this.now = now;
		this.updateTime = updateTime;
	}
	
	
	public String themeId;
	public String manId;
	public String womanId;
	public int startTime;
	public int endTime;
	public int now;
	public int updateTime;
}
