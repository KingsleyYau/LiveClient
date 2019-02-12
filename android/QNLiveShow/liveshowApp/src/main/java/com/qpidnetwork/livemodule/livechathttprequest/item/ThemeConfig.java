package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

public class ThemeConfig implements Serializable{

	private static final long serialVersionUID = -8144734894653323998L;
	
	public ThemeConfig(){
		
	}
	
	/**
	 * 主题配置Bean
	 * @param themeVersion 	主题版本
	 * @param themePath		主题基础路径
	 * @param themeTypeList	主题类型列表
	 * @param themeTagList	主题标签列表
	 * @param themeItemList	所有主题详情列表
	 */
	public ThemeConfig(String themeVersion,
				String themePath,
				ThemeTypeItem[] themeTypeList,
				ThemeTagItem[] themeTagList,
				ThemeItem[] themeItemList){
		this.themeVersion = themeVersion;
		this.themePath = themePath;
		this.themeTypeList = themeTypeList;
		this.themeTagList = themeTagList;
		this.themeList = themeItemList;
	}
	
	public String themeVersion;
	public String themePath;
	public ThemeTypeItem[] themeTypeList;
	public ThemeTagItem[] themeTagList;
	public ThemeItem[] themeList;
}
