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
	 * @param showDetailPage        // 节目详情页URL
	 * @param showDescription       // 节目介绍
	 * @param hangoutCreditMsg      // 多人互动资费提示
	 * @param loiH5Url              // 意向信页URL
	 * @param emfH5Url              // EMF页URL
	 * @param pmStartNotice         // 私信聊天界面没有聊天记录时的提示（New）
	 * @param httpSvrMobileUrl      // http mobile服务器的URL（包括mobile.charmlive.com或demo-mobile.charmlive.com）
	 * @param sendLetter            // 发送信件页URL
	 */
	public ConfigItem(String imServerUrl,
                      String httpServerUrl,
                      String addCreditsUrl,
                      String anchorPage,
                      String userLevel,
                      String intimacy,
                      String userProtocol,
                      String showDetailPage,
                      String showDescription,
                      String hangoutCreditMsg,
                      String loiH5Url,
                      String emfH5Url,
                      String pmStartNotice,
                      String postStampUrl,
                      String httpSvrMobileUrl,
					  String host,
					  String hostDomain,
					  int port,
					  double minChat,
					  String chatVoiceHostUrl,
					  String sendLetter){
		this.imServerUrl = imServerUrl;
		this.httpServerUrl = httpServerUrl;
		this.addCreditsUrl = addCreditsUrl;
		this.anchorPage = anchorPage;
		this.userLevel = userLevel;
		this.intimacy = intimacy;
		this.userProtocol = userProtocol;
		this.showDetailPage = showDetailPage;
		this.showDescription = showDescription;
		this.hangoutCreditMsg = hangoutCreditMsg;
		this.loiH5Url = loiH5Url;
		this.emfH5Url = emfH5Url;
		this.pmStartNotice = pmStartNotice;
		this.postStampUrl = postStampUrl;
		this.httpSvrMobileUrl = httpSvrMobileUrl;
		this.host = host;
		this.hostDomain = hostDomain;
		this.port = port;
		this.minChat = minChat;
		this.chatVoiceHostUrl = chatVoiceHostUrl;
		this.sendLetter = sendLetter;
	}
	
	public String imServerUrl;
	public String httpServerUrl;
	public String addCreditsUrl;
	public String anchorPage;
	public String userLevel;
	public String intimacy;
	public String userProtocol;

	public String showDetailPage;
	public String showDescription;
	public String hangoutCreditMsg;
	public String loiH5Url;
	public String emfH5Url;
	public String pmStartNotice;
	public String postStampUrl;
	public String httpSvrMobileUrl;

	//LiveChat相关
	public String host;
	public String hostDomain;
	public int port;
	public double minChat;
	public String chatVoiceHostUrl;

	//屏蔽功能兼容问题
	public String camShareHost = "";

	// 发送信件页URL
	public String sendLetter;
}
