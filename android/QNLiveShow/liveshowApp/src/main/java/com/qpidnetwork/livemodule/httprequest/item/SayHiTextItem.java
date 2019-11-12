package com.qpidnetwork.livemodule.httprequest.item;

/**
 * SayHi文本信息Item
 * @author Alex
 *
 */
public class SayHiTextItem {

	public SayHiTextItem(){

	}

	/**
	 * SayHi文本信息Item
	 * @param textId	文本ID
	 * @param text		文本内容
	 */
	public SayHiTextItem(
                         String textId,
                         String text){
		this.textId = textId;
		this.text = text;

	}
	
	public String textId;
	public String text;


	@Override
	public String toString() {
		return "SayHiTextItem[textId:"+textId
				+ " text:"+text
				+ "]";
	}
}
