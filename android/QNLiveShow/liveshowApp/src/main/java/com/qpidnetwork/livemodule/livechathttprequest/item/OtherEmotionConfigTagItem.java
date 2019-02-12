package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

public class OtherEmotionConfigTagItem implements Serializable  {
	/**
	 * 
	 */
	private static final long serialVersionUID = -6501153152343544529L;
	public OtherEmotionConfigTagItem() {
		
	}

	/**
	 * 
	 * @param toflag	终端使用标志（男士端/女士端）
	 * @param typeId	分类ID
	 * @param tagId		tag ID
	 * @param tagName	tag名称
	 */
	public OtherEmotionConfigTagItem(
			int toflag,
			String typeId,
			String tagId,
			String tagName
			) {
		this.toflag = toflag;
		this.typeId = typeId;
		this.tagId = tagId;
		this.tagName = tagName;
	}
	
	public int toflag;
	public String typeId;
	public String tagId;
	public String tagName;
}
