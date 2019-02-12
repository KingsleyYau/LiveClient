package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

public class OtherEmotionConfigItem implements Serializable {
	private static final long serialVersionUID = 7655480159263070906L;
	/**
	 * 终端使用标志（男士端/女士端） ，type及tag使用到
	 */
	public enum ToFlagType {
		FORMAN,		// 男士端
		FORLADY,	// 女士端
		UNKNOW		// 未知类型
	}
	
	public OtherEmotionConfigItem() {
		
	}

	/**
	 * 
	 * @param version			高级表情版本号
	 * @param path				路径
	 * @param typeList			分类列表
	 * @param tagList			tag列表
	 * @param manEmotionList	男士表情列表
	 * @param ladyEmotionList	女士表情列表
	 */
	public OtherEmotionConfigItem(
			int version,
			String path,
			OtherEmotionConfigTypeItem[] typeList,
			OtherEmotionConfigTagItem[] tagList,
			OtherEmotionConfigEmotionItem[] manEmotionList,
			OtherEmotionConfigEmotionItem[] ladyEmotionList
			) {
		this.version = version;
		this.path = path;
		this.typeList = typeList;
		this.tagList = tagList;
		this.manEmotionList = manEmotionList;
		this.ladyEmotionList = ladyEmotionList;
	}
	
	public int version;
	public String path;
	public OtherEmotionConfigTypeItem[] typeList;
	public OtherEmotionConfigTagItem[] tagList;
	public OtherEmotionConfigEmotionItem[] manEmotionList;
	public OtherEmotionConfigEmotionItem[] ladyEmotionList;
}
