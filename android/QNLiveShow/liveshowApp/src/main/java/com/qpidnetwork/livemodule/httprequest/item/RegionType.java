package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 主播在线状态
 * @author Hunter Mun
 *
 */
public enum RegionType {
	//对应QN的WebSiteManager.ParsingWebSiteLocalId()站点本地ID
	Unknown(-1),
	regionCD(4),	    // CD
	regionLD(8),		// LD
	regionAME(16);       // AME

	private int value = 0;

	private RegionType(int value){
		this.value = value;
	}

	public static RegionType valueOf(int value){   //   手写的从int到enum的转换函数
		switch(value) {
			case 4:
				return regionCD;
			case 8:
				return regionLD;
			case 16:
				return regionAME;
			default:
				return Unknown;
		}
	}

	public int value() {
		return this.value;
	}
}
