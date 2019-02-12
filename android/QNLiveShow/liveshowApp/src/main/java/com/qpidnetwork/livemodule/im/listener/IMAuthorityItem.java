package com.qpidnetwork.livemodule.im.listener;


import com.qpidnetwork.livemodule.httprequest.item.HttpAuthorityItem;

import java.io.Serializable;

public class IMAuthorityItem implements Serializable {

	private static final long serialVersionUID = 575769754336546270L;

	public IMAuthorityItem(){

	}

	/**
	 * @param isHasOneOnOneAuth
	 * @param isHasBookingAuth
	 */
	public IMAuthorityItem(
						   boolean isHasOneOnOneAuth,
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
		StringBuilder sb = new StringBuilder("IMAuthorityItem[");
		sb.append("isHasOneOnOneAuth:");
		sb.append(isHasOneOnOneAuth);
		sb.append(" isHasBookingAuth:");
		sb.append(isHasBookingAuth);
		sb.append("]");
		return sb.toString();
	}

	public void HttpAuthorityItem2IMAuthorityItem (HttpAuthorityItem httpAuthorityItem){
		isHasOneOnOneAuth = httpAuthorityItem.isHasOneOnOneAuth;
		isHasBookingAuth = httpAuthorityItem.isHasBookingAuth;
	}
}
