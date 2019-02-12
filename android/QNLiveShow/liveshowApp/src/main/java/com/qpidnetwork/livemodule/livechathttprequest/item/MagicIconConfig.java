package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

/**
 * 获取魔法小表情配置
 * @author Hunter
 * @since 2016.4.7
 */
public class MagicIconConfig implements Serializable{

	private static final long serialVersionUID = 7264570781882164953L;
	public MagicIconConfig(){
		
	}
	
	/**
	 * 
	 * @param path 基础路径（用于获取分类及MagicIcon图标路径）
	 * @param updatetime 最后更新时间
	 * @param magicIconArray MagicIcon 列表
	 * @param magicTypeArray 分类列表
	 */
	public MagicIconConfig(
			String path,
			int updatetime,
			MagicIconItem[] magicIconArray,
			MagicIconType[] magicTypeArray){
		this.path = path;
		this.maxupdatetime = updatetime;
		this.magicIconArray = magicIconArray;
		this.magicTypeArray = magicTypeArray;
	}
	public String path;
	public int maxupdatetime;
	public MagicIconItem[] magicIconArray;
	public MagicIconType[] magicTypeArray;
}
