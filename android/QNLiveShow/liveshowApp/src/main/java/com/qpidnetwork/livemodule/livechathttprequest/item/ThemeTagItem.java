package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

public class ThemeTagItem implements Serializable{

	private static final long serialVersionUID = -6664188316097031022L;
	
	public ThemeTagItem(){
		
	}
	
	/**
	 * 标签数据结构
	 * @param tagId		标签Id
	 * @param typeId	标签所属分类Id
	 * @param tagName	标签名
	 */
	public ThemeTagItem(String tagId,
			String typeId,
			String tagName){
		this.tagId = tagId;
		this.typeId = typeId;
		this.tagName = tagName;
	}
	
	public String tagId;
	public String typeId;
	public String tagName;

}
