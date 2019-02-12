package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 主播信息Item
 * @author Hunter Mun
 *
 */
public class HttpAuthorityItem {

	public HttpAuthorityItem(){

	}

	/**
	 * @param isHasOneOnOneAuth
	 * @param isHasBookingAuth
	 */
	public HttpAuthorityItem(boolean isHasOneOnOneAuth,
							 boolean isHasBookingAuth){
		this.isHasOneOnOneAuth = isHasOneOnOneAuth;
		this.isHasBookingAuth = isHasBookingAuth;

	}

	/**
	 * 权限
	 * isHasOneOnOneAuth             私密直播开播权限
	 * isHasBookingAuth              预约私密直播开播权限
	 */
	public boolean isHasOneOnOneAuth = true;
	public boolean isHasBookingAuth = true;


	@Override
	public String toString() {
		return "HttpAuthorityItem[isHasOneOnOneAuth:"+isHasOneOnOneAuth
				+ " isHasBookingAuth:"+isHasBookingAuth
				+ "]";
	}
}
