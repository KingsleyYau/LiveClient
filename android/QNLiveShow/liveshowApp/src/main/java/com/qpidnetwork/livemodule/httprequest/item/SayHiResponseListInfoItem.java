package com.qpidnetwork.livemodule.httprequest.item;

/**
 * Say Hi的Response列表信息Item
 * @author Alex
 *
 */
public class SayHiResponseListInfoItem {

	public SayHiResponseListInfoItem(){

	}

	/**
	 * Say Hi的Response列表信息Item
	 * @param totalCount	总数
	 * @param responseList	Response列表
	 */
	public SayHiResponseListInfoItem(
                         int totalCount,
						 SayHiResponseListItem[] responseList){
		this.totalCount = totalCount;
		this.responseList = responseList;

	}
	
	public int totalCount;
	public SayHiResponseListItem[] responseList;

	@Override
	public String toString() {
		return "SayHiResponseListInfoItem[totalCount:"+totalCount
				+ "]";
	}
}
