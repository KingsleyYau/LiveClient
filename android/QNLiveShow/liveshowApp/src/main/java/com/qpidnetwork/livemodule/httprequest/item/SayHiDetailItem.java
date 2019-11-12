package com.qpidnetwork.livemodule.httprequest.item;

/**
 * Say Hi详情的主播Item
 * @author Alex
 *
 */
public class SayHiDetailItem {

	public SayHiDetailItem(){

	}

	/**
	 * Say Hi详情的主播Item
	 * @param detail		详情
	 * @param responseList	sayHi回复列表
	 *
	 */
	public SayHiDetailItem(
			SayHiDetailAnchorItem detail,
			SayHiDetailResponseListItem[] responseList){
		this.detail = detail;
		this.responseList = responseList;

	}

	public SayHiDetailAnchorItem detail;
	public SayHiDetailResponseListItem[] responseList;

	@Override
	public String toString() {
		return "SayHiDetaiItem[sayHiId:"
				+ "]";
	}
}
