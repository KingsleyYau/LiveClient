package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

public class OtherEmotionConfigTypeItem implements Serializable  {
	/**
	 * 
	 */
	private static final long serialVersionUID = 93653417066013896L;
	public OtherEmotionConfigTypeItem() {
		
	}

	/**
	 * 
	 * @param toflag	终端使用标志（男士端/女士端）
	 * @param typeId	分类ID
	 * @param typeName	分类名称
	 */
	public OtherEmotionConfigTypeItem(
			int toflag,
			String typeId,
			String typeName
			) {
		this.toflag = toflag;
		this.typeId = typeId;
		this.typeName = typeName;
	}
	
	public int toflag;
	public String typeId;
	public String typeName;
}
