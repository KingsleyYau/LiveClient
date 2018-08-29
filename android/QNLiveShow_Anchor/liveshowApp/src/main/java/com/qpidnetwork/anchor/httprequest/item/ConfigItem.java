package com.qpidnetwork.anchor.httprequest.item;

public class ConfigItem {
	
	public ConfigItem(){
		
	}
	
	/**
	 * 同步配置bean
	 * @param imServerUrl			//IM服务器ip或域名
	 * @param httpServerUrl			//http服务器ip或域名
	 * @param mePageUrl				//播个人中心页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
	 * @param manPageUrl			//男士资料页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
	 * @param minAavilableVer		//App最低可用的内部版本号（整型）
	 * @param minAvailableMsg		//App强制升级提示
	 * @param newestVer 			//App最新的内部版本号（整型）
	 * @param newestMsg				//App普通升级提示
	 * @param downloadAppUrl        //下载App的url
	 * @param svrList				//流媒体服务器列表
	 * @param showDetailPage		//节目详情页URL
	 */
	public ConfigItem(String imServerUrl,
						String httpServerUrl,
						String mePageUrl,
						String manPageUrl,
					    int minAavilableVer,
					    String minAvailableMsg,
					    int newestVer,
					    String newestMsg,
					    String downloadAppUrl,
					    ServerItem[] svrList,
					    String showDetailPage
					  ){
		this.imServerUrl = imServerUrl;
		this.httpServerUrl = httpServerUrl;
		this.mePageUrl = mePageUrl;
		this.manPageUrl = manPageUrl;
		this.minAavilableVer = minAavilableVer;
		this.minAvailableMsg = minAvailableMsg;
		this.newestVer = newestVer;
		this.newestMsg = newestMsg;
		this.downloadAppUrl = downloadAppUrl;
		this.svrList = svrList;
		this.showDetailPage = showDetailPage;
	}
	
	public String imServerUrl;
	public String httpServerUrl;
	public String mePageUrl;
	public String manPageUrl;
	public String showDetailPage;
	public int minAavilableVer;
	public String minAvailableMsg;
	public int newestVer;
	public String newestMsg;
	public String downloadAppUrl;
	public ServerItem[] svrList;
}
