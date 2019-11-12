package com.qpidnetwork.livemodule.httprequest.item;

/**
 * SayHi主题信息Item
 * @author Alex
 *
 */
public class SayHiThemeItem {

	public SayHiThemeItem(){

	}

	/**
	 * SayHi主题信息Item
	 * @param themeId		主题ID
	 * @param themeName		主题名称
	 * @param smallImg		小图
	 * @param bigImg		大图
	 */
	public SayHiThemeItem(
                         String themeId,
                         String themeName,
						 String smallImg,
						 String bigImg){
		this.themeId = themeId;
		this.themeName = themeName;
		this.smallImg = smallImg;
		this.bigImg = bigImg;
	}
	
	public String themeId;
	public String themeName;
	public String smallImg;
	public String bigImg;


	@Override
	public String toString() {
		return "SayHiThemeItem[themeId:"+themeId
				+ " themeName:"+themeName
				+ " smallImg:"+smallImg
				+ " bigImg:"+bigImg
				+ "]";
	}
}
