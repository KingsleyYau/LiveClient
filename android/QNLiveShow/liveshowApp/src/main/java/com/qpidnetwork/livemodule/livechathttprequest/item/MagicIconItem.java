package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

/**
 * Magic icon item
 * @author Hunter
 * @since 2016.4.7
 */
public class MagicIconItem implements Serializable{

	private static final long serialVersionUID = -9192183913346483739L;
	public MagicIconItem(){
		
	}
	
	/**
	 * 
	 * @param id  id
	 * @param title 标题（描述）
	 * @param price 价格
	 * @param hotFlag 当前状态
	 * @param typeId 所属分类Id
	 * @param updatetime 最后更新时间
	 */
	public MagicIconItem(
			String id,
			String title,
			double price,
			int hotFlag,
			String typeId,
			int updatetime){
		this.id = id;
		this.title = title;
		this.price = price;
		this.hotFlag = HotFlag.values()[hotFlag];
		this.typeId = typeId;
		this.updatetime = updatetime;
	}
	
	public String id;
	public String title;
	public double price;
	public HotFlag hotFlag;
	public String typeId;
	public int updatetime;
	public enum HotFlag{
		Default,
		NEW,
		HOT
	}
}
