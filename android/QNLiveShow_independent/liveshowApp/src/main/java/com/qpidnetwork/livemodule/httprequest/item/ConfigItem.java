package com.qpidnetwork.livemodule.httprequest.item;

public class ConfigItem {
	
	public ConfigItem(){
		
	}
	
	/**
	 * 同步配置bean
	 * @param imServerUrl			//IM服务器ip或域名
	 * @param httpServerUrl			//http服务器ip或域名
	 * @param addCreditsUrl			//充值页面URL
	 * @param anchorPage			//主播资料页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
	 * @param userLevel 			//观众登记页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
	 * @param intimacy				//观众与主播亲密度页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
	 * @param userProtocol          //观众协议页URL
	 * @param termsOfUse			//使用条款URL（仅独立）
	 * @param privacyPolicy			//私隐政策URL（仅独立）
	 * @param minAavilableVer		//App最低可用的内部版本号（整型）
	 * @param minAvailableMsg		//App强制升级提示
	 * @param newestVer 			//App最新的内部版本号（整型）
	 * @param newestMsg				//App普通升级提示
	 * @param downloadAppUrl        //下载App的url
	 * @param svrList				//流媒体服务器列表
	 */
	public ConfigItem(String imServerUrl,
						String httpServerUrl,
						String addCreditsUrl,
						String anchorPage,
						String userLevel,
						String intimacy,
					    String userProtocol,
					    String termsOfUse,
					    String privacyPolicy,
					    int minAavilableVer,
					    String minAvailableMsg,
					    int newestVer,
					    String newestMsg,
					    String downloadAppUrl,
					    ServerItem[] svrList
					  ){
		this.imServerUrl = imServerUrl;
		this.httpServerUrl = httpServerUrl;
		this.addCreditsUrl = addCreditsUrl;
		this.anchorPage = anchorPage;
		this.userLevel = userLevel;
		this.intimacy = intimacy;
		this.userProtocol = userProtocol;
		this.termsOfUse = termsOfUse;
		this.privacyPolicy = privacyPolicy;
		this.minAavilableVer = minAavilableVer;
		this.minAvailableMsg = minAvailableMsg;
		this.newestVer = newestVer;
		this.newestMsg = newestMsg;
		this.downloadAppUrl = downloadAppUrl;
		this.svrList = svrList;
	}
	
	public String imServerUrl;
	public String httpServerUrl;
	public String addCreditsUrl;
	public String anchorPage;
	public String userLevel;
	public String intimacy;
	public String userProtocol;
	public String termsOfUse;
	public String privacyPolicy;
	public int minAavilableVer;
	public String minAvailableMsg;
	public int newestVer;
	public String newestMsg;
	public String downloadAppUrl;
	public ServerItem[] svrList;
}
