package com.qpidnetwork.livemodule.httprequest.item;

import java.io.Serializable;

public class LSOtherVersionCheckItem implements Serializable {
	/**
	 *
	 */
	private static final long serialVersionUID = 8173045249677502189L;
	public LSOtherVersionCheckItem() {

	}

	/**
	 *
	 * @param verCode	客户端内部版本号
	 * @param verName	客户端显示版本号
	 * @param verDesc	版本描述
	 * @param url		Android客户端下载URL
	 * @param pubTime	发布时间
	 * @param checkTime	检测更新时间
	 * @param isForceUpdate 	是否强制升级（ture：是，false：否）
	 */
	public LSOtherVersionCheckItem(
			int verCode,
			String verName,
			String verDesc,
			String url,
			String storeUrl,
			String pubTime,
			int checkTime,
			boolean isForceUpdate
			) {
		this.verCode = verCode;
		this.verName = verName;
		this.verDesc = verDesc;
		this.url = url;
		this.storeUrl = storeUrl;
		this.pubTime = pubTime;
		this.checkTime = checkTime;
		this.isForceUpdate = isForceUpdate;
	}
	
	public int verCode;
	public String verName;
	public String verDesc;
	public String url;
	public String storeUrl;
	public String pubTime;
	public int checkTime;
	public boolean isForceUpdate;
}
