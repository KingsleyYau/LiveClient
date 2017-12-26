package com.qpidnetwork.livemodule.httprequest.item;

public class ConfigItem {
	
	public ConfigItem(){
		
	}
	
	/**
	 * 同步配置bean
	 * @param imServerUrl			//IM服务器ip或域名
	 * @param httpServerUrl			//http服务器ip或域名
	 * @param addCreditsUrl			//充值页面URL
	 * @param anchorPage			// 主播资料页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
	 * @param userLevel 			// 观众登记页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
	 * @param intimacy				// 观众与主播亲密度页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
	 * @param userProtocol          // 观众协议页URL
	 */
	public ConfigItem(String imServerUrl,
						String httpServerUrl,
						String addCreditsUrl,
						String anchorPage,
						String userLevel,
						String intimacy,
					    String userProtocol){
		this.imServerUrl = imServerUrl;
		this.httpServerUrl = httpServerUrl;
		this.addCreditsUrl = addCreditsUrl;
		this.anchorPage = anchorPage;
		this.userLevel = userLevel;
		this.intimacy = intimacy;
		this.userProtocol = userProtocol;
	}
	
	public String imServerUrl;
	public String httpServerUrl;
	public String addCreditsUrl;
	public String anchorPage;
	public String userLevel;
	public String intimacy;
	public String userProtocol;
}
