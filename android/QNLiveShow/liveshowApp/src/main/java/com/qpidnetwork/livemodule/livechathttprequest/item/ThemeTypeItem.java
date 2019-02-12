package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

public class ThemeTypeItem implements Serializable{

	private static final long serialVersionUID = -5520671314258072546L;
	
	public ThemeTypeItem(){
		
	}
	
	/**
	 * 主题分类描述
	 * @param typeId	主题分类Id
	 * @param typeName	主题分类名称
	 */
	public ThemeTypeItem(String typeId,
				String typeName){
		this.typeId = typeId;
		this.typeName = typeName;
	}
	
	public String typeId;
	public String typeName;
}
