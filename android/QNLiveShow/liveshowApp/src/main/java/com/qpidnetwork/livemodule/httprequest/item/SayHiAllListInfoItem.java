package com.qpidnetwork.livemodule.httprequest.item;

/**
 * Say Hi的All列表信息Item
 * @author Alex
 *
 */
public class SayHiAllListInfoItem {

	public SayHiAllListInfoItem(){

	}

	/**
	 * Say Hi的All列表信息Item
	 * @param totalCount	总数
	 * @param allList		All列表
	 */
	public SayHiAllListInfoItem(
                         int totalCount,
                         SayHiAllListItem[] allList){
		this.totalCount = totalCount;
		this.allList = allList;

	}
	
	public int totalCount;
	public SayHiAllListItem[] allList;

	@Override
	public String toString() {
		return "SayHiAllListInfoItem[totalCount:"+totalCount
				+ "]";
	}
}
