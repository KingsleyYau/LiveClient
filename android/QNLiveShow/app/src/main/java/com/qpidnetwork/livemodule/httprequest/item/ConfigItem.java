package com.qpidnetwork.livemodule.httprequest.item;

public class ConfigItem {
	
	public ConfigItem(){
		
	}
	
	/**
	 * 同步配置bean
	 * @param imServerIp			//IM服务器ip或域名
	 * @param imServerPort			//IM服务器端口
	 * @param httpServerIp			//http服务器ip或域名
	 * @param httpServerPort		//http服务器端口
	 * @param uploadServerIp		//上传图片服务器ip或域名
	 * @param uploadServerPort		//上传图片服务器端口
	 * @param addCreditsUrl			//充值页面URL
	 */
	public ConfigItem(String imServerIp,
						int imServerPort,
						String httpServerIp,
						int httpServerPort,
						String uploadServerIp,
						int uploadServerPort,
						String addCreditsUrl){
		this.imServerIp = imServerIp;
		this.imServerPort = imServerPort;
		this.httpServerIp = httpServerIp;
		this.httpServerPort = httpServerPort;
		this.uploadServerIp = uploadServerIp;
		this.uploadServerPort = uploadServerPort;
		this.addCreditsUrl = addCreditsUrl;
	}
	
	public String imServerIp;
	public int imServerPort;
	public String httpServerIp;
	public int httpServerPort;
	public String uploadServerIp;
	public int uploadServerPort;
	public String addCreditsUrl;
}
