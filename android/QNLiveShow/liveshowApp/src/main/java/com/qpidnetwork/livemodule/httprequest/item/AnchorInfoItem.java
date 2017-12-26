package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 主播信息Item
 * @author Hunter Mun
 *
 */
public class AnchorInfoItem {

	public AnchorInfoItem(){
		
	}
	
	/**
	 * 主播信息Item
	 * @param address			联系地址
	 * @param anchorType		主播类型
	 * @param isLive			是否正在公开直播
	 * @param introduction		主播个人介绍
	 */
	public AnchorInfoItem(String address,
	 						int anchorType,
	 						boolean isLive,
	 						String introduction){
		this.address = address;
		if( anchorType < 0 || anchorType >= AnchorLevelType.values().length ) {
			this.anchorType = AnchorLevelType.Unknown;
		} else {
			this.anchorType = AnchorLevelType.values()[anchorType];
		}
		this.isLive = isLive;
		this.introduction = introduction;

	}
	
	public String address;
	public AnchorLevelType anchorType;
	public boolean isLive;
	public String introduction;


	@Override
	public String toString() {
		return "AnchorInfoItem[address:"+address
				+ " anchorType:"+anchorType
				+ " isLive:"+isLive
				+ " introduction:"+introduction
				+ "]";
	}
}
