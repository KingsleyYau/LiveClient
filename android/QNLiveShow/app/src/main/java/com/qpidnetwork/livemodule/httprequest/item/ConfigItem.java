package com.qpidnetwork.livemodule.httprequest.item;

public class ConfigItem {
	
	public ConfigItem(){
		
	}
	
	/**
	 * 同步配置bean
	 * @param imServerUrl			//IM服务器ip或域名
	 * @param httpServerUrl			//http服务器ip或域名
	 * @param addCreditsUrl			//充值页面URL
	 */
	public ConfigItem(String imServerUrl,
						String httpServerUrl,
						String addCreditsUrl){
		this.imServerUrl = imServerUrl;
		this.httpServerUrl = httpServerUrl;
		this.addCreditsUrl = addCreditsUrl;
	}
	
	public String imServerUrl;
	public String httpServerUrl;
	public String addCreditsUrl;
}
