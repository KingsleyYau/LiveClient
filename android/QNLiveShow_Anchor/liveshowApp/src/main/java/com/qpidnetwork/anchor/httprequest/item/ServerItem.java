package com.qpidnetwork.anchor.httprequest.item;

public class ServerItem {
	public ServerItem(){
		
	}
	
	/**
	 * @param serId					//流媒体服务器ID
	 * @param tUrl					//流媒体服务器测速url
	 */
	public ServerItem(String serId,
					String tUrl){
		this.serId = serId;
		this.tUrl = tUrl;
	}
	
	public String serId;
	public String tUrl;

}
