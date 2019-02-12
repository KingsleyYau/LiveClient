package com.qpidnetwork.livemodule.httprequest.item;

import java.io.Serializable;

public class LSValidSiteIdItem implements Serializable {
	/**
	 *
	 */
	private static final long serialVersionUID = 7788548955355612335L;
	public LSValidSiteIdItem() {

	}

	/**
	 * 可登录的站点
	 * @param siteId			网站ID
	 * @param isLive			是否直播站点
	 */
	public LSValidSiteIdItem(
			int siteId,
			boolean isLive
			) {
		this.siteId = siteId;
		this.isLive = isLive;
	}
	
	public int siteId;
	public boolean isLive;
}
