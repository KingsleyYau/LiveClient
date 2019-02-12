package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

/**
 * Magic Icon Type
 * @author Hunter 
 * @since 2016.4.7
 */
public class MagicIconType implements Serializable{

	private static final long serialVersionUID = 6940066896185233829L;
	public MagicIconType(){
		
	}
	/**
	 * 
	 * @param id typeId
	 * @param title typeTitle
	 */
	public MagicIconType(
			String id,
			String title){
		this.id = id;
		this.title = title;
	}
	public String id;
	public String title;
}
