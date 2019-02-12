package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

public class ThemeItem implements Serializable{
	
	private static final long serialVersionUID = 9184803509806217964L;
	
	public ThemeItem(){
		
	}
	
	/**
	 * 单个主题Item详细描述
	 * @param themeId 主题Id
	 * @param price   主题价格
	 * @param isNew   是否是最新主题
	 * @param isSale  是否是促销主题
	 * @param typeId  所属分类Id
	 * @param tagId  所属标签Id
	 * @param title   主题标题
	 * @param validSecond  主题有效时长
	 * @param themeType    主题类型
	 * @param description  主题描述
	 */
	public ThemeItem(String themeId,
			double price,
			boolean isNew,
			boolean isSale,
			String typeId,
			String tagId,
			String title,
			int validSecond,
			int themeType,
			String description){
		this.themeId = themeId;
		this.price = price;
		this.isNew = isNew;
		this.isSale = isSale;
		this.typeId = typeId;
		this.tagId = tagId;
		this.title = title;
		this.validsecond = validSecond;
		this.themeType = ThemeType.values()[themeType];
		this.description = description;
	}

	public String themeId;
	public double price;
	public boolean isNew;
	public boolean isSale;
	public String typeId;
	public String tagId;
	public String title;
	public int validsecond;
	public ThemeType themeType;
	public String description;
	
	public enum ThemeType{
		BASE_THEME,
		ADVANSE_THEME
	}
}
