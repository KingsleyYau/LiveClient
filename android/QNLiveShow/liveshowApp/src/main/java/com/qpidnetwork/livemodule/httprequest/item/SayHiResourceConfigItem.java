package com.qpidnetwork.livemodule.httprequest.item;

/**
 * SayHi用到的主题和文本
 * @author Alex
 *
 */
public class SayHiResourceConfigItem {

	public SayHiResourceConfigItem(){

	}

	/**
	 * SayHi主题信息Item
	 * @param themeList		主题列表
	 * @param textList		文本列表
	 */
	public SayHiResourceConfigItem(
			SayHiThemeItem[] themeList,
			SayHiTextItem[] textList){
		this.themeList = themeList;
		this.textList = textList;

	}
	
	public SayHiThemeItem[] themeList;
	public SayHiTextItem[] textList;


	@Override
	public String toString() {
		return "SayHiResourceConfigItem[]";
	}
}
